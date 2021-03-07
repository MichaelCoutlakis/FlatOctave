# FlatOctave

This is a utility for generating Octave scripts from a flatbuffers schema to read flatbuffers.

## Example

### Windows
flatbuffers can be installed via the vcpkg package manager, see https://google.github.io/flatbuffers/flatbuffers_guide_building.html

vcpkg install flatbuffers:x64-windows
#### Install flatbuffers


Make schema

cd C:\lib\vcpkg\buildtrees\flatbuffers\x86-windows-rel

flatc --cpp --gen-object-api -o C:\Git\Michael\Octave\FlatOctave -I C:\Git\Michael\Octave\FlatOctave C:\Git\Michael\Octave\FlatOctave\MyMessages.fbs

Run the FlatOctave Octave script compiler on the Schema


Use the Octave script :)

## Further Reading

1. Flatbuffers internals: https://google.github.io/flatbuffers/flatbuffers_internals.html
2. Flatbuffers binary format: https://github.com/dvidelabs/flatcc/blob/master/doc/binary-format.md#flatbuffers-binary-format
3. Octave data types: https://octave.org/doc/v4.2.1/Built_002din-Data-Types.html
