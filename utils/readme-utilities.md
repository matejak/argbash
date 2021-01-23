# Convenience wrapper utilities

- [Convenience wrapper utilities](#convenience-wrapper-utilities)
  - [Introduction](#introduction)
  - [Environment configuration](#environment-configuration)
    - [Docker image](#docker-image)
    - [Wrapper utilities and aliases](#wrapper-utilities-and-aliases)
  - [Script `utility-argbash-init.sh`](#script-utility-argbash-initsh)
  - [Script `utility-argbash.sh`](#script-utility-argbashsh)

## Introduction

I prefer to use the containerized version of [argbash][matejak-github-argbash]. Not only I can spare installing it on my local host, but I can use my [Docker image clone][this-dockerhub] (or the [original image][matejak-dockerhub-argbash]) on both Linux and Windows the same easy way. The usage examples are described in the [original README][matejak-github-argbash-docker-readme] file.

However, it can be even easier. Some time ago I've developed two simple wrapper utilities, that make using the dockerized **argbash** even more convenient.

After an easy, one-time environment configuration, it's the simplest one-liner you'll need most of the time:

```shell
argbash scrap.sh
```

The example above would update the existing script called `scrap.sh`, which has already been processed with **argbash** previously. This is all what you need in 99% of cases.

If you would need to generate the script `scrap.sh` as new from scratch, then you would first use the **template generator** `argbash-init` and then the **script generator** `argbash`:

```shell
### generate a new M4 template 'scrap.sh'
argbash-init scrap.sh

### transform the M4 template 'scrap.sh' into the script 'scrap.sh'
argbash scrap.sh 
```

After that you can edit the script according the [argbash documentation][argbash-doc-api] and update it again by executing `argbash scrap.sh`. That is the usage pattern I prefer.

## Environment configuration

The examples above have assumed the following:

- **Docker** has already been installed on the local host
- **argbash Docker image** has already been downloaded
- **convenience wrapper utilities** have already been downloaded and configured
- **aliases** `argbash` and `argbash-init` have already been defined

### Docker image

You can use my [argbash image clone][this-dockerhub] or the [original Docker image][matejak-dockerhub-argbash]. Both images should be equivalent most of the time. However, there could be also differences sometimes. Actually, the reason I've created my clone some time ago, was the outdated original image.

You can download the Docker images as follows:

```shell
### accetto clone
docker pull accetto/argbash-docker

### original image
docker pull matejak/argbash
```

### Wrapper utilities and aliases

The convenience utilities `utility-argbash-init.sh` and `utility-argbash.sh` are stored in the project's subfolder `utils`. Because they themselves have been developed with **argbash**, they offer all usual features, including the embedded help.

It is recommended to use them through the aliases `argbash-init` and `argbash`. You have to follow your own pattern, which fits your actual working environment, but assuming that you've copied the utilities into you home directory, you could define the aliases by adding the following lines into the file `~/.bashrc`:

```shell
alias argbash="~/utility-argbash.sh"
alias argbash-init="~/utility-argbash-init.sh"
```

The general usage pattern for both utilities is the same:

```text
<utility> [<options>] [--] <output-file> [<parameters>]
```

where

- `<utility>` is the full utility script name (including the path, if needed) or the alias (if defined)
- `<options>` are the optional options for the utility itself (see the embedded help)
- `--` is an optional separator between the options and the positional arguments
- `<output-file>` is the mandatory name of the file to process
- `<parameters>` are the optional arguments that will be passed to the **argbash** programs inside the container

Both utilities also need to know two more things (so called **essential variables**):

- which **argbash** image to use (essential variable `image`)
- which working directory to use (essential variable `workdir`)

These data usually do not change, so they could be configured beforehand. The utilities aim to support different usage scenarios, so they offer several ways to configure these **essential variables**. There are initialized in the following order (in decreasing priority):

- from the command line arguments (`-m|--image`, `-w|--workdir`)
- from the environment variables (`ARGBASH_IMAGE`, `ARGBASH_WORKDIR`)
- from the local variables in the utility scripts (`_essential_default_image`, `_essential_default_workdir`)

The default value of the "last resort" local variable `_essential_default_image` is `accetto/argbash-docker`.

The default value of the "last resort" local variable `_essential_default_workdir` is `.`, which will be always replaced by the current directory path (`$PWD`).

## Script `utility-argbash-init.sh`

This is the wrapper script for the dockerized [argbash template generator][argbash-doc-template-generator] `argbash-init`.

The embedded help should be probably sufficient:

```shell
utils> ./utility-argbash-init.sh -h
Generates 'argbash' compatible template from provided argument definitions using dockerized 'argbash'.
Usage: ./utility-argbash-init.sh [-v|--version] [-h|--help] [-m|--image <arg>] [-w|--workdir <arg>] [--(no-)echo] [--info] [--] <output-file> [<parameters-1>] ... [<parameters-n>] ...
        <output-file>: Output template file (recommended is '*.m4' or '*.sh')
        <parameters>: Argument definitions and/or other options for 'argbash-init' (see bellow and 'https://argbash.readthedocs.io')
        -v, --version: Prints version
        -h, --help: Prints help
        -m, --image: Docker image to use (no default)
        -w, --workdir: Working directory to use (no default)
        --echo, --no-echo: Just print the command line to be executed (off by default)
        --info: Just print the current essentials (env/local variables)


<< ---
Attention! The output file name must come before the argument definitions and/or other options for 'argbash-init'!

Supported argument definitions are:
   - single-valued positional arguments ('--pos')
   - single-valued optional arguments ('--opt')
   - boolean optional arguments ('--opt-bool')

The essential local variables ('image', 'workdir') are initialized in the following order:
   - from the command line arguments ('-m/--image', '-w/--workdir')
   - from the environment variables (ARGBASH_IMAGE, ARGBASH_WORKDIR)
   - from the local variables ('_essential_default_image', '_essential_default_workdir')

The created container will be automatically removed after generating the output file.
Note that the container must have writing permissions for the working directory.
---
#
```

The only required parameter is the **name of the output template file** that should be generated. It is provided as the first positional argument.

It's recommended to use the extension `*.sh` or `*.m4`. However, be aware, that the script generator `utility-argbash.sh` will refuse to overwrite files having the `*.m4` extension. I personally prefer starting with the `*.sh` extension right away.

The utility does not require any **option definitions** for the output script, but they can be also provided:

```shell
### providing option definitions
argbash-init scrap.sh --opt-bool debug --opt log --pos config
```

The example above would generate a new **M4 template** `scrap.sh` for the future script called `scrap.sh`, which would use the following arguments:

- an optional boolean argument `debug`
- an optional single value argument `log`
- a required positional argument `config`

Note that the generated **M4 template** file `scrap.sh` is not the final script yet. It needs to be processed by the **script generator** `utility-argbash.sh` first.

You can provide also additional parameters, that will be passed to the **argbash template generator** program inside the container. They can be provided before or after the **option definitions** for the output script.

One of such parameters is the option `--standalone` (or `-s`), which will generate the argument parsing code into a separate file:

```shell
### using additional option '-s'
argbash-init scrap.sh --opt-bool debug --opt log --pos config -s
```

The example above would generate two template files:

- `scrap.sh` as the M4 template for the future main script file
- `scrap-parsing.m4` as the M4 template for the future parsing script

Both templates should be then processed by the **argbash script generator** using a single command:

```shell
argbash scrap.sh
```

The example above will generate the final main script `scrap.sh` and the parsing script `scrap-parsing.sh`, which will be used by the main script. The template file `scrap-parsing.m4` is not needed any more and can be deleted manually.

If you want to check, what command line the utility would use, you can execute it with the option `--echo`:

```shell
argbash-init --echo scrap.sh --opt-bool debug --opt log --pos config -s

### output
docker run -it --rm -e PROGRAM=argbash-init -v <your-current-directory-will-be-here>:/work accetto/argbash-docker --opt-bool debug --opt log --pos config -s scrap.sh
```

The created Docker container is ephemeral and it will be automatically removed after the output file is generated.

Note that the container must have writing permissions for the working directory.

## Script `utility-argbash.sh`

This is the wrapper script for the dockerized [argbash script generator][argbash-doc-script-generator].

The embedded help should be probably sufficient:

```shell
utils> ./utility-argbash.sh -h
Generates 'argbash' compatible script from provided 'argbash' compatible template using dockerized 'argbash'.
Usage: ./utility-argbash.sh [-v|--version] [-h|--help] [-m|--image <arg>] [-w|--workdir <arg>] [-o|--output <arg>] [--(no-)echo] [--info] [--] <template> [<parameters-1>] ... [<parameters-n>] 
...
        <template>: Input template file to process
        <parameters>: Other options for 'argbash' (see 'https://argbash.readthedocs.io')
        -v, --version: Prints version
        -h, --help: Prints help
        -m, --image: Docker image to use (no default)
        -w, --workdir: Working directory to use (no default)
        -o, --output: Output file to generate (no default)
        --echo, --no-echo: Just print the command line to be executed (off by default)
        --info: Just print the current essentials (env/local variables)


<< ---
Attention! The input template file name must come before the other 'argbash' options!

The input template can be one of the following:
  - an '*.m4' template compatible with 'argbash'
  - a script previously generated by 'argbash'

The input template file is overwritten by default, except when:
  - it is a '*.m4' file
  - an another output file is explicitly defined ('-o/--output')

The essential local variables ('image', 'workdir') are initialized in the following order:
  - from the command line arguments ('-m/--image', '-w/--workdir')
  - from the environment variables (ARGBASH_IMAGE, ARGBASH_WORKDIR)
  - from the local variables ('_essential_default_image', '_essential_default_workdir')

The created container will be automatically removed after generating the output file.
Note that the container must have writing permissions for the working directory.
---
#
```

The only required parameter is the **input template file name** that should be processed. It is provided as the first positional argument. By default it is also used as the **output script file name**.

The **input template file** can be an **M4 template** previously generated by the **argbash template generator** (e.g. `utility-argbash-init.sh`) or an **argbash-ready script** already processed by the **argbash script generator** (e.g. `utility-argbash.sh`) previously.

Be aware, that if the **input template file** has the file extension `*.m4`, then the **script generator** utility will refuse to overwrite it. You have to use the option `-o` in such case:

```shell
### M4 template file will not be overwritten
argbash -o scrap.sh scrap.m4
```

If you want to check, what command line the utility would use, you can execute it with the option `--echo`:

```shell
argbash --echo scrap.sh

### output
docker run -it --rm -e PROGRAM=argbash -v <your-current-directory-will-be-here>:/work accetto/argbash-docker -o scrap.sh scrap.sh
```

The created Docker container is ephemeral and it will be automatically removed after the output file is generated.

Note that the container must have writing permissions for the working directory.

***

[this-dockerhub]: https://hub.docker.com/r/accetto/argbash-docker

[matejak-github-argbash]: https://github.com/matejak/argbash
[matejak-dockerhub-argbash]: https://hub.docker.com/r/matejak/argbash/
[matejak-github-argbash-docker-readme]: https://github.com/matejak/argbash/blob/master/docker/README.md

[argbash-doc-api]: https://argbash.readthedocs.io/en/latest/guide.html#argbash-api
[argbash-doc-template-generator]: https://argbash.readthedocs.io/en/latest/usage.html#template-generator
[argbash-doc-script-generator]: https://argbash.readthedocs.io/en/latest/usage.html#argbash
