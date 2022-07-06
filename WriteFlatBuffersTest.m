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
##T.m_VecFloat = [4.2, 3.8];
##T.m_Int = 13;
##T.m_str = "Hello World!";
##T.m_float = 3.14159;
##T.m_VecFloat2 = [3.7, 8.2];
##T.m_Nested.m_NestedInt = 32;
##T.M_Int = 77;
##T.m_VecInt = [7, 8];
##T.m_VecInt2 = [17, 18];
#T.m_String = "Hello, this is a string from Octave!";

##T.m_VecString{1, 1} = "asdf";
##T.m_VecString{1, 2} = "hi";

T.m_VecElement(1).m_Int = 13;
T.m_VecElement(2).m_Int = 14;

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