
user/_strace:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/fcntl.h"

#define MAXARGS 10

int
main(int argc, char *argv[]) {
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  if (argc <= 2) {
  10:	4789                	li	a5,2
  12:	04a7da63          	bge	a5,a0,66 <main+0x66>
  16:	8a2e                	mv	s4,a1
    fprintf(2, "strace: insufficient arguments\n");
    exit(1);
  }

  char *mask_str = argv[1];
  18:	0085b903          	ld	s2,8(a1)
  for (int i = 0; i < strlen(mask_str); i++) {
  1c:	4481                	li	s1,0
    if (!('0' <= mask_str[i] && mask_str[i] <= '9')) {
  1e:	49a5                	li	s3,9
  for (int i = 0; i < strlen(mask_str); i++) {
  20:	854a                	mv	a0,s2
  22:	00000097          	auipc	ra,0x0
  26:	148080e7          	jalr	328(ra) # 16a <strlen>
  2a:	2501                	sext.w	a0,a0
  2c:	0004879b          	sext.w	a5,s1
  30:	04a7f963          	bgeu	a5,a0,82 <main+0x82>
    if (!('0' <= mask_str[i] && mask_str[i] <= '9')) {
  34:	009907b3          	add	a5,s2,s1
  38:	0007c783          	lbu	a5,0(a5)
  3c:	fd07879b          	addiw	a5,a5,-48
  40:	0ff7f793          	zext.b	a5,a5
  44:	0485                	addi	s1,s1,1
  46:	fcf9fde3          	bgeu	s3,a5,20 <main+0x20>
      fprintf(2, "strace: invalid syscall mask\n");
  4a:	00001597          	auipc	a1,0x1
  4e:	88658593          	addi	a1,a1,-1914 # 8d0 <malloc+0x10a>
  52:	4509                	li	a0,2
  54:	00000097          	auipc	ra,0x0
  58:	68c080e7          	jalr	1676(ra) # 6e0 <fprintf>
      exit(1);
  5c:	4505                	li	a0,1
  5e:	00000097          	auipc	ra,0x0
  62:	330080e7          	jalr	816(ra) # 38e <exit>
    fprintf(2, "strace: insufficient arguments\n");
  66:	00001597          	auipc	a1,0x1
  6a:	84a58593          	addi	a1,a1,-1974 # 8b0 <malloc+0xea>
  6e:	4509                	li	a0,2
  70:	00000097          	auipc	ra,0x0
  74:	670080e7          	jalr	1648(ra) # 6e0 <fprintf>
    exit(1);
  78:	4505                	li	a0,1
  7a:	00000097          	auipc	ra,0x0
  7e:	314080e7          	jalr	788(ra) # 38e <exit>
    }
  }

  int mask = atoi(mask_str);
  82:	854a                	mv	a0,s2
  84:	00000097          	auipc	ra,0x0
  88:	210080e7          	jalr	528(ra) # 294 <atoi>
  8c:	84aa                	mv	s1,a0

  int pid = fork();
  8e:	00000097          	auipc	ra,0x0
  92:	2f8080e7          	jalr	760(ra) # 386 <fork>
  if (pid == -1) {
  96:	57fd                	li	a5,-1
  98:	04f50063          	beq	a0,a5,d8 <main+0xd8>
    fprintf(2, "strace: failed to run command\n");
    exit(1);
  }

  if (pid == 0) {
  9c:	ed21                	bnez	a0,f4 <main+0xf4>
    trace(mask);
  9e:	8526                	mv	a0,s1
  a0:	00000097          	auipc	ra,0x0
  a4:	38e080e7          	jalr	910(ra) # 42e <trace>

    exec(argv[2], argv + 2);
  a8:	010a0593          	addi	a1,s4,16
  ac:	010a3503          	ld	a0,16(s4)
  b0:	00000097          	auipc	ra,0x0
  b4:	316080e7          	jalr	790(ra) # 3c6 <exec>
    fprintf(2, "strace: exec %s failed\n", argv[2]);
  b8:	010a3603          	ld	a2,16(s4)
  bc:	00001597          	auipc	a1,0x1
  c0:	85458593          	addi	a1,a1,-1964 # 910 <malloc+0x14a>
  c4:	4509                	li	a0,2
  c6:	00000097          	auipc	ra,0x0
  ca:	61a080e7          	jalr	1562(ra) # 6e0 <fprintf>
    exit(1);
  ce:	4505                	li	a0,1
  d0:	00000097          	auipc	ra,0x0
  d4:	2be080e7          	jalr	702(ra) # 38e <exit>
    fprintf(2, "strace: failed to run command\n");
  d8:	00001597          	auipc	a1,0x1
  dc:	81858593          	addi	a1,a1,-2024 # 8f0 <malloc+0x12a>
  e0:	4509                	li	a0,2
  e2:	00000097          	auipc	ra,0x0
  e6:	5fe080e7          	jalr	1534(ra) # 6e0 <fprintf>
    exit(1);
  ea:	4505                	li	a0,1
  ec:	00000097          	auipc	ra,0x0
  f0:	2a2080e7          	jalr	674(ra) # 38e <exit>
  }
  wait(0);
  f4:	4501                	li	a0,0
  f6:	00000097          	auipc	ra,0x0
  fa:	2a0080e7          	jalr	672(ra) # 396 <wait>
  exit(0);
  fe:	4501                	li	a0,0
 100:	00000097          	auipc	ra,0x0
 104:	28e080e7          	jalr	654(ra) # 38e <exit>

0000000000000108 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 108:	1141                	addi	sp,sp,-16
 10a:	e406                	sd	ra,8(sp)
 10c:	e022                	sd	s0,0(sp)
 10e:	0800                	addi	s0,sp,16
  extern int main();
  main();
 110:	00000097          	auipc	ra,0x0
 114:	ef0080e7          	jalr	-272(ra) # 0 <main>
  exit(0);
 118:	4501                	li	a0,0
 11a:	00000097          	auipc	ra,0x0
 11e:	274080e7          	jalr	628(ra) # 38e <exit>

0000000000000122 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 122:	1141                	addi	sp,sp,-16
 124:	e422                	sd	s0,8(sp)
 126:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 128:	87aa                	mv	a5,a0
 12a:	0585                	addi	a1,a1,1
 12c:	0785                	addi	a5,a5,1
 12e:	fff5c703          	lbu	a4,-1(a1)
 132:	fee78fa3          	sb	a4,-1(a5)
 136:	fb75                	bnez	a4,12a <strcpy+0x8>
    ;
  return os;
}
 138:	6422                	ld	s0,8(sp)
 13a:	0141                	addi	sp,sp,16
 13c:	8082                	ret

000000000000013e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 13e:	1141                	addi	sp,sp,-16
 140:	e422                	sd	s0,8(sp)
 142:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 144:	00054783          	lbu	a5,0(a0)
 148:	cb91                	beqz	a5,15c <strcmp+0x1e>
 14a:	0005c703          	lbu	a4,0(a1)
 14e:	00f71763          	bne	a4,a5,15c <strcmp+0x1e>
    p++, q++;
 152:	0505                	addi	a0,a0,1
 154:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 156:	00054783          	lbu	a5,0(a0)
 15a:	fbe5                	bnez	a5,14a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 15c:	0005c503          	lbu	a0,0(a1)
}
 160:	40a7853b          	subw	a0,a5,a0
 164:	6422                	ld	s0,8(sp)
 166:	0141                	addi	sp,sp,16
 168:	8082                	ret

000000000000016a <strlen>:

uint
strlen(const char *s)
{
 16a:	1141                	addi	sp,sp,-16
 16c:	e422                	sd	s0,8(sp)
 16e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 170:	00054783          	lbu	a5,0(a0)
 174:	cf91                	beqz	a5,190 <strlen+0x26>
 176:	0505                	addi	a0,a0,1
 178:	87aa                	mv	a5,a0
 17a:	86be                	mv	a3,a5
 17c:	0785                	addi	a5,a5,1
 17e:	fff7c703          	lbu	a4,-1(a5)
 182:	ff65                	bnez	a4,17a <strlen+0x10>
 184:	40a6853b          	subw	a0,a3,a0
 188:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 18a:	6422                	ld	s0,8(sp)
 18c:	0141                	addi	sp,sp,16
 18e:	8082                	ret
  for(n = 0; s[n]; n++)
 190:	4501                	li	a0,0
 192:	bfe5                	j	18a <strlen+0x20>

0000000000000194 <memset>:

void*
memset(void *dst, int c, uint n)
{
 194:	1141                	addi	sp,sp,-16
 196:	e422                	sd	s0,8(sp)
 198:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 19a:	ca19                	beqz	a2,1b0 <memset+0x1c>
 19c:	87aa                	mv	a5,a0
 19e:	1602                	slli	a2,a2,0x20
 1a0:	9201                	srli	a2,a2,0x20
 1a2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1a6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1aa:	0785                	addi	a5,a5,1
 1ac:	fee79de3          	bne	a5,a4,1a6 <memset+0x12>
  }
  return dst;
}
 1b0:	6422                	ld	s0,8(sp)
 1b2:	0141                	addi	sp,sp,16
 1b4:	8082                	ret

00000000000001b6 <strchr>:

char*
strchr(const char *s, char c)
{
 1b6:	1141                	addi	sp,sp,-16
 1b8:	e422                	sd	s0,8(sp)
 1ba:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1bc:	00054783          	lbu	a5,0(a0)
 1c0:	cb99                	beqz	a5,1d6 <strchr+0x20>
    if(*s == c)
 1c2:	00f58763          	beq	a1,a5,1d0 <strchr+0x1a>
  for(; *s; s++)
 1c6:	0505                	addi	a0,a0,1
 1c8:	00054783          	lbu	a5,0(a0)
 1cc:	fbfd                	bnez	a5,1c2 <strchr+0xc>
      return (char*)s;
  return 0;
 1ce:	4501                	li	a0,0
}
 1d0:	6422                	ld	s0,8(sp)
 1d2:	0141                	addi	sp,sp,16
 1d4:	8082                	ret
  return 0;
 1d6:	4501                	li	a0,0
 1d8:	bfe5                	j	1d0 <strchr+0x1a>

00000000000001da <gets>:

char*
gets(char *buf, int max)
{
 1da:	711d                	addi	sp,sp,-96
 1dc:	ec86                	sd	ra,88(sp)
 1de:	e8a2                	sd	s0,80(sp)
 1e0:	e4a6                	sd	s1,72(sp)
 1e2:	e0ca                	sd	s2,64(sp)
 1e4:	fc4e                	sd	s3,56(sp)
 1e6:	f852                	sd	s4,48(sp)
 1e8:	f456                	sd	s5,40(sp)
 1ea:	f05a                	sd	s6,32(sp)
 1ec:	ec5e                	sd	s7,24(sp)
 1ee:	1080                	addi	s0,sp,96
 1f0:	8baa                	mv	s7,a0
 1f2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1f4:	892a                	mv	s2,a0
 1f6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1f8:	4aa9                	li	s5,10
 1fa:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1fc:	89a6                	mv	s3,s1
 1fe:	2485                	addiw	s1,s1,1
 200:	0344d863          	bge	s1,s4,230 <gets+0x56>
    cc = read(0, &c, 1);
 204:	4605                	li	a2,1
 206:	faf40593          	addi	a1,s0,-81
 20a:	4501                	li	a0,0
 20c:	00000097          	auipc	ra,0x0
 210:	19a080e7          	jalr	410(ra) # 3a6 <read>
    if(cc < 1)
 214:	00a05e63          	blez	a0,230 <gets+0x56>
    buf[i++] = c;
 218:	faf44783          	lbu	a5,-81(s0)
 21c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 220:	01578763          	beq	a5,s5,22e <gets+0x54>
 224:	0905                	addi	s2,s2,1
 226:	fd679be3          	bne	a5,s6,1fc <gets+0x22>
  for(i=0; i+1 < max; ){
 22a:	89a6                	mv	s3,s1
 22c:	a011                	j	230 <gets+0x56>
 22e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 230:	99de                	add	s3,s3,s7
 232:	00098023          	sb	zero,0(s3)
  return buf;
}
 236:	855e                	mv	a0,s7
 238:	60e6                	ld	ra,88(sp)
 23a:	6446                	ld	s0,80(sp)
 23c:	64a6                	ld	s1,72(sp)
 23e:	6906                	ld	s2,64(sp)
 240:	79e2                	ld	s3,56(sp)
 242:	7a42                	ld	s4,48(sp)
 244:	7aa2                	ld	s5,40(sp)
 246:	7b02                	ld	s6,32(sp)
 248:	6be2                	ld	s7,24(sp)
 24a:	6125                	addi	sp,sp,96
 24c:	8082                	ret

000000000000024e <stat>:

int
stat(const char *n, struct stat *st)
{
 24e:	1101                	addi	sp,sp,-32
 250:	ec06                	sd	ra,24(sp)
 252:	e822                	sd	s0,16(sp)
 254:	e426                	sd	s1,8(sp)
 256:	e04a                	sd	s2,0(sp)
 258:	1000                	addi	s0,sp,32
 25a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 25c:	4581                	li	a1,0
 25e:	00000097          	auipc	ra,0x0
 262:	170080e7          	jalr	368(ra) # 3ce <open>
  if(fd < 0)
 266:	02054563          	bltz	a0,290 <stat+0x42>
 26a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 26c:	85ca                	mv	a1,s2
 26e:	00000097          	auipc	ra,0x0
 272:	178080e7          	jalr	376(ra) # 3e6 <fstat>
 276:	892a                	mv	s2,a0
  close(fd);
 278:	8526                	mv	a0,s1
 27a:	00000097          	auipc	ra,0x0
 27e:	13c080e7          	jalr	316(ra) # 3b6 <close>
  return r;
}
 282:	854a                	mv	a0,s2
 284:	60e2                	ld	ra,24(sp)
 286:	6442                	ld	s0,16(sp)
 288:	64a2                	ld	s1,8(sp)
 28a:	6902                	ld	s2,0(sp)
 28c:	6105                	addi	sp,sp,32
 28e:	8082                	ret
    return -1;
 290:	597d                	li	s2,-1
 292:	bfc5                	j	282 <stat+0x34>

0000000000000294 <atoi>:

int
atoi(const char *s)
{
 294:	1141                	addi	sp,sp,-16
 296:	e422                	sd	s0,8(sp)
 298:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 29a:	00054683          	lbu	a3,0(a0)
 29e:	fd06879b          	addiw	a5,a3,-48
 2a2:	0ff7f793          	zext.b	a5,a5
 2a6:	4625                	li	a2,9
 2a8:	02f66863          	bltu	a2,a5,2d8 <atoi+0x44>
 2ac:	872a                	mv	a4,a0
  n = 0;
 2ae:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2b0:	0705                	addi	a4,a4,1
 2b2:	0025179b          	slliw	a5,a0,0x2
 2b6:	9fa9                	addw	a5,a5,a0
 2b8:	0017979b          	slliw	a5,a5,0x1
 2bc:	9fb5                	addw	a5,a5,a3
 2be:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2c2:	00074683          	lbu	a3,0(a4)
 2c6:	fd06879b          	addiw	a5,a3,-48
 2ca:	0ff7f793          	zext.b	a5,a5
 2ce:	fef671e3          	bgeu	a2,a5,2b0 <atoi+0x1c>
  return n;
}
 2d2:	6422                	ld	s0,8(sp)
 2d4:	0141                	addi	sp,sp,16
 2d6:	8082                	ret
  n = 0;
 2d8:	4501                	li	a0,0
 2da:	bfe5                	j	2d2 <atoi+0x3e>

00000000000002dc <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2dc:	1141                	addi	sp,sp,-16
 2de:	e422                	sd	s0,8(sp)
 2e0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2e2:	02b57463          	bgeu	a0,a1,30a <memmove+0x2e>
    while(n-- > 0)
 2e6:	00c05f63          	blez	a2,304 <memmove+0x28>
 2ea:	1602                	slli	a2,a2,0x20
 2ec:	9201                	srli	a2,a2,0x20
 2ee:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2f2:	872a                	mv	a4,a0
      *dst++ = *src++;
 2f4:	0585                	addi	a1,a1,1
 2f6:	0705                	addi	a4,a4,1
 2f8:	fff5c683          	lbu	a3,-1(a1)
 2fc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 300:	fee79ae3          	bne	a5,a4,2f4 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 304:	6422                	ld	s0,8(sp)
 306:	0141                	addi	sp,sp,16
 308:	8082                	ret
    dst += n;
 30a:	00c50733          	add	a4,a0,a2
    src += n;
 30e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 310:	fec05ae3          	blez	a2,304 <memmove+0x28>
 314:	fff6079b          	addiw	a5,a2,-1
 318:	1782                	slli	a5,a5,0x20
 31a:	9381                	srli	a5,a5,0x20
 31c:	fff7c793          	not	a5,a5
 320:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 322:	15fd                	addi	a1,a1,-1
 324:	177d                	addi	a4,a4,-1
 326:	0005c683          	lbu	a3,0(a1)
 32a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 32e:	fee79ae3          	bne	a5,a4,322 <memmove+0x46>
 332:	bfc9                	j	304 <memmove+0x28>

0000000000000334 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 334:	1141                	addi	sp,sp,-16
 336:	e422                	sd	s0,8(sp)
 338:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 33a:	ca05                	beqz	a2,36a <memcmp+0x36>
 33c:	fff6069b          	addiw	a3,a2,-1
 340:	1682                	slli	a3,a3,0x20
 342:	9281                	srli	a3,a3,0x20
 344:	0685                	addi	a3,a3,1
 346:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 348:	00054783          	lbu	a5,0(a0)
 34c:	0005c703          	lbu	a4,0(a1)
 350:	00e79863          	bne	a5,a4,360 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 354:	0505                	addi	a0,a0,1
    p2++;
 356:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 358:	fed518e3          	bne	a0,a3,348 <memcmp+0x14>
  }
  return 0;
 35c:	4501                	li	a0,0
 35e:	a019                	j	364 <memcmp+0x30>
      return *p1 - *p2;
 360:	40e7853b          	subw	a0,a5,a4
}
 364:	6422                	ld	s0,8(sp)
 366:	0141                	addi	sp,sp,16
 368:	8082                	ret
  return 0;
 36a:	4501                	li	a0,0
 36c:	bfe5                	j	364 <memcmp+0x30>

000000000000036e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 36e:	1141                	addi	sp,sp,-16
 370:	e406                	sd	ra,8(sp)
 372:	e022                	sd	s0,0(sp)
 374:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 376:	00000097          	auipc	ra,0x0
 37a:	f66080e7          	jalr	-154(ra) # 2dc <memmove>
}
 37e:	60a2                	ld	ra,8(sp)
 380:	6402                	ld	s0,0(sp)
 382:	0141                	addi	sp,sp,16
 384:	8082                	ret

0000000000000386 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 386:	4885                	li	a7,1
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <exit>:
.global exit
exit:
 li a7, SYS_exit
 38e:	4889                	li	a7,2
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <wait>:
.global wait
wait:
 li a7, SYS_wait
 396:	488d                	li	a7,3
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 39e:	4891                	li	a7,4
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <read>:
.global read
read:
 li a7, SYS_read
 3a6:	4895                	li	a7,5
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <write>:
.global write
write:
 li a7, SYS_write
 3ae:	48c1                	li	a7,16
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <close>:
.global close
close:
 li a7, SYS_close
 3b6:	48d5                	li	a7,21
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <kill>:
.global kill
kill:
 li a7, SYS_kill
 3be:	4899                	li	a7,6
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3c6:	489d                	li	a7,7
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <open>:
.global open
open:
 li a7, SYS_open
 3ce:	48bd                	li	a7,15
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3d6:	48c5                	li	a7,17
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3de:	48c9                	li	a7,18
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3e6:	48a1                	li	a7,8
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <link>:
.global link
link:
 li a7, SYS_link
 3ee:	48cd                	li	a7,19
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3f6:	48d1                	li	a7,20
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3fe:	48a5                	li	a7,9
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <dup>:
.global dup
dup:
 li a7, SYS_dup
 406:	48a9                	li	a7,10
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 40e:	48ad                	li	a7,11
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 416:	48b1                	li	a7,12
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 41e:	48b5                	li	a7,13
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 426:	48b9                	li	a7,14
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <trace>:
.global trace
trace:
 li a7, SYS_trace
 42e:	48d9                	li	a7,22
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 436:	48dd                	li	a7,23
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 43e:	48e1                	li	a7,24
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 446:	1101                	addi	sp,sp,-32
 448:	ec06                	sd	ra,24(sp)
 44a:	e822                	sd	s0,16(sp)
 44c:	1000                	addi	s0,sp,32
 44e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 452:	4605                	li	a2,1
 454:	fef40593          	addi	a1,s0,-17
 458:	00000097          	auipc	ra,0x0
 45c:	f56080e7          	jalr	-170(ra) # 3ae <write>
}
 460:	60e2                	ld	ra,24(sp)
 462:	6442                	ld	s0,16(sp)
 464:	6105                	addi	sp,sp,32
 466:	8082                	ret

0000000000000468 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 468:	7139                	addi	sp,sp,-64
 46a:	fc06                	sd	ra,56(sp)
 46c:	f822                	sd	s0,48(sp)
 46e:	f426                	sd	s1,40(sp)
 470:	f04a                	sd	s2,32(sp)
 472:	ec4e                	sd	s3,24(sp)
 474:	0080                	addi	s0,sp,64
 476:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 478:	c299                	beqz	a3,47e <printint+0x16>
 47a:	0805c963          	bltz	a1,50c <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 47e:	2581                	sext.w	a1,a1
  neg = 0;
 480:	4881                	li	a7,0
 482:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 486:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 488:	2601                	sext.w	a2,a2
 48a:	00000517          	auipc	a0,0x0
 48e:	4fe50513          	addi	a0,a0,1278 # 988 <digits>
 492:	883a                	mv	a6,a4
 494:	2705                	addiw	a4,a4,1
 496:	02c5f7bb          	remuw	a5,a1,a2
 49a:	1782                	slli	a5,a5,0x20
 49c:	9381                	srli	a5,a5,0x20
 49e:	97aa                	add	a5,a5,a0
 4a0:	0007c783          	lbu	a5,0(a5)
 4a4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4a8:	0005879b          	sext.w	a5,a1
 4ac:	02c5d5bb          	divuw	a1,a1,a2
 4b0:	0685                	addi	a3,a3,1
 4b2:	fec7f0e3          	bgeu	a5,a2,492 <printint+0x2a>
  if(neg)
 4b6:	00088c63          	beqz	a7,4ce <printint+0x66>
    buf[i++] = '-';
 4ba:	fd070793          	addi	a5,a4,-48
 4be:	00878733          	add	a4,a5,s0
 4c2:	02d00793          	li	a5,45
 4c6:	fef70823          	sb	a5,-16(a4)
 4ca:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4ce:	02e05863          	blez	a4,4fe <printint+0x96>
 4d2:	fc040793          	addi	a5,s0,-64
 4d6:	00e78933          	add	s2,a5,a4
 4da:	fff78993          	addi	s3,a5,-1
 4de:	99ba                	add	s3,s3,a4
 4e0:	377d                	addiw	a4,a4,-1
 4e2:	1702                	slli	a4,a4,0x20
 4e4:	9301                	srli	a4,a4,0x20
 4e6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4ea:	fff94583          	lbu	a1,-1(s2)
 4ee:	8526                	mv	a0,s1
 4f0:	00000097          	auipc	ra,0x0
 4f4:	f56080e7          	jalr	-170(ra) # 446 <putc>
  while(--i >= 0)
 4f8:	197d                	addi	s2,s2,-1
 4fa:	ff3918e3          	bne	s2,s3,4ea <printint+0x82>
}
 4fe:	70e2                	ld	ra,56(sp)
 500:	7442                	ld	s0,48(sp)
 502:	74a2                	ld	s1,40(sp)
 504:	7902                	ld	s2,32(sp)
 506:	69e2                	ld	s3,24(sp)
 508:	6121                	addi	sp,sp,64
 50a:	8082                	ret
    x = -xx;
 50c:	40b005bb          	negw	a1,a1
    neg = 1;
 510:	4885                	li	a7,1
    x = -xx;
 512:	bf85                	j	482 <printint+0x1a>

0000000000000514 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 514:	715d                	addi	sp,sp,-80
 516:	e486                	sd	ra,72(sp)
 518:	e0a2                	sd	s0,64(sp)
 51a:	fc26                	sd	s1,56(sp)
 51c:	f84a                	sd	s2,48(sp)
 51e:	f44e                	sd	s3,40(sp)
 520:	f052                	sd	s4,32(sp)
 522:	ec56                	sd	s5,24(sp)
 524:	e85a                	sd	s6,16(sp)
 526:	e45e                	sd	s7,8(sp)
 528:	e062                	sd	s8,0(sp)
 52a:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 52c:	0005c903          	lbu	s2,0(a1)
 530:	18090c63          	beqz	s2,6c8 <vprintf+0x1b4>
 534:	8aaa                	mv	s5,a0
 536:	8bb2                	mv	s7,a2
 538:	00158493          	addi	s1,a1,1
  state = 0;
 53c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 53e:	02500a13          	li	s4,37
 542:	4b55                	li	s6,21
 544:	a839                	j	562 <vprintf+0x4e>
        putc(fd, c);
 546:	85ca                	mv	a1,s2
 548:	8556                	mv	a0,s5
 54a:	00000097          	auipc	ra,0x0
 54e:	efc080e7          	jalr	-260(ra) # 446 <putc>
 552:	a019                	j	558 <vprintf+0x44>
    } else if(state == '%'){
 554:	01498d63          	beq	s3,s4,56e <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 558:	0485                	addi	s1,s1,1
 55a:	fff4c903          	lbu	s2,-1(s1)
 55e:	16090563          	beqz	s2,6c8 <vprintf+0x1b4>
    if(state == 0){
 562:	fe0999e3          	bnez	s3,554 <vprintf+0x40>
      if(c == '%'){
 566:	ff4910e3          	bne	s2,s4,546 <vprintf+0x32>
        state = '%';
 56a:	89d2                	mv	s3,s4
 56c:	b7f5                	j	558 <vprintf+0x44>
      if(c == 'd'){
 56e:	13490263          	beq	s2,s4,692 <vprintf+0x17e>
 572:	f9d9079b          	addiw	a5,s2,-99
 576:	0ff7f793          	zext.b	a5,a5
 57a:	12fb6563          	bltu	s6,a5,6a4 <vprintf+0x190>
 57e:	f9d9079b          	addiw	a5,s2,-99
 582:	0ff7f713          	zext.b	a4,a5
 586:	10eb6f63          	bltu	s6,a4,6a4 <vprintf+0x190>
 58a:	00271793          	slli	a5,a4,0x2
 58e:	00000717          	auipc	a4,0x0
 592:	3a270713          	addi	a4,a4,930 # 930 <malloc+0x16a>
 596:	97ba                	add	a5,a5,a4
 598:	439c                	lw	a5,0(a5)
 59a:	97ba                	add	a5,a5,a4
 59c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 59e:	008b8913          	addi	s2,s7,8
 5a2:	4685                	li	a3,1
 5a4:	4629                	li	a2,10
 5a6:	000ba583          	lw	a1,0(s7)
 5aa:	8556                	mv	a0,s5
 5ac:	00000097          	auipc	ra,0x0
 5b0:	ebc080e7          	jalr	-324(ra) # 468 <printint>
 5b4:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5b6:	4981                	li	s3,0
 5b8:	b745                	j	558 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ba:	008b8913          	addi	s2,s7,8
 5be:	4681                	li	a3,0
 5c0:	4629                	li	a2,10
 5c2:	000ba583          	lw	a1,0(s7)
 5c6:	8556                	mv	a0,s5
 5c8:	00000097          	auipc	ra,0x0
 5cc:	ea0080e7          	jalr	-352(ra) # 468 <printint>
 5d0:	8bca                	mv	s7,s2
      state = 0;
 5d2:	4981                	li	s3,0
 5d4:	b751                	j	558 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 5d6:	008b8913          	addi	s2,s7,8
 5da:	4681                	li	a3,0
 5dc:	4641                	li	a2,16
 5de:	000ba583          	lw	a1,0(s7)
 5e2:	8556                	mv	a0,s5
 5e4:	00000097          	auipc	ra,0x0
 5e8:	e84080e7          	jalr	-380(ra) # 468 <printint>
 5ec:	8bca                	mv	s7,s2
      state = 0;
 5ee:	4981                	li	s3,0
 5f0:	b7a5                	j	558 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 5f2:	008b8c13          	addi	s8,s7,8
 5f6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5fa:	03000593          	li	a1,48
 5fe:	8556                	mv	a0,s5
 600:	00000097          	auipc	ra,0x0
 604:	e46080e7          	jalr	-442(ra) # 446 <putc>
  putc(fd, 'x');
 608:	07800593          	li	a1,120
 60c:	8556                	mv	a0,s5
 60e:	00000097          	auipc	ra,0x0
 612:	e38080e7          	jalr	-456(ra) # 446 <putc>
 616:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 618:	00000b97          	auipc	s7,0x0
 61c:	370b8b93          	addi	s7,s7,880 # 988 <digits>
 620:	03c9d793          	srli	a5,s3,0x3c
 624:	97de                	add	a5,a5,s7
 626:	0007c583          	lbu	a1,0(a5)
 62a:	8556                	mv	a0,s5
 62c:	00000097          	auipc	ra,0x0
 630:	e1a080e7          	jalr	-486(ra) # 446 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 634:	0992                	slli	s3,s3,0x4
 636:	397d                	addiw	s2,s2,-1
 638:	fe0914e3          	bnez	s2,620 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 63c:	8be2                	mv	s7,s8
      state = 0;
 63e:	4981                	li	s3,0
 640:	bf21                	j	558 <vprintf+0x44>
        s = va_arg(ap, char*);
 642:	008b8993          	addi	s3,s7,8
 646:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 64a:	02090163          	beqz	s2,66c <vprintf+0x158>
        while(*s != 0){
 64e:	00094583          	lbu	a1,0(s2)
 652:	c9a5                	beqz	a1,6c2 <vprintf+0x1ae>
          putc(fd, *s);
 654:	8556                	mv	a0,s5
 656:	00000097          	auipc	ra,0x0
 65a:	df0080e7          	jalr	-528(ra) # 446 <putc>
          s++;
 65e:	0905                	addi	s2,s2,1
        while(*s != 0){
 660:	00094583          	lbu	a1,0(s2)
 664:	f9e5                	bnez	a1,654 <vprintf+0x140>
        s = va_arg(ap, char*);
 666:	8bce                	mv	s7,s3
      state = 0;
 668:	4981                	li	s3,0
 66a:	b5fd                	j	558 <vprintf+0x44>
          s = "(null)";
 66c:	00000917          	auipc	s2,0x0
 670:	2bc90913          	addi	s2,s2,700 # 928 <malloc+0x162>
        while(*s != 0){
 674:	02800593          	li	a1,40
 678:	bff1                	j	654 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 67a:	008b8913          	addi	s2,s7,8
 67e:	000bc583          	lbu	a1,0(s7)
 682:	8556                	mv	a0,s5
 684:	00000097          	auipc	ra,0x0
 688:	dc2080e7          	jalr	-574(ra) # 446 <putc>
 68c:	8bca                	mv	s7,s2
      state = 0;
 68e:	4981                	li	s3,0
 690:	b5e1                	j	558 <vprintf+0x44>
        putc(fd, c);
 692:	02500593          	li	a1,37
 696:	8556                	mv	a0,s5
 698:	00000097          	auipc	ra,0x0
 69c:	dae080e7          	jalr	-594(ra) # 446 <putc>
      state = 0;
 6a0:	4981                	li	s3,0
 6a2:	bd5d                	j	558 <vprintf+0x44>
        putc(fd, '%');
 6a4:	02500593          	li	a1,37
 6a8:	8556                	mv	a0,s5
 6aa:	00000097          	auipc	ra,0x0
 6ae:	d9c080e7          	jalr	-612(ra) # 446 <putc>
        putc(fd, c);
 6b2:	85ca                	mv	a1,s2
 6b4:	8556                	mv	a0,s5
 6b6:	00000097          	auipc	ra,0x0
 6ba:	d90080e7          	jalr	-624(ra) # 446 <putc>
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	bd61                	j	558 <vprintf+0x44>
        s = va_arg(ap, char*);
 6c2:	8bce                	mv	s7,s3
      state = 0;
 6c4:	4981                	li	s3,0
 6c6:	bd49                	j	558 <vprintf+0x44>
    }
  }
}
 6c8:	60a6                	ld	ra,72(sp)
 6ca:	6406                	ld	s0,64(sp)
 6cc:	74e2                	ld	s1,56(sp)
 6ce:	7942                	ld	s2,48(sp)
 6d0:	79a2                	ld	s3,40(sp)
 6d2:	7a02                	ld	s4,32(sp)
 6d4:	6ae2                	ld	s5,24(sp)
 6d6:	6b42                	ld	s6,16(sp)
 6d8:	6ba2                	ld	s7,8(sp)
 6da:	6c02                	ld	s8,0(sp)
 6dc:	6161                	addi	sp,sp,80
 6de:	8082                	ret

00000000000006e0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6e0:	715d                	addi	sp,sp,-80
 6e2:	ec06                	sd	ra,24(sp)
 6e4:	e822                	sd	s0,16(sp)
 6e6:	1000                	addi	s0,sp,32
 6e8:	e010                	sd	a2,0(s0)
 6ea:	e414                	sd	a3,8(s0)
 6ec:	e818                	sd	a4,16(s0)
 6ee:	ec1c                	sd	a5,24(s0)
 6f0:	03043023          	sd	a6,32(s0)
 6f4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6f8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6fc:	8622                	mv	a2,s0
 6fe:	00000097          	auipc	ra,0x0
 702:	e16080e7          	jalr	-490(ra) # 514 <vprintf>
}
 706:	60e2                	ld	ra,24(sp)
 708:	6442                	ld	s0,16(sp)
 70a:	6161                	addi	sp,sp,80
 70c:	8082                	ret

000000000000070e <printf>:

void
printf(const char *fmt, ...)
{
 70e:	711d                	addi	sp,sp,-96
 710:	ec06                	sd	ra,24(sp)
 712:	e822                	sd	s0,16(sp)
 714:	1000                	addi	s0,sp,32
 716:	e40c                	sd	a1,8(s0)
 718:	e810                	sd	a2,16(s0)
 71a:	ec14                	sd	a3,24(s0)
 71c:	f018                	sd	a4,32(s0)
 71e:	f41c                	sd	a5,40(s0)
 720:	03043823          	sd	a6,48(s0)
 724:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 728:	00840613          	addi	a2,s0,8
 72c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 730:	85aa                	mv	a1,a0
 732:	4505                	li	a0,1
 734:	00000097          	auipc	ra,0x0
 738:	de0080e7          	jalr	-544(ra) # 514 <vprintf>
}
 73c:	60e2                	ld	ra,24(sp)
 73e:	6442                	ld	s0,16(sp)
 740:	6125                	addi	sp,sp,96
 742:	8082                	ret

0000000000000744 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 744:	1141                	addi	sp,sp,-16
 746:	e422                	sd	s0,8(sp)
 748:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 74a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 74e:	00001797          	auipc	a5,0x1
 752:	8b27b783          	ld	a5,-1870(a5) # 1000 <freep>
 756:	a02d                	j	780 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 758:	4618                	lw	a4,8(a2)
 75a:	9f2d                	addw	a4,a4,a1
 75c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 760:	6398                	ld	a4,0(a5)
 762:	6310                	ld	a2,0(a4)
 764:	a83d                	j	7a2 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 766:	ff852703          	lw	a4,-8(a0)
 76a:	9f31                	addw	a4,a4,a2
 76c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 76e:	ff053683          	ld	a3,-16(a0)
 772:	a091                	j	7b6 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 774:	6398                	ld	a4,0(a5)
 776:	00e7e463          	bltu	a5,a4,77e <free+0x3a>
 77a:	00e6ea63          	bltu	a3,a4,78e <free+0x4a>
{
 77e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 780:	fed7fae3          	bgeu	a5,a3,774 <free+0x30>
 784:	6398                	ld	a4,0(a5)
 786:	00e6e463          	bltu	a3,a4,78e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 78a:	fee7eae3          	bltu	a5,a4,77e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 78e:	ff852583          	lw	a1,-8(a0)
 792:	6390                	ld	a2,0(a5)
 794:	02059813          	slli	a6,a1,0x20
 798:	01c85713          	srli	a4,a6,0x1c
 79c:	9736                	add	a4,a4,a3
 79e:	fae60de3          	beq	a2,a4,758 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7a2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7a6:	4790                	lw	a2,8(a5)
 7a8:	02061593          	slli	a1,a2,0x20
 7ac:	01c5d713          	srli	a4,a1,0x1c
 7b0:	973e                	add	a4,a4,a5
 7b2:	fae68ae3          	beq	a3,a4,766 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7b6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7b8:	00001717          	auipc	a4,0x1
 7bc:	84f73423          	sd	a5,-1976(a4) # 1000 <freep>
}
 7c0:	6422                	ld	s0,8(sp)
 7c2:	0141                	addi	sp,sp,16
 7c4:	8082                	ret

00000000000007c6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7c6:	7139                	addi	sp,sp,-64
 7c8:	fc06                	sd	ra,56(sp)
 7ca:	f822                	sd	s0,48(sp)
 7cc:	f426                	sd	s1,40(sp)
 7ce:	f04a                	sd	s2,32(sp)
 7d0:	ec4e                	sd	s3,24(sp)
 7d2:	e852                	sd	s4,16(sp)
 7d4:	e456                	sd	s5,8(sp)
 7d6:	e05a                	sd	s6,0(sp)
 7d8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7da:	02051493          	slli	s1,a0,0x20
 7de:	9081                	srli	s1,s1,0x20
 7e0:	04bd                	addi	s1,s1,15
 7e2:	8091                	srli	s1,s1,0x4
 7e4:	0014899b          	addiw	s3,s1,1
 7e8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7ea:	00001517          	auipc	a0,0x1
 7ee:	81653503          	ld	a0,-2026(a0) # 1000 <freep>
 7f2:	c515                	beqz	a0,81e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7f6:	4798                	lw	a4,8(a5)
 7f8:	02977f63          	bgeu	a4,s1,836 <malloc+0x70>
  if(nu < 4096)
 7fc:	8a4e                	mv	s4,s3
 7fe:	0009871b          	sext.w	a4,s3
 802:	6685                	lui	a3,0x1
 804:	00d77363          	bgeu	a4,a3,80a <malloc+0x44>
 808:	6a05                	lui	s4,0x1
 80a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 80e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 812:	00000917          	auipc	s2,0x0
 816:	7ee90913          	addi	s2,s2,2030 # 1000 <freep>
  if(p == (char*)-1)
 81a:	5afd                	li	s5,-1
 81c:	a895                	j	890 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 81e:	00000797          	auipc	a5,0x0
 822:	7f278793          	addi	a5,a5,2034 # 1010 <base>
 826:	00000717          	auipc	a4,0x0
 82a:	7cf73d23          	sd	a5,2010(a4) # 1000 <freep>
 82e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 830:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 834:	b7e1                	j	7fc <malloc+0x36>
      if(p->s.size == nunits)
 836:	02e48c63          	beq	s1,a4,86e <malloc+0xa8>
        p->s.size -= nunits;
 83a:	4137073b          	subw	a4,a4,s3
 83e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 840:	02071693          	slli	a3,a4,0x20
 844:	01c6d713          	srli	a4,a3,0x1c
 848:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 84a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 84e:	00000717          	auipc	a4,0x0
 852:	7aa73923          	sd	a0,1970(a4) # 1000 <freep>
      return (void*)(p + 1);
 856:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 85a:	70e2                	ld	ra,56(sp)
 85c:	7442                	ld	s0,48(sp)
 85e:	74a2                	ld	s1,40(sp)
 860:	7902                	ld	s2,32(sp)
 862:	69e2                	ld	s3,24(sp)
 864:	6a42                	ld	s4,16(sp)
 866:	6aa2                	ld	s5,8(sp)
 868:	6b02                	ld	s6,0(sp)
 86a:	6121                	addi	sp,sp,64
 86c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 86e:	6398                	ld	a4,0(a5)
 870:	e118                	sd	a4,0(a0)
 872:	bff1                	j	84e <malloc+0x88>
  hp->s.size = nu;
 874:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 878:	0541                	addi	a0,a0,16
 87a:	00000097          	auipc	ra,0x0
 87e:	eca080e7          	jalr	-310(ra) # 744 <free>
  return freep;
 882:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 886:	d971                	beqz	a0,85a <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 888:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 88a:	4798                	lw	a4,8(a5)
 88c:	fa9775e3          	bgeu	a4,s1,836 <malloc+0x70>
    if(p == freep)
 890:	00093703          	ld	a4,0(s2)
 894:	853e                	mv	a0,a5
 896:	fef719e3          	bne	a4,a5,888 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 89a:	8552                	mv	a0,s4
 89c:	00000097          	auipc	ra,0x0
 8a0:	b7a080e7          	jalr	-1158(ra) # 416 <sbrk>
  if(p == (char*)-1)
 8a4:	fd5518e3          	bne	a0,s5,874 <malloc+0xae>
        return 0;
 8a8:	4501                	li	a0,0
 8aa:	bf45                	j	85a <malloc+0x94>
