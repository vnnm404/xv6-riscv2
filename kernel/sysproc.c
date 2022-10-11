#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  exit(n);
  return 0; // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return wait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
  addr = myproc()->sz;
  if (growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  acquire(&tickslock);
  ticks0 = ticks;
  while (ticks - ticks0 < n)
  {
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

// Specification 1

uint64
sys_trace(void)
{
  int mask;
  struct proc *p;

  argint(0, &mask);
  p = myproc();

  p->smask = mask;
  return 0;
}

uint64 sys_sigalarm(void)
{
  struct proc *p;
  p = myproc();

  int interval;
  uint64 handler;

  argint(0, &interval);
  argaddr(1, &handler);

  p->interval = interval;
  p->handler = handler;

  return 0;
}

uint64 sys_sigreturn(void)
{
  struct proc *p;
  p = myproc();

  memmove(p->trapframe, p->alarmContext, PGSIZE);
  int a0 = p->alarmContext->a0;
  kfree(p->alarmContext);
  p->alarmOn = 0;
  p->nticks = 0;
  p->alarmContext = 0;
  // this is done to restore the original value of the a0 register
  // as sys_sigreturn is also a systemcall its return value will be stored in the a0 register
  return a0;
}

uint64 sys_settickets(void) {
  struct proc *p;
  int tk;

  argint(0, &tk);
  p = myproc();

  p->tickets += tk;
  return 0;
}

uint64 sys_set_priority(void){
  struct proc *p;
  int sp,pid;

  argint(0,&sp);
  argint(1,&pid);

  for(p=proc;p<&proc[NPROC];p++){
    acquire(&p->lock);
    if(p->pid==pid){
      int old_sp = p->staticP;
      p->staticP = sp;
      p->niceness = 5;
      p->rtime =0;
      p->stime =0;
      p->wtime =0;
      release(&p->lock);
      if(old_sp > sp){
        yield();
      }
      return old_sp;
    }
    release(&p->lock);
  }
  return -1;
}

uint64
sys_waitx(void)
{
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
  argaddr(1, &addr1); // user virtual memory
  argaddr(2, &addr2);
  int ret = waitx(addr, &wtime, &rtime);
  struct proc* p = myproc();
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    return -1;
  if (copyout(p->pagetable, addr2,(char*)&rtime, sizeof(int)) < 0)
    return -1;
  return ret;
}