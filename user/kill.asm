
user/_kill:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
   c:	4785                	li	a5,1
   e:	02a7dd63          	bge	a5,a0,48 <main+0x48>
  12:	00858493          	addi	s1,a1,8
  16:	ffe5091b          	addiw	s2,a0,-2
  1a:	02091793          	slli	a5,s2,0x20
  1e:	01d7d913          	srli	s2,a5,0x1d
  22:	05c1                	addi	a1,a1,16
  24:	992e                	add	s2,s2,a1
    fprintf(2, "usage: kill pid...\n");
    exit(1);
  }
  for(i=1; i<argc; i++)
    kill(atoi(argv[i]));
  26:	6088                	ld	a0,0(s1)
  28:	00000097          	auipc	ra,0x0
  2c:	1c8080e7          	jalr	456(ra) # 1f0 <atoi>
  30:	00000097          	auipc	ra,0x0
  34:	2ea080e7          	jalr	746(ra) # 31a <kill>
  for(i=1; i<argc; i++)
  38:	04a1                	addi	s1,s1,8
  3a:	ff2496e3          	bne	s1,s2,26 <main+0x26>
  exit(0);
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	2aa080e7          	jalr	682(ra) # 2ea <exit>
    fprintf(2, "usage: kill pid...\n");
  48:	00000597          	auipc	a1,0x0
  4c:	7d858593          	addi	a1,a1,2008 # 820 <malloc+0xe6>
  50:	4509                	li	a0,2
  52:	00000097          	auipc	ra,0x0
  56:	602080e7          	jalr	1538(ra) # 654 <fprintf>
    exit(1);
  5a:	4505                	li	a0,1
  5c:	00000097          	auipc	ra,0x0
  60:	28e080e7          	jalr	654(ra) # 2ea <exit>

0000000000000064 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  64:	1141                	addi	sp,sp,-16
  66:	e406                	sd	ra,8(sp)
  68:	e022                	sd	s0,0(sp)
  6a:	0800                	addi	s0,sp,16
  extern int main();
  main();
  6c:	00000097          	auipc	ra,0x0
  70:	f94080e7          	jalr	-108(ra) # 0 <main>
  exit(0);
  74:	4501                	li	a0,0
  76:	00000097          	auipc	ra,0x0
  7a:	274080e7          	jalr	628(ra) # 2ea <exit>

000000000000007e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  7e:	1141                	addi	sp,sp,-16
  80:	e422                	sd	s0,8(sp)
  82:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  84:	87aa                	mv	a5,a0
  86:	0585                	addi	a1,a1,1
  88:	0785                	addi	a5,a5,1
  8a:	fff5c703          	lbu	a4,-1(a1)
  8e:	fee78fa3          	sb	a4,-1(a5)
  92:	fb75                	bnez	a4,86 <strcpy+0x8>
    ;
  return os;
}
  94:	6422                	ld	s0,8(sp)
  96:	0141                	addi	sp,sp,16
  98:	8082                	ret

000000000000009a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  9a:	1141                	addi	sp,sp,-16
  9c:	e422                	sd	s0,8(sp)
  9e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  a0:	00054783          	lbu	a5,0(a0)
  a4:	cb91                	beqz	a5,b8 <strcmp+0x1e>
  a6:	0005c703          	lbu	a4,0(a1)
  aa:	00f71763          	bne	a4,a5,b8 <strcmp+0x1e>
    p++, q++;
  ae:	0505                	addi	a0,a0,1
  b0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  b2:	00054783          	lbu	a5,0(a0)
  b6:	fbe5                	bnez	a5,a6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  b8:	0005c503          	lbu	a0,0(a1)
}
  bc:	40a7853b          	subw	a0,a5,a0
  c0:	6422                	ld	s0,8(sp)
  c2:	0141                	addi	sp,sp,16
  c4:	8082                	ret

00000000000000c6 <strlen>:

uint
strlen(const char *s)
{
  c6:	1141                	addi	sp,sp,-16
  c8:	e422                	sd	s0,8(sp)
  ca:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  cc:	00054783          	lbu	a5,0(a0)
  d0:	cf91                	beqz	a5,ec <strlen+0x26>
  d2:	0505                	addi	a0,a0,1
  d4:	87aa                	mv	a5,a0
  d6:	86be                	mv	a3,a5
  d8:	0785                	addi	a5,a5,1
  da:	fff7c703          	lbu	a4,-1(a5)
  de:	ff65                	bnez	a4,d6 <strlen+0x10>
  e0:	40a6853b          	subw	a0,a3,a0
  e4:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  e6:	6422                	ld	s0,8(sp)
  e8:	0141                	addi	sp,sp,16
  ea:	8082                	ret
  for(n = 0; s[n]; n++)
  ec:	4501                	li	a0,0
  ee:	bfe5                	j	e6 <strlen+0x20>

00000000000000f0 <memset>:

void*
memset(void *dst, int c, uint n)
{
  f0:	1141                	addi	sp,sp,-16
  f2:	e422                	sd	s0,8(sp)
  f4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  f6:	ca19                	beqz	a2,10c <memset+0x1c>
  f8:	87aa                	mv	a5,a0
  fa:	1602                	slli	a2,a2,0x20
  fc:	9201                	srli	a2,a2,0x20
  fe:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 102:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 106:	0785                	addi	a5,a5,1
 108:	fee79de3          	bne	a5,a4,102 <memset+0x12>
  }
  return dst;
}
 10c:	6422                	ld	s0,8(sp)
 10e:	0141                	addi	sp,sp,16
 110:	8082                	ret

0000000000000112 <strchr>:

char*
strchr(const char *s, char c)
{
 112:	1141                	addi	sp,sp,-16
 114:	e422                	sd	s0,8(sp)
 116:	0800                	addi	s0,sp,16
  for(; *s; s++)
 118:	00054783          	lbu	a5,0(a0)
 11c:	cb99                	beqz	a5,132 <strchr+0x20>
    if(*s == c)
 11e:	00f58763          	beq	a1,a5,12c <strchr+0x1a>
  for(; *s; s++)
 122:	0505                	addi	a0,a0,1
 124:	00054783          	lbu	a5,0(a0)
 128:	fbfd                	bnez	a5,11e <strchr+0xc>
      return (char*)s;
  return 0;
 12a:	4501                	li	a0,0
}
 12c:	6422                	ld	s0,8(sp)
 12e:	0141                	addi	sp,sp,16
 130:	8082                	ret
  return 0;
 132:	4501                	li	a0,0
 134:	bfe5                	j	12c <strchr+0x1a>

0000000000000136 <gets>:

char*
gets(char *buf, int max)
{
 136:	711d                	addi	sp,sp,-96
 138:	ec86                	sd	ra,88(sp)
 13a:	e8a2                	sd	s0,80(sp)
 13c:	e4a6                	sd	s1,72(sp)
 13e:	e0ca                	sd	s2,64(sp)
 140:	fc4e                	sd	s3,56(sp)
 142:	f852                	sd	s4,48(sp)
 144:	f456                	sd	s5,40(sp)
 146:	f05a                	sd	s6,32(sp)
 148:	ec5e                	sd	s7,24(sp)
 14a:	1080                	addi	s0,sp,96
 14c:	8baa                	mv	s7,a0
 14e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 150:	892a                	mv	s2,a0
 152:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 154:	4aa9                	li	s5,10
 156:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 158:	89a6                	mv	s3,s1
 15a:	2485                	addiw	s1,s1,1
 15c:	0344d863          	bge	s1,s4,18c <gets+0x56>
    cc = read(0, &c, 1);
 160:	4605                	li	a2,1
 162:	faf40593          	addi	a1,s0,-81
 166:	4501                	li	a0,0
 168:	00000097          	auipc	ra,0x0
 16c:	19a080e7          	jalr	410(ra) # 302 <read>
    if(cc < 1)
 170:	00a05e63          	blez	a0,18c <gets+0x56>
    buf[i++] = c;
 174:	faf44783          	lbu	a5,-81(s0)
 178:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 17c:	01578763          	beq	a5,s5,18a <gets+0x54>
 180:	0905                	addi	s2,s2,1
 182:	fd679be3          	bne	a5,s6,158 <gets+0x22>
  for(i=0; i+1 < max; ){
 186:	89a6                	mv	s3,s1
 188:	a011                	j	18c <gets+0x56>
 18a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 18c:	99de                	add	s3,s3,s7
 18e:	00098023          	sb	zero,0(s3)
  return buf;
}
 192:	855e                	mv	a0,s7
 194:	60e6                	ld	ra,88(sp)
 196:	6446                	ld	s0,80(sp)
 198:	64a6                	ld	s1,72(sp)
 19a:	6906                	ld	s2,64(sp)
 19c:	79e2                	ld	s3,56(sp)
 19e:	7a42                	ld	s4,48(sp)
 1a0:	7aa2                	ld	s5,40(sp)
 1a2:	7b02                	ld	s6,32(sp)
 1a4:	6be2                	ld	s7,24(sp)
 1a6:	6125                	addi	sp,sp,96
 1a8:	8082                	ret

00000000000001aa <stat>:

int
stat(const char *n, struct stat *st)
{
 1aa:	1101                	addi	sp,sp,-32
 1ac:	ec06                	sd	ra,24(sp)
 1ae:	e822                	sd	s0,16(sp)
 1b0:	e426                	sd	s1,8(sp)
 1b2:	e04a                	sd	s2,0(sp)
 1b4:	1000                	addi	s0,sp,32
 1b6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1b8:	4581                	li	a1,0
 1ba:	00000097          	auipc	ra,0x0
 1be:	170080e7          	jalr	368(ra) # 32a <open>
  if(fd < 0)
 1c2:	02054563          	bltz	a0,1ec <stat+0x42>
 1c6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1c8:	85ca                	mv	a1,s2
 1ca:	00000097          	auipc	ra,0x0
 1ce:	178080e7          	jalr	376(ra) # 342 <fstat>
 1d2:	892a                	mv	s2,a0
  close(fd);
 1d4:	8526                	mv	a0,s1
 1d6:	00000097          	auipc	ra,0x0
 1da:	13c080e7          	jalr	316(ra) # 312 <close>
  return r;
}
 1de:	854a                	mv	a0,s2
 1e0:	60e2                	ld	ra,24(sp)
 1e2:	6442                	ld	s0,16(sp)
 1e4:	64a2                	ld	s1,8(sp)
 1e6:	6902                	ld	s2,0(sp)
 1e8:	6105                	addi	sp,sp,32
 1ea:	8082                	ret
    return -1;
 1ec:	597d                	li	s2,-1
 1ee:	bfc5                	j	1de <stat+0x34>

00000000000001f0 <atoi>:

int
atoi(const char *s)
{
 1f0:	1141                	addi	sp,sp,-16
 1f2:	e422                	sd	s0,8(sp)
 1f4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1f6:	00054683          	lbu	a3,0(a0)
 1fa:	fd06879b          	addiw	a5,a3,-48
 1fe:	0ff7f793          	zext.b	a5,a5
 202:	4625                	li	a2,9
 204:	02f66863          	bltu	a2,a5,234 <atoi+0x44>
 208:	872a                	mv	a4,a0
  n = 0;
 20a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 20c:	0705                	addi	a4,a4,1
 20e:	0025179b          	slliw	a5,a0,0x2
 212:	9fa9                	addw	a5,a5,a0
 214:	0017979b          	slliw	a5,a5,0x1
 218:	9fb5                	addw	a5,a5,a3
 21a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 21e:	00074683          	lbu	a3,0(a4)
 222:	fd06879b          	addiw	a5,a3,-48
 226:	0ff7f793          	zext.b	a5,a5
 22a:	fef671e3          	bgeu	a2,a5,20c <atoi+0x1c>
  return n;
}
 22e:	6422                	ld	s0,8(sp)
 230:	0141                	addi	sp,sp,16
 232:	8082                	ret
  n = 0;
 234:	4501                	li	a0,0
 236:	bfe5                	j	22e <atoi+0x3e>

0000000000000238 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 238:	1141                	addi	sp,sp,-16
 23a:	e422                	sd	s0,8(sp)
 23c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 23e:	02b57463          	bgeu	a0,a1,266 <memmove+0x2e>
    while(n-- > 0)
 242:	00c05f63          	blez	a2,260 <memmove+0x28>
 246:	1602                	slli	a2,a2,0x20
 248:	9201                	srli	a2,a2,0x20
 24a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 24e:	872a                	mv	a4,a0
      *dst++ = *src++;
 250:	0585                	addi	a1,a1,1
 252:	0705                	addi	a4,a4,1
 254:	fff5c683          	lbu	a3,-1(a1)
 258:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 25c:	fee79ae3          	bne	a5,a4,250 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 260:	6422                	ld	s0,8(sp)
 262:	0141                	addi	sp,sp,16
 264:	8082                	ret
    dst += n;
 266:	00c50733          	add	a4,a0,a2
    src += n;
 26a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 26c:	fec05ae3          	blez	a2,260 <memmove+0x28>
 270:	fff6079b          	addiw	a5,a2,-1
 274:	1782                	slli	a5,a5,0x20
 276:	9381                	srli	a5,a5,0x20
 278:	fff7c793          	not	a5,a5
 27c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 27e:	15fd                	addi	a1,a1,-1
 280:	177d                	addi	a4,a4,-1
 282:	0005c683          	lbu	a3,0(a1)
 286:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 28a:	fee79ae3          	bne	a5,a4,27e <memmove+0x46>
 28e:	bfc9                	j	260 <memmove+0x28>

0000000000000290 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 290:	1141                	addi	sp,sp,-16
 292:	e422                	sd	s0,8(sp)
 294:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 296:	ca05                	beqz	a2,2c6 <memcmp+0x36>
 298:	fff6069b          	addiw	a3,a2,-1
 29c:	1682                	slli	a3,a3,0x20
 29e:	9281                	srli	a3,a3,0x20
 2a0:	0685                	addi	a3,a3,1
 2a2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2a4:	00054783          	lbu	a5,0(a0)
 2a8:	0005c703          	lbu	a4,0(a1)
 2ac:	00e79863          	bne	a5,a4,2bc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2b0:	0505                	addi	a0,a0,1
    p2++;
 2b2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2b4:	fed518e3          	bne	a0,a3,2a4 <memcmp+0x14>
  }
  return 0;
 2b8:	4501                	li	a0,0
 2ba:	a019                	j	2c0 <memcmp+0x30>
      return *p1 - *p2;
 2bc:	40e7853b          	subw	a0,a5,a4
}
 2c0:	6422                	ld	s0,8(sp)
 2c2:	0141                	addi	sp,sp,16
 2c4:	8082                	ret
  return 0;
 2c6:	4501                	li	a0,0
 2c8:	bfe5                	j	2c0 <memcmp+0x30>

00000000000002ca <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2ca:	1141                	addi	sp,sp,-16
 2cc:	e406                	sd	ra,8(sp)
 2ce:	e022                	sd	s0,0(sp)
 2d0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2d2:	00000097          	auipc	ra,0x0
 2d6:	f66080e7          	jalr	-154(ra) # 238 <memmove>
}
 2da:	60a2                	ld	ra,8(sp)
 2dc:	6402                	ld	s0,0(sp)
 2de:	0141                	addi	sp,sp,16
 2e0:	8082                	ret

00000000000002e2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2e2:	4885                	li	a7,1
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <exit>:
.global exit
exit:
 li a7, SYS_exit
 2ea:	4889                	li	a7,2
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2f2:	488d                	li	a7,3
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2fa:	4891                	li	a7,4
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <read>:
.global read
read:
 li a7, SYS_read
 302:	4895                	li	a7,5
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <write>:
.global write
write:
 li a7, SYS_write
 30a:	48c1                	li	a7,16
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <close>:
.global close
close:
 li a7, SYS_close
 312:	48d5                	li	a7,21
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <kill>:
.global kill
kill:
 li a7, SYS_kill
 31a:	4899                	li	a7,6
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <exec>:
.global exec
exec:
 li a7, SYS_exec
 322:	489d                	li	a7,7
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <open>:
.global open
open:
 li a7, SYS_open
 32a:	48bd                	li	a7,15
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 332:	48c5                	li	a7,17
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 33a:	48c9                	li	a7,18
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 342:	48a1                	li	a7,8
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <link>:
.global link
link:
 li a7, SYS_link
 34a:	48cd                	li	a7,19
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 352:	48d1                	li	a7,20
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 35a:	48a5                	li	a7,9
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <dup>:
.global dup
dup:
 li a7, SYS_dup
 362:	48a9                	li	a7,10
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 36a:	48ad                	li	a7,11
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 372:	48b1                	li	a7,12
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 37a:	48b5                	li	a7,13
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 382:	48b9                	li	a7,14
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <trace>:
.global trace
trace:
 li a7, SYS_trace
 38a:	48d9                	li	a7,22
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 392:	48dd                	li	a7,23
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 39a:	48e1                	li	a7,24
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 3a2:	48e5                	li	a7,25
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
 3aa:	48e9                	li	a7,26
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 3b2:	48ed                	li	a7,27
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3ba:	1101                	addi	sp,sp,-32
 3bc:	ec06                	sd	ra,24(sp)
 3be:	e822                	sd	s0,16(sp)
 3c0:	1000                	addi	s0,sp,32
 3c2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3c6:	4605                	li	a2,1
 3c8:	fef40593          	addi	a1,s0,-17
 3cc:	00000097          	auipc	ra,0x0
 3d0:	f3e080e7          	jalr	-194(ra) # 30a <write>
}
 3d4:	60e2                	ld	ra,24(sp)
 3d6:	6442                	ld	s0,16(sp)
 3d8:	6105                	addi	sp,sp,32
 3da:	8082                	ret

00000000000003dc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3dc:	7139                	addi	sp,sp,-64
 3de:	fc06                	sd	ra,56(sp)
 3e0:	f822                	sd	s0,48(sp)
 3e2:	f426                	sd	s1,40(sp)
 3e4:	f04a                	sd	s2,32(sp)
 3e6:	ec4e                	sd	s3,24(sp)
 3e8:	0080                	addi	s0,sp,64
 3ea:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3ec:	c299                	beqz	a3,3f2 <printint+0x16>
 3ee:	0805c963          	bltz	a1,480 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3f2:	2581                	sext.w	a1,a1
  neg = 0;
 3f4:	4881                	li	a7,0
 3f6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3fa:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3fc:	2601                	sext.w	a2,a2
 3fe:	00000517          	auipc	a0,0x0
 402:	49a50513          	addi	a0,a0,1178 # 898 <digits>
 406:	883a                	mv	a6,a4
 408:	2705                	addiw	a4,a4,1
 40a:	02c5f7bb          	remuw	a5,a1,a2
 40e:	1782                	slli	a5,a5,0x20
 410:	9381                	srli	a5,a5,0x20
 412:	97aa                	add	a5,a5,a0
 414:	0007c783          	lbu	a5,0(a5)
 418:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 41c:	0005879b          	sext.w	a5,a1
 420:	02c5d5bb          	divuw	a1,a1,a2
 424:	0685                	addi	a3,a3,1
 426:	fec7f0e3          	bgeu	a5,a2,406 <printint+0x2a>
  if(neg)
 42a:	00088c63          	beqz	a7,442 <printint+0x66>
    buf[i++] = '-';
 42e:	fd070793          	addi	a5,a4,-48
 432:	00878733          	add	a4,a5,s0
 436:	02d00793          	li	a5,45
 43a:	fef70823          	sb	a5,-16(a4)
 43e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 442:	02e05863          	blez	a4,472 <printint+0x96>
 446:	fc040793          	addi	a5,s0,-64
 44a:	00e78933          	add	s2,a5,a4
 44e:	fff78993          	addi	s3,a5,-1
 452:	99ba                	add	s3,s3,a4
 454:	377d                	addiw	a4,a4,-1
 456:	1702                	slli	a4,a4,0x20
 458:	9301                	srli	a4,a4,0x20
 45a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 45e:	fff94583          	lbu	a1,-1(s2)
 462:	8526                	mv	a0,s1
 464:	00000097          	auipc	ra,0x0
 468:	f56080e7          	jalr	-170(ra) # 3ba <putc>
  while(--i >= 0)
 46c:	197d                	addi	s2,s2,-1
 46e:	ff3918e3          	bne	s2,s3,45e <printint+0x82>
}
 472:	70e2                	ld	ra,56(sp)
 474:	7442                	ld	s0,48(sp)
 476:	74a2                	ld	s1,40(sp)
 478:	7902                	ld	s2,32(sp)
 47a:	69e2                	ld	s3,24(sp)
 47c:	6121                	addi	sp,sp,64
 47e:	8082                	ret
    x = -xx;
 480:	40b005bb          	negw	a1,a1
    neg = 1;
 484:	4885                	li	a7,1
    x = -xx;
 486:	bf85                	j	3f6 <printint+0x1a>

0000000000000488 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 488:	715d                	addi	sp,sp,-80
 48a:	e486                	sd	ra,72(sp)
 48c:	e0a2                	sd	s0,64(sp)
 48e:	fc26                	sd	s1,56(sp)
 490:	f84a                	sd	s2,48(sp)
 492:	f44e                	sd	s3,40(sp)
 494:	f052                	sd	s4,32(sp)
 496:	ec56                	sd	s5,24(sp)
 498:	e85a                	sd	s6,16(sp)
 49a:	e45e                	sd	s7,8(sp)
 49c:	e062                	sd	s8,0(sp)
 49e:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4a0:	0005c903          	lbu	s2,0(a1)
 4a4:	18090c63          	beqz	s2,63c <vprintf+0x1b4>
 4a8:	8aaa                	mv	s5,a0
 4aa:	8bb2                	mv	s7,a2
 4ac:	00158493          	addi	s1,a1,1
  state = 0;
 4b0:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4b2:	02500a13          	li	s4,37
 4b6:	4b55                	li	s6,21
 4b8:	a839                	j	4d6 <vprintf+0x4e>
        putc(fd, c);
 4ba:	85ca                	mv	a1,s2
 4bc:	8556                	mv	a0,s5
 4be:	00000097          	auipc	ra,0x0
 4c2:	efc080e7          	jalr	-260(ra) # 3ba <putc>
 4c6:	a019                	j	4cc <vprintf+0x44>
    } else if(state == '%'){
 4c8:	01498d63          	beq	s3,s4,4e2 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 4cc:	0485                	addi	s1,s1,1
 4ce:	fff4c903          	lbu	s2,-1(s1)
 4d2:	16090563          	beqz	s2,63c <vprintf+0x1b4>
    if(state == 0){
 4d6:	fe0999e3          	bnez	s3,4c8 <vprintf+0x40>
      if(c == '%'){
 4da:	ff4910e3          	bne	s2,s4,4ba <vprintf+0x32>
        state = '%';
 4de:	89d2                	mv	s3,s4
 4e0:	b7f5                	j	4cc <vprintf+0x44>
      if(c == 'd'){
 4e2:	13490263          	beq	s2,s4,606 <vprintf+0x17e>
 4e6:	f9d9079b          	addiw	a5,s2,-99
 4ea:	0ff7f793          	zext.b	a5,a5
 4ee:	12fb6563          	bltu	s6,a5,618 <vprintf+0x190>
 4f2:	f9d9079b          	addiw	a5,s2,-99
 4f6:	0ff7f713          	zext.b	a4,a5
 4fa:	10eb6f63          	bltu	s6,a4,618 <vprintf+0x190>
 4fe:	00271793          	slli	a5,a4,0x2
 502:	00000717          	auipc	a4,0x0
 506:	33e70713          	addi	a4,a4,830 # 840 <malloc+0x106>
 50a:	97ba                	add	a5,a5,a4
 50c:	439c                	lw	a5,0(a5)
 50e:	97ba                	add	a5,a5,a4
 510:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 512:	008b8913          	addi	s2,s7,8
 516:	4685                	li	a3,1
 518:	4629                	li	a2,10
 51a:	000ba583          	lw	a1,0(s7)
 51e:	8556                	mv	a0,s5
 520:	00000097          	auipc	ra,0x0
 524:	ebc080e7          	jalr	-324(ra) # 3dc <printint>
 528:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 52a:	4981                	li	s3,0
 52c:	b745                	j	4cc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 52e:	008b8913          	addi	s2,s7,8
 532:	4681                	li	a3,0
 534:	4629                	li	a2,10
 536:	000ba583          	lw	a1,0(s7)
 53a:	8556                	mv	a0,s5
 53c:	00000097          	auipc	ra,0x0
 540:	ea0080e7          	jalr	-352(ra) # 3dc <printint>
 544:	8bca                	mv	s7,s2
      state = 0;
 546:	4981                	li	s3,0
 548:	b751                	j	4cc <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 54a:	008b8913          	addi	s2,s7,8
 54e:	4681                	li	a3,0
 550:	4641                	li	a2,16
 552:	000ba583          	lw	a1,0(s7)
 556:	8556                	mv	a0,s5
 558:	00000097          	auipc	ra,0x0
 55c:	e84080e7          	jalr	-380(ra) # 3dc <printint>
 560:	8bca                	mv	s7,s2
      state = 0;
 562:	4981                	li	s3,0
 564:	b7a5                	j	4cc <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 566:	008b8c13          	addi	s8,s7,8
 56a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 56e:	03000593          	li	a1,48
 572:	8556                	mv	a0,s5
 574:	00000097          	auipc	ra,0x0
 578:	e46080e7          	jalr	-442(ra) # 3ba <putc>
  putc(fd, 'x');
 57c:	07800593          	li	a1,120
 580:	8556                	mv	a0,s5
 582:	00000097          	auipc	ra,0x0
 586:	e38080e7          	jalr	-456(ra) # 3ba <putc>
 58a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 58c:	00000b97          	auipc	s7,0x0
 590:	30cb8b93          	addi	s7,s7,780 # 898 <digits>
 594:	03c9d793          	srli	a5,s3,0x3c
 598:	97de                	add	a5,a5,s7
 59a:	0007c583          	lbu	a1,0(a5)
 59e:	8556                	mv	a0,s5
 5a0:	00000097          	auipc	ra,0x0
 5a4:	e1a080e7          	jalr	-486(ra) # 3ba <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5a8:	0992                	slli	s3,s3,0x4
 5aa:	397d                	addiw	s2,s2,-1
 5ac:	fe0914e3          	bnez	s2,594 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5b0:	8be2                	mv	s7,s8
      state = 0;
 5b2:	4981                	li	s3,0
 5b4:	bf21                	j	4cc <vprintf+0x44>
        s = va_arg(ap, char*);
 5b6:	008b8993          	addi	s3,s7,8
 5ba:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5be:	02090163          	beqz	s2,5e0 <vprintf+0x158>
        while(*s != 0){
 5c2:	00094583          	lbu	a1,0(s2)
 5c6:	c9a5                	beqz	a1,636 <vprintf+0x1ae>
          putc(fd, *s);
 5c8:	8556                	mv	a0,s5
 5ca:	00000097          	auipc	ra,0x0
 5ce:	df0080e7          	jalr	-528(ra) # 3ba <putc>
          s++;
 5d2:	0905                	addi	s2,s2,1
        while(*s != 0){
 5d4:	00094583          	lbu	a1,0(s2)
 5d8:	f9e5                	bnez	a1,5c8 <vprintf+0x140>
        s = va_arg(ap, char*);
 5da:	8bce                	mv	s7,s3
      state = 0;
 5dc:	4981                	li	s3,0
 5de:	b5fd                	j	4cc <vprintf+0x44>
          s = "(null)";
 5e0:	00000917          	auipc	s2,0x0
 5e4:	25890913          	addi	s2,s2,600 # 838 <malloc+0xfe>
        while(*s != 0){
 5e8:	02800593          	li	a1,40
 5ec:	bff1                	j	5c8 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 5ee:	008b8913          	addi	s2,s7,8
 5f2:	000bc583          	lbu	a1,0(s7)
 5f6:	8556                	mv	a0,s5
 5f8:	00000097          	auipc	ra,0x0
 5fc:	dc2080e7          	jalr	-574(ra) # 3ba <putc>
 600:	8bca                	mv	s7,s2
      state = 0;
 602:	4981                	li	s3,0
 604:	b5e1                	j	4cc <vprintf+0x44>
        putc(fd, c);
 606:	02500593          	li	a1,37
 60a:	8556                	mv	a0,s5
 60c:	00000097          	auipc	ra,0x0
 610:	dae080e7          	jalr	-594(ra) # 3ba <putc>
      state = 0;
 614:	4981                	li	s3,0
 616:	bd5d                	j	4cc <vprintf+0x44>
        putc(fd, '%');
 618:	02500593          	li	a1,37
 61c:	8556                	mv	a0,s5
 61e:	00000097          	auipc	ra,0x0
 622:	d9c080e7          	jalr	-612(ra) # 3ba <putc>
        putc(fd, c);
 626:	85ca                	mv	a1,s2
 628:	8556                	mv	a0,s5
 62a:	00000097          	auipc	ra,0x0
 62e:	d90080e7          	jalr	-624(ra) # 3ba <putc>
      state = 0;
 632:	4981                	li	s3,0
 634:	bd61                	j	4cc <vprintf+0x44>
        s = va_arg(ap, char*);
 636:	8bce                	mv	s7,s3
      state = 0;
 638:	4981                	li	s3,0
 63a:	bd49                	j	4cc <vprintf+0x44>
    }
  }
}
 63c:	60a6                	ld	ra,72(sp)
 63e:	6406                	ld	s0,64(sp)
 640:	74e2                	ld	s1,56(sp)
 642:	7942                	ld	s2,48(sp)
 644:	79a2                	ld	s3,40(sp)
 646:	7a02                	ld	s4,32(sp)
 648:	6ae2                	ld	s5,24(sp)
 64a:	6b42                	ld	s6,16(sp)
 64c:	6ba2                	ld	s7,8(sp)
 64e:	6c02                	ld	s8,0(sp)
 650:	6161                	addi	sp,sp,80
 652:	8082                	ret

0000000000000654 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 654:	715d                	addi	sp,sp,-80
 656:	ec06                	sd	ra,24(sp)
 658:	e822                	sd	s0,16(sp)
 65a:	1000                	addi	s0,sp,32
 65c:	e010                	sd	a2,0(s0)
 65e:	e414                	sd	a3,8(s0)
 660:	e818                	sd	a4,16(s0)
 662:	ec1c                	sd	a5,24(s0)
 664:	03043023          	sd	a6,32(s0)
 668:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 66c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 670:	8622                	mv	a2,s0
 672:	00000097          	auipc	ra,0x0
 676:	e16080e7          	jalr	-490(ra) # 488 <vprintf>
}
 67a:	60e2                	ld	ra,24(sp)
 67c:	6442                	ld	s0,16(sp)
 67e:	6161                	addi	sp,sp,80
 680:	8082                	ret

0000000000000682 <printf>:

void
printf(const char *fmt, ...)
{
 682:	711d                	addi	sp,sp,-96
 684:	ec06                	sd	ra,24(sp)
 686:	e822                	sd	s0,16(sp)
 688:	1000                	addi	s0,sp,32
 68a:	e40c                	sd	a1,8(s0)
 68c:	e810                	sd	a2,16(s0)
 68e:	ec14                	sd	a3,24(s0)
 690:	f018                	sd	a4,32(s0)
 692:	f41c                	sd	a5,40(s0)
 694:	03043823          	sd	a6,48(s0)
 698:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 69c:	00840613          	addi	a2,s0,8
 6a0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6a4:	85aa                	mv	a1,a0
 6a6:	4505                	li	a0,1
 6a8:	00000097          	auipc	ra,0x0
 6ac:	de0080e7          	jalr	-544(ra) # 488 <vprintf>
}
 6b0:	60e2                	ld	ra,24(sp)
 6b2:	6442                	ld	s0,16(sp)
 6b4:	6125                	addi	sp,sp,96
 6b6:	8082                	ret

00000000000006b8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6b8:	1141                	addi	sp,sp,-16
 6ba:	e422                	sd	s0,8(sp)
 6bc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6be:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c2:	00001797          	auipc	a5,0x1
 6c6:	93e7b783          	ld	a5,-1730(a5) # 1000 <freep>
 6ca:	a02d                	j	6f4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6cc:	4618                	lw	a4,8(a2)
 6ce:	9f2d                	addw	a4,a4,a1
 6d0:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6d4:	6398                	ld	a4,0(a5)
 6d6:	6310                	ld	a2,0(a4)
 6d8:	a83d                	j	716 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6da:	ff852703          	lw	a4,-8(a0)
 6de:	9f31                	addw	a4,a4,a2
 6e0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6e2:	ff053683          	ld	a3,-16(a0)
 6e6:	a091                	j	72a <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6e8:	6398                	ld	a4,0(a5)
 6ea:	00e7e463          	bltu	a5,a4,6f2 <free+0x3a>
 6ee:	00e6ea63          	bltu	a3,a4,702 <free+0x4a>
{
 6f2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f4:	fed7fae3          	bgeu	a5,a3,6e8 <free+0x30>
 6f8:	6398                	ld	a4,0(a5)
 6fa:	00e6e463          	bltu	a3,a4,702 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6fe:	fee7eae3          	bltu	a5,a4,6f2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 702:	ff852583          	lw	a1,-8(a0)
 706:	6390                	ld	a2,0(a5)
 708:	02059813          	slli	a6,a1,0x20
 70c:	01c85713          	srli	a4,a6,0x1c
 710:	9736                	add	a4,a4,a3
 712:	fae60de3          	beq	a2,a4,6cc <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 716:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 71a:	4790                	lw	a2,8(a5)
 71c:	02061593          	slli	a1,a2,0x20
 720:	01c5d713          	srli	a4,a1,0x1c
 724:	973e                	add	a4,a4,a5
 726:	fae68ae3          	beq	a3,a4,6da <free+0x22>
    p->s.ptr = bp->s.ptr;
 72a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 72c:	00001717          	auipc	a4,0x1
 730:	8cf73a23          	sd	a5,-1836(a4) # 1000 <freep>
}
 734:	6422                	ld	s0,8(sp)
 736:	0141                	addi	sp,sp,16
 738:	8082                	ret

000000000000073a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 73a:	7139                	addi	sp,sp,-64
 73c:	fc06                	sd	ra,56(sp)
 73e:	f822                	sd	s0,48(sp)
 740:	f426                	sd	s1,40(sp)
 742:	f04a                	sd	s2,32(sp)
 744:	ec4e                	sd	s3,24(sp)
 746:	e852                	sd	s4,16(sp)
 748:	e456                	sd	s5,8(sp)
 74a:	e05a                	sd	s6,0(sp)
 74c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 74e:	02051493          	slli	s1,a0,0x20
 752:	9081                	srli	s1,s1,0x20
 754:	04bd                	addi	s1,s1,15
 756:	8091                	srli	s1,s1,0x4
 758:	0014899b          	addiw	s3,s1,1
 75c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 75e:	00001517          	auipc	a0,0x1
 762:	8a253503          	ld	a0,-1886(a0) # 1000 <freep>
 766:	c515                	beqz	a0,792 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 768:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 76a:	4798                	lw	a4,8(a5)
 76c:	02977f63          	bgeu	a4,s1,7aa <malloc+0x70>
  if(nu < 4096)
 770:	8a4e                	mv	s4,s3
 772:	0009871b          	sext.w	a4,s3
 776:	6685                	lui	a3,0x1
 778:	00d77363          	bgeu	a4,a3,77e <malloc+0x44>
 77c:	6a05                	lui	s4,0x1
 77e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 782:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 786:	00001917          	auipc	s2,0x1
 78a:	87a90913          	addi	s2,s2,-1926 # 1000 <freep>
  if(p == (char*)-1)
 78e:	5afd                	li	s5,-1
 790:	a895                	j	804 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 792:	00001797          	auipc	a5,0x1
 796:	87e78793          	addi	a5,a5,-1922 # 1010 <base>
 79a:	00001717          	auipc	a4,0x1
 79e:	86f73323          	sd	a5,-1946(a4) # 1000 <freep>
 7a2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7a4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7a8:	b7e1                	j	770 <malloc+0x36>
      if(p->s.size == nunits)
 7aa:	02e48c63          	beq	s1,a4,7e2 <malloc+0xa8>
        p->s.size -= nunits;
 7ae:	4137073b          	subw	a4,a4,s3
 7b2:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7b4:	02071693          	slli	a3,a4,0x20
 7b8:	01c6d713          	srli	a4,a3,0x1c
 7bc:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7be:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7c2:	00001717          	auipc	a4,0x1
 7c6:	82a73f23          	sd	a0,-1986(a4) # 1000 <freep>
      return (void*)(p + 1);
 7ca:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7ce:	70e2                	ld	ra,56(sp)
 7d0:	7442                	ld	s0,48(sp)
 7d2:	74a2                	ld	s1,40(sp)
 7d4:	7902                	ld	s2,32(sp)
 7d6:	69e2                	ld	s3,24(sp)
 7d8:	6a42                	ld	s4,16(sp)
 7da:	6aa2                	ld	s5,8(sp)
 7dc:	6b02                	ld	s6,0(sp)
 7de:	6121                	addi	sp,sp,64
 7e0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7e2:	6398                	ld	a4,0(a5)
 7e4:	e118                	sd	a4,0(a0)
 7e6:	bff1                	j	7c2 <malloc+0x88>
  hp->s.size = nu;
 7e8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7ec:	0541                	addi	a0,a0,16
 7ee:	00000097          	auipc	ra,0x0
 7f2:	eca080e7          	jalr	-310(ra) # 6b8 <free>
  return freep;
 7f6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7fa:	d971                	beqz	a0,7ce <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7fc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7fe:	4798                	lw	a4,8(a5)
 800:	fa9775e3          	bgeu	a4,s1,7aa <malloc+0x70>
    if(p == freep)
 804:	00093703          	ld	a4,0(s2)
 808:	853e                	mv	a0,a5
 80a:	fef719e3          	bne	a4,a5,7fc <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 80e:	8552                	mv	a0,s4
 810:	00000097          	auipc	ra,0x0
 814:	b62080e7          	jalr	-1182(ra) # 372 <sbrk>
  if(p == (char*)-1)
 818:	fd5518e3          	bne	a0,s5,7e8 <malloc+0xae>
        return 0;
 81c:	4501                	li	a0,0
 81e:	bf45                	j	7ce <malloc+0x94>
