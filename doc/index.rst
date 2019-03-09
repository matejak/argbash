Argbash documentation
=====================

Argbash
-------

``Argbash`` (`<https://argbash.io>`_) is a ``bash`` code generator that can assist you in writing scripts that accept arguments.
You declare arguments that your script should use in a few lines and then, you run ``Argbash`` on those declarations to get a parsing code that can be used on all platforms that have ``bash`` (Linux, macOS, MS Windows, ...).

You :ref:`can have <file_layout>` your parsing code in the script, you can have ``Argbash`` to help you to use it as a ``bash`` library, or you can generate the library yourself and include it yourself too, it's up to you.
A basic template generator ``argbash-init`` is part of the package, and you can :ref:`get started with it <quickstart_init>` in a couple of seconds.

``Argbash`` is free and `open source <https://github.com/matejak/argbash>`_ software, you are free to use it, share it, modify it and share the modifications with the world, since it is published under the 3-clause BSD linense.

.. image:: ../resources/logo/web-legacy.svg
   :alt: Link to argbash online generator
   :align: center
   :target: https://argbash.io/generate

:Version:
  |version|
:Authors:
  `Matěj Týč <https://github.com/matejak>`_
:Copyright:
  2014--|current-year|, Matěj Týč
:Website:
  https://argbash.io

Requirements
++++++++++++

Both you and your users need:

* ``bash>=3.0``

Only you need those on the top:

* ``autoconf>=2.64`` (``Argbash`` makes use of the ``autom4te`` utility)
* ``grep``, ``sed``, etc. (if you have ``autoconf``, you probably have those already)

.. _quickstart:

Quickstart
----------

In a nutshell, using ``Argbash`` consists of these simple steps:

#. You write (or generate) a simple template of your script based on arguments your script is supposed to accept.
#. You run the ``argbash`` script (located in the package's ``bin`` directory) on it to get the fully functional script.

Eventually, you may want to add/remove/rename arguments your script accepts.
In that case, you just need to edit the script --- you don't need to repeate the two steps listed above!
Why? It is so because the script retains the template section, so if you need to make adjustments to the template, you just edit the template section of the script and run ``argbash`` on top of the script to get it updated.

How to use ``Argbash``?
You can either

* :ref:`download and install it <user_install>` locally,
* use the `online generator <https://argbash.io/generate>`_, or
* use the `Docker container <https://hub.docker.com/r/matejak/argbash/>`_.


.. _quickstart_init:

Generating a template
+++++++++++++++++++++

``Argbash`` features the ``argbash-init`` script that you can use :ref:`to generate <argbash_init>` a template in one step.
Assume that you want a script that accepts one (mandatory) positional argument ``positional-arg`` and two optional ones ``--option`` and ``--print``, where the latter is a boolean argument.

In other words, we want to support these arguments:

* ``--option`` that accepts one value,
* ``--print`` or ``--no-print`` that doesn't accept any value, and
* an argument named ``positional-arg`` that we are going to refer to as positional that must be passed and that is not preceeded by *options* (such as ``--foo``, ``-f``).

We call ``argbash-init`` and as the desired result is a script, we directly pipe the output of ``argbash-init`` to ``argbash``:

.. literalinclude:: _static/index_script-create.txt
   :language: text

Let's see what the auto-generated script can do!

.. literalinclude:: _static/index_script-help.txt
   :language: text

.. literalinclude:: _static/index_script-output.txt
   :language: text

We didn't have to do much, yet the script is pretty capable.


Writing a template
++++++++++++++++++

Now, let's explore more advanced argument types on a trivial script that accepts some arguments and then prints their values.
So, let's say that we would like a script that produces the following help message:

.. literalinclude:: _static/minimal-output-help.txt
   :language: text
   :start-after: minimal.sh

Then, it means that we need following arguments:

* One mandatory positional argument.
  (In other words, an argument that must be passed and that is not preceded by options)
* Four optional arguments:

  * ``--option`` that accepts one value,
  * ``--print`` or ``--no-print`` that doesn't accept any value --- it either is or isn't specified,
  * ``--version`` that also doesn't accept any value and the program is supposed just to print its version and quit afterwards, and finally
  * ``--help`` that prints a help message and quits afterwards.

Therefore, we call ``argbash-init`` like we did before:

.. literalinclude:: _static/minimal_init-create.txt
   :language: bash

Next, we edit the template so it looks like this:

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

   bin/argbash minimal.m4 -o minimal.sh


Now we launch it and the output is good!

::

   ./minimal.sh posi-tional -o opt-ional --print

   Positional arg value: posi-tional
   Optional arg --option value: opt-ional

.. note::

   If something still isn't totally clear, take look at the :ref:`sec_example` section.


.. _limitations:

Limitations
+++++++++++

.. warning::

  Please read this carefully.

#. The square brackets in your script have to match (i.e. every opening square bracket ``[`` has to be followed at some point by a closing square bracket ``]``).

   There is a workaround --- if you need constructs s.a. ``red=$'\e[0;91m'``, you can put the matching square bracket behind a comment, i.e. ``red=$'\e[0;91m'  # match square bracket: ]``.

   This limitation does apply only to files that are processed by ``argbash`` --- you are fine if you have the argument parsing code in a separate file and you :ref:`don't use <usage_manual>` the ``INCLUDE_PARSING_CODE`` macro.
   You are also OK if you use :ref:`argbash-init <argbash_init>` in the *decoupled mode*.

#. The generated code generally contains bashisms as it relies heavily on ``bash`` arrays to process any kind of positional arguments and multi-valued optional arguments.
   That said, if you stick with optional arguments only, a POSIX shell s.a. ``dash`` should be able to process the ``Argbash``-generated parsing code.


FAQ
---

* **Q**: What is the license of generated code?
  Is it also the 3-clause BSD, as it contains parts of Argbash source code?

  **A**: No, as it is mentioned in the `LICENSE` file, you can distribute Argbash output under your terms.
  We recommend you to adhere to the BSD license --- keeping comments indicating that the code is generated is fair towards script's users.

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
