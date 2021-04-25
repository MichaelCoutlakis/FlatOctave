%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \brief Load in flatbuffers file and unpack it using the generated code
% \author Michael Coutlakis
% \date 2021-03-06
% \note: See https://google.github.io/flatbuffers/flatbuffers_internals.html
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clear all
clc

% Equivalent of load module I guess, load all the functions in the flatbuffers.m script:
flatbuffers

Directory = "C:\\Git\\Michael\\Octave\\FlatOctave\\WriteFlatbufferTestMessages";
FileName = "FlatMessage.fb";
FullFileName = [Directory, "\\", FileName];

fid = fopen(FullFileName);
fseek(fid, 0, SEEK_END);
FileLength = ftell(fid);
fseek(fid, 0, SEEK_SET);
b = fread(fid, FileLength);
b = uint8(b);

% Load the scrip:
TestMessages_generated
% Note: 5 is the index of the buffer start after the size prefix
Msg = TestMessageT_Unpack(b, 5)