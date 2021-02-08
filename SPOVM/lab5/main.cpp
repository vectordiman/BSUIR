// main.cpp

#include <iostream>
#include <Windows.h>
#include <string>

#define NUMBER_FILES 6

typedef BOOL (*readFunction)(const char*, const char*);
typedef BOOL (*writeFunction)(const char*, const char*, unsigned int, unsigned int);

HMODULE hModuleDLL;
CRITICAL_SECTION writeSection;
CRITICAL_SECTION readSection;
CRITICAL_SECTION deleteSection;

char message[80] = { '\0' };

DWORD WINAPI writeThread(LPVOID information)
{
	std::string filePath = "../store/Result_File.txt";
	int size = 0;
	int offset = 0;

	writeFunction writeTestFile = (writeFunction)GetProcAddress(hModuleDLL, "WriteTestFile");

	while (!TryEnterCriticalSection(&deleteSection))
	{
		EnterCriticalSection(&writeSection);

		offset = strlen((char*)information);
		writeTestFile(filePath.c_str(), (const char*)information, offset, size);
		size += offset;
		offset = 0;

		LeaveCriticalSection(&writeSection);
		Sleep(70);
	}
	std::cout << "Ended writeThread" << std::endl;
	LeaveCriticalSection(&deleteSection);
	return 0;
}

DWORD WINAPI readThread(LPVOID information)
{
	std::string filePath = "../store/0_File.txt";
	bool flagFirst = true;

	readFunction readTestFile = (readFunction)GetProcAddress(hModuleDLL, "ReadTestFile");

	EnterCriticalSection(&writeSection);
	EnterCriticalSection(&readSection);
	EnterCriticalSection(&deleteSection);

	CreateThread(NULL, NULL, writeThread, message, NULL, NULL);

	for (int index = 1; index <= NUMBER_FILES; index++)
	{
		if (flagFirst)
		{
			filePath[9]--;
			index--;
			flagFirst = false;
		}
		filePath[9]++;
		readTestFile(filePath.c_str(), message);

		LeaveCriticalSection(&writeSection);
		Sleep(50);
		EnterCriticalSection(&writeSection);

		if (index >= NUMBER_FILES)
			LeaveCriticalSection(&deleteSection);
		for (int i = 0; message[i]; i++)
			message[i] = '\0';
		Sleep(100);
	}

	EnterCriticalSection(&deleteSection);
	LeaveCriticalSection(&readSection);
	std::cout << "Ended readThread" << std::endl;
	return 0;
}

int main()
{
	hModuleDLL = LoadLibraryA("../../lab5_DLL/Release/lab5_DLL.dll");

	InitializeCriticalSection(&writeSection);
	InitializeCriticalSection(&readSection);
	InitializeCriticalSection(&deleteSection);

	CreateThread(NULL, NULL, readThread, message, NULL, NULL);
	Sleep(100);
	EnterCriticalSection(&readSection);

	DeleteCriticalSection(&writeSection);
	DeleteCriticalSection(&readSection);
	DeleteCriticalSection(&deleteSection);

	FreeLibrary(hModuleDLL);
	return 0;
}