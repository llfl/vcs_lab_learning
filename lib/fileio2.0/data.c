/* data.c - program to write a binary file.
   Currently writes the binary values 0-199 to data.bin
   Compile with:
       make data
*/

#include <stdio.h>

main()
{
    int b, c, d, h, ret, mem[1000000];
    float rt;
    char fmt[100], is[100], js[100];
    FILE *stream;

    stream = fopen("data.bin", "w");
    for (d=0; d < 200; d++) 
	is[d] = d;
    fwrite(is, sizeof(char), 200, stream);

    fclose(stream);
}
