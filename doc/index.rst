Quickstart
==========

Installation etc.
-----------------

Go to the ``resources`` folder.
There is a ``Makefile``.

* ``make ../bin/argbash.sh``, ``make bootstrap`` makes (or updates) the ``argbash.sh`` script (the script basically overwrites itself).
  Use the latter if previous update broke the current ``../bin/argbash.sh`` script.
* ``make examples`` compiles examples from ``.m4s`` files to ``.sh`` files in the ``examples`` folder.
* ``make check`` runs the tests.
* ``make install [PREFIX=foo]`` runs the installation into the prefix you can specify (default is ``$(HOME)/.local``).
  This will install the ``argbash`` script (notice the missing ``.sh`` extension) into ``$PREFIX/bin`` (and some support files into ``$PREFIX/lib/argbash``).
* ``make develop [PREFIX=foo]`` is similar to ``make install``, but it installs a wrapper around the local ``bin/argbash.sh``, so any change to the file will be immediatelly reflected for everybody who uses the system-wide one.
  This is inspired by Python's ``python setup.py develop`` pattern.
* ``make uninstall [PREFIX=foo]`` inverse of the above.

Declaring arguments
-------------------

Definitions
+++++++++++

There are two types of arguments:

* Positional
* Optional

Take an example:

::
  
  ls -l --color=auto /home

Here, the argument ``-l`` is optional of a boolean type (it is either on or off), ``--color`` is also optional, taking one value (in this case ``auto``, the equal sign acts as a delimiter) and ``/home`` is a positional one.
Generally, positional arguments are required, and there ordering matters, whereas optional arguments are, well, optional.

Your script
+++++++++++

You have to decide what arguments should your script support.
Argbash lets you choose from:

* Single-value positional arguments,
* single-value optional arguments,
* boolean optional arguments,
* action optional arguments (i.e. the --version and --help type of comments).

Take a look at the API and place the declarations either to your script or in a separate file.
Let yourself be inspired by the ``resources/examples/simple.m4s`` example (you can view it using BASH syntax coloring despite the extension).

Then, run the following command to your file:

::
  
  bin/argbash.sh myfile.m4s -o myfile.sh

to either get a script that should work, or a file that you include in your script.

Argbash API
+++++++++++

Generally, positional arguments have a name, whereas optional arguments have long name (and optionally a short name).
Moreover, they can have defaults and help messages. 
In order to declare your arguments, you write macros described below.

So let's get back to argument types.
Below, is a list of argument types and macros that you have to write to support those.
Place those macros in your files as Bash comments.

* Single-value positional arguments:
  ::

     ARG_POSITIONAL_SINGLE([argument-name])

* Single-value optional arguments:
  ::

     ARG_OPTIONAL_SINGLE([argument-name-long], [argument-name-short (optional)], [help message], [default (optional)])

* Boolean optional arguments:
  ::

     ARG_OPTIONAL_BOOLEAN([argument-name-long], [argument-name-short (optional)], [help message], [default (default default is 'off')])

* Action optional arguments (i.e. the --version and --help type of comments):
  ::

     ARG_OPTIONAL_ACTION([argument-name-long], [argument-name-short (optional)], [help message], [code to execute when specified])

  The scripts exits after the argument is encountered.
  You can specify a name of a function, ``echo "$0: v0.5"`` and whatever else.
* Help argument (a special case of an action argument):
  ::

     ARG_HELP([program description (optional)])

* Version argument (a special case of an action argument):
  ::

     ARG_VERSION([code to execute when specified])

Plus, there are convenience macros:

* Add a line where the directory where the script is running is stored to a variable:
  ::
    
     DEFINE_SCRIPT_DIR([variable name (optional, default is SCRIPT_DIR)])

.. note::

   Put macro parameters in square brackets.
   Parameters marked as optional can be left out blank:

   ::

     ARG_OPTIONAL_BOOLEAN([verbose], , [Turn on verbose mode], )

Finally, you have to express your desire to generate the parsing code, help message etc.
You do that by specifying a macro ``ARGBASH_GO``.

Using parsing results
+++++++++++++++++++++

The key is that parsing results are saved in variables that relate to argument (long) names.
The argument name is transliterated like this:

#. All letters are made upper-case
#. Dashes are transliterated to underscores (``-`` --> ``_``)
#. ``_ARG_`` is prepended to the string.

   So given that you have an argument ``--input-file`` that expects a value, you can access it via BASH variable ``_ARG_INPUT_FILE``.
#. Boolean arguments have values either ``on`` or ``off``.

   If (a boolean argument) ``--verbose`` is passed, value of ``_ARG_VERBOSE`` is set to ``on``.

Usage
-----

Separate file for parsing
-------------------------

This is really easy.
Just place the directives in the file behind comments and then run the ``argbash.sh`` with the ``--standalone`` argument.

Parsing code and script body together
-------------------------------------

This requires some trivial adjustments to your script.

#. Add Argbash definitions to the script so they come before the script body.
   Let's say that the file is called ``my-template.m4s`` (``m4s`` stands for ``m4sugar``).
   
   .. note::

      This one is just a recommendation, but don't do othewise if you don't have deep understanding of what's going on.

   Definitions are described in the Argbash API section, include them in a form as shell comments like this:

   ::

      # ARG_POSITIONAL_SINGLE([filename])
      # ARG_OPTIONAL_SINGLE([unit], u, [What unit we accept (b for bytes, k for kilobytes, M for megabytes)], b)
      # ARG_VERSION([echo $0 v0.1])
      # ARG_OPTIONAL_BOOLEAN(verbose)
      # ARG_HELP
      # ARGBASH_GO

#. Add this comment before the script body (it is a commented opening square bracket, the note is optional):

   ::

      # [ note: <--- this has to be here because of Argbash

   and another one (closing square bracket):

   ::

      # ] note: <--- this has to be here because of Argbash

#. Run the ``argbash.sh`` over the script:

   ::
    
      bin/argbash.sh my-template.m4sh -o my-script.sh

Then, if you do some script development and you decide to add an option or remove one:

4. Forget about the template, edit the script --- declarations are preserved in there.
   Obtain the updated version by re-running ``argbash.sh`` over ``my-script.sh``:

   ::
    
      bin/argbash.sh my-script.sh -o my-script-new.sh

   If you compare the two, you should find out that it works quite well and that the ``my-script-new.sh`` does what it is supposed to do and that it is by no means cluttered.

Examples
--------

Simple
++++++

The ``simple.sh`` script prints size of a file, accepting some options.

* See the `template <../resources/examples/simple.m4s>`_ and the `actual script <../resources/examples/simple.sh>`_ (one file).
* The `template <../resources/examples/simple-standalone.m4s>`_ and the `actual script <../resources/examples/simple-standalone.sh>`_ (separate file for parsing).

Limitations
-----------

.. warning::

  Please read this carefuly.

#. The delimiter between optional argument name and value is whitespace, ``=`` is not supported.
   Create an issue if this disturbs you, it should be quite easy to implement.
#. Clustering of short arguments (e.g. using ``-xzf`` instead of ``-x -z -f``) is not supported.
#. The square brackets in your script have to match (i.e. every opening square bracket ``[`` should be followed at some point by a closing square bracket ``]``)
   This limitation does not apply if you have the argument parsing code in a separate file.

Requirements
------------

You need:

* ``bash>=3.0``
* ``autoconf>=2.64`` (Argbash makes use of the ``autom4te`` utility)

How it works
------------

The source code of ``Argbash`` is mostly written in ``m4sugar``, which is built upon the venerable ``m4`` macro language.

Others
------

Here follows a list of influences and/or alternatives:

* Python ``argparse``: The main inspiration: https://docs.python.org/3/library/argparse.html

  * Pros: Works really well
  * Cons: It is Python, we are Bash.
  * Argbash: We handle the boolean options better.

* Bash --- ``shflags``: The Bash framework for argument parsing: https://github.com/kward/shflags
  * Pros: It works great on Linux.
  * Cons: Doesn't work with Windows Bash, doesn't support long options on OSX.
  * Argbash: We work the same on all platforms that have ``bash``.

* ``getopt``: Eternal utility for parsing command-line.
  This is what powers ``shflags``.
  * Pros: The GNU version can work with long and short optional arguments.
  * Cons: Its use is `discouraged <http://bash.cumulonim.biz/BashFAQ(2f)035.html#getopts>`_ --- it seems to have some issues, you still need to deal with positional arguments by other means.

* ``getopts``: Bash builtin for parsing command-line.
  * Pros: Being included with Bash, it behaves the same on all platforms.
  * Cons: Supports only short optional arguments.
