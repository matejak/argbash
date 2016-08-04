.. _sec_example:

Examples
========

Templates
---------

.. _minimal_example:

Minimal example
+++++++++++++++

The source code for the minimal example could look like this:

.. literalinclude:: ../resources/examples/minimal.m4
   :language: bash

Here, we can notice multiple notable things:

#. Definitions of arguments are placed before the script body.
   From ``bash`` point of view, they are commented out, so the "template" can be a syntactically valid script.

#. You access the values of argument ``foo-bar`` as ``$_arg_foo_bar`` etc. (this is covered more in-depth in :ref:`parsing_results`).

So let's try the script in action! Let's see what happens when we pass the -h option:

.. literalinclude:: _static/minimal-output-help.txt
   :language: text

OK, so it seems that passing it one (mandatory) positional arg will do the trick:

.. literalinclude:: _static/minimal-output-noverbose.txt
   :language: text

Oops, we have forgot to turn print on! Let's fix that...

.. literalinclude:: _static/minimal-output-foobar.txt
   :language: text

Another example
+++++++++++++++

Let's take a look at a script that takes filename as the only positional argument and prints size of the corresponding file.
The caller can influence the unit of display using optional argument ``--unit``.

The script's template is really simple:

.. literalinclude:: ../resources/examples/simple.m4
   :language: bash

When invoked with the help option, we get:

.. literalinclude:: _static/simple-output-help.txt
   :language: text

This script is a bit artificial, but hang on --- we will try to use it from within a wrapping script.

Wrapping scripts
++++++++++++++++

We will show how to write a script that accepts a list of directories and a glob pattern, combines them together, and displays filesize of files using the script below.
In order to do this, we will introduce positional argument that can accept an arbitrary amount of values and we will also use the wrapping functionality that ``Argbash`` possesses.

The script's template is still quite simple:

.. literalinclude:: ../resources/examples/simple-wrapper.m4
   :language: bash

The ``simple`` in ``ARGBASH_WRAP`` argument refers to the script from the previous section.
``filename`` means that our wrapping script won't "inherit" the ``filename`` argument --- that's correct, it is the wrapping script that decides what arguments make it to the wrapped one.

When invoked with the help option, we get:

.. literalinclude:: _static/wrapper-output-help.txt
   :language: text

So let's try it!

.. literalinclude:: _static/wrapper-output-action.txt
   :language: text

Source
------

Let's examine the generated :ref:`minimal example script <minimal_example>` (the contents are displayed below).

We can see that the header still contains the ``Argbash`` definitions.
They are not there for reference only, you can actually change them and re-run ``Argbash`` on the *script* again to get an updated version!
Yes, you don't need the ``.m4`` template, the ``.sh`` file serves as a template that is equally good!

.. literalinclude:: ../resources/examples/minimal.sh
   :language: bash
