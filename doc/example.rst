.. _sec_example:

Minimal example
===============

Essentials
----------

The source code for the minimal example could look like this:

.. literalinclude:: ../resources/examples/minimal.m4
   :language: bash

Here, we can notice multiple notable things:

#. Definitions of arguments are placed before the script body.
   From Bash point of view, they are commented out, so the "template" can be a syntactically valid script.

#. You access the values of argument ``foo-bar`` as ``$_ARG_FOO_BAR`` etc. (this is covered more in-depth in :ref:`parsing_results`).

So let's try the script in action! Let's see what happens when we pass the -h option:

.. include:: _static/minimal-output-help.txt

OK, so it seems that passing it one (mandatory) positional arg will do the trick:

.. include:: _static/minimal-output-noverbose.txt

Oops, we have forgot to turn print on! Let's fix that...

.. include:: _static/minimal-output-foobar.txt

Closer look
-----------

Let's examine the generated script (the contents are displayed below).

We can see that the header still contains the ``Argbash`` definitions.
They are not there for reference only, you can actually change them and re-run ``Argbash`` on the *script* again to get an updated version!
Yes, you don't need the ``.m4`` template, the ``.sh`` file serves as a template that is equally good!

.. literalinclude:: ../resources/examples/minimal.sh
   :language: bash
