#define _CRT_SECURE_NO_WARNINGS
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <malloc.h>
#define S 100

int main()
{
	FILE* in;
	in = fopen("C:/c/harry potter.txt", "r");
	if (in == NULL)
	{
		puts("Can't open file!");
		return 0;
	}
	int count = 0;
	char p[100];
	printf("Enter the pattern:\n");
	scanf("%s", &p);
	int n;
	while (!feof(in))
	{
		char str[S];
		fgets(str, S, in);
		if (str[strlen(str) - 1] == '\n')
			n = strlen(str) - 1;
		else
			n = strlen(str);
		for (int i = 0; i < n; i++)
		{
			if (str[i] == p[0] && (i == 0 || !((str[i - 1] >= 'a' && str[i - 1] <= 'z') || (str[i - 1] >= 'A' && str[i - 1] <= 'Z') || (str[i - 1] >= '0' && str[i - 1] <= '9'))))
			{
				int len = 1;
				int j = 1;
				int k;
				for (k = i + 1; str[k] == p[j] && k < n; k++)
				{
					len++;
					j++;
				}
				if (len == strlen(p) && !((str[k] >= 'a' && str[k] <= 'z') || (str[k] >= 'A' && str[k] <= 'Z') || (str[k] >= '0' && str[k] <= '9')))
					count++;
			}
		}

	}
	printf("%s _ %d", p, count);
	fclose(in);
	return 0;
}