%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \brief  Load in a flatbuffers file unpack and repack it. This is effectively
%         the "Reference Implementation", or what the code generator aims to
%         generate.
% \author Michael Coutlakis
% \date   2021-03-06
% \note:  See https://google.github.io/flatbuffers/flatbuffers_internals.html
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
b = uint8(b)'

% Load the scrip:
TestMessages_generated
% Note: 5 is the index of the buffer start after the size prefix
Msg = TestMessageT_Unpack(b, 5)

# Ok let's see if we can pack it to the same bytes:
TestMessageT = Msg;

##function TestMessageT = TestMessageT_Unpack(b, idxBuf)
Buf = uint8(0);
#FieldOffsets = typecast(b(idxVT + 4:idxVT + 4 + 2*N - 1), "uint16")
VT = struct("Offsets", [4, 6, 8, ], "Fields", {{"m_Int32";"m_String";"m_Nested";}});
N = length(VT.Offsets);
lenVT = 4 + N * 2;
lenInlineData = 4;    # 4 size of VTO



# Write the table:
Buf(1:4) = uint8(0);
# TODO soff to VT

# Members:
offsVT = zeros(1, N); # VT offsets to each member

# Indexes to offsets to tables and string / vector data stored out of line
# We will need to come back here once all the inline data has been added to 
# fill these in:
idxOffsOutline = [];  
# Offsets to the outline data for the corresponding entry in idxOffsOutline
offsOutline = [];
BufOutline = [];

idxMem = 5;
# Int field:
if(VT.Offsets(1) ~= 0)
##  idx = 7;
##  WriteInt32(TestMessageT.m_Int32)
  offsVT(1) = length(Buf);
  Buf(idxMem:idxMem + 3) = WriteInt32(TestMessageT.m_Int32)
  lenInlineData += 4
##  offsVT(1) = idxMem - 5;
##  idxMem += 4;
end

# String field:
if(VT.Offsets(2) ~= 0)
  offsVT(2) = length(Buf);
  offsOutline(end + 1) = length(BufOutline) - length(Buf)
  BufOutline = [BufOutline, WriteString(TestMessageT.m_String')]
  # It's outline, so add a record:
  idxOffsOutline(end + 1) = length(Buf) + 1
  Buf = [Buf, uint8([7, 7, 7, 7])]
  lenInlineData += 4
end

##error("exit")
disp("Here");
### Nested table
##if(VT.Offsets(3) ~= 0)
##  offsVT(3) = length(Buf);
####  offsOutline(end + 1) = length(BufOutline) + length(Buf)
####  BufOutline = [BufOutline, []]; # TODO: Add the nexted Table
####    # It's outline, so add a record:
####  idxOffsOutline(end + 1) = length(Buf) + 1;
##  
##  Buf = [Buf, uint8([9, 9, 9, 9])]
##  lenInlineData += 4  # Offset to the nexted RT
##end



# Fill in the offsets:
for(k = 1:length(idxOffsOutline))
  idx = idxOffsOutline(k)
  Buf(idx:idx + 3) = WriteUint32(offsOutline(k) + length(Buf))
end

# Write outline data:
Buf = [Buf, BufOutline]

# Write the VT:
BufVT(1:2) = WriteUint16(lenVT)
BufVT(3:4) = WriteUint16(lenInlineData)
for(idxElem = 1:N)
 BufVT = [BufVT, WriteUint16(offsVT(idxElem))]
end

# Write the soff to the VT:
Buf(1:4) = WriteInt32(length(BufVT))
# Write the size prefix and RTO
lenInner = length(Buf) + length(BufVT)
lenPad = 0
if((r = rem(lenInner, 4)) ~= 0)
  lenPad = 4 - r
end
offRT = 4 + lenPad + length(BufVT)
FlatBuf = [WriteUint32(4 + lenPad + lenInner), WriteUint32(offRT), zeros(1, lenPad), BufVT, Buf]
# Check they are the same
##d = sum(abs(FlatBuf - b))