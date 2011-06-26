/*
 * Copyright (c) 2011, Stephan Creutz
 * Distributed under the MIT License
 */

#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

// flag which indicates which memory should be aligned on page boundary
#define MEM_ALIGN

int main(int argc, char **argv)
{
  unsigned i, k;
  unsigned B = 10000; // default number of values to read
  unsigned K = 1; // default number of consecutive values to read
  unsigned long S = 100000000; // default total memory size

  // parse command line parameters
  int o;
  while ((o = getopt(argc, argv, "B:K:S:")) != -1) {
    switch (o) {
    case 'B':
      B = strtoul(optarg, NULL, 10);
      break;
    case 'K':
      K = strtoul(optarg, NULL, 10);
      break;
    case 'S':
      S = strtoul(optarg, NULL, 10);
      break;
    default:
      fprintf(stderr, "unknown command line option\n");
      return 1;
    }
  }

  if (K > S) {
    fprintf(stderr, "K must be less or equal S\n");
    return 1;
  }

  if (B > S) {
    fprintf(stderr, "B must be less or equal S\n");
    return 1;
  }

  if (K > B) {
    fprintf(stderr, "B must be less or equal K\n");
    return 1;
  }

  // precalculate random indizes to access the array
  unsigned *random_indizes = malloc(B / K * sizeof(unsigned));
  if (!random_indizes) {
    fprintf(stderr, "not enough mem.\n");
    return 1;
  }

  for (i = 0; i < B / K; i++)
    random_indizes[i] = rand() % (B - K - 1);

  // reserve space for the array to read
#if !defined(MEM_ALIGN)
  unsigned *m = calloc(S, sizeof(unsigned));
#else
  unsigned *m = NULL;
  // align memory on page boundary
  int ret = posix_memalign((void **) &m, (size_t) sysconf(_SC_PAGESIZE),
                           S * sizeof(unsigned));
  if (ret != 0) {
    fprintf(stderr, "not enough mem. or mem. could not be aligned\n");
    return 1;
  }
#endif
  if (!m) {
    fprintf(stderr, "not enough mem.\n");
    return 1;
  }
#if defined(MEM_ALIGN)
  memset(m, 0, S * sizeof(unsigned));
#endif

  struct timespec start, stop;
  // take start timestamp
  clock_gettime(CLOCK_REALTIME, &start);

  // do the memory access
  unsigned r = 0;
  for (i = 0; i < B / K; i++)
    for (k = 0; k < K; k++)
      r += m[random_indizes[i] + k];

  // take stop timestamp
  clock_gettime(CLOCK_REALTIME, &stop);

  free(m);
  free(random_indizes);

  // just to add a depedency such the compiler doesn't optimize r away
  printf("%u\n", r);

  // calculate the difference between the start and stop timestamp
  unsigned long long t = (stop.tv_sec * 1000000000 + stop.tv_nsec) -
    (start.tv_sec * 1000000000 + start.tv_nsec);
  printf("time: %llu\n", t);

  return 0;
}
