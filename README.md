# argbash

Bash argument parser

Well, `argbash` is not a parsing library, but it is rather a code generator.
It lets you to describe arguments your script should take and then, you can generate `bash` code that you can include in your script (and from then on, forget about `argbash` altogether).
`argbash` is very simple to use and the generated code is also rather nice to read (at if you don't have allergy to tabs).

Let's see an example script that is supposed to print size of a file (the core functionality is the `wc -c <filename> | cut -f 1 -d ' '` that calculates size in bytes and then `expr <size> / 1024` that calculates size in kilobytes etc.).
Here is what we need:

 - One required positional argument (e.g. the filename).
 - One optional argument (units of measurement).
 - One boolean argument (e.g. --verbose).
 - Help and version info should be included.

Then, the input for `argbash` looks like this (let's say you save it into a `parse.m4s` file):

	ARG_POSITIONAL_SINGLE([filename])
	ARG_OPTIONAL_SINGLE([unit], u, [What unit we accept (b for bytes, k for kilobytes, M for megabytes)], b)
	ARG_VERSION([echo $0 v0.1])
	ARG_OPTIONAL_BOOLEAN(verbose)
	ARG_HELP
	ARGBASH

The script code could look like this:

	source parse.sh
	
	VERBOSE=$_ARG_VERBOSE
	UNIT=$_ARG_UNIT

	test -f $_ARG_FILENAME || { echo "Filename $_ARG_FILENAME doesn't seem to belong to a file"; exit 1; }
	FILENAME="$_ARG_FILENAME"

	if [ $VERBOSE = on ]
	then
		_b="bytes (B)"
		_kb="kilobytes (kB)"
		_mb="megabytes (MB)"
	else
		_b="B"
		_kb="kB"
		_mb="MB"
	fi

	SIZE_BYTES=$(wc -c "$FILENAME" | cut -f 1 -d ' ')

	test "$UNIT" = b && echo $SIZE_BYTES $_b && exit 0

	SIZE_KILOBYTES=$(expr $SIZE_BYTES / 1024)
	test "$UNIT" = k && echo $SIZE_KILOBYTES $_kb && exit 0

	SIZE_MEGABYTES=$(expr $SIZE_KILOBYTES / 1024)
	test "$UNIT" = M && echo $SIZE_MEGABYTES $_mb && exit 0

	test "$VERBOSE" = on && echo "The unit '$UNIT' is not supported!"
	exit 1

You obtain the `parse.sh` by generating it from the `parse.m4s` you have to write this way:

	bin/genparae.sh parse.m4sh -o parse.sh

That's it!

If you don't feel comfortable including the parsing code in your script, you can actually cheat and include the script code in square brackets in a `script.m4s` file.
Actually, that's the case of the example you can find in `resources/examples/simple.m4s`

Requirements:

 - `bash` that can work with arrays (most likely `bash >= 3.0`)
 - `autom4te` utility that can work with sets (part of `autoconf >= 2.63` suite)
