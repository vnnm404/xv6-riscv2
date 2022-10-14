#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"

#define SEC17         100000000000000000L
#define SEC12         1000000000000L
#define SEC9          1000000000L

void f0() {
  for(volatile uint64 i = 0; i < SEC17; i++)
    ;
}

void f1() {
  for(volatile uint64 i = 0; i < SEC17; i++)
    ;
}

void f2() {
  for(volatile uint64 i = 0; i < SEC9; i++)
    ;
  
  sleep(100);

  for(volatile uint64 i = 0; i < SEC9; i++)
    ;
}

void f3() {
  while (1) {
    for(volatile uint64 i = 0; i < SEC9; i++)
      ;
    
    sleep(5);

    for(volatile uint64 i = 0; i < SEC9; i++)
      ;
  }
}

void f4() {
  sleep(100);
}

int main(int agrc, char *argv[]) {
  for(int i = 0; i < 5; i++) {
    int pid = fork();
    
    if (pid == 0) {
      // for(volatile uint64 i = 0; i < SEC10; i++)
      //   ;

      if (i == 0) f0();
      if (i == 1) f1();
      if (i == 2) f2();
      if (i == 3) f3();
      if (i == 4) f4();

      break;
    }
  }
  // exit(0);
  while(1);
}