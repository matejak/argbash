# argbash

![argbash logo](resources/logo/argbash.png)

Tired of arg processing (in `BASH`)? Don't let it bash you, take iniciative instead!

## What it is

Argbash is not a parsing library, but it is rather a code generator.
It lets you to describe arguments your script should take and then, you can generate `BASH` code that you can include in your script (and from then on, forget about `argbash` altogether).
`argbash` is very simple to use and the generated code is also rather nice to read (at if you don't have allergy to tabs).
Moreover, argument definitions stay embedded in the script, so when you need to update the parsing logic, you just re-run `argbash` on the already generated script.

So by writing few comments to your script and running the Argbash's `bin/genparse.sh` over it, you will get a BASH script with argument parsing.
See the `resources/examples/simple.m4s` for source and `resources/examples/simple.sh` for the result.

Following arguments are supported:

- Positional arguments,
- optional arguments that take one value,
- boolean optional arguments and
- action optional arguments (such as --version, --help).

The utility has been inspired by Python's `argparse` and the `shflags` project.

## Requirements

 - `BASH` that can work with arrays (most likely `bash >= 3.0`)
 - `autom4te` utility that can work with sets (part of `autoconf >= 2.63` suite)
