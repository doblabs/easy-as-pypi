############
Installation
############

.. |virtualenv| replace:: ``virtualenv``
.. _virtualenv: https://virtualenv.pypa.io/en/latest/

.. |workon| replace:: ``workon``
.. _workon: https://virtualenvwrapper.readthedocs.io/en/latest/command_ref.html?highlight=workon#workon

To install system-wide, run as superuser::

    $ pip3 install pypi-and-die

To install user-local, simply run::

    $ pip3 install -U pypi-and-die

To install within a |virtualenv|_, try::

    $ mkvirtualenv pypi-and-die
    (pypi-and-die) $ pip install release-ghub-pypi

To develop on the project, link to the source files instead::

    (pypi-and-die) $ deactivate
    $ rmvirtualenv pypi-and-die
    $ git clone git@github.com:hotoffthehamster/pypi-and-die.git
    $ cd pypi-and-die
    $ mkvirtualenv -a $(pwd) --python=/usr/bin/python3.7 pypi-and-die
    (pypi-and-die) $ make develop

After creating the virtual environment,
to start developing from a fresh terminal, run |workon|_::

    $ workon pypi-and-die
    (pypi-and-die) $ ...

