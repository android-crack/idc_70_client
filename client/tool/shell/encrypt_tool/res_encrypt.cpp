#include <iostream>
#include <string>
#include <assert.h>
#include <unistd.h>

using namespace std;

#define MAGIC_CODE			0xaa987bbc
#define VERSION1			1
#define VERSION2			2
#define DYNAMIC_KEY_LEN		32

static int gMaxEncryptLength = -1;

unsigned int g_EncryptKey[4] = 
{
	0x110011aa,
	0xaa2233bb,
	0xcc4455dd,
	0xee667788,
};

enum OperationType{
	kOperationTypeUnknow = 0,
	kOperationTypeEncrypt = 1,
	kOperationTypeDecrypt = 2,
};

unsigned int g_DynamicEncryptKey[DYNAMIC_KEY_LEN] = {0};

struct EncryptFileHeader
{
	int version;
	int magicCode1;
	int magicCode2;
};

char *getFileData(const char *fileName, size_t *fileSize)
{
	FILE *fp = fopen(fileName, "rb");
	assert(fp != NULL && "fail to open file");

	fseek(fp, 0, SEEK_END);
	*fileSize = ftell(fp);
	fseek(fp, 0, SEEK_SET);

	char *rawData = new char[*fileSize];
	fread(rawData, sizeof(char), *fileSize, fp);

	fclose(fp);

	return rawData;
}

void EncryptSingleFile(const char *fileName)
{
	if (g_EncryptKey[0] == 0 && g_EncryptKey[1] == 0 && g_EncryptKey[2] == 0 && g_EncryptKey[3] == 0)
	{
		assert(0 && "please set encrpyt code first");
	}

	size_t fileSize;
	char *rawData = getFileData(fileName, &fileSize);

	if (fileSize >= sizeof(EncryptFileHeader))
	{
		EncryptFileHeader *rawHeader = (EncryptFileHeader *)rawData;

		if (rawHeader->magicCode1 == MAGIC_CODE && rawHeader->magicCode2 == rawHeader->magicCode1 + 50)
		{
			printf("%s\n", "file already be encrypted");
			delete []rawData;
			return ;
		}
	}

	int *data = (int *)rawData;
	int size = fileSize / 4;

	if (gMaxEncryptLength > 0 && size > gMaxEncryptLength )
	{
		size = gMaxEncryptLength;
	}

	for (int i = 0; i < size; ++i)
	{
		data[i] ^= g_EncryptKey[i % 4];
	}

	EncryptFileHeader header;
	header.version = VERSION1;
	header.magicCode1 = MAGIC_CODE;
	header.magicCode2 = MAGIC_CODE + 50;

	FILE *fp = fopen(fileName, "wb");
	assert(fp != NULL && "fail to open file");
	fwrite(&header, sizeof(header), 1, fp);
	fwrite(rawData, fileSize, 1, fp);
	fclose(fp);

	delete []rawData;
}

char *DecryptVersion1File(const char *rawData, int fileSize, int *outSize)
{
	int *data = (int *)(rawData + sizeof(EncryptFileHeader));
	*outSize = fileSize - sizeof(EncryptFileHeader);
	int size = *outSize / 4;

	if (gMaxEncryptLength > 0 && size > gMaxEncryptLength)
	{
		size = gMaxEncryptLength;
	}

	for (int i = 0; i < size; ++i)
	{
		data[i] ^= g_EncryptKey[i % 4];
	}

	return (char *)data;
}

void DecryptSingleFile(const char *fileName)
{
	size_t fileSize;
	char *rawData = getFileData(fileName, &fileSize);
	char *data;
	int realSize = 0;

	if (fileSize <= sizeof(EncryptFileHeader))
	{
		return ;
	}

	EncryptFileHeader *rawHeader = (EncryptFileHeader *)rawData;

	
	if (rawHeader->magicCode1 == MAGIC_CODE && rawHeader->magicCode2 == MAGIC_CODE + 50)
	{
		if (rawHeader->version == VERSION1)
		{
			data = DecryptVersion1File(rawData, fileSize, &realSize);
		}
		else
		{
			assert(0);
		}

		FILE *fp = fopen(fileName, "wb");
		fwrite(data, realSize, 1, fp);
		fclose(fp);
	}

	delete []rawData;
}

int main(int argc, char *argv[])
{
	OperationType operation = kOperationTypeUnknow;
	char *path = NULL;
	char oc;
	while((oc = getopt(argc, argv, "o:l:p:")) != -1) {
	  switch(oc) { 
		case 'o':  
			if(*optarg == 'e'){
				operation = kOperationTypeEncrypt;
			}else if(*optarg == 'd'){
				operation = kOperationTypeDecrypt;
			}else{
				printf("operation type error\n");
				return 1;
			}
			break; 
		case 'l':  
			gMaxEncryptLength = atoi(optarg);
//			printf("maxEncryptLength = %d\n", gMaxEncryptLength);
			break;
		case 'p': 
			path = optarg;
//			printf("path = %s \n", path); 
			break; 
		case '?':  
			printf("arguments error!\n"); 
			break; 
		} 
	}
	if (operation == kOperationTypeUnknow || gMaxEncryptLength == -1 || path == NULL)
	{
		std::cout << "usage: res_encrypt -o[e:d] -p path -l length fileName" << std::endl;
		return -1;
	}

	if (operation == kOperationTypeEncrypt)
	{
		EncryptSingleFile(path);
	}
	else if (operation == kOperationTypeDecrypt)
	{
		DecryptSingleFile(path);
	}

	return 0;
}
