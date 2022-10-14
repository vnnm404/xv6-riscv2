
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
  10:	84aa                	mv	s1,a0
  12:	8a2e                	mv	s4,a1
  settickets(20);
  14:	4551                	li	a0,20
  16:	00000097          	auipc	ra,0x0
  1a:	43c080e7          	jalr	1084(ra) # 452 <settickets>
  if (argc <= 2) {
  1e:	4789                	li	a5,2
  20:	0497d963          	bge	a5,s1,72 <main+0x72>
    fprintf(2, "strace: insufficient arguments\n");
    exit(1);
  }

  char *mask_str = argv[1];
  24:	008a3903          	ld	s2,8(s4)
  for (int i = 0; i < strlen(mask_str); i++) {
  28:	4481                	li	s1,0
    if (!('0' <= mask_str[i] && mask_str[i] <= '9')) {
  2a:	49a5                	li	s3,9
  for (int i = 0; i < strlen(mask_str); i++) {
  2c:	854a                	mv	a0,s2
  2e:	00000097          	auipc	ra,0x0
  32:	148080e7          	jalr	328(ra) # 176 <strlen>
  36:	2501                	sext.w	a0,a0
  38:	0004879b          	sext.w	a5,s1
  3c:	04a7f963          	bgeu	a5,a0,8e <main+0x8e>
    if (!('0' <= mask_str[i] && mask_str[i] <= '9')) {
  40:	009907b3          	add	a5,s2,s1
  44:	0007c783          	lbu	a5,0(a5)
  48:	fd07879b          	addiw	a5,a5,-48
  4c:	0ff7f793          	zext.b	a5,a5
  50:	0485                	addi	s1,s1,1
  52:	fcf9fde3          	bgeu	s3,a5,2c <main+0x2c>
      fprintf(2, "strace: invalid syscall mask\n");
  56:	00001597          	auipc	a1,0x1
  5a:	89a58593          	addi	a1,a1,-1894 # 8f0 <malloc+0x106>
  5e:	4509                	li	a0,2
  60:	00000097          	auipc	ra,0x0
  64:	6a4080e7          	jalr	1700(ra) # 704 <fprintf>
      exit(1);
  68:	4505                	li	a0,1
  6a:	00000097          	auipc	ra,0x0
  6e:	330080e7          	jalr	816(ra) # 39a <exit>
    fprintf(2, "strace: insufficient arguments\n");
  72:	00001597          	auipc	a1,0x1
  76:	85e58593          	addi	a1,a1,-1954 # 8d0 <malloc+0xe6>
  7a:	4509                	li	a0,2
  7c:	00000097          	auipc	ra,0x0
  80:	688080e7          	jalr	1672(ra) # 704 <fprintf>
    exit(1);
  84:	4505                	li	a0,1
  86:	00000097          	auipc	ra,0x0
  8a:	314080e7          	jalr	788(ra) # 39a <exit>
    }
  }

  int mask = atoi(mask_str);
  8e:	854a                	mv	a0,s2
  90:	00000097          	auipc	ra,0x0
  94:	210080e7          	jalr	528(ra) # 2a0 <atoi>
  98:	84aa                	mv	s1,a0

  int pid = fork();
  9a:	00000097          	auipc	ra,0x0
  9e:	2f8080e7          	jalr	760(ra) # 392 <fork>
  if (pid == -1) {
  a2:	57fd                	li	a5,-1
  a4:	04f50063          	beq	a0,a5,e4 <main+0xe4>
    fprintf(2, "strace: failed to run command\n");
    exit(1);
  }

  if (pid == 0) {
  a8:	ed21                	bnez	a0,100 <main+0x100>
    trace(mask);
  aa:	8526                	mv	a0,s1
  ac:	00000097          	auipc	ra,0x0
  b0:	38e080e7          	jalr	910(ra) # 43a <trace>

    exec(argv[2], argv + 2);
  b4:	010a0593          	addi	a1,s4,16
  b8:	010a3503          	ld	a0,16(s4)
  bc:	00000097          	auipc	ra,0x0
  c0:	316080e7          	jalr	790(ra) # 3d2 <exec>
    fprintf(2, "strace: exec %s failed\n", argv[2]);
  c4:	010a3603          	ld	a2,16(s4)
  c8:	00001597          	auipc	a1,0x1
  cc:	86858593          	addi	a1,a1,-1944 # 930 <malloc+0x146>
  d0:	4509                	li	a0,2
  d2:	00000097          	auipc	ra,0x0
  d6:	632080e7          	jalr	1586(ra) # 704 <fprintf>
    exit(1);
  da:	4505                	li	a0,1
  dc:	00000097          	auipc	ra,0x0
  e0:	2be080e7          	jalr	702(ra) # 39a <exit>
    fprintf(2, "strace: failed to run command\n");
  e4:	00001597          	auipc	a1,0x1
  e8:	82c58593          	addi	a1,a1,-2004 # 910 <malloc+0x126>
  ec:	4509                	li	a0,2
  ee:	00000097          	auipc	ra,0x0
  f2:	616080e7          	jalr	1558(ra) # 704 <fprintf>
    exit(1);
  f6:	4505                	li	a0,1
  f8:	00000097          	auipc	ra,0x0
  fc:	2a2080e7          	jalr	674(ra) # 39a <exit>
  }
  wait(0);
 100:	4501                	li	a0,0
 102:	00000097          	auipc	ra,0x0
 106:	2a0080e7          	jalr	672(ra) # 3a2 <wait>
  exit(0);
 10a:	4501                	li	a0,0
 10c:	00000097          	auipc	ra,0x0
 110:	28e080e7          	jalr	654(ra) # 39a <exit>

0000000000000114 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 114:	1141                	addi	sp,sp,-16
 116:	e406                	sd	ra,8(sp)
 118:	e022                	sd	s0,0(sp)
 11a:	0800                	addi	s0,sp,16
  extern int main();
  main();
 11c:	00000097          	auipc	ra,0x0
 120:	ee4080e7          	jalr	-284(ra) # 0 <main>
  exit(0);
 124:	4501                	li	a0,0
 126:	00000097          	auipc	ra,0x0
 12a:	274080e7          	jalr	628(ra) # 39a <exit>

000000000000012e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 12e:	1141                	addi	sp,sp,-16
 130:	e422                	sd	s0,8(sp)
 132:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 134:	87aa                	mv	a5,a0
 136:	0585                	addi	a1,a1,1
 138:	0785                	addi	a5,a5,1
 13a:	fff5c703          	lbu	a4,-1(a1)
 13e:	fee78fa3          	sb	a4,-1(a5)
 142:	fb75                	bnez	a4,136 <strcpy+0x8>
    ;
  return os;
}
 144:	6422                	ld	s0,8(sp)
 146:	0141                	addi	sp,sp,16
 148:	8082                	ret

000000000000014a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 14a:	1141                	addi	sp,sp,-16
 14c:	e422                	sd	s0,8(sp)
 14e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 150:	00054783          	lbu	a5,0(a0)
 154:	cb91                	beqz	a5,168 <strcmp+0x1e>
 156:	0005c703          	lbu	a4,0(a1)
 15a:	00f71763          	bne	a4,a5,168 <strcmp+0x1e>
    p++, q++;
 15e:	0505                	addi	a0,a0,1
 160:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 162:	00054783          	lbu	a5,0(a0)
 166:	fbe5                	bnez	a5,156 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 168:	0005c503          	lbu	a0,0(a1)
}
 16c:	40a7853b          	subw	a0,a5,a0
 170:	6422                	ld	s0,8(sp)
 172:	0141                	addi	sp,sp,16
 174:	8082                	ret

0000000000000176 <strlen>:

uint
strlen(const char *s)
{
 176:	1141                	addi	sp,sp,-16
 178:	e422                	sd	s0,8(sp)
 17a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 17c:	00054783          	lbu	a5,0(a0)
 180:	cf91                	beqz	a5,19c <strlen+0x26>
 182:	0505                	addi	a0,a0,1
 184:	87aa                	mv	a5,a0
 186:	86be                	mv	a3,a5
 188:	0785                	addi	a5,a5,1
 18a:	fff7c703          	lbu	a4,-1(a5)
 18e:	ff65                	bnez	a4,186 <strlen+0x10>
 190:	40a6853b          	subw	a0,a3,a0
 194:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 196:	6422                	ld	s0,8(sp)
 198:	0141                	addi	sp,sp,16
 19a:	8082                	ret
  for(n = 0; s[n]; n++)
 19c:	4501                	li	a0,0
 19e:	bfe5                	j	196 <strlen+0x20>

00000000000001a0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1a0:	1141                	addi	sp,sp,-16
 1a2:	e422                	sd	s0,8(sp)
 1a4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1a6:	ca19                	beqz	a2,1bc <memset+0x1c>
 1a8:	87aa                	mv	a5,a0
 1aa:	1602                	slli	a2,a2,0x20
 1ac:	9201                	srli	a2,a2,0x20
 1ae:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1b2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1b6:	0785                	addi	a5,a5,1
 1b8:	fee79de3          	bne	a5,a4,1b2 <memset+0x12>
  }
  return dst;
}
 1bc:	6422                	ld	s0,8(sp)
 1be:	0141                	addi	sp,sp,16
 1c0:	8082                	ret

00000000000001c2 <strchr>:

char*
strchr(const char *s, char c)
{
 1c2:	1141                	addi	sp,sp,-16
 1c4:	e422                	sd	s0,8(sp)
 1c6:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1c8:	00054783          	lbu	a5,0(a0)
 1cc:	cb99                	beqz	a5,1e2 <strchr+0x20>
    if(*s == c)
 1ce:	00f58763          	beq	a1,a5,1dc <strchr+0x1a>
  for(; *s; s++)
 1d2:	0505                	addi	a0,a0,1
 1d4:	00054783          	lbu	a5,0(a0)
 1d8:	fbfd                	bnez	a5,1ce <strchr+0xc>
      return (char*)s;
  return 0;
 1da:	4501                	li	a0,0
}
 1dc:	6422                	ld	s0,8(sp)
 1de:	0141                	addi	sp,sp,16
 1e0:	8082                	ret
  return 0;
 1e2:	4501                	li	a0,0
 1e4:	bfe5                	j	1dc <strchr+0x1a>

00000000000001e6 <gets>:

char*
gets(char *buf, int max)
{
 1e6:	711d                	addi	sp,sp,-96
 1e8:	ec86                	sd	ra,88(sp)
 1ea:	e8a2                	sd	s0,80(sp)
 1ec:	e4a6                	sd	s1,72(sp)
 1ee:	e0ca                	sd	s2,64(sp)
 1f0:	fc4e                	sd	s3,56(sp)
 1f2:	f852                	sd	s4,48(sp)
 1f4:	f456                	sd	s5,40(sp)
 1f6:	f05a                	sd	s6,32(sp)
 1f8:	ec5e                	sd	s7,24(sp)
 1fa:	1080                	addi	s0,sp,96
 1fc:	8baa                	mv	s7,a0
 1fe:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 200:	892a                	mv	s2,a0
 202:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 204:	4aa9                	li	s5,10
 206:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 208:	89a6                	mv	s3,s1
 20a:	2485                	addiw	s1,s1,1
 20c:	0344d863          	bge	s1,s4,23c <gets+0x56>
    cc = read(0, &c, 1);
 210:	4605                	li	a2,1
 212:	faf40593          	addi	a1,s0,-81
 216:	4501                	li	a0,0
 218:	00000097          	auipc	ra,0x0
 21c:	19a080e7          	jalr	410(ra) # 3b2 <read>
    if(cc < 1)
 220:	00a05e63          	blez	a0,23c <gets+0x56>
    buf[i++] = c;
 224:	faf44783          	lbu	a5,-81(s0)
 228:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 22c:	01578763          	beq	a5,s5,23a <gets+0x54>
 230:	0905                	addi	s2,s2,1
 232:	fd679be3          	bne	a5,s6,208 <gets+0x22>
  for(i=0; i+1 < max; ){
 236:	89a6                	mv	s3,s1
 238:	a011                	j	23c <gets+0x56>
 23a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 23c:	99de                	add	s3,s3,s7
 23e:	00098023          	sb	zero,0(s3)
  return buf;
}
 242:	855e                	mv	a0,s7
 244:	60e6                	ld	ra,88(sp)
 246:	6446                	ld	s0,80(sp)
 248:	64a6                	ld	s1,72(sp)
 24a:	6906                	ld	s2,64(sp)
 24c:	79e2                	ld	s3,56(sp)
 24e:	7a42                	ld	s4,48(sp)
 250:	7aa2                	ld	s5,40(sp)
 252:	7b02                	ld	s6,32(sp)
 254:	6be2                	ld	s7,24(sp)
 256:	6125                	addi	sp,sp,96
 258:	8082                	ret

000000000000025a <stat>:

int
stat(const char *n, struct stat *st)
{
 25a:	1101                	addi	sp,sp,-32
 25c:	ec06                	sd	ra,24(sp)
 25e:	e822                	sd	s0,16(sp)
 260:	e426                	sd	s1,8(sp)
 262:	e04a                	sd	s2,0(sp)
 264:	1000                	addi	s0,sp,32
 266:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 268:	4581                	li	a1,0
 26a:	00000097          	auipc	ra,0x0
 26e:	170080e7          	jalr	368(ra) # 3da <open>
  if(fd < 0)
 272:	02054563          	bltz	a0,29c <stat+0x42>
 276:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 278:	85ca                	mv	a1,s2
 27a:	00000097          	auipc	ra,0x0
 27e:	178080e7          	jalr	376(ra) # 3f2 <fstat>
 282:	892a                	mv	s2,a0
  close(fd);
 284:	8526                	mv	a0,s1
 286:	00000097          	auipc	ra,0x0
 28a:	13c080e7          	jalr	316(ra) # 3c2 <close>
  return r;
}
 28e:	854a                	mv	a0,s2
 290:	60e2                	ld	ra,24(sp)
 292:	6442                	ld	s0,16(sp)
 294:	64a2                	ld	s1,8(sp)
 296:	6902                	ld	s2,0(sp)
 298:	6105                	addi	sp,sp,32
 29a:	8082                	ret
    return -1;
 29c:	597d                	li	s2,-1
 29e:	bfc5                	j	28e <stat+0x34>

00000000000002a0 <atoi>:

int
atoi(const char *s)
{
 2a0:	1141                	addi	sp,sp,-16
 2a2:	e422                	sd	s0,8(sp)
 2a4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2a6:	00054683          	lbu	a3,0(a0)
 2aa:	fd06879b          	addiw	a5,a3,-48
 2ae:	0ff7f793          	zext.b	a5,a5
 2b2:	4625                	li	a2,9
 2b4:	02f66863          	bltu	a2,a5,2e4 <atoi+0x44>
 2b8:	872a                	mv	a4,a0
  n = 0;
 2ba:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2bc:	0705                	addi	a4,a4,1
 2be:	0025179b          	slliw	a5,a0,0x2
 2c2:	9fa9                	addw	a5,a5,a0
 2c4:	0017979b          	slliw	a5,a5,0x1
 2c8:	9fb5                	addw	a5,a5,a3
 2ca:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2ce:	00074683          	lbu	a3,0(a4)
 2d2:	fd06879b          	addiw	a5,a3,-48
 2d6:	0ff7f793          	zext.b	a5,a5
 2da:	fef671e3          	bgeu	a2,a5,2bc <atoi+0x1c>
  return n;
}
 2de:	6422                	ld	s0,8(sp)
 2e0:	0141                	addi	sp,sp,16
 2e2:	8082                	ret
  n = 0;
 2e4:	4501                	li	a0,0
 2e6:	bfe5                	j	2de <atoi+0x3e>

00000000000002e8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2e8:	1141                	addi	sp,sp,-16
 2ea:	e422                	sd	s0,8(sp)
 2ec:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2ee:	02b57463          	bgeu	a0,a1,316 <memmove+0x2e>
    while(n-- > 0)
 2f2:	00c05f63          	blez	a2,310 <memmove+0x28>
 2f6:	1602                	slli	a2,a2,0x20
 2f8:	9201                	srli	a2,a2,0x20
 2fa:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2fe:	872a                	mv	a4,a0
      *dst++ = *src++;
 300:	0585                	addi	a1,a1,1
 302:	0705                	addi	a4,a4,1
 304:	fff5c683          	lbu	a3,-1(a1)
 308:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 30c:	fee79ae3          	bne	a5,a4,300 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 310:	6422                	ld	s0,8(sp)
 312:	0141                	addi	sp,sp,16
 314:	8082                	ret
    dst += n;
 316:	00c50733          	add	a4,a0,a2
    src += n;
 31a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 31c:	fec05ae3          	blez	a2,310 <memmove+0x28>
 320:	fff6079b          	addiw	a5,a2,-1
 324:	1782                	slli	a5,a5,0x20
 326:	9381                	srli	a5,a5,0x20
 328:	fff7c793          	not	a5,a5
 32c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 32e:	15fd                	addi	a1,a1,-1
 330:	177d                	addi	a4,a4,-1
 332:	0005c683          	lbu	a3,0(a1)
 336:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 33a:	fee79ae3          	bne	a5,a4,32e <memmove+0x46>
 33e:	bfc9                	j	310 <memmove+0x28>

0000000000000340 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 340:	1141                	addi	sp,sp,-16
 342:	e422                	sd	s0,8(sp)
 344:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 346:	ca05                	beqz	a2,376 <memcmp+0x36>
 348:	fff6069b          	addiw	a3,a2,-1
 34c:	1682                	slli	a3,a3,0x20
 34e:	9281                	srli	a3,a3,0x20
 350:	0685                	addi	a3,a3,1
 352:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 354:	00054783          	lbu	a5,0(a0)
 358:	0005c703          	lbu	a4,0(a1)
 35c:	00e79863          	bne	a5,a4,36c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 360:	0505                	addi	a0,a0,1
    p2++;
 362:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 364:	fed518e3          	bne	a0,a3,354 <memcmp+0x14>
  }
  return 0;
 368:	4501                	li	a0,0
 36a:	a019                	j	370 <memcmp+0x30>
      return *p1 - *p2;
 36c:	40e7853b          	subw	a0,a5,a4
}
 370:	6422                	ld	s0,8(sp)
 372:	0141                	addi	sp,sp,16
 374:	8082                	ret
  return 0;
 376:	4501                	li	a0,0
 378:	bfe5                	j	370 <memcmp+0x30>

000000000000037a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 37a:	1141                	addi	sp,sp,-16
 37c:	e406                	sd	ra,8(sp)
 37e:	e022                	sd	s0,0(sp)
 380:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 382:	00000097          	auipc	ra,0x0
 386:	f66080e7          	jalr	-154(ra) # 2e8 <memmove>
}
 38a:	60a2                	ld	ra,8(sp)
 38c:	6402                	ld	s0,0(sp)
 38e:	0141                	addi	sp,sp,16
 390:	8082                	ret

0000000000000392 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 392:	4885                	li	a7,1
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <exit>:
.global exit
exit:
 li a7, SYS_exit
 39a:	4889                	li	a7,2
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3a2:	488d                	li	a7,3
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3aa:	4891                	li	a7,4
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <read>:
.global read
read:
 li a7, SYS_read
 3b2:	4895                	li	a7,5
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <write>:
.global write
write:
 li a7, SYS_write
 3ba:	48c1                	li	a7,16
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <close>:
.global close
close:
 li a7, SYS_close
 3c2:	48d5                	li	a7,21
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <kill>:
.global kill
kill:
 li a7, SYS_kill
 3ca:	4899                	li	a7,6
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3d2:	489d                	li	a7,7
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <open>:
.global open
open:
 li a7, SYS_open
 3da:	48bd                	li	a7,15
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3e2:	48c5                	li	a7,17
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3ea:	48c9                	li	a7,18
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3f2:	48a1                	li	a7,8
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <link>:
.global link
link:
 li a7, SYS_link
 3fa:	48cd                	li	a7,19
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 402:	48d1                	li	a7,20
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 40a:	48a5                	li	a7,9
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <dup>:
.global dup
dup:
 li a7, SYS_dup
 412:	48a9                	li	a7,10
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 41a:	48ad                	li	a7,11
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 422:	48b1                	li	a7,12
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 42a:	48b5                	li	a7,13
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 432:	48b9                	li	a7,14
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <trace>:
.global trace
trace:
 li a7, SYS_trace
 43a:	48d9                	li	a7,22
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 442:	48dd                	li	a7,23
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 44a:	48e1                	li	a7,24
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 452:	48e5                	li	a7,25
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
 45a:	48e9                	li	a7,26
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 462:	48ed                	li	a7,27
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 46a:	1101                	addi	sp,sp,-32
 46c:	ec06                	sd	ra,24(sp)
 46e:	e822                	sd	s0,16(sp)
 470:	1000                	addi	s0,sp,32
 472:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 476:	4605                	li	a2,1
 478:	fef40593          	addi	a1,s0,-17
 47c:	00000097          	auipc	ra,0x0
 480:	f3e080e7          	jalr	-194(ra) # 3ba <write>
}
 484:	60e2                	ld	ra,24(sp)
 486:	6442                	ld	s0,16(sp)
 488:	6105                	addi	sp,sp,32
 48a:	8082                	ret

000000000000048c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 48c:	7139                	addi	sp,sp,-64
 48e:	fc06                	sd	ra,56(sp)
 490:	f822                	sd	s0,48(sp)
 492:	f426                	sd	s1,40(sp)
 494:	f04a                	sd	s2,32(sp)
 496:	ec4e                	sd	s3,24(sp)
 498:	0080                	addi	s0,sp,64
 49a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 49c:	c299                	beqz	a3,4a2 <printint+0x16>
 49e:	0805c963          	bltz	a1,530 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4a2:	2581                	sext.w	a1,a1
  neg = 0;
 4a4:	4881                	li	a7,0
 4a6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4aa:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4ac:	2601                	sext.w	a2,a2
 4ae:	00000517          	auipc	a0,0x0
 4b2:	4fa50513          	addi	a0,a0,1274 # 9a8 <digits>
 4b6:	883a                	mv	a6,a4
 4b8:	2705                	addiw	a4,a4,1
 4ba:	02c5f7bb          	remuw	a5,a1,a2
 4be:	1782                	slli	a5,a5,0x20
 4c0:	9381                	srli	a5,a5,0x20
 4c2:	97aa                	add	a5,a5,a0
 4c4:	0007c783          	lbu	a5,0(a5)
 4c8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4cc:	0005879b          	sext.w	a5,a1
 4d0:	02c5d5bb          	divuw	a1,a1,a2
 4d4:	0685                	addi	a3,a3,1
 4d6:	fec7f0e3          	bgeu	a5,a2,4b6 <printint+0x2a>
  if(neg)
 4da:	00088c63          	beqz	a7,4f2 <printint+0x66>
    buf[i++] = '-';
 4de:	fd070793          	addi	a5,a4,-48
 4e2:	00878733          	add	a4,a5,s0
 4e6:	02d00793          	li	a5,45
 4ea:	fef70823          	sb	a5,-16(a4)
 4ee:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4f2:	02e05863          	blez	a4,522 <printint+0x96>
 4f6:	fc040793          	addi	a5,s0,-64
 4fa:	00e78933          	add	s2,a5,a4
 4fe:	fff78993          	addi	s3,a5,-1
 502:	99ba                	add	s3,s3,a4
 504:	377d                	addiw	a4,a4,-1
 506:	1702                	slli	a4,a4,0x20
 508:	9301                	srli	a4,a4,0x20
 50a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 50e:	fff94583          	lbu	a1,-1(s2)
 512:	8526                	mv	a0,s1
 514:	00000097          	auipc	ra,0x0
 518:	f56080e7          	jalr	-170(ra) # 46a <putc>
  while(--i >= 0)
 51c:	197d                	addi	s2,s2,-1
 51e:	ff3918e3          	bne	s2,s3,50e <printint+0x82>
}
 522:	70e2                	ld	ra,56(sp)
 524:	7442                	ld	s0,48(sp)
 526:	74a2                	ld	s1,40(sp)
 528:	7902                	ld	s2,32(sp)
 52a:	69e2                	ld	s3,24(sp)
 52c:	6121                	addi	sp,sp,64
 52e:	8082                	ret
    x = -xx;
 530:	40b005bb          	negw	a1,a1
    neg = 1;
 534:	4885                	li	a7,1
    x = -xx;
 536:	bf85                	j	4a6 <printint+0x1a>

0000000000000538 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 538:	715d                	addi	sp,sp,-80
 53a:	e486                	sd	ra,72(sp)
 53c:	e0a2                	sd	s0,64(sp)
 53e:	fc26                	sd	s1,56(sp)
 540:	f84a                	sd	s2,48(sp)
 542:	f44e                	sd	s3,40(sp)
 544:	f052                	sd	s4,32(sp)
 546:	ec56                	sd	s5,24(sp)
 548:	e85a                	sd	s6,16(sp)
 54a:	e45e                	sd	s7,8(sp)
 54c:	e062                	sd	s8,0(sp)
 54e:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 550:	0005c903          	lbu	s2,0(a1)
 554:	18090c63          	beqz	s2,6ec <vprintf+0x1b4>
 558:	8aaa                	mv	s5,a0
 55a:	8bb2                	mv	s7,a2
 55c:	00158493          	addi	s1,a1,1
  state = 0;
 560:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 562:	02500a13          	li	s4,37
 566:	4b55                	li	s6,21
 568:	a839                	j	586 <vprintf+0x4e>
        putc(fd, c);
 56a:	85ca                	mv	a1,s2
 56c:	8556                	mv	a0,s5
 56e:	00000097          	auipc	ra,0x0
 572:	efc080e7          	jalr	-260(ra) # 46a <putc>
 576:	a019                	j	57c <vprintf+0x44>
    } else if(state == '%'){
 578:	01498d63          	beq	s3,s4,592 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 57c:	0485                	addi	s1,s1,1
 57e:	fff4c903          	lbu	s2,-1(s1)
 582:	16090563          	beqz	s2,6ec <vprintf+0x1b4>
    if(state == 0){
 586:	fe0999e3          	bnez	s3,578 <vprintf+0x40>
      if(c == '%'){
 58a:	ff4910e3          	bne	s2,s4,56a <vprintf+0x32>
        state = '%';
 58e:	89d2                	mv	s3,s4
 590:	b7f5                	j	57c <vprintf+0x44>
      if(c == 'd'){
 592:	13490263          	beq	s2,s4,6b6 <vprintf+0x17e>
 596:	f9d9079b          	addiw	a5,s2,-99
 59a:	0ff7f793          	zext.b	a5,a5
 59e:	12fb6563          	bltu	s6,a5,6c8 <vprintf+0x190>
 5a2:	f9d9079b          	addiw	a5,s2,-99
 5a6:	0ff7f713          	zext.b	a4,a5
 5aa:	10eb6f63          	bltu	s6,a4,6c8 <vprintf+0x190>
 5ae:	00271793          	slli	a5,a4,0x2
 5b2:	00000717          	auipc	a4,0x0
 5b6:	39e70713          	addi	a4,a4,926 # 950 <malloc+0x166>
 5ba:	97ba                	add	a5,a5,a4
 5bc:	439c                	lw	a5,0(a5)
 5be:	97ba                	add	a5,a5,a4
 5c0:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5c2:	008b8913          	addi	s2,s7,8
 5c6:	4685                	li	a3,1
 5c8:	4629                	li	a2,10
 5ca:	000ba583          	lw	a1,0(s7)
 5ce:	8556                	mv	a0,s5
 5d0:	00000097          	auipc	ra,0x0
 5d4:	ebc080e7          	jalr	-324(ra) # 48c <printint>
 5d8:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5da:	4981                	li	s3,0
 5dc:	b745                	j	57c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5de:	008b8913          	addi	s2,s7,8
 5e2:	4681                	li	a3,0
 5e4:	4629                	li	a2,10
 5e6:	000ba583          	lw	a1,0(s7)
 5ea:	8556                	mv	a0,s5
 5ec:	00000097          	auipc	ra,0x0
 5f0:	ea0080e7          	jalr	-352(ra) # 48c <printint>
 5f4:	8bca                	mv	s7,s2
      state = 0;
 5f6:	4981                	li	s3,0
 5f8:	b751                	j	57c <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 5fa:	008b8913          	addi	s2,s7,8
 5fe:	4681                	li	a3,0
 600:	4641                	li	a2,16
 602:	000ba583          	lw	a1,0(s7)
 606:	8556                	mv	a0,s5
 608:	00000097          	auipc	ra,0x0
 60c:	e84080e7          	jalr	-380(ra) # 48c <printint>
 610:	8bca                	mv	s7,s2
      state = 0;
 612:	4981                	li	s3,0
 614:	b7a5                	j	57c <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 616:	008b8c13          	addi	s8,s7,8
 61a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 61e:	03000593          	li	a1,48
 622:	8556                	mv	a0,s5
 624:	00000097          	auipc	ra,0x0
 628:	e46080e7          	jalr	-442(ra) # 46a <putc>
  putc(fd, 'x');
 62c:	07800593          	li	a1,120
 630:	8556                	mv	a0,s5
 632:	00000097          	auipc	ra,0x0
 636:	e38080e7          	jalr	-456(ra) # 46a <putc>
 63a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 63c:	00000b97          	auipc	s7,0x0
 640:	36cb8b93          	addi	s7,s7,876 # 9a8 <digits>
 644:	03c9d793          	srli	a5,s3,0x3c
 648:	97de                	add	a5,a5,s7
 64a:	0007c583          	lbu	a1,0(a5)
 64e:	8556                	mv	a0,s5
 650:	00000097          	auipc	ra,0x0
 654:	e1a080e7          	jalr	-486(ra) # 46a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 658:	0992                	slli	s3,s3,0x4
 65a:	397d                	addiw	s2,s2,-1
 65c:	fe0914e3          	bnez	s2,644 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 660:	8be2                	mv	s7,s8
      state = 0;
 662:	4981                	li	s3,0
 664:	bf21                	j	57c <vprintf+0x44>
        s = va_arg(ap, char*);
 666:	008b8993          	addi	s3,s7,8
 66a:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 66e:	02090163          	beqz	s2,690 <vprintf+0x158>
        while(*s != 0){
 672:	00094583          	lbu	a1,0(s2)
 676:	c9a5                	beqz	a1,6e6 <vprintf+0x1ae>
          putc(fd, *s);
 678:	8556                	mv	a0,s5
 67a:	00000097          	auipc	ra,0x0
 67e:	df0080e7          	jalr	-528(ra) # 46a <putc>
          s++;
 682:	0905                	addi	s2,s2,1
        while(*s != 0){
 684:	00094583          	lbu	a1,0(s2)
 688:	f9e5                	bnez	a1,678 <vprintf+0x140>
        s = va_arg(ap, char*);
 68a:	8bce                	mv	s7,s3
      state = 0;
 68c:	4981                	li	s3,0
 68e:	b5fd                	j	57c <vprintf+0x44>
          s = "(null)";
 690:	00000917          	auipc	s2,0x0
 694:	2b890913          	addi	s2,s2,696 # 948 <malloc+0x15e>
        while(*s != 0){
 698:	02800593          	li	a1,40
 69c:	bff1                	j	678 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 69e:	008b8913          	addi	s2,s7,8
 6a2:	000bc583          	lbu	a1,0(s7)
 6a6:	8556                	mv	a0,s5
 6a8:	00000097          	auipc	ra,0x0
 6ac:	dc2080e7          	jalr	-574(ra) # 46a <putc>
 6b0:	8bca                	mv	s7,s2
      state = 0;
 6b2:	4981                	li	s3,0
 6b4:	b5e1                	j	57c <vprintf+0x44>
        putc(fd, c);
 6b6:	02500593          	li	a1,37
 6ba:	8556                	mv	a0,s5
 6bc:	00000097          	auipc	ra,0x0
 6c0:	dae080e7          	jalr	-594(ra) # 46a <putc>
      state = 0;
 6c4:	4981                	li	s3,0
 6c6:	bd5d                	j	57c <vprintf+0x44>
        putc(fd, '%');
 6c8:	02500593          	li	a1,37
 6cc:	8556                	mv	a0,s5
 6ce:	00000097          	auipc	ra,0x0
 6d2:	d9c080e7          	jalr	-612(ra) # 46a <putc>
        putc(fd, c);
 6d6:	85ca                	mv	a1,s2
 6d8:	8556                	mv	a0,s5
 6da:	00000097          	auipc	ra,0x0
 6de:	d90080e7          	jalr	-624(ra) # 46a <putc>
      state = 0;
 6e2:	4981                	li	s3,0
 6e4:	bd61                	j	57c <vprintf+0x44>
        s = va_arg(ap, char*);
 6e6:	8bce                	mv	s7,s3
      state = 0;
 6e8:	4981                	li	s3,0
 6ea:	bd49                	j	57c <vprintf+0x44>
    }
  }
}
 6ec:	60a6                	ld	ra,72(sp)
 6ee:	6406                	ld	s0,64(sp)
 6f0:	74e2                	ld	s1,56(sp)
 6f2:	7942                	ld	s2,48(sp)
 6f4:	79a2                	ld	s3,40(sp)
 6f6:	7a02                	ld	s4,32(sp)
 6f8:	6ae2                	ld	s5,24(sp)
 6fa:	6b42                	ld	s6,16(sp)
 6fc:	6ba2                	ld	s7,8(sp)
 6fe:	6c02                	ld	s8,0(sp)
 700:	6161                	addi	sp,sp,80
 702:	8082                	ret

0000000000000704 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 704:	715d                	addi	sp,sp,-80
 706:	ec06                	sd	ra,24(sp)
 708:	e822                	sd	s0,16(sp)
 70a:	1000                	addi	s0,sp,32
 70c:	e010                	sd	a2,0(s0)
 70e:	e414                	sd	a3,8(s0)
 710:	e818                	sd	a4,16(s0)
 712:	ec1c                	sd	a5,24(s0)
 714:	03043023          	sd	a6,32(s0)
 718:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 71c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 720:	8622                	mv	a2,s0
 722:	00000097          	auipc	ra,0x0
 726:	e16080e7          	jalr	-490(ra) # 538 <vprintf>
}
 72a:	60e2                	ld	ra,24(sp)
 72c:	6442                	ld	s0,16(sp)
 72e:	6161                	addi	sp,sp,80
 730:	8082                	ret

0000000000000732 <printf>:

void
printf(const char *fmt, ...)
{
 732:	711d                	addi	sp,sp,-96
 734:	ec06                	sd	ra,24(sp)
 736:	e822                	sd	s0,16(sp)
 738:	1000                	addi	s0,sp,32
 73a:	e40c                	sd	a1,8(s0)
 73c:	e810                	sd	a2,16(s0)
 73e:	ec14                	sd	a3,24(s0)
 740:	f018                	sd	a4,32(s0)
 742:	f41c                	sd	a5,40(s0)
 744:	03043823          	sd	a6,48(s0)
 748:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 74c:	00840613          	addi	a2,s0,8
 750:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 754:	85aa                	mv	a1,a0
 756:	4505                	li	a0,1
 758:	00000097          	auipc	ra,0x0
 75c:	de0080e7          	jalr	-544(ra) # 538 <vprintf>
}
 760:	60e2                	ld	ra,24(sp)
 762:	6442                	ld	s0,16(sp)
 764:	6125                	addi	sp,sp,96
 766:	8082                	ret

0000000000000768 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 768:	1141                	addi	sp,sp,-16
 76a:	e422                	sd	s0,8(sp)
 76c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 76e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 772:	00001797          	auipc	a5,0x1
 776:	88e7b783          	ld	a5,-1906(a5) # 1000 <freep>
 77a:	a02d                	j	7a4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 77c:	4618                	lw	a4,8(a2)
 77e:	9f2d                	addw	a4,a4,a1
 780:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 784:	6398                	ld	a4,0(a5)
 786:	6310                	ld	a2,0(a4)
 788:	a83d                	j	7c6 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 78a:	ff852703          	lw	a4,-8(a0)
 78e:	9f31                	addw	a4,a4,a2
 790:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 792:	ff053683          	ld	a3,-16(a0)
 796:	a091                	j	7da <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 798:	6398                	ld	a4,0(a5)
 79a:	00e7e463          	bltu	a5,a4,7a2 <free+0x3a>
 79e:	00e6ea63          	bltu	a3,a4,7b2 <free+0x4a>
{
 7a2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a4:	fed7fae3          	bgeu	a5,a3,798 <free+0x30>
 7a8:	6398                	ld	a4,0(a5)
 7aa:	00e6e463          	bltu	a3,a4,7b2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ae:	fee7eae3          	bltu	a5,a4,7a2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7b2:	ff852583          	lw	a1,-8(a0)
 7b6:	6390                	ld	a2,0(a5)
 7b8:	02059813          	slli	a6,a1,0x20
 7bc:	01c85713          	srli	a4,a6,0x1c
 7c0:	9736                	add	a4,a4,a3
 7c2:	fae60de3          	beq	a2,a4,77c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7c6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7ca:	4790                	lw	a2,8(a5)
 7cc:	02061593          	slli	a1,a2,0x20
 7d0:	01c5d713          	srli	a4,a1,0x1c
 7d4:	973e                	add	a4,a4,a5
 7d6:	fae68ae3          	beq	a3,a4,78a <free+0x22>
    p->s.ptr = bp->s.ptr;
 7da:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7dc:	00001717          	auipc	a4,0x1
 7e0:	82f73223          	sd	a5,-2012(a4) # 1000 <freep>
}
 7e4:	6422                	ld	s0,8(sp)
 7e6:	0141                	addi	sp,sp,16
 7e8:	8082                	ret

00000000000007ea <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7ea:	7139                	addi	sp,sp,-64
 7ec:	fc06                	sd	ra,56(sp)
 7ee:	f822                	sd	s0,48(sp)
 7f0:	f426                	sd	s1,40(sp)
 7f2:	f04a                	sd	s2,32(sp)
 7f4:	ec4e                	sd	s3,24(sp)
 7f6:	e852                	sd	s4,16(sp)
 7f8:	e456                	sd	s5,8(sp)
 7fa:	e05a                	sd	s6,0(sp)
 7fc:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7fe:	02051493          	slli	s1,a0,0x20
 802:	9081                	srli	s1,s1,0x20
 804:	04bd                	addi	s1,s1,15
 806:	8091                	srli	s1,s1,0x4
 808:	0014899b          	addiw	s3,s1,1
 80c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 80e:	00000517          	auipc	a0,0x0
 812:	7f253503          	ld	a0,2034(a0) # 1000 <freep>
 816:	c515                	beqz	a0,842 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 818:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 81a:	4798                	lw	a4,8(a5)
 81c:	02977f63          	bgeu	a4,s1,85a <malloc+0x70>
  if(nu < 4096)
 820:	8a4e                	mv	s4,s3
 822:	0009871b          	sext.w	a4,s3
 826:	6685                	lui	a3,0x1
 828:	00d77363          	bgeu	a4,a3,82e <malloc+0x44>
 82c:	6a05                	lui	s4,0x1
 82e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 832:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 836:	00000917          	auipc	s2,0x0
 83a:	7ca90913          	addi	s2,s2,1994 # 1000 <freep>
  if(p == (char*)-1)
 83e:	5afd                	li	s5,-1
 840:	a895                	j	8b4 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 842:	00000797          	auipc	a5,0x0
 846:	7ce78793          	addi	a5,a5,1998 # 1010 <base>
 84a:	00000717          	auipc	a4,0x0
 84e:	7af73b23          	sd	a5,1974(a4) # 1000 <freep>
 852:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 854:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 858:	b7e1                	j	820 <malloc+0x36>
      if(p->s.size == nunits)
 85a:	02e48c63          	beq	s1,a4,892 <malloc+0xa8>
        p->s.size -= nunits;
 85e:	4137073b          	subw	a4,a4,s3
 862:	c798                	sw	a4,8(a5)
        p += p->s.size;
 864:	02071693          	slli	a3,a4,0x20
 868:	01c6d713          	srli	a4,a3,0x1c
 86c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 86e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 872:	00000717          	auipc	a4,0x0
 876:	78a73723          	sd	a0,1934(a4) # 1000 <freep>
      return (void*)(p + 1);
 87a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 87e:	70e2                	ld	ra,56(sp)
 880:	7442                	ld	s0,48(sp)
 882:	74a2                	ld	s1,40(sp)
 884:	7902                	ld	s2,32(sp)
 886:	69e2                	ld	s3,24(sp)
 888:	6a42                	ld	s4,16(sp)
 88a:	6aa2                	ld	s5,8(sp)
 88c:	6b02                	ld	s6,0(sp)
 88e:	6121                	addi	sp,sp,64
 890:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 892:	6398                	ld	a4,0(a5)
 894:	e118                	sd	a4,0(a0)
 896:	bff1                	j	872 <malloc+0x88>
  hp->s.size = nu;
 898:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 89c:	0541                	addi	a0,a0,16
 89e:	00000097          	auipc	ra,0x0
 8a2:	eca080e7          	jalr	-310(ra) # 768 <free>
  return freep;
 8a6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8aa:	d971                	beqz	a0,87e <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ac:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ae:	4798                	lw	a4,8(a5)
 8b0:	fa9775e3          	bgeu	a4,s1,85a <malloc+0x70>
    if(p == freep)
 8b4:	00093703          	ld	a4,0(s2)
 8b8:	853e                	mv	a0,a5
 8ba:	fef719e3          	bne	a4,a5,8ac <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 8be:	8552                	mv	a0,s4
 8c0:	00000097          	auipc	ra,0x0
 8c4:	b62080e7          	jalr	-1182(ra) # 422 <sbrk>
  if(p == (char*)-1)
 8c8:	fd5518e3          	bne	a0,s5,898 <malloc+0xae>
        return 0;
 8cc:	4501                	li	a0,0
 8ce:	bf45                	j	87e <malloc+0x94>
