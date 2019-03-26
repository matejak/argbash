[argbash](https://argbash.io)
=============================

[![Build Status](https://travis-ci.org/matejak/argbash.svg)](https://travis-ci.org/matejak/argbash)
[![Documentation Status](https://readthedocs.org/projects/argbash/badge/?version=latest)](https://readthedocs.org/projects/argbash/?badge=latest)

![argbash logo](resources/logo/argbash.png)

* Do you write `Bash` scripts that should accept arguments?
* But they don't since arguments support is a daunting task, because ...
* `getopt` is discouraged, `getopts` doesn't support long options, there is no widely-accepted `Bash` module to do the task and some solutions don't work on all platforms (Linux, OSX, MSW)...

Give a `Argbash` a try and stop being terrorized by those pesky arguments! With Argbash, you will get:

* Fast, minimalistic declaration of arguments your script expects (see below for supported argument types).
* Scripts generated from definitions once that can be used on all platforms that have `bash`.
* Definitions embedded in few lines of the script itself (so you can use `Argbash` to regenerate the parsing part of your script easily).
* Ability to re-use low-level `Argbash`-aware scripts by wrapping them by higher-level `Argbash`-aware ones conveniently, without duplicating code.
* Easy installation (optional). Just [grab a release](https://github.com/matejak/argbash/releases), unzip it, go inside and run `cd resources && make install` (you may want to run `sudo make install PREFIX=/usr` for a system-wide installation).
* [Documentation](http://argbash.readthedocs.org/en/latest/) and [examples](resources/examples).

Make your existing script powered by `Argbash` [in a couple of minutes](http://argbash.readthedocs.io/en/latest/#generating-a-template). Explore various Argbash flavours:

Flavour               | Target group
-------               | ------------
[Argbash online](https://argbash.io/generate) | Use it if you want to try Argbash without installing it and you have permanent access to the Internet.
[Argbash CLI](https://github.com/matejak/argbash/releases/latest) | Install the package to have `argbash` ready locally all the time.
[Argbash Docker](https://hub.docker.com/r/matejak/argbash/) | Pretty much like Argbash CLI, but you don't have to install it, you just download the image.


What it is
----------

Argbash is not a parsing library, but it is rather a code generator that generates a bash library tailor-made for your script.
It lets you to describe arguments your script should take and then, you can generate the `bash` parsing code.
It stays in your script by default, but you can have it generated to a separate file and let `Argbash` to include it in your script for you.
In any case, you won't need `Argbash` to run the script.

`Argbash` is very simple to use and the generated code is relatively nice to read.
Moreover, argument definitions stay embedded in the script, so when you need to update the parsing logic, you just re-run the `argbash` script on the already generated script.

So by writing few comments to your script and running the Argbash's `bin/argbash` over it, you will get a `bash` script with argument parsing.
See the [simple example source template](resources/examples/simple.m4) and [simple example script](resources/examples/simple.sh) for the result.
If you are not into long reading, let `bin/argbash-init` generate the template for you.

Following argument types are supported:

- Positional arguments (defaults supported, possibiliy of fixed, variable or infinite number of arguments),
- optional arguments that take one value,
- boolean optional arguments,
- repeated (i.e. non-overwriting) optional arguments,
- incrementing (such as `--verbose`) optional arguments and
- action optional arguments (such as `--version`, `--help`).

Following outputs are available:

- Bash scripts, tailor-made bash parsing libraries.
- POSIX scripts that use `getopts`, also tailor-made.
- Bash completion.
- [docopt](https://docopt.org)-compliant usage message.
- Manpage output using [rst2man](http://docutils.sourceforge.net/sandbox/manpage-writer/rst2man.txt).

The utility has been inspired by Python's `argparse` and the `shflags` project.

**[Read the docs (latest stable version)](http://argbash.readthedocs.org/en/stable/) for more info**


Requirements
------------

- `bash` that can work with arrays (most likely `bash >= 3.0`) (the only requirement for *users* - i.e. people that only execute scripts and don't make them)
- `autom4te` utility that can work with sets (part of `autoconf >= 2.63` suite)
- basic utilities s.a. `sed`, `grep`, `cat`, `test`.
