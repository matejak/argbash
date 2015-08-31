Argbash documentation
=====================

Quickstart
----------

Basically, you write a simple template of your script.
Then, you run ``Argbash`` on top of it to get the fully functional script, which retains the template section.
If you need to make adjustments to the template, you just edit the template section of the script and run ``Argbash`` on top of it to get the updated script.

Installation etc.
-----------------

Go to the ``resources`` folder.
There is a ``Makefile``.

* ``make ../bin/argbash.sh``, ``make bootstrap`` makes (or updates) the ``argbash.sh`` script (the script basically overwrites itself).
  Use the latter if previous update broke the current ``../bin/argbash.sh`` so it is not able to regenerate itself.
* ``make examples`` compiles examples from ``.m4`` files to ``.sh`` files in the ``examples`` folder.
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
Let yourself be inspired by the ``resources/examples/simple.m4`` example (you can view it using BASH syntax coloring despite the extension).

Then, run the following command to your file:

::
  
  bin/argbash.sh myfile.m4 -o myfile.sh

to either get a script that should work, or a file that you include in your script.

Argbash API
-----------

Generally, positional arguments have a name, whereas optional arguments have long name (and optionally a short name).
Moreover, they can have defaults and help messages. 
In order to declare your arguments, you write macros described below.

So let's get back to argument types.
Below, is a list of argument types and macros that you have to write to support those.
Place those macros in your files as Bash comments.

Positional arguments
++++++++++++++++++++

* Single-value positional arguments:
  ::

     ARG_POSITIONAL_SINGLE([argument-name])

Optional arguments
++++++++++++++++++

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
  You can specify a name of a function, ``echo "my-script: v0.5"`` and whatever else.
  This is simply a shell code that will be executed as-is (including ``"`` and ``'`` quotes) when the argument is passed.
  It can be multi-line, but if you need something sophisticated, it is recommended to define a shell function in your script template and call that one instead.

Special arguments
+++++++++++++++++

* Help argument (a special case of an optional action argument):
  ::

     ARG_HELP([program description (optional)])

  This will generate the ``--help`` and ``-h`` action arguments that will print the usage information.
  Notice that the usage information is generated even if this macro is not used --- we print it when we think that there is something wrong with arguments that were passed. 

* Version argument (a special case of an action argument):
  ::

     ARG_VERSION([code to execute when specified])
 
Convenience macros
++++++++++++++++++

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
   Let's say that the file is called ``my-template.m4`` (the extension :footnote:```m4`` is the extension used for the ``M4`` language, but we use the ``m4sugar`` extension built on top of it).` doesn't matter). 
   
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
    
      bin/argbash.sh my-template.m4 -o my-script.sh

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

* See the `template <../resources/examples/simple.m4>`_ and the `actual script <../resources/examples/simple.sh>`_ (one file).
* The `template <../resources/examples/simple-standalone.m4>`_ and the `actual script <../resources/examples/simple-standalone.sh>`_ (separate file for parsing).

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
