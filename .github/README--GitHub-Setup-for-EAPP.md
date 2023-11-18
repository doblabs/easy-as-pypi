<!-- Author: Landon Bouma <https://tallybark.com/> -->
<!-- Project: https://github.com/doblabs/easy-as-pypi#🥧 -->
<!-- License: MIT -->

# GitHub Settings for every EAPP project

## General settings

- Settings > General

  E.g., https://github.com/doblabs/easy-as-pypi/settings

  - Default branch: `release`

  - Features:
    - ✗ Wikis
    - ✓ Issues
    - ✗ Allow forking [Private repo option]
    - ✗ Sponsorships
    - ✓ Preserve this repo (GitHub Archive Program) [Public repo option]
    - ✗ Discussions
    - ✗ Projects

  - Pull Requests:
    - ✗ Allow merge commits
    - ✗ Allow squash merging
    - ✓ Allow rebase merging

    - ✗ Always suggest updating pull request branches

    - ✓ Allow auto-merge

    - ✓ Automatically delete head branches

  - Pushes:
    - ✓ Limit how many branches and tags can be updated in a single push:
      - Up to: 5

## Protected branch

- Settings > Branches

  E.g., https://github.com/doblabs/easy-as-pypi/settings/branches

  - Click *Add branch protection rule*

    - Branch name pattern: `release`

    - Protect matching branches:

      - ✓ Require a pull request before merging
        - ✓ Require approvals
          - Required number of approvals before merging: 1
        - ✓ Dismiss stale pull request approvals when new commits are pushed
        - ✗ Require review from Code Owners
        - ✗ Restrict who can dismiss pull request reviews
        - ✗ Allow specified actors to bypass required pull requests
        - ✗ Require approval of the most recent reviewable push

      - ✓ Require status checks to pass before merging
        - ✓ Require branches to be up to date before merging
          - CHORE: Use search box to tediously add all checks!
            - ENTER: Type `b` into the box,
              and all **18** `branch-checks-runner/` jobs should appear
              - Click first one in list and repeat process for all of them
            - SAVVY: I think checks have to pass for the search box to work...

      - ✗ Require conversation resolution before merging

      - ✗ Require signed commits

      - ✓ Require linear history

      - ✗ Require merge queue

      - ✗ Require deployments to succeed before merging

      - ✗ Lock branch

      - ✗ Do not allow bypassing the above settings

      - ✗ Restrict who can push to matching branches

    - Rules applied to everyone including administrators

      - ✓ Allow force pushes
        - ✓ Specify who can force push: *You*

      - ✗ Allow deletions

  - Click *Create*

## (PyPI) Environment

- Settings > Environments

  E.g., https://github.com/doblabs/easy-as-pypi/settings/environments

  - Click *New environment*

    - Name: `release`

    - Click *Configure environment*

      - Deployment branches and tags:

        - Click *No restriction* drop-down and
          change to *Selected branches and tags*.

        - Click *Add deployment branch or tag rule*
          for each of these rules:

          - Ref type: *Tag*
          - Name pattern: `[0-9]*`

          - Ref type: *Branch*
          - Name pattern: `release`

## Secrets and variables

- Settings > Secrets and variables > Actions

  E.g., https://github.com/doblabs/easy-as-pypi/settings/secrets/actions

  - Repository secrets

    - Add `CODECOV_TOKEN` (see *Codecov settings*, below)

  - Organization secrets

    - Confirm `USER_PAT` user token (used by some workflows)

## Codecov settings

- Settings > General

  E.g., https://app.codecov.io/gh/doblabs/easy-as-pypi/settings

  - Default Branch

    - Branch Context: `release`

  - Tokens

    - Copy `CODECOV_TOKEN` and add as repository secret (see above)

- Settings > Badges & Graphs

  E.g., https://app.codecov.io/gh/doblabs/easy-as-pypi/settings/badge

  - Copy the badge URL to `README.rst`, which includes a token

## Organization settings

### Organization secrets and variables

- Create a Personal access token *classic* so pushing version tag from
  `workflows/update-merged.yml` triggers release workflow, and so
  pushing code from `workflows/update-deps.yml` triggers checks.

  https://github.com/settings/tokens

  <!-- Note that I tried a *new* fine-grained personal access token
       (in *beta*) but did not get it to work. -->

  - Click *Generate new token* and pick *Generate new token (classic)*

    - Note: `EAPP-workflows`

    - Expiration: Up to a year, or none, you choose

    - Select scopes: Enable one setting: `public_repo` (under `repo`).

  - Add org secret for personal access token (PAT)

    E.g., https://github.com/organizations/doblabs/settings/secrets/actions

    - Click *New organization secret*

      - Name: `USER_PAT`

      - Value: *Copied from previous step*

 <!-- - Value: `ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX` -->

- Add org var for Git commit user (for `bin/update-poetry`, called by
  `workflows/update-deps.yml`)

  E.g., https://github.com/organizations/doblabs/settings/variables/actions

  - Click *New organization variable*

    - Name: `UPDEPS_USER_EMAIL`

      Value: `<user>@users.noreply.github.com`

