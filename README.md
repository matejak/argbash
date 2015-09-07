# argbash

[![Build Status](https://travis-ci.org/matejak/argbash.svg)](https://travis-ci.org/matejak/argbash)
[![Documentation Status](https://readthedocs.org/projects/argbash/badge/?version=latest)](https://readthedocs.org/projects/argbash/?badge=latest)

![argbash logo](resources/logo/argbash.png)

Do you write `Bash` scripts that are supposed to accept arguments?

Aren't you tired of that? `getopt` is discouraged, `getopts` doesn't support long options, there is no widely-accepted `Bash` module to do the task and some solutions don't work on all platforms (Linux, OSX, MSW)...

Give a `Argbash` a try and stop being terrorized by those pesky arguments! With Argbash, you will get:

* Fast, minimalistic declaration of arguments your script expects (positional, optional, long, short, boolean).
* Generate script from definitions once and use it afterwards on all platforms that have `Bash`!
* Definitions will stay embedded in few lines of the script itself (so you can use `Argbash` to regenerate the parsing part of your script easily).
* Easy installation. Just [grab a release](https://github.com/matejak/argbash/releases), unzip it, go inside and run `cd resources && make install` (you may want to run `sudo make install PREFIX=/usr/bin` for a system-wide installation).
* [Documentation](doc/index.rst) and [examples](resources/examples).

## What it is

Argbash is not a parsing library, but it is rather a code generator.
It lets you to describe arguments your script should take and then, you can generate `BASH` code that you can include in your script (and from then on, forget about `argbash` altogether).
`argbash` is very simple to use and the generated code is also rather nice to read (at if you don't have allergy to tabs).
Moreover, argument definitions stay embedded in the script, so when you need to update the parsing logic, you just re-run `argbash` on the already generated script.

So by writing few comments to your script and running the Argbash's `bin/argbash.sh` over it, you will get a BASH script with argument parsing.
See the `resources/examples/simple.m4s` for source and `resources/examples/simple.sh` for the result.

Following arguments are supported:

- Positional arguments,
- optional arguments that take one value,
- boolean optional arguments and
- action optional arguments (such as --version, --help).

The utility has been inspired by Python's `argparse` and the `shflags` project.

**[Read the docs](http://argbash.readthedocs.org/en/latest/) for more info**

## Requirements

 - `BASH` that can work with arrays (most likely `bash >= 3.0`)
 - `autom4te` utility that can work with sets (part of `autoconf >= 2.63` suite)
