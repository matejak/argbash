Argument parsing layout
=======================

It's all set with optional args.
The problem arises with positional ones that accept variable number of arguments.

Legend:

  * symbol p1.2 means positional argument p1, its 2nd argument.
  * symbol [p1.3] means positional argument p1, its 3rd argument and the fact that it is optional --- if it is not specified, no error occurs.

    If 2nd argument of p1 is optional, the 4th is even more optional (provided that p1 can accept 4 or more args).
    Although the help message notation should be

    ::

      p1.1 [p1.2 [p1.3 [...]]],

    we will use the less verbose notation

    ::

      p1.1 [p1.2] [p1.3] [...],

    that is supposed to mean the same.

The following is supported:

* Fixed number of positional arguments followed by whatever.
  e.g.:

  * ``p1.1 p1.2 p1.3 p2.1 [p2.2] [p2.3] ... [p2.n]``

* Optional argument followed by optional argument(s)

  * ``p1.1 p1.2 p1.3 p2.1 [p2.2] [p3.1] [p4.1]``

  What happens when the user passes p1.1 -- p2.1 and one more?
  The assignment is done from left to right.

What is NOT supported:

* Required args after arbitrary number of args (be it infinity or not)

  * ``p1.1 [p1.2] [p1.3] p2.1 p2.2``

   Current status would be:

     * ``foo bar baz -> p1.1 p2.1 p2.2``
     * ``foo foo2 bar baz -> p1.1 p2.1 p2.2 p1.2``

  * ``[p1.1] p2.1 p2.2``

