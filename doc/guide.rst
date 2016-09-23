.. _templates:

Template writing guide
======================

This section tells you how to write templates, the next one is about ``argbash`` script invocation.

Definitions
-----------

Positional and optional arguments
+++++++++++++++++++++++++++++++++

There are two major types of arguments --- thake an example:

::

  ls -l --sort time /home

* Optional arguments are ``-l`` and ``--sort``, while we have only one
* positional argument --- ``/home``.

Here, the argument ``-l`` is optional of a boolean type (it is either on or off), ``--sort`` is also optional, taking exactly one value (in this case ``time``).
``-l`` and ``--sort`` are called options, hence the name *optional* arguments.
The common pattern is that optional arguments are not required, being there just for the case you need them.

The ``/home`` argument is a positional one.
In case of ``ls``, the positional argument has a default --- running ``ls`` without parameters is the same as running ``ls "."``.
``ls`` itself accepts an arbitrary number of positional arguments and it treats them all in the same way.

On the other hand, the ``grep`` command requires at least one positional argument.
The first one is supposed to be the regular expression you want to match against, and the other ones correspond to filenames, so they are not treated the same.
The first positional argument ``grep`` accepts (i.e. the regular expression), doesn't have a default, whereas the second one normally defaults to ``-``, which means ``grep`` will try to read input from ``stdin``.


Option, Value, and others
+++++++++++++++++++++++++

We have positional and optional arguments sorted out, so let's define some other terms now keeping the example of ``ls -l --sort time /home``:

* Option:
  The string that identifies optional arguments on the command-line, can have a short (dash and a letter, e.g. ``-l``) or long (double dash and string, e.g. ``--sort``) form.

* Value:
  In connection with optional arguments, value of an argument is the string that follows it (provided that the argument expects a value to be given).
  Concerning positional arguments, it is simply the string on the command-line (whose location matches the location in which we expect the given positional argument).
  So in our example, the values are ``time`` and ``home``.

* Name:
  Both positional and optional arguments have a name.
  In case of optional argument, the name is what appears after the long option's the double dash, e.g. name of ``--project-path`` is ``project-path``.
  The argument's name is used in help and later in your script when you access argument's value.
  Names of positional arguments are much less visible to the script's user --- one can see them only in the help message.

* Argument:
  An argument is the high-level concept.
  On command-line, arguments are identified by options (which themselves may or may be not followed by values).
  Although this is confusing, it is a common way of putting it.
  In our example, we have

  * ``-l`` --- this argument has only the option, but never accepts values.
  * ``--sort`` --- this argument accepts exactly one value (in this case, the string ``time``).
    If you don't provide a value, you will get an error.

  ``Argbash`` exposes values of passed arguments as environmental variables.

* Default:
  In case of positional and boolean arguments, you may specify their default values.

  .. note::

    General notice:
    There is no way of how to find out whether an argument was passed or not just by looking at the value of the corresponding environmental variable in the script.
    ``bash`` doesn't distinguish between empty variables and variables containing an empty string.
    Also note that it is perfectly possible to pass an empty string as an argument value.

So let's get back to argument types.
Below, is a list of argument types and macros that you have to write to support those (e.g. ``ARGBASH_GO`` is a macro and ``ARG_OPTIONAL_BOOLEAN([verbose], [Verbose mode])`` is a macro called wit two arguments --- ``verbose`` and ``Verbose mode``).
Place those macros in your files as ``bash`` comments.

Your script
-----------

You have to decide what arguments should your script support.
As of this version, ``Argbash`` lets you choose from:

* Single-value positional arguments (with optional defaults),
* single-value optional arguments,
* boolean optional arguments,
* action optional arguments (i.e. the ``--version`` and ``--help`` type of args) and
* incremental arguments that "remember" how many times they have been repeated (e.g. ``--verbose``) and
* repeatable arguments that sequentially store their values into an array (e.g. ``-I``).

Plus, there are convenience macros that don't relate to argument parsing, but they might help you to write better scripts and a helper that enables you to easily wrap other ``Argbash``-aware scripts without fuss.

Take a look at the API and place the declarations either to your script or in a separate file.
Let yourself be inspired by the ``resources/examples/simple.m4`` example (``bash`` syntax highlighting is recommended, despite the extension).

Then, run the following command to your file:

::

  bin/argbash myfile.m4 -o myfile.sh

to either get a script that should just work, or a file that you include in your script.

Argbash API
-----------

Put macro parameters in square brackets.
Parameters marked as optional can be left out blank.

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

  If you leave the default blank, it is understood that you don't want one (and that the argument is mandatory).
  If you really want to have an explicit default of empty string, pass a quoted empty string (i.e. ``""`` or ``''``).

* Multi-value positional argument (with optional defaults):
  ::

     ARG_POSITIONAL_MULTI([argument-name], [help message], [number of arguments], ..., [default for the second-to-last (i.e. penultimate) argument (optional)], [default for the last argument (optional)])

  Given that your argument accepts :math:`n` values, you can specify :math:`m` defaults, :math:`(m \leq n)` for last :math:`m` values.

  For example, consider that your script makes use of only one multi-value argument, which accepts 3 values with two defaults ``bar`` and ``baz``.
  Then, it is imperative that at least one value is specified on the command-line.
  So If you pass a value ``val1`` on the command-line, you will be able to retrieve ``val1``, ``bar`` and ``baz`` inside the script.
  If you pass ``val1`` and ``val2``, you will be able to retrieve ``val1``, ``val2`` and ``baz``.
  If you pass nothing, or more than three values, an error will occur.

  Arguments are available as a ``bash`` array (first element has index of 0).

* Infinitely many-valued positional argument (with optional defaults):
  ::

     ARG_POSITIONAL_INF([argument-name], [help message], [minimal number of arguments (optional, default=0)], [default for the first non-required argument (optional)], ...)

  ``Argbash`` supports arguments with arbitrary number of values.
  However, you can require a minimal amount of values the caller has to provide and you can also assign defaults for the values that are not required.
  Given that your argument accepts at least :math:`n` values, you can specify defaults for :math:`n + 1`:sup:`th` argument (and so on).

  For example, consider that your script makes use of infinitely many-valued argument, which accepts at least 1 value and also has two defaults ``bar`` and ``baz``.
  Then, it is imperative that at least one value is specified on the command-line.
  So If you pass a value ``val1`` on the command-line, you will be able to retrieve ``val1``, ``bar`` and ``baz`` inside the script.
  If you pass ``val1``, ``val2``, ``val3`` and ``val4``, you will be able to retrieve ``val1``, ``val2`` ``val3`` and ``val4``.

  Arguments are available as a ``bash`` array (first element has index of 0).

  .. note::

     The main difference between ``ARG_POSITIONAL_MULTI`` and ``ARG_POSITIONAL_INF`` is in handling of defaults.
     In ``ARG_POSITIONAL_MULTI``, defaults determine the number of values that are required to be supplied.
     In ``ARG_POSITIONAL_INF``, you determine the number of required values and defaults follow.

* End of optional arguments and beginning of positional ones (the double-dash ``--``):
  ::

     ARG_POSITIONAL_DOUBLEDASH()

  You are encouraged to add this to your script if you use both positional and optional arguments.

  This pattern is known for example from the ``grep`` command.
  The idea is that you specify optional arguments first and then, whatever argument follows it, it is considered to be a positional one no matter how it looks.
  For example, if your script accepts a ``--help`` optional argument and you want it to be recognized as positional, using the double-dash is the only way.

Optional arguments
++++++++++++++++++

* Single-value optional arguments:
  ::

     ARG_OPTIONAL_SINGLE([argument-name-long], [argument-name-short (optional)], [help message], [default (optional)])

  The default default is an empty string.

* Boolean optional arguments:
  ::

     ARG_OPTIONAL_BOOLEAN([argument-name-long], [argument-name-short (optional)], [help message], [default (optional)])

  The default default is ``off`` (the only alternative is ``on``).

* Incremental optional arguments:
  ::

     ARG_OPTIONAL_INCREMENTAL([argument-name-long], [argument-name-short (optional)], [help message], [default (optional)])

  The default default is 0.
  The argument accepts no values on command-line, but it tracks a numerical value internally.
  That one increases with every argument occurence.

* Repeated optional arguments:
  ::

     ARG_OPTIONAL_REPEATED([argument-name-long], [argument-name-short (optional)], [help message], [default (optional)])

  The default default is an empty array.
  The argument can be repeated multiple times, but instead of the later specifications overriding earlier ones (s.a. ``ARG_OPTIONAL_SINGLE`` does), arguments are gradually appended to an array.

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

     ARG_HELP([short program description (optional)], [long program description (optional)])

  This will generate the ``--help`` and ``-h`` action arguments that will print the usage information.
  Notice that the usage information is generated even if this macro is not used --- we print it when we think that there is something wrong with arguments that were passed.

  The long program desription is a string passed to ``printf`` (so you may use ``\n`` to make it multiline etc.).

* Version argument (a special case of an action argument):
  ::

     ARG_VERSION([code to execute when specified])

* Verbose argument (a special case of a repeated argument):
  ::

     ARG_VERBOSE([short arg name])

  Default default is 0, so you can use a ``test $_arg_verbose -ge 1`` pattern in your script.

* Collect leftovers:
  ::

     ARG_LEFTOVERS([help text (optional)])

  This macro allows your script to accept more arguments and collect them consequently in the ``_arg_leftovers`` array.

  A use case for this is wrapping of scripts that are completely ``Argbash``-agnostic.
  Therefore, your script can take its own arguments and the rest that is not recognized can go to the wrapped script.

Convenience macros
++++++++++++++++++

Plus, there are convenience macros:

* Set the indentation in the parsing part of the script:
  ::

     ARGBASH_SET_INDENT([indentation character(s)])

  The default indentation is one tab per level.
  If you wish to use two spaces as the `Google style recommends <https://google.github.io/styleguide/shell.xml>`_, simply pass two spaces (in square brackets!) as an argument to the macro.

* Set the delimiter between option and value:
  ::

     ARGBASH_SET_DELIM([option-value delimiter caracter(s)])

  The default delimiter is either space or equal sign.
  You can either restrict delimiter to only space or only equal sign, or you can keep both.
  Assuming you have an option accepting value (can be either single-valued or repeated) ``--option`` with short option ``-o``, the following works with these arguments to the macro:

  * ``ARGBASH_SET_DELIM([ ])``: Either of ``--option value``, ``--o value`` assigns value to the ``option`` argument.
    ``--option=value`` will be considered as a single positional argument.

  * ``ARGBASH_SET_DELIM([=])``: Either of ``--option=value``, ``--o value`` assigns value to the ``option`` argument. 
    ``--option value`` will result in both ``--option`` and ``value`` to be considered as two positional arguments.
    ``-o=value`` will also be considered as a positional argument.

  * ``ARGBASH_SET_DELIM([= ])`` (or ``[ =]``): Either of ``--option=value``, ``--o value``, ``--option value`` assigns value to the ``option`` argument; they are treated the same way.
    This is the default behavior.

.. _script_dir:

* Add a line where the directory where the script is running is stored in an environmental variable:
  ::

     DEFINE_SCRIPT_DIR([variable name (optional, default is script_dir)])

  You can use this variable to e.g. source ``bash`` snippets that are in a known location relative to the script's parent directory.

.. _parsing_code:

* Include a file (let's say a ``parse.sh`` file) that is in the same directory during runtime.
  If you use this in your script, ``Argbash`` finds out and attempts to regenerate ``parse.sh`` using ``parse.sh`` or ``parse.m4`` if the former is not available.
  Thanks to this, managing a script with body and parsing logic in separate files is really easy.

  ::

     INCLUDE_PARSING_CODE([filename], [SCRIPT_DIR variable name (optional, default is script_dir)])

  In order to make use of ``INCLUDE_PARSING_CODE``, you have to use ``DEFINE_SCRIPT_DIR`` on preceding lines, but you will be told so if you don't.

  .. seealso::

     Check out the example: :ref:`ex_separating`

.. _argbash_wrap:

* Point to a script that uses ``Argbash`` (or to its template), and your script will inherit its arguments (unless you exclude some of them).

  ::

     ARGBASH_WRAP(filename stem, [list of long options to exclude], [flags to exclude certain arg types, default is HV for (h)elp and (v)ersion])

  Given that you have a script ``process_single.sh`` and you write its wrapper ``process_file.sh``
  Imagine that one reads a file and passes data from every line to ``process_single.sh`` along with some options that ``process_file.sh`` accepts.

  In this case, you write ``ARGBASH_WRAP([process_single], [operation])`` to your ``process_file.m4`` template.

  * Filename stem is a filename without a directory component or an extension.
    Stems are searched for in search paths (current directory, directory of the template) and extensions ``.m4`` and ``.sh`` are tried out.

  * The list of long options is a list of first arguments to functions such as ``ARG_POSITIONAL_SINGLE``, ``ARG_OPTIONAL_SINGLE``, ``ARG_OPTIONAL_BOOLEAN``, etc.
    Therefore, don't include leading double dash to any of the list items that represent blacklisted optional arguments.
    To blacklist the double dash positional argument feature, add the ``--`` symbol to the list.

  * Flags is a string that may contain some characters.
    If a flag is set, a class of arguments is excluded from the file.
    The default ``HVIS`` should be enough in most scenarios --- you want your own help, version info, indentation and option--value separator, not ones from the wrapped script, right?

    Following flags are supported:

    ========= ===================
    Character Meaning
    ========= ===================
    H         Don't include help.
    V         Don't include version info.
    I         Don't use wrapped script's indentation
    S         Don't use wrapped script's option--value separator
    ========= ===================

  * As a convenience feature, if you wrap a script with stem ``process_single``, all options that come from the wrapped script (both arguments and values) are stored in an array ``_args_process_single``.
    In the case where there may be issues with positional arguments (they are order-dependent and the wrapping script may want to inject its own to the wrapped script), you can use ``_args_process_single_opt``, or ``_args_process_single_pos``, where only optional/positional arguments are stored.
    Therefore, when you finally decide to call ``process-single.sh`` in your script with all wrapped arguments (e.g. ``--some-opt foo --bar``), all you have to do is to write

    ::

      ./process-single.sh "${_args_process_single_opt[@]}"

    which is exactly the same as

    ::

      MAYBE_BAR=
      test $_arg_bar = on && MAYBE_BAR='--bar'
      ./process-single.sh --some-opt "$_arg_some_opt" $MAYBE_BAR

    The stem to array name conversion is the same as with :ref:`argument names <argument_names>` except the prefix ``_args_`` is prepended.

    .. note::

       The wrapping functionality actually only makes your script to inherit (all or some of the) the wrapped script's arguments.
       If you really wish to call the wrapped script, it is your responsibility to know its location, ``Argbash`` essentially can't and won't help you with that.

       However, if you know the relative location of the wrapped script to the wrapper, you can use the :ref:`DEFINE_SCRIPT_DIR <script_dir>` macro.

    .. seealso::

       Check out the example: :ref:`ex_wrapping`

* Declare that your script uses an environment variable, set a default for it if it is blank upon the script's invocatino and optionally mention it in the script's help:

  ::

    DEFINE_ENV([variable name], [default if empty (optional)], [help message (optional)])

  For instance, if you declare ``DEFINE_ENV([ENVIRONMENT], [production], [The default environment])``, the value of the ``ENVIRONMENT`` environmental variable won't be empty --- if the user doesn't do anything, it will be ``production`` and if the user overrides it, it will stay that way.
  It is undefined whether the user can override it, so it has a blank value in the script due to the user override (i.e. it is not possible now, but it may become possible in a later release.).
  
* Declare that your script calls a program and enable the caller to set it using an environmental variable.

  ::

    DEFINE_PROG([variable name], [default if empty (optional)], [help message (optional)], [args (optional)])

  For instance, if you declare ``DEFINE_PROG([PYTHON], [python], [The preferred Python executable])`` in your script, you can use constructs s.a. ``"$PYTHON" script.py`` in later.
  This macro operates in two modes:

  * ``args`` are not given:
    The program name is searched for using the ``which`` utility and if it isn't a executable, the script will terminate with an error.
    ``DEFINE_PROG([PYTHON], [python], ,)``
  * ``args`` are given:
    The program is called with ``args`` and if the return code is non-zero, the script will terminate with an error.
    If you want to call the program with no arguments, leave the last argument blank --- the following usage is 100% legal: ``DEFINE_PROG([PYTHON], [python], ,)`` and it means "accept ``PYTHON`` with default value ``python``, but don't bother with help message and pass no arguments when evaluating whether a program is valid".
    
    Notice that this approach is wrong, calling ``python`` without arguments won't work (since it starts the ``Python`` shell) and you should use ``DEFINE_PROG([PYTHON], [python], , [--version])`` instead.
  In either case, the vaule of ``"$PYTHON"`` will be either ``python`` (if the user doesn't override it), or it can be whatever else what the caller set.

Action macro
++++++++++++

Finally, you have to express your desire to generate the parsing code, help message etc.
You do that by specifying a macro ``ARGBASH_GO``.
The macro doesn't take any parameters.

::

   ARGBASH_GO

Available shell stuff
+++++++++++++++++++++

* Variable ``script_dir`` that is available if the :ref:`DEFINE_SCRIPT_DIR <script_dir>` is used.

* Function ``die``.

  Accepts two parameters --- string that is printed to ``stderr`` and exit status number (optional, default is 1).
  If an environmental variable ``_PRINT_HELP`` is set to ``yes``, it prints help before the error message.

.. _argument_names:

Using parsing results
+++++++++++++++++++++

The key is that parsing results are saved in environmental variables that relate to argument (long) names.
The argument name is transliterated like this:

#. All letters are made lower-case
#. Dashes are transliterated to underscores (``include-batteries`` becomes ``include_batteries``)
#. ``_arg_`` is prepended to the string.

   So given that you have an argument ``--include-batteries`` that expects a value, you can access it via environmental variable ``_arg_include_batteries``.

* Boolean arguments have values either ``on`` or ``off``.
  If (a boolean argument) ``--quiet`` is passed, value of ``_arg_quiet`` is set to ``on``.
  Conversely, if ``--no-quiet`` is passed, value of ``_arg_quiet`` is set to ``off``.

* Repeated arguments collect values to a `bash array <http://>`_.

* Incremental arguments have a default value (0 by default) and their value in the script corresponds to the default plus the number of times the argument was specified.
