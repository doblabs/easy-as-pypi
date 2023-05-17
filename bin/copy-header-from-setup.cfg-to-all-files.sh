#!/usr/bin/env bash
# vim:tw=0:ts=2:sw=2:et:norl:nospell
# Project: https://github.com/pydob/easy-as-pypi#🥧
# License: MIT

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

BASH_SOURCE_DIR="$(dirname -- "${BASH_SOURCE[0]}")"

update_copy_headers () {
  local header_len=${1:-"-5"}
  local refhdr
  local grep0
  local grepn
  local headr

  local source_path="setup.cfg"

  if [ "${header_len}" != "-3" ] && [ "${header_len}" != "-5" ]; then
    >&2 echo "ERROR: Please specify a header_len of '-3' or '-5'."
    exit 1
  fi

  . "${BASH_SOURCE_DIR}/clone-and-rebrand-easy-as-pypi.sh"
  # Load source_appname_train, source_header_copy_years, source_header_copy_names.
  setup_source_string_matching

  set -e

  # Load the header containing copy header to spread.
  # In this example, the header is the first 5 lines.
  #   refhdr="$(head -5 /path/to/project/seeded/by/easy-as-pypi/setup.cfg)"
  # 2020-11-28 19:13: except now caller specifies header len (-3 or -5),
  # which so far is 3 to include "This files exists within", blank, and the
  # project URL lines; or 5 to also include another blank and then copyright.
  refhdr="$(head ${header_len} "${source_path}")"

  grep0="^# This file exists within '${source_appname_train}':$"

  grepn="^# Copyright © ${source_header_copy_years} ${source_header_copy_names}\. All rights reserved\.$"
  if [ "${header_len}" = "-3" ]; then
    # E.g., "^#   https://github.com/pydob/easy-as-pypi#🥧$"
    grepn="^#   ${source_header_projecturl}$"
  fi

  # Escape the double quotes, lest what's in them be dropped by awk.
  # Note the head -c -3 to remove trailing newline.
  headr="$(
    echo "${refhdr}" |
    awk '{printf "%s\\n",$0} END {print ""}' |
    head -c -3 |
    sed "s/\"/\\\\\"/g"
  )"
  # Curious:
  #  echo "${headr}"

  # *** Long AWK script explanations ahead!!

  # Note re: awk multiline pattern matching:
  # - If first line matches, but not last, then awk spits out nothing.
  #   - Cannot [ -s $file ]-check that it's nonempty, because head gets dumped.
  #   - So loop inclusively, but use inner grep to check full copy header found.
  #
  # (More wordy explanation):
  # Do a double-grep to find files to process -- the first grep looks
  # for the first line match, then loop over those files, but grep a
  # second time to verify the second line is also found (otherwise our
  # awk script would mutate the input text because it's not coded to
  # handle not finding a line to match the second regex).
  # - History: One trick I like is `git ls-files | while read file; do` but
  #   but we need to double-grep to guard against awking non-matching files.
  #   - I.e., if first line matches, but not last, then awk spits out nothing.
  #   - And cannot run [ -s $tmpXXX ] on awk output, because head gets dumped.
  # - So do the loop, but use a separate grep to ensure full copy header found.

  # NOTE: We use an alternative range pattern format below.
  #
  #       - The simple range pattern format is:
  #
  #           awk '/start/,/end/' myfile
  #
  #         which specifies the so-called 'begpat' and 'endpat' on/off
  #         patterns using *literal* values.
  #
  #         - See *7.1.3 Specifying Record Ranges with Patterns*:
  #
  #           https://www.gnu.org/software/gawk/manual/gawk.html#Ranges
  #
  #       - But we want to specify the patterns using awk variables,
  #         which is possible using 'dynamic' aka 'computed regexp', e.g.,:
  #
  #           awk 'BEGIN { start="start"; end="end" } $0 ~ start,$0 ~ end' myfile
  #
  #         - See *3.6 Using Dynamic Regexps*:
  #
  #           https://www.gnu.org/software/gawk/manual/gawk.html#Computed-Regexps
  #
  #       - Explainer:
  #
  #         - If we used the simple range pattern format, e.g.,
  #
  #             awk '/start/,/end/' myfile
  #
  #           we'd need to escape the patterns, if necessary, e.g.,
  #
  #             /https://domain.tld//
  #
  #           would need to be escaped as:
  #
  #             /https:\\/\\/domain.tld\\//
  #
  #           so as to avoid conflicting with awk's forward slash /regex/
  #           delimiters (that I could not find a way to change).
  #
  #         - But we want the patterns to be passed from the caller,
  #           so we'll have to sanitize the values ourself.
  #
  #           - One option is to use awk to escape the escapes, e.g.,
  #
  #               gsub(/\\//, \"\\\\/\", start)
  #
  #             However, the simple range pattern format does not let us use
  #             variables, e.g., `/start/,/end/` is taken literally, and the
  #             value of any variable named `start` is not substituted.
  #
  #           - Another option would be to sanitize the Bash variable first,
  #             e.g.,
  #
  #               line0=$(sanitize_awk_value $line0)
  #               linen=$(sanitize_awk_value $linen)
  #               awk "/$line0/,/$linen/" myfile
  #
  #             but it's easier to use dynamic regexp instead, as detailed
  #             earlier, which doesn't use surrounding regexp /slashes/.
  #
  #             So you'll see below:
  #
  #               \$0 ~ grep0,\$0 ~ grepn { found_it = 1; next };

  # NOTE: Use grep -R not grep -r to also include symbolic links
  #       (such as a private .ignore or .gitignore.local you may have).

  # Test grep #1 (copy-paste to your terminal to inspect):
  _cxpx_test_grep_outer () {
    grep -l -I -R -e "${grep0}" . --exclude-dir=build/ --exclude-dir=.git/
  }
  #
  # Test grep #2: (or uncomment 'continue' in final run, below):
  _cxpx_test_grep_inner () {
    grep -l -I -R -e "${grep0}" . --exclude-dir=build/ --exclude-dir=.git/ |
      while read file; do
        ! grep -e "${grepn}" ${file} > /dev/null && continue
        echo "Processing: ${file}"
      done
  }
  #
  # The actual grep-to-awk.
  grep -l -I -R -e "${grep0}" . --exclude-dir=build/ --exclude-dir=.git/ |
    while read file; do
      # If the file does not have match for final endpat/off, skip it
      # (lest we replace all contents, from grep0 to end of the file).
      ! grep -e "${grepn}" ${file} > /dev/null && continue

      echo "Processing: ${file}"
      # DEV: Uncomment this `continue` to just show files that would be processed.
      #  continue

      awk "
        BEGIN {
          headr = \"${headr}\"
          grep0 = \"${grep0}\"
          grepn = \"${grepn}\"
          # DEV: Uncommend to inspect:
          #  print \"grep0 = \" grep0 > \"/dev/stderr\"
          #  print \"grepn = \" grepn > \"/dev/stderr\"
        }
        \$0 ~ grep0,\$0 ~ grepn { found_it = 1; next };
        found_it == 1 { found_it = 0; print "headr" }
        # 2020-11-28: My orig. copy-paste code was this, but it adds
        #             an empty line after placing the new header...
        #   \$0 ~ /^\$/ && ignore_nls == 1 { next }
        #   found_it == 1 { found_it = 0; ignore_nls = 1; print "headr" }
        #   ignore_nls == 1 { ignore_nls = 0; print \"\" }
        # - so just always print the line:
        1
      " ${file} > tmpXXX && /bin/mv tmpXXX ${file}

    # YOU: Uncomment to test just one loop's worth.
    #  break
    done
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ #

main () {
  update_copy_headers "$@"
}

# +++

if [ "$0" = "${BASH_SOURCE[0]}" ]; then
  main "$@"
else
  >&2 echo "ERROR: Try executing this file instead."
  false
fi

