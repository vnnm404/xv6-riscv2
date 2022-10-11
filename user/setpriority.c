#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"

int main(int argc, char *argv[]){
    if(argc <= 2){
        fprintf(2, "setpriority: insufficient arguments\n");
        exit(1); 
    }

    int sp = atoi(argv[1]);
    if(sp < 0 || sp > 100){
        fprintf(2, "setpriority: priority not valid\n");
        exit(1);
    }
    int pid = atoi(argv[2]);
    
    int pid_f = fork();
    if(pid_f < 0){
        fprintf(2, "setpriority: unable to run process\n");
        exit(1);
    }
    else if (pid_f == 0){
        if(set_priority(sp,pid)==-1){
            fprintf(2, "setpriority: pid not valid\n");
            exit(1);
        } 
        printf("Sucess!\n");
    }

    wait(0);
    exit(0);

}