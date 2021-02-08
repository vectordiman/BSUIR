#include <iostream>
#include <fcntl.h>
#include <unistd.h>
#include <aio.h>

extern "C" bool ReadTestFile(const char* filePath, const char* message)
{	
	std::cout << "DLL - ReadTestFile - Start" << std::endl;

	aiocb aioStructure;
	aioStructure.aio_offset = 0;
	aioStructure.aio_fildes = open(filePath, O_RDONLY);;
	aioStructure.aio_buf = (void*)message;
	aioStructure.aio_nbytes = 80;
	aioStructure.aio_sigevent.sigev_notify = SIGEV_NONE;
	aio_read(&aioStructure);
	while(aio_error(&aioStructure)) { usleep(1000); }
	close(aioStructure.aio_fildes);

	std::cout << "DLL - ReadTestFile - Finish" << std::endl;
	return true;
}

extern "C" bool WriteTestFile(const char* filePath, const char* message, unsigned int size, unsigned int offset)
{
	std::cout << "DLL - WriteTestFile - Start" << std::endl;

	aiocb aioStructure;
	aioStructure.aio_offset = offset;
	aioStructure.aio_fildes = open(filePath, O_WRONLY);;
	aioStructure.aio_buf = (void*)message;
	aioStructure.aio_nbytes = size;
	aioStructure.aio_sigevent.sigev_notify = SIGEV_NONE;
	aio_write(&aioStructure);
	while(aio_error(&aioStructure)) { usleep(1000); }
	close(aioStructure.aio_fildes);

	std::cout << "DLL - WriteTestFile - Finish" << std::endl;
	std::cout << "=============================" << std::endl;
	return true;
}