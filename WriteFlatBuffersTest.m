close all
clear all # NB if loading a script file otherwise previously defined functions can stay in memory
clc

# Test writing a flatbuffer:

% Equivalent of load module I guess, load all the functions in the flatbuffers.m script:
flatbuffers

% Load the scrip:
TestMessages_generated


### Nested table:
##T.m_NestedInt = 37;
##T.m_String = "Hello!";
##
##B = NestedT_Pack(T)

# Test Message:
T.m_Int32 = 47774;
T.m_String = "Hello, this is a string from Octave!";

B = TestMessageT_Pack(T)

# Write a size prefix:
B = [WriteUint32(length(B)), B]

# Save to file:
Directory = "C:\\Git\\Michael\\Octave\\FlatOctave\\WriteFlatbufferTestMessages";
FileName = "OctaveTestMessage.fb";
FullFileName = [Directory, "\\", FileName];

fid = fopen(FullFileName, "wb");
fwrite(fid, B);
fclose(fid);