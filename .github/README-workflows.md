# EAPP GitHub Actions workflows work flow

- Push a version tag to start the release:

    [.github/workflows/checks-versioned.yml](https://github.com/doblabs/easy-as-pypi/blob/release/.github/workflows/checks-versioned.yml)

    [//]: # (~/.kit/py/easy-as-pypi/.github/workflows/checks-versioned.yml)

- The release job first waits on checks to pass:

    [.github/workflows/checks.yml](https://github.com/doblabs/easy-as-pypi/blob/release/.github/workflows/checks.yml)

    [//]: # (~/.kit/py/easy-as-pypi/.github/workflows/checks.yml)

- After checks pass, `checks-versioned` releases to GitHub:

    [.github/workflows/release-github.yml](https://github.com/doblabs/easy-as-pypi/blob/release/.github/workflows/release-github.yml)

    [//]: # (~/.kit/py/easy-as-pypi/.github/workflows/release-github.yml)

- When the release is created, it triggers a PyPI release:

    [.github/workflows/release-pypi.yml](https://github.com/doblabs/easy-as-pypi/blob/release/.github/workflows/release-pypi.yml)

    [//]: # (~/.kit/py/easy-as-pypi/.github/workflows/release-pypi.yml)

- The PyPI release kicks off a smoke test (e.g., `pip install`):

    [.github/workflows/release-smoke-test.yml](https://github.com/doblabs/easy-as-pypi/blob/release/.github/workflows/release-smoke-test.yml)

    [//]: # (~/.kit/py/easy-as-pypi/.github/workflows/release-smoke-test.yml)

- When the smoke test completes, it notifies downstream project(s),
  starting a *release cascade*:

    [.github/workflows/update-cascade.yml](https://github.com/doblabs/easy-as-pypi/blob/release/.github/workflows/update-cascade.yml)

    [//]: # (~/.kit/py/easy-as-pypi/.github/workflows/update-cascade.yml)

- Each downstream project will update its dependencies to start using the
  latest version of the upstream project. And they'll each use a PR to run
  checks and to merge the changes:

    [.github/workflows/update-deps.yml](https://github.com/doblabs/easy-as-pypi/blob/release/.github/workflows/update-deps.yml)

    [//]: # (~/.kit/py/easy-as-pypi/.github/workflows/update-deps.yml)

- Once a PR is merged and closed, the downstream project will create
  a new version tag for itself, and the whole process starts again:

    [.github/workflows/update-merged.yml](https://github.com/doblabs/easy-as-pypi/blob/release/.github/workflows/update-merged.yml)

    [//]: # (~/.kit/py/easy-as-pypi/.github/workflows/update-merged.yml)

- The release workflow will continue to cascade in this manner,
  from project to project, until the furthest downstream projects
  are eventually updated and released (at least those within the
  same organization as this project).

  In this way making a change in a dependency that requires updating
  and releasing multiple other projects is no longer a burden.

## Manual `workflow_dispatch` *Run workflow* options

Many of the workflows can be started manually
(look for the *Run workflow* button on GitHub).

- You can create a new version (and start the release process, and cascade)
  by manually running the *Release Cascade — Version* workflow
  ([.github/workflows/update-merged.yml](https://github.com/doblabs/easy-as-pypi/blob/release/.github/workflows/update-merged.yml)).

  This only works if the latest commit is not already versioned.

  And it will only bump the lowest version part, e.g.,
  from *1.0.0* to *1.0.1*, or from *1.2.3a4* to *1.2.3a5*.

- You can start the update dependency workflow manually
  by running the *Release Cascade — Update* workflow
  ([.github/workflows/update-deps.yml](https://github.com/doblabs/easy-as-pypi/blob/release/.github/workflows/update-deps.yml)).

  This runs ``poetry update``, and it starts the
  release cascade if there are any changes.

- You can send a dispatch to the closest downstream repo(s)
  using the *Release Cascade — Dispatch* workflow
  ([.github/workflows/update-cascade.yml](https://github.com/doblabs/easy-as-pypi/blob/release/.github/workflows/update-cascade.yml)).

  This starts the release cascade, but skips the current
  project and begins downstream instead.
  (Useful to test the cascade wiring.)

- You can start the smoke test using the
  *PyPI Smoke test* workflow
  ([.github/workflows/release-smoke-test.yml](https://github.com/doblabs/easy-as-pypi/blob/release/.github/workflows/release-smoke-test.yml)).

  If the smoke check passes, downstream repos are
  notified, and the release cascade will begin.

- You can manually start the PyPI release using
  the *Publish release to PyPI* workflow
  ([.github/workflows/release-pypi.yml](https://github.com/doblabs/easy-as-pypi/blob/release/.github/workflows/release-pypi.yml)).

  But this is unlikely to be helpful unless the
  previous PyPI release failed. Otherwise, when
  you re-run this workflow but the version hasn't
  changed, it fails.

## Recap

- In short, when you set a version tag on HEAD:

  - First, the workflow tests and builds the project,
    and then publishes the package to GitHub.

  - Next, it downloads the GitHub release assets,
    and then publishes the same build files to PyPI.

  - Finally, the workflow verifies the PyPI release, and
    then notifies its downstream projects, so they, too,
    can update their dependencies, version themselves, and
    publish releases. And then those projects will notify
    *their* downstream projects, &c, ad nauseam.

  *Push once, release many.*

