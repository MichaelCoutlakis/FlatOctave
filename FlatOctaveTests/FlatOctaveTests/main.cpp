
#include <cstdlib>
#include <fstream>
#include <string>
#include <vector>
#include <iostream>

#include "../../Tests_generated.h"


template<typename FlatBufferType>
void WriteToDisk(const FlatBufferType& FlatBuffer, std::string filename)
{
	flatbuffers::FlatBufferBuilder Builder;
	Builder.FinishSizePrefixed(FlatBufferType::TableType::Pack(Builder, &FlatBuffer));

	std::vector<uint8_t> Bytes(Builder.GetSize());
	std::memcpy(Bytes.data(), Builder.GetBufferPointer(), Builder.GetSize());

	std::ofstream FileOut(filename, std::ios::binary);
	if(!FileOut)
		std::cout << "Could not open file to save" << std::endl;
	FileOut.write(reinterpret_cast<const char*>(Builder.GetBufferPointer()), Builder.GetSize());
	// Close it to make sure the contents are actually written to disk:
	FileOut.close();
}

template<typename FlatBufferType>
std::vector<uint8_t> ToBytes(const FlatBufferType& FlatBuffer)
{
	flatbuffers::FlatBufferBuilder Builder;
	Builder.FinishSizePrefixed(FlatBufferType::TableType::Pack(Builder, &FlatBuffer));

	std::vector<uint8_t> Buffer(Builder.GetSize());
	std::memcpy(Buffer.data(), Builder.GetBufferPointer(), Builder.GetSize());
	return Buffer;
}

template<typename FlatBufferType>
FlatBufferType ReadFromDisk(std::string filename)
{
	std::ifstream FileIn(filename, std::ios::binary | std::ios::in);

	if(!FileIn)
		std::cout << "Could not open file " << filename << std::endl;

	// Seek to the end of the file
	FileIn.seekg(0, std::ios::end);
	// Determine file size from input position indicator tellg
	std::streampos pos = FileIn.tellg();

	if(pos < 0)
		std::cout << "Could not determine file size!" << std::endl;
	size_t length = static_cast<size_t>(pos);

	// Set position back to beginning of file for subsequent read:
	FileIn.seekg(0, std::ios::beg);
	std::vector<uint8_t> Buffer(length);
	FileIn.read(reinterpret_cast<char*>(Buffer.data()), length);
	FileIn.close();

	// Unpack the received message:
	FlatBufferType MsgRx;
	flatbuffers::GetSizePrefixedRoot<FlatBufferType::TableType>(Buffer.data())->UnPackTo(&MsgRx);
	return MsgRx;
}


template<typename T>
void ExpectEqual(const T& t1, const T& t2)
{
	// There isn't a default comparison operator, let's convert each to bytes and compare the serialized options:
	auto Bytes1 = ToBytes(t1);
	auto Bytes2 = ToBytes(t2);
	bool b = Bytes1 == Bytes2;

	if(!b)
		std::cout << "Equality comparison failed, " << typeid(T).name() << std::endl;
	else
		std::cout << typeid(T).name() << " comparison passed" << std::endl;
}

int main()
{
	// Make sure the generated code is up to date:
	std::system(R"(C:\Git\Michael\Octave\FlatOctave\flatbuffers-vs\x64\Debug\flatbuffers.exe --cpp --gen-object-api -o C:\Git\Michael\Octave\FlatOctave -I C:\Git\Michael\Octave\FlatOctave C:\Git\Michael\Octave\FlatOctave\Tests.fbs)");

	// Round trip test:
	using namespace TestMessages;

	std::string dir = R"(C:\Git\Michael\Octave\FlatOctave\)";

	//TestVectorT test_vector;

	//TestIntT TestIntTx;
	//TestIntTx.m_Int = 73;
	//WriteToDisk(TestIntTx, dir + "TestIntT_CppOut.fb");
	TestMessageT Tx;
	Tx.m_Int32 = 42;
	Tx.m_float = 3.14159f;
	Tx.m_String = "Tx String";
	Tx.m_Vector = { 1.f, 2.f, 3.f };
	Tx.m_VectorStrings = { "These", "are", "some", "strings" };
	auto pDS = std::make_unique<DataStructureT>();
	pDS->m_float = 1.2f;
	pDS->m_Int32 = 38;
	pDS->m_String = "hi";
	pDS->m_VectorInt = { 7, 8, 9 };

	auto pN2 = std::make_unique<Nested2T>();
	pN2->m_String = "n2";

	pDS->m_Nested = std::move(pN2);

	Tx.m_NestedTable = std::move(pDS);

	auto pE1 = std::make_unique<DataStructureT>();
	pE1->m_Int32 = 7;
	//pE1->m_float = 2.8;
	auto pE2 = std::make_unique<DataStructureT>();
	pE2->m_Int32 = 8;
	//pE2->m_float = 2.8;
	Tx.m_vTables.push_back(std::move(pE1));
	Tx.m_vTables.push_back(std::move(pE2));

	WriteToDisk(Tx, dir + "TestMessageT_CppOut.fb");

	// Run the octave script which will unpack, copy the structures and repack:
	system(R"(octave C:\Git\Michael\Octave\FlatOctave\RoundTripTest.m)");

	// Load the messages back and test for equality:
	//TestIntT TestIntRx = ReadFromDisk<TestIntT>(dir + "TestIntT_OctaveOut.fb");
	//ExpectEqual(TestIntTx, TestIntRx);
	TestMessageT Rx = ReadFromDisk<TestMessageT>(dir + "TestMessageT_OctaveOut.fb");
	//TestMessageT Rx = ReadFromDisk<TestMessageT>(dir + "TestMessageT_CppOut.fb");
	ExpectEqual(Tx, Rx);
	return 0;
}
