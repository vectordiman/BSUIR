#define _CRT_SECURE_NO_WARNINGS

#include <iostream>
#include <windows.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <assert.h>
#include <map>

using namespace std;

template<class Type>
class SmartPointer;

class ManagerHeap
{

	template <class> friend class SmartPointer;

private:

	HANDLE hHeap;

	static map<LPVOID, size_t>& getMemoryHeap()
	{
		static map<LPVOID, size_t> tempMemoryHeap;
		return tempMemoryHeap;
	}

public:

	ManagerHeap()
	{
		this->hHeap = HeapCreate(0, 0x01000, 0);
	};

	LPVOID mallocHeap(size_t tempSize)
	{
		LPVOID tempPointer = HeapAlloc(this->hHeap, NULL, tempSize);
		getMemoryHeap().insert(make_pair(tempPointer, 0));
		cout << "MemoryHeap allocated in " << tempPointer << endl;
		return tempPointer;
	}

	void freeHeap(LPVOID tempPointer) 
	{
		if (getMemoryHeap().count(tempPointer))
			getMemoryHeap().erase(tempPointer);
		cout << "MemoryHeap deleted in " << tempPointer << endl;
		HeapFree(this->hHeap, NULL, tempPointer);
	}

	void garbageCollectorHeap() 
	{
		for (auto iterator = getMemoryHeap().begin(); iterator != getMemoryHeap().end(); iterator++) 
		{
			if (iterator->second == 0)
			{
				freeHeap(iterator++->first);
			}
			if (iterator == getMemoryHeap().end())
				break;
		}
		cout << "garbageCollectorHeap ended " << endl;
	}

	~ManagerHeap()
	{
		HeapDestroy(this->hHeap);
	};

};

template <class Type>
class SmartPointer 
{
private:

	LPVOID pointer;

public:
	SmartPointer() {};

	SmartPointer(const SmartPointer& tempSmartPointer) 
	{
		*this = tempSmartPointer.pointer;
	}

	SmartPointer(LPVOID tempPointer) 
	{
		this->pointer = tempPointer;
	}

	~SmartPointer() 
	{
		if (ManagerHeap::getMemoryHeap().count(this->pointer))
			ManagerHeap::getMemoryHeap().find(this->pointer)->second--;
	}

	SmartPointer& operator=(LPVOID tempPointer) 
	{
		if (this->pointer == tempPointer)
			return *this;
		if (ManagerHeap::getMemoryHeap().count(this->pointer))
			ManagerHeap::getMemoryHeap().find(this->pointer)->second--;
		if (ManagerHeap::getMemoryHeap().count(tempPointer))
			ManagerHeap::getMemoryHeap().find(tempPointer)->second++;
		this->pointer = tempPointer;
		return *this;
	}

	SmartPointer& operator=(SmartPointer tempSmartPointer) 
	{
		*this = tempSmartPointer.pointer;
		return *this;
	}

	Type& operator*() 
	{
		return *(Type*)(this->pointer);
	}

	operator LPVOID () 
	{
		return this->pointer;
	}
};

ManagerHeap managerHeap;

void testHeap() 
{
	SmartPointer<int> numberOne = managerHeap.mallocHeap(sizeof(int));
	SmartPointer<int> numberTwo = numberOne;
	SmartPointer<int> numberFour = managerHeap.mallocHeap(sizeof(int));
	managerHeap.garbageCollectorHeap();
	return;
}

int main() 
{
	testHeap();
	return 0;
}