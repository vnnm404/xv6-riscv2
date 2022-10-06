#include "types.h"

#define RAND_MAX    32767

// src (https://stackoverflow.com/questions/4768180/rand-implementation)
int rand(uint64 seed) // RAND_MAX assumed to be 32767
{
  seed = seed * 1103515245 + 12345;
  return (unsigned int)(seed/65536) % 32768;
}