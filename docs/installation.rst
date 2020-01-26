############
Installation
############

.. |virtualenv| replace:: ``virtualenv``
.. _virtualenv: https://virtualenv.pypa.io/en/latest/

.. |workon| replace:: ``workon``
.. _workon: https://virtualenvwrapper.readthedocs.io/en/latest/command_ref.html?highlight=workon#workon

To install system-wide, run as superuser::

    $ pip3 install release-ghub-pypi

To install user-local, simply run::

    $ pip3 install -U release-ghub-pypi

To install within a |virtualenv|_, try::

    $ mkvirtualenv release-ghub-pypi
    $ pip install release-ghub-pypi

To develop on the project, link to the source files instead::

    $ deactivate
    $ rmvirtualenv release-ghub-pypi
    $ git clone git@github.com:hotoffthehamster/release-ghub-pypi.git
    $ cd release-ghub-pypi
    $ mkvirtualenv -a $(pwd) --python=/usr/bin/python3.7 release-ghub-pypi
    $ make develop

After creating the virtual environment,
to start developing from a fresh terminal, run |workon|_::

    $ workon release-ghub-pypi

