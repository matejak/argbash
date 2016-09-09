Installation
============

Installation is simple, but as it is described in the :ref:`quickstart`, you don't need it to use ``Argbash``.

#. Go to the ``resources`` folder.
   There is a ``Makefile``.

#. Run some checks: ``make check``.
   You should get no errors.

#. According to whether you have your ``$HOME/.local/bin`` folder in the ``PATH``:

   * If so, run ``make install PREFIX=$HOME/.local``,
   * else, run ``sudo make install PREFIX=/usr``.

``Argbash`` has this audience:

* Users --- people that use scripts that make use of ``Argbash``.
* Developers --- people that use ``Argbash`` to write scripts.
* Tinkerers --- people that come in contact with ``Argbash`` internals, typically curious Developers.

* ``bash >= 3.0`` --- this is obvious, everybody needs ``bash``. There is only one exception --- in cases of simple scripts, a ``POSIX`` shell s.a. ``dash`` will be enough for Users.
* ``autoconf >= 2.63`` --- ``Argbash`` is written in a ``m4`` language extension called ``m4sugar``, which is contained in ``autoconf``. Developers and Tinkerers need this. ``autoconf`` is available on Linux, OSX, BSDs and can be installed on MS Windows.
* ``grep``, ``sed``, ``coreutils`` --- The ``argbash`` script uses ``grep``, ``sed``, ``cat``, and ``test``. If you have ``autoconf``, you probably have those already.
* ``GNU Make >= 4.0`` --- the project uses Makefiles to perform a wide variety of tasks, although it is more of interest to Tinkerers.

Argbash components
------------------

The ``Argbash`` package consists of these scripts:

* ``argbash``, the main part of ``Argbash``.
  It is basically a wrapper around the ``autom4te`` utility that uses the ``Argbash`` "source code" located in the ``src`` directory.
  In course of an installation, both the script and the source are copied under the prefix --- script goes to ``$PREFIX/bin`` and source to ``$PREFIX/lib/argbash``.

  The ``argbash`` script itself is generated using ``Argbash``.
  It can be (re)generated using a Makefile that can be found in the ``resources`` folder.

* ``argbash-xtoy`` scripts (``x``, ``y`` are major version numbers) that assist users in modifying their scripts in case that ``Argbash`` :ref:`changes its API <api_change>`.
  For example, ``Argbash 2.1.4`` (we say ``Argbash`` of major version 2) has ``argbash-1to2`` script and ``Argbash`` of major version 3 will have scripts ``argbash-1to3`` and ``argbash-2to3``.

* ``argbash-init`` is a quickstart script --- it enables you to create a basic :ref:`template <templates>` for your script.
  Then, you just have to make some slight modifications, :ref:`feed it to argbash <invocation>` and you are done.

The main Makefile
-----------------

The ``Makefile`` in the ``resources`` folder can do many things:

.. _install:

Installation
++++++++++++

* ``make install [PREFIX=foo]`` runs the installation into the prefix you can specify (default is ``$(HOME)/.local``).
  This will install the ``argbash`` script (notice the missing ``.sh`` extension) into ``$PREFIX/bin`` (and some support files into ``$PREFIX/lib/argbash``).
* ``make develop [PREFIX=foo]`` is similar to ``make install``, but it installs a wrapper around the local ``bin/argbash``, so any change to the file will be immediatelly reflected for everybody who uses the system-wide one.
  This is inspired by Python's ``python setup.py develop`` pattern.
* ``make uninstall [PREFIX=foo]`` inverse of the above.

Running argbash
+++++++++++++++

* ``make ../bin/argbash``, ``make bootstrap`` makes (or updates) the ``argbash`` script (the script basically overwrites itself).
  Use the latter if previous update broke the current ``../bin/argbash`` so it is not able to regenerate itself.
* ``make examples`` compiles examples from ``.m4`` files to ``.sh`` files in the ``examples`` folder.
* ``make foo/bar.sh`` generates a script provided that there is a ``foo/bar.m4`` file.
* ``make foo/bar2.sh`` generates a script provided that there is a ``foo/bar.sh`` file.

Releasing
+++++++++

* ``make check`` runs the tests.
* ``make version VERSION=1.0.0`` sets the projct's version to all corners of the project where it should go.
* ``make release [VERSION=1.0.0]`` refreshes date in the ``ChangeLog`` and regenerates all of the stuff (and runs tests).
* ``make tag`` tags the version.
