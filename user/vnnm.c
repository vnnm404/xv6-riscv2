#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"

int main(int agrc, char *argv[]) {
  for(int i = 0; i < 10; i++)
    fork();
  sleep(100);
  printf("Done\n");
  while (1);
}