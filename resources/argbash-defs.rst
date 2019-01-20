
.. |AUTHOR| replace:: Matěj Týč

.. |MAN_SECTION| replace:: 1

.. |DESCRIPTION| replace::
   Argbash is a code generator that typically generates a bash argument-parsing library tailor-made for your script.
   It lets you to describe arguments your script should take and then, you can generate the ``bash`` parsing code.
   It stays in your script by default, but you can have it generated to a separate file and let ``bash`` to include it in your script for you.
   ``Argbash`` is very simple to use and the generated code is relatively nice to read.
   Moreover, argument definitions stay embedded in the script, so when you need to update the parsing logic, you just re-run the ``argbash`` script on the already generated script.

.. |OPTION_OUTPUT| replace:: \

.. |OPTION_TYPE| replace:: Check out the documentation to learn about all argbash capabilities that are supported.

.. |OPTION_LIBRARY| replace:: This option is deprecated and it is the same as ``--strip user-content``.

.. |OPTION_STRIP| replace::
   You can either strip ``none``, which is useful for scripts.
   If you strip ``user-content``, you keep the Argbash header.
   If you strip ``all``, you will have only the generated content in the result.

.. |OPTION_CHECK_TYPOS| replace:: \

.. |OPTION_COMMENTED| replace:: \

.. |OPTION_SEARCH| replace:: \

.. |OPTION_DEBUG| replace:: \

.. |OPTION_HELP| replace:: \

.. |OPTION_VERSION| replace:: \
