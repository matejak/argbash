Installation
============


.. _user_install:

User installation
-----------------

If you want to use Argbash locally, you have to download the software package and run the installation script.

1. Go to the `release section of the GitHub project <https://github.com/matejak/argbash/releases>`_, choose the version to download, and download the source code package.

#. Unpack the contents of the archive.
   You can use the ``bin/argbash`` script without any installation (as it is described in the :ref:`quickstart`), but you can proceed to the installation in order to be able to use ``argbash`` system-wide.

#. Go to the ``resources`` folder.
   There is a ``Makefile``.

#. According to whether you have your ``$HOME/.local/bin`` folder in the ``PATH``:

   * If so, run ``make install PREFIX=$HOME/.local``,
   * else, run ``sudo make install PREFIX=/usr``.

   .. note::

     If you want multiple ``Argbash`` versions installed in parallel, install them using ``make altinstall`` (and uninstall using ``make uninstall``) commands.
     This will create ``argbash-X.Y.Z`` script under the ``bin`` directory, with ``argbash-X.Y``, ``argbash-X`` and ``argbash`` symlinks pointing transitively to it.
     If you altinstall another version of ``Argbash``, the common symlinks will be overwritten (i.e. at least ``argbash``).

     This way of installation won't install the ``argbash-xtoy`` :ref:`migration scripts <argbash_components>`.

#. Optional:

   * Supply ``INSTALL_COMPLETION=yes`` as an installation argument to install bash completion for ``argbash`` to ``$(SYSCONFDIR)/bash_completion.d``.
     The default ``SYSCONFDIR`` is ``/etc``, but you may override it in the same way as you can override the ``PREFIX`` variable.

   * Run some checks by executing: ``make check`` (still in the ``resources`` folder).
     You should get a message ``All is OK`` at the bottom.


``Argbash`` has this audience:

* Users --- people that use scripts that make use of ``Argbash``.
* Developers --- people that use ``Argbash`` to write scripts.
* Tinkerers --- people that come in contact with ``Argbash`` internals, typically curious Developers.

* ``bash >= 3.0`` --- this is obvious, everybody needs ``bash``. There is only one exception --- in cases of simple scripts, a ``POSIX`` shell s.a. ``dash`` will be enough for Users.
* ``autoconf >= 2.63`` --- ``Argbash`` is written in a ``m4`` language extension called ``m4sugar``, which is contained in ``autoconf``. Developers and Tinkerers need this. ``autoconf`` is available on Linux, macOS, BSDs and can be installed on MS Windows.
* ``grep``, ``sed``, ``coreutils`` --- The ``argbash`` script uses ``grep``, ``sed``, ``cat``, and ``test``. If you have ``autoconf``, you probably have those already.
* ``GNU Make >= 4.0`` --- the project uses Makefiles to perform a wide variety of tasks, although it is more of interest to Tinkerers.


Building Argbash
----------------

If you identify yourself as a tinkerer (i.e. you want to play with internals of ``Argbash``), you may use a different set of steps:

#. Clone the Git repository: ``git clone https://github.com/matejak/argbash.git``

#. Go to the ``resources`` directory consider running a develop install there, e.g. ``make develop PREFIX=$HOME/.local``,

   This type of installation ensures that whenever you make a change to the ``bin/argbash`` script in the repository, the ``argbash`` command always calls that ``bin/argbash`` script.

#. After you make modifications the source files (``.m4`` files in the ``src`` directory), you regenerate ``bin/argbash`` by running ``make ../bin/argbash`` in the ``resources`` directory.

   If you let a bug through that prevents the ``argbash`` script to regenerate itself, run ``make bootstrap`` to regenerate it in a more robust way.

#. Remember to run ``make check`` in the ``resources`` directory often to catch bugs as soon as possible.


.. _argbash_components:

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
* ``make develop [PREFIX=foo]`` is similar to ``make install``, but it installs a wrapper around the local ``bin/argbash``, so any change to the file will be immediately reflected for everybody who uses the system-wide one.
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
* ``make version VERSION=1.0.0`` sets the project's version to all corners of the project where it should go.
* ``make release [VERSION=1.0.0]`` refreshes date in the ``ChangeLog`` and regenerates all of the stuff (and runs tests).
* ``make tag`` tags the version.
