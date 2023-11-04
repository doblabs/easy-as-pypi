#!/bin/bash
# vim:tw=0:ts=2:sw=2:et:norl:nospell:ft=bash
# Author: Landon Bouma <https://tallybark.com/>
# Project: https://github.com/thegittinsgood/git-update-faithful#⛲
# License: MIT

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# This intermediate file is used to track the canon SHA across runs,
# before the final commit action.
UPDEPS_CACHE_BASE="${UPDEPS_CACHE_BASE:-${UPDEPS_CACHE_DIR:-.git}/ohmyrepos-update-faithful-cache-}"
# The cache contains PID of process or parent, depending.
UPDEPS_CACHE_FILE="${UPDEPS_CACHE_FILE:-${UPDEPS_CACHE_BASE}$$}"

# Call either sets this directly or passes to update-faithful-begin.
UPDEPS_CANON_BASE_ABSOLUTE="${UPDEPS_CANON_BASE_ABSOLUTE}"

# ***

# Trace message switch.
DTRACE=false
# DEV/YOU: Uncomment to spit trace to stderr.
#  DTRACE=true

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

source_deps () {
  # Ensure coreutils installed (from Linux pkg mgr, or from macOS Homebrew).
  insist_cmd 'realpath'

  # Load the logger library, from github.com/landonb/sh-logger.
  # - Includes print commands: info, warn, error, debug.
  source_dep "deps/sh-logger/bin/logger.sh"
  set_logger_log_level

  source_dep_git_put_wise
}

set_logger_log_level () {
  # Note that LOG_LEVEL unset at first, then logger.sh defaults to
  # LOG_LEVEL_ERROR (40), but we want our `info` messages to shine.
  # - Here we let user override our new default (Debug and higher).
  # - This verifies UF_LOG_LEVEL is an integer. Note the -eq spews
  #   when it fails, e.g.:
  #     bash: [: <foo>: integer expression expected
  [ -n "${UF_LOG_LEVEL}" ] \
    && ! [ ${UF_LOG_LEVEL} -eq ${UF_LOG_LEVEL} ] \
    && >&2 echo "WARNING: Resetting UF_LOG_LEVEL, not an integer" \
    && export UF_LOG_LEVEL=
  # Default log level: Debug and higher.
  LOG_LEVEL=${UF_LOG_LEVEL:-${LOG_LEVEL_DEBUG}}
}

# Optional: git-put-wise, for 'identify_scope_ends_at'.
#   https://github.com/DepoXy/git-put-wise#🥨
source_dep_git_put_wise () {
  command -v git-put-wise > /dev/null \
    || return

  local put_wise_bin="$(dirname "$(realpath "$(command -v git-put-wise)")")"

  # CXREF: https://github.com/landonb/sh-git-nubs#🌰
  #   ~/.kit/sh/sh-git-nubs/bin/git-nubs.sh
  . "${put_wise_bin}/../deps/sh-git-nubs/bin/git-nubs.sh"

  . "${put_wise_bin}/../lib/common_put_wise.sh"
  . "${put_wise_bin}/../lib/dep_apply_confirm_patch_base.sh"
}

# ***

insist_cmd () {
  local cmdname="$1"

  command -v "${cmdname}" > /dev/null && return 0

  >&2 echo "ERROR: Missing system command ‘${cmdname}’."

  exit 1
}

source_dep () {
  local dep_path="$1"

  # The executables are at bin/*, so project root is one level up.
  local project_root
  project_root="$(dirname "$(realpath "$0")")/.."

  local dep_path="${project_root}/${dep_path}"

  if [ ! -f "${dep_path}" ]; then
    # Or maybe user is trying to source from their terminal.
    if $(printf %s "$0" | grep -q -E '(^-?|\/)(ba|da|fi|z)?sh$' -); then
      if [ -n "${BASH_SOURCE[0]}" ]; then
        # The lib is at lib/update-faithful.sh so project root is one level up.
        project_root="$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.."
      fi
    fi

    dep_path="${project_root}/${dep_path}"
  fi

  if [ ! -f "${dep_path}" ]; then
    >&2 echo "ERROR: Could not identify update-faithful dependency path."
    >&2 echo "- Hint: Did you *copy* bin/update-faithful.sh somewhere on PATH?"
    >&2 echo "  - Please use a symlink instead."
    >&2 echo "- Our incorrect dependency path guess: “${dep_path}”"

    exit 1
  fi

  . "${dep_path}"
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

update-faithful-file () {
  update_faithful_file "$@"
}

update_faithful_file () {
  local local_file="$1"
  # Canon paths are optional.
  # - Default canon file relative path same as local_file (a relative path).
  local canon_file_relative="$2"
  # - Default canon project path what caller set via update-faithful-begin,
  #   or if they set UPDEPS_CANON_BASE_ABSOLUTE directly. Otherwise caller
  #   could override using function arg, but that'd probably be a strange
  #   use case.
  local canon_base_absolute="${3:-${UPDEPS_CANON_BASE_ABSOLUTE}}"

  if [ -z "${canon_file_relative}" ]; then
    canon_file_relative="${local_file}"
  fi

  local canon_file_absolute="${canon_base_absolute}/${canon_file_relative}"

  # ***

  local success=true

  if ${success} && ! must_pass_checks_and_ensure_cache \
    "${canon_base_absolute}" "${canon_file_absolute}" "${local_file}" \
  ; then
    # Soft-fail. Note that must_pass_checks_and_ensure_cache only returns
    # nonzero if canon file has changes (if anything else wrong, it exits).
    success=false
  fi

  # ***

  # If update-faithful called on a canon project file itself, skip it.
  local local_file_realpath="$(realpath "${local_file}")"
  local canon_file_realpath="$(realpath "${canon_file_absolute}")"

  if [ "${local_file_realpath}" = "${canon_file_realpath}" ]; then
    local what_happn="is canon"

    print_update_faithful_progress_info "${local_file}" "${what_happn}"

    return 0
  fi

  # ***

  local canon_head
  canon_head="$(print_canon_scoped_head "${canon_file_absolute}")"

  if ${success} && ! examine_and_update_local_from_canon \
    "${local_file}" "${canon_file_absolute}" "${canon_file_relative}" "${canon_head}" \
  ; then
    success=false
  fi

  if ! ${success}; then
    handle_failed_state "${canon_head}" "${canon_file_absolute}"

    return 1
  fi
}

# ***

must_pass_checks_and_ensure_cache () {
  local canon_base_absolute="$1"
  local canon_file_absolute="$2"
  local local_file="$3"

  local is_update_begin=false
  [ -n "${local_file}" ] || is_update_begin=true
  must_git_nothing_or_only_deletes_staged_or_faithful_update_underway ${is_update_begin}

  cache_file_ensure_exists

  if [ -z "${canon_base_absolute}" ] && [ -z "${canon_file_absolute}" ]; then
    # Path via remove-faithful-file (don't care about rest).
    return 0
  fi

  # Exit if canon path not a directory.
  must_canon_base_is_dir "${canon_base_absolute}"

  if [ -n "${canon_file_absolute}" ]; then
    # Exit if not file and exists.
    must_be_file "${canon_file_absolute}" "reference"

    if [ -n "$(
      cd "${canon_base_absolute}"

      git status --porcelain=v1 -- "${canon_file_absolute}"
    )" ]; then
      # If we don't exit here, user sees "Cannot update changed and divergent follower file"
      # message (warn_diverged_and_uncommitted) which is misleading when it's the canon file's
      # fault, not follower's.
      >&2 error "ERROR: The canon reference file has uncommitted changes: “${canon_file_absolute}”"

      # Rather than exit, let caller cleanup (e.g., unstage changes).
      return 1
    fi
  fi

  if [ -n "${local_file}" ]; then
    # Exit if exists but not file.
    must_be_file_or_absent "${local_file}" "local"

    # For template render or canon copy, ensure directory path exists.
    local local_base
    local_base="$(dirname "${local_file}")"

    command mkdir -p "${local_base}"
  fi
}

# ***

must_git_nothing_or_only_deletes_staged_or_faithful_update_underway () {
  local is_update_begin="$1"

  ( git_nothing_staged \
    || cache_file_nonempty \
  ) && return 0

  # Something is staged, and cache file not started, so this is
  # first update-faithful. If only deletes staged, we assume user
  # git-rm'd divergent files and wants to commit with updates (as
  # opposed to committing git-rm files, running update-faithful,
  # then squashing the two commits).
  if ! git_nothing_staged && git_only_delete_files_staged; then
    # So that we only print the alert once, skip on update-faithful-begin.
    if ! ${is_update_begin}; then
      warn "ALERT: Starting update-faithful on a repo with deletes staged."
      info "- These files will be incorporated into the update-faithful commit:"

      git_print_staged_files
    fi

    return 0
  fi

  local projpath="${1:-$(pwd)}"

  warn "ERROR: Cannot start update-faithful on a repo with staged changes."
  warn "- See for yourself:"
  warn "  "
  warn "    cd \"${projpath}\" && git status"

  exit 1
}

git_nothing_staged () {
  git diff --cached --quiet
}

git_only_delete_files_staged () {
  [ -z "$(git diff --cached --name-status | sed '/^D\t/d')" ]
}

git_print_staged_files () {
  git --no-pager diff --cached --name-only
}

# ***

must_canon_base_is_dir () {
  local canon_base_absolute="$1"

  if [ ! -d "${canon_base_absolute}" ]; then
    >&2 error "ERROR: Canon path not a dir: “${canon_base_absolute}”"
    >&2 error "- HINT: Specify the canon base path before updating:"
    >&2 error "        - Set UPDEPS_CANON_BASE_ABSOLUTE environ"
    >&2 error "        - Or call \`update-faithful-begin\` first"

    exit 1
  fi
}

must_be_file () {
  local file="$1"
  local what="$2"
  local absent_ok="${3:-false}"

  if [ -z "${file}" ]; then
    >&2 error "ERROR: Please specify the update-faithful ${what} file path"

    exit 1
  elif [ ! -f "${file}" ] && ( ! ${absent_ok} || [ -e "${file}" ] ); then
    >&2 error "ERROR: The update-faithful ${what} file path is not a file: “${file}”"

    exit 1
  fi
}

must_be_file_or_absent () {
  local file="$1"
  local what="$2"

  local absent_ok=true

  must_be_file "$1" "$2" ${absent_ok}
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

examine_and_update_local_from_canon () {
  local local_file="$1"
  local canon_file_absolute="$2"
  local canon_file_relative="$3"
  local canon_head="$4"

  local local_changed=false
  local local_strayed=false
  local local_matches_HEAD=false

  insist_canon_head_consistent "${canon_head}" "${canon_file_absolute}"

  # If ${file} absent, git-status prints nothing and exits zero.
  has_no_changes "${local_file}" \
    || local_changed=true

  # If ${file} absent, diff exits nonzero.
  has_no_diff "${local_file}" "${canon_file_absolute}" "${canon_file_relative}" "${canon_head}" \
    || local_strayed=true

  # See if local file matches canon's HEAD version.
  local canon_head_private
  canon_head_private="$(print_canon_head "${canon_file_absolute}")"

  if [ "${canon_head}" != "${canon_head_private}" ]; then
    has_no_diff "${local_file}" "${canon_file_absolute}" "${canon_file_relative}" "${canon_head_private}" \
      && local_matches_HEAD=true || local_matches_HEAD=false
  fi

  # ***

  update_local_from_canon \
    "${local_file}" \
    "${canon_file_absolute}" \
    "${canon_file_relative}" \
    "${canon_head}" \
    "${canon_head_private}" \
    "${local_changed}" \
    "${local_strayed}" \
    "${local_matches_HEAD}"
}

# ***

print_canon_head () {
  local canon_file_absolute="$1"
  local use_scoping="${2:-false}"

  (
    cd "$(dirname "${canon_file_absolute}")"

    local canon_head="HEAD"

    # Optional: git-put-wise scope logic.
    if ${use_scoping} && command -v identify_scope_ends_at > /dev/null; then
      # Exclude latest commits whose messages start with "PRIVATE: " or
      # "PROTECTED: ". Use case: So you can keep some stuff private to
      # your local repo without needing to maintain a separate feature
      # branch.
      canon_head="$( \
        identify_scope_ends_at "^${SCOPING_PREFIX}" "^${PRIVATE_PREFIX}" \
      )"
    fi

    # identify-scope postfixes '^' parent shortcut, but we'll
    # deference for the commit message.

    printf "%s" "$(git rev-parse "${canon_head}")"
  )
}

print_canon_scoped_head () {
  local canon_file_absolute="$1"

  local use_scoping=true

  print_canon_head "${canon_file_absolute}" "${use_scoping}"
}

# ***

insist_canon_head_consistent () {
  local canon_head="$1"
  local canon_file_absolute="$2"

  cache_file_nonempty \
    || return 0

  local cached_head="$(cache_file_read_cached_head)"

  test "${canon_head}" != "${cached_head}" \
    || return 0

  # We'll leave the repo in its current, failure state,
  # as opposed to cleaning up (`git reset HEAD`, perhaps,
  # and removing the cache file).
  # - This seems like a DEV error, so shouldn't happen
  #   regularly, or really at all, seems like a rarity.

  local projpath="${1:-$(pwd)}"

  >&2 error "ERROR: Latest update-faithful canon HEAD changed?!"
  >&2 error "- Reference file: ${canon_file_absolute}"
  >&2 error "- Cached git ref: ${cached_head}"
  >&2 error "- Latest git ref: ${canon_head}"
  >&2 error "  "
  >&2 error "- You'll need to resolve the issue yourself, and to cleanup:"
  >&2 error "  "
  >&2 error "   cd \"${projpath}\""
  >&2 error "   git reset HEAD"
  >&2 error "   command rm \"${UPDEPS_CACHE_FILE}\""

  exit 1
}

# ***

# Ensure cache exists, so the `awk` are happy.
cache_file_ensure_exists () {
  if ! test -e "${UPDEPS_CACHE_FILE}"; then
    info
    info "┌── Starting update-faithful operation ─── Hold onto your butts!"
    info

    UPDEPS_MELD_CMP_LIST=""
    UPDEPS_CMD_RM_F_LIST=""
    UPDEPS_GIT_RM_F_LIST=""

    # Cleanup old cache files (from failed runs).
    cache_file_cleanup
  fi

  local cache_dir="$(dirname "${UPDEPS_CACHE_FILE}")"

  if [ ! -d "${cache_dir}" ]; then
    >&2 error "ERROR: Cache file directory is absent."
    >&2 error "- UPDEPS_CACHE_FILE: “${UPDEPS_CACHE_FILE}”"

    exit 1
  fi

  touch "${UPDEPS_CACHE_FILE}"
}

cache_file_nonempty () {
  test -s "${UPDEPS_CACHE_FILE}"
}

cache_file_cleanup () {
  # Verify is a partial path name.
  if [ -d "$(dirname "${UPDEPS_CACHE_BASE}")" ] \
    && [ ! -e "${UPDEPS_CACHE_BASE}" ] \
  ; then
    command rm -f "${UPDEPS_CACHE_BASE}"*
  fi
}

cache_file_write () {
  local canon_head="$1"
  local canon_file_absolute="$2"

  local canon_base_absolute="$(print_canon_base_absolute "${canon_file_absolute}")"

  echo -e "${canon_head}\n${canon_base_absolute}" > "${UPDEPS_CACHE_FILE}"
}

cache_file_mark_failed () {
  local canon_head="$1"
  local canon_file_absolute="$2"

  local canon_base_absolute
  canon_base_absolute="$(print_canon_base_absolute "${canon_file_absolute}")"

  if [ -z "${canon_head}" ]; then
    canon_head="$(cache_file_read_cached_head)"
  fi

  if [ -z "${canon_base_absolute}" ]; then
    canon_base_absolute="$(cache_file_read_canon_base_absolute)"
  fi

  echo -e "${canon_head}\n${canon_base_absolute}\nfalse" > "${UPDEPS_CACHE_FILE}"
}

# Note there's a simple awk command to print a specific line number, e.g.,
#   awk 'NR==1' "${UPDEPS_CACHE_FILE}"
# But we'll use printf to avoid exhibiting the newline.
cache_file_read_cached_head () {
  awk 'NR==1 { printf $0 }' "${UPDEPS_CACHE_FILE}"
}

cache_file_read_canon_base_absolute () {
  awk 'NR==2 { printf $0 }' "${UPDEPS_CACHE_FILE}"
}

# Note cache file might be 2 or 3 lines. If 2 lines, infer status ok.
cache_file_read_update_status () {
  if [ ! -f "${UPDEPS_CACHE_FILE}" ]; then
    printf "true"

    return
  fi

  awk 'NR==3 { print $0; found_it = 1; } END { if (!found_it) { print "true"; } }' \
    "${UPDEPS_CACHE_FILE}"
}

# ***

has_no_changes () {
  local file="$1"

  test -z "$(git status --porcelain=v1 -- "${file}")"
}

has_no_diff () {
  local local_file="$1"
  local canon_file_absolute="$2"
  local canon_file_relative="$3"
  local canon_head="$4"

  if ! test -e "${local_file}"; then
    return 0
  fi

  local local_fullpath

  local_fullpath="$(realpath "${local_file}")"

  diff -q \
    "${local_fullpath}" \
    <(canon_path_show_at_canon_head "${canon_file_absolute}" "${canon_file_relative}" "${canon_head}") \
      > /dev/null
}

canon_path_show_at_canon_head () {
  local canon_file_absolute="$1"
  local canon_file_relative="$2"
  local canon_head="$3"

  cd "$(dirname "${canon_file_absolute}")"

  # Note that git-show uses the root-relative path, regardless of curr. dir.
  git show ${canon_head}:"${canon_file_relative}"

  if [ $? -ne 0 ]; then
    >&2 error "ERROR: git-show failed:"
    >&2 error
    >&2 error "  git show ${canon_head}:\"${canon_file_relative}\""
    >&2 error
    >&2 error "- HINT: Perhaps you need to commit the file?"

    # This kills caller, including from within process substition.
    exit 1
  fi

  cd - >/dev/null
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

update_local_from_canon () {
  local local_file="$1"
  local canon_file_absolute="$2"
  local canon_file_relative="$3"
  local canon_head="$4"
  local canon_head_private=$5
  local local_changed=$6
  local local_strayed=$7
  local local_matches_HEAD=$8

  # ***

  warn_info_failing () {
    warn_usage_hint_add_meld_compare_cpyst
    warn_usage_hint_delete_local_profit

    warn " │"
    info " └→ Could not update file — Please fix errors and try the update-faithful operation again!"
    info
  }

  warn_usage_hint_add_meld_compare_cpyst () {
    UPDEPS_MELD_CMP_LIST+="
                                      meld \"${local_file}\" \"${canon_file_absolute}\" &"
  }

  warn_usage_hint_delete_local_profit () {
    warn " │   "
    warn " │ - USAGE: Delete the local file if you want the latest source (easy!):"

    if git status --porcelain=v1 -- "${local_file}" | grep -q -e "^??"; then
      warn " │   
                                      cd \"$(pwd -L)\"
                                      command rm -f \"${local_file}\"
                                      # Try again!
                                      $0"

      UPDEPS_CMD_RM_F_LIST+="${local_file} "
    else
      # Erm, too provocative:
      #   git commit -m \"Deps: Cleanse the unfaithful\"
      warn " │   
                                      cd \"$(pwd -L)\"
                                      git rm -f \"${local_file}\"
                                      git commit -m \"Deps: Decontaminate divergent files\"
                                      # Try again!
                                      $0"

      UPDEPS_GIT_RM_F_LIST+="${local_file} "
    fi
  }

  # ***

  warn_diverged_and_uncommitted () {
    warn
    warn "Cannot update changed and divergent follower file: ${local_file}"
    warn " │ - The follower file has local changes or is not yet committed"
    warn " │   but doesn't match canon."
    warn " │ - Take a look for yourself:"
    warn " │   
                                    cd \"$(pwd -L)\"
                                    meld \"${local_file}\" \"${canon_file_absolute}\" &"

    warn_info_failing
  }

  warn_divergent_and_unbaptised () {
    warn
    warn "Cannot update divergent follower file: ${local_file}"
    warn " │ - The local file differs from the latest source file,"
    warn " │   and there's no local reference commit."
    warn " │ - Have you edited this file personally?"
    warn " │ - Take a look for yourself:"
    warn " │   
                                    cd \"$(pwd -L)\"
                                    # The latest commit has no reference SHA:
                                    git --no-pager log --format=%B -n 1 -- \"${local_file}\"
                                    # The local file is tidy but differs from source:
                                    meld \"${local_file}\" \"${canon_file_absolute}\" &"

    warn_info_failing
  }

  warn_divergent_now_and_previously () {
    warn
    warn "Cannot update divergent follower file: ${local_file}"
    warn " │ - The follower file does not match latest canon source,"
    warn " │   nor does it match canon from previous update-faithful."
    warn " │ - Have you edited this file personally?"
    warn " │ - Take a look for yourself:"
    warn " │   
                                    cd \"$(pwd -L)\"
                                    # The local file is tidy but differs from source:
                                    meld \"${local_file}\" \"${canon_file_absolute}\" &"

    warn_info_failing
  }

  warn_divergent_from_scoped_head_but_matches_HEAD () {
    warn
    warn "Cannot update divergent follower file: ${local_file}"
    warn " │ - The follower file matches latest canon HEAD, but not the"
    warn " │   latest scoped head @ ${canon_head}"
    warn " │ - You likely copied this file from the other project manually,"
    warn " │   or perhaps you're using a hard link."
    warn " │ - Either way, you probably want to delete it, if not also"
    warn " │   scrub it from the commit history!"

    warn_info_failing
  }

  # ***

  _stage_follower () (
    local what_happn="$1"

    stage_follower "${local_file}" "${canon_head}" "${canon_file_absolute}" "${what_happn}"
  )

  # ***

  local success=false

  if [ ! -e "${local_file}" ]; then
    # Note you can `git rm "${local_file}"` and not git-commit,
    # then run update-faithful operation, and it'll commit changes
    # to canon file.
    copy_canon_version "${local_file}" "${canon_file_absolute}" "${canon_file_relative}" "${canon_head}"

    _stage_follower "baptised"

    success=true
  elif ${local_changed}; then
    if ${local_strayed}; then
      if ${local_matches_HEAD}; then
        # Might have local changes or not be committed yet,
        # but local file matches canon HEAD, so we can overwrite
        # with canon source.
        copy_canon_version "${local_file}" "${canon_file_absolute}" "${canon_file_relative}" "${canon_head}"

        _stage_follower "overwrit"

        success=true
      else
        # Unpossible to know what to do.
        # - Might have local changes, or might be outside repo still.
        warn_diverged_and_uncommitted

        success=false
      fi
    else
      # Uncommitted changes match canon.
      # - Could be a hard link (how author sometimes manages inter-project
      #   dependencies), whereby the local file *is* the canon file (same
      #   inode), and we just need to commit the changes.
      #   - We *could* `ls -i` and check inodes, but unnecessary.
      _stage_follower "recorded"

      success=true
    fi
  else
    # No local changes.
    if ! ${local_strayed}; then
      # Nothing to do: No changes since last update. Holding steadfast.
      # - Meh. We could add bool arg to tell stage_follower to skip the
      #   git-add, but git-add doesn't care, on file without changes,
      #   prints nothing and returns zero.
      _stage_follower "here yet"

      success=true
    else
      # No local changes, but local strayed, or rather, canon
      # probably strayed. Determine the canon HEAD when the
      # local file was last updated, and see if the local
      # file still matches.
      local prev_canon_head="$(latest_commit_read_canon_head "${local_file}")"

      if [ -z "${prev_canon_head}" ]; then
        warn_divergent_and_unbaptised

        success=false
      else
        local local_diverged=false

        has_no_diff "${local_file}" "${canon_file_absolute}" "${canon_file_relative}" "${prev_canon_head}" \
          || local_diverged=true

        if ${local_diverged}; then
          # Local file doesn't match canon head version, or previous
          # update-faithful version.
          if ${local_matches_HEAD}; then
            # Local file matches canon HEAD but not scoped head, which likely
            # means user copied private commit from canon repo (or maybe was/
            # is using hard links).
            warn_divergent_from_scoped_head_but_matches_HEAD
          else
            # Local file doesn't match canon HEAD, scoped head, or prev update head.
            warn_divergent_now_and_previously
          fi

          success=false
        else
          # Local file unchanged since last update-faithful,
          # so okay to update to latest canon.
          copy_canon_version "${local_file}" "${canon_file_absolute}" "${canon_file_relative}" "${canon_head}"

          _stage_follower "conveyed"

          success=true
        fi
      fi
    fi
  fi

  ${success} && return 0
}

# ***

copy_canon_version () {
  local local_file="$1"
  local canon_file_absolute="$2"
  local canon_file_relative="$3"
  local canon_head="$4"

  # Delete previous file, in case it's a hard link to canon,
  # so that we don't overwrite canon with an earlier version.
  # - It's up to the caller to remake hard-links.
  command rm -f "${local_file}"

  # Copy scoped version.
  command cp -f \
    <(canon_path_show_at_canon_head "${canon_file_absolute}" "${canon_file_relative}" "${canon_head}") \
    "${local_file}"
}

stage_follower () {
  local local_file="$1"
  local canon_head="$2"
  local canon_file_absolute="$3"
  local what_happn="$4"

  local update_status="$(cache_file_read_update_status)"

  if ${update_status}; then
    # Note when what_happn="here yet", local_file unchanged, but Git don't care.
    if [ -e "${local_file}" ]; then
      git add "${local_file}"
    fi
    # else, remove-faithful-file ran git-rm.

    # Cache the canon HEAD (it might already be cached, in which
    # case this recreates the cache file, with a new mod. date).
    cache_file_write "${canon_head}" "${canon_file_absolute}"
  fi

  print_update_faithful_progress_info "${local_file}" "${what_happn}" "${update_status}"
}

print_update_faithful_progress_info () {
  local local_file="$1"
  local what_happn="$2"
  local update_status="$3"

  if [ -z "${update_status}" ]; then
    update_status="$(cache_file_read_update_status)"
  fi

  local action_preamble=""

  if ${update_status}; then
    action_preamble="Follower file"
  else
    action_preamble="Would've been"
  fi

  info " ${action_preamble} $(font_emphasize "${what_happn}")" \
    "$(font_highlight "$(realpath -s "${local_file}")")"
}

# ***

print_canon_base_absolute () {
  local canon_file_absolute="$1"

  (
    cd "$(dirname "${canon_file_absolute}")"

    git_project_root_absolute
  )
}

git_project_root_absolute () {
  # Same output as git-extras's `git root`.
  git rev-parse --show-toplevel
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

remove-faithful-file () {
  remove_faithful_file "$@"
}

remove_faithful_file () {
  local local_file="$1"
  local canon_base_absolute="${2:-${UPDEPS_CANON_BASE_ABSOLUTE}}"

  if ! must_pass_checks_and_ensure_cache "" "" "${local_file}"; then
    # Soft-fail only happens in canon file has changes, but there was
    # no such file indicated in the args, so this is unexpected path.
    # - If any other check didn't pass, function exited.
    >&2 echo "ERROR: Unxpected path: This must-pass cmd soft-failed:"
    >&2 echo "  must_pass_checks_and_ensure_cache \"\" \"\" \"${local_file}\""

    return 1
  fi

  local what_happn="foregone"
  if [ -f "${local_file}" ]; then
    what_happn="perished"

    git rm -q "${local_file}"
  fi

  # The calls below (print_canon_scoped_head and stage_follower) will only
  # use the absolute file path to determine the absolute canon directory. I
  # know.
  local canon_fake_absolute="${canon_base_absolute}/ignored"

  local canon_head
  canon_head="$(print_canon_scoped_head "${canon_fake_absolute}")"

  stage_follower "${local_file}" "${canon_head}" "${canon_fake_absolute}" "${what_happn}"
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

render-faithful-file () {
  render_document_from_template "$@"
}

render_document_from_template () {
  local dst_file="$1"
  # Akin to update-faithful-file's canon_file_relative, the relative
  # path to the template file from the canon project directory. If
  # this is just the name of the destination file with a .tmpl ext,
  # it's optional.
  local canon_tmpl_relative="${2:-${dst_file%.*}.tmpl}"
  # Usually caller sets UPDEPS_CANON_BASE_ABSOLUTE before first update
  # operation, or sends path to update-faithful-begin, which sets it.
  local canon_base_absolute="${3:-${UPDEPS_CANON_BASE_ABSOLUTE}}"

  local canon_tmpl_absolute="${canon_base_absolute}/${canon_tmpl_relative}"

  local canon_head
  canon_head="$(print_canon_scoped_head "${canon_tmpl_absolute}")"

  insist_canon_head_consistent "${canon_head}" "${canon_tmpl_absolute}"

  # ***

  if ! must_pass_checks_and_ensure_cache \
    "${canon_base_absolute}" "${canon_tmpl_absolute}" "${dst_file}" \
  ; then
    # Only fails if canon file has changes (if anything else wrong, exited).
    handle_failed_state "${canon_head}" "${canon_tmpl_absolute}"

    return 1
  fi

  # ***

  # For UX purposes, so these few seconds happen at start of updates,
  # callers generally use update-faithful-begin to activate the venv,
  # and this call is a fallback in case they didn't.
  venv_activate_and_prepare

  # ***

  # Not that jinja2 won't do process substitution (Bash's <(some-cmd) syntax),
  # because `os.path.isfile(filename)` returns False on named pipes, e.g., on
  # '/dev/fd/63' (Ref: `get_source` in jinja2/loaders.py). So use a temp file.

  local temp_tmpl="$(mktemp -t ${UPDEPS_VENV_PREFIX}XXXX)"

  canon_path_show_at_canon_head "${canon_tmpl_absolute}" "${canon_tmpl_relative}" "${canon_head}" \
    > "${temp_tmpl}"

  # ***

  # Generate the source data JSON file.

  local src_data="$(mktemp -t ${UPDEPS_VENV_PREFIX}XXXX)"
  local src_format="json"

  print_tmpl_src_data "${canon_base_absolute}" > "${src_data}"

  # ***

  # E.g.,
  #   jinja2 helloworld.tmpl data.json --format=json
  jinja2 \
    "${temp_tmpl}" \
    "${src_data}" \
    --format=${src_format} \
      > "${dst_file}"

  command rm "${temp_tmpl}"
  command rm "${src_data}"

  # ***

  local what_happn="rendered"

  # Stage the generated file. If template and source data was unchanged,
  # nothing is staged.

  stage_follower "${dst_file}" "${canon_head}" "${canon_tmpl_absolute}" "${what_happn}"
}

# ***

print_tmpl_src_data () {
  local canon_base_absolute="$1"

  venv_install_yq

  local project_name=""
  local project_url=""
  local coc_contact_email=""

  project_name="$(
    tomlq -r .tool.poetry.name pyproject.toml
  )"
  project_url="$(
    tomlq -r .tool.poetry.homepage pyproject.toml
  )"

  # Fallback canon pyproject.toml for missing values.

  coc_contact_email="$(
    tomlq -r --exit-status .tool.git_update_faithful.coc_contact_email pyproject.toml
  )"

  if [ $? -ne 0 ]; then
    coc_contact_email="$(
      cd "${canon_base_absolute}"

      tomlq -r .tool.git_update_faithful.coc_contact_email pyproject.toml
    )"
  fi

  echo "\
{
    \"project\": {
        \"name\": \"${project_name}\",
        \"url\": \"${project_url}\",
        \"coc_contact_email\": \"${coc_contact_email}\"
    }
}"
}

# ***

UPDEPS_VENV_PREFIX="update-faithful-venv-"

venv_activate_and_prepare () {
  # If Python environment looks like one we created, we're good.
  if python -c "import sys; sys.stdout.write(sys.prefix)" \
    | grep -q -e "${UPDEPS_VENV_PREFIX}" \
  ; then
    return 0
  fi

  printf "%s" "Creating Python venv..."

  venv_activate

  venv_install_jinja2_cli

  printf "\r"
  info "Activated Python venv"
}

# REFER: https://gist.github.com/cupdike/6a9caaf18f30250364c8fcf6d64ff22e
# - BEGET: https://gist.github.com/csinchok/9714005
venv_activate () {
  local throwaway_dir=$(mktemp -d -t ${UPDEPS_VENV_PREFIX}XXXX)

  cd "${throwaway_dir}"

  venv_deactivate

  python3 -m venv .venv

  . ./.venv/bin/activate

  pip install --upgrade -q pip
  # ALTLY:
  #   python -m pip install --upgrade --quiet pip

  trap "command rm -rf \"${throwaway_dir}\"" EXIT

  cd - >/dev/null
}

venv_deactivate () {
  # Aka 'off'.
  type deactivate >/dev/null 2>&1 && deactivate
}

# TRACK/2023-10-17 19:36: Using single -q so only warnings or worse printed:
# - Without --quiet, prints multiple lines, e.g.,
#     $ pip install jinja2-cli
#     Collecting...
#     ...
#     Successfully installed...
# - With single -q, prints warning, but I think this is a pip regression:
#     $ pip install -q jinja2-cli
#     WARNING: There was an error checking the latest version of pip.
# - With double -qq, inhibits said warning message.
#   - But lets not inhibit that message, because ealier pip doesn't spew
#     it, e.g.,
#       # Exhibits warning:
#       $ pip -V
#       pip 23.3 from ...
#       # Does not exhibit warning:
#       $ pip install -U pip==23.2.1
venv_install_jinja2_cli () {
  # Because I want to "\r" cleanup the (temporary) progress message,
  # and because the "latest version of pip" warning seems erroneous,
  # we'll filter it.
  #
  #   pip install -q jinja2-cli

  local ignore_warning="WARNING: There was an error checking the latest version of pip."

  pip install -q jinja2-cli 2>&1 \
    | grep -v "${ignore_warning}"

  # ALTLY:
  #   python -m pip install jinja2-cli
}

# CXREF: `tomlq` from `yq`, a YAML/XML/TOML jq wrapper.
#   https://github.com/kislyuk/yq
#   https://kislyuk.github.io/yq/
venv_install_yq () {
  pip install -q yq
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# It's not necessary to call this function, unless you
# want the venv setup to happen early in the operation.
# Otherwise the first update-faithful-file call ensures
# that the cache exists, and first render-faithful-file
# call sets up the venv.
update-faithful-begin () {
  local canon_base_absolute="${1:-UPDEPS_CANON_BASE_ABSOLUTE}"
  local skip_venv_activate="${2:-false}"

  if [ -n "${canon_base_absolute}" ]; then
    UPDEPS_CANON_BASE_ABSOLUTE="${canon_base_absolute:-/}"
  fi

  must_pass_checks_and_ensure_cache "${UPDEPS_CANON_BASE_ABSOLUTE}" "" ""

  if ! ${skip_venv_activate}; then
    venv_activate_and_prepare
  fi
}

# ***

update-faithful-finish () {
  update_faithful_finish "$@"
}

update_faithful_finish () {
  if ! cache_file_nonempty; then
    cache_file_cleanup

    return 0
  fi

  local update_status="$(cache_file_read_update_status)"

  if ${update_status}; then
    if ! git_nothing_staged; then
      local cached_head="$(cache_file_read_cached_head)"

      local canon_base_absolute="$(cache_file_read_canon_base_absolute)"

      commit_changes "${cached_head}" "${canon_base_absolute}"

      info
      info "└── Finished update-faithful operation ─── Changes committed!"
      # info
    else
      info
      info "└── Finished update-faithful operation ─── Nothing changed!"
      # info
    fi
  else
    info
    info "└── Finishing update-faithful operation ─── Failed! Please see messages above and try again"
    if test -n "${UPDEPS_CMD_RM_F_LIST}" \
      || test -n "${UPDEPS_GIT_RM_F_LIST}" \
    ; then
      local cleanup_cmd_cpyst""
      local cleanup_git_cpyst""
      if test -n "${UPDEPS_CMD_RM_F_LIST}"; then
        cleanup_cmd_cpyst="
                                      command rm -f ${UPDEPS_CMD_RM_F_LIST}"
      fi
      if test -n "${UPDEPS_GIT_RM_F_LIST}"; then
        cleanup_git_cpyst="
                                      git rm -f ${UPDEPS_GIT_RM_F_LIST}
                                      # Optional: git-commit. Or just run update-faithful next.
                                      printf \"%s\\\n\\\n%s\" \\
                                        \"Deps: Temporarily expunge divergent faithfuls\" \\
                                        \"- These files will be restored in the next commit.\" \\
                                        | git commit -F -"
      fi
      info
      info "    - If you wanna just replace all the conflicts, eh:
                                      cd \"$(pwd -L)\"${UPDEPS_MELD_CMP_LIST}${cleanup_git_cpyst}${cleanup_cmd_cpyst}
                                      # Try again!
                                      $0"
      info
    fi
  fi

  venv_deactivate

  cache_file_cleanup
}

# ***

commit_changes () {
  local cached_head="$1"
  local canon_base_absolute="$2"

  echo "\
Deps: Update faithfuls

- Source: $(basename "${canon_base_absolute}") @ ${cached_head}

- Commit generated by:

    https://github.com/thegittinsgood/git-update-faithful#⛲" \
    | git commit -q -F -
}

# The latest update-faithful commit looks something like this:
#
#   Deps: Update faithfuls
#
#   - Source: easy-as-pypi @ 0477f4de66eb35f15f651af906dfb0936a2089a1
latest_commit_read_canon_head () {
  local local_file="$1"

  git --no-pager log --format=%B -n 1 -- "${local_file}" \
    | head -3 \
    | tail -1 \
    | sed '/^- Source: .* @ /!d' \
    | sed 's/^- Source: .* @ //'
}

# ***

handle_failed_state () {
  local canon_head="$1"
  local canon_file_absolute="$2"

  # Skip `cache_file_cleanup`, but mark failed, so caller can continue
  # calling update-faithful-file and eventually update-faithful-finish.
  # Then all the successes and failures are printed in one go, and the
  # user can fix everything and will find success on their second run.
  cache_file_mark_failed "${canon_head}" "${canon_file_absolute}"

  git reset HEAD > /dev/null
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

font_emphasize () {
  echo "$(attr_emphasis)${1}$(attr_reset)"
}

font_highlight () {
  echo "$(fg_lightorange)${1}$(attr_reset)"
}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

main () {
  source_deps
}

main "$@"
unset -f main
unset -f source_deps
unset -f insist_cmd

