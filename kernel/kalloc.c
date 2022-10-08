// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

#define fn(X) ((uint64)X - KERNBASE) / PGSIZE

void freerange(void *pa_start, void *pa_end);

extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  struct run *freelist;
} kmem;

struct {
  struct spinlock lock;
  int fr[fn(PHYSTOP) + 1];
  char lock_kalloc;
} memref;

void
kinit()
{
  initlock(&memref.lock, "memref");
  initlock(&kmem.lock, "kmem");
  freerange(end, (void*)PHYSTOP);
  memref.lock_kalloc = 1;
  memset((void*)memref.fr, 0, fn(PHYSTOP) + 1);
}

void memref_lock() {
  acquire(&memref.lock);
}

void memref_unlock() {
  release(&memref.lock);
}

int memref_get(void *pa) {
  return memref.fr[fn(pa)];
}

void memref_set(void *pa, int fq) {
  memref.fr[fn(pa)] = fq;
}

void memref_lock_kalloc() {
  memref.lock_kalloc = 1;
}

void memref_unlock_kalloc() {
  memref.lock_kalloc = 0;
}

void
freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char*)PGROUNDUP((uint64)pa_start);
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    kfree(p);
}

// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

  memref_lock();
  if (memref.fr[fn(pa)] > 1) {
    memref.fr[fn(pa)]--;
    memref_unlock();
    return;
  }

  memref.fr[fn(pa)] = 0;
  memref_unlock();

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

  r = (struct run*)pa;

  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
  struct run *r;

  acquire(&kmem.lock);
  r = kmem.freelist;
  if(r)
    kmem.freelist = r->next;
  release(&kmem.lock);

  if(r) {
    if (memref.lock_kalloc) {
      memref_lock();
      memref.fr[fn(r)] = 1;
      memref_unlock();
    } else {
      memref.fr[fn(r)] = 1;
    }

    memset((char*)r, 5, PGSIZE); // fill with junk
  }
  return (void*)r;
}
