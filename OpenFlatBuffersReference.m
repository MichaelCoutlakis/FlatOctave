%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \brief  Load in a flatbuffers file and unpack it. This is effectively the 
%         "Reference Implementation", or what the code generator aims to
%         generate.
% \author Michael Coutlakis
% \date   2021-03-06
% \note:  See https://google.github.io/flatbuffers/flatbuffers_internals.html
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clear all
clc

Directory = "C:\\Git\\Michael\\Octave\\FlatOctave\\WriteFlatbufferTestMessages";
FileName = "FlatMessage.fb";
FullFileName = [Directory, "\\", FileName];

fid = fopen(FullFileName, "rb");
fseek(fid, 0, SEEK_END);
FileLength = ftell(fid);
fseek(fid, 0, SEEK_SET);
b = fread(fid, FileLength);
fclose(fid);
% Make sure b is bytes. Just makes life easier below:
b = uint8(b);

% Let's have some conventions:
% idx, an absolute index into b, uint
% off_A_to_B, an offset from the stated location A to the stated destination B, int32
%   offRT and offVT only have destination specified since the source is start of the 
%   flatbuffer for RT and RT for VT
% offOuter: The offset to the field position of a member to it's actual location, e.g. 
% for strings which are not stored inline
% idx_FieldName_off, the index of an offset from the root table for a non-inline field
% RT: Root Table
% VT: vtable
% len: length in bytes, offset and index
% sizeA: size of A

% Load the library
flatbuffers
% Load the scrip:
TestMessages_generated

% See the reference for details:
% FIXME may need to swapbytes sometimes? But just treat little endian only for now
% If size prefixed, first 4 bytes is uint32_t of the size:
sizePrefix = typecast(b(1:4), "uint32")
% Next 4 bytes is offset to the root table:
offRT = typecast(b(5:8), "uint32")


% Root table:
% Note we need to account for: Octave's indexing starts at 1, if there is a size prefix this offsets everything by 4
SizePrefixedOffset = 4

% This is the root table in Octave's index into the bytes
idxRT = offRT + 1 + SizePrefixedOffset
offVT = typecast(b(idxRT:idxRT + 3), "int32")
% The start of the Vtable for this root table (in actual Octave Index)
idxVT = int32(idxRT) - offVT

sizeVT = typecast(b(idxVT:idxVT+1), "uint16")
InlineDataSize = typecast(b(idxVT + 2:idxVT + 3), "uint16")
N = int32(sizeVT / 2 - 2)  % Number of fields

FieldOffsets = typecast(uint8(b((idxVT + 4):(idxVT + 4 + N*2-1))), "uint16")

% Note: We would know this from the schema, but for now let's hard code it:
##VT_ = struct("Offsets", [4, 6, 8, 10, 12], "FieldNames", {{"m_String"; "m_Vector"; "m_Int32"; "m_float"; "m_NestedTable"}}); % NB the semicolon ; instead of , and {{}}
VT_ = struct("Offsets", [4], "FieldNames", {{"m_vTables"}}); % NB the semicolon ; instead of , and {{}}

### String:
##if(FieldOffsets(1) ~= 0)  % Check that the field is not deprecated
##  idx_m_String_off = idxRT + uint32(FieldOffsets(1))
##  
##  % For strings, the field contains another offset to where the field actually is since it's not stored inline:
##  offOuter = typecast(b(idx_m_String_off:idx_m_String_off + 3), "uint32")
##  idx_m_String = idx_m_String_off + offOuter
##  % For string fields, it's length of string then the string:
##  len_m_String = ReadUint32(b(idx_m_String:idx_m_String+3));
##  Msg.(VT_.FieldNames{1}) = cast(b(idx_m_String + 4:idx_m_String + 4 + len_m_String), "char")';
##end
##
##% Vector of floats:
##if(FieldOffsets(2) != 0)
##  m_VectorPosFieldOffset = idxRT + uint32(FieldOffsets(2))
##  
##  m_VectorRootOffset = typecast(b(m_VectorPosFieldOffset:m_VectorPosFieldOffset + 3), "uint32")
##  m_VectorPos = m_VectorPosFieldOffset + m_VectorRootOffset
##  VectorLength = typecast(b(m_VectorPos:m_VectorPos + 3), "uint32")
##  Msg.(VT_.FieldNames{2}) = typecast(b(m_VectorPos + 4:m_VectorPos + 4 + VectorLength * 4 -1), "single")'
##end
##
##% Int32:
##if(FieldOffsets(3) ~= 0)
##  m_Int32PosFieldOffset = idxRT + uint32(FieldOffsets(3));
##  % It's just a scalar, so we can do a straight read scalar function:
##  Msg.(VT_.FieldNames{3}) = typecast(b(m_Int32PosFieldOffset:m_Int32PosFieldOffset + 3), "int32");
##end
##
##% float:
##if(FieldOffsets(4) ~= 0)
##  m_floatPosFieldOffset = idxRT + uint32(FieldOffsets(4));
##  Msg.(VT_.FieldNames{4}) = typecast(b(m_floatPosFieldOffset:m_floatPosFieldOffset + 3), "single");
##end

##% Nested Table:
##if(FieldOffsets(5) ~= 0)
##  % Seems this is the start of the buffer:
##  idx_m_NestedTable_off = idxRT + uint32(FieldOffsets(5))
##  
####  % For nested Tables, ... ?
####  offOuter = typecast(b(idx_m_NestedTable_off:idx_m_NestedTable_off + 3), "uint32")
####  % This is where the 
####  idx_m_NestedTable = idx_m_NestedTable_off + offOuter
####  % For nested Table fields, ... ?
####  len_m_NestedTable = ReadUint32(b(idx_m_NestedTable:idx_m_NestedTable+3))
##  Msg.(VT_.FieldNames{5}) = OpenFlatBuffersReference_ReadNestedTable(b, idx_m_NestedTable_off)
##end

##% Nested Table:
##if(FieldOffsets(1) ~= 0)
##  % Seems this is the start of the buffer:
##  idx_m_NestedTable_off = idxRT + uint32(FieldOffsets(1))
##  
##  
##  Msg.(VT_.FieldNames{1}) = DataStructureT_Unpack(b, idx_m_NestedTable_off)
##end

### Vector of strings:
##if(FieldOffsets(1) != 0)
##  m_VectorPosFieldOffset = idxRT + uint32(FieldOffsets(1))
##  
##  m_VectorRootOffset = typecast(b(m_VectorPosFieldOffset:m_VectorPosFieldOffset + 3), "uint32")
##  m_VectorPos = m_VectorPosFieldOffset + m_VectorRootOffset
##  VectorLength = typecast(b(m_VectorPos:m_VectorPos + 3), "uint32")
##  
##  for(uK = 1:VectorLength)
##    idxElemOffPos = m_VectorPos + 4 * uK
##    idxElemK = idxElemOffPos + typecast(b(idxElemOffPos:idxElemOffPos + 3), "uint32")
##    # In the case of a string, there is a uint32_t length followed by the string
##    lenString = ReadUint32(b(idxElemK:idxElemK+3));
##    Msg.(VT_.FieldNames{1}){uK} = cast(b(idxElemK + 4:idxElemK + 4 + lenString - 1), "char")';
##  end
##end

# Vector of Tables:
if(FieldOffsets(1) != 0)
  m_VectorPosFieldOffset = idxRT + uint32(FieldOffsets(1))
  
  m_VectorRootOffset = typecast(b(m_VectorPosFieldOffset:m_VectorPosFieldOffset + 3), "uint32")
  m_VectorPos = m_VectorPosFieldOffset + m_VectorRootOffset
  VectorLength = typecast(b(m_VectorPos:m_VectorPos + 3), "uint32")
  
  
  for(uK = 1:VectorLength)
    #typecast(b(m_VectorPos + 4:m_VectorPos + 4 + VectorLength * 4 -1), "char")
    #b(m_VectorPos + 4:m_VectorPos + 4 + VectorLength * 4 -1)
    idxElemOffPos = m_VectorPos + 4 * uK
    idxElemK = idxElemOffPos + typecast(b(idxElemOffPos:idxElemOffPos + 3), "uint32")
    DST = DataStructureT_Unpack(b, idxElemOffPos)
    Msg.(VT_.FieldNames{1})(uK) = DataStructureT_Unpack(b, idxElemOffPos)
  end
end

% Start of the buffer
% b(1:4) -> Offset to root table
% start of the vtable
% b(5:6) size of table starting here
% b(7:8) size of inline data
% b(9...) array of uint16, offsets to fields from start of root table, 0 => not present

% start of root table:
% b(idxRT:idxRT + 3) -> offset to vtable used, default negative direction
% inline data 

