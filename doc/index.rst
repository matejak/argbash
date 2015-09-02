Argbash documentation
=====================

Quickstart
----------

Basically, you write a simple template of your script.
Then, you run the ``argbash.sh`` script (located in the package's ``bin`` directory) on it to get the fully functional script.
The script retains the template section, so if you need to make adjustments to the template, you just edit the template section of the script and run ``argbash.sh`` on top of it to get the updated script.

Requirements
++++++++++++

You need:

* ``bash>=3.0``
* ``autoconf>=2.64`` (Argbash makes use of the ``autom4te`` utility)


Writing a template
++++++++++++++++++

Let's stick with a testing script that accepts some arguments and then it just prints them out.
So, let's say that we would like a script that produces the following help message:


Then, it means that we need arguments:

*

Therefore, we write this to the template:

The body of the script is trivial, but note that it is enclosed in square brackets.
They are "hidden" in comments, but still, they have to be there.


We generate the script from the template:

The output is good!

Limitations
+++++++++++

.. warning::

  Please read this carefuly.

#. The delimiter between optional argument name and value is whitespace, ``=`` is not supported.
   Create an issue if this disturbs you, it should be quite easy to implement.
#. Clustering of short arguments (e.g. using ``-xzf`` instead of ``-x -z -f``) is not supported.
#. The square brackets in your script have to match (i.e. every opening square bracket ``[`` should be followed at some point by a closing square bracket ``]``)
   This limitation does not apply if you have the argument parsing code in a separate file.


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

