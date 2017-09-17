[argbash](https://argbash.io)
-----------------------------

![argbash logo](https://raw.githubusercontent.com/matejak/argbash/master/resources/logo/argbash-docker.png)

* Do you write `Bash` scripts that should accept arguments?
* But they don't since arguments support is a daunting task, because ...
* `getopt` is discouraged, `getopts` doesn't support long options, there is no widely-accepted `Bash` module to do the task and some solutions don't work on all platforms (Linux, OSX, MSW)...

Give a `Argbash` a try and stop being terrorized by those pesky arguments! With Argbash, you will get:


What it is
==========

Argbash is not a parsing library, but it is rather a code generator that generates a bash library tailor-made for your script.
It lets you to describe arguments your script should take and then, you can generate the `bash` parsing code.
It stays in your script by default, but you can have it generated to a separate file and let `Argbash` to include it in your script for you.
In any case, you won't need `Argbash` to run the script.

`Argbash` is very simple to use and the generated code is relatively nice to read.
Moreover, argument definitions stay embedded in the script, so when you need to update the parsing logic, you just re-run the `argbash` script on the already generated script.


How to use it
=============

This image is useful if you work with Docker and you would like to use Argbash without having to install it.
The sensible way how to use the `Argbash` image is to create a one-line shell script that does the same as `argbash`, but accomplishes the task by creating the container and destroying it after the job has been done.

| OS | script |
| --- | --- |
| Posix (e.g. Linux, MacOS) | `docker run -it --rm -v "$(pwd):/work" matejak/argbash "$@"` |
| Windows | `docker run -it --rm -v "%CD%:/work" matejak/argbash %*` |

What happens here?
A container is created from the `matejak/argbash` image.

* The `-t` option is needed for the output to be displayed.
* The `-v ...:/work` mounts the current directory to the working directory of the container, which is `/work`.
* The `"$@"` or `%*` propagates any arguments given to this one-liner script to the `argbash` invocation in the container.


Example
=======

Imagine that you want to download an example, edit it, and make it a full-fledged script with `argbash`.
You obviously have to fire up `docker`, but then, you just create the one-liner, download the example, and proceed.

```
printf '%s\n' '#!/bin/bash' 'docker run -it --rm -v "$(pwd):/work" matejak/argbash "$@"' > argbash-docker
chmod a+x argbash-docker

wget https://raw.githubusercontent.com/matejak/argbash/master/resources/examples/minimal.m4
vim minimal.m4

./argbash-docker minimal.m4 -o my-script.sh
./my-script.sh -h
```

Attribution
===========

The Argbash docker image has been contributed by [Peter Cummuskey](https://github.com/Tzrlk).
