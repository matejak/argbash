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

You can start using Argbash even more quickly by generating the initial template for your script using `argbash-init` tool, which is also available in this image.


How to use it
=============

This image is useful if you work with Docker and you would like to use Argbash without having to install it.
The sensible way how to use the `Argbash` image is to create a one-line shell script that does the same as `argbash` or `argbash-init`, but accomplishes the task by creating the container and destroying it after the job has been done.


| OS | script |
| --- | --- |
| Posix (e.g. Linux, MacOS) | `docker run -it --rm -e PROGRAM=argbash -v "$(pwd):/work" matejak/argbash "$@"` |
| Windows | `docker run -it --rm -e PROGRAM=argbash -v "%CD%:/work" matejak/argbash %*` |

What happens here?
A container is created from the `matejak/argbash` image.

* The `-t` option is needed for the output to be displayed.
* The `-e PROGRAM=argbash` option is redundant and it basically affirms the container to invoke `argbash`. If you specify `PROGRAM=argbash-init`, `argbash-init` will be invoked instead, default program is `argbash`.
* The `-v ...:/work` mounts the current directory to the working directory of the container, which is `/work`.
* The `"$@"` or `%*` propagates any arguments given to this one-liner script to the `argbash` invocation in the container.
  Make sure that you use the `-o|--output` option - if you intend to use the Argbash output from stdout, the line endings will be of the DOS kind (i.e. `\r\n` instead of just `\n` - thanks to [Filip Filmar](https://github.com/filmil) who found this out).

Note that as the container mounts the host directory, you may have issues with SELinux or similar measures enforcing proactive security.


Example
=======

Imagine that you want to download an example, edit it, and make it a full-fledged script with `argbash`.
You obviously have to fire up `docker`, but then, you just create the one-liner, download the example, and proceed.

```
printf '%s\n' '#!/bin/bash' 'docker run -it --rm -v "$(pwd):/work" matejak/argbash "$@"' > argbash-docker
printf '%s\n' '#!/bin/bash' 'docker run -it -e PROGRAM=argbash-init --rm -v "$(pwd):/work" matejak/argbash "$@"' > argbash-init-docker
chmod a+x argbash-docker argbash-init-docker

./argbash-init-docker --pos positional-arg --opt optional-arg minimal.m4
vim minimal.m4

./argbash-docker minimal.m4 -o my-script.sh
./my-script.sh -h
```

Attribution
===========

The Argbash docker image has been contributed by [Peter Cummuskey](https://github.com/Tzrlk).
Idea to dockerize `argbash-init` came up from user [gnoshti](https://hub.docker.com/u/gnosthi/).
