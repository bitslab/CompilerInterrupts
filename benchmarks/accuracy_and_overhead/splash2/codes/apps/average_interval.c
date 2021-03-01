#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char** argv)
{
  FILE * fp;
  char * line = NULL;
  size_t len = 0;
  ssize_t read;
  char clock[] = "Logical Clock:";
  size_t clock_len = strlen(clock);
  int prev_lc = 0, num_lines=0;
  double sum = 0;
  if(argc != 2) {
    printf("Argc %d is not 2\n", argc);
    exit(1);
  }

  fp = fopen(argv[1], "r");
  if (fp == NULL)
    exit(EXIT_FAILURE);

  while ((read = getline(&line, &len, fp)) != -1) {
    char *ptr = strstr(line, clock);
    if(ptr != NULL) {
      num_lines++;
      int pos = ptr - line;
      pos += clock_len;
      char* lc_str = line + pos;
      int lc = atoi(lc_str);
      int diff = lc - prev_lc;
      sum+=diff;
      prev_lc = lc;
      //printf("Line: %s", line);
      //printf("LC: %s", lc_str);
      //printf("Diff: %d\n", diff);
    } 
  }

  double avg = (sum / num_lines);
  printf("Avg interval is %f taken over %d clock updates\n", avg, num_lines);
  printf("Sum was: %f", sum);

  fclose(fp);
  if (line)
      free(line);
  return 0;
}
