#include <iostream>
#include <pthread.h>
#include <string.h>
#include <fcntl.h>
#include <dlfcn.h>
#include <unistd.h>

#define NUMBER_FILES 6

typedef bool (*readFunction)(const char*, const char*);
typedef bool (*writeFunction)(const char*, const char*, unsigned int, unsigned int);

pthread_t readPthread;
pthread_t writePthread;

void* hModuleDLL;
pthread_mutex_t writeMutex;
pthread_mutex_t readMutex;
pthread_mutex_t deleteMutex;

char message[80] = { '\0' };

void* writeThread(void* information)
{
	std::string filePath = "home/lab5/store/Result_File.txt";
	int size = 0;
	int offset = 0;

	writeFunction writeTestFile = (writeFunction)dlsym(hModuleDLL, "WriteTestFile");

	while (!pthread_mutex_trylock(&deleteMutex))
	{
		pthread_mutex_lock(&writeMutex);

		offset = strlen((char*)information);
		writeTestFile(filePath.c_str(), (const char*)information, offset, size);
		size += offset;
		offset = 0;

		pthread_mutex_unlock(&writeMutex);
		usleep(70000);
	}
	std::cout << "Ended writeThread" << std::endl;
	pthread_mutex_unlock(&deleteMutex);
	return NULL;
}

void* readThread(void* information)
{
	std::string filePath = "/home/lab5/store/0_File.txt";
	bool flagFirst = true;

	readFunction readTestFile = (readFunction)dlsym(hModuleDLL, "ReadTestFile");

	pthread_mutex_lock(&writeMutex);
	pthread_mutex_lock(&readMutex);
	pthread_mutex_lock(&deleteMutex);

	pthread_create(&writePthread, NULL, writeThread, &message);

	for (int index = 1; index <= NUMBER_FILES; index++)
	{
		if (flagFirst)
		{
			filePath[17]--;
			index--;
			flagFirst = false;
		}
		filePath[17]++;
		readTestFile(filePath.c_str(), message);

		pthread_mutex_unlock(&writeMutex);
		usleep(50000);
		pthread_mutex_lock(&writeMutex);

		if (index >= NUMBER_FILES)
			pthread_mutex_unlock(&deleteMutex);
		for (int i = 0; message[i]; i++)
			message[i] = '\0';
		usleep(100000);
	}

	pthread_mutex_lock(&deleteMutex);
	pthread_mutex_unlock(&readMutex);
	std::cout << "Ended readThread" << std::endl;
	return NULL;
}

int main()
{
	hModuleDLL = dlopen("/home/lab5/dllmain.so", RTLD_LAZY);

	pthread_mutex_init(&writeMutex, NULL);
	pthread_mutex_init(&readMutex, NULL);
	pthread_mutex_init(&deleteMutex, NULL);

	pthread_create(&readPthread, NULL, readThread, &message);
	usleep(100000);
	pthread_mutex_lock(&readMutex);

	pthread_mutex_destroy(&writeMutex);
	pthread_mutex_destroy(&readMutex);
	pthread_mutex_destroy(&deleteMutex);

	dlclose(hModuleDLL);
	return 0;
}