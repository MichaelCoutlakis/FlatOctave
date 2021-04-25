# FlatOctave

This is a utility for generating Octave scripts from a flatbuffers schema to read flatbuffers.

## Motivation

Why should there be an Octave version of Flatbuffers?

Well, you probably won't be using Octave and Flatbuffers in a final system. However, it may be useful for development, debugging or diagnostics.

For example, you might have some data structure in a Flatbuffer in C++ which is part of some algorithm under development. The Octave Flatbuffers could allow this data to be accessed for visualization.

Additionally, Octave provides sockets. Flatbuffers provides a mechanism of transferring data to the other side.

## Limitiations

Little Endian machines are assumed. I don't expect that I would ever need Big Endian support and you probably won't either so I'm not really too bothered to provide it.

## Example

### Windows
flatbuffers can be installed via the vcpkg package manager, see https://google.github.io/flatbuffers/flatbuffers_guide_building.html

vcpkg install flatbuffers:x64-windows
#### Install flatbuffers


Make schema

cd C:\lib\vcpkg\buildtrees\flatbuffers\x86-windows-rel

flatc --cpp --gen-object-api -o C:\Git\Michael\Octave\FlatOctave -I C:\Git\Michael\Octave\FlatOctave C:\Git\Michael\Octave\FlatOctave\TestMessages.fbs

Run the FlatOctave Octave script compiler on the Schema


Use the Octave script :smiley:

## Implemented Functionality
The following functionality has been implemented:

| Flatbuffer Type | Read Flatbuffer into Octave | Write Flatbuffer from Octave |
|---|:---:|:---:|
|int| :heavy_check_mark: | :heavy_check_mark: |
|float| :heavy_check_mark: | :x: |
|string| :heavy_check_mark: | :heavy_check_mark: |
|enum | :x: | :x: |
|:[float] (vector&lt;float&gt;)| :heavy_check_mark: | :x: |
|:[string] (vector&lt;string&gt;)| :heavy_check_mark: | :x: |
|Table| :heavy_check_mark: | :heavy_check_mark:|
|:[Table] (vector&lt;Table&gt;)| :heavy_check_mark: | :x: |


## Further Reading

1. Flatbuffers internals: https://google.github.io/flatbuffers/flatbuffers_internals.html
2. Flatbuffers binary format: https://github.com/dvidelabs/flatcc/blob/master/doc/binary-format.md#flatbuffers-binary-format
3. Octave data types: https://octave.org/doc/v4.2.1/Built_002din-Data-Types.html
