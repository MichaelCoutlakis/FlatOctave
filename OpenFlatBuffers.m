%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \brief Attempt to load in a flatbuffers file
% \author Michael Coutlakis
% \date 2021-03-06
% \note: See https://google.github.io/flatbuffers/flatbuffers_internals.html
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clear all

Directory = "C:\\Git\\Michael\\Octave\\FlatOctave\\WriteMyMessageFlatbuffer";
FileName = "FlatMessage.fb";
FullFileName = [Directory, "\\", FileName];

fid = fopen(FullFileName);
fseek(fid, 0, SEEK_END);
FileLength = ftell(fid);
fseek(fid, 0, SEEK_SET);
b = fread(fid, FileLength);

% E.g. we could get the string part like this:
cast(b, "char");

% See the reference for details:
% FIXME may need to swapbytes sometimes?
% If size prefixed, first 4 bytes is uint32_t of the size:
SizePrefix = typecast(uint8([b(1:4)]), "uint32")
% Next 4 bytes is offset to the root table:
RootTableOffset = typecast(uint8([b(5:8)]), "uint32")

% Read vtable. Should be in a function eventually:
TableSize = typecast(uint8([b(9), b(10)]), "uint16")
InlineDataSize = typecast(uint8([b(11), b(12)]), "uint16")

% Root table:
% Note we need to account for: Octave's indexing starts at 1, if there is a size prefix this offsets everything by 4
SizePrefixedOffset = 4
% This is the root table in Octave's index into the bytes
RT = RootTableOffset + 1 + SizePrefixedOffset
VTableOffset = typecast(uint8(b(RT:RT + 3)), "int32")
% The start of the Vtable for this root table (in actual Octave Index)
VT = int32(RT) - VTableOffset

VTableSize = typecast(uint8(b(VT:VT+1)), "uint16")
InlineDataSize = typecast(uint8(b((VT + 2):(VT + 3))), "uint16")
N = int32(VTableSize / 2 - 2)  % Number of fields
FieldOffsets = typecast(uint8(b((VT + 4):(VT + 4 + N))), "uint16")

% Now we look for the fields:
for IdxField = 1:N
  if(FieldOffsets(IdxField) ~= 0) 
    PosFieldOffset = RT + uint32(FieldOffsets(IdxField))
    
    % for strings, the field contains another offset to where the field is actually stored (as it's not inline)
    FieldOffsetFrom = typecast(uint8(b(PosFieldOffset:PosFieldOffset + 3)), "uint32")
    PosField = PosFieldOffset + FieldOffsetFrom
    % For string fields, it's length of string then the string:
    StringLength = typecast(uint8(b(PosField:PosField+3)), "uint32")
    StringChars = cast(b(PosField + 4:PosField + 4 + StringLength), "char")
  end  
end
