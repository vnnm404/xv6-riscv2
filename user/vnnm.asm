
user/_vnnm:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <f0>:

#define SEC17         100000000000000000L
#define SEC12         1000000000000L
#define SEC9          1000000000L

void f0() {
   0:	1101                	addi	sp,sp,-32
   2:	ec22                	sd	s0,24(sp)
   4:	1000                	addi	s0,sp,32
  for(volatile uint64 i = 0; i < SEC17; i++)
   6:	fe043423          	sd	zero,-24(s0)
   a:	fe843703          	ld	a4,-24(s0)
   e:	00001797          	auipc	a5,0x1
  12:	9627b783          	ld	a5,-1694(a5) # 970 <malloc+0xe6>
  16:	00e7ec63          	bltu	a5,a4,2e <f0+0x2e>
  1a:	873e                	mv	a4,a5
  1c:	fe843783          	ld	a5,-24(s0)
  20:	0785                	addi	a5,a5,1
  22:	fef43423          	sd	a5,-24(s0)
  26:	fe843783          	ld	a5,-24(s0)
  2a:	fef779e3          	bgeu	a4,a5,1c <f0+0x1c>
    ;
}
  2e:	6462                	ld	s0,24(sp)
  30:	6105                	addi	sp,sp,32
  32:	8082                	ret

0000000000000034 <f1>:

void f1() {
  34:	1101                	addi	sp,sp,-32
  36:	ec22                	sd	s0,24(sp)
  38:	1000                	addi	s0,sp,32
  for(volatile uint64 i = 0; i < SEC17; i++)
  3a:	fe043423          	sd	zero,-24(s0)
  3e:	fe843703          	ld	a4,-24(s0)
  42:	00001797          	auipc	a5,0x1
  46:	92e7b783          	ld	a5,-1746(a5) # 970 <malloc+0xe6>
  4a:	00e7ec63          	bltu	a5,a4,62 <f1+0x2e>
  4e:	873e                	mv	a4,a5
  50:	fe843783          	ld	a5,-24(s0)
  54:	0785                	addi	a5,a5,1
  56:	fef43423          	sd	a5,-24(s0)
  5a:	fe843783          	ld	a5,-24(s0)
  5e:	fef779e3          	bgeu	a4,a5,50 <f1+0x1c>
    ;
}
  62:	6462                	ld	s0,24(sp)
  64:	6105                	addi	sp,sp,32
  66:	8082                	ret

0000000000000068 <f2>:

void f2() {
  68:	1101                	addi	sp,sp,-32
  6a:	ec06                	sd	ra,24(sp)
  6c:	e822                	sd	s0,16(sp)
  6e:	1000                	addi	s0,sp,32
  for(volatile uint64 i = 0; i < SEC9; i++)
  70:	fe043023          	sd	zero,-32(s0)
  74:	fe043703          	ld	a4,-32(s0)
  78:	3b9ad7b7          	lui	a5,0x3b9ad
  7c:	9ff78793          	addi	a5,a5,-1537 # 3b9ac9ff <base+0x3b9ab9ef>
  80:	00e7ec63          	bltu	a5,a4,98 <f2+0x30>
  84:	873e                	mv	a4,a5
  86:	fe043783          	ld	a5,-32(s0)
  8a:	0785                	addi	a5,a5,1
  8c:	fef43023          	sd	a5,-32(s0)
  90:	fe043783          	ld	a5,-32(s0)
  94:	fef779e3          	bgeu	a4,a5,86 <f2+0x1e>
    ;
  
  sleep(100);
  98:	06400513          	li	a0,100
  9c:	00000097          	auipc	ra,0x0
  a0:	42e080e7          	jalr	1070(ra) # 4ca <sleep>

  for(volatile uint64 i = 0; i < SEC9; i++)
  a4:	fe043423          	sd	zero,-24(s0)
  a8:	fe843703          	ld	a4,-24(s0)
  ac:	3b9ad7b7          	lui	a5,0x3b9ad
  b0:	9ff78793          	addi	a5,a5,-1537 # 3b9ac9ff <base+0x3b9ab9ef>
  b4:	00e7ec63          	bltu	a5,a4,cc <f2+0x64>
  b8:	873e                	mv	a4,a5
  ba:	fe843783          	ld	a5,-24(s0)
  be:	0785                	addi	a5,a5,1
  c0:	fef43423          	sd	a5,-24(s0)
  c4:	fe843783          	ld	a5,-24(s0)
  c8:	fef779e3          	bgeu	a4,a5,ba <f2+0x52>
    ;
}
  cc:	60e2                	ld	ra,24(sp)
  ce:	6442                	ld	s0,16(sp)
  d0:	6105                	addi	sp,sp,32
  d2:	8082                	ret

00000000000000d4 <f3>:

void f3() {
  d4:	7179                	addi	sp,sp,-48
  d6:	f406                	sd	ra,40(sp)
  d8:	f022                	sd	s0,32(sp)
  da:	ec26                	sd	s1,24(sp)
  dc:	1800                	addi	s0,sp,48
  while (1) {
    for(volatile uint64 i = 0; i < SEC9; i++)
  de:	3b9ad4b7          	lui	s1,0x3b9ad
  e2:	9ff48493          	addi	s1,s1,-1537 # 3b9ac9ff <base+0x3b9ab9ef>
  e6:	fc043823          	sd	zero,-48(s0)
  ea:	fd043783          	ld	a5,-48(s0)
  ee:	00f4eb63          	bltu	s1,a5,104 <f3+0x30>
  f2:	fd043783          	ld	a5,-48(s0)
  f6:	0785                	addi	a5,a5,1
  f8:	fcf43823          	sd	a5,-48(s0)
  fc:	fd043783          	ld	a5,-48(s0)
 100:	fef4f9e3          	bgeu	s1,a5,f2 <f3+0x1e>
      ;
    
    sleep(5);
 104:	4515                	li	a0,5
 106:	00000097          	auipc	ra,0x0
 10a:	3c4080e7          	jalr	964(ra) # 4ca <sleep>

    for(volatile uint64 i = 0; i < SEC9; i++)
 10e:	fc043c23          	sd	zero,-40(s0)
 112:	fd843783          	ld	a5,-40(s0)
 116:	fcf4e8e3          	bltu	s1,a5,e6 <f3+0x12>
 11a:	fd843783          	ld	a5,-40(s0)
 11e:	0785                	addi	a5,a5,1
 120:	fcf43c23          	sd	a5,-40(s0)
 124:	fd843783          	ld	a5,-40(s0)
 128:	fef4f9e3          	bgeu	s1,a5,11a <f3+0x46>
 12c:	bf6d                	j	e6 <f3+0x12>

000000000000012e <f4>:
      ;
  }
}

void f4() {
 12e:	1141                	addi	sp,sp,-16
 130:	e406                	sd	ra,8(sp)
 132:	e022                	sd	s0,0(sp)
 134:	0800                	addi	s0,sp,16
  sleep(100);
 136:	06400513          	li	a0,100
 13a:	00000097          	auipc	ra,0x0
 13e:	390080e7          	jalr	912(ra) # 4ca <sleep>
}
 142:	60a2                	ld	ra,8(sp)
 144:	6402                	ld	s0,0(sp)
 146:	0141                	addi	sp,sp,16
 148:	8082                	ret

000000000000014a <main>:

int main(int agrc, char *argv[]) {
 14a:	1101                	addi	sp,sp,-32
 14c:	ec06                	sd	ra,24(sp)
 14e:	e822                	sd	s0,16(sp)
 150:	e426                	sd	s1,8(sp)
 152:	e04a                	sd	s2,0(sp)
 154:	1000                	addi	s0,sp,32
  for(int i = 0; i < 5; i++) {
 156:	4481                	li	s1,0
 158:	4915                	li	s2,5
    int pid = fork();
 15a:	00000097          	auipc	ra,0x0
 15e:	2d8080e7          	jalr	728(ra) # 432 <fork>
    
    if (pid == 0) {
 162:	c509                	beqz	a0,16c <main+0x22>
  for(int i = 0; i < 5; i++) {
 164:	2485                	addiw	s1,s1,1
 166:	ff249ae3          	bne	s1,s2,15a <main+0x10>

      break;
    }
  }
  // exit(0);
  while(1);
 16a:	a001                	j	16a <main+0x20>
      if (i == 0) f0();
 16c:	cc91                	beqz	s1,188 <main+0x3e>
      if (i == 1) f1();
 16e:	4785                	li	a5,1
 170:	02f48863          	beq	s1,a5,1a0 <main+0x56>
      if (i == 2) f2();
 174:	4789                	li	a5,2
 176:	02f48a63          	beq	s1,a5,1aa <main+0x60>
      if (i == 3) f3();
 17a:	478d                	li	a5,3
 17c:	00f49a63          	bne	s1,a5,190 <main+0x46>
 180:	00000097          	auipc	ra,0x0
 184:	f54080e7          	jalr	-172(ra) # d4 <f3>
      if (i == 0) f0();
 188:	00000097          	auipc	ra,0x0
 18c:	e78080e7          	jalr	-392(ra) # 0 <f0>
      if (i == 4) f4();
 190:	4791                	li	a5,4
 192:	fcf49ce3          	bne	s1,a5,16a <main+0x20>
 196:	00000097          	auipc	ra,0x0
 19a:	f98080e7          	jalr	-104(ra) # 12e <f4>
 19e:	b7f1                	j	16a <main+0x20>
      if (i == 1) f1();
 1a0:	00000097          	auipc	ra,0x0
 1a4:	e94080e7          	jalr	-364(ra) # 34 <f1>
      if (i == 3) f3();
 1a8:	b7e5                	j	190 <main+0x46>
      if (i == 2) f2();
 1aa:	00000097          	auipc	ra,0x0
 1ae:	ebe080e7          	jalr	-322(ra) # 68 <f2>
      if (i == 3) f3();
 1b2:	bff9                	j	190 <main+0x46>

00000000000001b4 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 1b4:	1141                	addi	sp,sp,-16
 1b6:	e406                	sd	ra,8(sp)
 1b8:	e022                	sd	s0,0(sp)
 1ba:	0800                	addi	s0,sp,16
  extern int main();
  main();
 1bc:	00000097          	auipc	ra,0x0
 1c0:	f8e080e7          	jalr	-114(ra) # 14a <main>
  exit(0);
 1c4:	4501                	li	a0,0
 1c6:	00000097          	auipc	ra,0x0
 1ca:	274080e7          	jalr	628(ra) # 43a <exit>

00000000000001ce <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1ce:	1141                	addi	sp,sp,-16
 1d0:	e422                	sd	s0,8(sp)
 1d2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1d4:	87aa                	mv	a5,a0
 1d6:	0585                	addi	a1,a1,1
 1d8:	0785                	addi	a5,a5,1
 1da:	fff5c703          	lbu	a4,-1(a1)
 1de:	fee78fa3          	sb	a4,-1(a5)
 1e2:	fb75                	bnez	a4,1d6 <strcpy+0x8>
    ;
  return os;
}
 1e4:	6422                	ld	s0,8(sp)
 1e6:	0141                	addi	sp,sp,16
 1e8:	8082                	ret

00000000000001ea <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1ea:	1141                	addi	sp,sp,-16
 1ec:	e422                	sd	s0,8(sp)
 1ee:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1f0:	00054783          	lbu	a5,0(a0)
 1f4:	cb91                	beqz	a5,208 <strcmp+0x1e>
 1f6:	0005c703          	lbu	a4,0(a1)
 1fa:	00f71763          	bne	a4,a5,208 <strcmp+0x1e>
    p++, q++;
 1fe:	0505                	addi	a0,a0,1
 200:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 202:	00054783          	lbu	a5,0(a0)
 206:	fbe5                	bnez	a5,1f6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 208:	0005c503          	lbu	a0,0(a1)
}
 20c:	40a7853b          	subw	a0,a5,a0
 210:	6422                	ld	s0,8(sp)
 212:	0141                	addi	sp,sp,16
 214:	8082                	ret

0000000000000216 <strlen>:

uint
strlen(const char *s)
{
 216:	1141                	addi	sp,sp,-16
 218:	e422                	sd	s0,8(sp)
 21a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 21c:	00054783          	lbu	a5,0(a0)
 220:	cf91                	beqz	a5,23c <strlen+0x26>
 222:	0505                	addi	a0,a0,1
 224:	87aa                	mv	a5,a0
 226:	86be                	mv	a3,a5
 228:	0785                	addi	a5,a5,1
 22a:	fff7c703          	lbu	a4,-1(a5)
 22e:	ff65                	bnez	a4,226 <strlen+0x10>
 230:	40a6853b          	subw	a0,a3,a0
 234:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 236:	6422                	ld	s0,8(sp)
 238:	0141                	addi	sp,sp,16
 23a:	8082                	ret
  for(n = 0; s[n]; n++)
 23c:	4501                	li	a0,0
 23e:	bfe5                	j	236 <strlen+0x20>

0000000000000240 <memset>:

void*
memset(void *dst, int c, uint n)
{
 240:	1141                	addi	sp,sp,-16
 242:	e422                	sd	s0,8(sp)
 244:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 246:	ca19                	beqz	a2,25c <memset+0x1c>
 248:	87aa                	mv	a5,a0
 24a:	1602                	slli	a2,a2,0x20
 24c:	9201                	srli	a2,a2,0x20
 24e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 252:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 256:	0785                	addi	a5,a5,1
 258:	fee79de3          	bne	a5,a4,252 <memset+0x12>
  }
  return dst;
}
 25c:	6422                	ld	s0,8(sp)
 25e:	0141                	addi	sp,sp,16
 260:	8082                	ret

0000000000000262 <strchr>:

char*
strchr(const char *s, char c)
{
 262:	1141                	addi	sp,sp,-16
 264:	e422                	sd	s0,8(sp)
 266:	0800                	addi	s0,sp,16
  for(; *s; s++)
 268:	00054783          	lbu	a5,0(a0)
 26c:	cb99                	beqz	a5,282 <strchr+0x20>
    if(*s == c)
 26e:	00f58763          	beq	a1,a5,27c <strchr+0x1a>
  for(; *s; s++)
 272:	0505                	addi	a0,a0,1
 274:	00054783          	lbu	a5,0(a0)
 278:	fbfd                	bnez	a5,26e <strchr+0xc>
      return (char*)s;
  return 0;
 27a:	4501                	li	a0,0
}
 27c:	6422                	ld	s0,8(sp)
 27e:	0141                	addi	sp,sp,16
 280:	8082                	ret
  return 0;
 282:	4501                	li	a0,0
 284:	bfe5                	j	27c <strchr+0x1a>

0000000000000286 <gets>:

char*
gets(char *buf, int max)
{
 286:	711d                	addi	sp,sp,-96
 288:	ec86                	sd	ra,88(sp)
 28a:	e8a2                	sd	s0,80(sp)
 28c:	e4a6                	sd	s1,72(sp)
 28e:	e0ca                	sd	s2,64(sp)
 290:	fc4e                	sd	s3,56(sp)
 292:	f852                	sd	s4,48(sp)
 294:	f456                	sd	s5,40(sp)
 296:	f05a                	sd	s6,32(sp)
 298:	ec5e                	sd	s7,24(sp)
 29a:	1080                	addi	s0,sp,96
 29c:	8baa                	mv	s7,a0
 29e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2a0:	892a                	mv	s2,a0
 2a2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2a4:	4aa9                	li	s5,10
 2a6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2a8:	89a6                	mv	s3,s1
 2aa:	2485                	addiw	s1,s1,1
 2ac:	0344d863          	bge	s1,s4,2dc <gets+0x56>
    cc = read(0, &c, 1);
 2b0:	4605                	li	a2,1
 2b2:	faf40593          	addi	a1,s0,-81
 2b6:	4501                	li	a0,0
 2b8:	00000097          	auipc	ra,0x0
 2bc:	19a080e7          	jalr	410(ra) # 452 <read>
    if(cc < 1)
 2c0:	00a05e63          	blez	a0,2dc <gets+0x56>
    buf[i++] = c;
 2c4:	faf44783          	lbu	a5,-81(s0)
 2c8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2cc:	01578763          	beq	a5,s5,2da <gets+0x54>
 2d0:	0905                	addi	s2,s2,1
 2d2:	fd679be3          	bne	a5,s6,2a8 <gets+0x22>
  for(i=0; i+1 < max; ){
 2d6:	89a6                	mv	s3,s1
 2d8:	a011                	j	2dc <gets+0x56>
 2da:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2dc:	99de                	add	s3,s3,s7
 2de:	00098023          	sb	zero,0(s3)
  return buf;
}
 2e2:	855e                	mv	a0,s7
 2e4:	60e6                	ld	ra,88(sp)
 2e6:	6446                	ld	s0,80(sp)
 2e8:	64a6                	ld	s1,72(sp)
 2ea:	6906                	ld	s2,64(sp)
 2ec:	79e2                	ld	s3,56(sp)
 2ee:	7a42                	ld	s4,48(sp)
 2f0:	7aa2                	ld	s5,40(sp)
 2f2:	7b02                	ld	s6,32(sp)
 2f4:	6be2                	ld	s7,24(sp)
 2f6:	6125                	addi	sp,sp,96
 2f8:	8082                	ret

00000000000002fa <stat>:

int
stat(const char *n, struct stat *st)
{
 2fa:	1101                	addi	sp,sp,-32
 2fc:	ec06                	sd	ra,24(sp)
 2fe:	e822                	sd	s0,16(sp)
 300:	e426                	sd	s1,8(sp)
 302:	e04a                	sd	s2,0(sp)
 304:	1000                	addi	s0,sp,32
 306:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 308:	4581                	li	a1,0
 30a:	00000097          	auipc	ra,0x0
 30e:	170080e7          	jalr	368(ra) # 47a <open>
  if(fd < 0)
 312:	02054563          	bltz	a0,33c <stat+0x42>
 316:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 318:	85ca                	mv	a1,s2
 31a:	00000097          	auipc	ra,0x0
 31e:	178080e7          	jalr	376(ra) # 492 <fstat>
 322:	892a                	mv	s2,a0
  close(fd);
 324:	8526                	mv	a0,s1
 326:	00000097          	auipc	ra,0x0
 32a:	13c080e7          	jalr	316(ra) # 462 <close>
  return r;
}
 32e:	854a                	mv	a0,s2
 330:	60e2                	ld	ra,24(sp)
 332:	6442                	ld	s0,16(sp)
 334:	64a2                	ld	s1,8(sp)
 336:	6902                	ld	s2,0(sp)
 338:	6105                	addi	sp,sp,32
 33a:	8082                	ret
    return -1;
 33c:	597d                	li	s2,-1
 33e:	bfc5                	j	32e <stat+0x34>

0000000000000340 <atoi>:

int
atoi(const char *s)
{
 340:	1141                	addi	sp,sp,-16
 342:	e422                	sd	s0,8(sp)
 344:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 346:	00054683          	lbu	a3,0(a0)
 34a:	fd06879b          	addiw	a5,a3,-48
 34e:	0ff7f793          	zext.b	a5,a5
 352:	4625                	li	a2,9
 354:	02f66863          	bltu	a2,a5,384 <atoi+0x44>
 358:	872a                	mv	a4,a0
  n = 0;
 35a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 35c:	0705                	addi	a4,a4,1
 35e:	0025179b          	slliw	a5,a0,0x2
 362:	9fa9                	addw	a5,a5,a0
 364:	0017979b          	slliw	a5,a5,0x1
 368:	9fb5                	addw	a5,a5,a3
 36a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 36e:	00074683          	lbu	a3,0(a4)
 372:	fd06879b          	addiw	a5,a3,-48
 376:	0ff7f793          	zext.b	a5,a5
 37a:	fef671e3          	bgeu	a2,a5,35c <atoi+0x1c>
  return n;
}
 37e:	6422                	ld	s0,8(sp)
 380:	0141                	addi	sp,sp,16
 382:	8082                	ret
  n = 0;
 384:	4501                	li	a0,0
 386:	bfe5                	j	37e <atoi+0x3e>

0000000000000388 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 388:	1141                	addi	sp,sp,-16
 38a:	e422                	sd	s0,8(sp)
 38c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 38e:	02b57463          	bgeu	a0,a1,3b6 <memmove+0x2e>
    while(n-- > 0)
 392:	00c05f63          	blez	a2,3b0 <memmove+0x28>
 396:	1602                	slli	a2,a2,0x20
 398:	9201                	srli	a2,a2,0x20
 39a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 39e:	872a                	mv	a4,a0
      *dst++ = *src++;
 3a0:	0585                	addi	a1,a1,1
 3a2:	0705                	addi	a4,a4,1
 3a4:	fff5c683          	lbu	a3,-1(a1)
 3a8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3ac:	fee79ae3          	bne	a5,a4,3a0 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3b0:	6422                	ld	s0,8(sp)
 3b2:	0141                	addi	sp,sp,16
 3b4:	8082                	ret
    dst += n;
 3b6:	00c50733          	add	a4,a0,a2
    src += n;
 3ba:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3bc:	fec05ae3          	blez	a2,3b0 <memmove+0x28>
 3c0:	fff6079b          	addiw	a5,a2,-1
 3c4:	1782                	slli	a5,a5,0x20
 3c6:	9381                	srli	a5,a5,0x20
 3c8:	fff7c793          	not	a5,a5
 3cc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3ce:	15fd                	addi	a1,a1,-1
 3d0:	177d                	addi	a4,a4,-1
 3d2:	0005c683          	lbu	a3,0(a1)
 3d6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3da:	fee79ae3          	bne	a5,a4,3ce <memmove+0x46>
 3de:	bfc9                	j	3b0 <memmove+0x28>

00000000000003e0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3e0:	1141                	addi	sp,sp,-16
 3e2:	e422                	sd	s0,8(sp)
 3e4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3e6:	ca05                	beqz	a2,416 <memcmp+0x36>
 3e8:	fff6069b          	addiw	a3,a2,-1
 3ec:	1682                	slli	a3,a3,0x20
 3ee:	9281                	srli	a3,a3,0x20
 3f0:	0685                	addi	a3,a3,1
 3f2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3f4:	00054783          	lbu	a5,0(a0)
 3f8:	0005c703          	lbu	a4,0(a1)
 3fc:	00e79863          	bne	a5,a4,40c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 400:	0505                	addi	a0,a0,1
    p2++;
 402:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 404:	fed518e3          	bne	a0,a3,3f4 <memcmp+0x14>
  }
  return 0;
 408:	4501                	li	a0,0
 40a:	a019                	j	410 <memcmp+0x30>
      return *p1 - *p2;
 40c:	40e7853b          	subw	a0,a5,a4
}
 410:	6422                	ld	s0,8(sp)
 412:	0141                	addi	sp,sp,16
 414:	8082                	ret
  return 0;
 416:	4501                	li	a0,0
 418:	bfe5                	j	410 <memcmp+0x30>

000000000000041a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 41a:	1141                	addi	sp,sp,-16
 41c:	e406                	sd	ra,8(sp)
 41e:	e022                	sd	s0,0(sp)
 420:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 422:	00000097          	auipc	ra,0x0
 426:	f66080e7          	jalr	-154(ra) # 388 <memmove>
}
 42a:	60a2                	ld	ra,8(sp)
 42c:	6402                	ld	s0,0(sp)
 42e:	0141                	addi	sp,sp,16
 430:	8082                	ret

0000000000000432 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 432:	4885                	li	a7,1
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <exit>:
.global exit
exit:
 li a7, SYS_exit
 43a:	4889                	li	a7,2
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <wait>:
.global wait
wait:
 li a7, SYS_wait
 442:	488d                	li	a7,3
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 44a:	4891                	li	a7,4
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <read>:
.global read
read:
 li a7, SYS_read
 452:	4895                	li	a7,5
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <write>:
.global write
write:
 li a7, SYS_write
 45a:	48c1                	li	a7,16
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <close>:
.global close
close:
 li a7, SYS_close
 462:	48d5                	li	a7,21
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <kill>:
.global kill
kill:
 li a7, SYS_kill
 46a:	4899                	li	a7,6
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <exec>:
.global exec
exec:
 li a7, SYS_exec
 472:	489d                	li	a7,7
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <open>:
.global open
open:
 li a7, SYS_open
 47a:	48bd                	li	a7,15
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 482:	48c5                	li	a7,17
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 48a:	48c9                	li	a7,18
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 492:	48a1                	li	a7,8
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <link>:
.global link
link:
 li a7, SYS_link
 49a:	48cd                	li	a7,19
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4a2:	48d1                	li	a7,20
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4aa:	48a5                	li	a7,9
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4b2:	48a9                	li	a7,10
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4ba:	48ad                	li	a7,11
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4c2:	48b1                	li	a7,12
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4ca:	48b5                	li	a7,13
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4d2:	48b9                	li	a7,14
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <trace>:
.global trace
trace:
 li a7, SYS_trace
 4da:	48d9                	li	a7,22
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 4e2:	48dd                	li	a7,23
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 4ea:	48e1                	li	a7,24
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 4f2:	48e5                	li	a7,25
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
 4fa:	48e9                	li	a7,26
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 502:	48ed                	li	a7,27
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 50a:	1101                	addi	sp,sp,-32
 50c:	ec06                	sd	ra,24(sp)
 50e:	e822                	sd	s0,16(sp)
 510:	1000                	addi	s0,sp,32
 512:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 516:	4605                	li	a2,1
 518:	fef40593          	addi	a1,s0,-17
 51c:	00000097          	auipc	ra,0x0
 520:	f3e080e7          	jalr	-194(ra) # 45a <write>
}
 524:	60e2                	ld	ra,24(sp)
 526:	6442                	ld	s0,16(sp)
 528:	6105                	addi	sp,sp,32
 52a:	8082                	ret

000000000000052c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 52c:	7139                	addi	sp,sp,-64
 52e:	fc06                	sd	ra,56(sp)
 530:	f822                	sd	s0,48(sp)
 532:	f426                	sd	s1,40(sp)
 534:	f04a                	sd	s2,32(sp)
 536:	ec4e                	sd	s3,24(sp)
 538:	0080                	addi	s0,sp,64
 53a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 53c:	c299                	beqz	a3,542 <printint+0x16>
 53e:	0805c963          	bltz	a1,5d0 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 542:	2581                	sext.w	a1,a1
  neg = 0;
 544:	4881                	li	a7,0
 546:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 54a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 54c:	2601                	sext.w	a2,a2
 54e:	00000517          	auipc	a0,0x0
 552:	49250513          	addi	a0,a0,1170 # 9e0 <digits>
 556:	883a                	mv	a6,a4
 558:	2705                	addiw	a4,a4,1
 55a:	02c5f7bb          	remuw	a5,a1,a2
 55e:	1782                	slli	a5,a5,0x20
 560:	9381                	srli	a5,a5,0x20
 562:	97aa                	add	a5,a5,a0
 564:	0007c783          	lbu	a5,0(a5)
 568:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 56c:	0005879b          	sext.w	a5,a1
 570:	02c5d5bb          	divuw	a1,a1,a2
 574:	0685                	addi	a3,a3,1
 576:	fec7f0e3          	bgeu	a5,a2,556 <printint+0x2a>
  if(neg)
 57a:	00088c63          	beqz	a7,592 <printint+0x66>
    buf[i++] = '-';
 57e:	fd070793          	addi	a5,a4,-48
 582:	00878733          	add	a4,a5,s0
 586:	02d00793          	li	a5,45
 58a:	fef70823          	sb	a5,-16(a4)
 58e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 592:	02e05863          	blez	a4,5c2 <printint+0x96>
 596:	fc040793          	addi	a5,s0,-64
 59a:	00e78933          	add	s2,a5,a4
 59e:	fff78993          	addi	s3,a5,-1
 5a2:	99ba                	add	s3,s3,a4
 5a4:	377d                	addiw	a4,a4,-1
 5a6:	1702                	slli	a4,a4,0x20
 5a8:	9301                	srli	a4,a4,0x20
 5aa:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5ae:	fff94583          	lbu	a1,-1(s2)
 5b2:	8526                	mv	a0,s1
 5b4:	00000097          	auipc	ra,0x0
 5b8:	f56080e7          	jalr	-170(ra) # 50a <putc>
  while(--i >= 0)
 5bc:	197d                	addi	s2,s2,-1
 5be:	ff3918e3          	bne	s2,s3,5ae <printint+0x82>
}
 5c2:	70e2                	ld	ra,56(sp)
 5c4:	7442                	ld	s0,48(sp)
 5c6:	74a2                	ld	s1,40(sp)
 5c8:	7902                	ld	s2,32(sp)
 5ca:	69e2                	ld	s3,24(sp)
 5cc:	6121                	addi	sp,sp,64
 5ce:	8082                	ret
    x = -xx;
 5d0:	40b005bb          	negw	a1,a1
    neg = 1;
 5d4:	4885                	li	a7,1
    x = -xx;
 5d6:	bf85                	j	546 <printint+0x1a>

00000000000005d8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5d8:	715d                	addi	sp,sp,-80
 5da:	e486                	sd	ra,72(sp)
 5dc:	e0a2                	sd	s0,64(sp)
 5de:	fc26                	sd	s1,56(sp)
 5e0:	f84a                	sd	s2,48(sp)
 5e2:	f44e                	sd	s3,40(sp)
 5e4:	f052                	sd	s4,32(sp)
 5e6:	ec56                	sd	s5,24(sp)
 5e8:	e85a                	sd	s6,16(sp)
 5ea:	e45e                	sd	s7,8(sp)
 5ec:	e062                	sd	s8,0(sp)
 5ee:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5f0:	0005c903          	lbu	s2,0(a1)
 5f4:	18090c63          	beqz	s2,78c <vprintf+0x1b4>
 5f8:	8aaa                	mv	s5,a0
 5fa:	8bb2                	mv	s7,a2
 5fc:	00158493          	addi	s1,a1,1
  state = 0;
 600:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 602:	02500a13          	li	s4,37
 606:	4b55                	li	s6,21
 608:	a839                	j	626 <vprintf+0x4e>
        putc(fd, c);
 60a:	85ca                	mv	a1,s2
 60c:	8556                	mv	a0,s5
 60e:	00000097          	auipc	ra,0x0
 612:	efc080e7          	jalr	-260(ra) # 50a <putc>
 616:	a019                	j	61c <vprintf+0x44>
    } else if(state == '%'){
 618:	01498d63          	beq	s3,s4,632 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 61c:	0485                	addi	s1,s1,1
 61e:	fff4c903          	lbu	s2,-1(s1)
 622:	16090563          	beqz	s2,78c <vprintf+0x1b4>
    if(state == 0){
 626:	fe0999e3          	bnez	s3,618 <vprintf+0x40>
      if(c == '%'){
 62a:	ff4910e3          	bne	s2,s4,60a <vprintf+0x32>
        state = '%';
 62e:	89d2                	mv	s3,s4
 630:	b7f5                	j	61c <vprintf+0x44>
      if(c == 'd'){
 632:	13490263          	beq	s2,s4,756 <vprintf+0x17e>
 636:	f9d9079b          	addiw	a5,s2,-99
 63a:	0ff7f793          	zext.b	a5,a5
 63e:	12fb6563          	bltu	s6,a5,768 <vprintf+0x190>
 642:	f9d9079b          	addiw	a5,s2,-99
 646:	0ff7f713          	zext.b	a4,a5
 64a:	10eb6f63          	bltu	s6,a4,768 <vprintf+0x190>
 64e:	00271793          	slli	a5,a4,0x2
 652:	00000717          	auipc	a4,0x0
 656:	33670713          	addi	a4,a4,822 # 988 <malloc+0xfe>
 65a:	97ba                	add	a5,a5,a4
 65c:	439c                	lw	a5,0(a5)
 65e:	97ba                	add	a5,a5,a4
 660:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 662:	008b8913          	addi	s2,s7,8
 666:	4685                	li	a3,1
 668:	4629                	li	a2,10
 66a:	000ba583          	lw	a1,0(s7)
 66e:	8556                	mv	a0,s5
 670:	00000097          	auipc	ra,0x0
 674:	ebc080e7          	jalr	-324(ra) # 52c <printint>
 678:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 67a:	4981                	li	s3,0
 67c:	b745                	j	61c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 67e:	008b8913          	addi	s2,s7,8
 682:	4681                	li	a3,0
 684:	4629                	li	a2,10
 686:	000ba583          	lw	a1,0(s7)
 68a:	8556                	mv	a0,s5
 68c:	00000097          	auipc	ra,0x0
 690:	ea0080e7          	jalr	-352(ra) # 52c <printint>
 694:	8bca                	mv	s7,s2
      state = 0;
 696:	4981                	li	s3,0
 698:	b751                	j	61c <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 69a:	008b8913          	addi	s2,s7,8
 69e:	4681                	li	a3,0
 6a0:	4641                	li	a2,16
 6a2:	000ba583          	lw	a1,0(s7)
 6a6:	8556                	mv	a0,s5
 6a8:	00000097          	auipc	ra,0x0
 6ac:	e84080e7          	jalr	-380(ra) # 52c <printint>
 6b0:	8bca                	mv	s7,s2
      state = 0;
 6b2:	4981                	li	s3,0
 6b4:	b7a5                	j	61c <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 6b6:	008b8c13          	addi	s8,s7,8
 6ba:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6be:	03000593          	li	a1,48
 6c2:	8556                	mv	a0,s5
 6c4:	00000097          	auipc	ra,0x0
 6c8:	e46080e7          	jalr	-442(ra) # 50a <putc>
  putc(fd, 'x');
 6cc:	07800593          	li	a1,120
 6d0:	8556                	mv	a0,s5
 6d2:	00000097          	auipc	ra,0x0
 6d6:	e38080e7          	jalr	-456(ra) # 50a <putc>
 6da:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6dc:	00000b97          	auipc	s7,0x0
 6e0:	304b8b93          	addi	s7,s7,772 # 9e0 <digits>
 6e4:	03c9d793          	srli	a5,s3,0x3c
 6e8:	97de                	add	a5,a5,s7
 6ea:	0007c583          	lbu	a1,0(a5)
 6ee:	8556                	mv	a0,s5
 6f0:	00000097          	auipc	ra,0x0
 6f4:	e1a080e7          	jalr	-486(ra) # 50a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6f8:	0992                	slli	s3,s3,0x4
 6fa:	397d                	addiw	s2,s2,-1
 6fc:	fe0914e3          	bnez	s2,6e4 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 700:	8be2                	mv	s7,s8
      state = 0;
 702:	4981                	li	s3,0
 704:	bf21                	j	61c <vprintf+0x44>
        s = va_arg(ap, char*);
 706:	008b8993          	addi	s3,s7,8
 70a:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 70e:	02090163          	beqz	s2,730 <vprintf+0x158>
        while(*s != 0){
 712:	00094583          	lbu	a1,0(s2)
 716:	c9a5                	beqz	a1,786 <vprintf+0x1ae>
          putc(fd, *s);
 718:	8556                	mv	a0,s5
 71a:	00000097          	auipc	ra,0x0
 71e:	df0080e7          	jalr	-528(ra) # 50a <putc>
          s++;
 722:	0905                	addi	s2,s2,1
        while(*s != 0){
 724:	00094583          	lbu	a1,0(s2)
 728:	f9e5                	bnez	a1,718 <vprintf+0x140>
        s = va_arg(ap, char*);
 72a:	8bce                	mv	s7,s3
      state = 0;
 72c:	4981                	li	s3,0
 72e:	b5fd                	j	61c <vprintf+0x44>
          s = "(null)";
 730:	00000917          	auipc	s2,0x0
 734:	25090913          	addi	s2,s2,592 # 980 <malloc+0xf6>
        while(*s != 0){
 738:	02800593          	li	a1,40
 73c:	bff1                	j	718 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 73e:	008b8913          	addi	s2,s7,8
 742:	000bc583          	lbu	a1,0(s7)
 746:	8556                	mv	a0,s5
 748:	00000097          	auipc	ra,0x0
 74c:	dc2080e7          	jalr	-574(ra) # 50a <putc>
 750:	8bca                	mv	s7,s2
      state = 0;
 752:	4981                	li	s3,0
 754:	b5e1                	j	61c <vprintf+0x44>
        putc(fd, c);
 756:	02500593          	li	a1,37
 75a:	8556                	mv	a0,s5
 75c:	00000097          	auipc	ra,0x0
 760:	dae080e7          	jalr	-594(ra) # 50a <putc>
      state = 0;
 764:	4981                	li	s3,0
 766:	bd5d                	j	61c <vprintf+0x44>
        putc(fd, '%');
 768:	02500593          	li	a1,37
 76c:	8556                	mv	a0,s5
 76e:	00000097          	auipc	ra,0x0
 772:	d9c080e7          	jalr	-612(ra) # 50a <putc>
        putc(fd, c);
 776:	85ca                	mv	a1,s2
 778:	8556                	mv	a0,s5
 77a:	00000097          	auipc	ra,0x0
 77e:	d90080e7          	jalr	-624(ra) # 50a <putc>
      state = 0;
 782:	4981                	li	s3,0
 784:	bd61                	j	61c <vprintf+0x44>
        s = va_arg(ap, char*);
 786:	8bce                	mv	s7,s3
      state = 0;
 788:	4981                	li	s3,0
 78a:	bd49                	j	61c <vprintf+0x44>
    }
  }
}
 78c:	60a6                	ld	ra,72(sp)
 78e:	6406                	ld	s0,64(sp)
 790:	74e2                	ld	s1,56(sp)
 792:	7942                	ld	s2,48(sp)
 794:	79a2                	ld	s3,40(sp)
 796:	7a02                	ld	s4,32(sp)
 798:	6ae2                	ld	s5,24(sp)
 79a:	6b42                	ld	s6,16(sp)
 79c:	6ba2                	ld	s7,8(sp)
 79e:	6c02                	ld	s8,0(sp)
 7a0:	6161                	addi	sp,sp,80
 7a2:	8082                	ret

00000000000007a4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7a4:	715d                	addi	sp,sp,-80
 7a6:	ec06                	sd	ra,24(sp)
 7a8:	e822                	sd	s0,16(sp)
 7aa:	1000                	addi	s0,sp,32
 7ac:	e010                	sd	a2,0(s0)
 7ae:	e414                	sd	a3,8(s0)
 7b0:	e818                	sd	a4,16(s0)
 7b2:	ec1c                	sd	a5,24(s0)
 7b4:	03043023          	sd	a6,32(s0)
 7b8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7bc:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7c0:	8622                	mv	a2,s0
 7c2:	00000097          	auipc	ra,0x0
 7c6:	e16080e7          	jalr	-490(ra) # 5d8 <vprintf>
}
 7ca:	60e2                	ld	ra,24(sp)
 7cc:	6442                	ld	s0,16(sp)
 7ce:	6161                	addi	sp,sp,80
 7d0:	8082                	ret

00000000000007d2 <printf>:

void
printf(const char *fmt, ...)
{
 7d2:	711d                	addi	sp,sp,-96
 7d4:	ec06                	sd	ra,24(sp)
 7d6:	e822                	sd	s0,16(sp)
 7d8:	1000                	addi	s0,sp,32
 7da:	e40c                	sd	a1,8(s0)
 7dc:	e810                	sd	a2,16(s0)
 7de:	ec14                	sd	a3,24(s0)
 7e0:	f018                	sd	a4,32(s0)
 7e2:	f41c                	sd	a5,40(s0)
 7e4:	03043823          	sd	a6,48(s0)
 7e8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ec:	00840613          	addi	a2,s0,8
 7f0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7f4:	85aa                	mv	a1,a0
 7f6:	4505                	li	a0,1
 7f8:	00000097          	auipc	ra,0x0
 7fc:	de0080e7          	jalr	-544(ra) # 5d8 <vprintf>
}
 800:	60e2                	ld	ra,24(sp)
 802:	6442                	ld	s0,16(sp)
 804:	6125                	addi	sp,sp,96
 806:	8082                	ret

0000000000000808 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 808:	1141                	addi	sp,sp,-16
 80a:	e422                	sd	s0,8(sp)
 80c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 80e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 812:	00000797          	auipc	a5,0x0
 816:	7ee7b783          	ld	a5,2030(a5) # 1000 <freep>
 81a:	a02d                	j	844 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 81c:	4618                	lw	a4,8(a2)
 81e:	9f2d                	addw	a4,a4,a1
 820:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 824:	6398                	ld	a4,0(a5)
 826:	6310                	ld	a2,0(a4)
 828:	a83d                	j	866 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 82a:	ff852703          	lw	a4,-8(a0)
 82e:	9f31                	addw	a4,a4,a2
 830:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 832:	ff053683          	ld	a3,-16(a0)
 836:	a091                	j	87a <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 838:	6398                	ld	a4,0(a5)
 83a:	00e7e463          	bltu	a5,a4,842 <free+0x3a>
 83e:	00e6ea63          	bltu	a3,a4,852 <free+0x4a>
{
 842:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 844:	fed7fae3          	bgeu	a5,a3,838 <free+0x30>
 848:	6398                	ld	a4,0(a5)
 84a:	00e6e463          	bltu	a3,a4,852 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 84e:	fee7eae3          	bltu	a5,a4,842 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 852:	ff852583          	lw	a1,-8(a0)
 856:	6390                	ld	a2,0(a5)
 858:	02059813          	slli	a6,a1,0x20
 85c:	01c85713          	srli	a4,a6,0x1c
 860:	9736                	add	a4,a4,a3
 862:	fae60de3          	beq	a2,a4,81c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 866:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 86a:	4790                	lw	a2,8(a5)
 86c:	02061593          	slli	a1,a2,0x20
 870:	01c5d713          	srli	a4,a1,0x1c
 874:	973e                	add	a4,a4,a5
 876:	fae68ae3          	beq	a3,a4,82a <free+0x22>
    p->s.ptr = bp->s.ptr;
 87a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 87c:	00000717          	auipc	a4,0x0
 880:	78f73223          	sd	a5,1924(a4) # 1000 <freep>
}
 884:	6422                	ld	s0,8(sp)
 886:	0141                	addi	sp,sp,16
 888:	8082                	ret

000000000000088a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 88a:	7139                	addi	sp,sp,-64
 88c:	fc06                	sd	ra,56(sp)
 88e:	f822                	sd	s0,48(sp)
 890:	f426                	sd	s1,40(sp)
 892:	f04a                	sd	s2,32(sp)
 894:	ec4e                	sd	s3,24(sp)
 896:	e852                	sd	s4,16(sp)
 898:	e456                	sd	s5,8(sp)
 89a:	e05a                	sd	s6,0(sp)
 89c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 89e:	02051493          	slli	s1,a0,0x20
 8a2:	9081                	srli	s1,s1,0x20
 8a4:	04bd                	addi	s1,s1,15
 8a6:	8091                	srli	s1,s1,0x4
 8a8:	0014899b          	addiw	s3,s1,1
 8ac:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8ae:	00000517          	auipc	a0,0x0
 8b2:	75253503          	ld	a0,1874(a0) # 1000 <freep>
 8b6:	c515                	beqz	a0,8e2 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ba:	4798                	lw	a4,8(a5)
 8bc:	02977f63          	bgeu	a4,s1,8fa <malloc+0x70>
  if(nu < 4096)
 8c0:	8a4e                	mv	s4,s3
 8c2:	0009871b          	sext.w	a4,s3
 8c6:	6685                	lui	a3,0x1
 8c8:	00d77363          	bgeu	a4,a3,8ce <malloc+0x44>
 8cc:	6a05                	lui	s4,0x1
 8ce:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8d2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8d6:	00000917          	auipc	s2,0x0
 8da:	72a90913          	addi	s2,s2,1834 # 1000 <freep>
  if(p == (char*)-1)
 8de:	5afd                	li	s5,-1
 8e0:	a895                	j	954 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 8e2:	00000797          	auipc	a5,0x0
 8e6:	72e78793          	addi	a5,a5,1838 # 1010 <base>
 8ea:	00000717          	auipc	a4,0x0
 8ee:	70f73b23          	sd	a5,1814(a4) # 1000 <freep>
 8f2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8f4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8f8:	b7e1                	j	8c0 <malloc+0x36>
      if(p->s.size == nunits)
 8fa:	02e48c63          	beq	s1,a4,932 <malloc+0xa8>
        p->s.size -= nunits;
 8fe:	4137073b          	subw	a4,a4,s3
 902:	c798                	sw	a4,8(a5)
        p += p->s.size;
 904:	02071693          	slli	a3,a4,0x20
 908:	01c6d713          	srli	a4,a3,0x1c
 90c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 90e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 912:	00000717          	auipc	a4,0x0
 916:	6ea73723          	sd	a0,1774(a4) # 1000 <freep>
      return (void*)(p + 1);
 91a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 91e:	70e2                	ld	ra,56(sp)
 920:	7442                	ld	s0,48(sp)
 922:	74a2                	ld	s1,40(sp)
 924:	7902                	ld	s2,32(sp)
 926:	69e2                	ld	s3,24(sp)
 928:	6a42                	ld	s4,16(sp)
 92a:	6aa2                	ld	s5,8(sp)
 92c:	6b02                	ld	s6,0(sp)
 92e:	6121                	addi	sp,sp,64
 930:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 932:	6398                	ld	a4,0(a5)
 934:	e118                	sd	a4,0(a0)
 936:	bff1                	j	912 <malloc+0x88>
  hp->s.size = nu;
 938:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 93c:	0541                	addi	a0,a0,16
 93e:	00000097          	auipc	ra,0x0
 942:	eca080e7          	jalr	-310(ra) # 808 <free>
  return freep;
 946:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 94a:	d971                	beqz	a0,91e <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 94c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 94e:	4798                	lw	a4,8(a5)
 950:	fa9775e3          	bgeu	a4,s1,8fa <malloc+0x70>
    if(p == freep)
 954:	00093703          	ld	a4,0(s2)
 958:	853e                	mv	a0,a5
 95a:	fef719e3          	bne	a4,a5,94c <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 95e:	8552                	mv	a0,s4
 960:	00000097          	auipc	ra,0x0
 964:	b62080e7          	jalr	-1182(ra) # 4c2 <sbrk>
  if(p == (char*)-1)
 968:	fd5518e3          	bne	a0,s5,938 <malloc+0xae>
        return 0;
 96c:	4501                	li	a0,0
 96e:	bf45                	j	91e <malloc+0x94>
