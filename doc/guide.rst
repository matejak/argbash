Template writing guide
======================

This section tells you how to write templates, the next one is about ``argbash.sh`` invocation.

Definitions
-----------

There are two types of arguments --- thake an example:

::
  
  ls -l --sort time /home

* Optional arguments are ``-l`` and ``--sort``, while we have only one
* positional argument --- ``/home``.

Here, the argument ``-l`` is optional of a boolean type (it is either on or off), ``--sort`` is also optional, taking exactly one value (in this case ``time``).
``-l`` and ``--sort`` are called options, hence the name *optional* arguments.
The common pattern is that optional arguments are not required, being there just for the case you need them.

The ``/home`` argument is a positional one.
In case of ``ls``, the positional argument has a default --- running ``ls`` without parameters is the same as running ``ls .``.
``ls`` itself accepts an arbitrary number of positional arguments and it treats them in the same way.

On the other hand, the ``grep`` command requires at least one positional argument.
The first one is supposed to be the regular expression you want to match against, and the rest are paths, so they are not treated the same.
The first positional argument doesn't have a default, whereas the second one normally defaults to ``-``, which means ``grep`` will try to read input from ``stdin``.

Your script
-----------

You have to decide what arguments should your script support.
As of this version, ``Argbash`` lets you choose from:

* Single-value positional arguments (with optional defaults),
* single-value optional arguments,
* boolean optional arguments,
* action optional arguments (i.e. the ``--version`` and ``--help`` type of args).

Plus, there are convenience macros that don't relate to argument parsing, but they might help you to write better scripts.

Take a look at the API and place the declarations either to your script or in a separate file.
Let yourself be inspired by the ``resources/examples/simple.m4`` example (you can view it using BASH syntax coloring despite the extension).

Then, run the following command to your file:

::
  
  bin/argbash.sh myfile.m4 -o myfile.sh

to either get a script that should work, or a file that you include in your script.

Argbash API
-----------

Nomenclature
++++++++++++

We have positional and optional arguments sorted out, so let's define some other terms now:

* Name:
  Both positional and optional arguments have a name.
  In case of optional argument, the name is what appears before the double dash, e.g. name of ``--project-path`` is ``project-path``.
  The name is used in help and later in your script.
  
* Argument:
  Options accept arguments.
  Although this is confusing, it is a common way of putting it.
  Let's take ``ls -l --sort time`` again as an example :

  * ``-l`` --- this option doesn't accept any arguments
  * ``--sort`` --- this option accepts exactly one argument (in this case, its value was ``time``).
    If you don't provide one, you will get an error.

  ``Argbash`` exposes values of passed arguments as variables.

* Default:
  In case of positional and boolean arguments, you may specify their default values.

  General notice:
  There is no way of how to find out whether an argument was used or not just by the value of the corresponding variable in the script.
  ``Bash`` doesn't distinguish between empty variables and variables containing an empty string.
  At the same time, it is possible to pass an empty string as an argument value.

So let's get back to argument types.
Below, is a list of argument types and macros that you have to write to support those.
Place those macros in your files as Bash comments.

Syntax
++++++

Put macro parameters in square brackets.
Parameters marked as optional can be left out blank:
The following code leaves second and last parameters blank.
Values of first and third parameters are ``verbose`` and ``Turn on verbose mode`` respectively.

::

   ARG_OPTIONAL_BOOLEAN([verbose], , [Turn on verbose mode], )

Positional arguments
++++++++++++++++++++

* Single-value positional argument (with optional default):
  ::

     ARG_POSITIONAL_SINGLE([argument-name], [help message], [default (optional)])

  The argument is mandatory, unless you specify a default.

  If you leave the default blank, it is understood that you don't want one.
  If you really want to have an explicit default of empty string, pass a quoted empty string (i.e. ``""`` or ``''``).

Optional arguments
++++++++++++++++++

* Single-value optional arguments:
  ::

     ARG_OPTIONAL_SINGLE([argument-name-long], [argument-name-short (optional)], [help message], [default (optional)])

  The default default is an empty string.

* Boolean optional arguments:
  ::

     ARG_OPTIONAL_BOOLEAN([argument-name-long], [argument-name-short (optional)], [help message], [default (optional)])

  The default default is ``off`` and you can specify only ``on`` and ``off``.

* Action optional arguments (i.e. the ``--version`` and ``--help`` type of comments):
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

* Include a file (let's say a ``parse.sh`` file) that is in the same directory during runtime.
  If you use this in your script, ``Argbash`` finds out and attempts to regenerate ``parse.sh`` using ``parse.sh`` or ``parse.m4`` if the former is not available.
  Thanks to this, managing a script with body and parsing logic in separate files is really easy.

  ::
    
     INCLUDE_PARSING_CODE([filename], [SCRIPT_DIR variable name (optional, default is SCRIPT_DIR)])

  You have to use ``DEFINE_SCRIPT_DIR`` before, but you will be told so if you don't.

Action macro
++++++++++++

Finally, you have to express your desire to generate the parsing code, help message etc.
You do that by specifying a macro ``ARGBASH_GO``.
The macro doesn't take any parameters.

::
  
   ARGBASH_GO

.. _parsing_results:

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

