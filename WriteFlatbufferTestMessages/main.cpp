#include <iostream>
#include <fstream>
#include <string>
#include <vector>



#include "../TestMessages_generated.h"

TestMessages::TestMessageT ReadTestMessage(const std::string& strFilename)
{
	using namespace TestMessages;
	// For sanity's sake, let's read it in to see if the round trip works:
	std::ifstream FileIn(strFilename, std::ios::binary | std::ios::in);

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
	TestMessageT MsgRx;
	flatbuffers::GetSizePrefixedRoot<TestMessage>(Buffer.data())->UnPackTo(&MsgRx);
	return MsgRx;
}

int main()
{
	using namespace TestMessages;
	auto MsgOctaveRx = ReadTestMessage("OctaveTestMessage.fb");

	// Create a message to transmit and populate it with some data:
	//Message1T MsgTx;
	TestMessageT MsgTx;
	MsgTx.m_Int32 = 42;
	//MsgTx.m_float = 3.14159f;
	MsgTx.m_String = "asdfa";
	//MsgTx.m_Nested = std::make_unique<NestedT>();
	//MsgTx.m_Nested->m_NestedInt = 37;
	//MsgTx.m_Nested->m_String = "Hello";
	//MsgTx.m_Vector = { 11, 22, 33, 44 };
	//

	//MsgTx.m_NestedTable = std::make_unique<NestedT>();
	//MsgTx.m_NestedTable->m_NestedInt = 47774;

	///* Test with a vector of strings: */
	//MsgTx.m_vstrStrings.push_back("Hello");
	//MsgTx.m_vstrStrings.push_back("World!");

	///* Test with a vector of tables: */
	//MsgTx.m_vTables.push_back(std::make_unique<DataStructureT>());
	//MsgTx.m_vTables.back()->m_Int32 = 17;
	//MsgTx.m_vTables.back()->m_String = "Hey";
	//MsgTx.m_vTables.push_back(std::make_unique<DataStructureT>());
	//MsgTx.m_vTables.back()->m_Int32 = 19;
	
	//MsgTx.m_vTables.push_back(std::make_unique<DataStructureT>());
	//MsgTx.m_vTables.back()->m_String = "Hey";

	//MsgTx.m_NestedTable = std::make_unique<DataStructureT>();
	////MsgTx.m_NestedTable->m_String = "asdf";
	//MsgTx.m_NestedTable->m_Int32 = 19;

	//MsgTx.m_int = 42;
	//MsgTx.m_float = 3.14159f;
	//MsgTx.m_vector = { 1.f, 2.f, 3.f, 4.f };
	//MsgTx.m_cvector = { {1.f, 1.f}, {1.f, -1.f} };

	// Save it to disk:
	flatbuffers::FlatBufferBuilder Builder;
	Builder.FinishSizePrefixed(TestMessage::Pack(Builder, &MsgTx));

	std::vector<uint8_t> BufferTx(Builder.GetSize());
	std::memcpy(BufferTx.data(), Builder.GetBufferPointer(), Builder.GetSize());

	std::string Filename = "FlatMessage.fb";
	std::ofstream FileOut(Filename, std::ios::binary);
	if (!FileOut)
		std::cout << "Could not open file to save" << std::endl;
	FileOut.write(reinterpret_cast<const char*>(Builder.GetBufferPointer()), Builder.GetSize());
	// Close it to make sure the contents are actually written to disk:
	FileOut.close();

	auto MsgRx = ReadTestMessage(Filename);
	return 0;
}
