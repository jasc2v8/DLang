[![Dub version](https://img.shields.io/dub/v/rdub.svg)](https://code.dlang.org/packages/rdub)
[![Dub downloads](https://img.shields.io/dub/dt/rdub.svg)](https://code.dlang.org/packages/rdub)

# rdub

RDUB is a front end for [DUB](https://code.dlang.org/getting_started), a D language build tool. It's designed to build source file(s) specified on the command line, without having to edit the dub files: dub.json, dub.sdl, src/app.d, source/app.d

This tool is great for running examples and building/testing small projects!  It's used in my other projects, [dlang-beginners](https://github.com/jasc2v8/dlang-beginners) and [dwtlib](https://github.com/jasc2v8/dwtlib).

## Changes

V3.0.0 Will force a rebuild every time, --force does not have to be on the command line

## Usage

$ rdmd rdub -h

    rdub is a front end for DUB, a D language build tool

    rdub [-h] [path/foo.d ... path/fooN.d] | [path/*.d] [dub args]

    -h    --help This help information

    rdub            = run dub with defaults ./src/app.d or ./source/app.d

    rdub path/foo.d = run dub as follows:

    1. If first run, copy src to src_bak, and source to source_bak
    2. Delete src/* and source/* to avoid more than one main() file
    3. Copy path/foo.d to ./src/foo.d
    4. Runs "dub --force" to build and run ./src/foo.d
    5. Pass all [dub args] to dub, except: -h

    Requires: dub.json or dub.sdl must have
                name "yourexename" and targetType "executable"

    Will always --force a rebuild, use dub to skip a forced rebuild by rdub.

## Examples

$ cd examples

	$ example_console.bat
	$ example_multi.bat
	$ example_wildcard.bat
	$ example_gui //requires [dwtlib](https://github.com/jasc2v8/dwtlib)

## Build rdub

Instead of using rdmd rdub, build rdub.exe as follows:

Build:

    cd build
    rdub_build.bat

Test:
    
    rdub.exe console\hello.d
    