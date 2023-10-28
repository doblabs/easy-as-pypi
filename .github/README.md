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

- The PyPI release kicks off a smoke test:

    [.github/workflows/release-smoke-test.yml](https://github.com/doblabs/easy-as-pypi/blob/release/.github/workflows/release-smoke-test.yml)

    [//]: # (~/.kit/py/easy-as-pypi/.github/workflows/release-smoke-test.yml)

- Future: Now that a single project release is automated, the next task
  is to automate starting downstream update-and-release pipelines.

  This will let us update the boilerplate project (EAPP), release it,
  and then all downstream, derived projects will incorporate the changes
  and release new versions. *Push once, release many.*

