Others
------

Here follows a list of influences and/or alternatives:

* Python ``argparse``: The main inspiration: https://docs.python.org/3/library/argparse.html

  * Pros: Works really well
  * Cons: It is Python, we are Bash.
  * Argbash: We handle the boolean options better.

* Bash --- ``shflags``: The Bash framework for argument parsing: https://github.com/kward/shflags

  * Pros: It works great on Linux.
  * Cons: Doesn't work with Windows Bash, doesn't support long options on OSX.
  * Argbash: We work the same on all platforms that have ``bash``.

* ``getopt``: Eternal utility for parsing command-line.
  This is what powers ``shflags``.

  * Pros: The GNU version can work with long and short optional arguments.
  * Cons: Its use is `discouraged <http://bash.cumulonim.biz/BashFAQ(2f)035.html#getopts>`_ --- it seems to have some issues, you still need to deal with positional arguments by other means.

* ``getopts``: Bash builtin for parsing command-line.

  * Pros: Being included with Bash, it behaves the same on all platforms.
  * Cons: Supports only short optional arguments.

