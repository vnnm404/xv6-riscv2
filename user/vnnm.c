#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int 
main(void) {
  trace(2147483647);
  printf("Hello, world\n");
  exit(0);
}