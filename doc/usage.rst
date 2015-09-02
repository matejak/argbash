Usage
=====

Layout
------

Separate file for parsing
+++++++++++++++++++++++++

This is really easy.
Just place the directives in the file behind comments and then run the ``argbash.sh`` with the ``--standalone`` argument.

Parsing code and script body together
+++++++++++++++++++++++++++++++++++++

This requires some trivial adjustments to your script.

#. Add Argbash definitions to the script so they come before the script body.
   Let's say that the file is called ``my-template.m4`` (the extension [*]_ is not important in itself). 
   
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

.. [*] ``m4`` is the extension used for the ``M4`` language, but we use the ``m4sugar`` extension built on top of it).


