Quickstart
==========

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
  
  bin/genparse.sh myfile.m4s -o myfile.sh

to either get a script that should work, or a file that you include in your script.

Argbash API
+++++++++++

Generally, positional arguments have a name, whereas optional arguments have long name (and optionally a short name).
Moreover, they can have defaults and help messages. 
In order to declare your arguments, you write macros described below.

So let's get back to argument types:

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

     ARG_HELP

   There are no parameters to this macro.
 * Version argument (a special case of an action argument):
   ::

     ARG_VERSION([code to execute when specified])

.. note::

   Put macro parameters in square brackets.
   Parameters marked as optional can be left out blank:

   ::

     ARG_OPTIONAL_BOOLEAN([verbose], , [Turn on verbose mode], )

Finally, you have to express your desire to generate the parsing code, help message etc.
You do that by specifying a macro ``ARGBASH``.

Using parsing results
+++++++++++++++++++++

The key is that parsing results are saved in variables that relate to argument (long) names.
The argument name is transliterated like this:

#. All letters are made upper-case
#. Dashes are transliterated to underscores (``-`` --> ``_``)
#. ``_ARG_`` is prepended to the string.

So given that you have an argument ``--input-file`` that expects a value, you can access it via BASH variable ``_ARG_INPUT_FILE``.
Boolean arguments have values either ``on`` or ``off``.

Limitations
-----------

.. warning::

  Please read this carefuly.

#. The delimiter between optional argument name and value is whitespace, ``=`` is not supported.
#. If there is an argument that expects a value to be passed, if there is no value, no error is raised.

Requirements
------------

You need:

* ``bash>=3.0``
* ``autoconf>=2.64`` (Argbash makes use of the ``autom4te`` utility)

How it works
------------

The source code of ``Argbash`` is mostly written in ``m4sugar``, which is build upon the venerable ``m4`` macro language.
