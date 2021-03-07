#include <iostream>
#include <fstream>
#include <string>
#include <vector>



#include "../MyMessages_generated.h"

int main()
{
	using namespace MyMessages;
	// Create a message to transmit and populate it with some data:
	//Message1T MsgTx;
	MessageStringT MsgTx;
	MsgTx.m_String = "Hello, flat Octave world!";
	MsgTx.m_Vector = { 11, 22, 33, 44 };
	MsgTx.m_Int32 = 42;
	MsgTx.m_float = 3.14159f;
	//MsgTx.m_int = 42;
	//MsgTx.m_float = 3.14159f;
	//MsgTx.m_vector = { 1.f, 2.f, 3.f, 4.f };
	//MsgTx.m_cvector = { {1.f, 1.f}, {1.f, -1.f} };

	// Save it to disk:
	flatbuffers::FlatBufferBuilder Builder;
	Builder.FinishSizePrefixed(MessageString::Pack(Builder, &MsgTx));

	std::string Filename = "FlatMessage.fb";
	std::ofstream FileOut(Filename);
	if (!FileOut)
		std::cout << "Could not open file to save" << std::endl;
	FileOut.write(reinterpret_cast<const char*>(Builder.GetBufferPointer()), Builder.GetSize());
	// Close it to make sure the contents are actually written to disk:
	FileOut.close();

	// For sanity's sake, let's read it in to see if the round trip works:
	std::ifstream FileIn(Filename, std::ios::binary | std::ios::in);

	// Seek to the end of the file
	FileIn.seekg(0, std::ios::end);
	// Determine file size from input position indicator tellg
	std::streampos pos = FileIn.tellg();

	if (pos < 0)
		std::cout << "Could not determine file size!" << std::endl;
	size_t length = static_cast<size_t>(pos);

	// Set position back to beginning of file for subsequent read:
	FileIn.seekg(0, std::ios::beg);
	std::vector<uint8_t> Buffer(length);
	FileIn.read(reinterpret_cast<char*>(Buffer.data()), length);
	FileIn.close();

	// Unpack the received message:
	//Message1T MsgRx;
	//GetSizePrefixedMessage1(Buffer.data())->UnPackTo(&MsgRx);
	MessageStringT MsgRx;
	flatbuffers::GetSizePrefixedRoot<MessageString>(Buffer.data())->UnPackTo(&MsgRx);
	return 0;
}
