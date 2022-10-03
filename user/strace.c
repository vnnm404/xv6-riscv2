#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"

#define MAXARGS 10

int
main(int argc, char *argv[]) {
  if (argc <= 2) {
    fprintf(2, "strace: insufficient arguments\n");
    exit(1);
  }

  char *mask_str = argv[1];
  for (int i = 0; i < strlen(mask_str); i++) {
    if (!('0' <= mask_str[i] && mask_str[i] <= '9')) {
      fprintf(2, "strace: invalid syscall mask\n");
      exit(1);
    }
  }

  int mask = atoi(mask_str);

  int pid = fork();
  if (pid == -1) {
    fprintf(2, "strace: failed to run command\n");
    exit(1);
  }

  if (pid == 0) {
    trace(mask);

    exec(argv[2], argv + 2);
    fprintf(2, "strace: exec %s failed\n", argv[2]);
    exit(1);
  }
  wait(0);
  exit(0);
}
