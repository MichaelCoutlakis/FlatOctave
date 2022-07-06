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
```flatbuffer
table MyBuffer
{
    m_Int:int32;
    m_VecFloat:[float];
    m_String:string;
}
```
Compile the schema
```
cd C:\lib\vcpkg\buildtrees\flatbuffers\x86-windows-rel

flatc --cpp --gen-object-api -o OutputDirectory -I IncludeDirectory MyBuffer.fbs
```
Run the FlatOctave Octave script compiler on the Schema

Use the Octave script :smiley:

```Octave
 B.m_Int = 42;
 B.m_VecFloat = [1, 2, 3, 4];
 B.m_String = "Hello From Octave!";

 Bytes = MyBufferT_Pack(B);

 # Write a size prefix:
 Bytes = [WriteUint32(length(Bytes)), Bytes];

 # Save it to disk or send it over the network:
 fid = fopen("Filename");
 fwrite(fid, Bytes);
 fclose(fid);
```

Read the flatbuffer in C++
```cpp
    std::vector<uint8_t> Buffer;
    // ... Read data into Buffer
    MyBufferT MyBufferRx;
    flatbuffers::GetSizePrefixedRoot<MyBuffer>(Buffer.data())->UnpackTo(&MyBufferRx);
```

## Implemented Functionality
The following functionality has been implemented:

| Flatbuffer Type | Read Flatbuffer into Octave | Write Flatbuffer from Octave |
|---|:---:|:---:|
|int| :heavy_check_mark: | :heavy_check_mark: |
|float| :heavy_check_mark: | :heavy_check_mark: |
|string| :heavy_check_mark: | :heavy_check_mark: |
|enum | :x: | :x: |
|:[float] (vector&lt;float&gt;)| :heavy_check_mark: | :heavy_check_mark: |
|:[string] (vector&lt;string&gt;)| :heavy_check_mark: | :heavy_check_mark: |
|Table| :heavy_check_mark: | :heavy_check_mark:|
|:[Table] (vector&lt;Table&gt;)| :heavy_check_mark: | :heavy_check_mark: |
|Array| :x: | :x: |
|Default Values | :x: | :x:|
|Optional Values | :x: | :x:|
|Required Values | :x: | :x:|
|Namespace |:x:| :x: |


## Why don't you just use python?
We don't ask this question :see_no_evil:

One reason might be that language hops are undesireable each time some feature isn't available.

## Further Reading

1. Flatbuffers internals: https://google.github.io/flatbuffers/flatbuffers_internals.html
2. Flatbuffers binary format: https://github.com/dvidelabs/flatcc/blob/master/doc/binary-format.md#flatbuffers-binary-format
3. Octave data types: https://octave.org/doc/v4.2.1/Built_002din-Data-Types.html
