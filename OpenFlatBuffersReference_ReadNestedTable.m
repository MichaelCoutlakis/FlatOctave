%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \brief  Load in a flatbuffers file and unpack it. This is effectively the 
%         "Reference Implementation", or what the code generator aims to
%         generate for a Nested Table
% \author Michael Coutlakis
% \date   2021-03-06
% \note:  See https://google.github.io/flatbuffers/flatbuffers_internals.html
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function NestedTable = OpenFlatBuffersReference_ReadNestedTable(b, idxBufStart)
  NestedTable = {};
  % Offset to root table:
  offRT = ReadUint32(b(idxBufStart:idxBufStart + 3))


  % This is the root table in Octave's index into the bytes
  idxRT = offRT + + idxBufStart
  offVT = typecast(b(idxRT:idxRT + 3), "int32")
  % The start of the Vtable for this root table (in actual Octave Index)
  idxVT = int32(idxRT) - offVT

  sizeVT = typecast(b(idxVT:idxVT+1), "uint16")
  InlineDataSize = typecast(b(idxVT + 2:idxVT + 3), "uint16")
  N = int32(sizeVT / 2 - 2)  % Number of fields

  FieldOffsets = typecast(uint8(b((idxVT + 4):(idxVT + 4 + N*2-1))), "uint16")

  % Note: We would know this from the schema, but for now let's hard code it:
  VT_ = struct("Offsets", [4,], "FieldNames", {{"m_NestedInt";}}); % NB the semicolon ; instead of , and {{}}
  
  % Int32:
  if(FieldOffsets(1) ~= 0)
    idx_m_NestedInt = idxRT + uint32(FieldOffsets(1));
    % It's just a scalar, so we can do a straight read scalar function:
    NestedTable.(VT_.FieldNames{1}) = ReadInt32(b(idx_m_NestedInt:idx_m_NestedInt + 3));
  end


endfunction