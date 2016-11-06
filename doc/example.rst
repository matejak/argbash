.. _sec_example:

Examples
========

Templates
---------

.. _minimal_example:

Minimal example
+++++++++++++++

Let's call minimal example a script that accepts some arguments and prints their values.
Let's consider a positional, optional, optional boolean, ``--version`` and ``--help`` arguments with parsing code embedded in the script.
First of all, we can generate the template using ``argbash-init``.
Then, we will edit it and add the script body.

First of all, we go examine ``argbash-init`` help --- either by running ``argbash-init -h`` or :ref:`looking into the documentation <argbash_init_general>`.
We find out that we can have ``argbash-init`` generate the positional, optional arguments and help, so we go ahead:

.. literalinclude:: _static/minimal_init-create.txt
   :language: bash

The output of ``argbash-init`` looks like this:

.. literalinclude:: ../resources/examples/minimal-raw.m4
   :language: bash

We add useful information and the line with the ``--version`` macro (by looking it up in the API docs) and the template finally looks better.
Plus, we append the actual script body to the template:

.. literalinclude:: ../resources/examples/minimal.m4
   :language: bash

Here, we can notice multiple notable things:

#. ``argbash-init`` has produced code that warn us if we treat the template as a script (i.e. if we execute it).
   This code will not be in the final script --- it will disappear as we pass the template to ``argbash``.

#. Definitions of arguments are placed before the script body.
   From ``bash`` point of view, they are commented out, so the "template" can be a syntactically valid script.

#. You access the values of argument ``foo-bar`` as ``$_arg_foo_bar`` etc. (this is covered more in-depth in :ref:`argument_names`).

So let's try the script in action!
We have to generate it first by passing the template to ``argbash``:

.. literalinclude:: _static/minimal_argbash-create.txt
   :language: text

This has produced the code :ref:`we can observe below <src_minimal>` (notice that the leading "this is not a script error" lines have disappeared).
Let's see what happens when we pass the ``-h`` option:

.. literalinclude:: _static/minimal-output-help.txt
   :language: text

OK, so it seems that passing it one (mandatory) positional arg will do the trick:

.. literalinclude:: _static/minimal-output-noverbose.txt
   :language: text

Oops, we have forgot to turn print on! Let's fix that...

.. literalinclude:: _static/minimal-output-foobar.txt
   :language: text

.. _ex_separating:

Separating the parsing code
+++++++++++++++++++++++++++

Let's take a look at a script that takes filename as the only positional argument and prints size of the corresponding file.
The caller can influence the unit of display using optional argument ``--unit``.
This script is a bit artificial, but hang on --- we will try to use it from within a wrapping script.

This time, we will :ref:`separate the parsing code and the script itself <file_layout>`.
The parsing code will be in the ``simple-parsing.sh`` file and the script then in ``simple.sh``.

.. note::

   This is the manual approach.
   A simpler way would be calling ``argbash-init`` in the :ref:`managed or decoupled mode <argbash_init_modes>` --- it will create the basic templates as in the previous example.

The template for the script's parsing section is really simple.
Below are the sole contents of ``simple-parsing.m4`` file:

.. literalinclude:: ../resources/examples/simple-parsing.m4
   :language: bash

Then, let's take a look at the script's template body (i.e. the ``simple.m4`` file):

.. literalinclude:: ../resources/examples/simple.m4
   :language: bash

We obtain the script from the template by running ``argbash`` over it --- it detects the parsing template and interconnects those two.

.. code-block:: bash

   argbash simple.m4 -o simple.sh

In other words, it will examine the ``simple.m4`` template, finding out that there is the :ref:`INCLUDE_PARSING_CODE <parsing_code>` macro.
If the parsing template (in our case ``simple-parsing.m4`` or ``simple-parsing.sh``) is found, a parsing script is produced out of it (otherwise, an error occurs).
Finally, the ``simple.sh`` script is (re)generated --- basically only the source directive is added, see those few lines:

.. literalinclude:: ../resources/examples/simple.sh
   :language: bash
   :end-before: # [ <-

When invoked with the help option, we get:

.. literalinclude:: _static/simple-output-help.txt
   :language: text

It will work as long as the parsing code's location (next to the script itself) doesn't change:

.. _ex_wrapping:

Wrapping scripts
++++++++++++++++

We will show how to write a script that accepts a list of directories and a glob pattern, combines them together, and displays size of files using the previous script.
In order to do this, we will introduce positional argument that can accept an arbitrary amount of values and we will also use the wrapping functionality that ``Argbash`` possesses.

We want to wrap the ``simple.m4`` (or ``simple.sh``).
However, since the script doesn't include any command definitions, we have to wrap the parsing component ``simple-parsing.``.
The script's template is still quite simple:

.. literalinclude:: ../resources/examples/simple-wrapper.m4
   :language: bash

The ``simple-parsing`` in :ref:`ARGBASH_WRAP <argbash_wrap>` argument refers to the parsing part of the script from the previous section.
Remember, we say that we are wrapping a script, but in fact, we just inherit a subset of its arguments and the actual wrapping (i.e. calling the wrapped script)  is still up to us, although it is made easy by a great deal.
The ``filename`` argument means that our wrapping script won't "inherit" the ``filename`` argument --- that's correct, it is the wrapping script that decides what arguments make it to the wrapped one.

When invoked with the help option, we get:

.. literalinclude:: _static/wrapper-output-help.txt
   :language: text

So let's try it!

.. literalinclude:: _static/wrapper-output-action.txt
   :language: text

Source
------

.. _src_minimal:

Minimal example
+++++++++++++++

Let's examine the generated :ref:`minimal example script <minimal_example>` (the contents are displayed below).

We can see that the header still contains the ``Argbash`` definitions.
They are not there for reference only, you can actually change them and re-run ``Argbash`` on the *script* again to get an updated version!
Yes, you don't need the ``.m4`` template, the ``.sh`` file serves as a template that is equally good!

.. literalinclude:: ../resources/examples/minimal.sh
   :language: bash
