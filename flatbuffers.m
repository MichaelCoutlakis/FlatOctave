%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \brief  Script file for Octave flatbuffers. If you like this is the Octave
%         side of the flatbuffers library, providing any useful functions
% \author Michael Coutlakis
% \date   2021-03-06
% \note:  Since this is a script file, before using it load the functions with
%         "flatbuffers"
% \note:  See https://google.github.io/flatbuffers/flatbuffers_internals.html
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
1;

% Another way to get multiple functions in one file would have been classdef, but whenever I use that it output to the Octave console
% seems to stop which is mind numbingly frustrating.


% Read an inline field, returning the default value if it's not there:
function R = FlatBuffersReadScalar(bytes, DefaultVal)
  x = 2  
endfunction

function Fun2()
  x = 3
endfunction

% Read a uint32 from the 4 bytes
function u = ReadUint32(b)
  u = typecast(b(1:4), "uint32");
endfunction

% Read an int32 from the 4 bytes
function u = ReadInt32(b)
  u = typecast(b(1:4), "int32");
endfunction

% Read a uint16 from the 2 bytes
function u = ReadUint16(b)
  u = typecast(b(1:2), "uint16");
endfunction