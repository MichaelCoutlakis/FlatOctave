%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \brief Attempt to load in a flatbuffers file
% \author Michael Coutlakis
% \date 2021-03-06
% \note: See https://google.github.io/flatbuffers/flatbuffers_internals.html
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clear all
clc

% Equivalent of load module I guess, load all the functions in the flatbuffers.m script:
flatbuffers

Directory = "C:\\Git\\Michael\\Octave\\FlatOctave\\WriteMyMessageFlatbuffer";
FileName = "FlatMessage.fb";
FullFileName = [Directory, "\\", FileName];

fid = fopen(FullFileName);
fseek(fid, 0, SEEK_END);
FileLength = ftell(fid);
fseek(fid, 0, SEEK_SET);
b = fread(fid, FileLength);
b = uint8(b);

% Load the scrip:
MyMessages_generated
Msg = MessageStringT_Unpack(b(5:end))

error("exit")

% E.g. we could get the string part like this:
##cast(b, "char");

% See the reference for details:
% FIXME may need to swapbytes sometimes?
% If size prefixed, first 4 bytes is uint32_t of the size:
SizePrefix = typecast(([b(1:4)]), "uint32")
% Next 4 bytes is offset to the root table:
RootTableOffset = typecast(([b(5:8)]), "uint32")

% Read vtable. Should be in a function eventually:
##TableSize = typecast(uint8([b(9), b(10)]), "uint16")
##InlineDataSize = typecast(uint8([b(11), b(12)]), "uint16")

% Root table:
% Note we need to account for: Octave's indexing starts at 1, if there is a size prefix this offsets everything by 4
SizePrefixedOffset = 4

##MsgStringT = MsgStringUnpack(b(5:end));

##MsgStringT = MsgString.Unpack(b(5:end));


% This is the root table in Octave's index into the bytes
RT = RootTableOffset + 1 + SizePrefixedOffset
VTableOffset = typecast(uint8(b(RT:RT + 3)), "int32")
% The start of the Vtable for this root table (in actual Octave Index)
VT = int32(RT) - VTableOffset

VTableSize = typecast(uint8(b(VT:VT+1)), "uint16")
InlineDataSize = typecast(uint8(b((VT + 2):(VT + 3))), "uint16")
N = int32(VTableSize / 2 - 2)  % Number of fields
##b((VT + 4):(VT + 4 + N*2 - 1))
FieldOffsets = typecast(uint8(b((VT + 4):(VT + 4 + N*2-1))), "uint16")

% Note: We would know this from the schema, but for now let's hard code it:
VT_ = struct("Offsets", [4, 6, 8, 10], "FieldNames", {{"m_String"; "m_Vector"; "m_Int32"; "m_float"}}); % NB the semicolon ; instead of , and {{}}

% String:
if(FieldOffsets(1) ~= 0)
  m_StringPosFieldOffset = RT + uint32(FieldOffsets(1))
  
  % For strings, the field contains another offset to where the field actually is since it's not stored inline:
  m_StringRootOffset = typecast(uint8(b(m_StringPosFieldOffset:m_StringPosFieldOffset + 3)), "uint32")
  m_StringPos = m_StringPosFieldOffset + m_StringRootOffset
  % For string fields, it's length of string then the string:
  StringLength = typecast(uint8(b(m_StringPos:m_StringPos+3)), "uint32");
  Msg.(VT_.FieldNames{1}) = cast(b(m_StringPos + 4:m_StringPos + 4 + StringLength), "char")';
end

% Vector of floats:
if(FieldOffsets(2) != 0)
  m_VectorPosFieldOffset = RT + uint32(FieldOffsets(2))
  
  m_VectorRootOffset = typecast(uint8(b(m_VectorPosFieldOffset:m_VectorPosFieldOffset + 3)), "uint32")
  m_VectorPos = m_VectorPosFieldOffset + m_VectorRootOffset
  VectorLength = typecast(uint8(b(m_VectorPos:m_VectorPos + 3)), "uint32")
  Msg.(VT_.FieldNames{2}) = typecast(uint8(b(m_VectorPos + 4:m_VectorPos + 4 + VectorLength * 4 -1)), "single")'
end
% Int32:
if(FieldOffsets(3) ~= 0)
  m_Int32PosFieldOffset = RT + uint32(FieldOffsets(3));
  % It's just a scalar, so we can do a straight read scalar function:
  Msg.(VT_.FieldNames{3}) = typecast(uint8(b(m_Int32PosFieldOffset:m_Int32PosFieldOffset + 3)), "int32");
end

% float:
if(FieldOffsets(4) ~= 0)
  m_floatPosFieldOffset = RT + uint32(FieldOffsets(4));
  Msg.(VT_.FieldNames{4}) = typecast(uint8(b(m_floatPosFieldOffset:m_floatPosFieldOffset + 3)), "single");
end


##% Now we look for the fields:
##for IdxField = 1:N
##  if(FieldOffsets(IdxField) ~= 0) 
##    PosFieldOffset = RT + uint32(FieldOffsets(IdxField))
##    
##    % for strings, the field contains another offset to where the field is actually stored (as it's not inline)
##    FieldOffsetFrom = typecast(uint8(b(PosFieldOffset:PosFieldOffset + 3)), "uint32")
##    PosField = PosFieldOffset + FieldOffsetFrom
##    % For string fields, it's length of string then the string:
##    StringLength = typecast(uint8(b(PosField:PosField+3)), "uint32")
##    StringChars = cast(b(PosField + 4:PosField + 4 + StringLength), "char")
##  end  
##end