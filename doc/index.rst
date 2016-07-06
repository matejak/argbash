Argbash documentation
=====================

Argbash
-------

``Argbash`` (`<https://github.com/matejak/argbash>`_) is a ``Bash`` code generator that can assist you in writing scripts that accept arguments.
You declare arguments that your script should use in few lines and then, you run ``Argbash`` on those declarations to get a parsing code that can be used on all platforms that have ``Bash`` (Linux, OSX, MS Windows, ...).
``Argbash`` is free software, you are free to use it, share it, modify it and share the modifications with the world, since it is published under the 3-clause BSD linense.

:Authors:
  - `Matěj Týč <https://github.com/matejak>`_

:Copyright:
  - 2014-2015, Matěj Týč

Requirements
++++++++++++

You need:

* ``bash>=3.0``
* ``autoconf>=2.64`` (``Argbash`` makes use of the ``autom4te`` utility)

Quickstart
----------

In a nutshell, using ``Argbash`` consists of these simple steps:

#. You write a simple template of your script based on arguments your script is supposed to accept.
#. You run the ``argbash.sh`` script (located in the package's ``bin`` directory) on it to get the fully functional script.

Eventually, you may want to add/remove/rename arguments your script accepts.
In that case, you just need to edit the script --- you don't need to repeate the two steps listed above!
Why? It is so because the script retains the template section, so if you need to make adjustments to the template, you just edit the template section of the script and run ``argbash.sh`` on top of the script to get it updated.

Writing a template
++++++++++++++++++

Let's stick with a testing script that accepts some arguments and then it just prints their values.
So, let's say that we would like a script that produces the following help message:

.. literalinclude:: _static/minimal-output-help.txt
   :language: text
   :start-after: minimal.sh

Then, it means that we need following arguments:

* One mandatory positional argument.
  (In other words, an argument that must be passed and that is not preceeded by *options* such as ``--foo``, ``-f``.)
* Four optional arguments:

  * ``--option`` that accepts one value,
  * ``--print`` that doesn't accept any value --- it either is or isn't specified,
  * ``--version`` that also doesn't accept any value and the program is supposed just to print its version and quit afterwards, and finally
  * ``--help`` that prints a help message and also quits.

Therefore, we write this to the template:

.. literalinclude:: ../resources/examples/minimal.m4
   :language: bash
   :end-before: needed because of Argbash

The body of the script (i.e. lines past the template) is trivial, but note that it is enclosed in a pair of square brackets.
They are "hidden" in comments and not seen by the shell, but still, they have to be there for the "use the script as a template" feature to function.

.. literalinclude:: ../resources/examples/minimal.m4
   :language: bash
   :start-after: ARGBASH_GO

We generate the script from the template:

::

   bin/argbash.sh script.m4 -o script.sh 


Now we launch it and the output is good!

::

   ./script.sh posi-tional -o opt-ional --print

   Positional arg value: posi-tional
   Optional arg --option value: opt-ional

.. note::

   If something still isn't totally clear, take look at the :ref:`sec_example` section.

.. _limitations:

Limitations
+++++++++++

.. warning::

  Please read this carefuly.

#. The delimiter between optional argument name and value is whitespace, ``=`` is not supported.
   Create an issue if this disturbs you, it should be quite easy to implement.
#. Clustering of short arguments (e.g. using ``-xzf`` instead of ``-x -z -f``) is not supported.
#. The square brackets in your script should match (i.e. every opening square bracket ``[`` should be followed at some point by a closing square bracket ``]``).
   More precisely, the number of closing square brackets ``]`` must not exceed the number of opening ``[``.
   This limitation does apply to files that are processed by ``argbash.sh`` --- you are fine if you have the argument parsing code in a separate file and you don't use the ``INCLUDE_PARSING_CODE``.

Index
-----

Contents:

.. toctree::
   :maxdepth: 2

   install
   guide
   usage
   example
   others


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
