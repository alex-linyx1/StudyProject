#define _CRT_SECURE_NO_WARNINGS

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//#include <io.h>
int main()
{
	FILE* A = fopen("C:/c/harry potter.txt", "r");
	char str[256];
//	char name[256];
	int l = 0;
	scanf("%d", &l);
	char* pattern = (char*)malloc(l * sizeof(char));
	scanf("%s", pattern);
	//printf("%s", pattern);
	//printf("%s", pattern);
	//scanf("%s", pattern);
	int counter = 0;
	//char* p;
	//char text[260];
	//int k = 0;
	//fgets(str, 256, A);
	//printf("%s", str);
	//fseek(A, 0, SEEK_SET);
	int k;
	int x, j;
	while (/*fscanf(A, "%s", text) != EOF*/ !feof(A))
	{
		fgets(str, 256 , A);
		for (int i = 0; i < strlen(str) && str[i] != '\n'; i++)
		{
			if (str[i] == pattern[0] && (!((str[i-1] >= 'A' && str[i-1] <= 'Z') || (str[i-1] >= 'a' && str[i - 1] <= 'z' )|| (str[i - 1] >= '0' && str[i - 1] <= '9'))|| i == 0))
			{
				//int j;
				k = 0;
				for (j = i; str[j] == pattern[k] && j < strlen(str) && k < strlen(pattern) ; j++)
				{

					k++;

				}
				if (strlen(pattern) == k && (!((str[j] >= 'A' && str[j] <= 'Z') || (str[j] >= 'a' && str[j] <= 'z') ||( str[j] >= '0' && str[j] <= '9')) || i == 0))
					counter++;

			}
		}
		//printf("%s", str);
		/*if (/*strncmp(text, pattern, strlen(pattern))strstr(str, pattern) != 0)
		{
			counter++;
		}*/
		//if (feof(A)) k = 1;
	}
	//while (/*fscanf(A, "%s", text) != EOF*/  !feof(A));
	printf("%d", counter);
	fclose(A);

}