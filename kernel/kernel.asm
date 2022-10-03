
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	c5010113          	addi	sp,sp,-944 # 80008c50 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	ac070713          	addi	a4,a4,-1344 # 80008b10 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	d3e78793          	addi	a5,a5,-706 # 80005da0 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc07f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dc678793          	addi	a5,a5,-570 # 80000e72 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	3a2080e7          	jalr	930(ra) # 800024cc <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	780080e7          	jalr	1920(ra) # 800008ba <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	711d                	addi	sp,sp,-96
    80000166:	ec86                	sd	ra,88(sp)
    80000168:	e8a2                	sd	s0,80(sp)
    8000016a:	e4a6                	sd	s1,72(sp)
    8000016c:	e0ca                	sd	s2,64(sp)
    8000016e:	fc4e                	sd	s3,56(sp)
    80000170:	f852                	sd	s4,48(sp)
    80000172:	f456                	sd	s5,40(sp)
    80000174:	f05a                	sd	s6,32(sp)
    80000176:	ec5e                	sd	s7,24(sp)
    80000178:	1080                	addi	s0,sp,96
    8000017a:	8aaa                	mv	s5,a0
    8000017c:	8a2e                	mv	s4,a1
    8000017e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000180:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000184:	00011517          	auipc	a0,0x11
    80000188:	acc50513          	addi	a0,a0,-1332 # 80010c50 <cons>
    8000018c:	00001097          	auipc	ra,0x1
    80000190:	a46080e7          	jalr	-1466(ra) # 80000bd2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000194:	00011497          	auipc	s1,0x11
    80000198:	abc48493          	addi	s1,s1,-1348 # 80010c50 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000019c:	00011917          	auipc	s2,0x11
    800001a0:	b4c90913          	addi	s2,s2,-1204 # 80010ce8 <cons+0x98>
  while(n > 0){
    800001a4:	09305263          	blez	s3,80000228 <consoleread+0xc4>
    while(cons.r == cons.w){
    800001a8:	0984a783          	lw	a5,152(s1)
    800001ac:	09c4a703          	lw	a4,156(s1)
    800001b0:	02f71763          	bne	a4,a5,800001de <consoleread+0x7a>
      if(killed(myproc())){
    800001b4:	00001097          	auipc	ra,0x1
    800001b8:	7f2080e7          	jalr	2034(ra) # 800019a6 <myproc>
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	15a080e7          	jalr	346(ra) # 80002316 <killed>
    800001c4:	ed2d                	bnez	a0,8000023e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001c6:	85a6                	mv	a1,s1
    800001c8:	854a                	mv	a0,s2
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	ea4080e7          	jalr	-348(ra) # 8000206e <sleep>
    while(cons.r == cons.w){
    800001d2:	0984a783          	lw	a5,152(s1)
    800001d6:	09c4a703          	lw	a4,156(s1)
    800001da:	fcf70de3          	beq	a4,a5,800001b4 <consoleread+0x50>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00011717          	auipc	a4,0x11
    800001e2:	a7270713          	addi	a4,a4,-1422 # 80010c50 <cons>
    800001e6:	0017869b          	addiw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	andi	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	06db8463          	beq	s7,a3,80000266 <consoleread+0x102>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	addi	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	8556                	mv	a0,s5
    80000210:	00002097          	auipc	ra,0x2
    80000214:	266080e7          	jalr	614(ra) # 80002476 <either_copyout>
    80000218:	57fd                	li	a5,-1
    8000021a:	00f50763          	beq	a0,a5,80000228 <consoleread+0xc4>
      break;

    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80000222:	47a9                	li	a5,10
    80000224:	f8fb90e3          	bne	s7,a5,800001a4 <consoleread+0x40>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000228:	00011517          	auipc	a0,0x11
    8000022c:	a2850513          	addi	a0,a0,-1496 # 80010c50 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a56080e7          	jalr	-1450(ra) # 80000c86 <release>

  return target - n;
    80000238:	413b053b          	subw	a0,s6,s3
    8000023c:	a811                	j	80000250 <consoleread+0xec>
        release(&cons.lock);
    8000023e:	00011517          	auipc	a0,0x11
    80000242:	a1250513          	addi	a0,a0,-1518 # 80010c50 <cons>
    80000246:	00001097          	auipc	ra,0x1
    8000024a:	a40080e7          	jalr	-1472(ra) # 80000c86 <release>
        return -1;
    8000024e:	557d                	li	a0,-1
}
    80000250:	60e6                	ld	ra,88(sp)
    80000252:	6446                	ld	s0,80(sp)
    80000254:	64a6                	ld	s1,72(sp)
    80000256:	6906                	ld	s2,64(sp)
    80000258:	79e2                	ld	s3,56(sp)
    8000025a:	7a42                	ld	s4,48(sp)
    8000025c:	7aa2                	ld	s5,40(sp)
    8000025e:	7b02                	ld	s6,32(sp)
    80000260:	6be2                	ld	s7,24(sp)
    80000262:	6125                	addi	sp,sp,96
    80000264:	8082                	ret
      if(n < target){
    80000266:	0009871b          	sext.w	a4,s3
    8000026a:	fb677fe3          	bgeu	a4,s6,80000228 <consoleread+0xc4>
        cons.r--;
    8000026e:	00011717          	auipc	a4,0x11
    80000272:	a6f72d23          	sw	a5,-1414(a4) # 80010ce8 <cons+0x98>
    80000276:	bf4d                	j	80000228 <consoleread+0xc4>

0000000080000278 <consputc>:
{
    80000278:	1141                	addi	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50a63          	beq	a0,a5,80000298 <consputc+0x20>
    uartputc_sync(c);
    80000288:	00000097          	auipc	ra,0x0
    8000028c:	560080e7          	jalr	1376(ra) # 800007e8 <uartputc_sync>
}
    80000290:	60a2                	ld	ra,8(sp)
    80000292:	6402                	ld	s0,0(sp)
    80000294:	0141                	addi	sp,sp,16
    80000296:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000298:	4521                	li	a0,8
    8000029a:	00000097          	auipc	ra,0x0
    8000029e:	54e080e7          	jalr	1358(ra) # 800007e8 <uartputc_sync>
    800002a2:	02000513          	li	a0,32
    800002a6:	00000097          	auipc	ra,0x0
    800002aa:	542080e7          	jalr	1346(ra) # 800007e8 <uartputc_sync>
    800002ae:	4521                	li	a0,8
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	538080e7          	jalr	1336(ra) # 800007e8 <uartputc_sync>
    800002b8:	bfe1                	j	80000290 <consputc+0x18>

00000000800002ba <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ba:	1101                	addi	sp,sp,-32
    800002bc:	ec06                	sd	ra,24(sp)
    800002be:	e822                	sd	s0,16(sp)
    800002c0:	e426                	sd	s1,8(sp)
    800002c2:	e04a                	sd	s2,0(sp)
    800002c4:	1000                	addi	s0,sp,32
    800002c6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c8:	00011517          	auipc	a0,0x11
    800002cc:	98850513          	addi	a0,a0,-1656 # 80010c50 <cons>
    800002d0:	00001097          	auipc	ra,0x1
    800002d4:	902080e7          	jalr	-1790(ra) # 80000bd2 <acquire>

  switch(c){
    800002d8:	47d5                	li	a5,21
    800002da:	0af48663          	beq	s1,a5,80000386 <consoleintr+0xcc>
    800002de:	0297ca63          	blt	a5,s1,80000312 <consoleintr+0x58>
    800002e2:	47a1                	li	a5,8
    800002e4:	0ef48763          	beq	s1,a5,800003d2 <consoleintr+0x118>
    800002e8:	47c1                	li	a5,16
    800002ea:	10f49a63          	bne	s1,a5,800003fe <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002ee:	00002097          	auipc	ra,0x2
    800002f2:	234080e7          	jalr	564(ra) # 80002522 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f6:	00011517          	auipc	a0,0x11
    800002fa:	95a50513          	addi	a0,a0,-1702 # 80010c50 <cons>
    800002fe:	00001097          	auipc	ra,0x1
    80000302:	988080e7          	jalr	-1656(ra) # 80000c86 <release>
}
    80000306:	60e2                	ld	ra,24(sp)
    80000308:	6442                	ld	s0,16(sp)
    8000030a:	64a2                	ld	s1,8(sp)
    8000030c:	6902                	ld	s2,0(sp)
    8000030e:	6105                	addi	sp,sp,32
    80000310:	8082                	ret
  switch(c){
    80000312:	07f00793          	li	a5,127
    80000316:	0af48e63          	beq	s1,a5,800003d2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031a:	00011717          	auipc	a4,0x11
    8000031e:	93670713          	addi	a4,a4,-1738 # 80010c50 <cons>
    80000322:	0a072783          	lw	a5,160(a4)
    80000326:	09872703          	lw	a4,152(a4)
    8000032a:	9f99                	subw	a5,a5,a4
    8000032c:	07f00713          	li	a4,127
    80000330:	fcf763e3          	bltu	a4,a5,800002f6 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000334:	47b5                	li	a5,13
    80000336:	0cf48763          	beq	s1,a5,80000404 <consoleintr+0x14a>
      consputc(c);
    8000033a:	8526                	mv	a0,s1
    8000033c:	00000097          	auipc	ra,0x0
    80000340:	f3c080e7          	jalr	-196(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000344:	00011797          	auipc	a5,0x11
    80000348:	90c78793          	addi	a5,a5,-1780 # 80010c50 <cons>
    8000034c:	0a07a683          	lw	a3,160(a5)
    80000350:	0016871b          	addiw	a4,a3,1
    80000354:	0007061b          	sext.w	a2,a4
    80000358:	0ae7a023          	sw	a4,160(a5)
    8000035c:	07f6f693          	andi	a3,a3,127
    80000360:	97b6                	add	a5,a5,a3
    80000362:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000366:	47a9                	li	a5,10
    80000368:	0cf48563          	beq	s1,a5,80000432 <consoleintr+0x178>
    8000036c:	4791                	li	a5,4
    8000036e:	0cf48263          	beq	s1,a5,80000432 <consoleintr+0x178>
    80000372:	00011797          	auipc	a5,0x11
    80000376:	9767a783          	lw	a5,-1674(a5) # 80010ce8 <cons+0x98>
    8000037a:	9f1d                	subw	a4,a4,a5
    8000037c:	08000793          	li	a5,128
    80000380:	f6f71be3          	bne	a4,a5,800002f6 <consoleintr+0x3c>
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000386:	00011717          	auipc	a4,0x11
    8000038a:	8ca70713          	addi	a4,a4,-1846 # 80010c50 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000396:	00011497          	auipc	s1,0x11
    8000039a:	8ba48493          	addi	s1,s1,-1862 # 80010c50 <cons>
    while(cons.e != cons.w &&
    8000039e:	4929                	li	s2,10
    800003a0:	f4f70be3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a4:	37fd                	addiw	a5,a5,-1
    800003a6:	07f7f713          	andi	a4,a5,127
    800003aa:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ac:	01874703          	lbu	a4,24(a4)
    800003b0:	f52703e3          	beq	a4,s2,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003b4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003b8:	10000513          	li	a0,256
    800003bc:	00000097          	auipc	ra,0x0
    800003c0:	ebc080e7          	jalr	-324(ra) # 80000278 <consputc>
    while(cons.e != cons.w &&
    800003c4:	0a04a783          	lw	a5,160(s1)
    800003c8:	09c4a703          	lw	a4,156(s1)
    800003cc:	fcf71ce3          	bne	a4,a5,800003a4 <consoleintr+0xea>
    800003d0:	b71d                	j	800002f6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d2:	00011717          	auipc	a4,0x11
    800003d6:	87e70713          	addi	a4,a4,-1922 # 80010c50 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003e6:	37fd                	addiw	a5,a5,-1
    800003e8:	00011717          	auipc	a4,0x11
    800003ec:	90f72423          	sw	a5,-1784(a4) # 80010cf0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f0:	10000513          	li	a0,256
    800003f4:	00000097          	auipc	ra,0x0
    800003f8:	e84080e7          	jalr	-380(ra) # 80000278 <consputc>
    800003fc:	bded                	j	800002f6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003fe:	ee048ce3          	beqz	s1,800002f6 <consoleintr+0x3c>
    80000402:	bf21                	j	8000031a <consoleintr+0x60>
      consputc(c);
    80000404:	4529                	li	a0,10
    80000406:	00000097          	auipc	ra,0x0
    8000040a:	e72080e7          	jalr	-398(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000040e:	00011797          	auipc	a5,0x11
    80000412:	84278793          	addi	a5,a5,-1982 # 80010c50 <cons>
    80000416:	0a07a703          	lw	a4,160(a5)
    8000041a:	0017069b          	addiw	a3,a4,1
    8000041e:	0006861b          	sext.w	a2,a3
    80000422:	0ad7a023          	sw	a3,160(a5)
    80000426:	07f77713          	andi	a4,a4,127
    8000042a:	97ba                	add	a5,a5,a4
    8000042c:	4729                	li	a4,10
    8000042e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000432:	00011797          	auipc	a5,0x11
    80000436:	8ac7ad23          	sw	a2,-1862(a5) # 80010cec <cons+0x9c>
        wakeup(&cons.r);
    8000043a:	00011517          	auipc	a0,0x11
    8000043e:	8ae50513          	addi	a0,a0,-1874 # 80010ce8 <cons+0x98>
    80000442:	00002097          	auipc	ra,0x2
    80000446:	c90080e7          	jalr	-880(ra) # 800020d2 <wakeup>
    8000044a:	b575                	j	800002f6 <consoleintr+0x3c>

000000008000044c <consoleinit>:

void
consoleinit(void)
{
    8000044c:	1141                	addi	sp,sp,-16
    8000044e:	e406                	sd	ra,8(sp)
    80000450:	e022                	sd	s0,0(sp)
    80000452:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000454:	00008597          	auipc	a1,0x8
    80000458:	bbc58593          	addi	a1,a1,-1092 # 80008010 <etext+0x10>
    8000045c:	00010517          	auipc	a0,0x10
    80000460:	7f450513          	addi	a0,a0,2036 # 80010c50 <cons>
    80000464:	00000097          	auipc	ra,0x0
    80000468:	6de080e7          	jalr	1758(ra) # 80000b42 <initlock>

  uartinit();
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	32c080e7          	jalr	812(ra) # 80000798 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000474:	00021797          	auipc	a5,0x21
    80000478:	17478793          	addi	a5,a5,372 # 800215e8 <devsw>
    8000047c:	00000717          	auipc	a4,0x0
    80000480:	ce870713          	addi	a4,a4,-792 # 80000164 <consoleread>
    80000484:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	c7a70713          	addi	a4,a4,-902 # 80000100 <consolewrite>
    8000048e:	ef98                	sd	a4,24(a5)
}
    80000490:	60a2                	ld	ra,8(sp)
    80000492:	6402                	ld	s0,0(sp)
    80000494:	0141                	addi	sp,sp,16
    80000496:	8082                	ret

0000000080000498 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000498:	7179                	addi	sp,sp,-48
    8000049a:	f406                	sd	ra,40(sp)
    8000049c:	f022                	sd	s0,32(sp)
    8000049e:	ec26                	sd	s1,24(sp)
    800004a0:	e84a                	sd	s2,16(sp)
    800004a2:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a4:	c219                	beqz	a2,800004aa <printint+0x12>
    800004a6:	08054763          	bltz	a0,80000534 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004aa:	2501                	sext.w	a0,a0
    800004ac:	4881                	li	a7,0
    800004ae:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b4:	2581                	sext.w	a1,a1
    800004b6:	00008617          	auipc	a2,0x8
    800004ba:	b8a60613          	addi	a2,a2,-1142 # 80008040 <digits>
    800004be:	883a                	mv	a6,a4
    800004c0:	2705                	addiw	a4,a4,1
    800004c2:	02b577bb          	remuw	a5,a0,a1
    800004c6:	1782                	slli	a5,a5,0x20
    800004c8:	9381                	srli	a5,a5,0x20
    800004ca:	97b2                	add	a5,a5,a2
    800004cc:	0007c783          	lbu	a5,0(a5)
    800004d0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d4:	0005079b          	sext.w	a5,a0
    800004d8:	02b5553b          	divuw	a0,a0,a1
    800004dc:	0685                	addi	a3,a3,1
    800004de:	feb7f0e3          	bgeu	a5,a1,800004be <printint+0x26>

  if(sign)
    800004e2:	00088c63          	beqz	a7,800004fa <printint+0x62>
    buf[i++] = '-';
    800004e6:	fe070793          	addi	a5,a4,-32
    800004ea:	00878733          	add	a4,a5,s0
    800004ee:	02d00793          	li	a5,45
    800004f2:	fef70823          	sb	a5,-16(a4)
    800004f6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fa:	02e05763          	blez	a4,80000528 <printint+0x90>
    800004fe:	fd040793          	addi	a5,s0,-48
    80000502:	00e784b3          	add	s1,a5,a4
    80000506:	fff78913          	addi	s2,a5,-1
    8000050a:	993a                	add	s2,s2,a4
    8000050c:	377d                	addiw	a4,a4,-1
    8000050e:	1702                	slli	a4,a4,0x20
    80000510:	9301                	srli	a4,a4,0x20
    80000512:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000516:	fff4c503          	lbu	a0,-1(s1)
    8000051a:	00000097          	auipc	ra,0x0
    8000051e:	d5e080e7          	jalr	-674(ra) # 80000278 <consputc>
  while(--i >= 0)
    80000522:	14fd                	addi	s1,s1,-1
    80000524:	ff2499e3          	bne	s1,s2,80000516 <printint+0x7e>
}
    80000528:	70a2                	ld	ra,40(sp)
    8000052a:	7402                	ld	s0,32(sp)
    8000052c:	64e2                	ld	s1,24(sp)
    8000052e:	6942                	ld	s2,16(sp)
    80000530:	6145                	addi	sp,sp,48
    80000532:	8082                	ret
    x = -xx;
    80000534:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000538:	4885                	li	a7,1
    x = -xx;
    8000053a:	bf95                	j	800004ae <printint+0x16>

000000008000053c <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053c:	1101                	addi	sp,sp,-32
    8000053e:	ec06                	sd	ra,24(sp)
    80000540:	e822                	sd	s0,16(sp)
    80000542:	e426                	sd	s1,8(sp)
    80000544:	1000                	addi	s0,sp,32
    80000546:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000548:	00010797          	auipc	a5,0x10
    8000054c:	7c07a423          	sw	zero,1992(a5) # 80010d10 <pr+0x18>
  printf("panic: ");
    80000550:	00008517          	auipc	a0,0x8
    80000554:	ac850513          	addi	a0,a0,-1336 # 80008018 <etext+0x18>
    80000558:	00000097          	auipc	ra,0x0
    8000055c:	02e080e7          	jalr	46(ra) # 80000586 <printf>
  printf(s);
    80000560:	8526                	mv	a0,s1
    80000562:	00000097          	auipc	ra,0x0
    80000566:	024080e7          	jalr	36(ra) # 80000586 <printf>
  printf("\n");
    8000056a:	00008517          	auipc	a0,0x8
    8000056e:	b5e50513          	addi	a0,a0,-1186 # 800080c8 <digits+0x88>
    80000572:	00000097          	auipc	ra,0x0
    80000576:	014080e7          	jalr	20(ra) # 80000586 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057a:	4785                	li	a5,1
    8000057c:	00008717          	auipc	a4,0x8
    80000580:	54f72a23          	sw	a5,1364(a4) # 80008ad0 <panicked>
  for(;;)
    80000584:	a001                	j	80000584 <panic+0x48>

0000000080000586 <printf>:
{
    80000586:	7131                	addi	sp,sp,-192
    80000588:	fc86                	sd	ra,120(sp)
    8000058a:	f8a2                	sd	s0,112(sp)
    8000058c:	f4a6                	sd	s1,104(sp)
    8000058e:	f0ca                	sd	s2,96(sp)
    80000590:	ecce                	sd	s3,88(sp)
    80000592:	e8d2                	sd	s4,80(sp)
    80000594:	e4d6                	sd	s5,72(sp)
    80000596:	e0da                	sd	s6,64(sp)
    80000598:	fc5e                	sd	s7,56(sp)
    8000059a:	f862                	sd	s8,48(sp)
    8000059c:	f466                	sd	s9,40(sp)
    8000059e:	f06a                	sd	s10,32(sp)
    800005a0:	ec6e                	sd	s11,24(sp)
    800005a2:	0100                	addi	s0,sp,128
    800005a4:	8a2a                	mv	s4,a0
    800005a6:	e40c                	sd	a1,8(s0)
    800005a8:	e810                	sd	a2,16(s0)
    800005aa:	ec14                	sd	a3,24(s0)
    800005ac:	f018                	sd	a4,32(s0)
    800005ae:	f41c                	sd	a5,40(s0)
    800005b0:	03043823          	sd	a6,48(s0)
    800005b4:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b8:	00010d97          	auipc	s11,0x10
    800005bc:	758dad83          	lw	s11,1880(s11) # 80010d10 <pr+0x18>
  if(locking)
    800005c0:	020d9b63          	bnez	s11,800005f6 <printf+0x70>
  if (fmt == 0)
    800005c4:	040a0263          	beqz	s4,80000608 <printf+0x82>
  va_start(ap, fmt);
    800005c8:	00840793          	addi	a5,s0,8
    800005cc:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d0:	000a4503          	lbu	a0,0(s4)
    800005d4:	14050f63          	beqz	a0,80000732 <printf+0x1ac>
    800005d8:	4981                	li	s3,0
    if(c != '%'){
    800005da:	02500a93          	li	s5,37
    switch(c){
    800005de:	07000b93          	li	s7,112
  consputc('x');
    800005e2:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e4:	00008b17          	auipc	s6,0x8
    800005e8:	a5cb0b13          	addi	s6,s6,-1444 # 80008040 <digits>
    switch(c){
    800005ec:	07300c93          	li	s9,115
    800005f0:	06400c13          	li	s8,100
    800005f4:	a82d                	j	8000062e <printf+0xa8>
    acquire(&pr.lock);
    800005f6:	00010517          	auipc	a0,0x10
    800005fa:	70250513          	addi	a0,a0,1794 # 80010cf8 <pr>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	5d4080e7          	jalr	1492(ra) # 80000bd2 <acquire>
    80000606:	bf7d                	j	800005c4 <printf+0x3e>
    panic("null fmt");
    80000608:	00008517          	auipc	a0,0x8
    8000060c:	a2050513          	addi	a0,a0,-1504 # 80008028 <etext+0x28>
    80000610:	00000097          	auipc	ra,0x0
    80000614:	f2c080e7          	jalr	-212(ra) # 8000053c <panic>
      consputc(c);
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	c60080e7          	jalr	-928(ra) # 80000278 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000620:	2985                	addiw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c503          	lbu	a0,0(a5)
    8000062a:	10050463          	beqz	a0,80000732 <printf+0x1ac>
    if(c != '%'){
    8000062e:	ff5515e3          	bne	a0,s5,80000618 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000632:	2985                	addiw	s3,s3,1
    80000634:	013a07b3          	add	a5,s4,s3
    80000638:	0007c783          	lbu	a5,0(a5)
    8000063c:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000640:	cbed                	beqz	a5,80000732 <printf+0x1ac>
    switch(c){
    80000642:	05778a63          	beq	a5,s7,80000696 <printf+0x110>
    80000646:	02fbf663          	bgeu	s7,a5,80000672 <printf+0xec>
    8000064a:	09978863          	beq	a5,s9,800006da <printf+0x154>
    8000064e:	07800713          	li	a4,120
    80000652:	0ce79563          	bne	a5,a4,8000071c <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000656:	f8843783          	ld	a5,-120(s0)
    8000065a:	00878713          	addi	a4,a5,8
    8000065e:	f8e43423          	sd	a4,-120(s0)
    80000662:	4605                	li	a2,1
    80000664:	85ea                	mv	a1,s10
    80000666:	4388                	lw	a0,0(a5)
    80000668:	00000097          	auipc	ra,0x0
    8000066c:	e30080e7          	jalr	-464(ra) # 80000498 <printint>
      break;
    80000670:	bf45                	j	80000620 <printf+0x9a>
    switch(c){
    80000672:	09578f63          	beq	a5,s5,80000710 <printf+0x18a>
    80000676:	0b879363          	bne	a5,s8,8000071c <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067a:	f8843783          	ld	a5,-120(s0)
    8000067e:	00878713          	addi	a4,a5,8
    80000682:	f8e43423          	sd	a4,-120(s0)
    80000686:	4605                	li	a2,1
    80000688:	45a9                	li	a1,10
    8000068a:	4388                	lw	a0,0(a5)
    8000068c:	00000097          	auipc	ra,0x0
    80000690:	e0c080e7          	jalr	-500(ra) # 80000498 <printint>
      break;
    80000694:	b771                	j	80000620 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a6:	03000513          	li	a0,48
    800006aa:	00000097          	auipc	ra,0x0
    800006ae:	bce080e7          	jalr	-1074(ra) # 80000278 <consputc>
  consputc('x');
    800006b2:	07800513          	li	a0,120
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	bc2080e7          	jalr	-1086(ra) # 80000278 <consputc>
    800006be:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c0:	03c95793          	srli	a5,s2,0x3c
    800006c4:	97da                	add	a5,a5,s6
    800006c6:	0007c503          	lbu	a0,0(a5)
    800006ca:	00000097          	auipc	ra,0x0
    800006ce:	bae080e7          	jalr	-1106(ra) # 80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d2:	0912                	slli	s2,s2,0x4
    800006d4:	34fd                	addiw	s1,s1,-1
    800006d6:	f4ed                	bnez	s1,800006c0 <printf+0x13a>
    800006d8:	b7a1                	j	80000620 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006da:	f8843783          	ld	a5,-120(s0)
    800006de:	00878713          	addi	a4,a5,8
    800006e2:	f8e43423          	sd	a4,-120(s0)
    800006e6:	6384                	ld	s1,0(a5)
    800006e8:	cc89                	beqz	s1,80000702 <printf+0x17c>
      for(; *s; s++)
    800006ea:	0004c503          	lbu	a0,0(s1)
    800006ee:	d90d                	beqz	a0,80000620 <printf+0x9a>
        consputc(*s);
    800006f0:	00000097          	auipc	ra,0x0
    800006f4:	b88080e7          	jalr	-1144(ra) # 80000278 <consputc>
      for(; *s; s++)
    800006f8:	0485                	addi	s1,s1,1
    800006fa:	0004c503          	lbu	a0,0(s1)
    800006fe:	f96d                	bnez	a0,800006f0 <printf+0x16a>
    80000700:	b705                	j	80000620 <printf+0x9a>
        s = "(null)";
    80000702:	00008497          	auipc	s1,0x8
    80000706:	91e48493          	addi	s1,s1,-1762 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070a:	02800513          	li	a0,40
    8000070e:	b7cd                	j	800006f0 <printf+0x16a>
      consputc('%');
    80000710:	8556                	mv	a0,s5
    80000712:	00000097          	auipc	ra,0x0
    80000716:	b66080e7          	jalr	-1178(ra) # 80000278 <consputc>
      break;
    8000071a:	b719                	j	80000620 <printf+0x9a>
      consputc('%');
    8000071c:	8556                	mv	a0,s5
    8000071e:	00000097          	auipc	ra,0x0
    80000722:	b5a080e7          	jalr	-1190(ra) # 80000278 <consputc>
      consputc(c);
    80000726:	8526                	mv	a0,s1
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b50080e7          	jalr	-1200(ra) # 80000278 <consputc>
      break;
    80000730:	bdc5                	j	80000620 <printf+0x9a>
  if(locking)
    80000732:	020d9163          	bnez	s11,80000754 <printf+0x1ce>
}
    80000736:	70e6                	ld	ra,120(sp)
    80000738:	7446                	ld	s0,112(sp)
    8000073a:	74a6                	ld	s1,104(sp)
    8000073c:	7906                	ld	s2,96(sp)
    8000073e:	69e6                	ld	s3,88(sp)
    80000740:	6a46                	ld	s4,80(sp)
    80000742:	6aa6                	ld	s5,72(sp)
    80000744:	6b06                	ld	s6,64(sp)
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	7c42                	ld	s8,48(sp)
    8000074a:	7ca2                	ld	s9,40(sp)
    8000074c:	7d02                	ld	s10,32(sp)
    8000074e:	6de2                	ld	s11,24(sp)
    80000750:	6129                	addi	sp,sp,192
    80000752:	8082                	ret
    release(&pr.lock);
    80000754:	00010517          	auipc	a0,0x10
    80000758:	5a450513          	addi	a0,a0,1444 # 80010cf8 <pr>
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	52a080e7          	jalr	1322(ra) # 80000c86 <release>
}
    80000764:	bfc9                	j	80000736 <printf+0x1b0>

0000000080000766 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000766:	1101                	addi	sp,sp,-32
    80000768:	ec06                	sd	ra,24(sp)
    8000076a:	e822                	sd	s0,16(sp)
    8000076c:	e426                	sd	s1,8(sp)
    8000076e:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000770:	00010497          	auipc	s1,0x10
    80000774:	58848493          	addi	s1,s1,1416 # 80010cf8 <pr>
    80000778:	00008597          	auipc	a1,0x8
    8000077c:	8c058593          	addi	a1,a1,-1856 # 80008038 <etext+0x38>
    80000780:	8526                	mv	a0,s1
    80000782:	00000097          	auipc	ra,0x0
    80000786:	3c0080e7          	jalr	960(ra) # 80000b42 <initlock>
  pr.locking = 1;
    8000078a:	4785                	li	a5,1
    8000078c:	cc9c                	sw	a5,24(s1)
}
    8000078e:	60e2                	ld	ra,24(sp)
    80000790:	6442                	ld	s0,16(sp)
    80000792:	64a2                	ld	s1,8(sp)
    80000794:	6105                	addi	sp,sp,32
    80000796:	8082                	ret

0000000080000798 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000798:	1141                	addi	sp,sp,-16
    8000079a:	e406                	sd	ra,8(sp)
    8000079c:	e022                	sd	s0,0(sp)
    8000079e:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a0:	100007b7          	lui	a5,0x10000
    800007a4:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a8:	f8000713          	li	a4,-128
    800007ac:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b0:	470d                	li	a4,3
    800007b2:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b6:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007ba:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007be:	469d                	li	a3,7
    800007c0:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c4:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c8:	00008597          	auipc	a1,0x8
    800007cc:	89058593          	addi	a1,a1,-1904 # 80008058 <digits+0x18>
    800007d0:	00010517          	auipc	a0,0x10
    800007d4:	54850513          	addi	a0,a0,1352 # 80010d18 <uart_tx_lock>
    800007d8:	00000097          	auipc	ra,0x0
    800007dc:	36a080e7          	jalr	874(ra) # 80000b42 <initlock>
}
    800007e0:	60a2                	ld	ra,8(sp)
    800007e2:	6402                	ld	s0,0(sp)
    800007e4:	0141                	addi	sp,sp,16
    800007e6:	8082                	ret

00000000800007e8 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e8:	1101                	addi	sp,sp,-32
    800007ea:	ec06                	sd	ra,24(sp)
    800007ec:	e822                	sd	s0,16(sp)
    800007ee:	e426                	sd	s1,8(sp)
    800007f0:	1000                	addi	s0,sp,32
    800007f2:	84aa                	mv	s1,a0
  push_off();
    800007f4:	00000097          	auipc	ra,0x0
    800007f8:	392080e7          	jalr	914(ra) # 80000b86 <push_off>

  if(panicked){
    800007fc:	00008797          	auipc	a5,0x8
    80000800:	2d47a783          	lw	a5,724(a5) # 80008ad0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000804:	10000737          	lui	a4,0x10000
  if(panicked){
    80000808:	c391                	beqz	a5,8000080c <uartputc_sync+0x24>
    for(;;)
    8000080a:	a001                	j	8000080a <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080c:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000810:	0207f793          	andi	a5,a5,32
    80000814:	dfe5                	beqz	a5,8000080c <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000816:	0ff4f513          	zext.b	a0,s1
    8000081a:	100007b7          	lui	a5,0x10000
    8000081e:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000822:	00000097          	auipc	ra,0x0
    80000826:	404080e7          	jalr	1028(ra) # 80000c26 <pop_off>
}
    8000082a:	60e2                	ld	ra,24(sp)
    8000082c:	6442                	ld	s0,16(sp)
    8000082e:	64a2                	ld	s1,8(sp)
    80000830:	6105                	addi	sp,sp,32
    80000832:	8082                	ret

0000000080000834 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000834:	00008797          	auipc	a5,0x8
    80000838:	2a47b783          	ld	a5,676(a5) # 80008ad8 <uart_tx_r>
    8000083c:	00008717          	auipc	a4,0x8
    80000840:	2a473703          	ld	a4,676(a4) # 80008ae0 <uart_tx_w>
    80000844:	06f70a63          	beq	a4,a5,800008b8 <uartstart+0x84>
{
    80000848:	7139                	addi	sp,sp,-64
    8000084a:	fc06                	sd	ra,56(sp)
    8000084c:	f822                	sd	s0,48(sp)
    8000084e:	f426                	sd	s1,40(sp)
    80000850:	f04a                	sd	s2,32(sp)
    80000852:	ec4e                	sd	s3,24(sp)
    80000854:	e852                	sd	s4,16(sp)
    80000856:	e456                	sd	s5,8(sp)
    80000858:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085a:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085e:	00010a17          	auipc	s4,0x10
    80000862:	4baa0a13          	addi	s4,s4,1210 # 80010d18 <uart_tx_lock>
    uart_tx_r += 1;
    80000866:	00008497          	auipc	s1,0x8
    8000086a:	27248493          	addi	s1,s1,626 # 80008ad8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086e:	00008997          	auipc	s3,0x8
    80000872:	27298993          	addi	s3,s3,626 # 80008ae0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000876:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087a:	02077713          	andi	a4,a4,32
    8000087e:	c705                	beqz	a4,800008a6 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000880:	01f7f713          	andi	a4,a5,31
    80000884:	9752                	add	a4,a4,s4
    80000886:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088a:	0785                	addi	a5,a5,1
    8000088c:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000088e:	8526                	mv	a0,s1
    80000890:	00002097          	auipc	ra,0x2
    80000894:	842080e7          	jalr	-1982(ra) # 800020d2 <wakeup>
    
    WriteReg(THR, c);
    80000898:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089c:	609c                	ld	a5,0(s1)
    8000089e:	0009b703          	ld	a4,0(s3)
    800008a2:	fcf71ae3          	bne	a4,a5,80000876 <uartstart+0x42>
  }
}
    800008a6:	70e2                	ld	ra,56(sp)
    800008a8:	7442                	ld	s0,48(sp)
    800008aa:	74a2                	ld	s1,40(sp)
    800008ac:	7902                	ld	s2,32(sp)
    800008ae:	69e2                	ld	s3,24(sp)
    800008b0:	6a42                	ld	s4,16(sp)
    800008b2:	6aa2                	ld	s5,8(sp)
    800008b4:	6121                	addi	sp,sp,64
    800008b6:	8082                	ret
    800008b8:	8082                	ret

00000000800008ba <uartputc>:
{
    800008ba:	7179                	addi	sp,sp,-48
    800008bc:	f406                	sd	ra,40(sp)
    800008be:	f022                	sd	s0,32(sp)
    800008c0:	ec26                	sd	s1,24(sp)
    800008c2:	e84a                	sd	s2,16(sp)
    800008c4:	e44e                	sd	s3,8(sp)
    800008c6:	e052                	sd	s4,0(sp)
    800008c8:	1800                	addi	s0,sp,48
    800008ca:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008cc:	00010517          	auipc	a0,0x10
    800008d0:	44c50513          	addi	a0,a0,1100 # 80010d18 <uart_tx_lock>
    800008d4:	00000097          	auipc	ra,0x0
    800008d8:	2fe080e7          	jalr	766(ra) # 80000bd2 <acquire>
  if(panicked){
    800008dc:	00008797          	auipc	a5,0x8
    800008e0:	1f47a783          	lw	a5,500(a5) # 80008ad0 <panicked>
    800008e4:	e7c9                	bnez	a5,8000096e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	1fa73703          	ld	a4,506(a4) # 80008ae0 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	1ea7b783          	ld	a5,490(a5) # 80008ad8 <uart_tx_r>
    800008f6:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fa:	00010997          	auipc	s3,0x10
    800008fe:	41e98993          	addi	s3,s3,1054 # 80010d18 <uart_tx_lock>
    80000902:	00008497          	auipc	s1,0x8
    80000906:	1d648493          	addi	s1,s1,470 # 80008ad8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090a:	00008917          	auipc	s2,0x8
    8000090e:	1d690913          	addi	s2,s2,470 # 80008ae0 <uart_tx_w>
    80000912:	00e79f63          	bne	a5,a4,80000930 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00001097          	auipc	ra,0x1
    8000091e:	754080e7          	jalr	1876(ra) # 8000206e <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	addi	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00010497          	auipc	s1,0x10
    80000934:	3e848493          	addi	s1,s1,1000 # 80010d18 <uart_tx_lock>
    80000938:	01f77793          	andi	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000942:	0705                	addi	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	18e7be23          	sd	a4,412(a5) # 80008ae0 <uart_tx_w>
  uartstart();
    8000094c:	00000097          	auipc	ra,0x0
    80000950:	ee8080e7          	jalr	-280(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    80000954:	8526                	mv	a0,s1
    80000956:	00000097          	auipc	ra,0x0
    8000095a:	330080e7          	jalr	816(ra) # 80000c86 <release>
}
    8000095e:	70a2                	ld	ra,40(sp)
    80000960:	7402                	ld	s0,32(sp)
    80000962:	64e2                	ld	s1,24(sp)
    80000964:	6942                	ld	s2,16(sp)
    80000966:	69a2                	ld	s3,8(sp)
    80000968:	6a02                	ld	s4,0(sp)
    8000096a:	6145                	addi	sp,sp,48
    8000096c:	8082                	ret
    for(;;)
    8000096e:	a001                	j	8000096e <uartputc+0xb4>

0000000080000970 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000970:	1141                	addi	sp,sp,-16
    80000972:	e422                	sd	s0,8(sp)
    80000974:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000976:	100007b7          	lui	a5,0x10000
    8000097a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097e:	8b85                	andi	a5,a5,1
    80000980:	cb81                	beqz	a5,80000990 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000982:	100007b7          	lui	a5,0x10000
    80000986:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098a:	6422                	ld	s0,8(sp)
    8000098c:	0141                	addi	sp,sp,16
    8000098e:	8082                	ret
    return -1;
    80000990:	557d                	li	a0,-1
    80000992:	bfe5                	j	8000098a <uartgetc+0x1a>

0000000080000994 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000994:	1101                	addi	sp,sp,-32
    80000996:	ec06                	sd	ra,24(sp)
    80000998:	e822                	sd	s0,16(sp)
    8000099a:	e426                	sd	s1,8(sp)
    8000099c:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000099e:	54fd                	li	s1,-1
    800009a0:	a029                	j	800009aa <uartintr+0x16>
      break;
    consoleintr(c);
    800009a2:	00000097          	auipc	ra,0x0
    800009a6:	918080e7          	jalr	-1768(ra) # 800002ba <consoleintr>
    int c = uartgetc();
    800009aa:	00000097          	auipc	ra,0x0
    800009ae:	fc6080e7          	jalr	-58(ra) # 80000970 <uartgetc>
    if(c == -1)
    800009b2:	fe9518e3          	bne	a0,s1,800009a2 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009b6:	00010497          	auipc	s1,0x10
    800009ba:	36248493          	addi	s1,s1,866 # 80010d18 <uart_tx_lock>
    800009be:	8526                	mv	a0,s1
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	212080e7          	jalr	530(ra) # 80000bd2 <acquire>
  uartstart();
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	e6c080e7          	jalr	-404(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    800009d0:	8526                	mv	a0,s1
    800009d2:	00000097          	auipc	ra,0x0
    800009d6:	2b4080e7          	jalr	692(ra) # 80000c86 <release>
}
    800009da:	60e2                	ld	ra,24(sp)
    800009dc:	6442                	ld	s0,16(sp)
    800009de:	64a2                	ld	s1,8(sp)
    800009e0:	6105                	addi	sp,sp,32
    800009e2:	8082                	ret

00000000800009e4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e4:	1101                	addi	sp,sp,-32
    800009e6:	ec06                	sd	ra,24(sp)
    800009e8:	e822                	sd	s0,16(sp)
    800009ea:	e426                	sd	s1,8(sp)
    800009ec:	e04a                	sd	s2,0(sp)
    800009ee:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f0:	03451793          	slli	a5,a0,0x34
    800009f4:	ebb9                	bnez	a5,80000a4a <kfree+0x66>
    800009f6:	84aa                	mv	s1,a0
    800009f8:	00022797          	auipc	a5,0x22
    800009fc:	d8878793          	addi	a5,a5,-632 # 80022780 <end>
    80000a00:	04f56563          	bltu	a0,a5,80000a4a <kfree+0x66>
    80000a04:	47c5                	li	a5,17
    80000a06:	07ee                	slli	a5,a5,0x1b
    80000a08:	04f57163          	bgeu	a0,a5,80000a4a <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a0c:	6605                	lui	a2,0x1
    80000a0e:	4585                	li	a1,1
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	2be080e7          	jalr	702(ra) # 80000cce <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a18:	00010917          	auipc	s2,0x10
    80000a1c:	33890913          	addi	s2,s2,824 # 80010d50 <kmem>
    80000a20:	854a                	mv	a0,s2
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	1b0080e7          	jalr	432(ra) # 80000bd2 <acquire>
  r->next = kmem.freelist;
    80000a2a:	01893783          	ld	a5,24(s2)
    80000a2e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a30:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a34:	854a                	mv	a0,s2
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	250080e7          	jalr	592(ra) # 80000c86 <release>
}
    80000a3e:	60e2                	ld	ra,24(sp)
    80000a40:	6442                	ld	s0,16(sp)
    80000a42:	64a2                	ld	s1,8(sp)
    80000a44:	6902                	ld	s2,0(sp)
    80000a46:	6105                	addi	sp,sp,32
    80000a48:	8082                	ret
    panic("kfree");
    80000a4a:	00007517          	auipc	a0,0x7
    80000a4e:	61650513          	addi	a0,a0,1558 # 80008060 <digits+0x20>
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	aea080e7          	jalr	-1302(ra) # 8000053c <panic>

0000000080000a5a <freerange>:
{
    80000a5a:	7179                	addi	sp,sp,-48
    80000a5c:	f406                	sd	ra,40(sp)
    80000a5e:	f022                	sd	s0,32(sp)
    80000a60:	ec26                	sd	s1,24(sp)
    80000a62:	e84a                	sd	s2,16(sp)
    80000a64:	e44e                	sd	s3,8(sp)
    80000a66:	e052                	sd	s4,0(sp)
    80000a68:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6a:	6785                	lui	a5,0x1
    80000a6c:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a70:	00e504b3          	add	s1,a0,a4
    80000a74:	777d                	lui	a4,0xfffff
    80000a76:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a78:	94be                	add	s1,s1,a5
    80000a7a:	0095ee63          	bltu	a1,s1,80000a96 <freerange+0x3c>
    80000a7e:	892e                	mv	s2,a1
    kfree(p);
    80000a80:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a82:	6985                	lui	s3,0x1
    kfree(p);
    80000a84:	01448533          	add	a0,s1,s4
    80000a88:	00000097          	auipc	ra,0x0
    80000a8c:	f5c080e7          	jalr	-164(ra) # 800009e4 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a90:	94ce                	add	s1,s1,s3
    80000a92:	fe9979e3          	bgeu	s2,s1,80000a84 <freerange+0x2a>
}
    80000a96:	70a2                	ld	ra,40(sp)
    80000a98:	7402                	ld	s0,32(sp)
    80000a9a:	64e2                	ld	s1,24(sp)
    80000a9c:	6942                	ld	s2,16(sp)
    80000a9e:	69a2                	ld	s3,8(sp)
    80000aa0:	6a02                	ld	s4,0(sp)
    80000aa2:	6145                	addi	sp,sp,48
    80000aa4:	8082                	ret

0000000080000aa6 <kinit>:
{
    80000aa6:	1141                	addi	sp,sp,-16
    80000aa8:	e406                	sd	ra,8(sp)
    80000aaa:	e022                	sd	s0,0(sp)
    80000aac:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aae:	00007597          	auipc	a1,0x7
    80000ab2:	5ba58593          	addi	a1,a1,1466 # 80008068 <digits+0x28>
    80000ab6:	00010517          	auipc	a0,0x10
    80000aba:	29a50513          	addi	a0,a0,666 # 80010d50 <kmem>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	084080e7          	jalr	132(ra) # 80000b42 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac6:	45c5                	li	a1,17
    80000ac8:	05ee                	slli	a1,a1,0x1b
    80000aca:	00022517          	auipc	a0,0x22
    80000ace:	cb650513          	addi	a0,a0,-842 # 80022780 <end>
    80000ad2:	00000097          	auipc	ra,0x0
    80000ad6:	f88080e7          	jalr	-120(ra) # 80000a5a <freerange>
}
    80000ada:	60a2                	ld	ra,8(sp)
    80000adc:	6402                	ld	s0,0(sp)
    80000ade:	0141                	addi	sp,sp,16
    80000ae0:	8082                	ret

0000000080000ae2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae2:	1101                	addi	sp,sp,-32
    80000ae4:	ec06                	sd	ra,24(sp)
    80000ae6:	e822                	sd	s0,16(sp)
    80000ae8:	e426                	sd	s1,8(sp)
    80000aea:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aec:	00010497          	auipc	s1,0x10
    80000af0:	26448493          	addi	s1,s1,612 # 80010d50 <kmem>
    80000af4:	8526                	mv	a0,s1
    80000af6:	00000097          	auipc	ra,0x0
    80000afa:	0dc080e7          	jalr	220(ra) # 80000bd2 <acquire>
  r = kmem.freelist;
    80000afe:	6c84                	ld	s1,24(s1)
  if(r)
    80000b00:	c885                	beqz	s1,80000b30 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b02:	609c                	ld	a5,0(s1)
    80000b04:	00010517          	auipc	a0,0x10
    80000b08:	24c50513          	addi	a0,a0,588 # 80010d50 <kmem>
    80000b0c:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b0e:	00000097          	auipc	ra,0x0
    80000b12:	178080e7          	jalr	376(ra) # 80000c86 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b16:	6605                	lui	a2,0x1
    80000b18:	4595                	li	a1,5
    80000b1a:	8526                	mv	a0,s1
    80000b1c:	00000097          	auipc	ra,0x0
    80000b20:	1b2080e7          	jalr	434(ra) # 80000cce <memset>
  return (void*)r;
}
    80000b24:	8526                	mv	a0,s1
    80000b26:	60e2                	ld	ra,24(sp)
    80000b28:	6442                	ld	s0,16(sp)
    80000b2a:	64a2                	ld	s1,8(sp)
    80000b2c:	6105                	addi	sp,sp,32
    80000b2e:	8082                	ret
  release(&kmem.lock);
    80000b30:	00010517          	auipc	a0,0x10
    80000b34:	22050513          	addi	a0,a0,544 # 80010d50 <kmem>
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	14e080e7          	jalr	334(ra) # 80000c86 <release>
  if(r)
    80000b40:	b7d5                	j	80000b24 <kalloc+0x42>

0000000080000b42 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b42:	1141                	addi	sp,sp,-16
    80000b44:	e422                	sd	s0,8(sp)
    80000b46:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b48:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b4e:	00053823          	sd	zero,16(a0)
}
    80000b52:	6422                	ld	s0,8(sp)
    80000b54:	0141                	addi	sp,sp,16
    80000b56:	8082                	ret

0000000080000b58 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b58:	411c                	lw	a5,0(a0)
    80000b5a:	e399                	bnez	a5,80000b60 <holding+0x8>
    80000b5c:	4501                	li	a0,0
  return r;
}
    80000b5e:	8082                	ret
{
    80000b60:	1101                	addi	sp,sp,-32
    80000b62:	ec06                	sd	ra,24(sp)
    80000b64:	e822                	sd	s0,16(sp)
    80000b66:	e426                	sd	s1,8(sp)
    80000b68:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6a:	6904                	ld	s1,16(a0)
    80000b6c:	00001097          	auipc	ra,0x1
    80000b70:	e1e080e7          	jalr	-482(ra) # 8000198a <mycpu>
    80000b74:	40a48533          	sub	a0,s1,a0
    80000b78:	00153513          	seqz	a0,a0
}
    80000b7c:	60e2                	ld	ra,24(sp)
    80000b7e:	6442                	ld	s0,16(sp)
    80000b80:	64a2                	ld	s1,8(sp)
    80000b82:	6105                	addi	sp,sp,32
    80000b84:	8082                	ret

0000000080000b86 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b86:	1101                	addi	sp,sp,-32
    80000b88:	ec06                	sd	ra,24(sp)
    80000b8a:	e822                	sd	s0,16(sp)
    80000b8c:	e426                	sd	s1,8(sp)
    80000b8e:	1000                	addi	s0,sp,32

static inline uint64
r_sstatus()
{
  uint64 x;
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b90:	100024f3          	csrr	s1,sstatus
    80000b94:	100027f3          	csrr	a5,sstatus

// disable device interrupts
static inline void
intr_off()
{
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b98:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b9e:	00001097          	auipc	ra,0x1
    80000ba2:	dec080e7          	jalr	-532(ra) # 8000198a <mycpu>
    80000ba6:	5d3c                	lw	a5,120(a0)
    80000ba8:	cf89                	beqz	a5,80000bc2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000baa:	00001097          	auipc	ra,0x1
    80000bae:	de0080e7          	jalr	-544(ra) # 8000198a <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addiw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	addi	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	00001097          	auipc	ra,0x1
    80000bc6:	dc8080e7          	jalr	-568(ra) # 8000198a <mycpu>
// are device interrupts enabled?
static inline int
intr_get()
{
  uint64 x = r_sstatus();
  return (x & SSTATUS_SIE) != 0;
    80000bca:	8085                	srli	s1,s1,0x1
    80000bcc:	8885                	andi	s1,s1,1
    80000bce:	dd64                	sw	s1,124(a0)
    80000bd0:	bfe9                	j	80000baa <push_off+0x24>

0000000080000bd2 <acquire>:
{
    80000bd2:	1101                	addi	sp,sp,-32
    80000bd4:	ec06                	sd	ra,24(sp)
    80000bd6:	e822                	sd	s0,16(sp)
    80000bd8:	e426                	sd	s1,8(sp)
    80000bda:	1000                	addi	s0,sp,32
    80000bdc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bde:	00000097          	auipc	ra,0x0
    80000be2:	fa8080e7          	jalr	-88(ra) # 80000b86 <push_off>
  if(holding(lk))
    80000be6:	8526                	mv	a0,s1
    80000be8:	00000097          	auipc	ra,0x0
    80000bec:	f70080e7          	jalr	-144(ra) # 80000b58 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf0:	4705                	li	a4,1
  if(holding(lk))
    80000bf2:	e115                	bnez	a0,80000c16 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	87ba                	mv	a5,a4
    80000bf6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfa:	2781                	sext.w	a5,a5
    80000bfc:	ffe5                	bnez	a5,80000bf4 <acquire+0x22>
  __sync_synchronize();
    80000bfe:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c02:	00001097          	auipc	ra,0x1
    80000c06:	d88080e7          	jalr	-632(ra) # 8000198a <mycpu>
    80000c0a:	e888                	sd	a0,16(s1)
}
    80000c0c:	60e2                	ld	ra,24(sp)
    80000c0e:	6442                	ld	s0,16(sp)
    80000c10:	64a2                	ld	s1,8(sp)
    80000c12:	6105                	addi	sp,sp,32
    80000c14:	8082                	ret
    panic("acquire");
    80000c16:	00007517          	auipc	a0,0x7
    80000c1a:	45a50513          	addi	a0,a0,1114 # 80008070 <digits+0x30>
    80000c1e:	00000097          	auipc	ra,0x0
    80000c22:	91e080e7          	jalr	-1762(ra) # 8000053c <panic>

0000000080000c26 <pop_off>:

void
pop_off(void)
{
    80000c26:	1141                	addi	sp,sp,-16
    80000c28:	e406                	sd	ra,8(sp)
    80000c2a:	e022                	sd	s0,0(sp)
    80000c2c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c2e:	00001097          	auipc	ra,0x1
    80000c32:	d5c080e7          	jalr	-676(ra) # 8000198a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c36:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c3c:	e78d                	bnez	a5,80000c66 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c3e:	5d3c                	lw	a5,120(a0)
    80000c40:	02f05b63          	blez	a5,80000c76 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c44:	37fd                	addiw	a5,a5,-1
    80000c46:	0007871b          	sext.w	a4,a5
    80000c4a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c4c:	eb09                	bnez	a4,80000c5e <pop_off+0x38>
    80000c4e:	5d7c                	lw	a5,124(a0)
    80000c50:	c799                	beqz	a5,80000c5e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c52:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c56:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c5e:	60a2                	ld	ra,8(sp)
    80000c60:	6402                	ld	s0,0(sp)
    80000c62:	0141                	addi	sp,sp,16
    80000c64:	8082                	ret
    panic("pop_off - interruptible");
    80000c66:	00007517          	auipc	a0,0x7
    80000c6a:	41250513          	addi	a0,a0,1042 # 80008078 <digits+0x38>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	8ce080e7          	jalr	-1842(ra) # 8000053c <panic>
    panic("pop_off");
    80000c76:	00007517          	auipc	a0,0x7
    80000c7a:	41a50513          	addi	a0,a0,1050 # 80008090 <digits+0x50>
    80000c7e:	00000097          	auipc	ra,0x0
    80000c82:	8be080e7          	jalr	-1858(ra) # 8000053c <panic>

0000000080000c86 <release>:
{
    80000c86:	1101                	addi	sp,sp,-32
    80000c88:	ec06                	sd	ra,24(sp)
    80000c8a:	e822                	sd	s0,16(sp)
    80000c8c:	e426                	sd	s1,8(sp)
    80000c8e:	1000                	addi	s0,sp,32
    80000c90:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c92:	00000097          	auipc	ra,0x0
    80000c96:	ec6080e7          	jalr	-314(ra) # 80000b58 <holding>
    80000c9a:	c115                	beqz	a0,80000cbe <release+0x38>
  lk->cpu = 0;
    80000c9c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca0:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca4:	0f50000f          	fence	iorw,ow
    80000ca8:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cac:	00000097          	auipc	ra,0x0
    80000cb0:	f7a080e7          	jalr	-134(ra) # 80000c26 <pop_off>
}
    80000cb4:	60e2                	ld	ra,24(sp)
    80000cb6:	6442                	ld	s0,16(sp)
    80000cb8:	64a2                	ld	s1,8(sp)
    80000cba:	6105                	addi	sp,sp,32
    80000cbc:	8082                	ret
    panic("release");
    80000cbe:	00007517          	auipc	a0,0x7
    80000cc2:	3da50513          	addi	a0,a0,986 # 80008098 <digits+0x58>
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	876080e7          	jalr	-1930(ra) # 8000053c <panic>

0000000080000cce <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cce:	1141                	addi	sp,sp,-16
    80000cd0:	e422                	sd	s0,8(sp)
    80000cd2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd4:	ca19                	beqz	a2,80000cea <memset+0x1c>
    80000cd6:	87aa                	mv	a5,a0
    80000cd8:	1602                	slli	a2,a2,0x20
    80000cda:	9201                	srli	a2,a2,0x20
    80000cdc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce4:	0785                	addi	a5,a5,1
    80000ce6:	fee79de3          	bne	a5,a4,80000ce0 <memset+0x12>
  }
  return dst;
}
    80000cea:	6422                	ld	s0,8(sp)
    80000cec:	0141                	addi	sp,sp,16
    80000cee:	8082                	ret

0000000080000cf0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf0:	1141                	addi	sp,sp,-16
    80000cf2:	e422                	sd	s0,8(sp)
    80000cf4:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf6:	ca05                	beqz	a2,80000d26 <memcmp+0x36>
    80000cf8:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cfc:	1682                	slli	a3,a3,0x20
    80000cfe:	9281                	srli	a3,a3,0x20
    80000d00:	0685                	addi	a3,a3,1
    80000d02:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d04:	00054783          	lbu	a5,0(a0)
    80000d08:	0005c703          	lbu	a4,0(a1)
    80000d0c:	00e79863          	bne	a5,a4,80000d1c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d10:	0505                	addi	a0,a0,1
    80000d12:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d14:	fed518e3          	bne	a0,a3,80000d04 <memcmp+0x14>
  }

  return 0;
    80000d18:	4501                	li	a0,0
    80000d1a:	a019                	j	80000d20 <memcmp+0x30>
      return *s1 - *s2;
    80000d1c:	40e7853b          	subw	a0,a5,a4
}
    80000d20:	6422                	ld	s0,8(sp)
    80000d22:	0141                	addi	sp,sp,16
    80000d24:	8082                	ret
  return 0;
    80000d26:	4501                	li	a0,0
    80000d28:	bfe5                	j	80000d20 <memcmp+0x30>

0000000080000d2a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2a:	1141                	addi	sp,sp,-16
    80000d2c:	e422                	sd	s0,8(sp)
    80000d2e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d30:	c205                	beqz	a2,80000d50 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d32:	02a5e263          	bltu	a1,a0,80000d56 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d36:	1602                	slli	a2,a2,0x20
    80000d38:	9201                	srli	a2,a2,0x20
    80000d3a:	00c587b3          	add	a5,a1,a2
{
    80000d3e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d40:	0585                	addi	a1,a1,1
    80000d42:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdc881>
    80000d44:	fff5c683          	lbu	a3,-1(a1)
    80000d48:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d4c:	fef59ae3          	bne	a1,a5,80000d40 <memmove+0x16>

  return dst;
}
    80000d50:	6422                	ld	s0,8(sp)
    80000d52:	0141                	addi	sp,sp,16
    80000d54:	8082                	ret
  if(s < d && s + n > d){
    80000d56:	02061693          	slli	a3,a2,0x20
    80000d5a:	9281                	srli	a3,a3,0x20
    80000d5c:	00d58733          	add	a4,a1,a3
    80000d60:	fce57be3          	bgeu	a0,a4,80000d36 <memmove+0xc>
    d += n;
    80000d64:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d66:	fff6079b          	addiw	a5,a2,-1
    80000d6a:	1782                	slli	a5,a5,0x20
    80000d6c:	9381                	srli	a5,a5,0x20
    80000d6e:	fff7c793          	not	a5,a5
    80000d72:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d74:	177d                	addi	a4,a4,-1
    80000d76:	16fd                	addi	a3,a3,-1
    80000d78:	00074603          	lbu	a2,0(a4)
    80000d7c:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d80:	fee79ae3          	bne	a5,a4,80000d74 <memmove+0x4a>
    80000d84:	b7f1                	j	80000d50 <memmove+0x26>

0000000080000d86 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d86:	1141                	addi	sp,sp,-16
    80000d88:	e406                	sd	ra,8(sp)
    80000d8a:	e022                	sd	s0,0(sp)
    80000d8c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d8e:	00000097          	auipc	ra,0x0
    80000d92:	f9c080e7          	jalr	-100(ra) # 80000d2a <memmove>
}
    80000d96:	60a2                	ld	ra,8(sp)
    80000d98:	6402                	ld	s0,0(sp)
    80000d9a:	0141                	addi	sp,sp,16
    80000d9c:	8082                	ret

0000000080000d9e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d9e:	1141                	addi	sp,sp,-16
    80000da0:	e422                	sd	s0,8(sp)
    80000da2:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da4:	ce11                	beqz	a2,80000dc0 <strncmp+0x22>
    80000da6:	00054783          	lbu	a5,0(a0)
    80000daa:	cf89                	beqz	a5,80000dc4 <strncmp+0x26>
    80000dac:	0005c703          	lbu	a4,0(a1)
    80000db0:	00f71a63          	bne	a4,a5,80000dc4 <strncmp+0x26>
    n--, p++, q++;
    80000db4:	367d                	addiw	a2,a2,-1
    80000db6:	0505                	addi	a0,a0,1
    80000db8:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dba:	f675                	bnez	a2,80000da6 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dbc:	4501                	li	a0,0
    80000dbe:	a809                	j	80000dd0 <strncmp+0x32>
    80000dc0:	4501                	li	a0,0
    80000dc2:	a039                	j	80000dd0 <strncmp+0x32>
  if(n == 0)
    80000dc4:	ca09                	beqz	a2,80000dd6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dc6:	00054503          	lbu	a0,0(a0)
    80000dca:	0005c783          	lbu	a5,0(a1)
    80000dce:	9d1d                	subw	a0,a0,a5
}
    80000dd0:	6422                	ld	s0,8(sp)
    80000dd2:	0141                	addi	sp,sp,16
    80000dd4:	8082                	ret
    return 0;
    80000dd6:	4501                	li	a0,0
    80000dd8:	bfe5                	j	80000dd0 <strncmp+0x32>

0000000080000dda <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dda:	1141                	addi	sp,sp,-16
    80000ddc:	e422                	sd	s0,8(sp)
    80000dde:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de0:	87aa                	mv	a5,a0
    80000de2:	86b2                	mv	a3,a2
    80000de4:	367d                	addiw	a2,a2,-1
    80000de6:	00d05963          	blez	a3,80000df8 <strncpy+0x1e>
    80000dea:	0785                	addi	a5,a5,1
    80000dec:	0005c703          	lbu	a4,0(a1)
    80000df0:	fee78fa3          	sb	a4,-1(a5)
    80000df4:	0585                	addi	a1,a1,1
    80000df6:	f775                	bnez	a4,80000de2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df8:	873e                	mv	a4,a5
    80000dfa:	9fb5                	addw	a5,a5,a3
    80000dfc:	37fd                	addiw	a5,a5,-1
    80000dfe:	00c05963          	blez	a2,80000e10 <strncpy+0x36>
    *s++ = 0;
    80000e02:	0705                	addi	a4,a4,1
    80000e04:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e08:	40e786bb          	subw	a3,a5,a4
    80000e0c:	fed04be3          	bgtz	a3,80000e02 <strncpy+0x28>
  return os;
}
    80000e10:	6422                	ld	s0,8(sp)
    80000e12:	0141                	addi	sp,sp,16
    80000e14:	8082                	ret

0000000080000e16 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e16:	1141                	addi	sp,sp,-16
    80000e18:	e422                	sd	s0,8(sp)
    80000e1a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e1c:	02c05363          	blez	a2,80000e42 <safestrcpy+0x2c>
    80000e20:	fff6069b          	addiw	a3,a2,-1
    80000e24:	1682                	slli	a3,a3,0x20
    80000e26:	9281                	srli	a3,a3,0x20
    80000e28:	96ae                	add	a3,a3,a1
    80000e2a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e2c:	00d58963          	beq	a1,a3,80000e3e <safestrcpy+0x28>
    80000e30:	0585                	addi	a1,a1,1
    80000e32:	0785                	addi	a5,a5,1
    80000e34:	fff5c703          	lbu	a4,-1(a1)
    80000e38:	fee78fa3          	sb	a4,-1(a5)
    80000e3c:	fb65                	bnez	a4,80000e2c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e3e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e42:	6422                	ld	s0,8(sp)
    80000e44:	0141                	addi	sp,sp,16
    80000e46:	8082                	ret

0000000080000e48 <strlen>:

int
strlen(const char *s)
{
    80000e48:	1141                	addi	sp,sp,-16
    80000e4a:	e422                	sd	s0,8(sp)
    80000e4c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e4e:	00054783          	lbu	a5,0(a0)
    80000e52:	cf91                	beqz	a5,80000e6e <strlen+0x26>
    80000e54:	0505                	addi	a0,a0,1
    80000e56:	87aa                	mv	a5,a0
    80000e58:	86be                	mv	a3,a5
    80000e5a:	0785                	addi	a5,a5,1
    80000e5c:	fff7c703          	lbu	a4,-1(a5)
    80000e60:	ff65                	bnez	a4,80000e58 <strlen+0x10>
    80000e62:	40a6853b          	subw	a0,a3,a0
    80000e66:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e68:	6422                	ld	s0,8(sp)
    80000e6a:	0141                	addi	sp,sp,16
    80000e6c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e6e:	4501                	li	a0,0
    80000e70:	bfe5                	j	80000e68 <strlen+0x20>

0000000080000e72 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e72:	1141                	addi	sp,sp,-16
    80000e74:	e406                	sd	ra,8(sp)
    80000e76:	e022                	sd	s0,0(sp)
    80000e78:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e7a:	00001097          	auipc	ra,0x1
    80000e7e:	b00080e7          	jalr	-1280(ra) # 8000197a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e82:	00008717          	auipc	a4,0x8
    80000e86:	c6670713          	addi	a4,a4,-922 # 80008ae8 <started>
  if(cpuid() == 0){
    80000e8a:	c139                	beqz	a0,80000ed0 <main+0x5e>
    while(started == 0)
    80000e8c:	431c                	lw	a5,0(a4)
    80000e8e:	2781                	sext.w	a5,a5
    80000e90:	dff5                	beqz	a5,80000e8c <main+0x1a>
      ;
    __sync_synchronize();
    80000e92:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e96:	00001097          	auipc	ra,0x1
    80000e9a:	ae4080e7          	jalr	-1308(ra) # 8000197a <cpuid>
    80000e9e:	85aa                	mv	a1,a0
    80000ea0:	00007517          	auipc	a0,0x7
    80000ea4:	21850513          	addi	a0,a0,536 # 800080b8 <digits+0x78>
    80000ea8:	fffff097          	auipc	ra,0xfffff
    80000eac:	6de080e7          	jalr	1758(ra) # 80000586 <printf>
    kvminithart();    // turn on paging
    80000eb0:	00000097          	auipc	ra,0x0
    80000eb4:	0d8080e7          	jalr	216(ra) # 80000f88 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb8:	00001097          	auipc	ra,0x1
    80000ebc:	7ae080e7          	jalr	1966(ra) # 80002666 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	f20080e7          	jalr	-224(ra) # 80005de0 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	ff4080e7          	jalr	-12(ra) # 80001ebc <scheduler>
    consoleinit();
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	57c080e7          	jalr	1404(ra) # 8000044c <consoleinit>
    printfinit();
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	88e080e7          	jalr	-1906(ra) # 80000766 <printfinit>
    printf("\n");
    80000ee0:	00007517          	auipc	a0,0x7
    80000ee4:	1e850513          	addi	a0,a0,488 # 800080c8 <digits+0x88>
    80000ee8:	fffff097          	auipc	ra,0xfffff
    80000eec:	69e080e7          	jalr	1694(ra) # 80000586 <printf>
    printf("xv6 kernel is booting\n");
    80000ef0:	00007517          	auipc	a0,0x7
    80000ef4:	1b050513          	addi	a0,a0,432 # 800080a0 <digits+0x60>
    80000ef8:	fffff097          	auipc	ra,0xfffff
    80000efc:	68e080e7          	jalr	1678(ra) # 80000586 <printf>
    printf("\n");
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	1c850513          	addi	a0,a0,456 # 800080c8 <digits+0x88>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	67e080e7          	jalr	1662(ra) # 80000586 <printf>
    kinit();         // physical page allocator
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	b96080e7          	jalr	-1130(ra) # 80000aa6 <kinit>
    kvminit();       // create kernel page table
    80000f18:	00000097          	auipc	ra,0x0
    80000f1c:	326080e7          	jalr	806(ra) # 8000123e <kvminit>
    kvminithart();   // turn on paging
    80000f20:	00000097          	auipc	ra,0x0
    80000f24:	068080e7          	jalr	104(ra) # 80000f88 <kvminithart>
    procinit();      // process table
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	99e080e7          	jalr	-1634(ra) # 800018c6 <procinit>
    trapinit();      // trap vectors
    80000f30:	00001097          	auipc	ra,0x1
    80000f34:	70e080e7          	jalr	1806(ra) # 8000263e <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00001097          	auipc	ra,0x1
    80000f3c:	72e080e7          	jalr	1838(ra) # 80002666 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	e8a080e7          	jalr	-374(ra) # 80005dca <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	e98080e7          	jalr	-360(ra) # 80005de0 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	098080e7          	jalr	152(ra) # 80002fe8 <binit>
    iinit();         // inode table
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	736080e7          	jalr	1846(ra) # 8000368e <iinit>
    fileinit();      // file table
    80000f60:	00003097          	auipc	ra,0x3
    80000f64:	6ac080e7          	jalr	1708(ra) # 8000460c <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	f80080e7          	jalr	-128(ra) # 80005ee8 <virtio_disk_init>
    userinit();      // first user process
    80000f70:	00001097          	auipc	ra,0x1
    80000f74:	d26080e7          	jalr	-730(ra) # 80001c96 <userinit>
    __sync_synchronize();
    80000f78:	0ff0000f          	fence
    started = 1;
    80000f7c:	4785                	li	a5,1
    80000f7e:	00008717          	auipc	a4,0x8
    80000f82:	b6f72523          	sw	a5,-1174(a4) # 80008ae8 <started>
    80000f86:	b789                	j	80000ec8 <main+0x56>

0000000080000f88 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f88:	1141                	addi	sp,sp,-16
    80000f8a:	e422                	sd	s0,8(sp)
    80000f8c:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f8e:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f92:	00008797          	auipc	a5,0x8
    80000f96:	b5e7b783          	ld	a5,-1186(a5) # 80008af0 <kernel_pagetable>
    80000f9a:	83b1                	srli	a5,a5,0xc
    80000f9c:	577d                	li	a4,-1
    80000f9e:	177e                	slli	a4,a4,0x3f
    80000fa0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa2:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fa6:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000faa:	6422                	ld	s0,8(sp)
    80000fac:	0141                	addi	sp,sp,16
    80000fae:	8082                	ret

0000000080000fb0 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb0:	7139                	addi	sp,sp,-64
    80000fb2:	fc06                	sd	ra,56(sp)
    80000fb4:	f822                	sd	s0,48(sp)
    80000fb6:	f426                	sd	s1,40(sp)
    80000fb8:	f04a                	sd	s2,32(sp)
    80000fba:	ec4e                	sd	s3,24(sp)
    80000fbc:	e852                	sd	s4,16(sp)
    80000fbe:	e456                	sd	s5,8(sp)
    80000fc0:	e05a                	sd	s6,0(sp)
    80000fc2:	0080                	addi	s0,sp,64
    80000fc4:	84aa                	mv	s1,a0
    80000fc6:	89ae                	mv	s3,a1
    80000fc8:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fca:	57fd                	li	a5,-1
    80000fcc:	83e9                	srli	a5,a5,0x1a
    80000fce:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd0:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd2:	04b7f263          	bgeu	a5,a1,80001016 <walk+0x66>
    panic("walk");
    80000fd6:	00007517          	auipc	a0,0x7
    80000fda:	0fa50513          	addi	a0,a0,250 # 800080d0 <digits+0x90>
    80000fde:	fffff097          	auipc	ra,0xfffff
    80000fe2:	55e080e7          	jalr	1374(ra) # 8000053c <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fe6:	060a8663          	beqz	s5,80001052 <walk+0xa2>
    80000fea:	00000097          	auipc	ra,0x0
    80000fee:	af8080e7          	jalr	-1288(ra) # 80000ae2 <kalloc>
    80000ff2:	84aa                	mv	s1,a0
    80000ff4:	c529                	beqz	a0,8000103e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ff6:	6605                	lui	a2,0x1
    80000ff8:	4581                	li	a1,0
    80000ffa:	00000097          	auipc	ra,0x0
    80000ffe:	cd4080e7          	jalr	-812(ra) # 80000cce <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001002:	00c4d793          	srli	a5,s1,0xc
    80001006:	07aa                	slli	a5,a5,0xa
    80001008:	0017e793          	ori	a5,a5,1
    8000100c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001010:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdc877>
    80001012:	036a0063          	beq	s4,s6,80001032 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001016:	0149d933          	srl	s2,s3,s4
    8000101a:	1ff97913          	andi	s2,s2,511
    8000101e:	090e                	slli	s2,s2,0x3
    80001020:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001022:	00093483          	ld	s1,0(s2)
    80001026:	0014f793          	andi	a5,s1,1
    8000102a:	dfd5                	beqz	a5,80000fe6 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000102c:	80a9                	srli	s1,s1,0xa
    8000102e:	04b2                	slli	s1,s1,0xc
    80001030:	b7c5                	j	80001010 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001032:	00c9d513          	srli	a0,s3,0xc
    80001036:	1ff57513          	andi	a0,a0,511
    8000103a:	050e                	slli	a0,a0,0x3
    8000103c:	9526                	add	a0,a0,s1
}
    8000103e:	70e2                	ld	ra,56(sp)
    80001040:	7442                	ld	s0,48(sp)
    80001042:	74a2                	ld	s1,40(sp)
    80001044:	7902                	ld	s2,32(sp)
    80001046:	69e2                	ld	s3,24(sp)
    80001048:	6a42                	ld	s4,16(sp)
    8000104a:	6aa2                	ld	s5,8(sp)
    8000104c:	6b02                	ld	s6,0(sp)
    8000104e:	6121                	addi	sp,sp,64
    80001050:	8082                	ret
        return 0;
    80001052:	4501                	li	a0,0
    80001054:	b7ed                	j	8000103e <walk+0x8e>

0000000080001056 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001056:	57fd                	li	a5,-1
    80001058:	83e9                	srli	a5,a5,0x1a
    8000105a:	00b7f463          	bgeu	a5,a1,80001062 <walkaddr+0xc>
    return 0;
    8000105e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001060:	8082                	ret
{
    80001062:	1141                	addi	sp,sp,-16
    80001064:	e406                	sd	ra,8(sp)
    80001066:	e022                	sd	s0,0(sp)
    80001068:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000106a:	4601                	li	a2,0
    8000106c:	00000097          	auipc	ra,0x0
    80001070:	f44080e7          	jalr	-188(ra) # 80000fb0 <walk>
  if(pte == 0)
    80001074:	c105                	beqz	a0,80001094 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001076:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001078:	0117f693          	andi	a3,a5,17
    8000107c:	4745                	li	a4,17
    return 0;
    8000107e:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001080:	00e68663          	beq	a3,a4,8000108c <walkaddr+0x36>
}
    80001084:	60a2                	ld	ra,8(sp)
    80001086:	6402                	ld	s0,0(sp)
    80001088:	0141                	addi	sp,sp,16
    8000108a:	8082                	ret
  pa = PTE2PA(*pte);
    8000108c:	83a9                	srli	a5,a5,0xa
    8000108e:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001092:	bfcd                	j	80001084 <walkaddr+0x2e>
    return 0;
    80001094:	4501                	li	a0,0
    80001096:	b7fd                	j	80001084 <walkaddr+0x2e>

0000000080001098 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001098:	715d                	addi	sp,sp,-80
    8000109a:	e486                	sd	ra,72(sp)
    8000109c:	e0a2                	sd	s0,64(sp)
    8000109e:	fc26                	sd	s1,56(sp)
    800010a0:	f84a                	sd	s2,48(sp)
    800010a2:	f44e                	sd	s3,40(sp)
    800010a4:	f052                	sd	s4,32(sp)
    800010a6:	ec56                	sd	s5,24(sp)
    800010a8:	e85a                	sd	s6,16(sp)
    800010aa:	e45e                	sd	s7,8(sp)
    800010ac:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010ae:	c639                	beqz	a2,800010fc <mappages+0x64>
    800010b0:	8aaa                	mv	s5,a0
    800010b2:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010b4:	777d                	lui	a4,0xfffff
    800010b6:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010ba:	fff58993          	addi	s3,a1,-1
    800010be:	99b2                	add	s3,s3,a2
    800010c0:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010c4:	893e                	mv	s2,a5
    800010c6:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010ca:	6b85                	lui	s7,0x1
    800010cc:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d0:	4605                	li	a2,1
    800010d2:	85ca                	mv	a1,s2
    800010d4:	8556                	mv	a0,s5
    800010d6:	00000097          	auipc	ra,0x0
    800010da:	eda080e7          	jalr	-294(ra) # 80000fb0 <walk>
    800010de:	cd1d                	beqz	a0,8000111c <mappages+0x84>
    if(*pte & PTE_V)
    800010e0:	611c                	ld	a5,0(a0)
    800010e2:	8b85                	andi	a5,a5,1
    800010e4:	e785                	bnez	a5,8000110c <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010e6:	80b1                	srli	s1,s1,0xc
    800010e8:	04aa                	slli	s1,s1,0xa
    800010ea:	0164e4b3          	or	s1,s1,s6
    800010ee:	0014e493          	ori	s1,s1,1
    800010f2:	e104                	sd	s1,0(a0)
    if(a == last)
    800010f4:	05390063          	beq	s2,s3,80001134 <mappages+0x9c>
    a += PGSIZE;
    800010f8:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010fa:	bfc9                	j	800010cc <mappages+0x34>
    panic("mappages: size");
    800010fc:	00007517          	auipc	a0,0x7
    80001100:	fdc50513          	addi	a0,a0,-36 # 800080d8 <digits+0x98>
    80001104:	fffff097          	auipc	ra,0xfffff
    80001108:	438080e7          	jalr	1080(ra) # 8000053c <panic>
      panic("mappages: remap");
    8000110c:	00007517          	auipc	a0,0x7
    80001110:	fdc50513          	addi	a0,a0,-36 # 800080e8 <digits+0xa8>
    80001114:	fffff097          	auipc	ra,0xfffff
    80001118:	428080e7          	jalr	1064(ra) # 8000053c <panic>
      return -1;
    8000111c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000111e:	60a6                	ld	ra,72(sp)
    80001120:	6406                	ld	s0,64(sp)
    80001122:	74e2                	ld	s1,56(sp)
    80001124:	7942                	ld	s2,48(sp)
    80001126:	79a2                	ld	s3,40(sp)
    80001128:	7a02                	ld	s4,32(sp)
    8000112a:	6ae2                	ld	s5,24(sp)
    8000112c:	6b42                	ld	s6,16(sp)
    8000112e:	6ba2                	ld	s7,8(sp)
    80001130:	6161                	addi	sp,sp,80
    80001132:	8082                	ret
  return 0;
    80001134:	4501                	li	a0,0
    80001136:	b7e5                	j	8000111e <mappages+0x86>

0000000080001138 <kvmmap>:
{
    80001138:	1141                	addi	sp,sp,-16
    8000113a:	e406                	sd	ra,8(sp)
    8000113c:	e022                	sd	s0,0(sp)
    8000113e:	0800                	addi	s0,sp,16
    80001140:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001142:	86b2                	mv	a3,a2
    80001144:	863e                	mv	a2,a5
    80001146:	00000097          	auipc	ra,0x0
    8000114a:	f52080e7          	jalr	-174(ra) # 80001098 <mappages>
    8000114e:	e509                	bnez	a0,80001158 <kvmmap+0x20>
}
    80001150:	60a2                	ld	ra,8(sp)
    80001152:	6402                	ld	s0,0(sp)
    80001154:	0141                	addi	sp,sp,16
    80001156:	8082                	ret
    panic("kvmmap");
    80001158:	00007517          	auipc	a0,0x7
    8000115c:	fa050513          	addi	a0,a0,-96 # 800080f8 <digits+0xb8>
    80001160:	fffff097          	auipc	ra,0xfffff
    80001164:	3dc080e7          	jalr	988(ra) # 8000053c <panic>

0000000080001168 <kvmmake>:
{
    80001168:	1101                	addi	sp,sp,-32
    8000116a:	ec06                	sd	ra,24(sp)
    8000116c:	e822                	sd	s0,16(sp)
    8000116e:	e426                	sd	s1,8(sp)
    80001170:	e04a                	sd	s2,0(sp)
    80001172:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001174:	00000097          	auipc	ra,0x0
    80001178:	96e080e7          	jalr	-1682(ra) # 80000ae2 <kalloc>
    8000117c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000117e:	6605                	lui	a2,0x1
    80001180:	4581                	li	a1,0
    80001182:	00000097          	auipc	ra,0x0
    80001186:	b4c080e7          	jalr	-1204(ra) # 80000cce <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000118a:	4719                	li	a4,6
    8000118c:	6685                	lui	a3,0x1
    8000118e:	10000637          	lui	a2,0x10000
    80001192:	100005b7          	lui	a1,0x10000
    80001196:	8526                	mv	a0,s1
    80001198:	00000097          	auipc	ra,0x0
    8000119c:	fa0080e7          	jalr	-96(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a0:	4719                	li	a4,6
    800011a2:	6685                	lui	a3,0x1
    800011a4:	10001637          	lui	a2,0x10001
    800011a8:	100015b7          	lui	a1,0x10001
    800011ac:	8526                	mv	a0,s1
    800011ae:	00000097          	auipc	ra,0x0
    800011b2:	f8a080e7          	jalr	-118(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011b6:	4719                	li	a4,6
    800011b8:	004006b7          	lui	a3,0x400
    800011bc:	0c000637          	lui	a2,0xc000
    800011c0:	0c0005b7          	lui	a1,0xc000
    800011c4:	8526                	mv	a0,s1
    800011c6:	00000097          	auipc	ra,0x0
    800011ca:	f72080e7          	jalr	-142(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011ce:	00007917          	auipc	s2,0x7
    800011d2:	e3290913          	addi	s2,s2,-462 # 80008000 <etext>
    800011d6:	4729                	li	a4,10
    800011d8:	80007697          	auipc	a3,0x80007
    800011dc:	e2868693          	addi	a3,a3,-472 # 8000 <_entry-0x7fff8000>
    800011e0:	4605                	li	a2,1
    800011e2:	067e                	slli	a2,a2,0x1f
    800011e4:	85b2                	mv	a1,a2
    800011e6:	8526                	mv	a0,s1
    800011e8:	00000097          	auipc	ra,0x0
    800011ec:	f50080e7          	jalr	-176(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f0:	4719                	li	a4,6
    800011f2:	46c5                	li	a3,17
    800011f4:	06ee                	slli	a3,a3,0x1b
    800011f6:	412686b3          	sub	a3,a3,s2
    800011fa:	864a                	mv	a2,s2
    800011fc:	85ca                	mv	a1,s2
    800011fe:	8526                	mv	a0,s1
    80001200:	00000097          	auipc	ra,0x0
    80001204:	f38080e7          	jalr	-200(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001208:	4729                	li	a4,10
    8000120a:	6685                	lui	a3,0x1
    8000120c:	00006617          	auipc	a2,0x6
    80001210:	df460613          	addi	a2,a2,-524 # 80007000 <_trampoline>
    80001214:	040005b7          	lui	a1,0x4000
    80001218:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000121a:	05b2                	slli	a1,a1,0xc
    8000121c:	8526                	mv	a0,s1
    8000121e:	00000097          	auipc	ra,0x0
    80001222:	f1a080e7          	jalr	-230(ra) # 80001138 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001226:	8526                	mv	a0,s1
    80001228:	00000097          	auipc	ra,0x0
    8000122c:	608080e7          	jalr	1544(ra) # 80001830 <proc_mapstacks>
}
    80001230:	8526                	mv	a0,s1
    80001232:	60e2                	ld	ra,24(sp)
    80001234:	6442                	ld	s0,16(sp)
    80001236:	64a2                	ld	s1,8(sp)
    80001238:	6902                	ld	s2,0(sp)
    8000123a:	6105                	addi	sp,sp,32
    8000123c:	8082                	ret

000000008000123e <kvminit>:
{
    8000123e:	1141                	addi	sp,sp,-16
    80001240:	e406                	sd	ra,8(sp)
    80001242:	e022                	sd	s0,0(sp)
    80001244:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001246:	00000097          	auipc	ra,0x0
    8000124a:	f22080e7          	jalr	-222(ra) # 80001168 <kvmmake>
    8000124e:	00008797          	auipc	a5,0x8
    80001252:	8aa7b123          	sd	a0,-1886(a5) # 80008af0 <kernel_pagetable>
}
    80001256:	60a2                	ld	ra,8(sp)
    80001258:	6402                	ld	s0,0(sp)
    8000125a:	0141                	addi	sp,sp,16
    8000125c:	8082                	ret

000000008000125e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000125e:	715d                	addi	sp,sp,-80
    80001260:	e486                	sd	ra,72(sp)
    80001262:	e0a2                	sd	s0,64(sp)
    80001264:	fc26                	sd	s1,56(sp)
    80001266:	f84a                	sd	s2,48(sp)
    80001268:	f44e                	sd	s3,40(sp)
    8000126a:	f052                	sd	s4,32(sp)
    8000126c:	ec56                	sd	s5,24(sp)
    8000126e:	e85a                	sd	s6,16(sp)
    80001270:	e45e                	sd	s7,8(sp)
    80001272:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001274:	03459793          	slli	a5,a1,0x34
    80001278:	e795                	bnez	a5,800012a4 <uvmunmap+0x46>
    8000127a:	8a2a                	mv	s4,a0
    8000127c:	892e                	mv	s2,a1
    8000127e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001280:	0632                	slli	a2,a2,0xc
    80001282:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001286:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001288:	6b05                	lui	s6,0x1
    8000128a:	0735e263          	bltu	a1,s3,800012ee <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000128e:	60a6                	ld	ra,72(sp)
    80001290:	6406                	ld	s0,64(sp)
    80001292:	74e2                	ld	s1,56(sp)
    80001294:	7942                	ld	s2,48(sp)
    80001296:	79a2                	ld	s3,40(sp)
    80001298:	7a02                	ld	s4,32(sp)
    8000129a:	6ae2                	ld	s5,24(sp)
    8000129c:	6b42                	ld	s6,16(sp)
    8000129e:	6ba2                	ld	s7,8(sp)
    800012a0:	6161                	addi	sp,sp,80
    800012a2:	8082                	ret
    panic("uvmunmap: not aligned");
    800012a4:	00007517          	auipc	a0,0x7
    800012a8:	e5c50513          	addi	a0,a0,-420 # 80008100 <digits+0xc0>
    800012ac:	fffff097          	auipc	ra,0xfffff
    800012b0:	290080e7          	jalr	656(ra) # 8000053c <panic>
      panic("uvmunmap: walk");
    800012b4:	00007517          	auipc	a0,0x7
    800012b8:	e6450513          	addi	a0,a0,-412 # 80008118 <digits+0xd8>
    800012bc:	fffff097          	auipc	ra,0xfffff
    800012c0:	280080e7          	jalr	640(ra) # 8000053c <panic>
      panic("uvmunmap: not mapped");
    800012c4:	00007517          	auipc	a0,0x7
    800012c8:	e6450513          	addi	a0,a0,-412 # 80008128 <digits+0xe8>
    800012cc:	fffff097          	auipc	ra,0xfffff
    800012d0:	270080e7          	jalr	624(ra) # 8000053c <panic>
      panic("uvmunmap: not a leaf");
    800012d4:	00007517          	auipc	a0,0x7
    800012d8:	e6c50513          	addi	a0,a0,-404 # 80008140 <digits+0x100>
    800012dc:	fffff097          	auipc	ra,0xfffff
    800012e0:	260080e7          	jalr	608(ra) # 8000053c <panic>
    *pte = 0;
    800012e4:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e8:	995a                	add	s2,s2,s6
    800012ea:	fb3972e3          	bgeu	s2,s3,8000128e <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012ee:	4601                	li	a2,0
    800012f0:	85ca                	mv	a1,s2
    800012f2:	8552                	mv	a0,s4
    800012f4:	00000097          	auipc	ra,0x0
    800012f8:	cbc080e7          	jalr	-836(ra) # 80000fb0 <walk>
    800012fc:	84aa                	mv	s1,a0
    800012fe:	d95d                	beqz	a0,800012b4 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001300:	6108                	ld	a0,0(a0)
    80001302:	00157793          	andi	a5,a0,1
    80001306:	dfdd                	beqz	a5,800012c4 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001308:	3ff57793          	andi	a5,a0,1023
    8000130c:	fd7784e3          	beq	a5,s7,800012d4 <uvmunmap+0x76>
    if(do_free){
    80001310:	fc0a8ae3          	beqz	s5,800012e4 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001314:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001316:	0532                	slli	a0,a0,0xc
    80001318:	fffff097          	auipc	ra,0xfffff
    8000131c:	6cc080e7          	jalr	1740(ra) # 800009e4 <kfree>
    80001320:	b7d1                	j	800012e4 <uvmunmap+0x86>

0000000080001322 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001322:	1101                	addi	sp,sp,-32
    80001324:	ec06                	sd	ra,24(sp)
    80001326:	e822                	sd	s0,16(sp)
    80001328:	e426                	sd	s1,8(sp)
    8000132a:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000132c:	fffff097          	auipc	ra,0xfffff
    80001330:	7b6080e7          	jalr	1974(ra) # 80000ae2 <kalloc>
    80001334:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001336:	c519                	beqz	a0,80001344 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001338:	6605                	lui	a2,0x1
    8000133a:	4581                	li	a1,0
    8000133c:	00000097          	auipc	ra,0x0
    80001340:	992080e7          	jalr	-1646(ra) # 80000cce <memset>
  return pagetable;
}
    80001344:	8526                	mv	a0,s1
    80001346:	60e2                	ld	ra,24(sp)
    80001348:	6442                	ld	s0,16(sp)
    8000134a:	64a2                	ld	s1,8(sp)
    8000134c:	6105                	addi	sp,sp,32
    8000134e:	8082                	ret

0000000080001350 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001350:	7179                	addi	sp,sp,-48
    80001352:	f406                	sd	ra,40(sp)
    80001354:	f022                	sd	s0,32(sp)
    80001356:	ec26                	sd	s1,24(sp)
    80001358:	e84a                	sd	s2,16(sp)
    8000135a:	e44e                	sd	s3,8(sp)
    8000135c:	e052                	sd	s4,0(sp)
    8000135e:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001360:	6785                	lui	a5,0x1
    80001362:	04f67863          	bgeu	a2,a5,800013b2 <uvmfirst+0x62>
    80001366:	8a2a                	mv	s4,a0
    80001368:	89ae                	mv	s3,a1
    8000136a:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000136c:	fffff097          	auipc	ra,0xfffff
    80001370:	776080e7          	jalr	1910(ra) # 80000ae2 <kalloc>
    80001374:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001376:	6605                	lui	a2,0x1
    80001378:	4581                	li	a1,0
    8000137a:	00000097          	auipc	ra,0x0
    8000137e:	954080e7          	jalr	-1708(ra) # 80000cce <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001382:	4779                	li	a4,30
    80001384:	86ca                	mv	a3,s2
    80001386:	6605                	lui	a2,0x1
    80001388:	4581                	li	a1,0
    8000138a:	8552                	mv	a0,s4
    8000138c:	00000097          	auipc	ra,0x0
    80001390:	d0c080e7          	jalr	-756(ra) # 80001098 <mappages>
  memmove(mem, src, sz);
    80001394:	8626                	mv	a2,s1
    80001396:	85ce                	mv	a1,s3
    80001398:	854a                	mv	a0,s2
    8000139a:	00000097          	auipc	ra,0x0
    8000139e:	990080e7          	jalr	-1648(ra) # 80000d2a <memmove>
}
    800013a2:	70a2                	ld	ra,40(sp)
    800013a4:	7402                	ld	s0,32(sp)
    800013a6:	64e2                	ld	s1,24(sp)
    800013a8:	6942                	ld	s2,16(sp)
    800013aa:	69a2                	ld	s3,8(sp)
    800013ac:	6a02                	ld	s4,0(sp)
    800013ae:	6145                	addi	sp,sp,48
    800013b0:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b2:	00007517          	auipc	a0,0x7
    800013b6:	da650513          	addi	a0,a0,-602 # 80008158 <digits+0x118>
    800013ba:	fffff097          	auipc	ra,0xfffff
    800013be:	182080e7          	jalr	386(ra) # 8000053c <panic>

00000000800013c2 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c2:	1101                	addi	sp,sp,-32
    800013c4:	ec06                	sd	ra,24(sp)
    800013c6:	e822                	sd	s0,16(sp)
    800013c8:	e426                	sd	s1,8(sp)
    800013ca:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013cc:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013ce:	00b67d63          	bgeu	a2,a1,800013e8 <uvmdealloc+0x26>
    800013d2:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013d4:	6785                	lui	a5,0x1
    800013d6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013d8:	00f60733          	add	a4,a2,a5
    800013dc:	76fd                	lui	a3,0xfffff
    800013de:	8f75                	and	a4,a4,a3
    800013e0:	97ae                	add	a5,a5,a1
    800013e2:	8ff5                	and	a5,a5,a3
    800013e4:	00f76863          	bltu	a4,a5,800013f4 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013e8:	8526                	mv	a0,s1
    800013ea:	60e2                	ld	ra,24(sp)
    800013ec:	6442                	ld	s0,16(sp)
    800013ee:	64a2                	ld	s1,8(sp)
    800013f0:	6105                	addi	sp,sp,32
    800013f2:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013f4:	8f99                	sub	a5,a5,a4
    800013f6:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013f8:	4685                	li	a3,1
    800013fa:	0007861b          	sext.w	a2,a5
    800013fe:	85ba                	mv	a1,a4
    80001400:	00000097          	auipc	ra,0x0
    80001404:	e5e080e7          	jalr	-418(ra) # 8000125e <uvmunmap>
    80001408:	b7c5                	j	800013e8 <uvmdealloc+0x26>

000000008000140a <uvmalloc>:
  if(newsz < oldsz)
    8000140a:	0ab66563          	bltu	a2,a1,800014b4 <uvmalloc+0xaa>
{
    8000140e:	7139                	addi	sp,sp,-64
    80001410:	fc06                	sd	ra,56(sp)
    80001412:	f822                	sd	s0,48(sp)
    80001414:	f426                	sd	s1,40(sp)
    80001416:	f04a                	sd	s2,32(sp)
    80001418:	ec4e                	sd	s3,24(sp)
    8000141a:	e852                	sd	s4,16(sp)
    8000141c:	e456                	sd	s5,8(sp)
    8000141e:	e05a                	sd	s6,0(sp)
    80001420:	0080                	addi	s0,sp,64
    80001422:	8aaa                	mv	s5,a0
    80001424:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001426:	6785                	lui	a5,0x1
    80001428:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000142a:	95be                	add	a1,a1,a5
    8000142c:	77fd                	lui	a5,0xfffff
    8000142e:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001432:	08c9f363          	bgeu	s3,a2,800014b8 <uvmalloc+0xae>
    80001436:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001438:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000143c:	fffff097          	auipc	ra,0xfffff
    80001440:	6a6080e7          	jalr	1702(ra) # 80000ae2 <kalloc>
    80001444:	84aa                	mv	s1,a0
    if(mem == 0){
    80001446:	c51d                	beqz	a0,80001474 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001448:	6605                	lui	a2,0x1
    8000144a:	4581                	li	a1,0
    8000144c:	00000097          	auipc	ra,0x0
    80001450:	882080e7          	jalr	-1918(ra) # 80000cce <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001454:	875a                	mv	a4,s6
    80001456:	86a6                	mv	a3,s1
    80001458:	6605                	lui	a2,0x1
    8000145a:	85ca                	mv	a1,s2
    8000145c:	8556                	mv	a0,s5
    8000145e:	00000097          	auipc	ra,0x0
    80001462:	c3a080e7          	jalr	-966(ra) # 80001098 <mappages>
    80001466:	e90d                	bnez	a0,80001498 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001468:	6785                	lui	a5,0x1
    8000146a:	993e                	add	s2,s2,a5
    8000146c:	fd4968e3          	bltu	s2,s4,8000143c <uvmalloc+0x32>
  return newsz;
    80001470:	8552                	mv	a0,s4
    80001472:	a809                	j	80001484 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001474:	864e                	mv	a2,s3
    80001476:	85ca                	mv	a1,s2
    80001478:	8556                	mv	a0,s5
    8000147a:	00000097          	auipc	ra,0x0
    8000147e:	f48080e7          	jalr	-184(ra) # 800013c2 <uvmdealloc>
      return 0;
    80001482:	4501                	li	a0,0
}
    80001484:	70e2                	ld	ra,56(sp)
    80001486:	7442                	ld	s0,48(sp)
    80001488:	74a2                	ld	s1,40(sp)
    8000148a:	7902                	ld	s2,32(sp)
    8000148c:	69e2                	ld	s3,24(sp)
    8000148e:	6a42                	ld	s4,16(sp)
    80001490:	6aa2                	ld	s5,8(sp)
    80001492:	6b02                	ld	s6,0(sp)
    80001494:	6121                	addi	sp,sp,64
    80001496:	8082                	ret
      kfree(mem);
    80001498:	8526                	mv	a0,s1
    8000149a:	fffff097          	auipc	ra,0xfffff
    8000149e:	54a080e7          	jalr	1354(ra) # 800009e4 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a2:	864e                	mv	a2,s3
    800014a4:	85ca                	mv	a1,s2
    800014a6:	8556                	mv	a0,s5
    800014a8:	00000097          	auipc	ra,0x0
    800014ac:	f1a080e7          	jalr	-230(ra) # 800013c2 <uvmdealloc>
      return 0;
    800014b0:	4501                	li	a0,0
    800014b2:	bfc9                	j	80001484 <uvmalloc+0x7a>
    return oldsz;
    800014b4:	852e                	mv	a0,a1
}
    800014b6:	8082                	ret
  return newsz;
    800014b8:	8532                	mv	a0,a2
    800014ba:	b7e9                	j	80001484 <uvmalloc+0x7a>

00000000800014bc <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014bc:	7179                	addi	sp,sp,-48
    800014be:	f406                	sd	ra,40(sp)
    800014c0:	f022                	sd	s0,32(sp)
    800014c2:	ec26                	sd	s1,24(sp)
    800014c4:	e84a                	sd	s2,16(sp)
    800014c6:	e44e                	sd	s3,8(sp)
    800014c8:	e052                	sd	s4,0(sp)
    800014ca:	1800                	addi	s0,sp,48
    800014cc:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014ce:	84aa                	mv	s1,a0
    800014d0:	6905                	lui	s2,0x1
    800014d2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014d4:	4985                	li	s3,1
    800014d6:	a829                	j	800014f0 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014d8:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014da:	00c79513          	slli	a0,a5,0xc
    800014de:	00000097          	auipc	ra,0x0
    800014e2:	fde080e7          	jalr	-34(ra) # 800014bc <freewalk>
      pagetable[i] = 0;
    800014e6:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014ea:	04a1                	addi	s1,s1,8
    800014ec:	03248163          	beq	s1,s2,8000150e <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014f0:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f2:	00f7f713          	andi	a4,a5,15
    800014f6:	ff3701e3          	beq	a4,s3,800014d8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014fa:	8b85                	andi	a5,a5,1
    800014fc:	d7fd                	beqz	a5,800014ea <freewalk+0x2e>
      panic("freewalk: leaf");
    800014fe:	00007517          	auipc	a0,0x7
    80001502:	c7a50513          	addi	a0,a0,-902 # 80008178 <digits+0x138>
    80001506:	fffff097          	auipc	ra,0xfffff
    8000150a:	036080e7          	jalr	54(ra) # 8000053c <panic>
    }
  }
  kfree((void*)pagetable);
    8000150e:	8552                	mv	a0,s4
    80001510:	fffff097          	auipc	ra,0xfffff
    80001514:	4d4080e7          	jalr	1236(ra) # 800009e4 <kfree>
}
    80001518:	70a2                	ld	ra,40(sp)
    8000151a:	7402                	ld	s0,32(sp)
    8000151c:	64e2                	ld	s1,24(sp)
    8000151e:	6942                	ld	s2,16(sp)
    80001520:	69a2                	ld	s3,8(sp)
    80001522:	6a02                	ld	s4,0(sp)
    80001524:	6145                	addi	sp,sp,48
    80001526:	8082                	ret

0000000080001528 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001528:	1101                	addi	sp,sp,-32
    8000152a:	ec06                	sd	ra,24(sp)
    8000152c:	e822                	sd	s0,16(sp)
    8000152e:	e426                	sd	s1,8(sp)
    80001530:	1000                	addi	s0,sp,32
    80001532:	84aa                	mv	s1,a0
  if(sz > 0)
    80001534:	e999                	bnez	a1,8000154a <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001536:	8526                	mv	a0,s1
    80001538:	00000097          	auipc	ra,0x0
    8000153c:	f84080e7          	jalr	-124(ra) # 800014bc <freewalk>
}
    80001540:	60e2                	ld	ra,24(sp)
    80001542:	6442                	ld	s0,16(sp)
    80001544:	64a2                	ld	s1,8(sp)
    80001546:	6105                	addi	sp,sp,32
    80001548:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000154a:	6785                	lui	a5,0x1
    8000154c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000154e:	95be                	add	a1,a1,a5
    80001550:	4685                	li	a3,1
    80001552:	00c5d613          	srli	a2,a1,0xc
    80001556:	4581                	li	a1,0
    80001558:	00000097          	auipc	ra,0x0
    8000155c:	d06080e7          	jalr	-762(ra) # 8000125e <uvmunmap>
    80001560:	bfd9                	j	80001536 <uvmfree+0xe>

0000000080001562 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001562:	c679                	beqz	a2,80001630 <uvmcopy+0xce>
{
    80001564:	715d                	addi	sp,sp,-80
    80001566:	e486                	sd	ra,72(sp)
    80001568:	e0a2                	sd	s0,64(sp)
    8000156a:	fc26                	sd	s1,56(sp)
    8000156c:	f84a                	sd	s2,48(sp)
    8000156e:	f44e                	sd	s3,40(sp)
    80001570:	f052                	sd	s4,32(sp)
    80001572:	ec56                	sd	s5,24(sp)
    80001574:	e85a                	sd	s6,16(sp)
    80001576:	e45e                	sd	s7,8(sp)
    80001578:	0880                	addi	s0,sp,80
    8000157a:	8b2a                	mv	s6,a0
    8000157c:	8aae                	mv	s5,a1
    8000157e:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001580:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001582:	4601                	li	a2,0
    80001584:	85ce                	mv	a1,s3
    80001586:	855a                	mv	a0,s6
    80001588:	00000097          	auipc	ra,0x0
    8000158c:	a28080e7          	jalr	-1496(ra) # 80000fb0 <walk>
    80001590:	c531                	beqz	a0,800015dc <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001592:	6118                	ld	a4,0(a0)
    80001594:	00177793          	andi	a5,a4,1
    80001598:	cbb1                	beqz	a5,800015ec <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000159a:	00a75593          	srli	a1,a4,0xa
    8000159e:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a6:	fffff097          	auipc	ra,0xfffff
    800015aa:	53c080e7          	jalr	1340(ra) # 80000ae2 <kalloc>
    800015ae:	892a                	mv	s2,a0
    800015b0:	c939                	beqz	a0,80001606 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b2:	6605                	lui	a2,0x1
    800015b4:	85de                	mv	a1,s7
    800015b6:	fffff097          	auipc	ra,0xfffff
    800015ba:	774080e7          	jalr	1908(ra) # 80000d2a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015be:	8726                	mv	a4,s1
    800015c0:	86ca                	mv	a3,s2
    800015c2:	6605                	lui	a2,0x1
    800015c4:	85ce                	mv	a1,s3
    800015c6:	8556                	mv	a0,s5
    800015c8:	00000097          	auipc	ra,0x0
    800015cc:	ad0080e7          	jalr	-1328(ra) # 80001098 <mappages>
    800015d0:	e515                	bnez	a0,800015fc <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d2:	6785                	lui	a5,0x1
    800015d4:	99be                	add	s3,s3,a5
    800015d6:	fb49e6e3          	bltu	s3,s4,80001582 <uvmcopy+0x20>
    800015da:	a081                	j	8000161a <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015dc:	00007517          	auipc	a0,0x7
    800015e0:	bac50513          	addi	a0,a0,-1108 # 80008188 <digits+0x148>
    800015e4:	fffff097          	auipc	ra,0xfffff
    800015e8:	f58080e7          	jalr	-168(ra) # 8000053c <panic>
      panic("uvmcopy: page not present");
    800015ec:	00007517          	auipc	a0,0x7
    800015f0:	bbc50513          	addi	a0,a0,-1092 # 800081a8 <digits+0x168>
    800015f4:	fffff097          	auipc	ra,0xfffff
    800015f8:	f48080e7          	jalr	-184(ra) # 8000053c <panic>
      kfree(mem);
    800015fc:	854a                	mv	a0,s2
    800015fe:	fffff097          	auipc	ra,0xfffff
    80001602:	3e6080e7          	jalr	998(ra) # 800009e4 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001606:	4685                	li	a3,1
    80001608:	00c9d613          	srli	a2,s3,0xc
    8000160c:	4581                	li	a1,0
    8000160e:	8556                	mv	a0,s5
    80001610:	00000097          	auipc	ra,0x0
    80001614:	c4e080e7          	jalr	-946(ra) # 8000125e <uvmunmap>
  return -1;
    80001618:	557d                	li	a0,-1
}
    8000161a:	60a6                	ld	ra,72(sp)
    8000161c:	6406                	ld	s0,64(sp)
    8000161e:	74e2                	ld	s1,56(sp)
    80001620:	7942                	ld	s2,48(sp)
    80001622:	79a2                	ld	s3,40(sp)
    80001624:	7a02                	ld	s4,32(sp)
    80001626:	6ae2                	ld	s5,24(sp)
    80001628:	6b42                	ld	s6,16(sp)
    8000162a:	6ba2                	ld	s7,8(sp)
    8000162c:	6161                	addi	sp,sp,80
    8000162e:	8082                	ret
  return 0;
    80001630:	4501                	li	a0,0
}
    80001632:	8082                	ret

0000000080001634 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001634:	1141                	addi	sp,sp,-16
    80001636:	e406                	sd	ra,8(sp)
    80001638:	e022                	sd	s0,0(sp)
    8000163a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000163c:	4601                	li	a2,0
    8000163e:	00000097          	auipc	ra,0x0
    80001642:	972080e7          	jalr	-1678(ra) # 80000fb0 <walk>
  if(pte == 0)
    80001646:	c901                	beqz	a0,80001656 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001648:	611c                	ld	a5,0(a0)
    8000164a:	9bbd                	andi	a5,a5,-17
    8000164c:	e11c                	sd	a5,0(a0)
}
    8000164e:	60a2                	ld	ra,8(sp)
    80001650:	6402                	ld	s0,0(sp)
    80001652:	0141                	addi	sp,sp,16
    80001654:	8082                	ret
    panic("uvmclear");
    80001656:	00007517          	auipc	a0,0x7
    8000165a:	b7250513          	addi	a0,a0,-1166 # 800081c8 <digits+0x188>
    8000165e:	fffff097          	auipc	ra,0xfffff
    80001662:	ede080e7          	jalr	-290(ra) # 8000053c <panic>

0000000080001666 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001666:	c6bd                	beqz	a3,800016d4 <copyout+0x6e>
{
    80001668:	715d                	addi	sp,sp,-80
    8000166a:	e486                	sd	ra,72(sp)
    8000166c:	e0a2                	sd	s0,64(sp)
    8000166e:	fc26                	sd	s1,56(sp)
    80001670:	f84a                	sd	s2,48(sp)
    80001672:	f44e                	sd	s3,40(sp)
    80001674:	f052                	sd	s4,32(sp)
    80001676:	ec56                	sd	s5,24(sp)
    80001678:	e85a                	sd	s6,16(sp)
    8000167a:	e45e                	sd	s7,8(sp)
    8000167c:	e062                	sd	s8,0(sp)
    8000167e:	0880                	addi	s0,sp,80
    80001680:	8b2a                	mv	s6,a0
    80001682:	8c2e                	mv	s8,a1
    80001684:	8a32                	mv	s4,a2
    80001686:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001688:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000168a:	6a85                	lui	s5,0x1
    8000168c:	a015                	j	800016b0 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000168e:	9562                	add	a0,a0,s8
    80001690:	0004861b          	sext.w	a2,s1
    80001694:	85d2                	mv	a1,s4
    80001696:	41250533          	sub	a0,a0,s2
    8000169a:	fffff097          	auipc	ra,0xfffff
    8000169e:	690080e7          	jalr	1680(ra) # 80000d2a <memmove>

    len -= n;
    800016a2:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a6:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016a8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ac:	02098263          	beqz	s3,800016d0 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b4:	85ca                	mv	a1,s2
    800016b6:	855a                	mv	a0,s6
    800016b8:	00000097          	auipc	ra,0x0
    800016bc:	99e080e7          	jalr	-1634(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    800016c0:	cd01                	beqz	a0,800016d8 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c2:	418904b3          	sub	s1,s2,s8
    800016c6:	94d6                	add	s1,s1,s5
    800016c8:	fc99f3e3          	bgeu	s3,s1,8000168e <copyout+0x28>
    800016cc:	84ce                	mv	s1,s3
    800016ce:	b7c1                	j	8000168e <copyout+0x28>
  }
  return 0;
    800016d0:	4501                	li	a0,0
    800016d2:	a021                	j	800016da <copyout+0x74>
    800016d4:	4501                	li	a0,0
}
    800016d6:	8082                	ret
      return -1;
    800016d8:	557d                	li	a0,-1
}
    800016da:	60a6                	ld	ra,72(sp)
    800016dc:	6406                	ld	s0,64(sp)
    800016de:	74e2                	ld	s1,56(sp)
    800016e0:	7942                	ld	s2,48(sp)
    800016e2:	79a2                	ld	s3,40(sp)
    800016e4:	7a02                	ld	s4,32(sp)
    800016e6:	6ae2                	ld	s5,24(sp)
    800016e8:	6b42                	ld	s6,16(sp)
    800016ea:	6ba2                	ld	s7,8(sp)
    800016ec:	6c02                	ld	s8,0(sp)
    800016ee:	6161                	addi	sp,sp,80
    800016f0:	8082                	ret

00000000800016f2 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f2:	caa5                	beqz	a3,80001762 <copyin+0x70>
{
    800016f4:	715d                	addi	sp,sp,-80
    800016f6:	e486                	sd	ra,72(sp)
    800016f8:	e0a2                	sd	s0,64(sp)
    800016fa:	fc26                	sd	s1,56(sp)
    800016fc:	f84a                	sd	s2,48(sp)
    800016fe:	f44e                	sd	s3,40(sp)
    80001700:	f052                	sd	s4,32(sp)
    80001702:	ec56                	sd	s5,24(sp)
    80001704:	e85a                	sd	s6,16(sp)
    80001706:	e45e                	sd	s7,8(sp)
    80001708:	e062                	sd	s8,0(sp)
    8000170a:	0880                	addi	s0,sp,80
    8000170c:	8b2a                	mv	s6,a0
    8000170e:	8a2e                	mv	s4,a1
    80001710:	8c32                	mv	s8,a2
    80001712:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001714:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001716:	6a85                	lui	s5,0x1
    80001718:	a01d                	j	8000173e <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000171a:	018505b3          	add	a1,a0,s8
    8000171e:	0004861b          	sext.w	a2,s1
    80001722:	412585b3          	sub	a1,a1,s2
    80001726:	8552                	mv	a0,s4
    80001728:	fffff097          	auipc	ra,0xfffff
    8000172c:	602080e7          	jalr	1538(ra) # 80000d2a <memmove>

    len -= n;
    80001730:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001734:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001736:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000173a:	02098263          	beqz	s3,8000175e <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000173e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001742:	85ca                	mv	a1,s2
    80001744:	855a                	mv	a0,s6
    80001746:	00000097          	auipc	ra,0x0
    8000174a:	910080e7          	jalr	-1776(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    8000174e:	cd01                	beqz	a0,80001766 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001750:	418904b3          	sub	s1,s2,s8
    80001754:	94d6                	add	s1,s1,s5
    80001756:	fc99f2e3          	bgeu	s3,s1,8000171a <copyin+0x28>
    8000175a:	84ce                	mv	s1,s3
    8000175c:	bf7d                	j	8000171a <copyin+0x28>
  }
  return 0;
    8000175e:	4501                	li	a0,0
    80001760:	a021                	j	80001768 <copyin+0x76>
    80001762:	4501                	li	a0,0
}
    80001764:	8082                	ret
      return -1;
    80001766:	557d                	li	a0,-1
}
    80001768:	60a6                	ld	ra,72(sp)
    8000176a:	6406                	ld	s0,64(sp)
    8000176c:	74e2                	ld	s1,56(sp)
    8000176e:	7942                	ld	s2,48(sp)
    80001770:	79a2                	ld	s3,40(sp)
    80001772:	7a02                	ld	s4,32(sp)
    80001774:	6ae2                	ld	s5,24(sp)
    80001776:	6b42                	ld	s6,16(sp)
    80001778:	6ba2                	ld	s7,8(sp)
    8000177a:	6c02                	ld	s8,0(sp)
    8000177c:	6161                	addi	sp,sp,80
    8000177e:	8082                	ret

0000000080001780 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001780:	c2dd                	beqz	a3,80001826 <copyinstr+0xa6>
{
    80001782:	715d                	addi	sp,sp,-80
    80001784:	e486                	sd	ra,72(sp)
    80001786:	e0a2                	sd	s0,64(sp)
    80001788:	fc26                	sd	s1,56(sp)
    8000178a:	f84a                	sd	s2,48(sp)
    8000178c:	f44e                	sd	s3,40(sp)
    8000178e:	f052                	sd	s4,32(sp)
    80001790:	ec56                	sd	s5,24(sp)
    80001792:	e85a                	sd	s6,16(sp)
    80001794:	e45e                	sd	s7,8(sp)
    80001796:	0880                	addi	s0,sp,80
    80001798:	8a2a                	mv	s4,a0
    8000179a:	8b2e                	mv	s6,a1
    8000179c:	8bb2                	mv	s7,a2
    8000179e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a0:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a2:	6985                	lui	s3,0x1
    800017a4:	a02d                	j	800017ce <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a6:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017aa:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ac:	37fd                	addiw	a5,a5,-1
    800017ae:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b2:	60a6                	ld	ra,72(sp)
    800017b4:	6406                	ld	s0,64(sp)
    800017b6:	74e2                	ld	s1,56(sp)
    800017b8:	7942                	ld	s2,48(sp)
    800017ba:	79a2                	ld	s3,40(sp)
    800017bc:	7a02                	ld	s4,32(sp)
    800017be:	6ae2                	ld	s5,24(sp)
    800017c0:	6b42                	ld	s6,16(sp)
    800017c2:	6ba2                	ld	s7,8(sp)
    800017c4:	6161                	addi	sp,sp,80
    800017c6:	8082                	ret
    srcva = va0 + PGSIZE;
    800017c8:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017cc:	c8a9                	beqz	s1,8000181e <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017ce:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d2:	85ca                	mv	a1,s2
    800017d4:	8552                	mv	a0,s4
    800017d6:	00000097          	auipc	ra,0x0
    800017da:	880080e7          	jalr	-1920(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    800017de:	c131                	beqz	a0,80001822 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017e0:	417906b3          	sub	a3,s2,s7
    800017e4:	96ce                	add	a3,a3,s3
    800017e6:	00d4f363          	bgeu	s1,a3,800017ec <copyinstr+0x6c>
    800017ea:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017ec:	955e                	add	a0,a0,s7
    800017ee:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f2:	daf9                	beqz	a3,800017c8 <copyinstr+0x48>
    800017f4:	87da                	mv	a5,s6
    800017f6:	885a                	mv	a6,s6
      if(*p == '\0'){
    800017f8:	41650633          	sub	a2,a0,s6
    while(n > 0){
    800017fc:	96da                	add	a3,a3,s6
    800017fe:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001800:	00f60733          	add	a4,a2,a5
    80001804:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdc880>
    80001808:	df59                	beqz	a4,800017a6 <copyinstr+0x26>
        *dst = *p;
    8000180a:	00e78023          	sb	a4,0(a5)
      dst++;
    8000180e:	0785                	addi	a5,a5,1
    while(n > 0){
    80001810:	fed797e3          	bne	a5,a3,800017fe <copyinstr+0x7e>
    80001814:	14fd                	addi	s1,s1,-1
    80001816:	94c2                	add	s1,s1,a6
      --max;
    80001818:	8c8d                	sub	s1,s1,a1
      dst++;
    8000181a:	8b3e                	mv	s6,a5
    8000181c:	b775                	j	800017c8 <copyinstr+0x48>
    8000181e:	4781                	li	a5,0
    80001820:	b771                	j	800017ac <copyinstr+0x2c>
      return -1;
    80001822:	557d                	li	a0,-1
    80001824:	b779                	j	800017b2 <copyinstr+0x32>
  int got_null = 0;
    80001826:	4781                	li	a5,0
  if(got_null){
    80001828:	37fd                	addiw	a5,a5,-1
    8000182a:	0007851b          	sext.w	a0,a5
}
    8000182e:	8082                	ret

0000000080001830 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001830:	7139                	addi	sp,sp,-64
    80001832:	fc06                	sd	ra,56(sp)
    80001834:	f822                	sd	s0,48(sp)
    80001836:	f426                	sd	s1,40(sp)
    80001838:	f04a                	sd	s2,32(sp)
    8000183a:	ec4e                	sd	s3,24(sp)
    8000183c:	e852                	sd	s4,16(sp)
    8000183e:	e456                	sd	s5,8(sp)
    80001840:	e05a                	sd	s6,0(sp)
    80001842:	0080                	addi	s0,sp,64
    80001844:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001846:	00010497          	auipc	s1,0x10
    8000184a:	95a48493          	addi	s1,s1,-1702 # 800111a0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000184e:	8b26                	mv	s6,s1
    80001850:	00006a97          	auipc	s5,0x6
    80001854:	7b0a8a93          	addi	s5,s5,1968 # 80008000 <etext>
    80001858:	04000937          	lui	s2,0x4000
    8000185c:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000185e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001860:	00016a17          	auipc	s4,0x16
    80001864:	b40a0a13          	addi	s4,s4,-1216 # 800173a0 <tickslock>
    char *pa = kalloc();
    80001868:	fffff097          	auipc	ra,0xfffff
    8000186c:	27a080e7          	jalr	634(ra) # 80000ae2 <kalloc>
    80001870:	862a                	mv	a2,a0
    if(pa == 0)
    80001872:	c131                	beqz	a0,800018b6 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001874:	416485b3          	sub	a1,s1,s6
    80001878:	858d                	srai	a1,a1,0x3
    8000187a:	000ab783          	ld	a5,0(s5)
    8000187e:	02f585b3          	mul	a1,a1,a5
    80001882:	2585                	addiw	a1,a1,1
    80001884:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001888:	4719                	li	a4,6
    8000188a:	6685                	lui	a3,0x1
    8000188c:	40b905b3          	sub	a1,s2,a1
    80001890:	854e                	mv	a0,s3
    80001892:	00000097          	auipc	ra,0x0
    80001896:	8a6080e7          	jalr	-1882(ra) # 80001138 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000189a:	18848493          	addi	s1,s1,392
    8000189e:	fd4495e3          	bne	s1,s4,80001868 <proc_mapstacks+0x38>
  }
}
    800018a2:	70e2                	ld	ra,56(sp)
    800018a4:	7442                	ld	s0,48(sp)
    800018a6:	74a2                	ld	s1,40(sp)
    800018a8:	7902                	ld	s2,32(sp)
    800018aa:	69e2                	ld	s3,24(sp)
    800018ac:	6a42                	ld	s4,16(sp)
    800018ae:	6aa2                	ld	s5,8(sp)
    800018b0:	6b02                	ld	s6,0(sp)
    800018b2:	6121                	addi	sp,sp,64
    800018b4:	8082                	ret
      panic("kalloc");
    800018b6:	00007517          	auipc	a0,0x7
    800018ba:	92250513          	addi	a0,a0,-1758 # 800081d8 <digits+0x198>
    800018be:	fffff097          	auipc	ra,0xfffff
    800018c2:	c7e080e7          	jalr	-898(ra) # 8000053c <panic>

00000000800018c6 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018c6:	7139                	addi	sp,sp,-64
    800018c8:	fc06                	sd	ra,56(sp)
    800018ca:	f822                	sd	s0,48(sp)
    800018cc:	f426                	sd	s1,40(sp)
    800018ce:	f04a                	sd	s2,32(sp)
    800018d0:	ec4e                	sd	s3,24(sp)
    800018d2:	e852                	sd	s4,16(sp)
    800018d4:	e456                	sd	s5,8(sp)
    800018d6:	e05a                	sd	s6,0(sp)
    800018d8:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018da:	00007597          	auipc	a1,0x7
    800018de:	90658593          	addi	a1,a1,-1786 # 800081e0 <digits+0x1a0>
    800018e2:	0000f517          	auipc	a0,0xf
    800018e6:	48e50513          	addi	a0,a0,1166 # 80010d70 <pid_lock>
    800018ea:	fffff097          	auipc	ra,0xfffff
    800018ee:	258080e7          	jalr	600(ra) # 80000b42 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f2:	00007597          	auipc	a1,0x7
    800018f6:	8f658593          	addi	a1,a1,-1802 # 800081e8 <digits+0x1a8>
    800018fa:	0000f517          	auipc	a0,0xf
    800018fe:	48e50513          	addi	a0,a0,1166 # 80010d88 <wait_lock>
    80001902:	fffff097          	auipc	ra,0xfffff
    80001906:	240080e7          	jalr	576(ra) # 80000b42 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000190a:	00010497          	auipc	s1,0x10
    8000190e:	89648493          	addi	s1,s1,-1898 # 800111a0 <proc>
      initlock(&p->lock, "proc");
    80001912:	00007b17          	auipc	s6,0x7
    80001916:	8e6b0b13          	addi	s6,s6,-1818 # 800081f8 <digits+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000191a:	8aa6                	mv	s5,s1
    8000191c:	00006a17          	auipc	s4,0x6
    80001920:	6e4a0a13          	addi	s4,s4,1764 # 80008000 <etext>
    80001924:	04000937          	lui	s2,0x4000
    80001928:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000192a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000192c:	00016997          	auipc	s3,0x16
    80001930:	a7498993          	addi	s3,s3,-1420 # 800173a0 <tickslock>
      initlock(&p->lock, "proc");
    80001934:	85da                	mv	a1,s6
    80001936:	8526                	mv	a0,s1
    80001938:	fffff097          	auipc	ra,0xfffff
    8000193c:	20a080e7          	jalr	522(ra) # 80000b42 <initlock>
      p->state = UNUSED;
    80001940:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001944:	415487b3          	sub	a5,s1,s5
    80001948:	878d                	srai	a5,a5,0x3
    8000194a:	000a3703          	ld	a4,0(s4)
    8000194e:	02e787b3          	mul	a5,a5,a4
    80001952:	2785                	addiw	a5,a5,1
    80001954:	00d7979b          	slliw	a5,a5,0xd
    80001958:	40f907b3          	sub	a5,s2,a5
    8000195c:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000195e:	18848493          	addi	s1,s1,392
    80001962:	fd3499e3          	bne	s1,s3,80001934 <procinit+0x6e>
  }
}
    80001966:	70e2                	ld	ra,56(sp)
    80001968:	7442                	ld	s0,48(sp)
    8000196a:	74a2                	ld	s1,40(sp)
    8000196c:	7902                	ld	s2,32(sp)
    8000196e:	69e2                	ld	s3,24(sp)
    80001970:	6a42                	ld	s4,16(sp)
    80001972:	6aa2                	ld	s5,8(sp)
    80001974:	6b02                	ld	s6,0(sp)
    80001976:	6121                	addi	sp,sp,64
    80001978:	8082                	ret

000000008000197a <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    8000197a:	1141                	addi	sp,sp,-16
    8000197c:	e422                	sd	s0,8(sp)
    8000197e:	0800                	addi	s0,sp,16
// this core's hartid (core number), the index into cpus[].
static inline uint64
r_tp()
{
  uint64 x;
  asm volatile("mv %0, tp" : "=r" (x) );
    80001980:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001982:	2501                	sext.w	a0,a0
    80001984:	6422                	ld	s0,8(sp)
    80001986:	0141                	addi	sp,sp,16
    80001988:	8082                	ret

000000008000198a <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    8000198a:	1141                	addi	sp,sp,-16
    8000198c:	e422                	sd	s0,8(sp)
    8000198e:	0800                	addi	s0,sp,16
    80001990:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001992:	2781                	sext.w	a5,a5
    80001994:	079e                	slli	a5,a5,0x7
  return c;
}
    80001996:	0000f517          	auipc	a0,0xf
    8000199a:	40a50513          	addi	a0,a0,1034 # 80010da0 <cpus>
    8000199e:	953e                	add	a0,a0,a5
    800019a0:	6422                	ld	s0,8(sp)
    800019a2:	0141                	addi	sp,sp,16
    800019a4:	8082                	ret

00000000800019a6 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019a6:	1101                	addi	sp,sp,-32
    800019a8:	ec06                	sd	ra,24(sp)
    800019aa:	e822                	sd	s0,16(sp)
    800019ac:	e426                	sd	s1,8(sp)
    800019ae:	1000                	addi	s0,sp,32
  push_off();
    800019b0:	fffff097          	auipc	ra,0xfffff
    800019b4:	1d6080e7          	jalr	470(ra) # 80000b86 <push_off>
    800019b8:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019ba:	2781                	sext.w	a5,a5
    800019bc:	079e                	slli	a5,a5,0x7
    800019be:	0000f717          	auipc	a4,0xf
    800019c2:	3b270713          	addi	a4,a4,946 # 80010d70 <pid_lock>
    800019c6:	97ba                	add	a5,a5,a4
    800019c8:	7b84                	ld	s1,48(a5)
  pop_off();
    800019ca:	fffff097          	auipc	ra,0xfffff
    800019ce:	25c080e7          	jalr	604(ra) # 80000c26 <pop_off>
  return p;
}
    800019d2:	8526                	mv	a0,s1
    800019d4:	60e2                	ld	ra,24(sp)
    800019d6:	6442                	ld	s0,16(sp)
    800019d8:	64a2                	ld	s1,8(sp)
    800019da:	6105                	addi	sp,sp,32
    800019dc:	8082                	ret

00000000800019de <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019de:	1141                	addi	sp,sp,-16
    800019e0:	e406                	sd	ra,8(sp)
    800019e2:	e022                	sd	s0,0(sp)
    800019e4:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019e6:	00000097          	auipc	ra,0x0
    800019ea:	fc0080e7          	jalr	-64(ra) # 800019a6 <myproc>
    800019ee:	fffff097          	auipc	ra,0xfffff
    800019f2:	298080e7          	jalr	664(ra) # 80000c86 <release>

  if (first) {
    800019f6:	00007797          	auipc	a5,0x7
    800019fa:	08a7a783          	lw	a5,138(a5) # 80008a80 <first.1>
    800019fe:	eb89                	bnez	a5,80001a10 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a00:	00001097          	auipc	ra,0x1
    80001a04:	c7e080e7          	jalr	-898(ra) # 8000267e <usertrapret>
}
    80001a08:	60a2                	ld	ra,8(sp)
    80001a0a:	6402                	ld	s0,0(sp)
    80001a0c:	0141                	addi	sp,sp,16
    80001a0e:	8082                	ret
    first = 0;
    80001a10:	00007797          	auipc	a5,0x7
    80001a14:	0607a823          	sw	zero,112(a5) # 80008a80 <first.1>
    fsinit(ROOTDEV);
    80001a18:	4505                	li	a0,1
    80001a1a:	00002097          	auipc	ra,0x2
    80001a1e:	bf4080e7          	jalr	-1036(ra) # 8000360e <fsinit>
    80001a22:	bff9                	j	80001a00 <forkret+0x22>

0000000080001a24 <allocpid>:
{
    80001a24:	1101                	addi	sp,sp,-32
    80001a26:	ec06                	sd	ra,24(sp)
    80001a28:	e822                	sd	s0,16(sp)
    80001a2a:	e426                	sd	s1,8(sp)
    80001a2c:	e04a                	sd	s2,0(sp)
    80001a2e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a30:	0000f917          	auipc	s2,0xf
    80001a34:	34090913          	addi	s2,s2,832 # 80010d70 <pid_lock>
    80001a38:	854a                	mv	a0,s2
    80001a3a:	fffff097          	auipc	ra,0xfffff
    80001a3e:	198080e7          	jalr	408(ra) # 80000bd2 <acquire>
  pid = nextpid;
    80001a42:	00007797          	auipc	a5,0x7
    80001a46:	04278793          	addi	a5,a5,66 # 80008a84 <nextpid>
    80001a4a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a4c:	0014871b          	addiw	a4,s1,1
    80001a50:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a52:	854a                	mv	a0,s2
    80001a54:	fffff097          	auipc	ra,0xfffff
    80001a58:	232080e7          	jalr	562(ra) # 80000c86 <release>
}
    80001a5c:	8526                	mv	a0,s1
    80001a5e:	60e2                	ld	ra,24(sp)
    80001a60:	6442                	ld	s0,16(sp)
    80001a62:	64a2                	ld	s1,8(sp)
    80001a64:	6902                	ld	s2,0(sp)
    80001a66:	6105                	addi	sp,sp,32
    80001a68:	8082                	ret

0000000080001a6a <proc_pagetable>:
{
    80001a6a:	1101                	addi	sp,sp,-32
    80001a6c:	ec06                	sd	ra,24(sp)
    80001a6e:	e822                	sd	s0,16(sp)
    80001a70:	e426                	sd	s1,8(sp)
    80001a72:	e04a                	sd	s2,0(sp)
    80001a74:	1000                	addi	s0,sp,32
    80001a76:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a78:	00000097          	auipc	ra,0x0
    80001a7c:	8aa080e7          	jalr	-1878(ra) # 80001322 <uvmcreate>
    80001a80:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a82:	c121                	beqz	a0,80001ac2 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a84:	4729                	li	a4,10
    80001a86:	00005697          	auipc	a3,0x5
    80001a8a:	57a68693          	addi	a3,a3,1402 # 80007000 <_trampoline>
    80001a8e:	6605                	lui	a2,0x1
    80001a90:	040005b7          	lui	a1,0x4000
    80001a94:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a96:	05b2                	slli	a1,a1,0xc
    80001a98:	fffff097          	auipc	ra,0xfffff
    80001a9c:	600080e7          	jalr	1536(ra) # 80001098 <mappages>
    80001aa0:	02054863          	bltz	a0,80001ad0 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001aa4:	4719                	li	a4,6
    80001aa6:	05893683          	ld	a3,88(s2)
    80001aaa:	6605                	lui	a2,0x1
    80001aac:	020005b7          	lui	a1,0x2000
    80001ab0:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ab2:	05b6                	slli	a1,a1,0xd
    80001ab4:	8526                	mv	a0,s1
    80001ab6:	fffff097          	auipc	ra,0xfffff
    80001aba:	5e2080e7          	jalr	1506(ra) # 80001098 <mappages>
    80001abe:	02054163          	bltz	a0,80001ae0 <proc_pagetable+0x76>
}
    80001ac2:	8526                	mv	a0,s1
    80001ac4:	60e2                	ld	ra,24(sp)
    80001ac6:	6442                	ld	s0,16(sp)
    80001ac8:	64a2                	ld	s1,8(sp)
    80001aca:	6902                	ld	s2,0(sp)
    80001acc:	6105                	addi	sp,sp,32
    80001ace:	8082                	ret
    uvmfree(pagetable, 0);
    80001ad0:	4581                	li	a1,0
    80001ad2:	8526                	mv	a0,s1
    80001ad4:	00000097          	auipc	ra,0x0
    80001ad8:	a54080e7          	jalr	-1452(ra) # 80001528 <uvmfree>
    return 0;
    80001adc:	4481                	li	s1,0
    80001ade:	b7d5                	j	80001ac2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ae0:	4681                	li	a3,0
    80001ae2:	4605                	li	a2,1
    80001ae4:	040005b7          	lui	a1,0x4000
    80001ae8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aea:	05b2                	slli	a1,a1,0xc
    80001aec:	8526                	mv	a0,s1
    80001aee:	fffff097          	auipc	ra,0xfffff
    80001af2:	770080e7          	jalr	1904(ra) # 8000125e <uvmunmap>
    uvmfree(pagetable, 0);
    80001af6:	4581                	li	a1,0
    80001af8:	8526                	mv	a0,s1
    80001afa:	00000097          	auipc	ra,0x0
    80001afe:	a2e080e7          	jalr	-1490(ra) # 80001528 <uvmfree>
    return 0;
    80001b02:	4481                	li	s1,0
    80001b04:	bf7d                	j	80001ac2 <proc_pagetable+0x58>

0000000080001b06 <proc_freepagetable>:
{
    80001b06:	1101                	addi	sp,sp,-32
    80001b08:	ec06                	sd	ra,24(sp)
    80001b0a:	e822                	sd	s0,16(sp)
    80001b0c:	e426                	sd	s1,8(sp)
    80001b0e:	e04a                	sd	s2,0(sp)
    80001b10:	1000                	addi	s0,sp,32
    80001b12:	84aa                	mv	s1,a0
    80001b14:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b16:	4681                	li	a3,0
    80001b18:	4605                	li	a2,1
    80001b1a:	040005b7          	lui	a1,0x4000
    80001b1e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b20:	05b2                	slli	a1,a1,0xc
    80001b22:	fffff097          	auipc	ra,0xfffff
    80001b26:	73c080e7          	jalr	1852(ra) # 8000125e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b2a:	4681                	li	a3,0
    80001b2c:	4605                	li	a2,1
    80001b2e:	020005b7          	lui	a1,0x2000
    80001b32:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b34:	05b6                	slli	a1,a1,0xd
    80001b36:	8526                	mv	a0,s1
    80001b38:	fffff097          	auipc	ra,0xfffff
    80001b3c:	726080e7          	jalr	1830(ra) # 8000125e <uvmunmap>
  uvmfree(pagetable, sz);
    80001b40:	85ca                	mv	a1,s2
    80001b42:	8526                	mv	a0,s1
    80001b44:	00000097          	auipc	ra,0x0
    80001b48:	9e4080e7          	jalr	-1564(ra) # 80001528 <uvmfree>
}
    80001b4c:	60e2                	ld	ra,24(sp)
    80001b4e:	6442                	ld	s0,16(sp)
    80001b50:	64a2                	ld	s1,8(sp)
    80001b52:	6902                	ld	s2,0(sp)
    80001b54:	6105                	addi	sp,sp,32
    80001b56:	8082                	ret

0000000080001b58 <freeproc>:
{
    80001b58:	1101                	addi	sp,sp,-32
    80001b5a:	ec06                	sd	ra,24(sp)
    80001b5c:	e822                	sd	s0,16(sp)
    80001b5e:	e426                	sd	s1,8(sp)
    80001b60:	1000                	addi	s0,sp,32
    80001b62:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b64:	6d28                	ld	a0,88(a0)
    80001b66:	c509                	beqz	a0,80001b70 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b68:	fffff097          	auipc	ra,0xfffff
    80001b6c:	e7c080e7          	jalr	-388(ra) # 800009e4 <kfree>
  p->trapframe = 0;
    80001b70:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b74:	68a8                	ld	a0,80(s1)
    80001b76:	c511                	beqz	a0,80001b82 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b78:	64ac                	ld	a1,72(s1)
    80001b7a:	00000097          	auipc	ra,0x0
    80001b7e:	f8c080e7          	jalr	-116(ra) # 80001b06 <proc_freepagetable>
  p->pagetable = 0;
    80001b82:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b86:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b8a:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b8e:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b92:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b96:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b9a:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b9e:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ba2:	0004ac23          	sw	zero,24(s1)
  p->smask = 0;
    80001ba6:	1604a423          	sw	zero,360(s1)
  p->interval = 0;
    80001baa:	1604a623          	sw	zero,364(s1)
  p->nticks =0;
    80001bae:	1604ac23          	sw	zero,376(s1)
  p->handler = 0;
    80001bb2:	1604b823          	sd	zero,368(s1)
}
    80001bb6:	60e2                	ld	ra,24(sp)
    80001bb8:	6442                	ld	s0,16(sp)
    80001bba:	64a2                	ld	s1,8(sp)
    80001bbc:	6105                	addi	sp,sp,32
    80001bbe:	8082                	ret

0000000080001bc0 <allocproc>:
{
    80001bc0:	1101                	addi	sp,sp,-32
    80001bc2:	ec06                	sd	ra,24(sp)
    80001bc4:	e822                	sd	s0,16(sp)
    80001bc6:	e426                	sd	s1,8(sp)
    80001bc8:	e04a                	sd	s2,0(sp)
    80001bca:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bcc:	0000f497          	auipc	s1,0xf
    80001bd0:	5d448493          	addi	s1,s1,1492 # 800111a0 <proc>
    80001bd4:	00015917          	auipc	s2,0x15
    80001bd8:	7cc90913          	addi	s2,s2,1996 # 800173a0 <tickslock>
    acquire(&p->lock);
    80001bdc:	8526                	mv	a0,s1
    80001bde:	fffff097          	auipc	ra,0xfffff
    80001be2:	ff4080e7          	jalr	-12(ra) # 80000bd2 <acquire>
    if(p->state == UNUSED) {
    80001be6:	4c9c                	lw	a5,24(s1)
    80001be8:	cf81                	beqz	a5,80001c00 <allocproc+0x40>
      release(&p->lock);
    80001bea:	8526                	mv	a0,s1
    80001bec:	fffff097          	auipc	ra,0xfffff
    80001bf0:	09a080e7          	jalr	154(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bf4:	18848493          	addi	s1,s1,392
    80001bf8:	ff2492e3          	bne	s1,s2,80001bdc <allocproc+0x1c>
  return 0;
    80001bfc:	4481                	li	s1,0
    80001bfe:	a8a9                	j	80001c58 <allocproc+0x98>
  p->pid = allocpid();
    80001c00:	00000097          	auipc	ra,0x0
    80001c04:	e24080e7          	jalr	-476(ra) # 80001a24 <allocpid>
    80001c08:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c0a:	4785                	li	a5,1
    80001c0c:	cc9c                	sw	a5,24(s1)
  p->nticks =0;
    80001c0e:	1604ac23          	sw	zero,376(s1)
  p->alarmOn =0;
    80001c12:	1604ae23          	sw	zero,380(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c16:	fffff097          	auipc	ra,0xfffff
    80001c1a:	ecc080e7          	jalr	-308(ra) # 80000ae2 <kalloc>
    80001c1e:	892a                	mv	s2,a0
    80001c20:	eca8                	sd	a0,88(s1)
    80001c22:	c131                	beqz	a0,80001c66 <allocproc+0xa6>
  p->pagetable = proc_pagetable(p);
    80001c24:	8526                	mv	a0,s1
    80001c26:	00000097          	auipc	ra,0x0
    80001c2a:	e44080e7          	jalr	-444(ra) # 80001a6a <proc_pagetable>
    80001c2e:	892a                	mv	s2,a0
    80001c30:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c32:	c531                	beqz	a0,80001c7e <allocproc+0xbe>
  memset(&p->context, 0, sizeof(p->context));
    80001c34:	07000613          	li	a2,112
    80001c38:	4581                	li	a1,0
    80001c3a:	06048513          	addi	a0,s1,96
    80001c3e:	fffff097          	auipc	ra,0xfffff
    80001c42:	090080e7          	jalr	144(ra) # 80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001c46:	00000797          	auipc	a5,0x0
    80001c4a:	d9878793          	addi	a5,a5,-616 # 800019de <forkret>
    80001c4e:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c50:	60bc                	ld	a5,64(s1)
    80001c52:	6705                	lui	a4,0x1
    80001c54:	97ba                	add	a5,a5,a4
    80001c56:	f4bc                	sd	a5,104(s1)
}
    80001c58:	8526                	mv	a0,s1
    80001c5a:	60e2                	ld	ra,24(sp)
    80001c5c:	6442                	ld	s0,16(sp)
    80001c5e:	64a2                	ld	s1,8(sp)
    80001c60:	6902                	ld	s2,0(sp)
    80001c62:	6105                	addi	sp,sp,32
    80001c64:	8082                	ret
    freeproc(p);
    80001c66:	8526                	mv	a0,s1
    80001c68:	00000097          	auipc	ra,0x0
    80001c6c:	ef0080e7          	jalr	-272(ra) # 80001b58 <freeproc>
    release(&p->lock);
    80001c70:	8526                	mv	a0,s1
    80001c72:	fffff097          	auipc	ra,0xfffff
    80001c76:	014080e7          	jalr	20(ra) # 80000c86 <release>
    return 0;
    80001c7a:	84ca                	mv	s1,s2
    80001c7c:	bff1                	j	80001c58 <allocproc+0x98>
    freeproc(p);
    80001c7e:	8526                	mv	a0,s1
    80001c80:	00000097          	auipc	ra,0x0
    80001c84:	ed8080e7          	jalr	-296(ra) # 80001b58 <freeproc>
    release(&p->lock);
    80001c88:	8526                	mv	a0,s1
    80001c8a:	fffff097          	auipc	ra,0xfffff
    80001c8e:	ffc080e7          	jalr	-4(ra) # 80000c86 <release>
    return 0;
    80001c92:	84ca                	mv	s1,s2
    80001c94:	b7d1                	j	80001c58 <allocproc+0x98>

0000000080001c96 <userinit>:
{
    80001c96:	1101                	addi	sp,sp,-32
    80001c98:	ec06                	sd	ra,24(sp)
    80001c9a:	e822                	sd	s0,16(sp)
    80001c9c:	e426                	sd	s1,8(sp)
    80001c9e:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ca0:	00000097          	auipc	ra,0x0
    80001ca4:	f20080e7          	jalr	-224(ra) # 80001bc0 <allocproc>
    80001ca8:	84aa                	mv	s1,a0
  initproc = p;
    80001caa:	00007797          	auipc	a5,0x7
    80001cae:	e4a7b723          	sd	a0,-434(a5) # 80008af8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cb2:	03400613          	li	a2,52
    80001cb6:	00007597          	auipc	a1,0x7
    80001cba:	dda58593          	addi	a1,a1,-550 # 80008a90 <initcode>
    80001cbe:	6928                	ld	a0,80(a0)
    80001cc0:	fffff097          	auipc	ra,0xfffff
    80001cc4:	690080e7          	jalr	1680(ra) # 80001350 <uvmfirst>
  p->sz = PGSIZE;
    80001cc8:	6785                	lui	a5,0x1
    80001cca:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001ccc:	6cb8                	ld	a4,88(s1)
    80001cce:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cd2:	6cb8                	ld	a4,88(s1)
    80001cd4:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cd6:	4641                	li	a2,16
    80001cd8:	00006597          	auipc	a1,0x6
    80001cdc:	52858593          	addi	a1,a1,1320 # 80008200 <digits+0x1c0>
    80001ce0:	15848513          	addi	a0,s1,344
    80001ce4:	fffff097          	auipc	ra,0xfffff
    80001ce8:	132080e7          	jalr	306(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001cec:	00006517          	auipc	a0,0x6
    80001cf0:	52450513          	addi	a0,a0,1316 # 80008210 <digits+0x1d0>
    80001cf4:	00002097          	auipc	ra,0x2
    80001cf8:	338080e7          	jalr	824(ra) # 8000402c <namei>
    80001cfc:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d00:	478d                	li	a5,3
    80001d02:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d04:	8526                	mv	a0,s1
    80001d06:	fffff097          	auipc	ra,0xfffff
    80001d0a:	f80080e7          	jalr	-128(ra) # 80000c86 <release>
}
    80001d0e:	60e2                	ld	ra,24(sp)
    80001d10:	6442                	ld	s0,16(sp)
    80001d12:	64a2                	ld	s1,8(sp)
    80001d14:	6105                	addi	sp,sp,32
    80001d16:	8082                	ret

0000000080001d18 <growproc>:
{
    80001d18:	1101                	addi	sp,sp,-32
    80001d1a:	ec06                	sd	ra,24(sp)
    80001d1c:	e822                	sd	s0,16(sp)
    80001d1e:	e426                	sd	s1,8(sp)
    80001d20:	e04a                	sd	s2,0(sp)
    80001d22:	1000                	addi	s0,sp,32
    80001d24:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d26:	00000097          	auipc	ra,0x0
    80001d2a:	c80080e7          	jalr	-896(ra) # 800019a6 <myproc>
    80001d2e:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d30:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d32:	01204c63          	bgtz	s2,80001d4a <growproc+0x32>
  } else if(n < 0){
    80001d36:	02094663          	bltz	s2,80001d62 <growproc+0x4a>
  p->sz = sz;
    80001d3a:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d3c:	4501                	li	a0,0
}
    80001d3e:	60e2                	ld	ra,24(sp)
    80001d40:	6442                	ld	s0,16(sp)
    80001d42:	64a2                	ld	s1,8(sp)
    80001d44:	6902                	ld	s2,0(sp)
    80001d46:	6105                	addi	sp,sp,32
    80001d48:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d4a:	4691                	li	a3,4
    80001d4c:	00b90633          	add	a2,s2,a1
    80001d50:	6928                	ld	a0,80(a0)
    80001d52:	fffff097          	auipc	ra,0xfffff
    80001d56:	6b8080e7          	jalr	1720(ra) # 8000140a <uvmalloc>
    80001d5a:	85aa                	mv	a1,a0
    80001d5c:	fd79                	bnez	a0,80001d3a <growproc+0x22>
      return -1;
    80001d5e:	557d                	li	a0,-1
    80001d60:	bff9                	j	80001d3e <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d62:	00b90633          	add	a2,s2,a1
    80001d66:	6928                	ld	a0,80(a0)
    80001d68:	fffff097          	auipc	ra,0xfffff
    80001d6c:	65a080e7          	jalr	1626(ra) # 800013c2 <uvmdealloc>
    80001d70:	85aa                	mv	a1,a0
    80001d72:	b7e1                	j	80001d3a <growproc+0x22>

0000000080001d74 <fork>:
{
    80001d74:	7139                	addi	sp,sp,-64
    80001d76:	fc06                	sd	ra,56(sp)
    80001d78:	f822                	sd	s0,48(sp)
    80001d7a:	f426                	sd	s1,40(sp)
    80001d7c:	f04a                	sd	s2,32(sp)
    80001d7e:	ec4e                	sd	s3,24(sp)
    80001d80:	e852                	sd	s4,16(sp)
    80001d82:	e456                	sd	s5,8(sp)
    80001d84:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d86:	00000097          	auipc	ra,0x0
    80001d8a:	c20080e7          	jalr	-992(ra) # 800019a6 <myproc>
    80001d8e:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d90:	00000097          	auipc	ra,0x0
    80001d94:	e30080e7          	jalr	-464(ra) # 80001bc0 <allocproc>
    80001d98:	12050063          	beqz	a0,80001eb8 <fork+0x144>
    80001d9c:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d9e:	048ab603          	ld	a2,72(s5)
    80001da2:	692c                	ld	a1,80(a0)
    80001da4:	050ab503          	ld	a0,80(s5)
    80001da8:	fffff097          	auipc	ra,0xfffff
    80001dac:	7ba080e7          	jalr	1978(ra) # 80001562 <uvmcopy>
    80001db0:	04054863          	bltz	a0,80001e00 <fork+0x8c>
  np->sz = p->sz;
    80001db4:	048ab783          	ld	a5,72(s5)
    80001db8:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001dbc:	058ab683          	ld	a3,88(s5)
    80001dc0:	87b6                	mv	a5,a3
    80001dc2:	0589b703          	ld	a4,88(s3)
    80001dc6:	12068693          	addi	a3,a3,288
    80001dca:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dce:	6788                	ld	a0,8(a5)
    80001dd0:	6b8c                	ld	a1,16(a5)
    80001dd2:	6f90                	ld	a2,24(a5)
    80001dd4:	01073023          	sd	a6,0(a4)
    80001dd8:	e708                	sd	a0,8(a4)
    80001dda:	eb0c                	sd	a1,16(a4)
    80001ddc:	ef10                	sd	a2,24(a4)
    80001dde:	02078793          	addi	a5,a5,32
    80001de2:	02070713          	addi	a4,a4,32
    80001de6:	fed792e3          	bne	a5,a3,80001dca <fork+0x56>
  np->trapframe->a0 = 0;
    80001dea:	0589b783          	ld	a5,88(s3)
    80001dee:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001df2:	0d0a8493          	addi	s1,s5,208
    80001df6:	0d098913          	addi	s2,s3,208
    80001dfa:	150a8a13          	addi	s4,s5,336
    80001dfe:	a00d                	j	80001e20 <fork+0xac>
    freeproc(np);
    80001e00:	854e                	mv	a0,s3
    80001e02:	00000097          	auipc	ra,0x0
    80001e06:	d56080e7          	jalr	-682(ra) # 80001b58 <freeproc>
    release(&np->lock);
    80001e0a:	854e                	mv	a0,s3
    80001e0c:	fffff097          	auipc	ra,0xfffff
    80001e10:	e7a080e7          	jalr	-390(ra) # 80000c86 <release>
    return -1;
    80001e14:	597d                	li	s2,-1
    80001e16:	a079                	j	80001ea4 <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001e18:	04a1                	addi	s1,s1,8
    80001e1a:	0921                	addi	s2,s2,8
    80001e1c:	01448b63          	beq	s1,s4,80001e32 <fork+0xbe>
    if(p->ofile[i])
    80001e20:	6088                	ld	a0,0(s1)
    80001e22:	d97d                	beqz	a0,80001e18 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e24:	00003097          	auipc	ra,0x3
    80001e28:	87a080e7          	jalr	-1926(ra) # 8000469e <filedup>
    80001e2c:	00a93023          	sd	a0,0(s2)
    80001e30:	b7e5                	j	80001e18 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e32:	150ab503          	ld	a0,336(s5)
    80001e36:	00002097          	auipc	ra,0x2
    80001e3a:	a12080e7          	jalr	-1518(ra) # 80003848 <idup>
    80001e3e:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e42:	4641                	li	a2,16
    80001e44:	158a8593          	addi	a1,s5,344
    80001e48:	15898513          	addi	a0,s3,344
    80001e4c:	fffff097          	auipc	ra,0xfffff
    80001e50:	fca080e7          	jalr	-54(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    80001e54:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001e58:	854e                	mv	a0,s3
    80001e5a:	fffff097          	auipc	ra,0xfffff
    80001e5e:	e2c080e7          	jalr	-468(ra) # 80000c86 <release>
  acquire(&wait_lock);
    80001e62:	0000f497          	auipc	s1,0xf
    80001e66:	f2648493          	addi	s1,s1,-218 # 80010d88 <wait_lock>
    80001e6a:	8526                	mv	a0,s1
    80001e6c:	fffff097          	auipc	ra,0xfffff
    80001e70:	d66080e7          	jalr	-666(ra) # 80000bd2 <acquire>
  np->parent = p;
    80001e74:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001e78:	8526                	mv	a0,s1
    80001e7a:	fffff097          	auipc	ra,0xfffff
    80001e7e:	e0c080e7          	jalr	-500(ra) # 80000c86 <release>
  acquire(&np->lock);
    80001e82:	854e                	mv	a0,s3
    80001e84:	fffff097          	auipc	ra,0xfffff
    80001e88:	d4e080e7          	jalr	-690(ra) # 80000bd2 <acquire>
  np->state = RUNNABLE;
    80001e8c:	478d                	li	a5,3
    80001e8e:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001e92:	854e                	mv	a0,s3
    80001e94:	fffff097          	auipc	ra,0xfffff
    80001e98:	df2080e7          	jalr	-526(ra) # 80000c86 <release>
  np->smask = p->smask;
    80001e9c:	168aa783          	lw	a5,360(s5)
    80001ea0:	16f9a423          	sw	a5,360(s3)
}
    80001ea4:	854a                	mv	a0,s2
    80001ea6:	70e2                	ld	ra,56(sp)
    80001ea8:	7442                	ld	s0,48(sp)
    80001eaa:	74a2                	ld	s1,40(sp)
    80001eac:	7902                	ld	s2,32(sp)
    80001eae:	69e2                	ld	s3,24(sp)
    80001eb0:	6a42                	ld	s4,16(sp)
    80001eb2:	6aa2                	ld	s5,8(sp)
    80001eb4:	6121                	addi	sp,sp,64
    80001eb6:	8082                	ret
    return -1;
    80001eb8:	597d                	li	s2,-1
    80001eba:	b7ed                	j	80001ea4 <fork+0x130>

0000000080001ebc <scheduler>:
{
    80001ebc:	7139                	addi	sp,sp,-64
    80001ebe:	fc06                	sd	ra,56(sp)
    80001ec0:	f822                	sd	s0,48(sp)
    80001ec2:	f426                	sd	s1,40(sp)
    80001ec4:	f04a                	sd	s2,32(sp)
    80001ec6:	ec4e                	sd	s3,24(sp)
    80001ec8:	e852                	sd	s4,16(sp)
    80001eca:	e456                	sd	s5,8(sp)
    80001ecc:	e05a                	sd	s6,0(sp)
    80001ece:	0080                	addi	s0,sp,64
    80001ed0:	8792                	mv	a5,tp
  int id = r_tp();
    80001ed2:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ed4:	00779a93          	slli	s5,a5,0x7
    80001ed8:	0000f717          	auipc	a4,0xf
    80001edc:	e9870713          	addi	a4,a4,-360 # 80010d70 <pid_lock>
    80001ee0:	9756                	add	a4,a4,s5
    80001ee2:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ee6:	0000f717          	auipc	a4,0xf
    80001eea:	ec270713          	addi	a4,a4,-318 # 80010da8 <cpus+0x8>
    80001eee:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001ef0:	498d                	li	s3,3
        p->state = RUNNING;
    80001ef2:	4b11                	li	s6,4
        c->proc = p;
    80001ef4:	079e                	slli	a5,a5,0x7
    80001ef6:	0000fa17          	auipc	s4,0xf
    80001efa:	e7aa0a13          	addi	s4,s4,-390 # 80010d70 <pid_lock>
    80001efe:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f00:	00015917          	auipc	s2,0x15
    80001f04:	4a090913          	addi	s2,s2,1184 # 800173a0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f08:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f0c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f10:	10079073          	csrw	sstatus,a5
    80001f14:	0000f497          	auipc	s1,0xf
    80001f18:	28c48493          	addi	s1,s1,652 # 800111a0 <proc>
    80001f1c:	a811                	j	80001f30 <scheduler+0x74>
      release(&p->lock);
    80001f1e:	8526                	mv	a0,s1
    80001f20:	fffff097          	auipc	ra,0xfffff
    80001f24:	d66080e7          	jalr	-666(ra) # 80000c86 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f28:	18848493          	addi	s1,s1,392
    80001f2c:	fd248ee3          	beq	s1,s2,80001f08 <scheduler+0x4c>
      acquire(&p->lock);
    80001f30:	8526                	mv	a0,s1
    80001f32:	fffff097          	auipc	ra,0xfffff
    80001f36:	ca0080e7          	jalr	-864(ra) # 80000bd2 <acquire>
      if(p->state == RUNNABLE) {
    80001f3a:	4c9c                	lw	a5,24(s1)
    80001f3c:	ff3791e3          	bne	a5,s3,80001f1e <scheduler+0x62>
        p->state = RUNNING;
    80001f40:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f44:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f48:	06048593          	addi	a1,s1,96
    80001f4c:	8556                	mv	a0,s5
    80001f4e:	00000097          	auipc	ra,0x0
    80001f52:	686080e7          	jalr	1670(ra) # 800025d4 <swtch>
        c->proc = 0;
    80001f56:	020a3823          	sd	zero,48(s4)
    80001f5a:	b7d1                	j	80001f1e <scheduler+0x62>

0000000080001f5c <sched>:
{
    80001f5c:	7179                	addi	sp,sp,-48
    80001f5e:	f406                	sd	ra,40(sp)
    80001f60:	f022                	sd	s0,32(sp)
    80001f62:	ec26                	sd	s1,24(sp)
    80001f64:	e84a                	sd	s2,16(sp)
    80001f66:	e44e                	sd	s3,8(sp)
    80001f68:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f6a:	00000097          	auipc	ra,0x0
    80001f6e:	a3c080e7          	jalr	-1476(ra) # 800019a6 <myproc>
    80001f72:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f74:	fffff097          	auipc	ra,0xfffff
    80001f78:	be4080e7          	jalr	-1052(ra) # 80000b58 <holding>
    80001f7c:	c93d                	beqz	a0,80001ff2 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f7e:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f80:	2781                	sext.w	a5,a5
    80001f82:	079e                	slli	a5,a5,0x7
    80001f84:	0000f717          	auipc	a4,0xf
    80001f88:	dec70713          	addi	a4,a4,-532 # 80010d70 <pid_lock>
    80001f8c:	97ba                	add	a5,a5,a4
    80001f8e:	0a87a703          	lw	a4,168(a5)
    80001f92:	4785                	li	a5,1
    80001f94:	06f71763          	bne	a4,a5,80002002 <sched+0xa6>
  if(p->state == RUNNING)
    80001f98:	4c98                	lw	a4,24(s1)
    80001f9a:	4791                	li	a5,4
    80001f9c:	06f70b63          	beq	a4,a5,80002012 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fa0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001fa4:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001fa6:	efb5                	bnez	a5,80002022 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fa8:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001faa:	0000f917          	auipc	s2,0xf
    80001fae:	dc690913          	addi	s2,s2,-570 # 80010d70 <pid_lock>
    80001fb2:	2781                	sext.w	a5,a5
    80001fb4:	079e                	slli	a5,a5,0x7
    80001fb6:	97ca                	add	a5,a5,s2
    80001fb8:	0ac7a983          	lw	s3,172(a5)
    80001fbc:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fbe:	2781                	sext.w	a5,a5
    80001fc0:	079e                	slli	a5,a5,0x7
    80001fc2:	0000f597          	auipc	a1,0xf
    80001fc6:	de658593          	addi	a1,a1,-538 # 80010da8 <cpus+0x8>
    80001fca:	95be                	add	a1,a1,a5
    80001fcc:	06048513          	addi	a0,s1,96
    80001fd0:	00000097          	auipc	ra,0x0
    80001fd4:	604080e7          	jalr	1540(ra) # 800025d4 <swtch>
    80001fd8:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fda:	2781                	sext.w	a5,a5
    80001fdc:	079e                	slli	a5,a5,0x7
    80001fde:	993e                	add	s2,s2,a5
    80001fe0:	0b392623          	sw	s3,172(s2)
}
    80001fe4:	70a2                	ld	ra,40(sp)
    80001fe6:	7402                	ld	s0,32(sp)
    80001fe8:	64e2                	ld	s1,24(sp)
    80001fea:	6942                	ld	s2,16(sp)
    80001fec:	69a2                	ld	s3,8(sp)
    80001fee:	6145                	addi	sp,sp,48
    80001ff0:	8082                	ret
    panic("sched p->lock");
    80001ff2:	00006517          	auipc	a0,0x6
    80001ff6:	22650513          	addi	a0,a0,550 # 80008218 <digits+0x1d8>
    80001ffa:	ffffe097          	auipc	ra,0xffffe
    80001ffe:	542080e7          	jalr	1346(ra) # 8000053c <panic>
    panic("sched locks");
    80002002:	00006517          	auipc	a0,0x6
    80002006:	22650513          	addi	a0,a0,550 # 80008228 <digits+0x1e8>
    8000200a:	ffffe097          	auipc	ra,0xffffe
    8000200e:	532080e7          	jalr	1330(ra) # 8000053c <panic>
    panic("sched running");
    80002012:	00006517          	auipc	a0,0x6
    80002016:	22650513          	addi	a0,a0,550 # 80008238 <digits+0x1f8>
    8000201a:	ffffe097          	auipc	ra,0xffffe
    8000201e:	522080e7          	jalr	1314(ra) # 8000053c <panic>
    panic("sched interruptible");
    80002022:	00006517          	auipc	a0,0x6
    80002026:	22650513          	addi	a0,a0,550 # 80008248 <digits+0x208>
    8000202a:	ffffe097          	auipc	ra,0xffffe
    8000202e:	512080e7          	jalr	1298(ra) # 8000053c <panic>

0000000080002032 <yield>:
{
    80002032:	1101                	addi	sp,sp,-32
    80002034:	ec06                	sd	ra,24(sp)
    80002036:	e822                	sd	s0,16(sp)
    80002038:	e426                	sd	s1,8(sp)
    8000203a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000203c:	00000097          	auipc	ra,0x0
    80002040:	96a080e7          	jalr	-1686(ra) # 800019a6 <myproc>
    80002044:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002046:	fffff097          	auipc	ra,0xfffff
    8000204a:	b8c080e7          	jalr	-1140(ra) # 80000bd2 <acquire>
  p->state = RUNNABLE;
    8000204e:	478d                	li	a5,3
    80002050:	cc9c                	sw	a5,24(s1)
  sched();
    80002052:	00000097          	auipc	ra,0x0
    80002056:	f0a080e7          	jalr	-246(ra) # 80001f5c <sched>
  release(&p->lock);
    8000205a:	8526                	mv	a0,s1
    8000205c:	fffff097          	auipc	ra,0xfffff
    80002060:	c2a080e7          	jalr	-982(ra) # 80000c86 <release>
}
    80002064:	60e2                	ld	ra,24(sp)
    80002066:	6442                	ld	s0,16(sp)
    80002068:	64a2                	ld	s1,8(sp)
    8000206a:	6105                	addi	sp,sp,32
    8000206c:	8082                	ret

000000008000206e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000206e:	7179                	addi	sp,sp,-48
    80002070:	f406                	sd	ra,40(sp)
    80002072:	f022                	sd	s0,32(sp)
    80002074:	ec26                	sd	s1,24(sp)
    80002076:	e84a                	sd	s2,16(sp)
    80002078:	e44e                	sd	s3,8(sp)
    8000207a:	1800                	addi	s0,sp,48
    8000207c:	89aa                	mv	s3,a0
    8000207e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002080:	00000097          	auipc	ra,0x0
    80002084:	926080e7          	jalr	-1754(ra) # 800019a6 <myproc>
    80002088:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000208a:	fffff097          	auipc	ra,0xfffff
    8000208e:	b48080e7          	jalr	-1208(ra) # 80000bd2 <acquire>
  release(lk);
    80002092:	854a                	mv	a0,s2
    80002094:	fffff097          	auipc	ra,0xfffff
    80002098:	bf2080e7          	jalr	-1038(ra) # 80000c86 <release>

  // Go to sleep.
  p->chan = chan;
    8000209c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800020a0:	4789                	li	a5,2
    800020a2:	cc9c                	sw	a5,24(s1)

  sched();
    800020a4:	00000097          	auipc	ra,0x0
    800020a8:	eb8080e7          	jalr	-328(ra) # 80001f5c <sched>

  // Tidy up.
  p->chan = 0;
    800020ac:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800020b0:	8526                	mv	a0,s1
    800020b2:	fffff097          	auipc	ra,0xfffff
    800020b6:	bd4080e7          	jalr	-1068(ra) # 80000c86 <release>
  acquire(lk);
    800020ba:	854a                	mv	a0,s2
    800020bc:	fffff097          	auipc	ra,0xfffff
    800020c0:	b16080e7          	jalr	-1258(ra) # 80000bd2 <acquire>
}
    800020c4:	70a2                	ld	ra,40(sp)
    800020c6:	7402                	ld	s0,32(sp)
    800020c8:	64e2                	ld	s1,24(sp)
    800020ca:	6942                	ld	s2,16(sp)
    800020cc:	69a2                	ld	s3,8(sp)
    800020ce:	6145                	addi	sp,sp,48
    800020d0:	8082                	ret

00000000800020d2 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800020d2:	7139                	addi	sp,sp,-64
    800020d4:	fc06                	sd	ra,56(sp)
    800020d6:	f822                	sd	s0,48(sp)
    800020d8:	f426                	sd	s1,40(sp)
    800020da:	f04a                	sd	s2,32(sp)
    800020dc:	ec4e                	sd	s3,24(sp)
    800020de:	e852                	sd	s4,16(sp)
    800020e0:	e456                	sd	s5,8(sp)
    800020e2:	0080                	addi	s0,sp,64
    800020e4:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800020e6:	0000f497          	auipc	s1,0xf
    800020ea:	0ba48493          	addi	s1,s1,186 # 800111a0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800020ee:	4989                	li	s3,2
        p->state = RUNNABLE;
    800020f0:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800020f2:	00015917          	auipc	s2,0x15
    800020f6:	2ae90913          	addi	s2,s2,686 # 800173a0 <tickslock>
    800020fa:	a811                	j	8000210e <wakeup+0x3c>
      }
      release(&p->lock);
    800020fc:	8526                	mv	a0,s1
    800020fe:	fffff097          	auipc	ra,0xfffff
    80002102:	b88080e7          	jalr	-1144(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002106:	18848493          	addi	s1,s1,392
    8000210a:	03248663          	beq	s1,s2,80002136 <wakeup+0x64>
    if(p != myproc()){
    8000210e:	00000097          	auipc	ra,0x0
    80002112:	898080e7          	jalr	-1896(ra) # 800019a6 <myproc>
    80002116:	fea488e3          	beq	s1,a0,80002106 <wakeup+0x34>
      acquire(&p->lock);
    8000211a:	8526                	mv	a0,s1
    8000211c:	fffff097          	auipc	ra,0xfffff
    80002120:	ab6080e7          	jalr	-1354(ra) # 80000bd2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002124:	4c9c                	lw	a5,24(s1)
    80002126:	fd379be3          	bne	a5,s3,800020fc <wakeup+0x2a>
    8000212a:	709c                	ld	a5,32(s1)
    8000212c:	fd4798e3          	bne	a5,s4,800020fc <wakeup+0x2a>
        p->state = RUNNABLE;
    80002130:	0154ac23          	sw	s5,24(s1)
    80002134:	b7e1                	j	800020fc <wakeup+0x2a>
    }
  }
}
    80002136:	70e2                	ld	ra,56(sp)
    80002138:	7442                	ld	s0,48(sp)
    8000213a:	74a2                	ld	s1,40(sp)
    8000213c:	7902                	ld	s2,32(sp)
    8000213e:	69e2                	ld	s3,24(sp)
    80002140:	6a42                	ld	s4,16(sp)
    80002142:	6aa2                	ld	s5,8(sp)
    80002144:	6121                	addi	sp,sp,64
    80002146:	8082                	ret

0000000080002148 <reparent>:
{
    80002148:	7179                	addi	sp,sp,-48
    8000214a:	f406                	sd	ra,40(sp)
    8000214c:	f022                	sd	s0,32(sp)
    8000214e:	ec26                	sd	s1,24(sp)
    80002150:	e84a                	sd	s2,16(sp)
    80002152:	e44e                	sd	s3,8(sp)
    80002154:	e052                	sd	s4,0(sp)
    80002156:	1800                	addi	s0,sp,48
    80002158:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000215a:	0000f497          	auipc	s1,0xf
    8000215e:	04648493          	addi	s1,s1,70 # 800111a0 <proc>
      pp->parent = initproc;
    80002162:	00007a17          	auipc	s4,0x7
    80002166:	996a0a13          	addi	s4,s4,-1642 # 80008af8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000216a:	00015997          	auipc	s3,0x15
    8000216e:	23698993          	addi	s3,s3,566 # 800173a0 <tickslock>
    80002172:	a029                	j	8000217c <reparent+0x34>
    80002174:	18848493          	addi	s1,s1,392
    80002178:	01348d63          	beq	s1,s3,80002192 <reparent+0x4a>
    if(pp->parent == p){
    8000217c:	7c9c                	ld	a5,56(s1)
    8000217e:	ff279be3          	bne	a5,s2,80002174 <reparent+0x2c>
      pp->parent = initproc;
    80002182:	000a3503          	ld	a0,0(s4)
    80002186:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002188:	00000097          	auipc	ra,0x0
    8000218c:	f4a080e7          	jalr	-182(ra) # 800020d2 <wakeup>
    80002190:	b7d5                	j	80002174 <reparent+0x2c>
}
    80002192:	70a2                	ld	ra,40(sp)
    80002194:	7402                	ld	s0,32(sp)
    80002196:	64e2                	ld	s1,24(sp)
    80002198:	6942                	ld	s2,16(sp)
    8000219a:	69a2                	ld	s3,8(sp)
    8000219c:	6a02                	ld	s4,0(sp)
    8000219e:	6145                	addi	sp,sp,48
    800021a0:	8082                	ret

00000000800021a2 <exit>:
{
    800021a2:	7179                	addi	sp,sp,-48
    800021a4:	f406                	sd	ra,40(sp)
    800021a6:	f022                	sd	s0,32(sp)
    800021a8:	ec26                	sd	s1,24(sp)
    800021aa:	e84a                	sd	s2,16(sp)
    800021ac:	e44e                	sd	s3,8(sp)
    800021ae:	e052                	sd	s4,0(sp)
    800021b0:	1800                	addi	s0,sp,48
    800021b2:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021b4:	fffff097          	auipc	ra,0xfffff
    800021b8:	7f2080e7          	jalr	2034(ra) # 800019a6 <myproc>
    800021bc:	89aa                	mv	s3,a0
  if(p == initproc)
    800021be:	00007797          	auipc	a5,0x7
    800021c2:	93a7b783          	ld	a5,-1734(a5) # 80008af8 <initproc>
    800021c6:	0d050493          	addi	s1,a0,208
    800021ca:	15050913          	addi	s2,a0,336
    800021ce:	02a79363          	bne	a5,a0,800021f4 <exit+0x52>
    panic("init exiting");
    800021d2:	00006517          	auipc	a0,0x6
    800021d6:	08e50513          	addi	a0,a0,142 # 80008260 <digits+0x220>
    800021da:	ffffe097          	auipc	ra,0xffffe
    800021de:	362080e7          	jalr	866(ra) # 8000053c <panic>
      fileclose(f);
    800021e2:	00002097          	auipc	ra,0x2
    800021e6:	50e080e7          	jalr	1294(ra) # 800046f0 <fileclose>
      p->ofile[fd] = 0;
    800021ea:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800021ee:	04a1                	addi	s1,s1,8
    800021f0:	01248563          	beq	s1,s2,800021fa <exit+0x58>
    if(p->ofile[fd]){
    800021f4:	6088                	ld	a0,0(s1)
    800021f6:	f575                	bnez	a0,800021e2 <exit+0x40>
    800021f8:	bfdd                	j	800021ee <exit+0x4c>
  begin_op();
    800021fa:	00002097          	auipc	ra,0x2
    800021fe:	032080e7          	jalr	50(ra) # 8000422c <begin_op>
  iput(p->cwd);
    80002202:	1509b503          	ld	a0,336(s3)
    80002206:	00002097          	auipc	ra,0x2
    8000220a:	83a080e7          	jalr	-1990(ra) # 80003a40 <iput>
  end_op();
    8000220e:	00002097          	auipc	ra,0x2
    80002212:	098080e7          	jalr	152(ra) # 800042a6 <end_op>
  p->cwd = 0;
    80002216:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000221a:	0000f497          	auipc	s1,0xf
    8000221e:	b6e48493          	addi	s1,s1,-1170 # 80010d88 <wait_lock>
    80002222:	8526                	mv	a0,s1
    80002224:	fffff097          	auipc	ra,0xfffff
    80002228:	9ae080e7          	jalr	-1618(ra) # 80000bd2 <acquire>
  reparent(p);
    8000222c:	854e                	mv	a0,s3
    8000222e:	00000097          	auipc	ra,0x0
    80002232:	f1a080e7          	jalr	-230(ra) # 80002148 <reparent>
  wakeup(p->parent);
    80002236:	0389b503          	ld	a0,56(s3)
    8000223a:	00000097          	auipc	ra,0x0
    8000223e:	e98080e7          	jalr	-360(ra) # 800020d2 <wakeup>
  acquire(&p->lock);
    80002242:	854e                	mv	a0,s3
    80002244:	fffff097          	auipc	ra,0xfffff
    80002248:	98e080e7          	jalr	-1650(ra) # 80000bd2 <acquire>
  p->xstate = status;
    8000224c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002250:	4795                	li	a5,5
    80002252:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002256:	8526                	mv	a0,s1
    80002258:	fffff097          	auipc	ra,0xfffff
    8000225c:	a2e080e7          	jalr	-1490(ra) # 80000c86 <release>
  sched();
    80002260:	00000097          	auipc	ra,0x0
    80002264:	cfc080e7          	jalr	-772(ra) # 80001f5c <sched>
  panic("zombie exit");
    80002268:	00006517          	auipc	a0,0x6
    8000226c:	00850513          	addi	a0,a0,8 # 80008270 <digits+0x230>
    80002270:	ffffe097          	auipc	ra,0xffffe
    80002274:	2cc080e7          	jalr	716(ra) # 8000053c <panic>

0000000080002278 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002278:	7179                	addi	sp,sp,-48
    8000227a:	f406                	sd	ra,40(sp)
    8000227c:	f022                	sd	s0,32(sp)
    8000227e:	ec26                	sd	s1,24(sp)
    80002280:	e84a                	sd	s2,16(sp)
    80002282:	e44e                	sd	s3,8(sp)
    80002284:	1800                	addi	s0,sp,48
    80002286:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002288:	0000f497          	auipc	s1,0xf
    8000228c:	f1848493          	addi	s1,s1,-232 # 800111a0 <proc>
    80002290:	00015997          	auipc	s3,0x15
    80002294:	11098993          	addi	s3,s3,272 # 800173a0 <tickslock>
    acquire(&p->lock);
    80002298:	8526                	mv	a0,s1
    8000229a:	fffff097          	auipc	ra,0xfffff
    8000229e:	938080e7          	jalr	-1736(ra) # 80000bd2 <acquire>
    if(p->pid == pid){
    800022a2:	589c                	lw	a5,48(s1)
    800022a4:	01278d63          	beq	a5,s2,800022be <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800022a8:	8526                	mv	a0,s1
    800022aa:	fffff097          	auipc	ra,0xfffff
    800022ae:	9dc080e7          	jalr	-1572(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800022b2:	18848493          	addi	s1,s1,392
    800022b6:	ff3491e3          	bne	s1,s3,80002298 <kill+0x20>
  }
  return -1;
    800022ba:	557d                	li	a0,-1
    800022bc:	a829                	j	800022d6 <kill+0x5e>
      p->killed = 1;
    800022be:	4785                	li	a5,1
    800022c0:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800022c2:	4c98                	lw	a4,24(s1)
    800022c4:	4789                	li	a5,2
    800022c6:	00f70f63          	beq	a4,a5,800022e4 <kill+0x6c>
      release(&p->lock);
    800022ca:	8526                	mv	a0,s1
    800022cc:	fffff097          	auipc	ra,0xfffff
    800022d0:	9ba080e7          	jalr	-1606(ra) # 80000c86 <release>
      return 0;
    800022d4:	4501                	li	a0,0
}
    800022d6:	70a2                	ld	ra,40(sp)
    800022d8:	7402                	ld	s0,32(sp)
    800022da:	64e2                	ld	s1,24(sp)
    800022dc:	6942                	ld	s2,16(sp)
    800022de:	69a2                	ld	s3,8(sp)
    800022e0:	6145                	addi	sp,sp,48
    800022e2:	8082                	ret
        p->state = RUNNABLE;
    800022e4:	478d                	li	a5,3
    800022e6:	cc9c                	sw	a5,24(s1)
    800022e8:	b7cd                	j	800022ca <kill+0x52>

00000000800022ea <setkilled>:

void
setkilled(struct proc *p)
{
    800022ea:	1101                	addi	sp,sp,-32
    800022ec:	ec06                	sd	ra,24(sp)
    800022ee:	e822                	sd	s0,16(sp)
    800022f0:	e426                	sd	s1,8(sp)
    800022f2:	1000                	addi	s0,sp,32
    800022f4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022f6:	fffff097          	auipc	ra,0xfffff
    800022fa:	8dc080e7          	jalr	-1828(ra) # 80000bd2 <acquire>
  p->killed = 1;
    800022fe:	4785                	li	a5,1
    80002300:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002302:	8526                	mv	a0,s1
    80002304:	fffff097          	auipc	ra,0xfffff
    80002308:	982080e7          	jalr	-1662(ra) # 80000c86 <release>
}
    8000230c:	60e2                	ld	ra,24(sp)
    8000230e:	6442                	ld	s0,16(sp)
    80002310:	64a2                	ld	s1,8(sp)
    80002312:	6105                	addi	sp,sp,32
    80002314:	8082                	ret

0000000080002316 <killed>:

int
killed(struct proc *p)
{
    80002316:	1101                	addi	sp,sp,-32
    80002318:	ec06                	sd	ra,24(sp)
    8000231a:	e822                	sd	s0,16(sp)
    8000231c:	e426                	sd	s1,8(sp)
    8000231e:	e04a                	sd	s2,0(sp)
    80002320:	1000                	addi	s0,sp,32
    80002322:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002324:	fffff097          	auipc	ra,0xfffff
    80002328:	8ae080e7          	jalr	-1874(ra) # 80000bd2 <acquire>
  k = p->killed;
    8000232c:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002330:	8526                	mv	a0,s1
    80002332:	fffff097          	auipc	ra,0xfffff
    80002336:	954080e7          	jalr	-1708(ra) # 80000c86 <release>
  return k;
}
    8000233a:	854a                	mv	a0,s2
    8000233c:	60e2                	ld	ra,24(sp)
    8000233e:	6442                	ld	s0,16(sp)
    80002340:	64a2                	ld	s1,8(sp)
    80002342:	6902                	ld	s2,0(sp)
    80002344:	6105                	addi	sp,sp,32
    80002346:	8082                	ret

0000000080002348 <wait>:
{
    80002348:	715d                	addi	sp,sp,-80
    8000234a:	e486                	sd	ra,72(sp)
    8000234c:	e0a2                	sd	s0,64(sp)
    8000234e:	fc26                	sd	s1,56(sp)
    80002350:	f84a                	sd	s2,48(sp)
    80002352:	f44e                	sd	s3,40(sp)
    80002354:	f052                	sd	s4,32(sp)
    80002356:	ec56                	sd	s5,24(sp)
    80002358:	e85a                	sd	s6,16(sp)
    8000235a:	e45e                	sd	s7,8(sp)
    8000235c:	e062                	sd	s8,0(sp)
    8000235e:	0880                	addi	s0,sp,80
    80002360:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002362:	fffff097          	auipc	ra,0xfffff
    80002366:	644080e7          	jalr	1604(ra) # 800019a6 <myproc>
    8000236a:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000236c:	0000f517          	auipc	a0,0xf
    80002370:	a1c50513          	addi	a0,a0,-1508 # 80010d88 <wait_lock>
    80002374:	fffff097          	auipc	ra,0xfffff
    80002378:	85e080e7          	jalr	-1954(ra) # 80000bd2 <acquire>
    havekids = 0;
    8000237c:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000237e:	4a15                	li	s4,5
        havekids = 1;
    80002380:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002382:	00015997          	auipc	s3,0x15
    80002386:	01e98993          	addi	s3,s3,30 # 800173a0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000238a:	0000fc17          	auipc	s8,0xf
    8000238e:	9fec0c13          	addi	s8,s8,-1538 # 80010d88 <wait_lock>
    80002392:	a0d1                	j	80002456 <wait+0x10e>
          pid = pp->pid;
    80002394:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002398:	000b0e63          	beqz	s6,800023b4 <wait+0x6c>
    8000239c:	4691                	li	a3,4
    8000239e:	02c48613          	addi	a2,s1,44
    800023a2:	85da                	mv	a1,s6
    800023a4:	05093503          	ld	a0,80(s2)
    800023a8:	fffff097          	auipc	ra,0xfffff
    800023ac:	2be080e7          	jalr	702(ra) # 80001666 <copyout>
    800023b0:	04054163          	bltz	a0,800023f2 <wait+0xaa>
          freeproc(pp);
    800023b4:	8526                	mv	a0,s1
    800023b6:	fffff097          	auipc	ra,0xfffff
    800023ba:	7a2080e7          	jalr	1954(ra) # 80001b58 <freeproc>
          release(&pp->lock);
    800023be:	8526                	mv	a0,s1
    800023c0:	fffff097          	auipc	ra,0xfffff
    800023c4:	8c6080e7          	jalr	-1850(ra) # 80000c86 <release>
          release(&wait_lock);
    800023c8:	0000f517          	auipc	a0,0xf
    800023cc:	9c050513          	addi	a0,a0,-1600 # 80010d88 <wait_lock>
    800023d0:	fffff097          	auipc	ra,0xfffff
    800023d4:	8b6080e7          	jalr	-1866(ra) # 80000c86 <release>
}
    800023d8:	854e                	mv	a0,s3
    800023da:	60a6                	ld	ra,72(sp)
    800023dc:	6406                	ld	s0,64(sp)
    800023de:	74e2                	ld	s1,56(sp)
    800023e0:	7942                	ld	s2,48(sp)
    800023e2:	79a2                	ld	s3,40(sp)
    800023e4:	7a02                	ld	s4,32(sp)
    800023e6:	6ae2                	ld	s5,24(sp)
    800023e8:	6b42                	ld	s6,16(sp)
    800023ea:	6ba2                	ld	s7,8(sp)
    800023ec:	6c02                	ld	s8,0(sp)
    800023ee:	6161                	addi	sp,sp,80
    800023f0:	8082                	ret
            release(&pp->lock);
    800023f2:	8526                	mv	a0,s1
    800023f4:	fffff097          	auipc	ra,0xfffff
    800023f8:	892080e7          	jalr	-1902(ra) # 80000c86 <release>
            release(&wait_lock);
    800023fc:	0000f517          	auipc	a0,0xf
    80002400:	98c50513          	addi	a0,a0,-1652 # 80010d88 <wait_lock>
    80002404:	fffff097          	auipc	ra,0xfffff
    80002408:	882080e7          	jalr	-1918(ra) # 80000c86 <release>
            return -1;
    8000240c:	59fd                	li	s3,-1
    8000240e:	b7e9                	j	800023d8 <wait+0x90>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002410:	18848493          	addi	s1,s1,392
    80002414:	03348463          	beq	s1,s3,8000243c <wait+0xf4>
      if(pp->parent == p){
    80002418:	7c9c                	ld	a5,56(s1)
    8000241a:	ff279be3          	bne	a5,s2,80002410 <wait+0xc8>
        acquire(&pp->lock);
    8000241e:	8526                	mv	a0,s1
    80002420:	ffffe097          	auipc	ra,0xffffe
    80002424:	7b2080e7          	jalr	1970(ra) # 80000bd2 <acquire>
        if(pp->state == ZOMBIE){
    80002428:	4c9c                	lw	a5,24(s1)
    8000242a:	f74785e3          	beq	a5,s4,80002394 <wait+0x4c>
        release(&pp->lock);
    8000242e:	8526                	mv	a0,s1
    80002430:	fffff097          	auipc	ra,0xfffff
    80002434:	856080e7          	jalr	-1962(ra) # 80000c86 <release>
        havekids = 1;
    80002438:	8756                	mv	a4,s5
    8000243a:	bfd9                	j	80002410 <wait+0xc8>
    if(!havekids || killed(p)){
    8000243c:	c31d                	beqz	a4,80002462 <wait+0x11a>
    8000243e:	854a                	mv	a0,s2
    80002440:	00000097          	auipc	ra,0x0
    80002444:	ed6080e7          	jalr	-298(ra) # 80002316 <killed>
    80002448:	ed09                	bnez	a0,80002462 <wait+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000244a:	85e2                	mv	a1,s8
    8000244c:	854a                	mv	a0,s2
    8000244e:	00000097          	auipc	ra,0x0
    80002452:	c20080e7          	jalr	-992(ra) # 8000206e <sleep>
    havekids = 0;
    80002456:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002458:	0000f497          	auipc	s1,0xf
    8000245c:	d4848493          	addi	s1,s1,-696 # 800111a0 <proc>
    80002460:	bf65                	j	80002418 <wait+0xd0>
      release(&wait_lock);
    80002462:	0000f517          	auipc	a0,0xf
    80002466:	92650513          	addi	a0,a0,-1754 # 80010d88 <wait_lock>
    8000246a:	fffff097          	auipc	ra,0xfffff
    8000246e:	81c080e7          	jalr	-2020(ra) # 80000c86 <release>
      return -1;
    80002472:	59fd                	li	s3,-1
    80002474:	b795                	j	800023d8 <wait+0x90>

0000000080002476 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002476:	7179                	addi	sp,sp,-48
    80002478:	f406                	sd	ra,40(sp)
    8000247a:	f022                	sd	s0,32(sp)
    8000247c:	ec26                	sd	s1,24(sp)
    8000247e:	e84a                	sd	s2,16(sp)
    80002480:	e44e                	sd	s3,8(sp)
    80002482:	e052                	sd	s4,0(sp)
    80002484:	1800                	addi	s0,sp,48
    80002486:	84aa                	mv	s1,a0
    80002488:	892e                	mv	s2,a1
    8000248a:	89b2                	mv	s3,a2
    8000248c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000248e:	fffff097          	auipc	ra,0xfffff
    80002492:	518080e7          	jalr	1304(ra) # 800019a6 <myproc>
  if(user_dst){
    80002496:	c08d                	beqz	s1,800024b8 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002498:	86d2                	mv	a3,s4
    8000249a:	864e                	mv	a2,s3
    8000249c:	85ca                	mv	a1,s2
    8000249e:	6928                	ld	a0,80(a0)
    800024a0:	fffff097          	auipc	ra,0xfffff
    800024a4:	1c6080e7          	jalr	454(ra) # 80001666 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024a8:	70a2                	ld	ra,40(sp)
    800024aa:	7402                	ld	s0,32(sp)
    800024ac:	64e2                	ld	s1,24(sp)
    800024ae:	6942                	ld	s2,16(sp)
    800024b0:	69a2                	ld	s3,8(sp)
    800024b2:	6a02                	ld	s4,0(sp)
    800024b4:	6145                	addi	sp,sp,48
    800024b6:	8082                	ret
    memmove((char *)dst, src, len);
    800024b8:	000a061b          	sext.w	a2,s4
    800024bc:	85ce                	mv	a1,s3
    800024be:	854a                	mv	a0,s2
    800024c0:	fffff097          	auipc	ra,0xfffff
    800024c4:	86a080e7          	jalr	-1942(ra) # 80000d2a <memmove>
    return 0;
    800024c8:	8526                	mv	a0,s1
    800024ca:	bff9                	j	800024a8 <either_copyout+0x32>

00000000800024cc <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024cc:	7179                	addi	sp,sp,-48
    800024ce:	f406                	sd	ra,40(sp)
    800024d0:	f022                	sd	s0,32(sp)
    800024d2:	ec26                	sd	s1,24(sp)
    800024d4:	e84a                	sd	s2,16(sp)
    800024d6:	e44e                	sd	s3,8(sp)
    800024d8:	e052                	sd	s4,0(sp)
    800024da:	1800                	addi	s0,sp,48
    800024dc:	892a                	mv	s2,a0
    800024de:	84ae                	mv	s1,a1
    800024e0:	89b2                	mv	s3,a2
    800024e2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024e4:	fffff097          	auipc	ra,0xfffff
    800024e8:	4c2080e7          	jalr	1218(ra) # 800019a6 <myproc>
  if(user_src){
    800024ec:	c08d                	beqz	s1,8000250e <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024ee:	86d2                	mv	a3,s4
    800024f0:	864e                	mv	a2,s3
    800024f2:	85ca                	mv	a1,s2
    800024f4:	6928                	ld	a0,80(a0)
    800024f6:	fffff097          	auipc	ra,0xfffff
    800024fa:	1fc080e7          	jalr	508(ra) # 800016f2 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024fe:	70a2                	ld	ra,40(sp)
    80002500:	7402                	ld	s0,32(sp)
    80002502:	64e2                	ld	s1,24(sp)
    80002504:	6942                	ld	s2,16(sp)
    80002506:	69a2                	ld	s3,8(sp)
    80002508:	6a02                	ld	s4,0(sp)
    8000250a:	6145                	addi	sp,sp,48
    8000250c:	8082                	ret
    memmove(dst, (char*)src, len);
    8000250e:	000a061b          	sext.w	a2,s4
    80002512:	85ce                	mv	a1,s3
    80002514:	854a                	mv	a0,s2
    80002516:	fffff097          	auipc	ra,0xfffff
    8000251a:	814080e7          	jalr	-2028(ra) # 80000d2a <memmove>
    return 0;
    8000251e:	8526                	mv	a0,s1
    80002520:	bff9                	j	800024fe <either_copyin+0x32>

0000000080002522 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002522:	715d                	addi	sp,sp,-80
    80002524:	e486                	sd	ra,72(sp)
    80002526:	e0a2                	sd	s0,64(sp)
    80002528:	fc26                	sd	s1,56(sp)
    8000252a:	f84a                	sd	s2,48(sp)
    8000252c:	f44e                	sd	s3,40(sp)
    8000252e:	f052                	sd	s4,32(sp)
    80002530:	ec56                	sd	s5,24(sp)
    80002532:	e85a                	sd	s6,16(sp)
    80002534:	e45e                	sd	s7,8(sp)
    80002536:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002538:	00006517          	auipc	a0,0x6
    8000253c:	b9050513          	addi	a0,a0,-1136 # 800080c8 <digits+0x88>
    80002540:	ffffe097          	auipc	ra,0xffffe
    80002544:	046080e7          	jalr	70(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002548:	0000f497          	auipc	s1,0xf
    8000254c:	db048493          	addi	s1,s1,-592 # 800112f8 <proc+0x158>
    80002550:	00015917          	auipc	s2,0x15
    80002554:	fa890913          	addi	s2,s2,-88 # 800174f8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002558:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000255a:	00006997          	auipc	s3,0x6
    8000255e:	d2698993          	addi	s3,s3,-730 # 80008280 <digits+0x240>
    // Specification 1
    printf("%d %s %s %d", p->pid, state, p->name, p->smask);
    80002562:	00006a97          	auipc	s5,0x6
    80002566:	d26a8a93          	addi	s5,s5,-730 # 80008288 <digits+0x248>
    printf("\n");
    8000256a:	00006a17          	auipc	s4,0x6
    8000256e:	b5ea0a13          	addi	s4,s4,-1186 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002572:	00006b97          	auipc	s7,0x6
    80002576:	d56b8b93          	addi	s7,s7,-682 # 800082c8 <states.0>
    8000257a:	a015                	j	8000259e <procdump+0x7c>
    printf("%d %s %s %d", p->pid, state, p->name, p->smask);
    8000257c:	4a98                	lw	a4,16(a3)
    8000257e:	ed86a583          	lw	a1,-296(a3)
    80002582:	8556                	mv	a0,s5
    80002584:	ffffe097          	auipc	ra,0xffffe
    80002588:	002080e7          	jalr	2(ra) # 80000586 <printf>
    printf("\n");
    8000258c:	8552                	mv	a0,s4
    8000258e:	ffffe097          	auipc	ra,0xffffe
    80002592:	ff8080e7          	jalr	-8(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002596:	18848493          	addi	s1,s1,392
    8000259a:	03248263          	beq	s1,s2,800025be <procdump+0x9c>
    if(p->state == UNUSED)
    8000259e:	86a6                	mv	a3,s1
    800025a0:	ec04a783          	lw	a5,-320(s1)
    800025a4:	dbed                	beqz	a5,80002596 <procdump+0x74>
      state = "???";
    800025a6:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025a8:	fcfb6ae3          	bltu	s6,a5,8000257c <procdump+0x5a>
    800025ac:	02079713          	slli	a4,a5,0x20
    800025b0:	01d75793          	srli	a5,a4,0x1d
    800025b4:	97de                	add	a5,a5,s7
    800025b6:	6390                	ld	a2,0(a5)
    800025b8:	f271                	bnez	a2,8000257c <procdump+0x5a>
      state = "???";
    800025ba:	864e                	mv	a2,s3
    800025bc:	b7c1                	j	8000257c <procdump+0x5a>
  }
}
    800025be:	60a6                	ld	ra,72(sp)
    800025c0:	6406                	ld	s0,64(sp)
    800025c2:	74e2                	ld	s1,56(sp)
    800025c4:	7942                	ld	s2,48(sp)
    800025c6:	79a2                	ld	s3,40(sp)
    800025c8:	7a02                	ld	s4,32(sp)
    800025ca:	6ae2                	ld	s5,24(sp)
    800025cc:	6b42                	ld	s6,16(sp)
    800025ce:	6ba2                	ld	s7,8(sp)
    800025d0:	6161                	addi	sp,sp,80
    800025d2:	8082                	ret

00000000800025d4 <swtch>:
    800025d4:	00153023          	sd	ra,0(a0)
    800025d8:	00253423          	sd	sp,8(a0)
    800025dc:	e900                	sd	s0,16(a0)
    800025de:	ed04                	sd	s1,24(a0)
    800025e0:	03253023          	sd	s2,32(a0)
    800025e4:	03353423          	sd	s3,40(a0)
    800025e8:	03453823          	sd	s4,48(a0)
    800025ec:	03553c23          	sd	s5,56(a0)
    800025f0:	05653023          	sd	s6,64(a0)
    800025f4:	05753423          	sd	s7,72(a0)
    800025f8:	05853823          	sd	s8,80(a0)
    800025fc:	05953c23          	sd	s9,88(a0)
    80002600:	07a53023          	sd	s10,96(a0)
    80002604:	07b53423          	sd	s11,104(a0)
    80002608:	0005b083          	ld	ra,0(a1)
    8000260c:	0085b103          	ld	sp,8(a1)
    80002610:	6980                	ld	s0,16(a1)
    80002612:	6d84                	ld	s1,24(a1)
    80002614:	0205b903          	ld	s2,32(a1)
    80002618:	0285b983          	ld	s3,40(a1)
    8000261c:	0305ba03          	ld	s4,48(a1)
    80002620:	0385ba83          	ld	s5,56(a1)
    80002624:	0405bb03          	ld	s6,64(a1)
    80002628:	0485bb83          	ld	s7,72(a1)
    8000262c:	0505bc03          	ld	s8,80(a1)
    80002630:	0585bc83          	ld	s9,88(a1)
    80002634:	0605bd03          	ld	s10,96(a1)
    80002638:	0685bd83          	ld	s11,104(a1)
    8000263c:	8082                	ret

000000008000263e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000263e:	1141                	addi	sp,sp,-16
    80002640:	e406                	sd	ra,8(sp)
    80002642:	e022                	sd	s0,0(sp)
    80002644:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002646:	00006597          	auipc	a1,0x6
    8000264a:	cb258593          	addi	a1,a1,-846 # 800082f8 <states.0+0x30>
    8000264e:	00015517          	auipc	a0,0x15
    80002652:	d5250513          	addi	a0,a0,-686 # 800173a0 <tickslock>
    80002656:	ffffe097          	auipc	ra,0xffffe
    8000265a:	4ec080e7          	jalr	1260(ra) # 80000b42 <initlock>
}
    8000265e:	60a2                	ld	ra,8(sp)
    80002660:	6402                	ld	s0,0(sp)
    80002662:	0141                	addi	sp,sp,16
    80002664:	8082                	ret

0000000080002666 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002666:	1141                	addi	sp,sp,-16
    80002668:	e422                	sd	s0,8(sp)
    8000266a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000266c:	00003797          	auipc	a5,0x3
    80002670:	6a478793          	addi	a5,a5,1700 # 80005d10 <kernelvec>
    80002674:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002678:	6422                	ld	s0,8(sp)
    8000267a:	0141                	addi	sp,sp,16
    8000267c:	8082                	ret

000000008000267e <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000267e:	1141                	addi	sp,sp,-16
    80002680:	e406                	sd	ra,8(sp)
    80002682:	e022                	sd	s0,0(sp)
    80002684:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002686:	fffff097          	auipc	ra,0xfffff
    8000268a:	320080e7          	jalr	800(ra) # 800019a6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000268e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002692:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002694:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002698:	00005697          	auipc	a3,0x5
    8000269c:	96868693          	addi	a3,a3,-1688 # 80007000 <_trampoline>
    800026a0:	00005717          	auipc	a4,0x5
    800026a4:	96070713          	addi	a4,a4,-1696 # 80007000 <_trampoline>
    800026a8:	8f15                	sub	a4,a4,a3
    800026aa:	040007b7          	lui	a5,0x4000
    800026ae:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800026b0:	07b2                	slli	a5,a5,0xc
    800026b2:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026b4:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026b8:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026ba:	18002673          	csrr	a2,satp
    800026be:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026c0:	6d30                	ld	a2,88(a0)
    800026c2:	6138                	ld	a4,64(a0)
    800026c4:	6585                	lui	a1,0x1
    800026c6:	972e                	add	a4,a4,a1
    800026c8:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026ca:	6d38                	ld	a4,88(a0)
    800026cc:	00000617          	auipc	a2,0x0
    800026d0:	13460613          	addi	a2,a2,308 # 80002800 <usertrap>
    800026d4:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026d6:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026d8:	8612                	mv	a2,tp
    800026da:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026dc:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026e0:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026e4:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026e8:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026ec:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026ee:	6f18                	ld	a4,24(a4)
    800026f0:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800026f4:	6928                	ld	a0,80(a0)
    800026f6:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800026f8:	00005717          	auipc	a4,0x5
    800026fc:	9a470713          	addi	a4,a4,-1628 # 8000709c <userret>
    80002700:	8f15                	sub	a4,a4,a3
    80002702:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002704:	577d                	li	a4,-1
    80002706:	177e                	slli	a4,a4,0x3f
    80002708:	8d59                	or	a0,a0,a4
    8000270a:	9782                	jalr	a5
}
    8000270c:	60a2                	ld	ra,8(sp)
    8000270e:	6402                	ld	s0,0(sp)
    80002710:	0141                	addi	sp,sp,16
    80002712:	8082                	ret

0000000080002714 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002714:	1101                	addi	sp,sp,-32
    80002716:	ec06                	sd	ra,24(sp)
    80002718:	e822                	sd	s0,16(sp)
    8000271a:	e426                	sd	s1,8(sp)
    8000271c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000271e:	00015497          	auipc	s1,0x15
    80002722:	c8248493          	addi	s1,s1,-894 # 800173a0 <tickslock>
    80002726:	8526                	mv	a0,s1
    80002728:	ffffe097          	auipc	ra,0xffffe
    8000272c:	4aa080e7          	jalr	1194(ra) # 80000bd2 <acquire>
  ticks++;
    80002730:	00006517          	auipc	a0,0x6
    80002734:	3d050513          	addi	a0,a0,976 # 80008b00 <ticks>
    80002738:	411c                	lw	a5,0(a0)
    8000273a:	2785                	addiw	a5,a5,1
    8000273c:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000273e:	00000097          	auipc	ra,0x0
    80002742:	994080e7          	jalr	-1644(ra) # 800020d2 <wakeup>
  release(&tickslock);
    80002746:	8526                	mv	a0,s1
    80002748:	ffffe097          	auipc	ra,0xffffe
    8000274c:	53e080e7          	jalr	1342(ra) # 80000c86 <release>
}
    80002750:	60e2                	ld	ra,24(sp)
    80002752:	6442                	ld	s0,16(sp)
    80002754:	64a2                	ld	s1,8(sp)
    80002756:	6105                	addi	sp,sp,32
    80002758:	8082                	ret

000000008000275a <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000275a:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    8000275e:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002760:	0807df63          	bgez	a5,800027fe <devintr+0xa4>
{
    80002764:	1101                	addi	sp,sp,-32
    80002766:	ec06                	sd	ra,24(sp)
    80002768:	e822                	sd	s0,16(sp)
    8000276a:	e426                	sd	s1,8(sp)
    8000276c:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    8000276e:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002772:	46a5                	li	a3,9
    80002774:	00d70d63          	beq	a4,a3,8000278e <devintr+0x34>
  } else if(scause == 0x8000000000000001L){
    80002778:	577d                	li	a4,-1
    8000277a:	177e                	slli	a4,a4,0x3f
    8000277c:	0705                	addi	a4,a4,1
    return 0;
    8000277e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002780:	04e78e63          	beq	a5,a4,800027dc <devintr+0x82>
  }
}
    80002784:	60e2                	ld	ra,24(sp)
    80002786:	6442                	ld	s0,16(sp)
    80002788:	64a2                	ld	s1,8(sp)
    8000278a:	6105                	addi	sp,sp,32
    8000278c:	8082                	ret
    int irq = plic_claim();
    8000278e:	00003097          	auipc	ra,0x3
    80002792:	68a080e7          	jalr	1674(ra) # 80005e18 <plic_claim>
    80002796:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002798:	47a9                	li	a5,10
    8000279a:	02f50763          	beq	a0,a5,800027c8 <devintr+0x6e>
    } else if(irq == VIRTIO0_IRQ){
    8000279e:	4785                	li	a5,1
    800027a0:	02f50963          	beq	a0,a5,800027d2 <devintr+0x78>
    return 1;
    800027a4:	4505                	li	a0,1
    } else if(irq){
    800027a6:	dcf9                	beqz	s1,80002784 <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    800027a8:	85a6                	mv	a1,s1
    800027aa:	00006517          	auipc	a0,0x6
    800027ae:	b5650513          	addi	a0,a0,-1194 # 80008300 <states.0+0x38>
    800027b2:	ffffe097          	auipc	ra,0xffffe
    800027b6:	dd4080e7          	jalr	-556(ra) # 80000586 <printf>
      plic_complete(irq);
    800027ba:	8526                	mv	a0,s1
    800027bc:	00003097          	auipc	ra,0x3
    800027c0:	680080e7          	jalr	1664(ra) # 80005e3c <plic_complete>
    return 1;
    800027c4:	4505                	li	a0,1
    800027c6:	bf7d                	j	80002784 <devintr+0x2a>
      uartintr();
    800027c8:	ffffe097          	auipc	ra,0xffffe
    800027cc:	1cc080e7          	jalr	460(ra) # 80000994 <uartintr>
    if(irq)
    800027d0:	b7ed                	j	800027ba <devintr+0x60>
      virtio_disk_intr();
    800027d2:	00004097          	auipc	ra,0x4
    800027d6:	b30080e7          	jalr	-1232(ra) # 80006302 <virtio_disk_intr>
    if(irq)
    800027da:	b7c5                	j	800027ba <devintr+0x60>
    if(cpuid() == 0){
    800027dc:	fffff097          	auipc	ra,0xfffff
    800027e0:	19e080e7          	jalr	414(ra) # 8000197a <cpuid>
    800027e4:	c901                	beqz	a0,800027f4 <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800027e6:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800027ea:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800027ec:	14479073          	csrw	sip,a5
    return 2;
    800027f0:	4509                	li	a0,2
    800027f2:	bf49                	j	80002784 <devintr+0x2a>
      clockintr();
    800027f4:	00000097          	auipc	ra,0x0
    800027f8:	f20080e7          	jalr	-224(ra) # 80002714 <clockintr>
    800027fc:	b7ed                	j	800027e6 <devintr+0x8c>
}
    800027fe:	8082                	ret

0000000080002800 <usertrap>:
{
    80002800:	1101                	addi	sp,sp,-32
    80002802:	ec06                	sd	ra,24(sp)
    80002804:	e822                	sd	s0,16(sp)
    80002806:	e426                	sd	s1,8(sp)
    80002808:	e04a                	sd	s2,0(sp)
    8000280a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000280c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002810:	1007f793          	andi	a5,a5,256
    80002814:	e7bd                	bnez	a5,80002882 <usertrap+0x82>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002816:	00003797          	auipc	a5,0x3
    8000281a:	4fa78793          	addi	a5,a5,1274 # 80005d10 <kernelvec>
    8000281e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002822:	fffff097          	auipc	ra,0xfffff
    80002826:	184080e7          	jalr	388(ra) # 800019a6 <myproc>
    8000282a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000282c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000282e:	14102773          	csrr	a4,sepc
    80002832:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002834:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002838:	47a1                	li	a5,8
    8000283a:	04f70c63          	beq	a4,a5,80002892 <usertrap+0x92>
  } else if((which_dev = devintr()) != 0){
    8000283e:	00000097          	auipc	ra,0x0
    80002842:	f1c080e7          	jalr	-228(ra) # 8000275a <devintr>
    80002846:	892a                	mv	s2,a0
    80002848:	c561                	beqz	a0,80002910 <usertrap+0x110>
    if(which_dev==2 && p->alarmOn==0){
    8000284a:	4789                	li	a5,2
    8000284c:	06f51763          	bne	a0,a5,800028ba <usertrap+0xba>
    80002850:	17c4a783          	lw	a5,380(s1)
    80002854:	ef81                	bnez	a5,8000286c <usertrap+0x6c>
      p->nticks += 1;
    80002856:	1784a783          	lw	a5,376(s1)
    8000285a:	2785                	addiw	a5,a5,1
    8000285c:	0007871b          	sext.w	a4,a5
    80002860:	16f4ac23          	sw	a5,376(s1)
      if(p->nticks==p->interval){
    80002864:	16c4a783          	lw	a5,364(s1)
    80002868:	06e78f63          	beq	a5,a4,800028e6 <usertrap+0xe6>
  if(killed(p))
    8000286c:	8526                	mv	a0,s1
    8000286e:	00000097          	auipc	ra,0x0
    80002872:	aa8080e7          	jalr	-1368(ra) # 80002316 <killed>
    80002876:	e17d                	bnez	a0,8000295c <usertrap+0x15c>
    yield();
    80002878:	fffff097          	auipc	ra,0xfffff
    8000287c:	7ba080e7          	jalr	1978(ra) # 80002032 <yield>
    80002880:	a099                	j	800028c6 <usertrap+0xc6>
    panic("usertrap: not from user mode");
    80002882:	00006517          	auipc	a0,0x6
    80002886:	a9e50513          	addi	a0,a0,-1378 # 80008320 <states.0+0x58>
    8000288a:	ffffe097          	auipc	ra,0xffffe
    8000288e:	cb2080e7          	jalr	-846(ra) # 8000053c <panic>
    if(killed(p))
    80002892:	00000097          	auipc	ra,0x0
    80002896:	a84080e7          	jalr	-1404(ra) # 80002316 <killed>
    8000289a:	e121                	bnez	a0,800028da <usertrap+0xda>
    p->trapframe->epc += 4;
    8000289c:	6cb8                	ld	a4,88(s1)
    8000289e:	6f1c                	ld	a5,24(a4)
    800028a0:	0791                	addi	a5,a5,4
    800028a2:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028a4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800028a8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028ac:	10079073          	csrw	sstatus,a5
    syscall();
    800028b0:	00000097          	auipc	ra,0x0
    800028b4:	302080e7          	jalr	770(ra) # 80002bb2 <syscall>
  int which_dev = 0;
    800028b8:	4901                	li	s2,0
  if(killed(p))
    800028ba:	8526                	mv	a0,s1
    800028bc:	00000097          	auipc	ra,0x0
    800028c0:	a5a080e7          	jalr	-1446(ra) # 80002316 <killed>
    800028c4:	e159                	bnez	a0,8000294a <usertrap+0x14a>
  usertrapret();
    800028c6:	00000097          	auipc	ra,0x0
    800028ca:	db8080e7          	jalr	-584(ra) # 8000267e <usertrapret>
}
    800028ce:	60e2                	ld	ra,24(sp)
    800028d0:	6442                	ld	s0,16(sp)
    800028d2:	64a2                	ld	s1,8(sp)
    800028d4:	6902                	ld	s2,0(sp)
    800028d6:	6105                	addi	sp,sp,32
    800028d8:	8082                	ret
      exit(-1);
    800028da:	557d                	li	a0,-1
    800028dc:	00000097          	auipc	ra,0x0
    800028e0:	8c6080e7          	jalr	-1850(ra) # 800021a2 <exit>
    800028e4:	bf65                	j	8000289c <usertrap+0x9c>
        struct trapframe *context = kalloc();
    800028e6:	ffffe097          	auipc	ra,0xffffe
    800028ea:	1fc080e7          	jalr	508(ra) # 80000ae2 <kalloc>
    800028ee:	892a                	mv	s2,a0
        memmove(context,p->trapframe,PGSIZE);
    800028f0:	6605                	lui	a2,0x1
    800028f2:	6cac                	ld	a1,88(s1)
    800028f4:	ffffe097          	auipc	ra,0xffffe
    800028f8:	436080e7          	jalr	1078(ra) # 80000d2a <memmove>
        p->alarmContext = context;
    800028fc:	1924b023          	sd	s2,384(s1)
        p->alarmOn =1; // done to prevent reentrance (test 2)
    80002900:	4785                	li	a5,1
    80002902:	16f4ae23          	sw	a5,380(s1)
        p->trapframe->epc = p->handler;
    80002906:	6cbc                	ld	a5,88(s1)
    80002908:	1704b703          	ld	a4,368(s1)
    8000290c:	ef98                	sd	a4,24(a5)
    8000290e:	bfb9                	j	8000286c <usertrap+0x6c>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002910:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002914:	5890                	lw	a2,48(s1)
    80002916:	00006517          	auipc	a0,0x6
    8000291a:	a2a50513          	addi	a0,a0,-1494 # 80008340 <states.0+0x78>
    8000291e:	ffffe097          	auipc	ra,0xffffe
    80002922:	c68080e7          	jalr	-920(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002926:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000292a:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000292e:	00006517          	auipc	a0,0x6
    80002932:	a4250513          	addi	a0,a0,-1470 # 80008370 <states.0+0xa8>
    80002936:	ffffe097          	auipc	ra,0xffffe
    8000293a:	c50080e7          	jalr	-944(ra) # 80000586 <printf>
    setkilled(p);
    8000293e:	8526                	mv	a0,s1
    80002940:	00000097          	auipc	ra,0x0
    80002944:	9aa080e7          	jalr	-1622(ra) # 800022ea <setkilled>
    80002948:	bf8d                	j	800028ba <usertrap+0xba>
    exit(-1);
    8000294a:	557d                	li	a0,-1
    8000294c:	00000097          	auipc	ra,0x0
    80002950:	856080e7          	jalr	-1962(ra) # 800021a2 <exit>
  if(which_dev == 2)
    80002954:	4789                	li	a5,2
    80002956:	f6f918e3          	bne	s2,a5,800028c6 <usertrap+0xc6>
    8000295a:	bf39                	j	80002878 <usertrap+0x78>
    exit(-1);
    8000295c:	557d                	li	a0,-1
    8000295e:	00000097          	auipc	ra,0x0
    80002962:	844080e7          	jalr	-1980(ra) # 800021a2 <exit>
  if(which_dev == 2)
    80002966:	bf09                	j	80002878 <usertrap+0x78>

0000000080002968 <kerneltrap>:
{
    80002968:	7179                	addi	sp,sp,-48
    8000296a:	f406                	sd	ra,40(sp)
    8000296c:	f022                	sd	s0,32(sp)
    8000296e:	ec26                	sd	s1,24(sp)
    80002970:	e84a                	sd	s2,16(sp)
    80002972:	e44e                	sd	s3,8(sp)
    80002974:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002976:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000297a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000297e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002982:	1004f793          	andi	a5,s1,256
    80002986:	cb85                	beqz	a5,800029b6 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002988:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000298c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000298e:	ef85                	bnez	a5,800029c6 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002990:	00000097          	auipc	ra,0x0
    80002994:	dca080e7          	jalr	-566(ra) # 8000275a <devintr>
    80002998:	cd1d                	beqz	a0,800029d6 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000299a:	4789                	li	a5,2
    8000299c:	06f50a63          	beq	a0,a5,80002a10 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029a0:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029a4:	10049073          	csrw	sstatus,s1
}
    800029a8:	70a2                	ld	ra,40(sp)
    800029aa:	7402                	ld	s0,32(sp)
    800029ac:	64e2                	ld	s1,24(sp)
    800029ae:	6942                	ld	s2,16(sp)
    800029b0:	69a2                	ld	s3,8(sp)
    800029b2:	6145                	addi	sp,sp,48
    800029b4:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800029b6:	00006517          	auipc	a0,0x6
    800029ba:	9da50513          	addi	a0,a0,-1574 # 80008390 <states.0+0xc8>
    800029be:	ffffe097          	auipc	ra,0xffffe
    800029c2:	b7e080e7          	jalr	-1154(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    800029c6:	00006517          	auipc	a0,0x6
    800029ca:	9f250513          	addi	a0,a0,-1550 # 800083b8 <states.0+0xf0>
    800029ce:	ffffe097          	auipc	ra,0xffffe
    800029d2:	b6e080e7          	jalr	-1170(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    800029d6:	85ce                	mv	a1,s3
    800029d8:	00006517          	auipc	a0,0x6
    800029dc:	a0050513          	addi	a0,a0,-1536 # 800083d8 <states.0+0x110>
    800029e0:	ffffe097          	auipc	ra,0xffffe
    800029e4:	ba6080e7          	jalr	-1114(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029e8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029ec:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029f0:	00006517          	auipc	a0,0x6
    800029f4:	9f850513          	addi	a0,a0,-1544 # 800083e8 <states.0+0x120>
    800029f8:	ffffe097          	auipc	ra,0xffffe
    800029fc:	b8e080e7          	jalr	-1138(ra) # 80000586 <printf>
    panic("kerneltrap");
    80002a00:	00006517          	auipc	a0,0x6
    80002a04:	a0050513          	addi	a0,a0,-1536 # 80008400 <states.0+0x138>
    80002a08:	ffffe097          	auipc	ra,0xffffe
    80002a0c:	b34080e7          	jalr	-1228(ra) # 8000053c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a10:	fffff097          	auipc	ra,0xfffff
    80002a14:	f96080e7          	jalr	-106(ra) # 800019a6 <myproc>
    80002a18:	d541                	beqz	a0,800029a0 <kerneltrap+0x38>
    80002a1a:	fffff097          	auipc	ra,0xfffff
    80002a1e:	f8c080e7          	jalr	-116(ra) # 800019a6 <myproc>
    80002a22:	4d18                	lw	a4,24(a0)
    80002a24:	4791                	li	a5,4
    80002a26:	f6f71de3          	bne	a4,a5,800029a0 <kerneltrap+0x38>
    yield();
    80002a2a:	fffff097          	auipc	ra,0xfffff
    80002a2e:	608080e7          	jalr	1544(ra) # 80002032 <yield>
    80002a32:	b7bd                	j	800029a0 <kerneltrap+0x38>

0000000080002a34 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a34:	1101                	addi	sp,sp,-32
    80002a36:	ec06                	sd	ra,24(sp)
    80002a38:	e822                	sd	s0,16(sp)
    80002a3a:	e426                	sd	s1,8(sp)
    80002a3c:	1000                	addi	s0,sp,32
    80002a3e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a40:	fffff097          	auipc	ra,0xfffff
    80002a44:	f66080e7          	jalr	-154(ra) # 800019a6 <myproc>
  switch (n) {
    80002a48:	4795                	li	a5,5
    80002a4a:	0497e163          	bltu	a5,s1,80002a8c <argraw+0x58>
    80002a4e:	048a                	slli	s1,s1,0x2
    80002a50:	00006717          	auipc	a4,0x6
    80002a54:	ae870713          	addi	a4,a4,-1304 # 80008538 <states.0+0x270>
    80002a58:	94ba                	add	s1,s1,a4
    80002a5a:	409c                	lw	a5,0(s1)
    80002a5c:	97ba                	add	a5,a5,a4
    80002a5e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a60:	6d3c                	ld	a5,88(a0)
    80002a62:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a64:	60e2                	ld	ra,24(sp)
    80002a66:	6442                	ld	s0,16(sp)
    80002a68:	64a2                	ld	s1,8(sp)
    80002a6a:	6105                	addi	sp,sp,32
    80002a6c:	8082                	ret
    return p->trapframe->a1;
    80002a6e:	6d3c                	ld	a5,88(a0)
    80002a70:	7fa8                	ld	a0,120(a5)
    80002a72:	bfcd                	j	80002a64 <argraw+0x30>
    return p->trapframe->a2;
    80002a74:	6d3c                	ld	a5,88(a0)
    80002a76:	63c8                	ld	a0,128(a5)
    80002a78:	b7f5                	j	80002a64 <argraw+0x30>
    return p->trapframe->a3;
    80002a7a:	6d3c                	ld	a5,88(a0)
    80002a7c:	67c8                	ld	a0,136(a5)
    80002a7e:	b7dd                	j	80002a64 <argraw+0x30>
    return p->trapframe->a4;
    80002a80:	6d3c                	ld	a5,88(a0)
    80002a82:	6bc8                	ld	a0,144(a5)
    80002a84:	b7c5                	j	80002a64 <argraw+0x30>
    return p->trapframe->a5;
    80002a86:	6d3c                	ld	a5,88(a0)
    80002a88:	6fc8                	ld	a0,152(a5)
    80002a8a:	bfe9                	j	80002a64 <argraw+0x30>
  panic("argraw");
    80002a8c:	00006517          	auipc	a0,0x6
    80002a90:	98450513          	addi	a0,a0,-1660 # 80008410 <states.0+0x148>
    80002a94:	ffffe097          	auipc	ra,0xffffe
    80002a98:	aa8080e7          	jalr	-1368(ra) # 8000053c <panic>

0000000080002a9c <fetchaddr>:
{
    80002a9c:	1101                	addi	sp,sp,-32
    80002a9e:	ec06                	sd	ra,24(sp)
    80002aa0:	e822                	sd	s0,16(sp)
    80002aa2:	e426                	sd	s1,8(sp)
    80002aa4:	e04a                	sd	s2,0(sp)
    80002aa6:	1000                	addi	s0,sp,32
    80002aa8:	84aa                	mv	s1,a0
    80002aaa:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002aac:	fffff097          	auipc	ra,0xfffff
    80002ab0:	efa080e7          	jalr	-262(ra) # 800019a6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002ab4:	653c                	ld	a5,72(a0)
    80002ab6:	02f4f863          	bgeu	s1,a5,80002ae6 <fetchaddr+0x4a>
    80002aba:	00848713          	addi	a4,s1,8
    80002abe:	02e7e663          	bltu	a5,a4,80002aea <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002ac2:	46a1                	li	a3,8
    80002ac4:	8626                	mv	a2,s1
    80002ac6:	85ca                	mv	a1,s2
    80002ac8:	6928                	ld	a0,80(a0)
    80002aca:	fffff097          	auipc	ra,0xfffff
    80002ace:	c28080e7          	jalr	-984(ra) # 800016f2 <copyin>
    80002ad2:	00a03533          	snez	a0,a0
    80002ad6:	40a00533          	neg	a0,a0
}
    80002ada:	60e2                	ld	ra,24(sp)
    80002adc:	6442                	ld	s0,16(sp)
    80002ade:	64a2                	ld	s1,8(sp)
    80002ae0:	6902                	ld	s2,0(sp)
    80002ae2:	6105                	addi	sp,sp,32
    80002ae4:	8082                	ret
    return -1;
    80002ae6:	557d                	li	a0,-1
    80002ae8:	bfcd                	j	80002ada <fetchaddr+0x3e>
    80002aea:	557d                	li	a0,-1
    80002aec:	b7fd                	j	80002ada <fetchaddr+0x3e>

0000000080002aee <fetchstr>:
{
    80002aee:	7179                	addi	sp,sp,-48
    80002af0:	f406                	sd	ra,40(sp)
    80002af2:	f022                	sd	s0,32(sp)
    80002af4:	ec26                	sd	s1,24(sp)
    80002af6:	e84a                	sd	s2,16(sp)
    80002af8:	e44e                	sd	s3,8(sp)
    80002afa:	1800                	addi	s0,sp,48
    80002afc:	892a                	mv	s2,a0
    80002afe:	84ae                	mv	s1,a1
    80002b00:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b02:	fffff097          	auipc	ra,0xfffff
    80002b06:	ea4080e7          	jalr	-348(ra) # 800019a6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002b0a:	86ce                	mv	a3,s3
    80002b0c:	864a                	mv	a2,s2
    80002b0e:	85a6                	mv	a1,s1
    80002b10:	6928                	ld	a0,80(a0)
    80002b12:	fffff097          	auipc	ra,0xfffff
    80002b16:	c6e080e7          	jalr	-914(ra) # 80001780 <copyinstr>
    80002b1a:	00054e63          	bltz	a0,80002b36 <fetchstr+0x48>
  return strlen(buf);
    80002b1e:	8526                	mv	a0,s1
    80002b20:	ffffe097          	auipc	ra,0xffffe
    80002b24:	328080e7          	jalr	808(ra) # 80000e48 <strlen>
}
    80002b28:	70a2                	ld	ra,40(sp)
    80002b2a:	7402                	ld	s0,32(sp)
    80002b2c:	64e2                	ld	s1,24(sp)
    80002b2e:	6942                	ld	s2,16(sp)
    80002b30:	69a2                	ld	s3,8(sp)
    80002b32:	6145                	addi	sp,sp,48
    80002b34:	8082                	ret
    return -1;
    80002b36:	557d                	li	a0,-1
    80002b38:	bfc5                	j	80002b28 <fetchstr+0x3a>

0000000080002b3a <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002b3a:	1101                	addi	sp,sp,-32
    80002b3c:	ec06                	sd	ra,24(sp)
    80002b3e:	e822                	sd	s0,16(sp)
    80002b40:	e426                	sd	s1,8(sp)
    80002b42:	1000                	addi	s0,sp,32
    80002b44:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b46:	00000097          	auipc	ra,0x0
    80002b4a:	eee080e7          	jalr	-274(ra) # 80002a34 <argraw>
    80002b4e:	c088                	sw	a0,0(s1)
}
    80002b50:	60e2                	ld	ra,24(sp)
    80002b52:	6442                	ld	s0,16(sp)
    80002b54:	64a2                	ld	s1,8(sp)
    80002b56:	6105                	addi	sp,sp,32
    80002b58:	8082                	ret

0000000080002b5a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002b5a:	1101                	addi	sp,sp,-32
    80002b5c:	ec06                	sd	ra,24(sp)
    80002b5e:	e822                	sd	s0,16(sp)
    80002b60:	e426                	sd	s1,8(sp)
    80002b62:	1000                	addi	s0,sp,32
    80002b64:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b66:	00000097          	auipc	ra,0x0
    80002b6a:	ece080e7          	jalr	-306(ra) # 80002a34 <argraw>
    80002b6e:	e088                	sd	a0,0(s1)
}
    80002b70:	60e2                	ld	ra,24(sp)
    80002b72:	6442                	ld	s0,16(sp)
    80002b74:	64a2                	ld	s1,8(sp)
    80002b76:	6105                	addi	sp,sp,32
    80002b78:	8082                	ret

0000000080002b7a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b7a:	7179                	addi	sp,sp,-48
    80002b7c:	f406                	sd	ra,40(sp)
    80002b7e:	f022                	sd	s0,32(sp)
    80002b80:	ec26                	sd	s1,24(sp)
    80002b82:	e84a                	sd	s2,16(sp)
    80002b84:	1800                	addi	s0,sp,48
    80002b86:	84ae                	mv	s1,a1
    80002b88:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002b8a:	fd840593          	addi	a1,s0,-40
    80002b8e:	00000097          	auipc	ra,0x0
    80002b92:	fcc080e7          	jalr	-52(ra) # 80002b5a <argaddr>
  return fetchstr(addr, buf, max);
    80002b96:	864a                	mv	a2,s2
    80002b98:	85a6                	mv	a1,s1
    80002b9a:	fd843503          	ld	a0,-40(s0)
    80002b9e:	00000097          	auipc	ra,0x0
    80002ba2:	f50080e7          	jalr	-176(ra) # 80002aee <fetchstr>
}
    80002ba6:	70a2                	ld	ra,40(sp)
    80002ba8:	7402                	ld	s0,32(sp)
    80002baa:	64e2                	ld	s1,24(sp)
    80002bac:	6942                	ld	s2,16(sp)
    80002bae:	6145                	addi	sp,sp,48
    80002bb0:	8082                	ret

0000000080002bb2 <syscall>:
  [SYS_sigreturn]   0,
};

void
syscall(void)
{
    80002bb2:	7159                	addi	sp,sp,-112
    80002bb4:	f486                	sd	ra,104(sp)
    80002bb6:	f0a2                	sd	s0,96(sp)
    80002bb8:	eca6                	sd	s1,88(sp)
    80002bba:	e8ca                	sd	s2,80(sp)
    80002bbc:	e4ce                	sd	s3,72(sp)
    80002bbe:	e0d2                	sd	s4,64(sp)
    80002bc0:	fc56                	sd	s5,56(sp)
    80002bc2:	f85a                	sd	s6,48(sp)
    80002bc4:	f45e                	sd	s7,40(sp)
    80002bc6:	1880                	addi	s0,sp,112
  int num;
  struct proc *p = myproc();
    80002bc8:	fffff097          	auipc	ra,0xfffff
    80002bcc:	dde080e7          	jalr	-546(ra) # 800019a6 <myproc>
    80002bd0:	89aa                	mv	s3,a0

  num = p->trapframe->a7;
    80002bd2:	6d24                	ld	s1,88(a0)
    80002bd4:	74dc                	ld	a5,168(s1)
    80002bd6:	00078b1b          	sext.w	s6,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002bda:	37fd                	addiw	a5,a5,-1
    80002bdc:	475d                	li	a4,23
    80002bde:	0cf76363          	bltu	a4,a5,80002ca4 <syscall+0xf2>
    80002be2:	003b1713          	slli	a4,s6,0x3
    80002be6:	00006797          	auipc	a5,0x6
    80002bea:	96a78793          	addi	a5,a5,-1686 # 80008550 <syscalls>
    80002bee:	97ba                	add	a5,a5,a4
    80002bf0:	0007bb83          	ld	s7,0(a5)
    80002bf4:	0a0b8863          	beqz	s7,80002ca4 <syscall+0xf2>
    // save arguments of syscall if it needs to be traced
    int nargs = syscall_nargs[num];
    80002bf8:	002b1713          	slli	a4,s6,0x2
    80002bfc:	00006797          	auipc	a5,0x6
    80002c00:	95478793          	addi	a5,a5,-1708 # 80008550 <syscalls>
    80002c04:	97ba                	add	a5,a5,a4
    80002c06:	0c87aa03          	lw	s4,200(a5)
    int args[6];
    for (int i = 0; i < nargs; i++) {
    80002c0a:	0d405963          	blez	s4,80002cdc <syscall+0x12a>
    80002c0e:	f9840a93          	addi	s5,s0,-104
    80002c12:	8956                	mv	s2,s5
    80002c14:	4481                	li	s1,0
      argint(i, &args[i]);
    80002c16:	85ca                	mv	a1,s2
    80002c18:	8526                	mv	a0,s1
    80002c1a:	00000097          	auipc	ra,0x0
    80002c1e:	f20080e7          	jalr	-224(ra) # 80002b3a <argint>
    for (int i = 0; i < nargs; i++) {
    80002c22:	2485                	addiw	s1,s1,1
    80002c24:	0911                	addi	s2,s2,4
    80002c26:	fe9a18e3          	bne	s4,s1,80002c16 <syscall+0x64>
    }

    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002c2a:	0589b483          	ld	s1,88(s3)
    80002c2e:	9b82                	jalr	s7
    80002c30:	f8a8                	sd	a0,112(s1)

    // if trace was called
    // Specification 1        
    int trace_call = p->smask & (1 << num);
    80002c32:	4705                	li	a4,1
    80002c34:	0167173b          	sllw	a4,a4,s6
    80002c38:	1689a783          	lw	a5,360(s3)
    80002c3c:	8ff9                	and	a5,a5,a4
    if (trace_call) { 
    80002c3e:	2781                	sext.w	a5,a5
    80002c40:	c3d9                	beqz	a5,80002cc6 <syscall+0x114>
      printf("%d: syscall %s (", p->pid, syscall_names[num]);
    80002c42:	0b0e                	slli	s6,s6,0x3
    80002c44:	00006797          	auipc	a5,0x6
    80002c48:	90c78793          	addi	a5,a5,-1780 # 80008550 <syscalls>
    80002c4c:	97da                	add	a5,a5,s6
    80002c4e:	1307b603          	ld	a2,304(a5)
    80002c52:	0309a583          	lw	a1,48(s3)
    80002c56:	00005517          	auipc	a0,0x5
    80002c5a:	7c250513          	addi	a0,a0,1986 # 80008418 <states.0+0x150>
    80002c5e:	ffffe097          	auipc	ra,0xffffe
    80002c62:	928080e7          	jalr	-1752(ra) # 80000586 <printf>
      for (int i = 0; i < nargs; i++) { 
    80002c66:	4481                	li	s1,0
        printf("%d", args[i]);
    80002c68:	00005b17          	auipc	s6,0x5
    80002c6c:	7c8b0b13          	addi	s6,s6,1992 # 80008430 <states.0+0x168>
        if (i != nargs - 1)
    80002c70:	fffa091b          	addiw	s2,s4,-1
          printf(" ");
    80002c74:	00005b97          	auipc	s7,0x5
    80002c78:	7c4b8b93          	addi	s7,s7,1988 # 80008438 <states.0+0x170>
    80002c7c:	a029                	j	80002c86 <syscall+0xd4>
      for (int i = 0; i < nargs; i++) { 
    80002c7e:	2485                	addiw	s1,s1,1
    80002c80:	0a91                	addi	s5,s5,4
    80002c82:	089a0963          	beq	s4,s1,80002d14 <syscall+0x162>
        printf("%d", args[i]);
    80002c86:	000aa583          	lw	a1,0(s5)
    80002c8a:	855a                	mv	a0,s6
    80002c8c:	ffffe097          	auipc	ra,0xffffe
    80002c90:	8fa080e7          	jalr	-1798(ra) # 80000586 <printf>
        if (i != nargs - 1)
    80002c94:	fe9905e3          	beq	s2,s1,80002c7e <syscall+0xcc>
          printf(" ");
    80002c98:	855e                	mv	a0,s7
    80002c9a:	ffffe097          	auipc	ra,0xffffe
    80002c9e:	8ec080e7          	jalr	-1812(ra) # 80000586 <printf>
    80002ca2:	bff1                	j	80002c7e <syscall+0xcc>
    // if traced, print return value
    if (trace_call) {
      printf("-> %d\n", p->trapframe->a0);
    }
  } else {         
    printf("%d %s: unknown sys call %d\n",
    80002ca4:	86da                	mv	a3,s6
    80002ca6:	15898613          	addi	a2,s3,344
    80002caa:	0309a583          	lw	a1,48(s3)
    80002cae:	00005517          	auipc	a0,0x5
    80002cb2:	7a250513          	addi	a0,a0,1954 # 80008450 <states.0+0x188>
    80002cb6:	ffffe097          	auipc	ra,0xffffe
    80002cba:	8d0080e7          	jalr	-1840(ra) # 80000586 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002cbe:	0589b783          	ld	a5,88(s3)
    80002cc2:	577d                	li	a4,-1
    80002cc4:	fbb8                	sd	a4,112(a5)
  }
}
    80002cc6:	70a6                	ld	ra,104(sp)
    80002cc8:	7406                	ld	s0,96(sp)
    80002cca:	64e6                	ld	s1,88(sp)
    80002ccc:	6946                	ld	s2,80(sp)
    80002cce:	69a6                	ld	s3,72(sp)
    80002cd0:	6a06                	ld	s4,64(sp)
    80002cd2:	7ae2                	ld	s5,56(sp)
    80002cd4:	7b42                	ld	s6,48(sp)
    80002cd6:	7ba2                	ld	s7,40(sp)
    80002cd8:	6165                	addi	sp,sp,112
    80002cda:	8082                	ret
    p->trapframe->a0 = syscalls[num]();
    80002cdc:	9b82                	jalr	s7
    80002cde:	f8a8                	sd	a0,112(s1)
    int trace_call = p->smask & (1 << num);
    80002ce0:	4705                	li	a4,1
    80002ce2:	0167173b          	sllw	a4,a4,s6
    80002ce6:	1689a783          	lw	a5,360(s3)
    80002cea:	8ff9                	and	a5,a5,a4
    if (trace_call) { 
    80002cec:	2781                	sext.w	a5,a5
    80002cee:	dfe1                	beqz	a5,80002cc6 <syscall+0x114>
      printf("%d: syscall %s (", p->pid, syscall_names[num]);
    80002cf0:	0b0e                	slli	s6,s6,0x3
    80002cf2:	00006797          	auipc	a5,0x6
    80002cf6:	85e78793          	addi	a5,a5,-1954 # 80008550 <syscalls>
    80002cfa:	97da                	add	a5,a5,s6
    80002cfc:	1307b603          	ld	a2,304(a5)
    80002d00:	0309a583          	lw	a1,48(s3)
    80002d04:	00005517          	auipc	a0,0x5
    80002d08:	71450513          	addi	a0,a0,1812 # 80008418 <states.0+0x150>
    80002d0c:	ffffe097          	auipc	ra,0xffffe
    80002d10:	87a080e7          	jalr	-1926(ra) # 80000586 <printf>
      printf(") ");
    80002d14:	00005517          	auipc	a0,0x5
    80002d18:	72c50513          	addi	a0,a0,1836 # 80008440 <states.0+0x178>
    80002d1c:	ffffe097          	auipc	ra,0xffffe
    80002d20:	86a080e7          	jalr	-1942(ra) # 80000586 <printf>
      printf("-> %d\n", p->trapframe->a0);
    80002d24:	0589b783          	ld	a5,88(s3)
    80002d28:	7bac                	ld	a1,112(a5)
    80002d2a:	00005517          	auipc	a0,0x5
    80002d2e:	71e50513          	addi	a0,a0,1822 # 80008448 <states.0+0x180>
    80002d32:	ffffe097          	auipc	ra,0xffffe
    80002d36:	854080e7          	jalr	-1964(ra) # 80000586 <printf>
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002d3a:	b771                	j	80002cc6 <syscall+0x114>

0000000080002d3c <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002d3c:	1101                	addi	sp,sp,-32
    80002d3e:	ec06                	sd	ra,24(sp)
    80002d40:	e822                	sd	s0,16(sp)
    80002d42:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002d44:	fec40593          	addi	a1,s0,-20
    80002d48:	4501                	li	a0,0
    80002d4a:	00000097          	auipc	ra,0x0
    80002d4e:	df0080e7          	jalr	-528(ra) # 80002b3a <argint>
  exit(n);
    80002d52:	fec42503          	lw	a0,-20(s0)
    80002d56:	fffff097          	auipc	ra,0xfffff
    80002d5a:	44c080e7          	jalr	1100(ra) # 800021a2 <exit>
  return 0;  // not reached
}
    80002d5e:	4501                	li	a0,0
    80002d60:	60e2                	ld	ra,24(sp)
    80002d62:	6442                	ld	s0,16(sp)
    80002d64:	6105                	addi	sp,sp,32
    80002d66:	8082                	ret

0000000080002d68 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002d68:	1141                	addi	sp,sp,-16
    80002d6a:	e406                	sd	ra,8(sp)
    80002d6c:	e022                	sd	s0,0(sp)
    80002d6e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002d70:	fffff097          	auipc	ra,0xfffff
    80002d74:	c36080e7          	jalr	-970(ra) # 800019a6 <myproc>
}
    80002d78:	5908                	lw	a0,48(a0)
    80002d7a:	60a2                	ld	ra,8(sp)
    80002d7c:	6402                	ld	s0,0(sp)
    80002d7e:	0141                	addi	sp,sp,16
    80002d80:	8082                	ret

0000000080002d82 <sys_fork>:

uint64
sys_fork(void)
{
    80002d82:	1141                	addi	sp,sp,-16
    80002d84:	e406                	sd	ra,8(sp)
    80002d86:	e022                	sd	s0,0(sp)
    80002d88:	0800                	addi	s0,sp,16
  return fork();
    80002d8a:	fffff097          	auipc	ra,0xfffff
    80002d8e:	fea080e7          	jalr	-22(ra) # 80001d74 <fork>
}
    80002d92:	60a2                	ld	ra,8(sp)
    80002d94:	6402                	ld	s0,0(sp)
    80002d96:	0141                	addi	sp,sp,16
    80002d98:	8082                	ret

0000000080002d9a <sys_wait>:

uint64
sys_wait(void)
{
    80002d9a:	1101                	addi	sp,sp,-32
    80002d9c:	ec06                	sd	ra,24(sp)
    80002d9e:	e822                	sd	s0,16(sp)
    80002da0:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002da2:	fe840593          	addi	a1,s0,-24
    80002da6:	4501                	li	a0,0
    80002da8:	00000097          	auipc	ra,0x0
    80002dac:	db2080e7          	jalr	-590(ra) # 80002b5a <argaddr>
  return wait(p);
    80002db0:	fe843503          	ld	a0,-24(s0)
    80002db4:	fffff097          	auipc	ra,0xfffff
    80002db8:	594080e7          	jalr	1428(ra) # 80002348 <wait>
}
    80002dbc:	60e2                	ld	ra,24(sp)
    80002dbe:	6442                	ld	s0,16(sp)
    80002dc0:	6105                	addi	sp,sp,32
    80002dc2:	8082                	ret

0000000080002dc4 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002dc4:	7179                	addi	sp,sp,-48
    80002dc6:	f406                	sd	ra,40(sp)
    80002dc8:	f022                	sd	s0,32(sp)
    80002dca:	ec26                	sd	s1,24(sp)
    80002dcc:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002dce:	fdc40593          	addi	a1,s0,-36
    80002dd2:	4501                	li	a0,0
    80002dd4:	00000097          	auipc	ra,0x0
    80002dd8:	d66080e7          	jalr	-666(ra) # 80002b3a <argint>
  addr = myproc()->sz;
    80002ddc:	fffff097          	auipc	ra,0xfffff
    80002de0:	bca080e7          	jalr	-1078(ra) # 800019a6 <myproc>
    80002de4:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002de6:	fdc42503          	lw	a0,-36(s0)
    80002dea:	fffff097          	auipc	ra,0xfffff
    80002dee:	f2e080e7          	jalr	-210(ra) # 80001d18 <growproc>
    80002df2:	00054863          	bltz	a0,80002e02 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002df6:	8526                	mv	a0,s1
    80002df8:	70a2                	ld	ra,40(sp)
    80002dfa:	7402                	ld	s0,32(sp)
    80002dfc:	64e2                	ld	s1,24(sp)
    80002dfe:	6145                	addi	sp,sp,48
    80002e00:	8082                	ret
    return -1;
    80002e02:	54fd                	li	s1,-1
    80002e04:	bfcd                	j	80002df6 <sys_sbrk+0x32>

0000000080002e06 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002e06:	7139                	addi	sp,sp,-64
    80002e08:	fc06                	sd	ra,56(sp)
    80002e0a:	f822                	sd	s0,48(sp)
    80002e0c:	f426                	sd	s1,40(sp)
    80002e0e:	f04a                	sd	s2,32(sp)
    80002e10:	ec4e                	sd	s3,24(sp)
    80002e12:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002e14:	fcc40593          	addi	a1,s0,-52
    80002e18:	4501                	li	a0,0
    80002e1a:	00000097          	auipc	ra,0x0
    80002e1e:	d20080e7          	jalr	-736(ra) # 80002b3a <argint>
  acquire(&tickslock);
    80002e22:	00014517          	auipc	a0,0x14
    80002e26:	57e50513          	addi	a0,a0,1406 # 800173a0 <tickslock>
    80002e2a:	ffffe097          	auipc	ra,0xffffe
    80002e2e:	da8080e7          	jalr	-600(ra) # 80000bd2 <acquire>
  ticks0 = ticks;
    80002e32:	00006917          	auipc	s2,0x6
    80002e36:	cce92903          	lw	s2,-818(s2) # 80008b00 <ticks>
  while(ticks - ticks0 < n){
    80002e3a:	fcc42783          	lw	a5,-52(s0)
    80002e3e:	cf9d                	beqz	a5,80002e7c <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002e40:	00014997          	auipc	s3,0x14
    80002e44:	56098993          	addi	s3,s3,1376 # 800173a0 <tickslock>
    80002e48:	00006497          	auipc	s1,0x6
    80002e4c:	cb848493          	addi	s1,s1,-840 # 80008b00 <ticks>
    if(killed(myproc())){
    80002e50:	fffff097          	auipc	ra,0xfffff
    80002e54:	b56080e7          	jalr	-1194(ra) # 800019a6 <myproc>
    80002e58:	fffff097          	auipc	ra,0xfffff
    80002e5c:	4be080e7          	jalr	1214(ra) # 80002316 <killed>
    80002e60:	ed15                	bnez	a0,80002e9c <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002e62:	85ce                	mv	a1,s3
    80002e64:	8526                	mv	a0,s1
    80002e66:	fffff097          	auipc	ra,0xfffff
    80002e6a:	208080e7          	jalr	520(ra) # 8000206e <sleep>
  while(ticks - ticks0 < n){
    80002e6e:	409c                	lw	a5,0(s1)
    80002e70:	412787bb          	subw	a5,a5,s2
    80002e74:	fcc42703          	lw	a4,-52(s0)
    80002e78:	fce7ece3          	bltu	a5,a4,80002e50 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002e7c:	00014517          	auipc	a0,0x14
    80002e80:	52450513          	addi	a0,a0,1316 # 800173a0 <tickslock>
    80002e84:	ffffe097          	auipc	ra,0xffffe
    80002e88:	e02080e7          	jalr	-510(ra) # 80000c86 <release>
  return 0;
    80002e8c:	4501                	li	a0,0
}
    80002e8e:	70e2                	ld	ra,56(sp)
    80002e90:	7442                	ld	s0,48(sp)
    80002e92:	74a2                	ld	s1,40(sp)
    80002e94:	7902                	ld	s2,32(sp)
    80002e96:	69e2                	ld	s3,24(sp)
    80002e98:	6121                	addi	sp,sp,64
    80002e9a:	8082                	ret
      release(&tickslock);
    80002e9c:	00014517          	auipc	a0,0x14
    80002ea0:	50450513          	addi	a0,a0,1284 # 800173a0 <tickslock>
    80002ea4:	ffffe097          	auipc	ra,0xffffe
    80002ea8:	de2080e7          	jalr	-542(ra) # 80000c86 <release>
      return -1;
    80002eac:	557d                	li	a0,-1
    80002eae:	b7c5                	j	80002e8e <sys_sleep+0x88>

0000000080002eb0 <sys_kill>:

uint64
sys_kill(void)
{
    80002eb0:	1101                	addi	sp,sp,-32
    80002eb2:	ec06                	sd	ra,24(sp)
    80002eb4:	e822                	sd	s0,16(sp)
    80002eb6:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002eb8:	fec40593          	addi	a1,s0,-20
    80002ebc:	4501                	li	a0,0
    80002ebe:	00000097          	auipc	ra,0x0
    80002ec2:	c7c080e7          	jalr	-900(ra) # 80002b3a <argint>
  return kill(pid);
    80002ec6:	fec42503          	lw	a0,-20(s0)
    80002eca:	fffff097          	auipc	ra,0xfffff
    80002ece:	3ae080e7          	jalr	942(ra) # 80002278 <kill>
}
    80002ed2:	60e2                	ld	ra,24(sp)
    80002ed4:	6442                	ld	s0,16(sp)
    80002ed6:	6105                	addi	sp,sp,32
    80002ed8:	8082                	ret

0000000080002eda <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002eda:	1101                	addi	sp,sp,-32
    80002edc:	ec06                	sd	ra,24(sp)
    80002ede:	e822                	sd	s0,16(sp)
    80002ee0:	e426                	sd	s1,8(sp)
    80002ee2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ee4:	00014517          	auipc	a0,0x14
    80002ee8:	4bc50513          	addi	a0,a0,1212 # 800173a0 <tickslock>
    80002eec:	ffffe097          	auipc	ra,0xffffe
    80002ef0:	ce6080e7          	jalr	-794(ra) # 80000bd2 <acquire>
  xticks = ticks;
    80002ef4:	00006497          	auipc	s1,0x6
    80002ef8:	c0c4a483          	lw	s1,-1012(s1) # 80008b00 <ticks>
  release(&tickslock);
    80002efc:	00014517          	auipc	a0,0x14
    80002f00:	4a450513          	addi	a0,a0,1188 # 800173a0 <tickslock>
    80002f04:	ffffe097          	auipc	ra,0xffffe
    80002f08:	d82080e7          	jalr	-638(ra) # 80000c86 <release>
  return xticks;
}
    80002f0c:	02049513          	slli	a0,s1,0x20
    80002f10:	9101                	srli	a0,a0,0x20
    80002f12:	60e2                	ld	ra,24(sp)
    80002f14:	6442                	ld	s0,16(sp)
    80002f16:	64a2                	ld	s1,8(sp)
    80002f18:	6105                	addi	sp,sp,32
    80002f1a:	8082                	ret

0000000080002f1c <sys_trace>:

// Specification 1

uint64
sys_trace(void) {
    80002f1c:	1101                	addi	sp,sp,-32
    80002f1e:	ec06                	sd	ra,24(sp)
    80002f20:	e822                	sd	s0,16(sp)
    80002f22:	1000                	addi	s0,sp,32
  int mask;
  struct proc *p;

  argint(0, &mask);
    80002f24:	fec40593          	addi	a1,s0,-20
    80002f28:	4501                	li	a0,0
    80002f2a:	00000097          	auipc	ra,0x0
    80002f2e:	c10080e7          	jalr	-1008(ra) # 80002b3a <argint>
  p = myproc();
    80002f32:	fffff097          	auipc	ra,0xfffff
    80002f36:	a74080e7          	jalr	-1420(ra) # 800019a6 <myproc>

  p->smask = mask;
    80002f3a:	fec42783          	lw	a5,-20(s0)
    80002f3e:	16f52423          	sw	a5,360(a0)
  return 0;
}
    80002f42:	4501                	li	a0,0
    80002f44:	60e2                	ld	ra,24(sp)
    80002f46:	6442                	ld	s0,16(sp)
    80002f48:	6105                	addi	sp,sp,32
    80002f4a:	8082                	ret

0000000080002f4c <sys_sigalarm>:

uint64 sys_sigalarm(void){
    80002f4c:	7179                	addi	sp,sp,-48
    80002f4e:	f406                	sd	ra,40(sp)
    80002f50:	f022                	sd	s0,32(sp)
    80002f52:	ec26                	sd	s1,24(sp)
    80002f54:	1800                	addi	s0,sp,48
  struct proc * p;
  p =myproc();
    80002f56:	fffff097          	auipc	ra,0xfffff
    80002f5a:	a50080e7          	jalr	-1456(ra) # 800019a6 <myproc>
    80002f5e:	84aa                	mv	s1,a0

  int interval;
  uint64 handler;

  argint(0,&interval);
    80002f60:	fdc40593          	addi	a1,s0,-36
    80002f64:	4501                	li	a0,0
    80002f66:	00000097          	auipc	ra,0x0
    80002f6a:	bd4080e7          	jalr	-1068(ra) # 80002b3a <argint>
  argaddr(1,&handler);
    80002f6e:	fd040593          	addi	a1,s0,-48
    80002f72:	4505                	li	a0,1
    80002f74:	00000097          	auipc	ra,0x0
    80002f78:	be6080e7          	jalr	-1050(ra) # 80002b5a <argaddr>

  p->interval = interval;
    80002f7c:	fdc42783          	lw	a5,-36(s0)
    80002f80:	16f4a623          	sw	a5,364(s1)
  p->handler = handler;
    80002f84:	fd043783          	ld	a5,-48(s0)
    80002f88:	16f4b823          	sd	a5,368(s1)

  return 0;
  
}
    80002f8c:	4501                	li	a0,0
    80002f8e:	70a2                	ld	ra,40(sp)
    80002f90:	7402                	ld	s0,32(sp)
    80002f92:	64e2                	ld	s1,24(sp)
    80002f94:	6145                	addi	sp,sp,48
    80002f96:	8082                	ret

0000000080002f98 <sys_sigreturn>:

uint64 sys_sigreturn(void){
    80002f98:	1101                	addi	sp,sp,-32
    80002f9a:	ec06                	sd	ra,24(sp)
    80002f9c:	e822                	sd	s0,16(sp)
    80002f9e:	e426                	sd	s1,8(sp)
    80002fa0:	e04a                	sd	s2,0(sp)
    80002fa2:	1000                	addi	s0,sp,32

  struct proc * p;
  p =myproc();
    80002fa4:	fffff097          	auipc	ra,0xfffff
    80002fa8:	a02080e7          	jalr	-1534(ra) # 800019a6 <myproc>
    80002fac:	84aa                	mv	s1,a0

  memmove(p->trapframe,p->alarmContext,PGSIZE);
    80002fae:	6605                	lui	a2,0x1
    80002fb0:	18053583          	ld	a1,384(a0)
    80002fb4:	6d28                	ld	a0,88(a0)
    80002fb6:	ffffe097          	auipc	ra,0xffffe
    80002fba:	d74080e7          	jalr	-652(ra) # 80000d2a <memmove>
  int a0 = p->alarmContext->a0;
    80002fbe:	1804b503          	ld	a0,384(s1)
    80002fc2:	07052903          	lw	s2,112(a0)
  kfree(p->alarmContext);
    80002fc6:	ffffe097          	auipc	ra,0xffffe
    80002fca:	a1e080e7          	jalr	-1506(ra) # 800009e4 <kfree>
  p->alarmOn=0;
    80002fce:	1604ae23          	sw	zero,380(s1)
  p->nticks=0;
    80002fd2:	1604ac23          	sw	zero,376(s1)
  p->alarmContext=0;
    80002fd6:	1804b023          	sd	zero,384(s1)
  // this is done to restore the original value of the a0 register
  // as sys_sigreturn is also a systemcall its return value will be stored in the a0 register
  return a0;
    80002fda:	854a                	mv	a0,s2
    80002fdc:	60e2                	ld	ra,24(sp)
    80002fde:	6442                	ld	s0,16(sp)
    80002fe0:	64a2                	ld	s1,8(sp)
    80002fe2:	6902                	ld	s2,0(sp)
    80002fe4:	6105                	addi	sp,sp,32
    80002fe6:	8082                	ret

0000000080002fe8 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002fe8:	7179                	addi	sp,sp,-48
    80002fea:	f406                	sd	ra,40(sp)
    80002fec:	f022                	sd	s0,32(sp)
    80002fee:	ec26                	sd	s1,24(sp)
    80002ff0:	e84a                	sd	s2,16(sp)
    80002ff2:	e44e                	sd	s3,8(sp)
    80002ff4:	e052                	sd	s4,0(sp)
    80002ff6:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002ff8:	00005597          	auipc	a1,0x5
    80002ffc:	75058593          	addi	a1,a1,1872 # 80008748 <syscall_names+0xc8>
    80003000:	00014517          	auipc	a0,0x14
    80003004:	3b850513          	addi	a0,a0,952 # 800173b8 <bcache>
    80003008:	ffffe097          	auipc	ra,0xffffe
    8000300c:	b3a080e7          	jalr	-1222(ra) # 80000b42 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003010:	0001c797          	auipc	a5,0x1c
    80003014:	3a878793          	addi	a5,a5,936 # 8001f3b8 <bcache+0x8000>
    80003018:	0001c717          	auipc	a4,0x1c
    8000301c:	60870713          	addi	a4,a4,1544 # 8001f620 <bcache+0x8268>
    80003020:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003024:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003028:	00014497          	auipc	s1,0x14
    8000302c:	3a848493          	addi	s1,s1,936 # 800173d0 <bcache+0x18>
    b->next = bcache.head.next;
    80003030:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003032:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003034:	00005a17          	auipc	s4,0x5
    80003038:	71ca0a13          	addi	s4,s4,1820 # 80008750 <syscall_names+0xd0>
    b->next = bcache.head.next;
    8000303c:	2b893783          	ld	a5,696(s2)
    80003040:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003042:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003046:	85d2                	mv	a1,s4
    80003048:	01048513          	addi	a0,s1,16
    8000304c:	00001097          	auipc	ra,0x1
    80003050:	496080e7          	jalr	1174(ra) # 800044e2 <initsleeplock>
    bcache.head.next->prev = b;
    80003054:	2b893783          	ld	a5,696(s2)
    80003058:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000305a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000305e:	45848493          	addi	s1,s1,1112
    80003062:	fd349de3          	bne	s1,s3,8000303c <binit+0x54>
  }
}
    80003066:	70a2                	ld	ra,40(sp)
    80003068:	7402                	ld	s0,32(sp)
    8000306a:	64e2                	ld	s1,24(sp)
    8000306c:	6942                	ld	s2,16(sp)
    8000306e:	69a2                	ld	s3,8(sp)
    80003070:	6a02                	ld	s4,0(sp)
    80003072:	6145                	addi	sp,sp,48
    80003074:	8082                	ret

0000000080003076 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003076:	7179                	addi	sp,sp,-48
    80003078:	f406                	sd	ra,40(sp)
    8000307a:	f022                	sd	s0,32(sp)
    8000307c:	ec26                	sd	s1,24(sp)
    8000307e:	e84a                	sd	s2,16(sp)
    80003080:	e44e                	sd	s3,8(sp)
    80003082:	1800                	addi	s0,sp,48
    80003084:	892a                	mv	s2,a0
    80003086:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003088:	00014517          	auipc	a0,0x14
    8000308c:	33050513          	addi	a0,a0,816 # 800173b8 <bcache>
    80003090:	ffffe097          	auipc	ra,0xffffe
    80003094:	b42080e7          	jalr	-1214(ra) # 80000bd2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003098:	0001c497          	auipc	s1,0x1c
    8000309c:	5d84b483          	ld	s1,1496(s1) # 8001f670 <bcache+0x82b8>
    800030a0:	0001c797          	auipc	a5,0x1c
    800030a4:	58078793          	addi	a5,a5,1408 # 8001f620 <bcache+0x8268>
    800030a8:	02f48f63          	beq	s1,a5,800030e6 <bread+0x70>
    800030ac:	873e                	mv	a4,a5
    800030ae:	a021                	j	800030b6 <bread+0x40>
    800030b0:	68a4                	ld	s1,80(s1)
    800030b2:	02e48a63          	beq	s1,a4,800030e6 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800030b6:	449c                	lw	a5,8(s1)
    800030b8:	ff279ce3          	bne	a5,s2,800030b0 <bread+0x3a>
    800030bc:	44dc                	lw	a5,12(s1)
    800030be:	ff3799e3          	bne	a5,s3,800030b0 <bread+0x3a>
      b->refcnt++;
    800030c2:	40bc                	lw	a5,64(s1)
    800030c4:	2785                	addiw	a5,a5,1
    800030c6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030c8:	00014517          	auipc	a0,0x14
    800030cc:	2f050513          	addi	a0,a0,752 # 800173b8 <bcache>
    800030d0:	ffffe097          	auipc	ra,0xffffe
    800030d4:	bb6080e7          	jalr	-1098(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    800030d8:	01048513          	addi	a0,s1,16
    800030dc:	00001097          	auipc	ra,0x1
    800030e0:	440080e7          	jalr	1088(ra) # 8000451c <acquiresleep>
      return b;
    800030e4:	a8b9                	j	80003142 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030e6:	0001c497          	auipc	s1,0x1c
    800030ea:	5824b483          	ld	s1,1410(s1) # 8001f668 <bcache+0x82b0>
    800030ee:	0001c797          	auipc	a5,0x1c
    800030f2:	53278793          	addi	a5,a5,1330 # 8001f620 <bcache+0x8268>
    800030f6:	00f48863          	beq	s1,a5,80003106 <bread+0x90>
    800030fa:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800030fc:	40bc                	lw	a5,64(s1)
    800030fe:	cf81                	beqz	a5,80003116 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003100:	64a4                	ld	s1,72(s1)
    80003102:	fee49de3          	bne	s1,a4,800030fc <bread+0x86>
  panic("bget: no buffers");
    80003106:	00005517          	auipc	a0,0x5
    8000310a:	65250513          	addi	a0,a0,1618 # 80008758 <syscall_names+0xd8>
    8000310e:	ffffd097          	auipc	ra,0xffffd
    80003112:	42e080e7          	jalr	1070(ra) # 8000053c <panic>
      b->dev = dev;
    80003116:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000311a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000311e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003122:	4785                	li	a5,1
    80003124:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003126:	00014517          	auipc	a0,0x14
    8000312a:	29250513          	addi	a0,a0,658 # 800173b8 <bcache>
    8000312e:	ffffe097          	auipc	ra,0xffffe
    80003132:	b58080e7          	jalr	-1192(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    80003136:	01048513          	addi	a0,s1,16
    8000313a:	00001097          	auipc	ra,0x1
    8000313e:	3e2080e7          	jalr	994(ra) # 8000451c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003142:	409c                	lw	a5,0(s1)
    80003144:	cb89                	beqz	a5,80003156 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003146:	8526                	mv	a0,s1
    80003148:	70a2                	ld	ra,40(sp)
    8000314a:	7402                	ld	s0,32(sp)
    8000314c:	64e2                	ld	s1,24(sp)
    8000314e:	6942                	ld	s2,16(sp)
    80003150:	69a2                	ld	s3,8(sp)
    80003152:	6145                	addi	sp,sp,48
    80003154:	8082                	ret
    virtio_disk_rw(b, 0);
    80003156:	4581                	li	a1,0
    80003158:	8526                	mv	a0,s1
    8000315a:	00003097          	auipc	ra,0x3
    8000315e:	f78080e7          	jalr	-136(ra) # 800060d2 <virtio_disk_rw>
    b->valid = 1;
    80003162:	4785                	li	a5,1
    80003164:	c09c                	sw	a5,0(s1)
  return b;
    80003166:	b7c5                	j	80003146 <bread+0xd0>

0000000080003168 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003168:	1101                	addi	sp,sp,-32
    8000316a:	ec06                	sd	ra,24(sp)
    8000316c:	e822                	sd	s0,16(sp)
    8000316e:	e426                	sd	s1,8(sp)
    80003170:	1000                	addi	s0,sp,32
    80003172:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003174:	0541                	addi	a0,a0,16
    80003176:	00001097          	auipc	ra,0x1
    8000317a:	440080e7          	jalr	1088(ra) # 800045b6 <holdingsleep>
    8000317e:	cd01                	beqz	a0,80003196 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003180:	4585                	li	a1,1
    80003182:	8526                	mv	a0,s1
    80003184:	00003097          	auipc	ra,0x3
    80003188:	f4e080e7          	jalr	-178(ra) # 800060d2 <virtio_disk_rw>
}
    8000318c:	60e2                	ld	ra,24(sp)
    8000318e:	6442                	ld	s0,16(sp)
    80003190:	64a2                	ld	s1,8(sp)
    80003192:	6105                	addi	sp,sp,32
    80003194:	8082                	ret
    panic("bwrite");
    80003196:	00005517          	auipc	a0,0x5
    8000319a:	5da50513          	addi	a0,a0,1498 # 80008770 <syscall_names+0xf0>
    8000319e:	ffffd097          	auipc	ra,0xffffd
    800031a2:	39e080e7          	jalr	926(ra) # 8000053c <panic>

00000000800031a6 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800031a6:	1101                	addi	sp,sp,-32
    800031a8:	ec06                	sd	ra,24(sp)
    800031aa:	e822                	sd	s0,16(sp)
    800031ac:	e426                	sd	s1,8(sp)
    800031ae:	e04a                	sd	s2,0(sp)
    800031b0:	1000                	addi	s0,sp,32
    800031b2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031b4:	01050913          	addi	s2,a0,16
    800031b8:	854a                	mv	a0,s2
    800031ba:	00001097          	auipc	ra,0x1
    800031be:	3fc080e7          	jalr	1020(ra) # 800045b6 <holdingsleep>
    800031c2:	c925                	beqz	a0,80003232 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    800031c4:	854a                	mv	a0,s2
    800031c6:	00001097          	auipc	ra,0x1
    800031ca:	3ac080e7          	jalr	940(ra) # 80004572 <releasesleep>

  acquire(&bcache.lock);
    800031ce:	00014517          	auipc	a0,0x14
    800031d2:	1ea50513          	addi	a0,a0,490 # 800173b8 <bcache>
    800031d6:	ffffe097          	auipc	ra,0xffffe
    800031da:	9fc080e7          	jalr	-1540(ra) # 80000bd2 <acquire>
  b->refcnt--;
    800031de:	40bc                	lw	a5,64(s1)
    800031e0:	37fd                	addiw	a5,a5,-1
    800031e2:	0007871b          	sext.w	a4,a5
    800031e6:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800031e8:	e71d                	bnez	a4,80003216 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800031ea:	68b8                	ld	a4,80(s1)
    800031ec:	64bc                	ld	a5,72(s1)
    800031ee:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800031f0:	68b8                	ld	a4,80(s1)
    800031f2:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800031f4:	0001c797          	auipc	a5,0x1c
    800031f8:	1c478793          	addi	a5,a5,452 # 8001f3b8 <bcache+0x8000>
    800031fc:	2b87b703          	ld	a4,696(a5)
    80003200:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003202:	0001c717          	auipc	a4,0x1c
    80003206:	41e70713          	addi	a4,a4,1054 # 8001f620 <bcache+0x8268>
    8000320a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000320c:	2b87b703          	ld	a4,696(a5)
    80003210:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003212:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003216:	00014517          	auipc	a0,0x14
    8000321a:	1a250513          	addi	a0,a0,418 # 800173b8 <bcache>
    8000321e:	ffffe097          	auipc	ra,0xffffe
    80003222:	a68080e7          	jalr	-1432(ra) # 80000c86 <release>
}
    80003226:	60e2                	ld	ra,24(sp)
    80003228:	6442                	ld	s0,16(sp)
    8000322a:	64a2                	ld	s1,8(sp)
    8000322c:	6902                	ld	s2,0(sp)
    8000322e:	6105                	addi	sp,sp,32
    80003230:	8082                	ret
    panic("brelse");
    80003232:	00005517          	auipc	a0,0x5
    80003236:	54650513          	addi	a0,a0,1350 # 80008778 <syscall_names+0xf8>
    8000323a:	ffffd097          	auipc	ra,0xffffd
    8000323e:	302080e7          	jalr	770(ra) # 8000053c <panic>

0000000080003242 <bpin>:

void
bpin(struct buf *b) {
    80003242:	1101                	addi	sp,sp,-32
    80003244:	ec06                	sd	ra,24(sp)
    80003246:	e822                	sd	s0,16(sp)
    80003248:	e426                	sd	s1,8(sp)
    8000324a:	1000                	addi	s0,sp,32
    8000324c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000324e:	00014517          	auipc	a0,0x14
    80003252:	16a50513          	addi	a0,a0,362 # 800173b8 <bcache>
    80003256:	ffffe097          	auipc	ra,0xffffe
    8000325a:	97c080e7          	jalr	-1668(ra) # 80000bd2 <acquire>
  b->refcnt++;
    8000325e:	40bc                	lw	a5,64(s1)
    80003260:	2785                	addiw	a5,a5,1
    80003262:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003264:	00014517          	auipc	a0,0x14
    80003268:	15450513          	addi	a0,a0,340 # 800173b8 <bcache>
    8000326c:	ffffe097          	auipc	ra,0xffffe
    80003270:	a1a080e7          	jalr	-1510(ra) # 80000c86 <release>
}
    80003274:	60e2                	ld	ra,24(sp)
    80003276:	6442                	ld	s0,16(sp)
    80003278:	64a2                	ld	s1,8(sp)
    8000327a:	6105                	addi	sp,sp,32
    8000327c:	8082                	ret

000000008000327e <bunpin>:

void
bunpin(struct buf *b) {
    8000327e:	1101                	addi	sp,sp,-32
    80003280:	ec06                	sd	ra,24(sp)
    80003282:	e822                	sd	s0,16(sp)
    80003284:	e426                	sd	s1,8(sp)
    80003286:	1000                	addi	s0,sp,32
    80003288:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000328a:	00014517          	auipc	a0,0x14
    8000328e:	12e50513          	addi	a0,a0,302 # 800173b8 <bcache>
    80003292:	ffffe097          	auipc	ra,0xffffe
    80003296:	940080e7          	jalr	-1728(ra) # 80000bd2 <acquire>
  b->refcnt--;
    8000329a:	40bc                	lw	a5,64(s1)
    8000329c:	37fd                	addiw	a5,a5,-1
    8000329e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032a0:	00014517          	auipc	a0,0x14
    800032a4:	11850513          	addi	a0,a0,280 # 800173b8 <bcache>
    800032a8:	ffffe097          	auipc	ra,0xffffe
    800032ac:	9de080e7          	jalr	-1570(ra) # 80000c86 <release>
}
    800032b0:	60e2                	ld	ra,24(sp)
    800032b2:	6442                	ld	s0,16(sp)
    800032b4:	64a2                	ld	s1,8(sp)
    800032b6:	6105                	addi	sp,sp,32
    800032b8:	8082                	ret

00000000800032ba <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800032ba:	1101                	addi	sp,sp,-32
    800032bc:	ec06                	sd	ra,24(sp)
    800032be:	e822                	sd	s0,16(sp)
    800032c0:	e426                	sd	s1,8(sp)
    800032c2:	e04a                	sd	s2,0(sp)
    800032c4:	1000                	addi	s0,sp,32
    800032c6:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800032c8:	00d5d59b          	srliw	a1,a1,0xd
    800032cc:	0001c797          	auipc	a5,0x1c
    800032d0:	7c87a783          	lw	a5,1992(a5) # 8001fa94 <sb+0x1c>
    800032d4:	9dbd                	addw	a1,a1,a5
    800032d6:	00000097          	auipc	ra,0x0
    800032da:	da0080e7          	jalr	-608(ra) # 80003076 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800032de:	0074f713          	andi	a4,s1,7
    800032e2:	4785                	li	a5,1
    800032e4:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800032e8:	14ce                	slli	s1,s1,0x33
    800032ea:	90d9                	srli	s1,s1,0x36
    800032ec:	00950733          	add	a4,a0,s1
    800032f0:	05874703          	lbu	a4,88(a4)
    800032f4:	00e7f6b3          	and	a3,a5,a4
    800032f8:	c69d                	beqz	a3,80003326 <bfree+0x6c>
    800032fa:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800032fc:	94aa                	add	s1,s1,a0
    800032fe:	fff7c793          	not	a5,a5
    80003302:	8f7d                	and	a4,a4,a5
    80003304:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003308:	00001097          	auipc	ra,0x1
    8000330c:	0f6080e7          	jalr	246(ra) # 800043fe <log_write>
  brelse(bp);
    80003310:	854a                	mv	a0,s2
    80003312:	00000097          	auipc	ra,0x0
    80003316:	e94080e7          	jalr	-364(ra) # 800031a6 <brelse>
}
    8000331a:	60e2                	ld	ra,24(sp)
    8000331c:	6442                	ld	s0,16(sp)
    8000331e:	64a2                	ld	s1,8(sp)
    80003320:	6902                	ld	s2,0(sp)
    80003322:	6105                	addi	sp,sp,32
    80003324:	8082                	ret
    panic("freeing free block");
    80003326:	00005517          	auipc	a0,0x5
    8000332a:	45a50513          	addi	a0,a0,1114 # 80008780 <syscall_names+0x100>
    8000332e:	ffffd097          	auipc	ra,0xffffd
    80003332:	20e080e7          	jalr	526(ra) # 8000053c <panic>

0000000080003336 <balloc>:
{
    80003336:	711d                	addi	sp,sp,-96
    80003338:	ec86                	sd	ra,88(sp)
    8000333a:	e8a2                	sd	s0,80(sp)
    8000333c:	e4a6                	sd	s1,72(sp)
    8000333e:	e0ca                	sd	s2,64(sp)
    80003340:	fc4e                	sd	s3,56(sp)
    80003342:	f852                	sd	s4,48(sp)
    80003344:	f456                	sd	s5,40(sp)
    80003346:	f05a                	sd	s6,32(sp)
    80003348:	ec5e                	sd	s7,24(sp)
    8000334a:	e862                	sd	s8,16(sp)
    8000334c:	e466                	sd	s9,8(sp)
    8000334e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003350:	0001c797          	auipc	a5,0x1c
    80003354:	72c7a783          	lw	a5,1836(a5) # 8001fa7c <sb+0x4>
    80003358:	cff5                	beqz	a5,80003454 <balloc+0x11e>
    8000335a:	8baa                	mv	s7,a0
    8000335c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000335e:	0001cb17          	auipc	s6,0x1c
    80003362:	71ab0b13          	addi	s6,s6,1818 # 8001fa78 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003366:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003368:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000336a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000336c:	6c89                	lui	s9,0x2
    8000336e:	a061                	j	800033f6 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003370:	97ca                	add	a5,a5,s2
    80003372:	8e55                	or	a2,a2,a3
    80003374:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003378:	854a                	mv	a0,s2
    8000337a:	00001097          	auipc	ra,0x1
    8000337e:	084080e7          	jalr	132(ra) # 800043fe <log_write>
        brelse(bp);
    80003382:	854a                	mv	a0,s2
    80003384:	00000097          	auipc	ra,0x0
    80003388:	e22080e7          	jalr	-478(ra) # 800031a6 <brelse>
  bp = bread(dev, bno);
    8000338c:	85a6                	mv	a1,s1
    8000338e:	855e                	mv	a0,s7
    80003390:	00000097          	auipc	ra,0x0
    80003394:	ce6080e7          	jalr	-794(ra) # 80003076 <bread>
    80003398:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000339a:	40000613          	li	a2,1024
    8000339e:	4581                	li	a1,0
    800033a0:	05850513          	addi	a0,a0,88
    800033a4:	ffffe097          	auipc	ra,0xffffe
    800033a8:	92a080e7          	jalr	-1750(ra) # 80000cce <memset>
  log_write(bp);
    800033ac:	854a                	mv	a0,s2
    800033ae:	00001097          	auipc	ra,0x1
    800033b2:	050080e7          	jalr	80(ra) # 800043fe <log_write>
  brelse(bp);
    800033b6:	854a                	mv	a0,s2
    800033b8:	00000097          	auipc	ra,0x0
    800033bc:	dee080e7          	jalr	-530(ra) # 800031a6 <brelse>
}
    800033c0:	8526                	mv	a0,s1
    800033c2:	60e6                	ld	ra,88(sp)
    800033c4:	6446                	ld	s0,80(sp)
    800033c6:	64a6                	ld	s1,72(sp)
    800033c8:	6906                	ld	s2,64(sp)
    800033ca:	79e2                	ld	s3,56(sp)
    800033cc:	7a42                	ld	s4,48(sp)
    800033ce:	7aa2                	ld	s5,40(sp)
    800033d0:	7b02                	ld	s6,32(sp)
    800033d2:	6be2                	ld	s7,24(sp)
    800033d4:	6c42                	ld	s8,16(sp)
    800033d6:	6ca2                	ld	s9,8(sp)
    800033d8:	6125                	addi	sp,sp,96
    800033da:	8082                	ret
    brelse(bp);
    800033dc:	854a                	mv	a0,s2
    800033de:	00000097          	auipc	ra,0x0
    800033e2:	dc8080e7          	jalr	-568(ra) # 800031a6 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800033e6:	015c87bb          	addw	a5,s9,s5
    800033ea:	00078a9b          	sext.w	s5,a5
    800033ee:	004b2703          	lw	a4,4(s6)
    800033f2:	06eaf163          	bgeu	s5,a4,80003454 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    800033f6:	41fad79b          	sraiw	a5,s5,0x1f
    800033fa:	0137d79b          	srliw	a5,a5,0x13
    800033fe:	015787bb          	addw	a5,a5,s5
    80003402:	40d7d79b          	sraiw	a5,a5,0xd
    80003406:	01cb2583          	lw	a1,28(s6)
    8000340a:	9dbd                	addw	a1,a1,a5
    8000340c:	855e                	mv	a0,s7
    8000340e:	00000097          	auipc	ra,0x0
    80003412:	c68080e7          	jalr	-920(ra) # 80003076 <bread>
    80003416:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003418:	004b2503          	lw	a0,4(s6)
    8000341c:	000a849b          	sext.w	s1,s5
    80003420:	8762                	mv	a4,s8
    80003422:	faa4fde3          	bgeu	s1,a0,800033dc <balloc+0xa6>
      m = 1 << (bi % 8);
    80003426:	00777693          	andi	a3,a4,7
    8000342a:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000342e:	41f7579b          	sraiw	a5,a4,0x1f
    80003432:	01d7d79b          	srliw	a5,a5,0x1d
    80003436:	9fb9                	addw	a5,a5,a4
    80003438:	4037d79b          	sraiw	a5,a5,0x3
    8000343c:	00f90633          	add	a2,s2,a5
    80003440:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80003444:	00c6f5b3          	and	a1,a3,a2
    80003448:	d585                	beqz	a1,80003370 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000344a:	2705                	addiw	a4,a4,1
    8000344c:	2485                	addiw	s1,s1,1
    8000344e:	fd471ae3          	bne	a4,s4,80003422 <balloc+0xec>
    80003452:	b769                	j	800033dc <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80003454:	00005517          	auipc	a0,0x5
    80003458:	34450513          	addi	a0,a0,836 # 80008798 <syscall_names+0x118>
    8000345c:	ffffd097          	auipc	ra,0xffffd
    80003460:	12a080e7          	jalr	298(ra) # 80000586 <printf>
  return 0;
    80003464:	4481                	li	s1,0
    80003466:	bfa9                	j	800033c0 <balloc+0x8a>

0000000080003468 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003468:	7179                	addi	sp,sp,-48
    8000346a:	f406                	sd	ra,40(sp)
    8000346c:	f022                	sd	s0,32(sp)
    8000346e:	ec26                	sd	s1,24(sp)
    80003470:	e84a                	sd	s2,16(sp)
    80003472:	e44e                	sd	s3,8(sp)
    80003474:	e052                	sd	s4,0(sp)
    80003476:	1800                	addi	s0,sp,48
    80003478:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000347a:	47ad                	li	a5,11
    8000347c:	02b7e863          	bltu	a5,a1,800034ac <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003480:	02059793          	slli	a5,a1,0x20
    80003484:	01e7d593          	srli	a1,a5,0x1e
    80003488:	00b504b3          	add	s1,a0,a1
    8000348c:	0504a903          	lw	s2,80(s1)
    80003490:	06091e63          	bnez	s2,8000350c <bmap+0xa4>
      addr = balloc(ip->dev);
    80003494:	4108                	lw	a0,0(a0)
    80003496:	00000097          	auipc	ra,0x0
    8000349a:	ea0080e7          	jalr	-352(ra) # 80003336 <balloc>
    8000349e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800034a2:	06090563          	beqz	s2,8000350c <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    800034a6:	0524a823          	sw	s2,80(s1)
    800034aa:	a08d                	j	8000350c <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800034ac:	ff45849b          	addiw	s1,a1,-12
    800034b0:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800034b4:	0ff00793          	li	a5,255
    800034b8:	08e7e563          	bltu	a5,a4,80003542 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800034bc:	08052903          	lw	s2,128(a0)
    800034c0:	00091d63          	bnez	s2,800034da <bmap+0x72>
      addr = balloc(ip->dev);
    800034c4:	4108                	lw	a0,0(a0)
    800034c6:	00000097          	auipc	ra,0x0
    800034ca:	e70080e7          	jalr	-400(ra) # 80003336 <balloc>
    800034ce:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800034d2:	02090d63          	beqz	s2,8000350c <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800034d6:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800034da:	85ca                	mv	a1,s2
    800034dc:	0009a503          	lw	a0,0(s3)
    800034e0:	00000097          	auipc	ra,0x0
    800034e4:	b96080e7          	jalr	-1130(ra) # 80003076 <bread>
    800034e8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800034ea:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800034ee:	02049713          	slli	a4,s1,0x20
    800034f2:	01e75593          	srli	a1,a4,0x1e
    800034f6:	00b784b3          	add	s1,a5,a1
    800034fa:	0004a903          	lw	s2,0(s1)
    800034fe:	02090063          	beqz	s2,8000351e <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003502:	8552                	mv	a0,s4
    80003504:	00000097          	auipc	ra,0x0
    80003508:	ca2080e7          	jalr	-862(ra) # 800031a6 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000350c:	854a                	mv	a0,s2
    8000350e:	70a2                	ld	ra,40(sp)
    80003510:	7402                	ld	s0,32(sp)
    80003512:	64e2                	ld	s1,24(sp)
    80003514:	6942                	ld	s2,16(sp)
    80003516:	69a2                	ld	s3,8(sp)
    80003518:	6a02                	ld	s4,0(sp)
    8000351a:	6145                	addi	sp,sp,48
    8000351c:	8082                	ret
      addr = balloc(ip->dev);
    8000351e:	0009a503          	lw	a0,0(s3)
    80003522:	00000097          	auipc	ra,0x0
    80003526:	e14080e7          	jalr	-492(ra) # 80003336 <balloc>
    8000352a:	0005091b          	sext.w	s2,a0
      if(addr){
    8000352e:	fc090ae3          	beqz	s2,80003502 <bmap+0x9a>
        a[bn] = addr;
    80003532:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003536:	8552                	mv	a0,s4
    80003538:	00001097          	auipc	ra,0x1
    8000353c:	ec6080e7          	jalr	-314(ra) # 800043fe <log_write>
    80003540:	b7c9                	j	80003502 <bmap+0x9a>
  panic("bmap: out of range");
    80003542:	00005517          	auipc	a0,0x5
    80003546:	26e50513          	addi	a0,a0,622 # 800087b0 <syscall_names+0x130>
    8000354a:	ffffd097          	auipc	ra,0xffffd
    8000354e:	ff2080e7          	jalr	-14(ra) # 8000053c <panic>

0000000080003552 <iget>:
{
    80003552:	7179                	addi	sp,sp,-48
    80003554:	f406                	sd	ra,40(sp)
    80003556:	f022                	sd	s0,32(sp)
    80003558:	ec26                	sd	s1,24(sp)
    8000355a:	e84a                	sd	s2,16(sp)
    8000355c:	e44e                	sd	s3,8(sp)
    8000355e:	e052                	sd	s4,0(sp)
    80003560:	1800                	addi	s0,sp,48
    80003562:	89aa                	mv	s3,a0
    80003564:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003566:	0001c517          	auipc	a0,0x1c
    8000356a:	53250513          	addi	a0,a0,1330 # 8001fa98 <itable>
    8000356e:	ffffd097          	auipc	ra,0xffffd
    80003572:	664080e7          	jalr	1636(ra) # 80000bd2 <acquire>
  empty = 0;
    80003576:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003578:	0001c497          	auipc	s1,0x1c
    8000357c:	53848493          	addi	s1,s1,1336 # 8001fab0 <itable+0x18>
    80003580:	0001e697          	auipc	a3,0x1e
    80003584:	fc068693          	addi	a3,a3,-64 # 80021540 <log>
    80003588:	a039                	j	80003596 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000358a:	02090b63          	beqz	s2,800035c0 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000358e:	08848493          	addi	s1,s1,136
    80003592:	02d48a63          	beq	s1,a3,800035c6 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003596:	449c                	lw	a5,8(s1)
    80003598:	fef059e3          	blez	a5,8000358a <iget+0x38>
    8000359c:	4098                	lw	a4,0(s1)
    8000359e:	ff3716e3          	bne	a4,s3,8000358a <iget+0x38>
    800035a2:	40d8                	lw	a4,4(s1)
    800035a4:	ff4713e3          	bne	a4,s4,8000358a <iget+0x38>
      ip->ref++;
    800035a8:	2785                	addiw	a5,a5,1
    800035aa:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800035ac:	0001c517          	auipc	a0,0x1c
    800035b0:	4ec50513          	addi	a0,a0,1260 # 8001fa98 <itable>
    800035b4:	ffffd097          	auipc	ra,0xffffd
    800035b8:	6d2080e7          	jalr	1746(ra) # 80000c86 <release>
      return ip;
    800035bc:	8926                	mv	s2,s1
    800035be:	a03d                	j	800035ec <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035c0:	f7f9                	bnez	a5,8000358e <iget+0x3c>
    800035c2:	8926                	mv	s2,s1
    800035c4:	b7e9                	j	8000358e <iget+0x3c>
  if(empty == 0)
    800035c6:	02090c63          	beqz	s2,800035fe <iget+0xac>
  ip->dev = dev;
    800035ca:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800035ce:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800035d2:	4785                	li	a5,1
    800035d4:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800035d8:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800035dc:	0001c517          	auipc	a0,0x1c
    800035e0:	4bc50513          	addi	a0,a0,1212 # 8001fa98 <itable>
    800035e4:	ffffd097          	auipc	ra,0xffffd
    800035e8:	6a2080e7          	jalr	1698(ra) # 80000c86 <release>
}
    800035ec:	854a                	mv	a0,s2
    800035ee:	70a2                	ld	ra,40(sp)
    800035f0:	7402                	ld	s0,32(sp)
    800035f2:	64e2                	ld	s1,24(sp)
    800035f4:	6942                	ld	s2,16(sp)
    800035f6:	69a2                	ld	s3,8(sp)
    800035f8:	6a02                	ld	s4,0(sp)
    800035fa:	6145                	addi	sp,sp,48
    800035fc:	8082                	ret
    panic("iget: no inodes");
    800035fe:	00005517          	auipc	a0,0x5
    80003602:	1ca50513          	addi	a0,a0,458 # 800087c8 <syscall_names+0x148>
    80003606:	ffffd097          	auipc	ra,0xffffd
    8000360a:	f36080e7          	jalr	-202(ra) # 8000053c <panic>

000000008000360e <fsinit>:
fsinit(int dev) {
    8000360e:	7179                	addi	sp,sp,-48
    80003610:	f406                	sd	ra,40(sp)
    80003612:	f022                	sd	s0,32(sp)
    80003614:	ec26                	sd	s1,24(sp)
    80003616:	e84a                	sd	s2,16(sp)
    80003618:	e44e                	sd	s3,8(sp)
    8000361a:	1800                	addi	s0,sp,48
    8000361c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000361e:	4585                	li	a1,1
    80003620:	00000097          	auipc	ra,0x0
    80003624:	a56080e7          	jalr	-1450(ra) # 80003076 <bread>
    80003628:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000362a:	0001c997          	auipc	s3,0x1c
    8000362e:	44e98993          	addi	s3,s3,1102 # 8001fa78 <sb>
    80003632:	02000613          	li	a2,32
    80003636:	05850593          	addi	a1,a0,88
    8000363a:	854e                	mv	a0,s3
    8000363c:	ffffd097          	auipc	ra,0xffffd
    80003640:	6ee080e7          	jalr	1774(ra) # 80000d2a <memmove>
  brelse(bp);
    80003644:	8526                	mv	a0,s1
    80003646:	00000097          	auipc	ra,0x0
    8000364a:	b60080e7          	jalr	-1184(ra) # 800031a6 <brelse>
  if(sb.magic != FSMAGIC)
    8000364e:	0009a703          	lw	a4,0(s3)
    80003652:	102037b7          	lui	a5,0x10203
    80003656:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000365a:	02f71263          	bne	a4,a5,8000367e <fsinit+0x70>
  initlog(dev, &sb);
    8000365e:	0001c597          	auipc	a1,0x1c
    80003662:	41a58593          	addi	a1,a1,1050 # 8001fa78 <sb>
    80003666:	854a                	mv	a0,s2
    80003668:	00001097          	auipc	ra,0x1
    8000366c:	b2c080e7          	jalr	-1236(ra) # 80004194 <initlog>
}
    80003670:	70a2                	ld	ra,40(sp)
    80003672:	7402                	ld	s0,32(sp)
    80003674:	64e2                	ld	s1,24(sp)
    80003676:	6942                	ld	s2,16(sp)
    80003678:	69a2                	ld	s3,8(sp)
    8000367a:	6145                	addi	sp,sp,48
    8000367c:	8082                	ret
    panic("invalid file system");
    8000367e:	00005517          	auipc	a0,0x5
    80003682:	15a50513          	addi	a0,a0,346 # 800087d8 <syscall_names+0x158>
    80003686:	ffffd097          	auipc	ra,0xffffd
    8000368a:	eb6080e7          	jalr	-330(ra) # 8000053c <panic>

000000008000368e <iinit>:
{
    8000368e:	7179                	addi	sp,sp,-48
    80003690:	f406                	sd	ra,40(sp)
    80003692:	f022                	sd	s0,32(sp)
    80003694:	ec26                	sd	s1,24(sp)
    80003696:	e84a                	sd	s2,16(sp)
    80003698:	e44e                	sd	s3,8(sp)
    8000369a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000369c:	00005597          	auipc	a1,0x5
    800036a0:	15458593          	addi	a1,a1,340 # 800087f0 <syscall_names+0x170>
    800036a4:	0001c517          	auipc	a0,0x1c
    800036a8:	3f450513          	addi	a0,a0,1012 # 8001fa98 <itable>
    800036ac:	ffffd097          	auipc	ra,0xffffd
    800036b0:	496080e7          	jalr	1174(ra) # 80000b42 <initlock>
  for(i = 0; i < NINODE; i++) {
    800036b4:	0001c497          	auipc	s1,0x1c
    800036b8:	40c48493          	addi	s1,s1,1036 # 8001fac0 <itable+0x28>
    800036bc:	0001e997          	auipc	s3,0x1e
    800036c0:	e9498993          	addi	s3,s3,-364 # 80021550 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800036c4:	00005917          	auipc	s2,0x5
    800036c8:	13490913          	addi	s2,s2,308 # 800087f8 <syscall_names+0x178>
    800036cc:	85ca                	mv	a1,s2
    800036ce:	8526                	mv	a0,s1
    800036d0:	00001097          	auipc	ra,0x1
    800036d4:	e12080e7          	jalr	-494(ra) # 800044e2 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800036d8:	08848493          	addi	s1,s1,136
    800036dc:	ff3498e3          	bne	s1,s3,800036cc <iinit+0x3e>
}
    800036e0:	70a2                	ld	ra,40(sp)
    800036e2:	7402                	ld	s0,32(sp)
    800036e4:	64e2                	ld	s1,24(sp)
    800036e6:	6942                	ld	s2,16(sp)
    800036e8:	69a2                	ld	s3,8(sp)
    800036ea:	6145                	addi	sp,sp,48
    800036ec:	8082                	ret

00000000800036ee <ialloc>:
{
    800036ee:	7139                	addi	sp,sp,-64
    800036f0:	fc06                	sd	ra,56(sp)
    800036f2:	f822                	sd	s0,48(sp)
    800036f4:	f426                	sd	s1,40(sp)
    800036f6:	f04a                	sd	s2,32(sp)
    800036f8:	ec4e                	sd	s3,24(sp)
    800036fa:	e852                	sd	s4,16(sp)
    800036fc:	e456                	sd	s5,8(sp)
    800036fe:	e05a                	sd	s6,0(sp)
    80003700:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003702:	0001c717          	auipc	a4,0x1c
    80003706:	38272703          	lw	a4,898(a4) # 8001fa84 <sb+0xc>
    8000370a:	4785                	li	a5,1
    8000370c:	04e7f863          	bgeu	a5,a4,8000375c <ialloc+0x6e>
    80003710:	8aaa                	mv	s5,a0
    80003712:	8b2e                	mv	s6,a1
    80003714:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003716:	0001ca17          	auipc	s4,0x1c
    8000371a:	362a0a13          	addi	s4,s4,866 # 8001fa78 <sb>
    8000371e:	00495593          	srli	a1,s2,0x4
    80003722:	018a2783          	lw	a5,24(s4)
    80003726:	9dbd                	addw	a1,a1,a5
    80003728:	8556                	mv	a0,s5
    8000372a:	00000097          	auipc	ra,0x0
    8000372e:	94c080e7          	jalr	-1716(ra) # 80003076 <bread>
    80003732:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003734:	05850993          	addi	s3,a0,88
    80003738:	00f97793          	andi	a5,s2,15
    8000373c:	079a                	slli	a5,a5,0x6
    8000373e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003740:	00099783          	lh	a5,0(s3)
    80003744:	cf9d                	beqz	a5,80003782 <ialloc+0x94>
    brelse(bp);
    80003746:	00000097          	auipc	ra,0x0
    8000374a:	a60080e7          	jalr	-1440(ra) # 800031a6 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000374e:	0905                	addi	s2,s2,1
    80003750:	00ca2703          	lw	a4,12(s4)
    80003754:	0009079b          	sext.w	a5,s2
    80003758:	fce7e3e3          	bltu	a5,a4,8000371e <ialloc+0x30>
  printf("ialloc: no inodes\n");
    8000375c:	00005517          	auipc	a0,0x5
    80003760:	0a450513          	addi	a0,a0,164 # 80008800 <syscall_names+0x180>
    80003764:	ffffd097          	auipc	ra,0xffffd
    80003768:	e22080e7          	jalr	-478(ra) # 80000586 <printf>
  return 0;
    8000376c:	4501                	li	a0,0
}
    8000376e:	70e2                	ld	ra,56(sp)
    80003770:	7442                	ld	s0,48(sp)
    80003772:	74a2                	ld	s1,40(sp)
    80003774:	7902                	ld	s2,32(sp)
    80003776:	69e2                	ld	s3,24(sp)
    80003778:	6a42                	ld	s4,16(sp)
    8000377a:	6aa2                	ld	s5,8(sp)
    8000377c:	6b02                	ld	s6,0(sp)
    8000377e:	6121                	addi	sp,sp,64
    80003780:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003782:	04000613          	li	a2,64
    80003786:	4581                	li	a1,0
    80003788:	854e                	mv	a0,s3
    8000378a:	ffffd097          	auipc	ra,0xffffd
    8000378e:	544080e7          	jalr	1348(ra) # 80000cce <memset>
      dip->type = type;
    80003792:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003796:	8526                	mv	a0,s1
    80003798:	00001097          	auipc	ra,0x1
    8000379c:	c66080e7          	jalr	-922(ra) # 800043fe <log_write>
      brelse(bp);
    800037a0:	8526                	mv	a0,s1
    800037a2:	00000097          	auipc	ra,0x0
    800037a6:	a04080e7          	jalr	-1532(ra) # 800031a6 <brelse>
      return iget(dev, inum);
    800037aa:	0009059b          	sext.w	a1,s2
    800037ae:	8556                	mv	a0,s5
    800037b0:	00000097          	auipc	ra,0x0
    800037b4:	da2080e7          	jalr	-606(ra) # 80003552 <iget>
    800037b8:	bf5d                	j	8000376e <ialloc+0x80>

00000000800037ba <iupdate>:
{
    800037ba:	1101                	addi	sp,sp,-32
    800037bc:	ec06                	sd	ra,24(sp)
    800037be:	e822                	sd	s0,16(sp)
    800037c0:	e426                	sd	s1,8(sp)
    800037c2:	e04a                	sd	s2,0(sp)
    800037c4:	1000                	addi	s0,sp,32
    800037c6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037c8:	415c                	lw	a5,4(a0)
    800037ca:	0047d79b          	srliw	a5,a5,0x4
    800037ce:	0001c597          	auipc	a1,0x1c
    800037d2:	2c25a583          	lw	a1,706(a1) # 8001fa90 <sb+0x18>
    800037d6:	9dbd                	addw	a1,a1,a5
    800037d8:	4108                	lw	a0,0(a0)
    800037da:	00000097          	auipc	ra,0x0
    800037de:	89c080e7          	jalr	-1892(ra) # 80003076 <bread>
    800037e2:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037e4:	05850793          	addi	a5,a0,88
    800037e8:	40d8                	lw	a4,4(s1)
    800037ea:	8b3d                	andi	a4,a4,15
    800037ec:	071a                	slli	a4,a4,0x6
    800037ee:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800037f0:	04449703          	lh	a4,68(s1)
    800037f4:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800037f8:	04649703          	lh	a4,70(s1)
    800037fc:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003800:	04849703          	lh	a4,72(s1)
    80003804:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003808:	04a49703          	lh	a4,74(s1)
    8000380c:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003810:	44f8                	lw	a4,76(s1)
    80003812:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003814:	03400613          	li	a2,52
    80003818:	05048593          	addi	a1,s1,80
    8000381c:	00c78513          	addi	a0,a5,12
    80003820:	ffffd097          	auipc	ra,0xffffd
    80003824:	50a080e7          	jalr	1290(ra) # 80000d2a <memmove>
  log_write(bp);
    80003828:	854a                	mv	a0,s2
    8000382a:	00001097          	auipc	ra,0x1
    8000382e:	bd4080e7          	jalr	-1068(ra) # 800043fe <log_write>
  brelse(bp);
    80003832:	854a                	mv	a0,s2
    80003834:	00000097          	auipc	ra,0x0
    80003838:	972080e7          	jalr	-1678(ra) # 800031a6 <brelse>
}
    8000383c:	60e2                	ld	ra,24(sp)
    8000383e:	6442                	ld	s0,16(sp)
    80003840:	64a2                	ld	s1,8(sp)
    80003842:	6902                	ld	s2,0(sp)
    80003844:	6105                	addi	sp,sp,32
    80003846:	8082                	ret

0000000080003848 <idup>:
{
    80003848:	1101                	addi	sp,sp,-32
    8000384a:	ec06                	sd	ra,24(sp)
    8000384c:	e822                	sd	s0,16(sp)
    8000384e:	e426                	sd	s1,8(sp)
    80003850:	1000                	addi	s0,sp,32
    80003852:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003854:	0001c517          	auipc	a0,0x1c
    80003858:	24450513          	addi	a0,a0,580 # 8001fa98 <itable>
    8000385c:	ffffd097          	auipc	ra,0xffffd
    80003860:	376080e7          	jalr	886(ra) # 80000bd2 <acquire>
  ip->ref++;
    80003864:	449c                	lw	a5,8(s1)
    80003866:	2785                	addiw	a5,a5,1
    80003868:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000386a:	0001c517          	auipc	a0,0x1c
    8000386e:	22e50513          	addi	a0,a0,558 # 8001fa98 <itable>
    80003872:	ffffd097          	auipc	ra,0xffffd
    80003876:	414080e7          	jalr	1044(ra) # 80000c86 <release>
}
    8000387a:	8526                	mv	a0,s1
    8000387c:	60e2                	ld	ra,24(sp)
    8000387e:	6442                	ld	s0,16(sp)
    80003880:	64a2                	ld	s1,8(sp)
    80003882:	6105                	addi	sp,sp,32
    80003884:	8082                	ret

0000000080003886 <ilock>:
{
    80003886:	1101                	addi	sp,sp,-32
    80003888:	ec06                	sd	ra,24(sp)
    8000388a:	e822                	sd	s0,16(sp)
    8000388c:	e426                	sd	s1,8(sp)
    8000388e:	e04a                	sd	s2,0(sp)
    80003890:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003892:	c115                	beqz	a0,800038b6 <ilock+0x30>
    80003894:	84aa                	mv	s1,a0
    80003896:	451c                	lw	a5,8(a0)
    80003898:	00f05f63          	blez	a5,800038b6 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000389c:	0541                	addi	a0,a0,16
    8000389e:	00001097          	auipc	ra,0x1
    800038a2:	c7e080e7          	jalr	-898(ra) # 8000451c <acquiresleep>
  if(ip->valid == 0){
    800038a6:	40bc                	lw	a5,64(s1)
    800038a8:	cf99                	beqz	a5,800038c6 <ilock+0x40>
}
    800038aa:	60e2                	ld	ra,24(sp)
    800038ac:	6442                	ld	s0,16(sp)
    800038ae:	64a2                	ld	s1,8(sp)
    800038b0:	6902                	ld	s2,0(sp)
    800038b2:	6105                	addi	sp,sp,32
    800038b4:	8082                	ret
    panic("ilock");
    800038b6:	00005517          	auipc	a0,0x5
    800038ba:	f6250513          	addi	a0,a0,-158 # 80008818 <syscall_names+0x198>
    800038be:	ffffd097          	auipc	ra,0xffffd
    800038c2:	c7e080e7          	jalr	-898(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038c6:	40dc                	lw	a5,4(s1)
    800038c8:	0047d79b          	srliw	a5,a5,0x4
    800038cc:	0001c597          	auipc	a1,0x1c
    800038d0:	1c45a583          	lw	a1,452(a1) # 8001fa90 <sb+0x18>
    800038d4:	9dbd                	addw	a1,a1,a5
    800038d6:	4088                	lw	a0,0(s1)
    800038d8:	fffff097          	auipc	ra,0xfffff
    800038dc:	79e080e7          	jalr	1950(ra) # 80003076 <bread>
    800038e0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038e2:	05850593          	addi	a1,a0,88
    800038e6:	40dc                	lw	a5,4(s1)
    800038e8:	8bbd                	andi	a5,a5,15
    800038ea:	079a                	slli	a5,a5,0x6
    800038ec:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800038ee:	00059783          	lh	a5,0(a1)
    800038f2:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800038f6:	00259783          	lh	a5,2(a1)
    800038fa:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800038fe:	00459783          	lh	a5,4(a1)
    80003902:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003906:	00659783          	lh	a5,6(a1)
    8000390a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000390e:	459c                	lw	a5,8(a1)
    80003910:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003912:	03400613          	li	a2,52
    80003916:	05b1                	addi	a1,a1,12
    80003918:	05048513          	addi	a0,s1,80
    8000391c:	ffffd097          	auipc	ra,0xffffd
    80003920:	40e080e7          	jalr	1038(ra) # 80000d2a <memmove>
    brelse(bp);
    80003924:	854a                	mv	a0,s2
    80003926:	00000097          	auipc	ra,0x0
    8000392a:	880080e7          	jalr	-1920(ra) # 800031a6 <brelse>
    ip->valid = 1;
    8000392e:	4785                	li	a5,1
    80003930:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003932:	04449783          	lh	a5,68(s1)
    80003936:	fbb5                	bnez	a5,800038aa <ilock+0x24>
      panic("ilock: no type");
    80003938:	00005517          	auipc	a0,0x5
    8000393c:	ee850513          	addi	a0,a0,-280 # 80008820 <syscall_names+0x1a0>
    80003940:	ffffd097          	auipc	ra,0xffffd
    80003944:	bfc080e7          	jalr	-1028(ra) # 8000053c <panic>

0000000080003948 <iunlock>:
{
    80003948:	1101                	addi	sp,sp,-32
    8000394a:	ec06                	sd	ra,24(sp)
    8000394c:	e822                	sd	s0,16(sp)
    8000394e:	e426                	sd	s1,8(sp)
    80003950:	e04a                	sd	s2,0(sp)
    80003952:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003954:	c905                	beqz	a0,80003984 <iunlock+0x3c>
    80003956:	84aa                	mv	s1,a0
    80003958:	01050913          	addi	s2,a0,16
    8000395c:	854a                	mv	a0,s2
    8000395e:	00001097          	auipc	ra,0x1
    80003962:	c58080e7          	jalr	-936(ra) # 800045b6 <holdingsleep>
    80003966:	cd19                	beqz	a0,80003984 <iunlock+0x3c>
    80003968:	449c                	lw	a5,8(s1)
    8000396a:	00f05d63          	blez	a5,80003984 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000396e:	854a                	mv	a0,s2
    80003970:	00001097          	auipc	ra,0x1
    80003974:	c02080e7          	jalr	-1022(ra) # 80004572 <releasesleep>
}
    80003978:	60e2                	ld	ra,24(sp)
    8000397a:	6442                	ld	s0,16(sp)
    8000397c:	64a2                	ld	s1,8(sp)
    8000397e:	6902                	ld	s2,0(sp)
    80003980:	6105                	addi	sp,sp,32
    80003982:	8082                	ret
    panic("iunlock");
    80003984:	00005517          	auipc	a0,0x5
    80003988:	eac50513          	addi	a0,a0,-340 # 80008830 <syscall_names+0x1b0>
    8000398c:	ffffd097          	auipc	ra,0xffffd
    80003990:	bb0080e7          	jalr	-1104(ra) # 8000053c <panic>

0000000080003994 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003994:	7179                	addi	sp,sp,-48
    80003996:	f406                	sd	ra,40(sp)
    80003998:	f022                	sd	s0,32(sp)
    8000399a:	ec26                	sd	s1,24(sp)
    8000399c:	e84a                	sd	s2,16(sp)
    8000399e:	e44e                	sd	s3,8(sp)
    800039a0:	e052                	sd	s4,0(sp)
    800039a2:	1800                	addi	s0,sp,48
    800039a4:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800039a6:	05050493          	addi	s1,a0,80
    800039aa:	08050913          	addi	s2,a0,128
    800039ae:	a021                	j	800039b6 <itrunc+0x22>
    800039b0:	0491                	addi	s1,s1,4
    800039b2:	01248d63          	beq	s1,s2,800039cc <itrunc+0x38>
    if(ip->addrs[i]){
    800039b6:	408c                	lw	a1,0(s1)
    800039b8:	dde5                	beqz	a1,800039b0 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800039ba:	0009a503          	lw	a0,0(s3)
    800039be:	00000097          	auipc	ra,0x0
    800039c2:	8fc080e7          	jalr	-1796(ra) # 800032ba <bfree>
      ip->addrs[i] = 0;
    800039c6:	0004a023          	sw	zero,0(s1)
    800039ca:	b7dd                	j	800039b0 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800039cc:	0809a583          	lw	a1,128(s3)
    800039d0:	e185                	bnez	a1,800039f0 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800039d2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800039d6:	854e                	mv	a0,s3
    800039d8:	00000097          	auipc	ra,0x0
    800039dc:	de2080e7          	jalr	-542(ra) # 800037ba <iupdate>
}
    800039e0:	70a2                	ld	ra,40(sp)
    800039e2:	7402                	ld	s0,32(sp)
    800039e4:	64e2                	ld	s1,24(sp)
    800039e6:	6942                	ld	s2,16(sp)
    800039e8:	69a2                	ld	s3,8(sp)
    800039ea:	6a02                	ld	s4,0(sp)
    800039ec:	6145                	addi	sp,sp,48
    800039ee:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800039f0:	0009a503          	lw	a0,0(s3)
    800039f4:	fffff097          	auipc	ra,0xfffff
    800039f8:	682080e7          	jalr	1666(ra) # 80003076 <bread>
    800039fc:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800039fe:	05850493          	addi	s1,a0,88
    80003a02:	45850913          	addi	s2,a0,1112
    80003a06:	a021                	j	80003a0e <itrunc+0x7a>
    80003a08:	0491                	addi	s1,s1,4
    80003a0a:	01248b63          	beq	s1,s2,80003a20 <itrunc+0x8c>
      if(a[j])
    80003a0e:	408c                	lw	a1,0(s1)
    80003a10:	dde5                	beqz	a1,80003a08 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003a12:	0009a503          	lw	a0,0(s3)
    80003a16:	00000097          	auipc	ra,0x0
    80003a1a:	8a4080e7          	jalr	-1884(ra) # 800032ba <bfree>
    80003a1e:	b7ed                	j	80003a08 <itrunc+0x74>
    brelse(bp);
    80003a20:	8552                	mv	a0,s4
    80003a22:	fffff097          	auipc	ra,0xfffff
    80003a26:	784080e7          	jalr	1924(ra) # 800031a6 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a2a:	0809a583          	lw	a1,128(s3)
    80003a2e:	0009a503          	lw	a0,0(s3)
    80003a32:	00000097          	auipc	ra,0x0
    80003a36:	888080e7          	jalr	-1912(ra) # 800032ba <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a3a:	0809a023          	sw	zero,128(s3)
    80003a3e:	bf51                	j	800039d2 <itrunc+0x3e>

0000000080003a40 <iput>:
{
    80003a40:	1101                	addi	sp,sp,-32
    80003a42:	ec06                	sd	ra,24(sp)
    80003a44:	e822                	sd	s0,16(sp)
    80003a46:	e426                	sd	s1,8(sp)
    80003a48:	e04a                	sd	s2,0(sp)
    80003a4a:	1000                	addi	s0,sp,32
    80003a4c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a4e:	0001c517          	auipc	a0,0x1c
    80003a52:	04a50513          	addi	a0,a0,74 # 8001fa98 <itable>
    80003a56:	ffffd097          	auipc	ra,0xffffd
    80003a5a:	17c080e7          	jalr	380(ra) # 80000bd2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a5e:	4498                	lw	a4,8(s1)
    80003a60:	4785                	li	a5,1
    80003a62:	02f70363          	beq	a4,a5,80003a88 <iput+0x48>
  ip->ref--;
    80003a66:	449c                	lw	a5,8(s1)
    80003a68:	37fd                	addiw	a5,a5,-1
    80003a6a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003a6c:	0001c517          	auipc	a0,0x1c
    80003a70:	02c50513          	addi	a0,a0,44 # 8001fa98 <itable>
    80003a74:	ffffd097          	auipc	ra,0xffffd
    80003a78:	212080e7          	jalr	530(ra) # 80000c86 <release>
}
    80003a7c:	60e2                	ld	ra,24(sp)
    80003a7e:	6442                	ld	s0,16(sp)
    80003a80:	64a2                	ld	s1,8(sp)
    80003a82:	6902                	ld	s2,0(sp)
    80003a84:	6105                	addi	sp,sp,32
    80003a86:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a88:	40bc                	lw	a5,64(s1)
    80003a8a:	dff1                	beqz	a5,80003a66 <iput+0x26>
    80003a8c:	04a49783          	lh	a5,74(s1)
    80003a90:	fbf9                	bnez	a5,80003a66 <iput+0x26>
    acquiresleep(&ip->lock);
    80003a92:	01048913          	addi	s2,s1,16
    80003a96:	854a                	mv	a0,s2
    80003a98:	00001097          	auipc	ra,0x1
    80003a9c:	a84080e7          	jalr	-1404(ra) # 8000451c <acquiresleep>
    release(&itable.lock);
    80003aa0:	0001c517          	auipc	a0,0x1c
    80003aa4:	ff850513          	addi	a0,a0,-8 # 8001fa98 <itable>
    80003aa8:	ffffd097          	auipc	ra,0xffffd
    80003aac:	1de080e7          	jalr	478(ra) # 80000c86 <release>
    itrunc(ip);
    80003ab0:	8526                	mv	a0,s1
    80003ab2:	00000097          	auipc	ra,0x0
    80003ab6:	ee2080e7          	jalr	-286(ra) # 80003994 <itrunc>
    ip->type = 0;
    80003aba:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003abe:	8526                	mv	a0,s1
    80003ac0:	00000097          	auipc	ra,0x0
    80003ac4:	cfa080e7          	jalr	-774(ra) # 800037ba <iupdate>
    ip->valid = 0;
    80003ac8:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003acc:	854a                	mv	a0,s2
    80003ace:	00001097          	auipc	ra,0x1
    80003ad2:	aa4080e7          	jalr	-1372(ra) # 80004572 <releasesleep>
    acquire(&itable.lock);
    80003ad6:	0001c517          	auipc	a0,0x1c
    80003ada:	fc250513          	addi	a0,a0,-62 # 8001fa98 <itable>
    80003ade:	ffffd097          	auipc	ra,0xffffd
    80003ae2:	0f4080e7          	jalr	244(ra) # 80000bd2 <acquire>
    80003ae6:	b741                	j	80003a66 <iput+0x26>

0000000080003ae8 <iunlockput>:
{
    80003ae8:	1101                	addi	sp,sp,-32
    80003aea:	ec06                	sd	ra,24(sp)
    80003aec:	e822                	sd	s0,16(sp)
    80003aee:	e426                	sd	s1,8(sp)
    80003af0:	1000                	addi	s0,sp,32
    80003af2:	84aa                	mv	s1,a0
  iunlock(ip);
    80003af4:	00000097          	auipc	ra,0x0
    80003af8:	e54080e7          	jalr	-428(ra) # 80003948 <iunlock>
  iput(ip);
    80003afc:	8526                	mv	a0,s1
    80003afe:	00000097          	auipc	ra,0x0
    80003b02:	f42080e7          	jalr	-190(ra) # 80003a40 <iput>
}
    80003b06:	60e2                	ld	ra,24(sp)
    80003b08:	6442                	ld	s0,16(sp)
    80003b0a:	64a2                	ld	s1,8(sp)
    80003b0c:	6105                	addi	sp,sp,32
    80003b0e:	8082                	ret

0000000080003b10 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b10:	1141                	addi	sp,sp,-16
    80003b12:	e422                	sd	s0,8(sp)
    80003b14:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b16:	411c                	lw	a5,0(a0)
    80003b18:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b1a:	415c                	lw	a5,4(a0)
    80003b1c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b1e:	04451783          	lh	a5,68(a0)
    80003b22:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b26:	04a51783          	lh	a5,74(a0)
    80003b2a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b2e:	04c56783          	lwu	a5,76(a0)
    80003b32:	e99c                	sd	a5,16(a1)
}
    80003b34:	6422                	ld	s0,8(sp)
    80003b36:	0141                	addi	sp,sp,16
    80003b38:	8082                	ret

0000000080003b3a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b3a:	457c                	lw	a5,76(a0)
    80003b3c:	0ed7e963          	bltu	a5,a3,80003c2e <readi+0xf4>
{
    80003b40:	7159                	addi	sp,sp,-112
    80003b42:	f486                	sd	ra,104(sp)
    80003b44:	f0a2                	sd	s0,96(sp)
    80003b46:	eca6                	sd	s1,88(sp)
    80003b48:	e8ca                	sd	s2,80(sp)
    80003b4a:	e4ce                	sd	s3,72(sp)
    80003b4c:	e0d2                	sd	s4,64(sp)
    80003b4e:	fc56                	sd	s5,56(sp)
    80003b50:	f85a                	sd	s6,48(sp)
    80003b52:	f45e                	sd	s7,40(sp)
    80003b54:	f062                	sd	s8,32(sp)
    80003b56:	ec66                	sd	s9,24(sp)
    80003b58:	e86a                	sd	s10,16(sp)
    80003b5a:	e46e                	sd	s11,8(sp)
    80003b5c:	1880                	addi	s0,sp,112
    80003b5e:	8b2a                	mv	s6,a0
    80003b60:	8bae                	mv	s7,a1
    80003b62:	8a32                	mv	s4,a2
    80003b64:	84b6                	mv	s1,a3
    80003b66:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003b68:	9f35                	addw	a4,a4,a3
    return 0;
    80003b6a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003b6c:	0ad76063          	bltu	a4,a3,80003c0c <readi+0xd2>
  if(off + n > ip->size)
    80003b70:	00e7f463          	bgeu	a5,a4,80003b78 <readi+0x3e>
    n = ip->size - off;
    80003b74:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b78:	0a0a8963          	beqz	s5,80003c2a <readi+0xf0>
    80003b7c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b7e:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003b82:	5c7d                	li	s8,-1
    80003b84:	a82d                	j	80003bbe <readi+0x84>
    80003b86:	020d1d93          	slli	s11,s10,0x20
    80003b8a:	020ddd93          	srli	s11,s11,0x20
    80003b8e:	05890613          	addi	a2,s2,88
    80003b92:	86ee                	mv	a3,s11
    80003b94:	963a                	add	a2,a2,a4
    80003b96:	85d2                	mv	a1,s4
    80003b98:	855e                	mv	a0,s7
    80003b9a:	fffff097          	auipc	ra,0xfffff
    80003b9e:	8dc080e7          	jalr	-1828(ra) # 80002476 <either_copyout>
    80003ba2:	05850d63          	beq	a0,s8,80003bfc <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003ba6:	854a                	mv	a0,s2
    80003ba8:	fffff097          	auipc	ra,0xfffff
    80003bac:	5fe080e7          	jalr	1534(ra) # 800031a6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bb0:	013d09bb          	addw	s3,s10,s3
    80003bb4:	009d04bb          	addw	s1,s10,s1
    80003bb8:	9a6e                	add	s4,s4,s11
    80003bba:	0559f763          	bgeu	s3,s5,80003c08 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003bbe:	00a4d59b          	srliw	a1,s1,0xa
    80003bc2:	855a                	mv	a0,s6
    80003bc4:	00000097          	auipc	ra,0x0
    80003bc8:	8a4080e7          	jalr	-1884(ra) # 80003468 <bmap>
    80003bcc:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003bd0:	cd85                	beqz	a1,80003c08 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003bd2:	000b2503          	lw	a0,0(s6)
    80003bd6:	fffff097          	auipc	ra,0xfffff
    80003bda:	4a0080e7          	jalr	1184(ra) # 80003076 <bread>
    80003bde:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003be0:	3ff4f713          	andi	a4,s1,1023
    80003be4:	40ec87bb          	subw	a5,s9,a4
    80003be8:	413a86bb          	subw	a3,s5,s3
    80003bec:	8d3e                	mv	s10,a5
    80003bee:	2781                	sext.w	a5,a5
    80003bf0:	0006861b          	sext.w	a2,a3
    80003bf4:	f8f679e3          	bgeu	a2,a5,80003b86 <readi+0x4c>
    80003bf8:	8d36                	mv	s10,a3
    80003bfa:	b771                	j	80003b86 <readi+0x4c>
      brelse(bp);
    80003bfc:	854a                	mv	a0,s2
    80003bfe:	fffff097          	auipc	ra,0xfffff
    80003c02:	5a8080e7          	jalr	1448(ra) # 800031a6 <brelse>
      tot = -1;
    80003c06:	59fd                	li	s3,-1
  }
  return tot;
    80003c08:	0009851b          	sext.w	a0,s3
}
    80003c0c:	70a6                	ld	ra,104(sp)
    80003c0e:	7406                	ld	s0,96(sp)
    80003c10:	64e6                	ld	s1,88(sp)
    80003c12:	6946                	ld	s2,80(sp)
    80003c14:	69a6                	ld	s3,72(sp)
    80003c16:	6a06                	ld	s4,64(sp)
    80003c18:	7ae2                	ld	s5,56(sp)
    80003c1a:	7b42                	ld	s6,48(sp)
    80003c1c:	7ba2                	ld	s7,40(sp)
    80003c1e:	7c02                	ld	s8,32(sp)
    80003c20:	6ce2                	ld	s9,24(sp)
    80003c22:	6d42                	ld	s10,16(sp)
    80003c24:	6da2                	ld	s11,8(sp)
    80003c26:	6165                	addi	sp,sp,112
    80003c28:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c2a:	89d6                	mv	s3,s5
    80003c2c:	bff1                	j	80003c08 <readi+0xce>
    return 0;
    80003c2e:	4501                	li	a0,0
}
    80003c30:	8082                	ret

0000000080003c32 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c32:	457c                	lw	a5,76(a0)
    80003c34:	10d7e863          	bltu	a5,a3,80003d44 <writei+0x112>
{
    80003c38:	7159                	addi	sp,sp,-112
    80003c3a:	f486                	sd	ra,104(sp)
    80003c3c:	f0a2                	sd	s0,96(sp)
    80003c3e:	eca6                	sd	s1,88(sp)
    80003c40:	e8ca                	sd	s2,80(sp)
    80003c42:	e4ce                	sd	s3,72(sp)
    80003c44:	e0d2                	sd	s4,64(sp)
    80003c46:	fc56                	sd	s5,56(sp)
    80003c48:	f85a                	sd	s6,48(sp)
    80003c4a:	f45e                	sd	s7,40(sp)
    80003c4c:	f062                	sd	s8,32(sp)
    80003c4e:	ec66                	sd	s9,24(sp)
    80003c50:	e86a                	sd	s10,16(sp)
    80003c52:	e46e                	sd	s11,8(sp)
    80003c54:	1880                	addi	s0,sp,112
    80003c56:	8aaa                	mv	s5,a0
    80003c58:	8bae                	mv	s7,a1
    80003c5a:	8a32                	mv	s4,a2
    80003c5c:	8936                	mv	s2,a3
    80003c5e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c60:	00e687bb          	addw	a5,a3,a4
    80003c64:	0ed7e263          	bltu	a5,a3,80003d48 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003c68:	00043737          	lui	a4,0x43
    80003c6c:	0ef76063          	bltu	a4,a5,80003d4c <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c70:	0c0b0863          	beqz	s6,80003d40 <writei+0x10e>
    80003c74:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c76:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003c7a:	5c7d                	li	s8,-1
    80003c7c:	a091                	j	80003cc0 <writei+0x8e>
    80003c7e:	020d1d93          	slli	s11,s10,0x20
    80003c82:	020ddd93          	srli	s11,s11,0x20
    80003c86:	05848513          	addi	a0,s1,88
    80003c8a:	86ee                	mv	a3,s11
    80003c8c:	8652                	mv	a2,s4
    80003c8e:	85de                	mv	a1,s7
    80003c90:	953a                	add	a0,a0,a4
    80003c92:	fffff097          	auipc	ra,0xfffff
    80003c96:	83a080e7          	jalr	-1990(ra) # 800024cc <either_copyin>
    80003c9a:	07850263          	beq	a0,s8,80003cfe <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003c9e:	8526                	mv	a0,s1
    80003ca0:	00000097          	auipc	ra,0x0
    80003ca4:	75e080e7          	jalr	1886(ra) # 800043fe <log_write>
    brelse(bp);
    80003ca8:	8526                	mv	a0,s1
    80003caa:	fffff097          	auipc	ra,0xfffff
    80003cae:	4fc080e7          	jalr	1276(ra) # 800031a6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cb2:	013d09bb          	addw	s3,s10,s3
    80003cb6:	012d093b          	addw	s2,s10,s2
    80003cba:	9a6e                	add	s4,s4,s11
    80003cbc:	0569f663          	bgeu	s3,s6,80003d08 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003cc0:	00a9559b          	srliw	a1,s2,0xa
    80003cc4:	8556                	mv	a0,s5
    80003cc6:	fffff097          	auipc	ra,0xfffff
    80003cca:	7a2080e7          	jalr	1954(ra) # 80003468 <bmap>
    80003cce:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003cd2:	c99d                	beqz	a1,80003d08 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003cd4:	000aa503          	lw	a0,0(s5)
    80003cd8:	fffff097          	auipc	ra,0xfffff
    80003cdc:	39e080e7          	jalr	926(ra) # 80003076 <bread>
    80003ce0:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ce2:	3ff97713          	andi	a4,s2,1023
    80003ce6:	40ec87bb          	subw	a5,s9,a4
    80003cea:	413b06bb          	subw	a3,s6,s3
    80003cee:	8d3e                	mv	s10,a5
    80003cf0:	2781                	sext.w	a5,a5
    80003cf2:	0006861b          	sext.w	a2,a3
    80003cf6:	f8f674e3          	bgeu	a2,a5,80003c7e <writei+0x4c>
    80003cfa:	8d36                	mv	s10,a3
    80003cfc:	b749                	j	80003c7e <writei+0x4c>
      brelse(bp);
    80003cfe:	8526                	mv	a0,s1
    80003d00:	fffff097          	auipc	ra,0xfffff
    80003d04:	4a6080e7          	jalr	1190(ra) # 800031a6 <brelse>
  }

  if(off > ip->size)
    80003d08:	04caa783          	lw	a5,76(s5)
    80003d0c:	0127f463          	bgeu	a5,s2,80003d14 <writei+0xe2>
    ip->size = off;
    80003d10:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003d14:	8556                	mv	a0,s5
    80003d16:	00000097          	auipc	ra,0x0
    80003d1a:	aa4080e7          	jalr	-1372(ra) # 800037ba <iupdate>

  return tot;
    80003d1e:	0009851b          	sext.w	a0,s3
}
    80003d22:	70a6                	ld	ra,104(sp)
    80003d24:	7406                	ld	s0,96(sp)
    80003d26:	64e6                	ld	s1,88(sp)
    80003d28:	6946                	ld	s2,80(sp)
    80003d2a:	69a6                	ld	s3,72(sp)
    80003d2c:	6a06                	ld	s4,64(sp)
    80003d2e:	7ae2                	ld	s5,56(sp)
    80003d30:	7b42                	ld	s6,48(sp)
    80003d32:	7ba2                	ld	s7,40(sp)
    80003d34:	7c02                	ld	s8,32(sp)
    80003d36:	6ce2                	ld	s9,24(sp)
    80003d38:	6d42                	ld	s10,16(sp)
    80003d3a:	6da2                	ld	s11,8(sp)
    80003d3c:	6165                	addi	sp,sp,112
    80003d3e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d40:	89da                	mv	s3,s6
    80003d42:	bfc9                	j	80003d14 <writei+0xe2>
    return -1;
    80003d44:	557d                	li	a0,-1
}
    80003d46:	8082                	ret
    return -1;
    80003d48:	557d                	li	a0,-1
    80003d4a:	bfe1                	j	80003d22 <writei+0xf0>
    return -1;
    80003d4c:	557d                	li	a0,-1
    80003d4e:	bfd1                	j	80003d22 <writei+0xf0>

0000000080003d50 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d50:	1141                	addi	sp,sp,-16
    80003d52:	e406                	sd	ra,8(sp)
    80003d54:	e022                	sd	s0,0(sp)
    80003d56:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d58:	4639                	li	a2,14
    80003d5a:	ffffd097          	auipc	ra,0xffffd
    80003d5e:	044080e7          	jalr	68(ra) # 80000d9e <strncmp>
}
    80003d62:	60a2                	ld	ra,8(sp)
    80003d64:	6402                	ld	s0,0(sp)
    80003d66:	0141                	addi	sp,sp,16
    80003d68:	8082                	ret

0000000080003d6a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003d6a:	7139                	addi	sp,sp,-64
    80003d6c:	fc06                	sd	ra,56(sp)
    80003d6e:	f822                	sd	s0,48(sp)
    80003d70:	f426                	sd	s1,40(sp)
    80003d72:	f04a                	sd	s2,32(sp)
    80003d74:	ec4e                	sd	s3,24(sp)
    80003d76:	e852                	sd	s4,16(sp)
    80003d78:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003d7a:	04451703          	lh	a4,68(a0)
    80003d7e:	4785                	li	a5,1
    80003d80:	00f71a63          	bne	a4,a5,80003d94 <dirlookup+0x2a>
    80003d84:	892a                	mv	s2,a0
    80003d86:	89ae                	mv	s3,a1
    80003d88:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d8a:	457c                	lw	a5,76(a0)
    80003d8c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003d8e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d90:	e79d                	bnez	a5,80003dbe <dirlookup+0x54>
    80003d92:	a8a5                	j	80003e0a <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003d94:	00005517          	auipc	a0,0x5
    80003d98:	aa450513          	addi	a0,a0,-1372 # 80008838 <syscall_names+0x1b8>
    80003d9c:	ffffc097          	auipc	ra,0xffffc
    80003da0:	7a0080e7          	jalr	1952(ra) # 8000053c <panic>
      panic("dirlookup read");
    80003da4:	00005517          	auipc	a0,0x5
    80003da8:	aac50513          	addi	a0,a0,-1364 # 80008850 <syscall_names+0x1d0>
    80003dac:	ffffc097          	auipc	ra,0xffffc
    80003db0:	790080e7          	jalr	1936(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003db4:	24c1                	addiw	s1,s1,16
    80003db6:	04c92783          	lw	a5,76(s2)
    80003dba:	04f4f763          	bgeu	s1,a5,80003e08 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dbe:	4741                	li	a4,16
    80003dc0:	86a6                	mv	a3,s1
    80003dc2:	fc040613          	addi	a2,s0,-64
    80003dc6:	4581                	li	a1,0
    80003dc8:	854a                	mv	a0,s2
    80003dca:	00000097          	auipc	ra,0x0
    80003dce:	d70080e7          	jalr	-656(ra) # 80003b3a <readi>
    80003dd2:	47c1                	li	a5,16
    80003dd4:	fcf518e3          	bne	a0,a5,80003da4 <dirlookup+0x3a>
    if(de.inum == 0)
    80003dd8:	fc045783          	lhu	a5,-64(s0)
    80003ddc:	dfe1                	beqz	a5,80003db4 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003dde:	fc240593          	addi	a1,s0,-62
    80003de2:	854e                	mv	a0,s3
    80003de4:	00000097          	auipc	ra,0x0
    80003de8:	f6c080e7          	jalr	-148(ra) # 80003d50 <namecmp>
    80003dec:	f561                	bnez	a0,80003db4 <dirlookup+0x4a>
      if(poff)
    80003dee:	000a0463          	beqz	s4,80003df6 <dirlookup+0x8c>
        *poff = off;
    80003df2:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003df6:	fc045583          	lhu	a1,-64(s0)
    80003dfa:	00092503          	lw	a0,0(s2)
    80003dfe:	fffff097          	auipc	ra,0xfffff
    80003e02:	754080e7          	jalr	1876(ra) # 80003552 <iget>
    80003e06:	a011                	j	80003e0a <dirlookup+0xa0>
  return 0;
    80003e08:	4501                	li	a0,0
}
    80003e0a:	70e2                	ld	ra,56(sp)
    80003e0c:	7442                	ld	s0,48(sp)
    80003e0e:	74a2                	ld	s1,40(sp)
    80003e10:	7902                	ld	s2,32(sp)
    80003e12:	69e2                	ld	s3,24(sp)
    80003e14:	6a42                	ld	s4,16(sp)
    80003e16:	6121                	addi	sp,sp,64
    80003e18:	8082                	ret

0000000080003e1a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e1a:	711d                	addi	sp,sp,-96
    80003e1c:	ec86                	sd	ra,88(sp)
    80003e1e:	e8a2                	sd	s0,80(sp)
    80003e20:	e4a6                	sd	s1,72(sp)
    80003e22:	e0ca                	sd	s2,64(sp)
    80003e24:	fc4e                	sd	s3,56(sp)
    80003e26:	f852                	sd	s4,48(sp)
    80003e28:	f456                	sd	s5,40(sp)
    80003e2a:	f05a                	sd	s6,32(sp)
    80003e2c:	ec5e                	sd	s7,24(sp)
    80003e2e:	e862                	sd	s8,16(sp)
    80003e30:	e466                	sd	s9,8(sp)
    80003e32:	1080                	addi	s0,sp,96
    80003e34:	84aa                	mv	s1,a0
    80003e36:	8b2e                	mv	s6,a1
    80003e38:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e3a:	00054703          	lbu	a4,0(a0)
    80003e3e:	02f00793          	li	a5,47
    80003e42:	02f70263          	beq	a4,a5,80003e66 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e46:	ffffe097          	auipc	ra,0xffffe
    80003e4a:	b60080e7          	jalr	-1184(ra) # 800019a6 <myproc>
    80003e4e:	15053503          	ld	a0,336(a0)
    80003e52:	00000097          	auipc	ra,0x0
    80003e56:	9f6080e7          	jalr	-1546(ra) # 80003848 <idup>
    80003e5a:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003e5c:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003e60:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003e62:	4b85                	li	s7,1
    80003e64:	a875                	j	80003f20 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003e66:	4585                	li	a1,1
    80003e68:	4505                	li	a0,1
    80003e6a:	fffff097          	auipc	ra,0xfffff
    80003e6e:	6e8080e7          	jalr	1768(ra) # 80003552 <iget>
    80003e72:	8a2a                	mv	s4,a0
    80003e74:	b7e5                	j	80003e5c <namex+0x42>
      iunlockput(ip);
    80003e76:	8552                	mv	a0,s4
    80003e78:	00000097          	auipc	ra,0x0
    80003e7c:	c70080e7          	jalr	-912(ra) # 80003ae8 <iunlockput>
      return 0;
    80003e80:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e82:	8552                	mv	a0,s4
    80003e84:	60e6                	ld	ra,88(sp)
    80003e86:	6446                	ld	s0,80(sp)
    80003e88:	64a6                	ld	s1,72(sp)
    80003e8a:	6906                	ld	s2,64(sp)
    80003e8c:	79e2                	ld	s3,56(sp)
    80003e8e:	7a42                	ld	s4,48(sp)
    80003e90:	7aa2                	ld	s5,40(sp)
    80003e92:	7b02                	ld	s6,32(sp)
    80003e94:	6be2                	ld	s7,24(sp)
    80003e96:	6c42                	ld	s8,16(sp)
    80003e98:	6ca2                	ld	s9,8(sp)
    80003e9a:	6125                	addi	sp,sp,96
    80003e9c:	8082                	ret
      iunlock(ip);
    80003e9e:	8552                	mv	a0,s4
    80003ea0:	00000097          	auipc	ra,0x0
    80003ea4:	aa8080e7          	jalr	-1368(ra) # 80003948 <iunlock>
      return ip;
    80003ea8:	bfe9                	j	80003e82 <namex+0x68>
      iunlockput(ip);
    80003eaa:	8552                	mv	a0,s4
    80003eac:	00000097          	auipc	ra,0x0
    80003eb0:	c3c080e7          	jalr	-964(ra) # 80003ae8 <iunlockput>
      return 0;
    80003eb4:	8a4e                	mv	s4,s3
    80003eb6:	b7f1                	j	80003e82 <namex+0x68>
  len = path - s;
    80003eb8:	40998633          	sub	a2,s3,s1
    80003ebc:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003ec0:	099c5863          	bge	s8,s9,80003f50 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003ec4:	4639                	li	a2,14
    80003ec6:	85a6                	mv	a1,s1
    80003ec8:	8556                	mv	a0,s5
    80003eca:	ffffd097          	auipc	ra,0xffffd
    80003ece:	e60080e7          	jalr	-416(ra) # 80000d2a <memmove>
    80003ed2:	84ce                	mv	s1,s3
  while(*path == '/')
    80003ed4:	0004c783          	lbu	a5,0(s1)
    80003ed8:	01279763          	bne	a5,s2,80003ee6 <namex+0xcc>
    path++;
    80003edc:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ede:	0004c783          	lbu	a5,0(s1)
    80003ee2:	ff278de3          	beq	a5,s2,80003edc <namex+0xc2>
    ilock(ip);
    80003ee6:	8552                	mv	a0,s4
    80003ee8:	00000097          	auipc	ra,0x0
    80003eec:	99e080e7          	jalr	-1634(ra) # 80003886 <ilock>
    if(ip->type != T_DIR){
    80003ef0:	044a1783          	lh	a5,68(s4)
    80003ef4:	f97791e3          	bne	a5,s7,80003e76 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003ef8:	000b0563          	beqz	s6,80003f02 <namex+0xe8>
    80003efc:	0004c783          	lbu	a5,0(s1)
    80003f00:	dfd9                	beqz	a5,80003e9e <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f02:	4601                	li	a2,0
    80003f04:	85d6                	mv	a1,s5
    80003f06:	8552                	mv	a0,s4
    80003f08:	00000097          	auipc	ra,0x0
    80003f0c:	e62080e7          	jalr	-414(ra) # 80003d6a <dirlookup>
    80003f10:	89aa                	mv	s3,a0
    80003f12:	dd41                	beqz	a0,80003eaa <namex+0x90>
    iunlockput(ip);
    80003f14:	8552                	mv	a0,s4
    80003f16:	00000097          	auipc	ra,0x0
    80003f1a:	bd2080e7          	jalr	-1070(ra) # 80003ae8 <iunlockput>
    ip = next;
    80003f1e:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003f20:	0004c783          	lbu	a5,0(s1)
    80003f24:	01279763          	bne	a5,s2,80003f32 <namex+0x118>
    path++;
    80003f28:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f2a:	0004c783          	lbu	a5,0(s1)
    80003f2e:	ff278de3          	beq	a5,s2,80003f28 <namex+0x10e>
  if(*path == 0)
    80003f32:	cb9d                	beqz	a5,80003f68 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80003f34:	0004c783          	lbu	a5,0(s1)
    80003f38:	89a6                	mv	s3,s1
  len = path - s;
    80003f3a:	4c81                	li	s9,0
    80003f3c:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003f3e:	01278963          	beq	a5,s2,80003f50 <namex+0x136>
    80003f42:	dbbd                	beqz	a5,80003eb8 <namex+0x9e>
    path++;
    80003f44:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003f46:	0009c783          	lbu	a5,0(s3)
    80003f4a:	ff279ce3          	bne	a5,s2,80003f42 <namex+0x128>
    80003f4e:	b7ad                	j	80003eb8 <namex+0x9e>
    memmove(name, s, len);
    80003f50:	2601                	sext.w	a2,a2
    80003f52:	85a6                	mv	a1,s1
    80003f54:	8556                	mv	a0,s5
    80003f56:	ffffd097          	auipc	ra,0xffffd
    80003f5a:	dd4080e7          	jalr	-556(ra) # 80000d2a <memmove>
    name[len] = 0;
    80003f5e:	9cd6                	add	s9,s9,s5
    80003f60:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003f64:	84ce                	mv	s1,s3
    80003f66:	b7bd                	j	80003ed4 <namex+0xba>
  if(nameiparent){
    80003f68:	f00b0de3          	beqz	s6,80003e82 <namex+0x68>
    iput(ip);
    80003f6c:	8552                	mv	a0,s4
    80003f6e:	00000097          	auipc	ra,0x0
    80003f72:	ad2080e7          	jalr	-1326(ra) # 80003a40 <iput>
    return 0;
    80003f76:	4a01                	li	s4,0
    80003f78:	b729                	j	80003e82 <namex+0x68>

0000000080003f7a <dirlink>:
{
    80003f7a:	7139                	addi	sp,sp,-64
    80003f7c:	fc06                	sd	ra,56(sp)
    80003f7e:	f822                	sd	s0,48(sp)
    80003f80:	f426                	sd	s1,40(sp)
    80003f82:	f04a                	sd	s2,32(sp)
    80003f84:	ec4e                	sd	s3,24(sp)
    80003f86:	e852                	sd	s4,16(sp)
    80003f88:	0080                	addi	s0,sp,64
    80003f8a:	892a                	mv	s2,a0
    80003f8c:	8a2e                	mv	s4,a1
    80003f8e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003f90:	4601                	li	a2,0
    80003f92:	00000097          	auipc	ra,0x0
    80003f96:	dd8080e7          	jalr	-552(ra) # 80003d6a <dirlookup>
    80003f9a:	e93d                	bnez	a0,80004010 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f9c:	04c92483          	lw	s1,76(s2)
    80003fa0:	c49d                	beqz	s1,80003fce <dirlink+0x54>
    80003fa2:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fa4:	4741                	li	a4,16
    80003fa6:	86a6                	mv	a3,s1
    80003fa8:	fc040613          	addi	a2,s0,-64
    80003fac:	4581                	li	a1,0
    80003fae:	854a                	mv	a0,s2
    80003fb0:	00000097          	auipc	ra,0x0
    80003fb4:	b8a080e7          	jalr	-1142(ra) # 80003b3a <readi>
    80003fb8:	47c1                	li	a5,16
    80003fba:	06f51163          	bne	a0,a5,8000401c <dirlink+0xa2>
    if(de.inum == 0)
    80003fbe:	fc045783          	lhu	a5,-64(s0)
    80003fc2:	c791                	beqz	a5,80003fce <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fc4:	24c1                	addiw	s1,s1,16
    80003fc6:	04c92783          	lw	a5,76(s2)
    80003fca:	fcf4ede3          	bltu	s1,a5,80003fa4 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003fce:	4639                	li	a2,14
    80003fd0:	85d2                	mv	a1,s4
    80003fd2:	fc240513          	addi	a0,s0,-62
    80003fd6:	ffffd097          	auipc	ra,0xffffd
    80003fda:	e04080e7          	jalr	-508(ra) # 80000dda <strncpy>
  de.inum = inum;
    80003fde:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fe2:	4741                	li	a4,16
    80003fe4:	86a6                	mv	a3,s1
    80003fe6:	fc040613          	addi	a2,s0,-64
    80003fea:	4581                	li	a1,0
    80003fec:	854a                	mv	a0,s2
    80003fee:	00000097          	auipc	ra,0x0
    80003ff2:	c44080e7          	jalr	-956(ra) # 80003c32 <writei>
    80003ff6:	1541                	addi	a0,a0,-16
    80003ff8:	00a03533          	snez	a0,a0
    80003ffc:	40a00533          	neg	a0,a0
}
    80004000:	70e2                	ld	ra,56(sp)
    80004002:	7442                	ld	s0,48(sp)
    80004004:	74a2                	ld	s1,40(sp)
    80004006:	7902                	ld	s2,32(sp)
    80004008:	69e2                	ld	s3,24(sp)
    8000400a:	6a42                	ld	s4,16(sp)
    8000400c:	6121                	addi	sp,sp,64
    8000400e:	8082                	ret
    iput(ip);
    80004010:	00000097          	auipc	ra,0x0
    80004014:	a30080e7          	jalr	-1488(ra) # 80003a40 <iput>
    return -1;
    80004018:	557d                	li	a0,-1
    8000401a:	b7dd                	j	80004000 <dirlink+0x86>
      panic("dirlink read");
    8000401c:	00005517          	auipc	a0,0x5
    80004020:	84450513          	addi	a0,a0,-1980 # 80008860 <syscall_names+0x1e0>
    80004024:	ffffc097          	auipc	ra,0xffffc
    80004028:	518080e7          	jalr	1304(ra) # 8000053c <panic>

000000008000402c <namei>:

struct inode*
namei(char *path)
{
    8000402c:	1101                	addi	sp,sp,-32
    8000402e:	ec06                	sd	ra,24(sp)
    80004030:	e822                	sd	s0,16(sp)
    80004032:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004034:	fe040613          	addi	a2,s0,-32
    80004038:	4581                	li	a1,0
    8000403a:	00000097          	auipc	ra,0x0
    8000403e:	de0080e7          	jalr	-544(ra) # 80003e1a <namex>
}
    80004042:	60e2                	ld	ra,24(sp)
    80004044:	6442                	ld	s0,16(sp)
    80004046:	6105                	addi	sp,sp,32
    80004048:	8082                	ret

000000008000404a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000404a:	1141                	addi	sp,sp,-16
    8000404c:	e406                	sd	ra,8(sp)
    8000404e:	e022                	sd	s0,0(sp)
    80004050:	0800                	addi	s0,sp,16
    80004052:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004054:	4585                	li	a1,1
    80004056:	00000097          	auipc	ra,0x0
    8000405a:	dc4080e7          	jalr	-572(ra) # 80003e1a <namex>
}
    8000405e:	60a2                	ld	ra,8(sp)
    80004060:	6402                	ld	s0,0(sp)
    80004062:	0141                	addi	sp,sp,16
    80004064:	8082                	ret

0000000080004066 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004066:	1101                	addi	sp,sp,-32
    80004068:	ec06                	sd	ra,24(sp)
    8000406a:	e822                	sd	s0,16(sp)
    8000406c:	e426                	sd	s1,8(sp)
    8000406e:	e04a                	sd	s2,0(sp)
    80004070:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004072:	0001d917          	auipc	s2,0x1d
    80004076:	4ce90913          	addi	s2,s2,1230 # 80021540 <log>
    8000407a:	01892583          	lw	a1,24(s2)
    8000407e:	02892503          	lw	a0,40(s2)
    80004082:	fffff097          	auipc	ra,0xfffff
    80004086:	ff4080e7          	jalr	-12(ra) # 80003076 <bread>
    8000408a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000408c:	02c92603          	lw	a2,44(s2)
    80004090:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004092:	00c05f63          	blez	a2,800040b0 <write_head+0x4a>
    80004096:	0001d717          	auipc	a4,0x1d
    8000409a:	4da70713          	addi	a4,a4,1242 # 80021570 <log+0x30>
    8000409e:	87aa                	mv	a5,a0
    800040a0:	060a                	slli	a2,a2,0x2
    800040a2:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800040a4:	4314                	lw	a3,0(a4)
    800040a6:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800040a8:	0711                	addi	a4,a4,4
    800040aa:	0791                	addi	a5,a5,4
    800040ac:	fec79ce3          	bne	a5,a2,800040a4 <write_head+0x3e>
  }
  bwrite(buf);
    800040b0:	8526                	mv	a0,s1
    800040b2:	fffff097          	auipc	ra,0xfffff
    800040b6:	0b6080e7          	jalr	182(ra) # 80003168 <bwrite>
  brelse(buf);
    800040ba:	8526                	mv	a0,s1
    800040bc:	fffff097          	auipc	ra,0xfffff
    800040c0:	0ea080e7          	jalr	234(ra) # 800031a6 <brelse>
}
    800040c4:	60e2                	ld	ra,24(sp)
    800040c6:	6442                	ld	s0,16(sp)
    800040c8:	64a2                	ld	s1,8(sp)
    800040ca:	6902                	ld	s2,0(sp)
    800040cc:	6105                	addi	sp,sp,32
    800040ce:	8082                	ret

00000000800040d0 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800040d0:	0001d797          	auipc	a5,0x1d
    800040d4:	49c7a783          	lw	a5,1180(a5) # 8002156c <log+0x2c>
    800040d8:	0af05d63          	blez	a5,80004192 <install_trans+0xc2>
{
    800040dc:	7139                	addi	sp,sp,-64
    800040de:	fc06                	sd	ra,56(sp)
    800040e0:	f822                	sd	s0,48(sp)
    800040e2:	f426                	sd	s1,40(sp)
    800040e4:	f04a                	sd	s2,32(sp)
    800040e6:	ec4e                	sd	s3,24(sp)
    800040e8:	e852                	sd	s4,16(sp)
    800040ea:	e456                	sd	s5,8(sp)
    800040ec:	e05a                	sd	s6,0(sp)
    800040ee:	0080                	addi	s0,sp,64
    800040f0:	8b2a                	mv	s6,a0
    800040f2:	0001da97          	auipc	s5,0x1d
    800040f6:	47ea8a93          	addi	s5,s5,1150 # 80021570 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040fa:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800040fc:	0001d997          	auipc	s3,0x1d
    80004100:	44498993          	addi	s3,s3,1092 # 80021540 <log>
    80004104:	a00d                	j	80004126 <install_trans+0x56>
    brelse(lbuf);
    80004106:	854a                	mv	a0,s2
    80004108:	fffff097          	auipc	ra,0xfffff
    8000410c:	09e080e7          	jalr	158(ra) # 800031a6 <brelse>
    brelse(dbuf);
    80004110:	8526                	mv	a0,s1
    80004112:	fffff097          	auipc	ra,0xfffff
    80004116:	094080e7          	jalr	148(ra) # 800031a6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000411a:	2a05                	addiw	s4,s4,1
    8000411c:	0a91                	addi	s5,s5,4
    8000411e:	02c9a783          	lw	a5,44(s3)
    80004122:	04fa5e63          	bge	s4,a5,8000417e <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004126:	0189a583          	lw	a1,24(s3)
    8000412a:	014585bb          	addw	a1,a1,s4
    8000412e:	2585                	addiw	a1,a1,1
    80004130:	0289a503          	lw	a0,40(s3)
    80004134:	fffff097          	auipc	ra,0xfffff
    80004138:	f42080e7          	jalr	-190(ra) # 80003076 <bread>
    8000413c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000413e:	000aa583          	lw	a1,0(s5)
    80004142:	0289a503          	lw	a0,40(s3)
    80004146:	fffff097          	auipc	ra,0xfffff
    8000414a:	f30080e7          	jalr	-208(ra) # 80003076 <bread>
    8000414e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004150:	40000613          	li	a2,1024
    80004154:	05890593          	addi	a1,s2,88
    80004158:	05850513          	addi	a0,a0,88
    8000415c:	ffffd097          	auipc	ra,0xffffd
    80004160:	bce080e7          	jalr	-1074(ra) # 80000d2a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004164:	8526                	mv	a0,s1
    80004166:	fffff097          	auipc	ra,0xfffff
    8000416a:	002080e7          	jalr	2(ra) # 80003168 <bwrite>
    if(recovering == 0)
    8000416e:	f80b1ce3          	bnez	s6,80004106 <install_trans+0x36>
      bunpin(dbuf);
    80004172:	8526                	mv	a0,s1
    80004174:	fffff097          	auipc	ra,0xfffff
    80004178:	10a080e7          	jalr	266(ra) # 8000327e <bunpin>
    8000417c:	b769                	j	80004106 <install_trans+0x36>
}
    8000417e:	70e2                	ld	ra,56(sp)
    80004180:	7442                	ld	s0,48(sp)
    80004182:	74a2                	ld	s1,40(sp)
    80004184:	7902                	ld	s2,32(sp)
    80004186:	69e2                	ld	s3,24(sp)
    80004188:	6a42                	ld	s4,16(sp)
    8000418a:	6aa2                	ld	s5,8(sp)
    8000418c:	6b02                	ld	s6,0(sp)
    8000418e:	6121                	addi	sp,sp,64
    80004190:	8082                	ret
    80004192:	8082                	ret

0000000080004194 <initlog>:
{
    80004194:	7179                	addi	sp,sp,-48
    80004196:	f406                	sd	ra,40(sp)
    80004198:	f022                	sd	s0,32(sp)
    8000419a:	ec26                	sd	s1,24(sp)
    8000419c:	e84a                	sd	s2,16(sp)
    8000419e:	e44e                	sd	s3,8(sp)
    800041a0:	1800                	addi	s0,sp,48
    800041a2:	892a                	mv	s2,a0
    800041a4:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800041a6:	0001d497          	auipc	s1,0x1d
    800041aa:	39a48493          	addi	s1,s1,922 # 80021540 <log>
    800041ae:	00004597          	auipc	a1,0x4
    800041b2:	6c258593          	addi	a1,a1,1730 # 80008870 <syscall_names+0x1f0>
    800041b6:	8526                	mv	a0,s1
    800041b8:	ffffd097          	auipc	ra,0xffffd
    800041bc:	98a080e7          	jalr	-1654(ra) # 80000b42 <initlock>
  log.start = sb->logstart;
    800041c0:	0149a583          	lw	a1,20(s3)
    800041c4:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800041c6:	0109a783          	lw	a5,16(s3)
    800041ca:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800041cc:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800041d0:	854a                	mv	a0,s2
    800041d2:	fffff097          	auipc	ra,0xfffff
    800041d6:	ea4080e7          	jalr	-348(ra) # 80003076 <bread>
  log.lh.n = lh->n;
    800041da:	4d30                	lw	a2,88(a0)
    800041dc:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800041de:	00c05f63          	blez	a2,800041fc <initlog+0x68>
    800041e2:	87aa                	mv	a5,a0
    800041e4:	0001d717          	auipc	a4,0x1d
    800041e8:	38c70713          	addi	a4,a4,908 # 80021570 <log+0x30>
    800041ec:	060a                	slli	a2,a2,0x2
    800041ee:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800041f0:	4ff4                	lw	a3,92(a5)
    800041f2:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800041f4:	0791                	addi	a5,a5,4
    800041f6:	0711                	addi	a4,a4,4
    800041f8:	fec79ce3          	bne	a5,a2,800041f0 <initlog+0x5c>
  brelse(buf);
    800041fc:	fffff097          	auipc	ra,0xfffff
    80004200:	faa080e7          	jalr	-86(ra) # 800031a6 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004204:	4505                	li	a0,1
    80004206:	00000097          	auipc	ra,0x0
    8000420a:	eca080e7          	jalr	-310(ra) # 800040d0 <install_trans>
  log.lh.n = 0;
    8000420e:	0001d797          	auipc	a5,0x1d
    80004212:	3407af23          	sw	zero,862(a5) # 8002156c <log+0x2c>
  write_head(); // clear the log
    80004216:	00000097          	auipc	ra,0x0
    8000421a:	e50080e7          	jalr	-432(ra) # 80004066 <write_head>
}
    8000421e:	70a2                	ld	ra,40(sp)
    80004220:	7402                	ld	s0,32(sp)
    80004222:	64e2                	ld	s1,24(sp)
    80004224:	6942                	ld	s2,16(sp)
    80004226:	69a2                	ld	s3,8(sp)
    80004228:	6145                	addi	sp,sp,48
    8000422a:	8082                	ret

000000008000422c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000422c:	1101                	addi	sp,sp,-32
    8000422e:	ec06                	sd	ra,24(sp)
    80004230:	e822                	sd	s0,16(sp)
    80004232:	e426                	sd	s1,8(sp)
    80004234:	e04a                	sd	s2,0(sp)
    80004236:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004238:	0001d517          	auipc	a0,0x1d
    8000423c:	30850513          	addi	a0,a0,776 # 80021540 <log>
    80004240:	ffffd097          	auipc	ra,0xffffd
    80004244:	992080e7          	jalr	-1646(ra) # 80000bd2 <acquire>
  while(1){
    if(log.committing){
    80004248:	0001d497          	auipc	s1,0x1d
    8000424c:	2f848493          	addi	s1,s1,760 # 80021540 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004250:	4979                	li	s2,30
    80004252:	a039                	j	80004260 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004254:	85a6                	mv	a1,s1
    80004256:	8526                	mv	a0,s1
    80004258:	ffffe097          	auipc	ra,0xffffe
    8000425c:	e16080e7          	jalr	-490(ra) # 8000206e <sleep>
    if(log.committing){
    80004260:	50dc                	lw	a5,36(s1)
    80004262:	fbed                	bnez	a5,80004254 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004264:	5098                	lw	a4,32(s1)
    80004266:	2705                	addiw	a4,a4,1
    80004268:	0027179b          	slliw	a5,a4,0x2
    8000426c:	9fb9                	addw	a5,a5,a4
    8000426e:	0017979b          	slliw	a5,a5,0x1
    80004272:	54d4                	lw	a3,44(s1)
    80004274:	9fb5                	addw	a5,a5,a3
    80004276:	00f95963          	bge	s2,a5,80004288 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000427a:	85a6                	mv	a1,s1
    8000427c:	8526                	mv	a0,s1
    8000427e:	ffffe097          	auipc	ra,0xffffe
    80004282:	df0080e7          	jalr	-528(ra) # 8000206e <sleep>
    80004286:	bfe9                	j	80004260 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004288:	0001d517          	auipc	a0,0x1d
    8000428c:	2b850513          	addi	a0,a0,696 # 80021540 <log>
    80004290:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004292:	ffffd097          	auipc	ra,0xffffd
    80004296:	9f4080e7          	jalr	-1548(ra) # 80000c86 <release>
      break;
    }
  }
}
    8000429a:	60e2                	ld	ra,24(sp)
    8000429c:	6442                	ld	s0,16(sp)
    8000429e:	64a2                	ld	s1,8(sp)
    800042a0:	6902                	ld	s2,0(sp)
    800042a2:	6105                	addi	sp,sp,32
    800042a4:	8082                	ret

00000000800042a6 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800042a6:	7139                	addi	sp,sp,-64
    800042a8:	fc06                	sd	ra,56(sp)
    800042aa:	f822                	sd	s0,48(sp)
    800042ac:	f426                	sd	s1,40(sp)
    800042ae:	f04a                	sd	s2,32(sp)
    800042b0:	ec4e                	sd	s3,24(sp)
    800042b2:	e852                	sd	s4,16(sp)
    800042b4:	e456                	sd	s5,8(sp)
    800042b6:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800042b8:	0001d497          	auipc	s1,0x1d
    800042bc:	28848493          	addi	s1,s1,648 # 80021540 <log>
    800042c0:	8526                	mv	a0,s1
    800042c2:	ffffd097          	auipc	ra,0xffffd
    800042c6:	910080e7          	jalr	-1776(ra) # 80000bd2 <acquire>
  log.outstanding -= 1;
    800042ca:	509c                	lw	a5,32(s1)
    800042cc:	37fd                	addiw	a5,a5,-1
    800042ce:	0007891b          	sext.w	s2,a5
    800042d2:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800042d4:	50dc                	lw	a5,36(s1)
    800042d6:	e7b9                	bnez	a5,80004324 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800042d8:	04091e63          	bnez	s2,80004334 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800042dc:	0001d497          	auipc	s1,0x1d
    800042e0:	26448493          	addi	s1,s1,612 # 80021540 <log>
    800042e4:	4785                	li	a5,1
    800042e6:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800042e8:	8526                	mv	a0,s1
    800042ea:	ffffd097          	auipc	ra,0xffffd
    800042ee:	99c080e7          	jalr	-1636(ra) # 80000c86 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800042f2:	54dc                	lw	a5,44(s1)
    800042f4:	06f04763          	bgtz	a5,80004362 <end_op+0xbc>
    acquire(&log.lock);
    800042f8:	0001d497          	auipc	s1,0x1d
    800042fc:	24848493          	addi	s1,s1,584 # 80021540 <log>
    80004300:	8526                	mv	a0,s1
    80004302:	ffffd097          	auipc	ra,0xffffd
    80004306:	8d0080e7          	jalr	-1840(ra) # 80000bd2 <acquire>
    log.committing = 0;
    8000430a:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000430e:	8526                	mv	a0,s1
    80004310:	ffffe097          	auipc	ra,0xffffe
    80004314:	dc2080e7          	jalr	-574(ra) # 800020d2 <wakeup>
    release(&log.lock);
    80004318:	8526                	mv	a0,s1
    8000431a:	ffffd097          	auipc	ra,0xffffd
    8000431e:	96c080e7          	jalr	-1684(ra) # 80000c86 <release>
}
    80004322:	a03d                	j	80004350 <end_op+0xaa>
    panic("log.committing");
    80004324:	00004517          	auipc	a0,0x4
    80004328:	55450513          	addi	a0,a0,1364 # 80008878 <syscall_names+0x1f8>
    8000432c:	ffffc097          	auipc	ra,0xffffc
    80004330:	210080e7          	jalr	528(ra) # 8000053c <panic>
    wakeup(&log);
    80004334:	0001d497          	auipc	s1,0x1d
    80004338:	20c48493          	addi	s1,s1,524 # 80021540 <log>
    8000433c:	8526                	mv	a0,s1
    8000433e:	ffffe097          	auipc	ra,0xffffe
    80004342:	d94080e7          	jalr	-620(ra) # 800020d2 <wakeup>
  release(&log.lock);
    80004346:	8526                	mv	a0,s1
    80004348:	ffffd097          	auipc	ra,0xffffd
    8000434c:	93e080e7          	jalr	-1730(ra) # 80000c86 <release>
}
    80004350:	70e2                	ld	ra,56(sp)
    80004352:	7442                	ld	s0,48(sp)
    80004354:	74a2                	ld	s1,40(sp)
    80004356:	7902                	ld	s2,32(sp)
    80004358:	69e2                	ld	s3,24(sp)
    8000435a:	6a42                	ld	s4,16(sp)
    8000435c:	6aa2                	ld	s5,8(sp)
    8000435e:	6121                	addi	sp,sp,64
    80004360:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004362:	0001da97          	auipc	s5,0x1d
    80004366:	20ea8a93          	addi	s5,s5,526 # 80021570 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000436a:	0001da17          	auipc	s4,0x1d
    8000436e:	1d6a0a13          	addi	s4,s4,470 # 80021540 <log>
    80004372:	018a2583          	lw	a1,24(s4)
    80004376:	012585bb          	addw	a1,a1,s2
    8000437a:	2585                	addiw	a1,a1,1
    8000437c:	028a2503          	lw	a0,40(s4)
    80004380:	fffff097          	auipc	ra,0xfffff
    80004384:	cf6080e7          	jalr	-778(ra) # 80003076 <bread>
    80004388:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000438a:	000aa583          	lw	a1,0(s5)
    8000438e:	028a2503          	lw	a0,40(s4)
    80004392:	fffff097          	auipc	ra,0xfffff
    80004396:	ce4080e7          	jalr	-796(ra) # 80003076 <bread>
    8000439a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000439c:	40000613          	li	a2,1024
    800043a0:	05850593          	addi	a1,a0,88
    800043a4:	05848513          	addi	a0,s1,88
    800043a8:	ffffd097          	auipc	ra,0xffffd
    800043ac:	982080e7          	jalr	-1662(ra) # 80000d2a <memmove>
    bwrite(to);  // write the log
    800043b0:	8526                	mv	a0,s1
    800043b2:	fffff097          	auipc	ra,0xfffff
    800043b6:	db6080e7          	jalr	-586(ra) # 80003168 <bwrite>
    brelse(from);
    800043ba:	854e                	mv	a0,s3
    800043bc:	fffff097          	auipc	ra,0xfffff
    800043c0:	dea080e7          	jalr	-534(ra) # 800031a6 <brelse>
    brelse(to);
    800043c4:	8526                	mv	a0,s1
    800043c6:	fffff097          	auipc	ra,0xfffff
    800043ca:	de0080e7          	jalr	-544(ra) # 800031a6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043ce:	2905                	addiw	s2,s2,1
    800043d0:	0a91                	addi	s5,s5,4
    800043d2:	02ca2783          	lw	a5,44(s4)
    800043d6:	f8f94ee3          	blt	s2,a5,80004372 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800043da:	00000097          	auipc	ra,0x0
    800043de:	c8c080e7          	jalr	-884(ra) # 80004066 <write_head>
    install_trans(0); // Now install writes to home locations
    800043e2:	4501                	li	a0,0
    800043e4:	00000097          	auipc	ra,0x0
    800043e8:	cec080e7          	jalr	-788(ra) # 800040d0 <install_trans>
    log.lh.n = 0;
    800043ec:	0001d797          	auipc	a5,0x1d
    800043f0:	1807a023          	sw	zero,384(a5) # 8002156c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800043f4:	00000097          	auipc	ra,0x0
    800043f8:	c72080e7          	jalr	-910(ra) # 80004066 <write_head>
    800043fc:	bdf5                	j	800042f8 <end_op+0x52>

00000000800043fe <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800043fe:	1101                	addi	sp,sp,-32
    80004400:	ec06                	sd	ra,24(sp)
    80004402:	e822                	sd	s0,16(sp)
    80004404:	e426                	sd	s1,8(sp)
    80004406:	e04a                	sd	s2,0(sp)
    80004408:	1000                	addi	s0,sp,32
    8000440a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000440c:	0001d917          	auipc	s2,0x1d
    80004410:	13490913          	addi	s2,s2,308 # 80021540 <log>
    80004414:	854a                	mv	a0,s2
    80004416:	ffffc097          	auipc	ra,0xffffc
    8000441a:	7bc080e7          	jalr	1980(ra) # 80000bd2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000441e:	02c92603          	lw	a2,44(s2)
    80004422:	47f5                	li	a5,29
    80004424:	06c7c563          	blt	a5,a2,8000448e <log_write+0x90>
    80004428:	0001d797          	auipc	a5,0x1d
    8000442c:	1347a783          	lw	a5,308(a5) # 8002155c <log+0x1c>
    80004430:	37fd                	addiw	a5,a5,-1
    80004432:	04f65e63          	bge	a2,a5,8000448e <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004436:	0001d797          	auipc	a5,0x1d
    8000443a:	12a7a783          	lw	a5,298(a5) # 80021560 <log+0x20>
    8000443e:	06f05063          	blez	a5,8000449e <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004442:	4781                	li	a5,0
    80004444:	06c05563          	blez	a2,800044ae <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004448:	44cc                	lw	a1,12(s1)
    8000444a:	0001d717          	auipc	a4,0x1d
    8000444e:	12670713          	addi	a4,a4,294 # 80021570 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004452:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004454:	4314                	lw	a3,0(a4)
    80004456:	04b68c63          	beq	a3,a1,800044ae <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000445a:	2785                	addiw	a5,a5,1
    8000445c:	0711                	addi	a4,a4,4
    8000445e:	fef61be3          	bne	a2,a5,80004454 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004462:	0621                	addi	a2,a2,8
    80004464:	060a                	slli	a2,a2,0x2
    80004466:	0001d797          	auipc	a5,0x1d
    8000446a:	0da78793          	addi	a5,a5,218 # 80021540 <log>
    8000446e:	97b2                	add	a5,a5,a2
    80004470:	44d8                	lw	a4,12(s1)
    80004472:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004474:	8526                	mv	a0,s1
    80004476:	fffff097          	auipc	ra,0xfffff
    8000447a:	dcc080e7          	jalr	-564(ra) # 80003242 <bpin>
    log.lh.n++;
    8000447e:	0001d717          	auipc	a4,0x1d
    80004482:	0c270713          	addi	a4,a4,194 # 80021540 <log>
    80004486:	575c                	lw	a5,44(a4)
    80004488:	2785                	addiw	a5,a5,1
    8000448a:	d75c                	sw	a5,44(a4)
    8000448c:	a82d                	j	800044c6 <log_write+0xc8>
    panic("too big a transaction");
    8000448e:	00004517          	auipc	a0,0x4
    80004492:	3fa50513          	addi	a0,a0,1018 # 80008888 <syscall_names+0x208>
    80004496:	ffffc097          	auipc	ra,0xffffc
    8000449a:	0a6080e7          	jalr	166(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    8000449e:	00004517          	auipc	a0,0x4
    800044a2:	40250513          	addi	a0,a0,1026 # 800088a0 <syscall_names+0x220>
    800044a6:	ffffc097          	auipc	ra,0xffffc
    800044aa:	096080e7          	jalr	150(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    800044ae:	00878693          	addi	a3,a5,8
    800044b2:	068a                	slli	a3,a3,0x2
    800044b4:	0001d717          	auipc	a4,0x1d
    800044b8:	08c70713          	addi	a4,a4,140 # 80021540 <log>
    800044bc:	9736                	add	a4,a4,a3
    800044be:	44d4                	lw	a3,12(s1)
    800044c0:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800044c2:	faf609e3          	beq	a2,a5,80004474 <log_write+0x76>
  }
  release(&log.lock);
    800044c6:	0001d517          	auipc	a0,0x1d
    800044ca:	07a50513          	addi	a0,a0,122 # 80021540 <log>
    800044ce:	ffffc097          	auipc	ra,0xffffc
    800044d2:	7b8080e7          	jalr	1976(ra) # 80000c86 <release>
}
    800044d6:	60e2                	ld	ra,24(sp)
    800044d8:	6442                	ld	s0,16(sp)
    800044da:	64a2                	ld	s1,8(sp)
    800044dc:	6902                	ld	s2,0(sp)
    800044de:	6105                	addi	sp,sp,32
    800044e0:	8082                	ret

00000000800044e2 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800044e2:	1101                	addi	sp,sp,-32
    800044e4:	ec06                	sd	ra,24(sp)
    800044e6:	e822                	sd	s0,16(sp)
    800044e8:	e426                	sd	s1,8(sp)
    800044ea:	e04a                	sd	s2,0(sp)
    800044ec:	1000                	addi	s0,sp,32
    800044ee:	84aa                	mv	s1,a0
    800044f0:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800044f2:	00004597          	auipc	a1,0x4
    800044f6:	3ce58593          	addi	a1,a1,974 # 800088c0 <syscall_names+0x240>
    800044fa:	0521                	addi	a0,a0,8
    800044fc:	ffffc097          	auipc	ra,0xffffc
    80004500:	646080e7          	jalr	1606(ra) # 80000b42 <initlock>
  lk->name = name;
    80004504:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004508:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000450c:	0204a423          	sw	zero,40(s1)
}
    80004510:	60e2                	ld	ra,24(sp)
    80004512:	6442                	ld	s0,16(sp)
    80004514:	64a2                	ld	s1,8(sp)
    80004516:	6902                	ld	s2,0(sp)
    80004518:	6105                	addi	sp,sp,32
    8000451a:	8082                	ret

000000008000451c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000451c:	1101                	addi	sp,sp,-32
    8000451e:	ec06                	sd	ra,24(sp)
    80004520:	e822                	sd	s0,16(sp)
    80004522:	e426                	sd	s1,8(sp)
    80004524:	e04a                	sd	s2,0(sp)
    80004526:	1000                	addi	s0,sp,32
    80004528:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000452a:	00850913          	addi	s2,a0,8
    8000452e:	854a                	mv	a0,s2
    80004530:	ffffc097          	auipc	ra,0xffffc
    80004534:	6a2080e7          	jalr	1698(ra) # 80000bd2 <acquire>
  while (lk->locked) {
    80004538:	409c                	lw	a5,0(s1)
    8000453a:	cb89                	beqz	a5,8000454c <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000453c:	85ca                	mv	a1,s2
    8000453e:	8526                	mv	a0,s1
    80004540:	ffffe097          	auipc	ra,0xffffe
    80004544:	b2e080e7          	jalr	-1234(ra) # 8000206e <sleep>
  while (lk->locked) {
    80004548:	409c                	lw	a5,0(s1)
    8000454a:	fbed                	bnez	a5,8000453c <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000454c:	4785                	li	a5,1
    8000454e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004550:	ffffd097          	auipc	ra,0xffffd
    80004554:	456080e7          	jalr	1110(ra) # 800019a6 <myproc>
    80004558:	591c                	lw	a5,48(a0)
    8000455a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000455c:	854a                	mv	a0,s2
    8000455e:	ffffc097          	auipc	ra,0xffffc
    80004562:	728080e7          	jalr	1832(ra) # 80000c86 <release>
}
    80004566:	60e2                	ld	ra,24(sp)
    80004568:	6442                	ld	s0,16(sp)
    8000456a:	64a2                	ld	s1,8(sp)
    8000456c:	6902                	ld	s2,0(sp)
    8000456e:	6105                	addi	sp,sp,32
    80004570:	8082                	ret

0000000080004572 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004572:	1101                	addi	sp,sp,-32
    80004574:	ec06                	sd	ra,24(sp)
    80004576:	e822                	sd	s0,16(sp)
    80004578:	e426                	sd	s1,8(sp)
    8000457a:	e04a                	sd	s2,0(sp)
    8000457c:	1000                	addi	s0,sp,32
    8000457e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004580:	00850913          	addi	s2,a0,8
    80004584:	854a                	mv	a0,s2
    80004586:	ffffc097          	auipc	ra,0xffffc
    8000458a:	64c080e7          	jalr	1612(ra) # 80000bd2 <acquire>
  lk->locked = 0;
    8000458e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004592:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004596:	8526                	mv	a0,s1
    80004598:	ffffe097          	auipc	ra,0xffffe
    8000459c:	b3a080e7          	jalr	-1222(ra) # 800020d2 <wakeup>
  release(&lk->lk);
    800045a0:	854a                	mv	a0,s2
    800045a2:	ffffc097          	auipc	ra,0xffffc
    800045a6:	6e4080e7          	jalr	1764(ra) # 80000c86 <release>
}
    800045aa:	60e2                	ld	ra,24(sp)
    800045ac:	6442                	ld	s0,16(sp)
    800045ae:	64a2                	ld	s1,8(sp)
    800045b0:	6902                	ld	s2,0(sp)
    800045b2:	6105                	addi	sp,sp,32
    800045b4:	8082                	ret

00000000800045b6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800045b6:	7179                	addi	sp,sp,-48
    800045b8:	f406                	sd	ra,40(sp)
    800045ba:	f022                	sd	s0,32(sp)
    800045bc:	ec26                	sd	s1,24(sp)
    800045be:	e84a                	sd	s2,16(sp)
    800045c0:	e44e                	sd	s3,8(sp)
    800045c2:	1800                	addi	s0,sp,48
    800045c4:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800045c6:	00850913          	addi	s2,a0,8
    800045ca:	854a                	mv	a0,s2
    800045cc:	ffffc097          	auipc	ra,0xffffc
    800045d0:	606080e7          	jalr	1542(ra) # 80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800045d4:	409c                	lw	a5,0(s1)
    800045d6:	ef99                	bnez	a5,800045f4 <holdingsleep+0x3e>
    800045d8:	4481                	li	s1,0
  release(&lk->lk);
    800045da:	854a                	mv	a0,s2
    800045dc:	ffffc097          	auipc	ra,0xffffc
    800045e0:	6aa080e7          	jalr	1706(ra) # 80000c86 <release>
  return r;
}
    800045e4:	8526                	mv	a0,s1
    800045e6:	70a2                	ld	ra,40(sp)
    800045e8:	7402                	ld	s0,32(sp)
    800045ea:	64e2                	ld	s1,24(sp)
    800045ec:	6942                	ld	s2,16(sp)
    800045ee:	69a2                	ld	s3,8(sp)
    800045f0:	6145                	addi	sp,sp,48
    800045f2:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800045f4:	0284a983          	lw	s3,40(s1)
    800045f8:	ffffd097          	auipc	ra,0xffffd
    800045fc:	3ae080e7          	jalr	942(ra) # 800019a6 <myproc>
    80004600:	5904                	lw	s1,48(a0)
    80004602:	413484b3          	sub	s1,s1,s3
    80004606:	0014b493          	seqz	s1,s1
    8000460a:	bfc1                	j	800045da <holdingsleep+0x24>

000000008000460c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000460c:	1141                	addi	sp,sp,-16
    8000460e:	e406                	sd	ra,8(sp)
    80004610:	e022                	sd	s0,0(sp)
    80004612:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004614:	00004597          	auipc	a1,0x4
    80004618:	2bc58593          	addi	a1,a1,700 # 800088d0 <syscall_names+0x250>
    8000461c:	0001d517          	auipc	a0,0x1d
    80004620:	06c50513          	addi	a0,a0,108 # 80021688 <ftable>
    80004624:	ffffc097          	auipc	ra,0xffffc
    80004628:	51e080e7          	jalr	1310(ra) # 80000b42 <initlock>
}
    8000462c:	60a2                	ld	ra,8(sp)
    8000462e:	6402                	ld	s0,0(sp)
    80004630:	0141                	addi	sp,sp,16
    80004632:	8082                	ret

0000000080004634 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004634:	1101                	addi	sp,sp,-32
    80004636:	ec06                	sd	ra,24(sp)
    80004638:	e822                	sd	s0,16(sp)
    8000463a:	e426                	sd	s1,8(sp)
    8000463c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000463e:	0001d517          	auipc	a0,0x1d
    80004642:	04a50513          	addi	a0,a0,74 # 80021688 <ftable>
    80004646:	ffffc097          	auipc	ra,0xffffc
    8000464a:	58c080e7          	jalr	1420(ra) # 80000bd2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000464e:	0001d497          	auipc	s1,0x1d
    80004652:	05248493          	addi	s1,s1,82 # 800216a0 <ftable+0x18>
    80004656:	0001e717          	auipc	a4,0x1e
    8000465a:	fea70713          	addi	a4,a4,-22 # 80022640 <disk>
    if(f->ref == 0){
    8000465e:	40dc                	lw	a5,4(s1)
    80004660:	cf99                	beqz	a5,8000467e <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004662:	02848493          	addi	s1,s1,40
    80004666:	fee49ce3          	bne	s1,a4,8000465e <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000466a:	0001d517          	auipc	a0,0x1d
    8000466e:	01e50513          	addi	a0,a0,30 # 80021688 <ftable>
    80004672:	ffffc097          	auipc	ra,0xffffc
    80004676:	614080e7          	jalr	1556(ra) # 80000c86 <release>
  return 0;
    8000467a:	4481                	li	s1,0
    8000467c:	a819                	j	80004692 <filealloc+0x5e>
      f->ref = 1;
    8000467e:	4785                	li	a5,1
    80004680:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004682:	0001d517          	auipc	a0,0x1d
    80004686:	00650513          	addi	a0,a0,6 # 80021688 <ftable>
    8000468a:	ffffc097          	auipc	ra,0xffffc
    8000468e:	5fc080e7          	jalr	1532(ra) # 80000c86 <release>
}
    80004692:	8526                	mv	a0,s1
    80004694:	60e2                	ld	ra,24(sp)
    80004696:	6442                	ld	s0,16(sp)
    80004698:	64a2                	ld	s1,8(sp)
    8000469a:	6105                	addi	sp,sp,32
    8000469c:	8082                	ret

000000008000469e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000469e:	1101                	addi	sp,sp,-32
    800046a0:	ec06                	sd	ra,24(sp)
    800046a2:	e822                	sd	s0,16(sp)
    800046a4:	e426                	sd	s1,8(sp)
    800046a6:	1000                	addi	s0,sp,32
    800046a8:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800046aa:	0001d517          	auipc	a0,0x1d
    800046ae:	fde50513          	addi	a0,a0,-34 # 80021688 <ftable>
    800046b2:	ffffc097          	auipc	ra,0xffffc
    800046b6:	520080e7          	jalr	1312(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    800046ba:	40dc                	lw	a5,4(s1)
    800046bc:	02f05263          	blez	a5,800046e0 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800046c0:	2785                	addiw	a5,a5,1
    800046c2:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800046c4:	0001d517          	auipc	a0,0x1d
    800046c8:	fc450513          	addi	a0,a0,-60 # 80021688 <ftable>
    800046cc:	ffffc097          	auipc	ra,0xffffc
    800046d0:	5ba080e7          	jalr	1466(ra) # 80000c86 <release>
  return f;
}
    800046d4:	8526                	mv	a0,s1
    800046d6:	60e2                	ld	ra,24(sp)
    800046d8:	6442                	ld	s0,16(sp)
    800046da:	64a2                	ld	s1,8(sp)
    800046dc:	6105                	addi	sp,sp,32
    800046de:	8082                	ret
    panic("filedup");
    800046e0:	00004517          	auipc	a0,0x4
    800046e4:	1f850513          	addi	a0,a0,504 # 800088d8 <syscall_names+0x258>
    800046e8:	ffffc097          	auipc	ra,0xffffc
    800046ec:	e54080e7          	jalr	-428(ra) # 8000053c <panic>

00000000800046f0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800046f0:	7139                	addi	sp,sp,-64
    800046f2:	fc06                	sd	ra,56(sp)
    800046f4:	f822                	sd	s0,48(sp)
    800046f6:	f426                	sd	s1,40(sp)
    800046f8:	f04a                	sd	s2,32(sp)
    800046fa:	ec4e                	sd	s3,24(sp)
    800046fc:	e852                	sd	s4,16(sp)
    800046fe:	e456                	sd	s5,8(sp)
    80004700:	0080                	addi	s0,sp,64
    80004702:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004704:	0001d517          	auipc	a0,0x1d
    80004708:	f8450513          	addi	a0,a0,-124 # 80021688 <ftable>
    8000470c:	ffffc097          	auipc	ra,0xffffc
    80004710:	4c6080e7          	jalr	1222(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    80004714:	40dc                	lw	a5,4(s1)
    80004716:	06f05163          	blez	a5,80004778 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000471a:	37fd                	addiw	a5,a5,-1
    8000471c:	0007871b          	sext.w	a4,a5
    80004720:	c0dc                	sw	a5,4(s1)
    80004722:	06e04363          	bgtz	a4,80004788 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004726:	0004a903          	lw	s2,0(s1)
    8000472a:	0094ca83          	lbu	s5,9(s1)
    8000472e:	0104ba03          	ld	s4,16(s1)
    80004732:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004736:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000473a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000473e:	0001d517          	auipc	a0,0x1d
    80004742:	f4a50513          	addi	a0,a0,-182 # 80021688 <ftable>
    80004746:	ffffc097          	auipc	ra,0xffffc
    8000474a:	540080e7          	jalr	1344(ra) # 80000c86 <release>

  if(ff.type == FD_PIPE){
    8000474e:	4785                	li	a5,1
    80004750:	04f90d63          	beq	s2,a5,800047aa <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004754:	3979                	addiw	s2,s2,-2
    80004756:	4785                	li	a5,1
    80004758:	0527e063          	bltu	a5,s2,80004798 <fileclose+0xa8>
    begin_op();
    8000475c:	00000097          	auipc	ra,0x0
    80004760:	ad0080e7          	jalr	-1328(ra) # 8000422c <begin_op>
    iput(ff.ip);
    80004764:	854e                	mv	a0,s3
    80004766:	fffff097          	auipc	ra,0xfffff
    8000476a:	2da080e7          	jalr	730(ra) # 80003a40 <iput>
    end_op();
    8000476e:	00000097          	auipc	ra,0x0
    80004772:	b38080e7          	jalr	-1224(ra) # 800042a6 <end_op>
    80004776:	a00d                	j	80004798 <fileclose+0xa8>
    panic("fileclose");
    80004778:	00004517          	auipc	a0,0x4
    8000477c:	16850513          	addi	a0,a0,360 # 800088e0 <syscall_names+0x260>
    80004780:	ffffc097          	auipc	ra,0xffffc
    80004784:	dbc080e7          	jalr	-580(ra) # 8000053c <panic>
    release(&ftable.lock);
    80004788:	0001d517          	auipc	a0,0x1d
    8000478c:	f0050513          	addi	a0,a0,-256 # 80021688 <ftable>
    80004790:	ffffc097          	auipc	ra,0xffffc
    80004794:	4f6080e7          	jalr	1270(ra) # 80000c86 <release>
  }
}
    80004798:	70e2                	ld	ra,56(sp)
    8000479a:	7442                	ld	s0,48(sp)
    8000479c:	74a2                	ld	s1,40(sp)
    8000479e:	7902                	ld	s2,32(sp)
    800047a0:	69e2                	ld	s3,24(sp)
    800047a2:	6a42                	ld	s4,16(sp)
    800047a4:	6aa2                	ld	s5,8(sp)
    800047a6:	6121                	addi	sp,sp,64
    800047a8:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800047aa:	85d6                	mv	a1,s5
    800047ac:	8552                	mv	a0,s4
    800047ae:	00000097          	auipc	ra,0x0
    800047b2:	348080e7          	jalr	840(ra) # 80004af6 <pipeclose>
    800047b6:	b7cd                	j	80004798 <fileclose+0xa8>

00000000800047b8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800047b8:	715d                	addi	sp,sp,-80
    800047ba:	e486                	sd	ra,72(sp)
    800047bc:	e0a2                	sd	s0,64(sp)
    800047be:	fc26                	sd	s1,56(sp)
    800047c0:	f84a                	sd	s2,48(sp)
    800047c2:	f44e                	sd	s3,40(sp)
    800047c4:	0880                	addi	s0,sp,80
    800047c6:	84aa                	mv	s1,a0
    800047c8:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800047ca:	ffffd097          	auipc	ra,0xffffd
    800047ce:	1dc080e7          	jalr	476(ra) # 800019a6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800047d2:	409c                	lw	a5,0(s1)
    800047d4:	37f9                	addiw	a5,a5,-2
    800047d6:	4705                	li	a4,1
    800047d8:	04f76763          	bltu	a4,a5,80004826 <filestat+0x6e>
    800047dc:	892a                	mv	s2,a0
    ilock(f->ip);
    800047de:	6c88                	ld	a0,24(s1)
    800047e0:	fffff097          	auipc	ra,0xfffff
    800047e4:	0a6080e7          	jalr	166(ra) # 80003886 <ilock>
    stati(f->ip, &st);
    800047e8:	fb840593          	addi	a1,s0,-72
    800047ec:	6c88                	ld	a0,24(s1)
    800047ee:	fffff097          	auipc	ra,0xfffff
    800047f2:	322080e7          	jalr	802(ra) # 80003b10 <stati>
    iunlock(f->ip);
    800047f6:	6c88                	ld	a0,24(s1)
    800047f8:	fffff097          	auipc	ra,0xfffff
    800047fc:	150080e7          	jalr	336(ra) # 80003948 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004800:	46e1                	li	a3,24
    80004802:	fb840613          	addi	a2,s0,-72
    80004806:	85ce                	mv	a1,s3
    80004808:	05093503          	ld	a0,80(s2)
    8000480c:	ffffd097          	auipc	ra,0xffffd
    80004810:	e5a080e7          	jalr	-422(ra) # 80001666 <copyout>
    80004814:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004818:	60a6                	ld	ra,72(sp)
    8000481a:	6406                	ld	s0,64(sp)
    8000481c:	74e2                	ld	s1,56(sp)
    8000481e:	7942                	ld	s2,48(sp)
    80004820:	79a2                	ld	s3,40(sp)
    80004822:	6161                	addi	sp,sp,80
    80004824:	8082                	ret
  return -1;
    80004826:	557d                	li	a0,-1
    80004828:	bfc5                	j	80004818 <filestat+0x60>

000000008000482a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000482a:	7179                	addi	sp,sp,-48
    8000482c:	f406                	sd	ra,40(sp)
    8000482e:	f022                	sd	s0,32(sp)
    80004830:	ec26                	sd	s1,24(sp)
    80004832:	e84a                	sd	s2,16(sp)
    80004834:	e44e                	sd	s3,8(sp)
    80004836:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004838:	00854783          	lbu	a5,8(a0)
    8000483c:	c3d5                	beqz	a5,800048e0 <fileread+0xb6>
    8000483e:	84aa                	mv	s1,a0
    80004840:	89ae                	mv	s3,a1
    80004842:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004844:	411c                	lw	a5,0(a0)
    80004846:	4705                	li	a4,1
    80004848:	04e78963          	beq	a5,a4,8000489a <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000484c:	470d                	li	a4,3
    8000484e:	04e78d63          	beq	a5,a4,800048a8 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004852:	4709                	li	a4,2
    80004854:	06e79e63          	bne	a5,a4,800048d0 <fileread+0xa6>
    ilock(f->ip);
    80004858:	6d08                	ld	a0,24(a0)
    8000485a:	fffff097          	auipc	ra,0xfffff
    8000485e:	02c080e7          	jalr	44(ra) # 80003886 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004862:	874a                	mv	a4,s2
    80004864:	5094                	lw	a3,32(s1)
    80004866:	864e                	mv	a2,s3
    80004868:	4585                	li	a1,1
    8000486a:	6c88                	ld	a0,24(s1)
    8000486c:	fffff097          	auipc	ra,0xfffff
    80004870:	2ce080e7          	jalr	718(ra) # 80003b3a <readi>
    80004874:	892a                	mv	s2,a0
    80004876:	00a05563          	blez	a0,80004880 <fileread+0x56>
      f->off += r;
    8000487a:	509c                	lw	a5,32(s1)
    8000487c:	9fa9                	addw	a5,a5,a0
    8000487e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004880:	6c88                	ld	a0,24(s1)
    80004882:	fffff097          	auipc	ra,0xfffff
    80004886:	0c6080e7          	jalr	198(ra) # 80003948 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000488a:	854a                	mv	a0,s2
    8000488c:	70a2                	ld	ra,40(sp)
    8000488e:	7402                	ld	s0,32(sp)
    80004890:	64e2                	ld	s1,24(sp)
    80004892:	6942                	ld	s2,16(sp)
    80004894:	69a2                	ld	s3,8(sp)
    80004896:	6145                	addi	sp,sp,48
    80004898:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000489a:	6908                	ld	a0,16(a0)
    8000489c:	00000097          	auipc	ra,0x0
    800048a0:	3c2080e7          	jalr	962(ra) # 80004c5e <piperead>
    800048a4:	892a                	mv	s2,a0
    800048a6:	b7d5                	j	8000488a <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800048a8:	02451783          	lh	a5,36(a0)
    800048ac:	03079693          	slli	a3,a5,0x30
    800048b0:	92c1                	srli	a3,a3,0x30
    800048b2:	4725                	li	a4,9
    800048b4:	02d76863          	bltu	a4,a3,800048e4 <fileread+0xba>
    800048b8:	0792                	slli	a5,a5,0x4
    800048ba:	0001d717          	auipc	a4,0x1d
    800048be:	d2e70713          	addi	a4,a4,-722 # 800215e8 <devsw>
    800048c2:	97ba                	add	a5,a5,a4
    800048c4:	639c                	ld	a5,0(a5)
    800048c6:	c38d                	beqz	a5,800048e8 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800048c8:	4505                	li	a0,1
    800048ca:	9782                	jalr	a5
    800048cc:	892a                	mv	s2,a0
    800048ce:	bf75                	j	8000488a <fileread+0x60>
    panic("fileread");
    800048d0:	00004517          	auipc	a0,0x4
    800048d4:	02050513          	addi	a0,a0,32 # 800088f0 <syscall_names+0x270>
    800048d8:	ffffc097          	auipc	ra,0xffffc
    800048dc:	c64080e7          	jalr	-924(ra) # 8000053c <panic>
    return -1;
    800048e0:	597d                	li	s2,-1
    800048e2:	b765                	j	8000488a <fileread+0x60>
      return -1;
    800048e4:	597d                	li	s2,-1
    800048e6:	b755                	j	8000488a <fileread+0x60>
    800048e8:	597d                	li	s2,-1
    800048ea:	b745                	j	8000488a <fileread+0x60>

00000000800048ec <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800048ec:	00954783          	lbu	a5,9(a0)
    800048f0:	10078e63          	beqz	a5,80004a0c <filewrite+0x120>
{
    800048f4:	715d                	addi	sp,sp,-80
    800048f6:	e486                	sd	ra,72(sp)
    800048f8:	e0a2                	sd	s0,64(sp)
    800048fa:	fc26                	sd	s1,56(sp)
    800048fc:	f84a                	sd	s2,48(sp)
    800048fe:	f44e                	sd	s3,40(sp)
    80004900:	f052                	sd	s4,32(sp)
    80004902:	ec56                	sd	s5,24(sp)
    80004904:	e85a                	sd	s6,16(sp)
    80004906:	e45e                	sd	s7,8(sp)
    80004908:	e062                	sd	s8,0(sp)
    8000490a:	0880                	addi	s0,sp,80
    8000490c:	892a                	mv	s2,a0
    8000490e:	8b2e                	mv	s6,a1
    80004910:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004912:	411c                	lw	a5,0(a0)
    80004914:	4705                	li	a4,1
    80004916:	02e78263          	beq	a5,a4,8000493a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000491a:	470d                	li	a4,3
    8000491c:	02e78563          	beq	a5,a4,80004946 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004920:	4709                	li	a4,2
    80004922:	0ce79d63          	bne	a5,a4,800049fc <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004926:	0ac05b63          	blez	a2,800049dc <filewrite+0xf0>
    int i = 0;
    8000492a:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000492c:	6b85                	lui	s7,0x1
    8000492e:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004932:	6c05                	lui	s8,0x1
    80004934:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004938:	a851                	j	800049cc <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    8000493a:	6908                	ld	a0,16(a0)
    8000493c:	00000097          	auipc	ra,0x0
    80004940:	22a080e7          	jalr	554(ra) # 80004b66 <pipewrite>
    80004944:	a045                	j	800049e4 <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004946:	02451783          	lh	a5,36(a0)
    8000494a:	03079693          	slli	a3,a5,0x30
    8000494e:	92c1                	srli	a3,a3,0x30
    80004950:	4725                	li	a4,9
    80004952:	0ad76f63          	bltu	a4,a3,80004a10 <filewrite+0x124>
    80004956:	0792                	slli	a5,a5,0x4
    80004958:	0001d717          	auipc	a4,0x1d
    8000495c:	c9070713          	addi	a4,a4,-880 # 800215e8 <devsw>
    80004960:	97ba                	add	a5,a5,a4
    80004962:	679c                	ld	a5,8(a5)
    80004964:	cbc5                	beqz	a5,80004a14 <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    80004966:	4505                	li	a0,1
    80004968:	9782                	jalr	a5
    8000496a:	a8ad                	j	800049e4 <filewrite+0xf8>
      if(n1 > max)
    8000496c:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004970:	00000097          	auipc	ra,0x0
    80004974:	8bc080e7          	jalr	-1860(ra) # 8000422c <begin_op>
      ilock(f->ip);
    80004978:	01893503          	ld	a0,24(s2)
    8000497c:	fffff097          	auipc	ra,0xfffff
    80004980:	f0a080e7          	jalr	-246(ra) # 80003886 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004984:	8756                	mv	a4,s5
    80004986:	02092683          	lw	a3,32(s2)
    8000498a:	01698633          	add	a2,s3,s6
    8000498e:	4585                	li	a1,1
    80004990:	01893503          	ld	a0,24(s2)
    80004994:	fffff097          	auipc	ra,0xfffff
    80004998:	29e080e7          	jalr	670(ra) # 80003c32 <writei>
    8000499c:	84aa                	mv	s1,a0
    8000499e:	00a05763          	blez	a0,800049ac <filewrite+0xc0>
        f->off += r;
    800049a2:	02092783          	lw	a5,32(s2)
    800049a6:	9fa9                	addw	a5,a5,a0
    800049a8:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800049ac:	01893503          	ld	a0,24(s2)
    800049b0:	fffff097          	auipc	ra,0xfffff
    800049b4:	f98080e7          	jalr	-104(ra) # 80003948 <iunlock>
      end_op();
    800049b8:	00000097          	auipc	ra,0x0
    800049bc:	8ee080e7          	jalr	-1810(ra) # 800042a6 <end_op>

      if(r != n1){
    800049c0:	009a9f63          	bne	s5,s1,800049de <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    800049c4:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800049c8:	0149db63          	bge	s3,s4,800049de <filewrite+0xf2>
      int n1 = n - i;
    800049cc:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800049d0:	0004879b          	sext.w	a5,s1
    800049d4:	f8fbdce3          	bge	s7,a5,8000496c <filewrite+0x80>
    800049d8:	84e2                	mv	s1,s8
    800049da:	bf49                	j	8000496c <filewrite+0x80>
    int i = 0;
    800049dc:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800049de:	033a1d63          	bne	s4,s3,80004a18 <filewrite+0x12c>
    800049e2:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    800049e4:	60a6                	ld	ra,72(sp)
    800049e6:	6406                	ld	s0,64(sp)
    800049e8:	74e2                	ld	s1,56(sp)
    800049ea:	7942                	ld	s2,48(sp)
    800049ec:	79a2                	ld	s3,40(sp)
    800049ee:	7a02                	ld	s4,32(sp)
    800049f0:	6ae2                	ld	s5,24(sp)
    800049f2:	6b42                	ld	s6,16(sp)
    800049f4:	6ba2                	ld	s7,8(sp)
    800049f6:	6c02                	ld	s8,0(sp)
    800049f8:	6161                	addi	sp,sp,80
    800049fa:	8082                	ret
    panic("filewrite");
    800049fc:	00004517          	auipc	a0,0x4
    80004a00:	f0450513          	addi	a0,a0,-252 # 80008900 <syscall_names+0x280>
    80004a04:	ffffc097          	auipc	ra,0xffffc
    80004a08:	b38080e7          	jalr	-1224(ra) # 8000053c <panic>
    return -1;
    80004a0c:	557d                	li	a0,-1
}
    80004a0e:	8082                	ret
      return -1;
    80004a10:	557d                	li	a0,-1
    80004a12:	bfc9                	j	800049e4 <filewrite+0xf8>
    80004a14:	557d                	li	a0,-1
    80004a16:	b7f9                	j	800049e4 <filewrite+0xf8>
    ret = (i == n ? n : -1);
    80004a18:	557d                	li	a0,-1
    80004a1a:	b7e9                	j	800049e4 <filewrite+0xf8>

0000000080004a1c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004a1c:	7179                	addi	sp,sp,-48
    80004a1e:	f406                	sd	ra,40(sp)
    80004a20:	f022                	sd	s0,32(sp)
    80004a22:	ec26                	sd	s1,24(sp)
    80004a24:	e84a                	sd	s2,16(sp)
    80004a26:	e44e                	sd	s3,8(sp)
    80004a28:	e052                	sd	s4,0(sp)
    80004a2a:	1800                	addi	s0,sp,48
    80004a2c:	84aa                	mv	s1,a0
    80004a2e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004a30:	0005b023          	sd	zero,0(a1)
    80004a34:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004a38:	00000097          	auipc	ra,0x0
    80004a3c:	bfc080e7          	jalr	-1028(ra) # 80004634 <filealloc>
    80004a40:	e088                	sd	a0,0(s1)
    80004a42:	c551                	beqz	a0,80004ace <pipealloc+0xb2>
    80004a44:	00000097          	auipc	ra,0x0
    80004a48:	bf0080e7          	jalr	-1040(ra) # 80004634 <filealloc>
    80004a4c:	00aa3023          	sd	a0,0(s4)
    80004a50:	c92d                	beqz	a0,80004ac2 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004a52:	ffffc097          	auipc	ra,0xffffc
    80004a56:	090080e7          	jalr	144(ra) # 80000ae2 <kalloc>
    80004a5a:	892a                	mv	s2,a0
    80004a5c:	c125                	beqz	a0,80004abc <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004a5e:	4985                	li	s3,1
    80004a60:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004a64:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004a68:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004a6c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004a70:	00004597          	auipc	a1,0x4
    80004a74:	a1858593          	addi	a1,a1,-1512 # 80008488 <states.0+0x1c0>
    80004a78:	ffffc097          	auipc	ra,0xffffc
    80004a7c:	0ca080e7          	jalr	202(ra) # 80000b42 <initlock>
  (*f0)->type = FD_PIPE;
    80004a80:	609c                	ld	a5,0(s1)
    80004a82:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004a86:	609c                	ld	a5,0(s1)
    80004a88:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004a8c:	609c                	ld	a5,0(s1)
    80004a8e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004a92:	609c                	ld	a5,0(s1)
    80004a94:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004a98:	000a3783          	ld	a5,0(s4)
    80004a9c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004aa0:	000a3783          	ld	a5,0(s4)
    80004aa4:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004aa8:	000a3783          	ld	a5,0(s4)
    80004aac:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004ab0:	000a3783          	ld	a5,0(s4)
    80004ab4:	0127b823          	sd	s2,16(a5)
  return 0;
    80004ab8:	4501                	li	a0,0
    80004aba:	a025                	j	80004ae2 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004abc:	6088                	ld	a0,0(s1)
    80004abe:	e501                	bnez	a0,80004ac6 <pipealloc+0xaa>
    80004ac0:	a039                	j	80004ace <pipealloc+0xb2>
    80004ac2:	6088                	ld	a0,0(s1)
    80004ac4:	c51d                	beqz	a0,80004af2 <pipealloc+0xd6>
    fileclose(*f0);
    80004ac6:	00000097          	auipc	ra,0x0
    80004aca:	c2a080e7          	jalr	-982(ra) # 800046f0 <fileclose>
  if(*f1)
    80004ace:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004ad2:	557d                	li	a0,-1
  if(*f1)
    80004ad4:	c799                	beqz	a5,80004ae2 <pipealloc+0xc6>
    fileclose(*f1);
    80004ad6:	853e                	mv	a0,a5
    80004ad8:	00000097          	auipc	ra,0x0
    80004adc:	c18080e7          	jalr	-1000(ra) # 800046f0 <fileclose>
  return -1;
    80004ae0:	557d                	li	a0,-1
}
    80004ae2:	70a2                	ld	ra,40(sp)
    80004ae4:	7402                	ld	s0,32(sp)
    80004ae6:	64e2                	ld	s1,24(sp)
    80004ae8:	6942                	ld	s2,16(sp)
    80004aea:	69a2                	ld	s3,8(sp)
    80004aec:	6a02                	ld	s4,0(sp)
    80004aee:	6145                	addi	sp,sp,48
    80004af0:	8082                	ret
  return -1;
    80004af2:	557d                	li	a0,-1
    80004af4:	b7fd                	j	80004ae2 <pipealloc+0xc6>

0000000080004af6 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004af6:	1101                	addi	sp,sp,-32
    80004af8:	ec06                	sd	ra,24(sp)
    80004afa:	e822                	sd	s0,16(sp)
    80004afc:	e426                	sd	s1,8(sp)
    80004afe:	e04a                	sd	s2,0(sp)
    80004b00:	1000                	addi	s0,sp,32
    80004b02:	84aa                	mv	s1,a0
    80004b04:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b06:	ffffc097          	auipc	ra,0xffffc
    80004b0a:	0cc080e7          	jalr	204(ra) # 80000bd2 <acquire>
  if(writable){
    80004b0e:	02090d63          	beqz	s2,80004b48 <pipeclose+0x52>
    pi->writeopen = 0;
    80004b12:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004b16:	21848513          	addi	a0,s1,536
    80004b1a:	ffffd097          	auipc	ra,0xffffd
    80004b1e:	5b8080e7          	jalr	1464(ra) # 800020d2 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004b22:	2204b783          	ld	a5,544(s1)
    80004b26:	eb95                	bnez	a5,80004b5a <pipeclose+0x64>
    release(&pi->lock);
    80004b28:	8526                	mv	a0,s1
    80004b2a:	ffffc097          	auipc	ra,0xffffc
    80004b2e:	15c080e7          	jalr	348(ra) # 80000c86 <release>
    kfree((char*)pi);
    80004b32:	8526                	mv	a0,s1
    80004b34:	ffffc097          	auipc	ra,0xffffc
    80004b38:	eb0080e7          	jalr	-336(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    80004b3c:	60e2                	ld	ra,24(sp)
    80004b3e:	6442                	ld	s0,16(sp)
    80004b40:	64a2                	ld	s1,8(sp)
    80004b42:	6902                	ld	s2,0(sp)
    80004b44:	6105                	addi	sp,sp,32
    80004b46:	8082                	ret
    pi->readopen = 0;
    80004b48:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004b4c:	21c48513          	addi	a0,s1,540
    80004b50:	ffffd097          	auipc	ra,0xffffd
    80004b54:	582080e7          	jalr	1410(ra) # 800020d2 <wakeup>
    80004b58:	b7e9                	j	80004b22 <pipeclose+0x2c>
    release(&pi->lock);
    80004b5a:	8526                	mv	a0,s1
    80004b5c:	ffffc097          	auipc	ra,0xffffc
    80004b60:	12a080e7          	jalr	298(ra) # 80000c86 <release>
}
    80004b64:	bfe1                	j	80004b3c <pipeclose+0x46>

0000000080004b66 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004b66:	711d                	addi	sp,sp,-96
    80004b68:	ec86                	sd	ra,88(sp)
    80004b6a:	e8a2                	sd	s0,80(sp)
    80004b6c:	e4a6                	sd	s1,72(sp)
    80004b6e:	e0ca                	sd	s2,64(sp)
    80004b70:	fc4e                	sd	s3,56(sp)
    80004b72:	f852                	sd	s4,48(sp)
    80004b74:	f456                	sd	s5,40(sp)
    80004b76:	f05a                	sd	s6,32(sp)
    80004b78:	ec5e                	sd	s7,24(sp)
    80004b7a:	e862                	sd	s8,16(sp)
    80004b7c:	1080                	addi	s0,sp,96
    80004b7e:	84aa                	mv	s1,a0
    80004b80:	8aae                	mv	s5,a1
    80004b82:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004b84:	ffffd097          	auipc	ra,0xffffd
    80004b88:	e22080e7          	jalr	-478(ra) # 800019a6 <myproc>
    80004b8c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004b8e:	8526                	mv	a0,s1
    80004b90:	ffffc097          	auipc	ra,0xffffc
    80004b94:	042080e7          	jalr	66(ra) # 80000bd2 <acquire>
  while(i < n){
    80004b98:	0b405663          	blez	s4,80004c44 <pipewrite+0xde>
  int i = 0;
    80004b9c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b9e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004ba0:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004ba4:	21c48b93          	addi	s7,s1,540
    80004ba8:	a089                	j	80004bea <pipewrite+0x84>
      release(&pi->lock);
    80004baa:	8526                	mv	a0,s1
    80004bac:	ffffc097          	auipc	ra,0xffffc
    80004bb0:	0da080e7          	jalr	218(ra) # 80000c86 <release>
      return -1;
    80004bb4:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004bb6:	854a                	mv	a0,s2
    80004bb8:	60e6                	ld	ra,88(sp)
    80004bba:	6446                	ld	s0,80(sp)
    80004bbc:	64a6                	ld	s1,72(sp)
    80004bbe:	6906                	ld	s2,64(sp)
    80004bc0:	79e2                	ld	s3,56(sp)
    80004bc2:	7a42                	ld	s4,48(sp)
    80004bc4:	7aa2                	ld	s5,40(sp)
    80004bc6:	7b02                	ld	s6,32(sp)
    80004bc8:	6be2                	ld	s7,24(sp)
    80004bca:	6c42                	ld	s8,16(sp)
    80004bcc:	6125                	addi	sp,sp,96
    80004bce:	8082                	ret
      wakeup(&pi->nread);
    80004bd0:	8562                	mv	a0,s8
    80004bd2:	ffffd097          	auipc	ra,0xffffd
    80004bd6:	500080e7          	jalr	1280(ra) # 800020d2 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004bda:	85a6                	mv	a1,s1
    80004bdc:	855e                	mv	a0,s7
    80004bde:	ffffd097          	auipc	ra,0xffffd
    80004be2:	490080e7          	jalr	1168(ra) # 8000206e <sleep>
  while(i < n){
    80004be6:	07495063          	bge	s2,s4,80004c46 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004bea:	2204a783          	lw	a5,544(s1)
    80004bee:	dfd5                	beqz	a5,80004baa <pipewrite+0x44>
    80004bf0:	854e                	mv	a0,s3
    80004bf2:	ffffd097          	auipc	ra,0xffffd
    80004bf6:	724080e7          	jalr	1828(ra) # 80002316 <killed>
    80004bfa:	f945                	bnez	a0,80004baa <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004bfc:	2184a783          	lw	a5,536(s1)
    80004c00:	21c4a703          	lw	a4,540(s1)
    80004c04:	2007879b          	addiw	a5,a5,512
    80004c08:	fcf704e3          	beq	a4,a5,80004bd0 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c0c:	4685                	li	a3,1
    80004c0e:	01590633          	add	a2,s2,s5
    80004c12:	faf40593          	addi	a1,s0,-81
    80004c16:	0509b503          	ld	a0,80(s3)
    80004c1a:	ffffd097          	auipc	ra,0xffffd
    80004c1e:	ad8080e7          	jalr	-1320(ra) # 800016f2 <copyin>
    80004c22:	03650263          	beq	a0,s6,80004c46 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004c26:	21c4a783          	lw	a5,540(s1)
    80004c2a:	0017871b          	addiw	a4,a5,1
    80004c2e:	20e4ae23          	sw	a4,540(s1)
    80004c32:	1ff7f793          	andi	a5,a5,511
    80004c36:	97a6                	add	a5,a5,s1
    80004c38:	faf44703          	lbu	a4,-81(s0)
    80004c3c:	00e78c23          	sb	a4,24(a5)
      i++;
    80004c40:	2905                	addiw	s2,s2,1
    80004c42:	b755                	j	80004be6 <pipewrite+0x80>
  int i = 0;
    80004c44:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004c46:	21848513          	addi	a0,s1,536
    80004c4a:	ffffd097          	auipc	ra,0xffffd
    80004c4e:	488080e7          	jalr	1160(ra) # 800020d2 <wakeup>
  release(&pi->lock);
    80004c52:	8526                	mv	a0,s1
    80004c54:	ffffc097          	auipc	ra,0xffffc
    80004c58:	032080e7          	jalr	50(ra) # 80000c86 <release>
  return i;
    80004c5c:	bfa9                	j	80004bb6 <pipewrite+0x50>

0000000080004c5e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004c5e:	715d                	addi	sp,sp,-80
    80004c60:	e486                	sd	ra,72(sp)
    80004c62:	e0a2                	sd	s0,64(sp)
    80004c64:	fc26                	sd	s1,56(sp)
    80004c66:	f84a                	sd	s2,48(sp)
    80004c68:	f44e                	sd	s3,40(sp)
    80004c6a:	f052                	sd	s4,32(sp)
    80004c6c:	ec56                	sd	s5,24(sp)
    80004c6e:	e85a                	sd	s6,16(sp)
    80004c70:	0880                	addi	s0,sp,80
    80004c72:	84aa                	mv	s1,a0
    80004c74:	892e                	mv	s2,a1
    80004c76:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004c78:	ffffd097          	auipc	ra,0xffffd
    80004c7c:	d2e080e7          	jalr	-722(ra) # 800019a6 <myproc>
    80004c80:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004c82:	8526                	mv	a0,s1
    80004c84:	ffffc097          	auipc	ra,0xffffc
    80004c88:	f4e080e7          	jalr	-178(ra) # 80000bd2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c8c:	2184a703          	lw	a4,536(s1)
    80004c90:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c94:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c98:	02f71763          	bne	a4,a5,80004cc6 <piperead+0x68>
    80004c9c:	2244a783          	lw	a5,548(s1)
    80004ca0:	c39d                	beqz	a5,80004cc6 <piperead+0x68>
    if(killed(pr)){
    80004ca2:	8552                	mv	a0,s4
    80004ca4:	ffffd097          	auipc	ra,0xffffd
    80004ca8:	672080e7          	jalr	1650(ra) # 80002316 <killed>
    80004cac:	e949                	bnez	a0,80004d3e <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004cae:	85a6                	mv	a1,s1
    80004cb0:	854e                	mv	a0,s3
    80004cb2:	ffffd097          	auipc	ra,0xffffd
    80004cb6:	3bc080e7          	jalr	956(ra) # 8000206e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004cba:	2184a703          	lw	a4,536(s1)
    80004cbe:	21c4a783          	lw	a5,540(s1)
    80004cc2:	fcf70de3          	beq	a4,a5,80004c9c <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004cc6:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004cc8:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004cca:	05505463          	blez	s5,80004d12 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004cce:	2184a783          	lw	a5,536(s1)
    80004cd2:	21c4a703          	lw	a4,540(s1)
    80004cd6:	02f70e63          	beq	a4,a5,80004d12 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004cda:	0017871b          	addiw	a4,a5,1
    80004cde:	20e4ac23          	sw	a4,536(s1)
    80004ce2:	1ff7f793          	andi	a5,a5,511
    80004ce6:	97a6                	add	a5,a5,s1
    80004ce8:	0187c783          	lbu	a5,24(a5)
    80004cec:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004cf0:	4685                	li	a3,1
    80004cf2:	fbf40613          	addi	a2,s0,-65
    80004cf6:	85ca                	mv	a1,s2
    80004cf8:	050a3503          	ld	a0,80(s4)
    80004cfc:	ffffd097          	auipc	ra,0xffffd
    80004d00:	96a080e7          	jalr	-1686(ra) # 80001666 <copyout>
    80004d04:	01650763          	beq	a0,s6,80004d12 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d08:	2985                	addiw	s3,s3,1
    80004d0a:	0905                	addi	s2,s2,1
    80004d0c:	fd3a91e3          	bne	s5,s3,80004cce <piperead+0x70>
    80004d10:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004d12:	21c48513          	addi	a0,s1,540
    80004d16:	ffffd097          	auipc	ra,0xffffd
    80004d1a:	3bc080e7          	jalr	956(ra) # 800020d2 <wakeup>
  release(&pi->lock);
    80004d1e:	8526                	mv	a0,s1
    80004d20:	ffffc097          	auipc	ra,0xffffc
    80004d24:	f66080e7          	jalr	-154(ra) # 80000c86 <release>
  return i;
}
    80004d28:	854e                	mv	a0,s3
    80004d2a:	60a6                	ld	ra,72(sp)
    80004d2c:	6406                	ld	s0,64(sp)
    80004d2e:	74e2                	ld	s1,56(sp)
    80004d30:	7942                	ld	s2,48(sp)
    80004d32:	79a2                	ld	s3,40(sp)
    80004d34:	7a02                	ld	s4,32(sp)
    80004d36:	6ae2                	ld	s5,24(sp)
    80004d38:	6b42                	ld	s6,16(sp)
    80004d3a:	6161                	addi	sp,sp,80
    80004d3c:	8082                	ret
      release(&pi->lock);
    80004d3e:	8526                	mv	a0,s1
    80004d40:	ffffc097          	auipc	ra,0xffffc
    80004d44:	f46080e7          	jalr	-186(ra) # 80000c86 <release>
      return -1;
    80004d48:	59fd                	li	s3,-1
    80004d4a:	bff9                	j	80004d28 <piperead+0xca>

0000000080004d4c <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004d4c:	1141                	addi	sp,sp,-16
    80004d4e:	e422                	sd	s0,8(sp)
    80004d50:	0800                	addi	s0,sp,16
    80004d52:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004d54:	8905                	andi	a0,a0,1
    80004d56:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004d58:	8b89                	andi	a5,a5,2
    80004d5a:	c399                	beqz	a5,80004d60 <flags2perm+0x14>
      perm |= PTE_W;
    80004d5c:	00456513          	ori	a0,a0,4
    return perm;
}
    80004d60:	6422                	ld	s0,8(sp)
    80004d62:	0141                	addi	sp,sp,16
    80004d64:	8082                	ret

0000000080004d66 <exec>:

int
exec(char *path, char **argv)
{
    80004d66:	df010113          	addi	sp,sp,-528
    80004d6a:	20113423          	sd	ra,520(sp)
    80004d6e:	20813023          	sd	s0,512(sp)
    80004d72:	ffa6                	sd	s1,504(sp)
    80004d74:	fbca                	sd	s2,496(sp)
    80004d76:	f7ce                	sd	s3,488(sp)
    80004d78:	f3d2                	sd	s4,480(sp)
    80004d7a:	efd6                	sd	s5,472(sp)
    80004d7c:	ebda                	sd	s6,464(sp)
    80004d7e:	e7de                	sd	s7,456(sp)
    80004d80:	e3e2                	sd	s8,448(sp)
    80004d82:	ff66                	sd	s9,440(sp)
    80004d84:	fb6a                	sd	s10,432(sp)
    80004d86:	f76e                	sd	s11,424(sp)
    80004d88:	0c00                	addi	s0,sp,528
    80004d8a:	892a                	mv	s2,a0
    80004d8c:	dea43c23          	sd	a0,-520(s0)
    80004d90:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004d94:	ffffd097          	auipc	ra,0xffffd
    80004d98:	c12080e7          	jalr	-1006(ra) # 800019a6 <myproc>
    80004d9c:	84aa                	mv	s1,a0

  begin_op();
    80004d9e:	fffff097          	auipc	ra,0xfffff
    80004da2:	48e080e7          	jalr	1166(ra) # 8000422c <begin_op>

  if((ip = namei(path)) == 0){
    80004da6:	854a                	mv	a0,s2
    80004da8:	fffff097          	auipc	ra,0xfffff
    80004dac:	284080e7          	jalr	644(ra) # 8000402c <namei>
    80004db0:	c92d                	beqz	a0,80004e22 <exec+0xbc>
    80004db2:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004db4:	fffff097          	auipc	ra,0xfffff
    80004db8:	ad2080e7          	jalr	-1326(ra) # 80003886 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004dbc:	04000713          	li	a4,64
    80004dc0:	4681                	li	a3,0
    80004dc2:	e5040613          	addi	a2,s0,-432
    80004dc6:	4581                	li	a1,0
    80004dc8:	8552                	mv	a0,s4
    80004dca:	fffff097          	auipc	ra,0xfffff
    80004dce:	d70080e7          	jalr	-656(ra) # 80003b3a <readi>
    80004dd2:	04000793          	li	a5,64
    80004dd6:	00f51a63          	bne	a0,a5,80004dea <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004dda:	e5042703          	lw	a4,-432(s0)
    80004dde:	464c47b7          	lui	a5,0x464c4
    80004de2:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004de6:	04f70463          	beq	a4,a5,80004e2e <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004dea:	8552                	mv	a0,s4
    80004dec:	fffff097          	auipc	ra,0xfffff
    80004df0:	cfc080e7          	jalr	-772(ra) # 80003ae8 <iunlockput>
    end_op();
    80004df4:	fffff097          	auipc	ra,0xfffff
    80004df8:	4b2080e7          	jalr	1202(ra) # 800042a6 <end_op>
  }
  return -1;
    80004dfc:	557d                	li	a0,-1
}
    80004dfe:	20813083          	ld	ra,520(sp)
    80004e02:	20013403          	ld	s0,512(sp)
    80004e06:	74fe                	ld	s1,504(sp)
    80004e08:	795e                	ld	s2,496(sp)
    80004e0a:	79be                	ld	s3,488(sp)
    80004e0c:	7a1e                	ld	s4,480(sp)
    80004e0e:	6afe                	ld	s5,472(sp)
    80004e10:	6b5e                	ld	s6,464(sp)
    80004e12:	6bbe                	ld	s7,456(sp)
    80004e14:	6c1e                	ld	s8,448(sp)
    80004e16:	7cfa                	ld	s9,440(sp)
    80004e18:	7d5a                	ld	s10,432(sp)
    80004e1a:	7dba                	ld	s11,424(sp)
    80004e1c:	21010113          	addi	sp,sp,528
    80004e20:	8082                	ret
    end_op();
    80004e22:	fffff097          	auipc	ra,0xfffff
    80004e26:	484080e7          	jalr	1156(ra) # 800042a6 <end_op>
    return -1;
    80004e2a:	557d                	li	a0,-1
    80004e2c:	bfc9                	j	80004dfe <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004e2e:	8526                	mv	a0,s1
    80004e30:	ffffd097          	auipc	ra,0xffffd
    80004e34:	c3a080e7          	jalr	-966(ra) # 80001a6a <proc_pagetable>
    80004e38:	8b2a                	mv	s6,a0
    80004e3a:	d945                	beqz	a0,80004dea <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e3c:	e7042d03          	lw	s10,-400(s0)
    80004e40:	e8845783          	lhu	a5,-376(s0)
    80004e44:	10078463          	beqz	a5,80004f4c <exec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e48:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e4a:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004e4c:	6c85                	lui	s9,0x1
    80004e4e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004e52:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004e56:	6a85                	lui	s5,0x1
    80004e58:	a0b5                	j	80004ec4 <exec+0x15e>
      panic("loadseg: address should exist");
    80004e5a:	00004517          	auipc	a0,0x4
    80004e5e:	ab650513          	addi	a0,a0,-1354 # 80008910 <syscall_names+0x290>
    80004e62:	ffffb097          	auipc	ra,0xffffb
    80004e66:	6da080e7          	jalr	1754(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    80004e6a:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004e6c:	8726                	mv	a4,s1
    80004e6e:	012c06bb          	addw	a3,s8,s2
    80004e72:	4581                	li	a1,0
    80004e74:	8552                	mv	a0,s4
    80004e76:	fffff097          	auipc	ra,0xfffff
    80004e7a:	cc4080e7          	jalr	-828(ra) # 80003b3a <readi>
    80004e7e:	2501                	sext.w	a0,a0
    80004e80:	24a49863          	bne	s1,a0,800050d0 <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    80004e84:	012a893b          	addw	s2,s5,s2
    80004e88:	03397563          	bgeu	s2,s3,80004eb2 <exec+0x14c>
    pa = walkaddr(pagetable, va + i);
    80004e8c:	02091593          	slli	a1,s2,0x20
    80004e90:	9181                	srli	a1,a1,0x20
    80004e92:	95de                	add	a1,a1,s7
    80004e94:	855a                	mv	a0,s6
    80004e96:	ffffc097          	auipc	ra,0xffffc
    80004e9a:	1c0080e7          	jalr	448(ra) # 80001056 <walkaddr>
    80004e9e:	862a                	mv	a2,a0
    if(pa == 0)
    80004ea0:	dd4d                	beqz	a0,80004e5a <exec+0xf4>
    if(sz - i < PGSIZE)
    80004ea2:	412984bb          	subw	s1,s3,s2
    80004ea6:	0004879b          	sext.w	a5,s1
    80004eaa:	fcfcf0e3          	bgeu	s9,a5,80004e6a <exec+0x104>
    80004eae:	84d6                	mv	s1,s5
    80004eb0:	bf6d                	j	80004e6a <exec+0x104>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004eb2:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004eb6:	2d85                	addiw	s11,s11,1
    80004eb8:	038d0d1b          	addiw	s10,s10,56
    80004ebc:	e8845783          	lhu	a5,-376(s0)
    80004ec0:	08fdd763          	bge	s11,a5,80004f4e <exec+0x1e8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004ec4:	2d01                	sext.w	s10,s10
    80004ec6:	03800713          	li	a4,56
    80004eca:	86ea                	mv	a3,s10
    80004ecc:	e1840613          	addi	a2,s0,-488
    80004ed0:	4581                	li	a1,0
    80004ed2:	8552                	mv	a0,s4
    80004ed4:	fffff097          	auipc	ra,0xfffff
    80004ed8:	c66080e7          	jalr	-922(ra) # 80003b3a <readi>
    80004edc:	03800793          	li	a5,56
    80004ee0:	1ef51663          	bne	a0,a5,800050cc <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    80004ee4:	e1842783          	lw	a5,-488(s0)
    80004ee8:	4705                	li	a4,1
    80004eea:	fce796e3          	bne	a5,a4,80004eb6 <exec+0x150>
    if(ph.memsz < ph.filesz)
    80004eee:	e4043483          	ld	s1,-448(s0)
    80004ef2:	e3843783          	ld	a5,-456(s0)
    80004ef6:	1ef4e863          	bltu	s1,a5,800050e6 <exec+0x380>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004efa:	e2843783          	ld	a5,-472(s0)
    80004efe:	94be                	add	s1,s1,a5
    80004f00:	1ef4e663          	bltu	s1,a5,800050ec <exec+0x386>
    if(ph.vaddr % PGSIZE != 0)
    80004f04:	df043703          	ld	a4,-528(s0)
    80004f08:	8ff9                	and	a5,a5,a4
    80004f0a:	1e079463          	bnez	a5,800050f2 <exec+0x38c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004f0e:	e1c42503          	lw	a0,-484(s0)
    80004f12:	00000097          	auipc	ra,0x0
    80004f16:	e3a080e7          	jalr	-454(ra) # 80004d4c <flags2perm>
    80004f1a:	86aa                	mv	a3,a0
    80004f1c:	8626                	mv	a2,s1
    80004f1e:	85ca                	mv	a1,s2
    80004f20:	855a                	mv	a0,s6
    80004f22:	ffffc097          	auipc	ra,0xffffc
    80004f26:	4e8080e7          	jalr	1256(ra) # 8000140a <uvmalloc>
    80004f2a:	e0a43423          	sd	a0,-504(s0)
    80004f2e:	1c050563          	beqz	a0,800050f8 <exec+0x392>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004f32:	e2843b83          	ld	s7,-472(s0)
    80004f36:	e2042c03          	lw	s8,-480(s0)
    80004f3a:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004f3e:	00098463          	beqz	s3,80004f46 <exec+0x1e0>
    80004f42:	4901                	li	s2,0
    80004f44:	b7a1                	j	80004e8c <exec+0x126>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004f46:	e0843903          	ld	s2,-504(s0)
    80004f4a:	b7b5                	j	80004eb6 <exec+0x150>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f4c:	4901                	li	s2,0
  iunlockput(ip);
    80004f4e:	8552                	mv	a0,s4
    80004f50:	fffff097          	auipc	ra,0xfffff
    80004f54:	b98080e7          	jalr	-1128(ra) # 80003ae8 <iunlockput>
  end_op();
    80004f58:	fffff097          	auipc	ra,0xfffff
    80004f5c:	34e080e7          	jalr	846(ra) # 800042a6 <end_op>
  p = myproc();
    80004f60:	ffffd097          	auipc	ra,0xffffd
    80004f64:	a46080e7          	jalr	-1466(ra) # 800019a6 <myproc>
    80004f68:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004f6a:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004f6e:	6985                	lui	s3,0x1
    80004f70:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004f72:	99ca                	add	s3,s3,s2
    80004f74:	77fd                	lui	a5,0xfffff
    80004f76:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004f7a:	4691                	li	a3,4
    80004f7c:	6609                	lui	a2,0x2
    80004f7e:	964e                	add	a2,a2,s3
    80004f80:	85ce                	mv	a1,s3
    80004f82:	855a                	mv	a0,s6
    80004f84:	ffffc097          	auipc	ra,0xffffc
    80004f88:	486080e7          	jalr	1158(ra) # 8000140a <uvmalloc>
    80004f8c:	892a                	mv	s2,a0
    80004f8e:	e0a43423          	sd	a0,-504(s0)
    80004f92:	e509                	bnez	a0,80004f9c <exec+0x236>
  if(pagetable)
    80004f94:	e1343423          	sd	s3,-504(s0)
    80004f98:	4a01                	li	s4,0
    80004f9a:	aa1d                	j	800050d0 <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004f9c:	75f9                	lui	a1,0xffffe
    80004f9e:	95aa                	add	a1,a1,a0
    80004fa0:	855a                	mv	a0,s6
    80004fa2:	ffffc097          	auipc	ra,0xffffc
    80004fa6:	692080e7          	jalr	1682(ra) # 80001634 <uvmclear>
  stackbase = sp - PGSIZE;
    80004faa:	7bfd                	lui	s7,0xfffff
    80004fac:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004fae:	e0043783          	ld	a5,-512(s0)
    80004fb2:	6388                	ld	a0,0(a5)
    80004fb4:	c52d                	beqz	a0,8000501e <exec+0x2b8>
    80004fb6:	e9040993          	addi	s3,s0,-368
    80004fba:	f9040c13          	addi	s8,s0,-112
    80004fbe:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004fc0:	ffffc097          	auipc	ra,0xffffc
    80004fc4:	e88080e7          	jalr	-376(ra) # 80000e48 <strlen>
    80004fc8:	0015079b          	addiw	a5,a0,1
    80004fcc:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004fd0:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004fd4:	13796563          	bltu	s2,s7,800050fe <exec+0x398>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004fd8:	e0043d03          	ld	s10,-512(s0)
    80004fdc:	000d3a03          	ld	s4,0(s10)
    80004fe0:	8552                	mv	a0,s4
    80004fe2:	ffffc097          	auipc	ra,0xffffc
    80004fe6:	e66080e7          	jalr	-410(ra) # 80000e48 <strlen>
    80004fea:	0015069b          	addiw	a3,a0,1
    80004fee:	8652                	mv	a2,s4
    80004ff0:	85ca                	mv	a1,s2
    80004ff2:	855a                	mv	a0,s6
    80004ff4:	ffffc097          	auipc	ra,0xffffc
    80004ff8:	672080e7          	jalr	1650(ra) # 80001666 <copyout>
    80004ffc:	10054363          	bltz	a0,80005102 <exec+0x39c>
    ustack[argc] = sp;
    80005000:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005004:	0485                	addi	s1,s1,1
    80005006:	008d0793          	addi	a5,s10,8
    8000500a:	e0f43023          	sd	a5,-512(s0)
    8000500e:	008d3503          	ld	a0,8(s10)
    80005012:	c909                	beqz	a0,80005024 <exec+0x2be>
    if(argc >= MAXARG)
    80005014:	09a1                	addi	s3,s3,8
    80005016:	fb8995e3          	bne	s3,s8,80004fc0 <exec+0x25a>
  ip = 0;
    8000501a:	4a01                	li	s4,0
    8000501c:	a855                	j	800050d0 <exec+0x36a>
  sp = sz;
    8000501e:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005022:	4481                	li	s1,0
  ustack[argc] = 0;
    80005024:	00349793          	slli	a5,s1,0x3
    80005028:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdc810>
    8000502c:	97a2                	add	a5,a5,s0
    8000502e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005032:	00148693          	addi	a3,s1,1
    80005036:	068e                	slli	a3,a3,0x3
    80005038:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000503c:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80005040:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80005044:	f57968e3          	bltu	s2,s7,80004f94 <exec+0x22e>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005048:	e9040613          	addi	a2,s0,-368
    8000504c:	85ca                	mv	a1,s2
    8000504e:	855a                	mv	a0,s6
    80005050:	ffffc097          	auipc	ra,0xffffc
    80005054:	616080e7          	jalr	1558(ra) # 80001666 <copyout>
    80005058:	0a054763          	bltz	a0,80005106 <exec+0x3a0>
  p->trapframe->a1 = sp;
    8000505c:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80005060:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005064:	df843783          	ld	a5,-520(s0)
    80005068:	0007c703          	lbu	a4,0(a5)
    8000506c:	cf11                	beqz	a4,80005088 <exec+0x322>
    8000506e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005070:	02f00693          	li	a3,47
    80005074:	a039                	j	80005082 <exec+0x31c>
      last = s+1;
    80005076:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000507a:	0785                	addi	a5,a5,1
    8000507c:	fff7c703          	lbu	a4,-1(a5)
    80005080:	c701                	beqz	a4,80005088 <exec+0x322>
    if(*s == '/')
    80005082:	fed71ce3          	bne	a4,a3,8000507a <exec+0x314>
    80005086:	bfc5                	j	80005076 <exec+0x310>
  safestrcpy(p->name, last, sizeof(p->name));
    80005088:	4641                	li	a2,16
    8000508a:	df843583          	ld	a1,-520(s0)
    8000508e:	158a8513          	addi	a0,s5,344
    80005092:	ffffc097          	auipc	ra,0xffffc
    80005096:	d84080e7          	jalr	-636(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    8000509a:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    8000509e:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800050a2:	e0843783          	ld	a5,-504(s0)
    800050a6:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800050aa:	058ab783          	ld	a5,88(s5)
    800050ae:	e6843703          	ld	a4,-408(s0)
    800050b2:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800050b4:	058ab783          	ld	a5,88(s5)
    800050b8:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800050bc:	85e6                	mv	a1,s9
    800050be:	ffffd097          	auipc	ra,0xffffd
    800050c2:	a48080e7          	jalr	-1464(ra) # 80001b06 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800050c6:	0004851b          	sext.w	a0,s1
    800050ca:	bb15                	j	80004dfe <exec+0x98>
    800050cc:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    800050d0:	e0843583          	ld	a1,-504(s0)
    800050d4:	855a                	mv	a0,s6
    800050d6:	ffffd097          	auipc	ra,0xffffd
    800050da:	a30080e7          	jalr	-1488(ra) # 80001b06 <proc_freepagetable>
  return -1;
    800050de:	557d                	li	a0,-1
  if(ip){
    800050e0:	d00a0fe3          	beqz	s4,80004dfe <exec+0x98>
    800050e4:	b319                	j	80004dea <exec+0x84>
    800050e6:	e1243423          	sd	s2,-504(s0)
    800050ea:	b7dd                	j	800050d0 <exec+0x36a>
    800050ec:	e1243423          	sd	s2,-504(s0)
    800050f0:	b7c5                	j	800050d0 <exec+0x36a>
    800050f2:	e1243423          	sd	s2,-504(s0)
    800050f6:	bfe9                	j	800050d0 <exec+0x36a>
    800050f8:	e1243423          	sd	s2,-504(s0)
    800050fc:	bfd1                	j	800050d0 <exec+0x36a>
  ip = 0;
    800050fe:	4a01                	li	s4,0
    80005100:	bfc1                	j	800050d0 <exec+0x36a>
    80005102:	4a01                	li	s4,0
  if(pagetable)
    80005104:	b7f1                	j	800050d0 <exec+0x36a>
  sz = sz1;
    80005106:	e0843983          	ld	s3,-504(s0)
    8000510a:	b569                	j	80004f94 <exec+0x22e>

000000008000510c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000510c:	7179                	addi	sp,sp,-48
    8000510e:	f406                	sd	ra,40(sp)
    80005110:	f022                	sd	s0,32(sp)
    80005112:	ec26                	sd	s1,24(sp)
    80005114:	e84a                	sd	s2,16(sp)
    80005116:	1800                	addi	s0,sp,48
    80005118:	892e                	mv	s2,a1
    8000511a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000511c:	fdc40593          	addi	a1,s0,-36
    80005120:	ffffe097          	auipc	ra,0xffffe
    80005124:	a1a080e7          	jalr	-1510(ra) # 80002b3a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005128:	fdc42703          	lw	a4,-36(s0)
    8000512c:	47bd                	li	a5,15
    8000512e:	02e7eb63          	bltu	a5,a4,80005164 <argfd+0x58>
    80005132:	ffffd097          	auipc	ra,0xffffd
    80005136:	874080e7          	jalr	-1932(ra) # 800019a6 <myproc>
    8000513a:	fdc42703          	lw	a4,-36(s0)
    8000513e:	01a70793          	addi	a5,a4,26
    80005142:	078e                	slli	a5,a5,0x3
    80005144:	953e                	add	a0,a0,a5
    80005146:	611c                	ld	a5,0(a0)
    80005148:	c385                	beqz	a5,80005168 <argfd+0x5c>
    return -1;
  if(pfd)
    8000514a:	00090463          	beqz	s2,80005152 <argfd+0x46>
    *pfd = fd;
    8000514e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005152:	4501                	li	a0,0
  if(pf)
    80005154:	c091                	beqz	s1,80005158 <argfd+0x4c>
    *pf = f;
    80005156:	e09c                	sd	a5,0(s1)
}
    80005158:	70a2                	ld	ra,40(sp)
    8000515a:	7402                	ld	s0,32(sp)
    8000515c:	64e2                	ld	s1,24(sp)
    8000515e:	6942                	ld	s2,16(sp)
    80005160:	6145                	addi	sp,sp,48
    80005162:	8082                	ret
    return -1;
    80005164:	557d                	li	a0,-1
    80005166:	bfcd                	j	80005158 <argfd+0x4c>
    80005168:	557d                	li	a0,-1
    8000516a:	b7fd                	j	80005158 <argfd+0x4c>

000000008000516c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000516c:	1101                	addi	sp,sp,-32
    8000516e:	ec06                	sd	ra,24(sp)
    80005170:	e822                	sd	s0,16(sp)
    80005172:	e426                	sd	s1,8(sp)
    80005174:	1000                	addi	s0,sp,32
    80005176:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005178:	ffffd097          	auipc	ra,0xffffd
    8000517c:	82e080e7          	jalr	-2002(ra) # 800019a6 <myproc>
    80005180:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005182:	0d050793          	addi	a5,a0,208
    80005186:	4501                	li	a0,0
    80005188:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000518a:	6398                	ld	a4,0(a5)
    8000518c:	cb19                	beqz	a4,800051a2 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000518e:	2505                	addiw	a0,a0,1
    80005190:	07a1                	addi	a5,a5,8
    80005192:	fed51ce3          	bne	a0,a3,8000518a <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005196:	557d                	li	a0,-1
}
    80005198:	60e2                	ld	ra,24(sp)
    8000519a:	6442                	ld	s0,16(sp)
    8000519c:	64a2                	ld	s1,8(sp)
    8000519e:	6105                	addi	sp,sp,32
    800051a0:	8082                	ret
      p->ofile[fd] = f;
    800051a2:	01a50793          	addi	a5,a0,26
    800051a6:	078e                	slli	a5,a5,0x3
    800051a8:	963e                	add	a2,a2,a5
    800051aa:	e204                	sd	s1,0(a2)
      return fd;
    800051ac:	b7f5                	j	80005198 <fdalloc+0x2c>

00000000800051ae <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800051ae:	715d                	addi	sp,sp,-80
    800051b0:	e486                	sd	ra,72(sp)
    800051b2:	e0a2                	sd	s0,64(sp)
    800051b4:	fc26                	sd	s1,56(sp)
    800051b6:	f84a                	sd	s2,48(sp)
    800051b8:	f44e                	sd	s3,40(sp)
    800051ba:	f052                	sd	s4,32(sp)
    800051bc:	ec56                	sd	s5,24(sp)
    800051be:	e85a                	sd	s6,16(sp)
    800051c0:	0880                	addi	s0,sp,80
    800051c2:	8b2e                	mv	s6,a1
    800051c4:	89b2                	mv	s3,a2
    800051c6:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800051c8:	fb040593          	addi	a1,s0,-80
    800051cc:	fffff097          	auipc	ra,0xfffff
    800051d0:	e7e080e7          	jalr	-386(ra) # 8000404a <nameiparent>
    800051d4:	84aa                	mv	s1,a0
    800051d6:	14050b63          	beqz	a0,8000532c <create+0x17e>
    return 0;

  ilock(dp);
    800051da:	ffffe097          	auipc	ra,0xffffe
    800051de:	6ac080e7          	jalr	1708(ra) # 80003886 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800051e2:	4601                	li	a2,0
    800051e4:	fb040593          	addi	a1,s0,-80
    800051e8:	8526                	mv	a0,s1
    800051ea:	fffff097          	auipc	ra,0xfffff
    800051ee:	b80080e7          	jalr	-1152(ra) # 80003d6a <dirlookup>
    800051f2:	8aaa                	mv	s5,a0
    800051f4:	c921                	beqz	a0,80005244 <create+0x96>
    iunlockput(dp);
    800051f6:	8526                	mv	a0,s1
    800051f8:	fffff097          	auipc	ra,0xfffff
    800051fc:	8f0080e7          	jalr	-1808(ra) # 80003ae8 <iunlockput>
    ilock(ip);
    80005200:	8556                	mv	a0,s5
    80005202:	ffffe097          	auipc	ra,0xffffe
    80005206:	684080e7          	jalr	1668(ra) # 80003886 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000520a:	4789                	li	a5,2
    8000520c:	02fb1563          	bne	s6,a5,80005236 <create+0x88>
    80005210:	044ad783          	lhu	a5,68(s5)
    80005214:	37f9                	addiw	a5,a5,-2
    80005216:	17c2                	slli	a5,a5,0x30
    80005218:	93c1                	srli	a5,a5,0x30
    8000521a:	4705                	li	a4,1
    8000521c:	00f76d63          	bltu	a4,a5,80005236 <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005220:	8556                	mv	a0,s5
    80005222:	60a6                	ld	ra,72(sp)
    80005224:	6406                	ld	s0,64(sp)
    80005226:	74e2                	ld	s1,56(sp)
    80005228:	7942                	ld	s2,48(sp)
    8000522a:	79a2                	ld	s3,40(sp)
    8000522c:	7a02                	ld	s4,32(sp)
    8000522e:	6ae2                	ld	s5,24(sp)
    80005230:	6b42                	ld	s6,16(sp)
    80005232:	6161                	addi	sp,sp,80
    80005234:	8082                	ret
    iunlockput(ip);
    80005236:	8556                	mv	a0,s5
    80005238:	fffff097          	auipc	ra,0xfffff
    8000523c:	8b0080e7          	jalr	-1872(ra) # 80003ae8 <iunlockput>
    return 0;
    80005240:	4a81                	li	s5,0
    80005242:	bff9                	j	80005220 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005244:	85da                	mv	a1,s6
    80005246:	4088                	lw	a0,0(s1)
    80005248:	ffffe097          	auipc	ra,0xffffe
    8000524c:	4a6080e7          	jalr	1190(ra) # 800036ee <ialloc>
    80005250:	8a2a                	mv	s4,a0
    80005252:	c529                	beqz	a0,8000529c <create+0xee>
  ilock(ip);
    80005254:	ffffe097          	auipc	ra,0xffffe
    80005258:	632080e7          	jalr	1586(ra) # 80003886 <ilock>
  ip->major = major;
    8000525c:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005260:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005264:	4905                	li	s2,1
    80005266:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000526a:	8552                	mv	a0,s4
    8000526c:	ffffe097          	auipc	ra,0xffffe
    80005270:	54e080e7          	jalr	1358(ra) # 800037ba <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005274:	032b0b63          	beq	s6,s2,800052aa <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005278:	004a2603          	lw	a2,4(s4)
    8000527c:	fb040593          	addi	a1,s0,-80
    80005280:	8526                	mv	a0,s1
    80005282:	fffff097          	auipc	ra,0xfffff
    80005286:	cf8080e7          	jalr	-776(ra) # 80003f7a <dirlink>
    8000528a:	06054f63          	bltz	a0,80005308 <create+0x15a>
  iunlockput(dp);
    8000528e:	8526                	mv	a0,s1
    80005290:	fffff097          	auipc	ra,0xfffff
    80005294:	858080e7          	jalr	-1960(ra) # 80003ae8 <iunlockput>
  return ip;
    80005298:	8ad2                	mv	s5,s4
    8000529a:	b759                	j	80005220 <create+0x72>
    iunlockput(dp);
    8000529c:	8526                	mv	a0,s1
    8000529e:	fffff097          	auipc	ra,0xfffff
    800052a2:	84a080e7          	jalr	-1974(ra) # 80003ae8 <iunlockput>
    return 0;
    800052a6:	8ad2                	mv	s5,s4
    800052a8:	bfa5                	j	80005220 <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800052aa:	004a2603          	lw	a2,4(s4)
    800052ae:	00003597          	auipc	a1,0x3
    800052b2:	68258593          	addi	a1,a1,1666 # 80008930 <syscall_names+0x2b0>
    800052b6:	8552                	mv	a0,s4
    800052b8:	fffff097          	auipc	ra,0xfffff
    800052bc:	cc2080e7          	jalr	-830(ra) # 80003f7a <dirlink>
    800052c0:	04054463          	bltz	a0,80005308 <create+0x15a>
    800052c4:	40d0                	lw	a2,4(s1)
    800052c6:	00003597          	auipc	a1,0x3
    800052ca:	67258593          	addi	a1,a1,1650 # 80008938 <syscall_names+0x2b8>
    800052ce:	8552                	mv	a0,s4
    800052d0:	fffff097          	auipc	ra,0xfffff
    800052d4:	caa080e7          	jalr	-854(ra) # 80003f7a <dirlink>
    800052d8:	02054863          	bltz	a0,80005308 <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    800052dc:	004a2603          	lw	a2,4(s4)
    800052e0:	fb040593          	addi	a1,s0,-80
    800052e4:	8526                	mv	a0,s1
    800052e6:	fffff097          	auipc	ra,0xfffff
    800052ea:	c94080e7          	jalr	-876(ra) # 80003f7a <dirlink>
    800052ee:	00054d63          	bltz	a0,80005308 <create+0x15a>
    dp->nlink++;  // for ".."
    800052f2:	04a4d783          	lhu	a5,74(s1)
    800052f6:	2785                	addiw	a5,a5,1
    800052f8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800052fc:	8526                	mv	a0,s1
    800052fe:	ffffe097          	auipc	ra,0xffffe
    80005302:	4bc080e7          	jalr	1212(ra) # 800037ba <iupdate>
    80005306:	b761                	j	8000528e <create+0xe0>
  ip->nlink = 0;
    80005308:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000530c:	8552                	mv	a0,s4
    8000530e:	ffffe097          	auipc	ra,0xffffe
    80005312:	4ac080e7          	jalr	1196(ra) # 800037ba <iupdate>
  iunlockput(ip);
    80005316:	8552                	mv	a0,s4
    80005318:	ffffe097          	auipc	ra,0xffffe
    8000531c:	7d0080e7          	jalr	2000(ra) # 80003ae8 <iunlockput>
  iunlockput(dp);
    80005320:	8526                	mv	a0,s1
    80005322:	ffffe097          	auipc	ra,0xffffe
    80005326:	7c6080e7          	jalr	1990(ra) # 80003ae8 <iunlockput>
  return 0;
    8000532a:	bddd                	j	80005220 <create+0x72>
    return 0;
    8000532c:	8aaa                	mv	s5,a0
    8000532e:	bdcd                	j	80005220 <create+0x72>

0000000080005330 <sys_dup>:
{
    80005330:	7179                	addi	sp,sp,-48
    80005332:	f406                	sd	ra,40(sp)
    80005334:	f022                	sd	s0,32(sp)
    80005336:	ec26                	sd	s1,24(sp)
    80005338:	e84a                	sd	s2,16(sp)
    8000533a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000533c:	fd840613          	addi	a2,s0,-40
    80005340:	4581                	li	a1,0
    80005342:	4501                	li	a0,0
    80005344:	00000097          	auipc	ra,0x0
    80005348:	dc8080e7          	jalr	-568(ra) # 8000510c <argfd>
    return -1;
    8000534c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000534e:	02054363          	bltz	a0,80005374 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005352:	fd843903          	ld	s2,-40(s0)
    80005356:	854a                	mv	a0,s2
    80005358:	00000097          	auipc	ra,0x0
    8000535c:	e14080e7          	jalr	-492(ra) # 8000516c <fdalloc>
    80005360:	84aa                	mv	s1,a0
    return -1;
    80005362:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005364:	00054863          	bltz	a0,80005374 <sys_dup+0x44>
  filedup(f);
    80005368:	854a                	mv	a0,s2
    8000536a:	fffff097          	auipc	ra,0xfffff
    8000536e:	334080e7          	jalr	820(ra) # 8000469e <filedup>
  return fd;
    80005372:	87a6                	mv	a5,s1
}
    80005374:	853e                	mv	a0,a5
    80005376:	70a2                	ld	ra,40(sp)
    80005378:	7402                	ld	s0,32(sp)
    8000537a:	64e2                	ld	s1,24(sp)
    8000537c:	6942                	ld	s2,16(sp)
    8000537e:	6145                	addi	sp,sp,48
    80005380:	8082                	ret

0000000080005382 <sys_read>:
{
    80005382:	7179                	addi	sp,sp,-48
    80005384:	f406                	sd	ra,40(sp)
    80005386:	f022                	sd	s0,32(sp)
    80005388:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000538a:	fd840593          	addi	a1,s0,-40
    8000538e:	4505                	li	a0,1
    80005390:	ffffd097          	auipc	ra,0xffffd
    80005394:	7ca080e7          	jalr	1994(ra) # 80002b5a <argaddr>
  argint(2, &n);
    80005398:	fe440593          	addi	a1,s0,-28
    8000539c:	4509                	li	a0,2
    8000539e:	ffffd097          	auipc	ra,0xffffd
    800053a2:	79c080e7          	jalr	1948(ra) # 80002b3a <argint>
  if(argfd(0, 0, &f) < 0)
    800053a6:	fe840613          	addi	a2,s0,-24
    800053aa:	4581                	li	a1,0
    800053ac:	4501                	li	a0,0
    800053ae:	00000097          	auipc	ra,0x0
    800053b2:	d5e080e7          	jalr	-674(ra) # 8000510c <argfd>
    800053b6:	87aa                	mv	a5,a0
    return -1;
    800053b8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800053ba:	0007cc63          	bltz	a5,800053d2 <sys_read+0x50>
  return fileread(f, p, n);
    800053be:	fe442603          	lw	a2,-28(s0)
    800053c2:	fd843583          	ld	a1,-40(s0)
    800053c6:	fe843503          	ld	a0,-24(s0)
    800053ca:	fffff097          	auipc	ra,0xfffff
    800053ce:	460080e7          	jalr	1120(ra) # 8000482a <fileread>
}
    800053d2:	70a2                	ld	ra,40(sp)
    800053d4:	7402                	ld	s0,32(sp)
    800053d6:	6145                	addi	sp,sp,48
    800053d8:	8082                	ret

00000000800053da <sys_write>:
{
    800053da:	7179                	addi	sp,sp,-48
    800053dc:	f406                	sd	ra,40(sp)
    800053de:	f022                	sd	s0,32(sp)
    800053e0:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800053e2:	fd840593          	addi	a1,s0,-40
    800053e6:	4505                	li	a0,1
    800053e8:	ffffd097          	auipc	ra,0xffffd
    800053ec:	772080e7          	jalr	1906(ra) # 80002b5a <argaddr>
  argint(2, &n);
    800053f0:	fe440593          	addi	a1,s0,-28
    800053f4:	4509                	li	a0,2
    800053f6:	ffffd097          	auipc	ra,0xffffd
    800053fa:	744080e7          	jalr	1860(ra) # 80002b3a <argint>
  if(argfd(0, 0, &f) < 0)
    800053fe:	fe840613          	addi	a2,s0,-24
    80005402:	4581                	li	a1,0
    80005404:	4501                	li	a0,0
    80005406:	00000097          	auipc	ra,0x0
    8000540a:	d06080e7          	jalr	-762(ra) # 8000510c <argfd>
    8000540e:	87aa                	mv	a5,a0
    return -1;
    80005410:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005412:	0007cc63          	bltz	a5,8000542a <sys_write+0x50>
  return filewrite(f, p, n);
    80005416:	fe442603          	lw	a2,-28(s0)
    8000541a:	fd843583          	ld	a1,-40(s0)
    8000541e:	fe843503          	ld	a0,-24(s0)
    80005422:	fffff097          	auipc	ra,0xfffff
    80005426:	4ca080e7          	jalr	1226(ra) # 800048ec <filewrite>
}
    8000542a:	70a2                	ld	ra,40(sp)
    8000542c:	7402                	ld	s0,32(sp)
    8000542e:	6145                	addi	sp,sp,48
    80005430:	8082                	ret

0000000080005432 <sys_close>:
{
    80005432:	1101                	addi	sp,sp,-32
    80005434:	ec06                	sd	ra,24(sp)
    80005436:	e822                	sd	s0,16(sp)
    80005438:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000543a:	fe040613          	addi	a2,s0,-32
    8000543e:	fec40593          	addi	a1,s0,-20
    80005442:	4501                	li	a0,0
    80005444:	00000097          	auipc	ra,0x0
    80005448:	cc8080e7          	jalr	-824(ra) # 8000510c <argfd>
    return -1;
    8000544c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000544e:	02054463          	bltz	a0,80005476 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005452:	ffffc097          	auipc	ra,0xffffc
    80005456:	554080e7          	jalr	1364(ra) # 800019a6 <myproc>
    8000545a:	fec42783          	lw	a5,-20(s0)
    8000545e:	07e9                	addi	a5,a5,26
    80005460:	078e                	slli	a5,a5,0x3
    80005462:	953e                	add	a0,a0,a5
    80005464:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005468:	fe043503          	ld	a0,-32(s0)
    8000546c:	fffff097          	auipc	ra,0xfffff
    80005470:	284080e7          	jalr	644(ra) # 800046f0 <fileclose>
  return 0;
    80005474:	4781                	li	a5,0
}
    80005476:	853e                	mv	a0,a5
    80005478:	60e2                	ld	ra,24(sp)
    8000547a:	6442                	ld	s0,16(sp)
    8000547c:	6105                	addi	sp,sp,32
    8000547e:	8082                	ret

0000000080005480 <sys_fstat>:
{
    80005480:	1101                	addi	sp,sp,-32
    80005482:	ec06                	sd	ra,24(sp)
    80005484:	e822                	sd	s0,16(sp)
    80005486:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005488:	fe040593          	addi	a1,s0,-32
    8000548c:	4505                	li	a0,1
    8000548e:	ffffd097          	auipc	ra,0xffffd
    80005492:	6cc080e7          	jalr	1740(ra) # 80002b5a <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005496:	fe840613          	addi	a2,s0,-24
    8000549a:	4581                	li	a1,0
    8000549c:	4501                	li	a0,0
    8000549e:	00000097          	auipc	ra,0x0
    800054a2:	c6e080e7          	jalr	-914(ra) # 8000510c <argfd>
    800054a6:	87aa                	mv	a5,a0
    return -1;
    800054a8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800054aa:	0007ca63          	bltz	a5,800054be <sys_fstat+0x3e>
  return filestat(f, st);
    800054ae:	fe043583          	ld	a1,-32(s0)
    800054b2:	fe843503          	ld	a0,-24(s0)
    800054b6:	fffff097          	auipc	ra,0xfffff
    800054ba:	302080e7          	jalr	770(ra) # 800047b8 <filestat>
}
    800054be:	60e2                	ld	ra,24(sp)
    800054c0:	6442                	ld	s0,16(sp)
    800054c2:	6105                	addi	sp,sp,32
    800054c4:	8082                	ret

00000000800054c6 <sys_link>:
{
    800054c6:	7169                	addi	sp,sp,-304
    800054c8:	f606                	sd	ra,296(sp)
    800054ca:	f222                	sd	s0,288(sp)
    800054cc:	ee26                	sd	s1,280(sp)
    800054ce:	ea4a                	sd	s2,272(sp)
    800054d0:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054d2:	08000613          	li	a2,128
    800054d6:	ed040593          	addi	a1,s0,-304
    800054da:	4501                	li	a0,0
    800054dc:	ffffd097          	auipc	ra,0xffffd
    800054e0:	69e080e7          	jalr	1694(ra) # 80002b7a <argstr>
    return -1;
    800054e4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054e6:	10054e63          	bltz	a0,80005602 <sys_link+0x13c>
    800054ea:	08000613          	li	a2,128
    800054ee:	f5040593          	addi	a1,s0,-176
    800054f2:	4505                	li	a0,1
    800054f4:	ffffd097          	auipc	ra,0xffffd
    800054f8:	686080e7          	jalr	1670(ra) # 80002b7a <argstr>
    return -1;
    800054fc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054fe:	10054263          	bltz	a0,80005602 <sys_link+0x13c>
  begin_op();
    80005502:	fffff097          	auipc	ra,0xfffff
    80005506:	d2a080e7          	jalr	-726(ra) # 8000422c <begin_op>
  if((ip = namei(old)) == 0){
    8000550a:	ed040513          	addi	a0,s0,-304
    8000550e:	fffff097          	auipc	ra,0xfffff
    80005512:	b1e080e7          	jalr	-1250(ra) # 8000402c <namei>
    80005516:	84aa                	mv	s1,a0
    80005518:	c551                	beqz	a0,800055a4 <sys_link+0xde>
  ilock(ip);
    8000551a:	ffffe097          	auipc	ra,0xffffe
    8000551e:	36c080e7          	jalr	876(ra) # 80003886 <ilock>
  if(ip->type == T_DIR){
    80005522:	04449703          	lh	a4,68(s1)
    80005526:	4785                	li	a5,1
    80005528:	08f70463          	beq	a4,a5,800055b0 <sys_link+0xea>
  ip->nlink++;
    8000552c:	04a4d783          	lhu	a5,74(s1)
    80005530:	2785                	addiw	a5,a5,1
    80005532:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005536:	8526                	mv	a0,s1
    80005538:	ffffe097          	auipc	ra,0xffffe
    8000553c:	282080e7          	jalr	642(ra) # 800037ba <iupdate>
  iunlock(ip);
    80005540:	8526                	mv	a0,s1
    80005542:	ffffe097          	auipc	ra,0xffffe
    80005546:	406080e7          	jalr	1030(ra) # 80003948 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000554a:	fd040593          	addi	a1,s0,-48
    8000554e:	f5040513          	addi	a0,s0,-176
    80005552:	fffff097          	auipc	ra,0xfffff
    80005556:	af8080e7          	jalr	-1288(ra) # 8000404a <nameiparent>
    8000555a:	892a                	mv	s2,a0
    8000555c:	c935                	beqz	a0,800055d0 <sys_link+0x10a>
  ilock(dp);
    8000555e:	ffffe097          	auipc	ra,0xffffe
    80005562:	328080e7          	jalr	808(ra) # 80003886 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005566:	00092703          	lw	a4,0(s2)
    8000556a:	409c                	lw	a5,0(s1)
    8000556c:	04f71d63          	bne	a4,a5,800055c6 <sys_link+0x100>
    80005570:	40d0                	lw	a2,4(s1)
    80005572:	fd040593          	addi	a1,s0,-48
    80005576:	854a                	mv	a0,s2
    80005578:	fffff097          	auipc	ra,0xfffff
    8000557c:	a02080e7          	jalr	-1534(ra) # 80003f7a <dirlink>
    80005580:	04054363          	bltz	a0,800055c6 <sys_link+0x100>
  iunlockput(dp);
    80005584:	854a                	mv	a0,s2
    80005586:	ffffe097          	auipc	ra,0xffffe
    8000558a:	562080e7          	jalr	1378(ra) # 80003ae8 <iunlockput>
  iput(ip);
    8000558e:	8526                	mv	a0,s1
    80005590:	ffffe097          	auipc	ra,0xffffe
    80005594:	4b0080e7          	jalr	1200(ra) # 80003a40 <iput>
  end_op();
    80005598:	fffff097          	auipc	ra,0xfffff
    8000559c:	d0e080e7          	jalr	-754(ra) # 800042a6 <end_op>
  return 0;
    800055a0:	4781                	li	a5,0
    800055a2:	a085                	j	80005602 <sys_link+0x13c>
    end_op();
    800055a4:	fffff097          	auipc	ra,0xfffff
    800055a8:	d02080e7          	jalr	-766(ra) # 800042a6 <end_op>
    return -1;
    800055ac:	57fd                	li	a5,-1
    800055ae:	a891                	j	80005602 <sys_link+0x13c>
    iunlockput(ip);
    800055b0:	8526                	mv	a0,s1
    800055b2:	ffffe097          	auipc	ra,0xffffe
    800055b6:	536080e7          	jalr	1334(ra) # 80003ae8 <iunlockput>
    end_op();
    800055ba:	fffff097          	auipc	ra,0xfffff
    800055be:	cec080e7          	jalr	-788(ra) # 800042a6 <end_op>
    return -1;
    800055c2:	57fd                	li	a5,-1
    800055c4:	a83d                	j	80005602 <sys_link+0x13c>
    iunlockput(dp);
    800055c6:	854a                	mv	a0,s2
    800055c8:	ffffe097          	auipc	ra,0xffffe
    800055cc:	520080e7          	jalr	1312(ra) # 80003ae8 <iunlockput>
  ilock(ip);
    800055d0:	8526                	mv	a0,s1
    800055d2:	ffffe097          	auipc	ra,0xffffe
    800055d6:	2b4080e7          	jalr	692(ra) # 80003886 <ilock>
  ip->nlink--;
    800055da:	04a4d783          	lhu	a5,74(s1)
    800055de:	37fd                	addiw	a5,a5,-1
    800055e0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055e4:	8526                	mv	a0,s1
    800055e6:	ffffe097          	auipc	ra,0xffffe
    800055ea:	1d4080e7          	jalr	468(ra) # 800037ba <iupdate>
  iunlockput(ip);
    800055ee:	8526                	mv	a0,s1
    800055f0:	ffffe097          	auipc	ra,0xffffe
    800055f4:	4f8080e7          	jalr	1272(ra) # 80003ae8 <iunlockput>
  end_op();
    800055f8:	fffff097          	auipc	ra,0xfffff
    800055fc:	cae080e7          	jalr	-850(ra) # 800042a6 <end_op>
  return -1;
    80005600:	57fd                	li	a5,-1
}
    80005602:	853e                	mv	a0,a5
    80005604:	70b2                	ld	ra,296(sp)
    80005606:	7412                	ld	s0,288(sp)
    80005608:	64f2                	ld	s1,280(sp)
    8000560a:	6952                	ld	s2,272(sp)
    8000560c:	6155                	addi	sp,sp,304
    8000560e:	8082                	ret

0000000080005610 <sys_unlink>:
{
    80005610:	7151                	addi	sp,sp,-240
    80005612:	f586                	sd	ra,232(sp)
    80005614:	f1a2                	sd	s0,224(sp)
    80005616:	eda6                	sd	s1,216(sp)
    80005618:	e9ca                	sd	s2,208(sp)
    8000561a:	e5ce                	sd	s3,200(sp)
    8000561c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000561e:	08000613          	li	a2,128
    80005622:	f3040593          	addi	a1,s0,-208
    80005626:	4501                	li	a0,0
    80005628:	ffffd097          	auipc	ra,0xffffd
    8000562c:	552080e7          	jalr	1362(ra) # 80002b7a <argstr>
    80005630:	18054163          	bltz	a0,800057b2 <sys_unlink+0x1a2>
  begin_op();
    80005634:	fffff097          	auipc	ra,0xfffff
    80005638:	bf8080e7          	jalr	-1032(ra) # 8000422c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000563c:	fb040593          	addi	a1,s0,-80
    80005640:	f3040513          	addi	a0,s0,-208
    80005644:	fffff097          	auipc	ra,0xfffff
    80005648:	a06080e7          	jalr	-1530(ra) # 8000404a <nameiparent>
    8000564c:	84aa                	mv	s1,a0
    8000564e:	c979                	beqz	a0,80005724 <sys_unlink+0x114>
  ilock(dp);
    80005650:	ffffe097          	auipc	ra,0xffffe
    80005654:	236080e7          	jalr	566(ra) # 80003886 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005658:	00003597          	auipc	a1,0x3
    8000565c:	2d858593          	addi	a1,a1,728 # 80008930 <syscall_names+0x2b0>
    80005660:	fb040513          	addi	a0,s0,-80
    80005664:	ffffe097          	auipc	ra,0xffffe
    80005668:	6ec080e7          	jalr	1772(ra) # 80003d50 <namecmp>
    8000566c:	14050a63          	beqz	a0,800057c0 <sys_unlink+0x1b0>
    80005670:	00003597          	auipc	a1,0x3
    80005674:	2c858593          	addi	a1,a1,712 # 80008938 <syscall_names+0x2b8>
    80005678:	fb040513          	addi	a0,s0,-80
    8000567c:	ffffe097          	auipc	ra,0xffffe
    80005680:	6d4080e7          	jalr	1748(ra) # 80003d50 <namecmp>
    80005684:	12050e63          	beqz	a0,800057c0 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005688:	f2c40613          	addi	a2,s0,-212
    8000568c:	fb040593          	addi	a1,s0,-80
    80005690:	8526                	mv	a0,s1
    80005692:	ffffe097          	auipc	ra,0xffffe
    80005696:	6d8080e7          	jalr	1752(ra) # 80003d6a <dirlookup>
    8000569a:	892a                	mv	s2,a0
    8000569c:	12050263          	beqz	a0,800057c0 <sys_unlink+0x1b0>
  ilock(ip);
    800056a0:	ffffe097          	auipc	ra,0xffffe
    800056a4:	1e6080e7          	jalr	486(ra) # 80003886 <ilock>
  if(ip->nlink < 1)
    800056a8:	04a91783          	lh	a5,74(s2)
    800056ac:	08f05263          	blez	a5,80005730 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800056b0:	04491703          	lh	a4,68(s2)
    800056b4:	4785                	li	a5,1
    800056b6:	08f70563          	beq	a4,a5,80005740 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800056ba:	4641                	li	a2,16
    800056bc:	4581                	li	a1,0
    800056be:	fc040513          	addi	a0,s0,-64
    800056c2:	ffffb097          	auipc	ra,0xffffb
    800056c6:	60c080e7          	jalr	1548(ra) # 80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800056ca:	4741                	li	a4,16
    800056cc:	f2c42683          	lw	a3,-212(s0)
    800056d0:	fc040613          	addi	a2,s0,-64
    800056d4:	4581                	li	a1,0
    800056d6:	8526                	mv	a0,s1
    800056d8:	ffffe097          	auipc	ra,0xffffe
    800056dc:	55a080e7          	jalr	1370(ra) # 80003c32 <writei>
    800056e0:	47c1                	li	a5,16
    800056e2:	0af51563          	bne	a0,a5,8000578c <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800056e6:	04491703          	lh	a4,68(s2)
    800056ea:	4785                	li	a5,1
    800056ec:	0af70863          	beq	a4,a5,8000579c <sys_unlink+0x18c>
  iunlockput(dp);
    800056f0:	8526                	mv	a0,s1
    800056f2:	ffffe097          	auipc	ra,0xffffe
    800056f6:	3f6080e7          	jalr	1014(ra) # 80003ae8 <iunlockput>
  ip->nlink--;
    800056fa:	04a95783          	lhu	a5,74(s2)
    800056fe:	37fd                	addiw	a5,a5,-1
    80005700:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005704:	854a                	mv	a0,s2
    80005706:	ffffe097          	auipc	ra,0xffffe
    8000570a:	0b4080e7          	jalr	180(ra) # 800037ba <iupdate>
  iunlockput(ip);
    8000570e:	854a                	mv	a0,s2
    80005710:	ffffe097          	auipc	ra,0xffffe
    80005714:	3d8080e7          	jalr	984(ra) # 80003ae8 <iunlockput>
  end_op();
    80005718:	fffff097          	auipc	ra,0xfffff
    8000571c:	b8e080e7          	jalr	-1138(ra) # 800042a6 <end_op>
  return 0;
    80005720:	4501                	li	a0,0
    80005722:	a84d                	j	800057d4 <sys_unlink+0x1c4>
    end_op();
    80005724:	fffff097          	auipc	ra,0xfffff
    80005728:	b82080e7          	jalr	-1150(ra) # 800042a6 <end_op>
    return -1;
    8000572c:	557d                	li	a0,-1
    8000572e:	a05d                	j	800057d4 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005730:	00003517          	auipc	a0,0x3
    80005734:	21050513          	addi	a0,a0,528 # 80008940 <syscall_names+0x2c0>
    80005738:	ffffb097          	auipc	ra,0xffffb
    8000573c:	e04080e7          	jalr	-508(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005740:	04c92703          	lw	a4,76(s2)
    80005744:	02000793          	li	a5,32
    80005748:	f6e7f9e3          	bgeu	a5,a4,800056ba <sys_unlink+0xaa>
    8000574c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005750:	4741                	li	a4,16
    80005752:	86ce                	mv	a3,s3
    80005754:	f1840613          	addi	a2,s0,-232
    80005758:	4581                	li	a1,0
    8000575a:	854a                	mv	a0,s2
    8000575c:	ffffe097          	auipc	ra,0xffffe
    80005760:	3de080e7          	jalr	990(ra) # 80003b3a <readi>
    80005764:	47c1                	li	a5,16
    80005766:	00f51b63          	bne	a0,a5,8000577c <sys_unlink+0x16c>
    if(de.inum != 0)
    8000576a:	f1845783          	lhu	a5,-232(s0)
    8000576e:	e7a1                	bnez	a5,800057b6 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005770:	29c1                	addiw	s3,s3,16
    80005772:	04c92783          	lw	a5,76(s2)
    80005776:	fcf9ede3          	bltu	s3,a5,80005750 <sys_unlink+0x140>
    8000577a:	b781                	j	800056ba <sys_unlink+0xaa>
      panic("isdirempty: readi");
    8000577c:	00003517          	auipc	a0,0x3
    80005780:	1dc50513          	addi	a0,a0,476 # 80008958 <syscall_names+0x2d8>
    80005784:	ffffb097          	auipc	ra,0xffffb
    80005788:	db8080e7          	jalr	-584(ra) # 8000053c <panic>
    panic("unlink: writei");
    8000578c:	00003517          	auipc	a0,0x3
    80005790:	1e450513          	addi	a0,a0,484 # 80008970 <syscall_names+0x2f0>
    80005794:	ffffb097          	auipc	ra,0xffffb
    80005798:	da8080e7          	jalr	-600(ra) # 8000053c <panic>
    dp->nlink--;
    8000579c:	04a4d783          	lhu	a5,74(s1)
    800057a0:	37fd                	addiw	a5,a5,-1
    800057a2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800057a6:	8526                	mv	a0,s1
    800057a8:	ffffe097          	auipc	ra,0xffffe
    800057ac:	012080e7          	jalr	18(ra) # 800037ba <iupdate>
    800057b0:	b781                	j	800056f0 <sys_unlink+0xe0>
    return -1;
    800057b2:	557d                	li	a0,-1
    800057b4:	a005                	j	800057d4 <sys_unlink+0x1c4>
    iunlockput(ip);
    800057b6:	854a                	mv	a0,s2
    800057b8:	ffffe097          	auipc	ra,0xffffe
    800057bc:	330080e7          	jalr	816(ra) # 80003ae8 <iunlockput>
  iunlockput(dp);
    800057c0:	8526                	mv	a0,s1
    800057c2:	ffffe097          	auipc	ra,0xffffe
    800057c6:	326080e7          	jalr	806(ra) # 80003ae8 <iunlockput>
  end_op();
    800057ca:	fffff097          	auipc	ra,0xfffff
    800057ce:	adc080e7          	jalr	-1316(ra) # 800042a6 <end_op>
  return -1;
    800057d2:	557d                	li	a0,-1
}
    800057d4:	70ae                	ld	ra,232(sp)
    800057d6:	740e                	ld	s0,224(sp)
    800057d8:	64ee                	ld	s1,216(sp)
    800057da:	694e                	ld	s2,208(sp)
    800057dc:	69ae                	ld	s3,200(sp)
    800057de:	616d                	addi	sp,sp,240
    800057e0:	8082                	ret

00000000800057e2 <sys_open>:

uint64
sys_open(void)
{
    800057e2:	7131                	addi	sp,sp,-192
    800057e4:	fd06                	sd	ra,184(sp)
    800057e6:	f922                	sd	s0,176(sp)
    800057e8:	f526                	sd	s1,168(sp)
    800057ea:	f14a                	sd	s2,160(sp)
    800057ec:	ed4e                	sd	s3,152(sp)
    800057ee:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800057f0:	f4c40593          	addi	a1,s0,-180
    800057f4:	4505                	li	a0,1
    800057f6:	ffffd097          	auipc	ra,0xffffd
    800057fa:	344080e7          	jalr	836(ra) # 80002b3a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800057fe:	08000613          	li	a2,128
    80005802:	f5040593          	addi	a1,s0,-176
    80005806:	4501                	li	a0,0
    80005808:	ffffd097          	auipc	ra,0xffffd
    8000580c:	372080e7          	jalr	882(ra) # 80002b7a <argstr>
    80005810:	87aa                	mv	a5,a0
    return -1;
    80005812:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005814:	0a07c863          	bltz	a5,800058c4 <sys_open+0xe2>

  begin_op();
    80005818:	fffff097          	auipc	ra,0xfffff
    8000581c:	a14080e7          	jalr	-1516(ra) # 8000422c <begin_op>

  if(omode & O_CREATE){
    80005820:	f4c42783          	lw	a5,-180(s0)
    80005824:	2007f793          	andi	a5,a5,512
    80005828:	cbdd                	beqz	a5,800058de <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    8000582a:	4681                	li	a3,0
    8000582c:	4601                	li	a2,0
    8000582e:	4589                	li	a1,2
    80005830:	f5040513          	addi	a0,s0,-176
    80005834:	00000097          	auipc	ra,0x0
    80005838:	97a080e7          	jalr	-1670(ra) # 800051ae <create>
    8000583c:	84aa                	mv	s1,a0
    if(ip == 0){
    8000583e:	c951                	beqz	a0,800058d2 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005840:	04449703          	lh	a4,68(s1)
    80005844:	478d                	li	a5,3
    80005846:	00f71763          	bne	a4,a5,80005854 <sys_open+0x72>
    8000584a:	0464d703          	lhu	a4,70(s1)
    8000584e:	47a5                	li	a5,9
    80005850:	0ce7ec63          	bltu	a5,a4,80005928 <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005854:	fffff097          	auipc	ra,0xfffff
    80005858:	de0080e7          	jalr	-544(ra) # 80004634 <filealloc>
    8000585c:	892a                	mv	s2,a0
    8000585e:	c56d                	beqz	a0,80005948 <sys_open+0x166>
    80005860:	00000097          	auipc	ra,0x0
    80005864:	90c080e7          	jalr	-1780(ra) # 8000516c <fdalloc>
    80005868:	89aa                	mv	s3,a0
    8000586a:	0c054a63          	bltz	a0,8000593e <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000586e:	04449703          	lh	a4,68(s1)
    80005872:	478d                	li	a5,3
    80005874:	0ef70563          	beq	a4,a5,8000595e <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005878:	4789                	li	a5,2
    8000587a:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000587e:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005882:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005886:	f4c42783          	lw	a5,-180(s0)
    8000588a:	0017c713          	xori	a4,a5,1
    8000588e:	8b05                	andi	a4,a4,1
    80005890:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005894:	0037f713          	andi	a4,a5,3
    80005898:	00e03733          	snez	a4,a4
    8000589c:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800058a0:	4007f793          	andi	a5,a5,1024
    800058a4:	c791                	beqz	a5,800058b0 <sys_open+0xce>
    800058a6:	04449703          	lh	a4,68(s1)
    800058aa:	4789                	li	a5,2
    800058ac:	0cf70063          	beq	a4,a5,8000596c <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    800058b0:	8526                	mv	a0,s1
    800058b2:	ffffe097          	auipc	ra,0xffffe
    800058b6:	096080e7          	jalr	150(ra) # 80003948 <iunlock>
  end_op();
    800058ba:	fffff097          	auipc	ra,0xfffff
    800058be:	9ec080e7          	jalr	-1556(ra) # 800042a6 <end_op>

  return fd;
    800058c2:	854e                	mv	a0,s3
}
    800058c4:	70ea                	ld	ra,184(sp)
    800058c6:	744a                	ld	s0,176(sp)
    800058c8:	74aa                	ld	s1,168(sp)
    800058ca:	790a                	ld	s2,160(sp)
    800058cc:	69ea                	ld	s3,152(sp)
    800058ce:	6129                	addi	sp,sp,192
    800058d0:	8082                	ret
      end_op();
    800058d2:	fffff097          	auipc	ra,0xfffff
    800058d6:	9d4080e7          	jalr	-1580(ra) # 800042a6 <end_op>
      return -1;
    800058da:	557d                	li	a0,-1
    800058dc:	b7e5                	j	800058c4 <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    800058de:	f5040513          	addi	a0,s0,-176
    800058e2:	ffffe097          	auipc	ra,0xffffe
    800058e6:	74a080e7          	jalr	1866(ra) # 8000402c <namei>
    800058ea:	84aa                	mv	s1,a0
    800058ec:	c905                	beqz	a0,8000591c <sys_open+0x13a>
    ilock(ip);
    800058ee:	ffffe097          	auipc	ra,0xffffe
    800058f2:	f98080e7          	jalr	-104(ra) # 80003886 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800058f6:	04449703          	lh	a4,68(s1)
    800058fa:	4785                	li	a5,1
    800058fc:	f4f712e3          	bne	a4,a5,80005840 <sys_open+0x5e>
    80005900:	f4c42783          	lw	a5,-180(s0)
    80005904:	dba1                	beqz	a5,80005854 <sys_open+0x72>
      iunlockput(ip);
    80005906:	8526                	mv	a0,s1
    80005908:	ffffe097          	auipc	ra,0xffffe
    8000590c:	1e0080e7          	jalr	480(ra) # 80003ae8 <iunlockput>
      end_op();
    80005910:	fffff097          	auipc	ra,0xfffff
    80005914:	996080e7          	jalr	-1642(ra) # 800042a6 <end_op>
      return -1;
    80005918:	557d                	li	a0,-1
    8000591a:	b76d                	j	800058c4 <sys_open+0xe2>
      end_op();
    8000591c:	fffff097          	auipc	ra,0xfffff
    80005920:	98a080e7          	jalr	-1654(ra) # 800042a6 <end_op>
      return -1;
    80005924:	557d                	li	a0,-1
    80005926:	bf79                	j	800058c4 <sys_open+0xe2>
    iunlockput(ip);
    80005928:	8526                	mv	a0,s1
    8000592a:	ffffe097          	auipc	ra,0xffffe
    8000592e:	1be080e7          	jalr	446(ra) # 80003ae8 <iunlockput>
    end_op();
    80005932:	fffff097          	auipc	ra,0xfffff
    80005936:	974080e7          	jalr	-1676(ra) # 800042a6 <end_op>
    return -1;
    8000593a:	557d                	li	a0,-1
    8000593c:	b761                	j	800058c4 <sys_open+0xe2>
      fileclose(f);
    8000593e:	854a                	mv	a0,s2
    80005940:	fffff097          	auipc	ra,0xfffff
    80005944:	db0080e7          	jalr	-592(ra) # 800046f0 <fileclose>
    iunlockput(ip);
    80005948:	8526                	mv	a0,s1
    8000594a:	ffffe097          	auipc	ra,0xffffe
    8000594e:	19e080e7          	jalr	414(ra) # 80003ae8 <iunlockput>
    end_op();
    80005952:	fffff097          	auipc	ra,0xfffff
    80005956:	954080e7          	jalr	-1708(ra) # 800042a6 <end_op>
    return -1;
    8000595a:	557d                	li	a0,-1
    8000595c:	b7a5                	j	800058c4 <sys_open+0xe2>
    f->type = FD_DEVICE;
    8000595e:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005962:	04649783          	lh	a5,70(s1)
    80005966:	02f91223          	sh	a5,36(s2)
    8000596a:	bf21                	j	80005882 <sys_open+0xa0>
    itrunc(ip);
    8000596c:	8526                	mv	a0,s1
    8000596e:	ffffe097          	auipc	ra,0xffffe
    80005972:	026080e7          	jalr	38(ra) # 80003994 <itrunc>
    80005976:	bf2d                	j	800058b0 <sys_open+0xce>

0000000080005978 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005978:	7175                	addi	sp,sp,-144
    8000597a:	e506                	sd	ra,136(sp)
    8000597c:	e122                	sd	s0,128(sp)
    8000597e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005980:	fffff097          	auipc	ra,0xfffff
    80005984:	8ac080e7          	jalr	-1876(ra) # 8000422c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005988:	08000613          	li	a2,128
    8000598c:	f7040593          	addi	a1,s0,-144
    80005990:	4501                	li	a0,0
    80005992:	ffffd097          	auipc	ra,0xffffd
    80005996:	1e8080e7          	jalr	488(ra) # 80002b7a <argstr>
    8000599a:	02054963          	bltz	a0,800059cc <sys_mkdir+0x54>
    8000599e:	4681                	li	a3,0
    800059a0:	4601                	li	a2,0
    800059a2:	4585                	li	a1,1
    800059a4:	f7040513          	addi	a0,s0,-144
    800059a8:	00000097          	auipc	ra,0x0
    800059ac:	806080e7          	jalr	-2042(ra) # 800051ae <create>
    800059b0:	cd11                	beqz	a0,800059cc <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800059b2:	ffffe097          	auipc	ra,0xffffe
    800059b6:	136080e7          	jalr	310(ra) # 80003ae8 <iunlockput>
  end_op();
    800059ba:	fffff097          	auipc	ra,0xfffff
    800059be:	8ec080e7          	jalr	-1812(ra) # 800042a6 <end_op>
  return 0;
    800059c2:	4501                	li	a0,0
}
    800059c4:	60aa                	ld	ra,136(sp)
    800059c6:	640a                	ld	s0,128(sp)
    800059c8:	6149                	addi	sp,sp,144
    800059ca:	8082                	ret
    end_op();
    800059cc:	fffff097          	auipc	ra,0xfffff
    800059d0:	8da080e7          	jalr	-1830(ra) # 800042a6 <end_op>
    return -1;
    800059d4:	557d                	li	a0,-1
    800059d6:	b7fd                	j	800059c4 <sys_mkdir+0x4c>

00000000800059d8 <sys_mknod>:

uint64
sys_mknod(void)
{
    800059d8:	7135                	addi	sp,sp,-160
    800059da:	ed06                	sd	ra,152(sp)
    800059dc:	e922                	sd	s0,144(sp)
    800059de:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800059e0:	fffff097          	auipc	ra,0xfffff
    800059e4:	84c080e7          	jalr	-1972(ra) # 8000422c <begin_op>
  argint(1, &major);
    800059e8:	f6c40593          	addi	a1,s0,-148
    800059ec:	4505                	li	a0,1
    800059ee:	ffffd097          	auipc	ra,0xffffd
    800059f2:	14c080e7          	jalr	332(ra) # 80002b3a <argint>
  argint(2, &minor);
    800059f6:	f6840593          	addi	a1,s0,-152
    800059fa:	4509                	li	a0,2
    800059fc:	ffffd097          	auipc	ra,0xffffd
    80005a00:	13e080e7          	jalr	318(ra) # 80002b3a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a04:	08000613          	li	a2,128
    80005a08:	f7040593          	addi	a1,s0,-144
    80005a0c:	4501                	li	a0,0
    80005a0e:	ffffd097          	auipc	ra,0xffffd
    80005a12:	16c080e7          	jalr	364(ra) # 80002b7a <argstr>
    80005a16:	02054b63          	bltz	a0,80005a4c <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005a1a:	f6841683          	lh	a3,-152(s0)
    80005a1e:	f6c41603          	lh	a2,-148(s0)
    80005a22:	458d                	li	a1,3
    80005a24:	f7040513          	addi	a0,s0,-144
    80005a28:	fffff097          	auipc	ra,0xfffff
    80005a2c:	786080e7          	jalr	1926(ra) # 800051ae <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a30:	cd11                	beqz	a0,80005a4c <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a32:	ffffe097          	auipc	ra,0xffffe
    80005a36:	0b6080e7          	jalr	182(ra) # 80003ae8 <iunlockput>
  end_op();
    80005a3a:	fffff097          	auipc	ra,0xfffff
    80005a3e:	86c080e7          	jalr	-1940(ra) # 800042a6 <end_op>
  return 0;
    80005a42:	4501                	li	a0,0
}
    80005a44:	60ea                	ld	ra,152(sp)
    80005a46:	644a                	ld	s0,144(sp)
    80005a48:	610d                	addi	sp,sp,160
    80005a4a:	8082                	ret
    end_op();
    80005a4c:	fffff097          	auipc	ra,0xfffff
    80005a50:	85a080e7          	jalr	-1958(ra) # 800042a6 <end_op>
    return -1;
    80005a54:	557d                	li	a0,-1
    80005a56:	b7fd                	j	80005a44 <sys_mknod+0x6c>

0000000080005a58 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005a58:	7135                	addi	sp,sp,-160
    80005a5a:	ed06                	sd	ra,152(sp)
    80005a5c:	e922                	sd	s0,144(sp)
    80005a5e:	e526                	sd	s1,136(sp)
    80005a60:	e14a                	sd	s2,128(sp)
    80005a62:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005a64:	ffffc097          	auipc	ra,0xffffc
    80005a68:	f42080e7          	jalr	-190(ra) # 800019a6 <myproc>
    80005a6c:	892a                	mv	s2,a0
  
  begin_op();
    80005a6e:	ffffe097          	auipc	ra,0xffffe
    80005a72:	7be080e7          	jalr	1982(ra) # 8000422c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005a76:	08000613          	li	a2,128
    80005a7a:	f6040593          	addi	a1,s0,-160
    80005a7e:	4501                	li	a0,0
    80005a80:	ffffd097          	auipc	ra,0xffffd
    80005a84:	0fa080e7          	jalr	250(ra) # 80002b7a <argstr>
    80005a88:	04054b63          	bltz	a0,80005ade <sys_chdir+0x86>
    80005a8c:	f6040513          	addi	a0,s0,-160
    80005a90:	ffffe097          	auipc	ra,0xffffe
    80005a94:	59c080e7          	jalr	1436(ra) # 8000402c <namei>
    80005a98:	84aa                	mv	s1,a0
    80005a9a:	c131                	beqz	a0,80005ade <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005a9c:	ffffe097          	auipc	ra,0xffffe
    80005aa0:	dea080e7          	jalr	-534(ra) # 80003886 <ilock>
  if(ip->type != T_DIR){
    80005aa4:	04449703          	lh	a4,68(s1)
    80005aa8:	4785                	li	a5,1
    80005aaa:	04f71063          	bne	a4,a5,80005aea <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005aae:	8526                	mv	a0,s1
    80005ab0:	ffffe097          	auipc	ra,0xffffe
    80005ab4:	e98080e7          	jalr	-360(ra) # 80003948 <iunlock>
  iput(p->cwd);
    80005ab8:	15093503          	ld	a0,336(s2)
    80005abc:	ffffe097          	auipc	ra,0xffffe
    80005ac0:	f84080e7          	jalr	-124(ra) # 80003a40 <iput>
  end_op();
    80005ac4:	ffffe097          	auipc	ra,0xffffe
    80005ac8:	7e2080e7          	jalr	2018(ra) # 800042a6 <end_op>
  p->cwd = ip;
    80005acc:	14993823          	sd	s1,336(s2)
  return 0;
    80005ad0:	4501                	li	a0,0
}
    80005ad2:	60ea                	ld	ra,152(sp)
    80005ad4:	644a                	ld	s0,144(sp)
    80005ad6:	64aa                	ld	s1,136(sp)
    80005ad8:	690a                	ld	s2,128(sp)
    80005ada:	610d                	addi	sp,sp,160
    80005adc:	8082                	ret
    end_op();
    80005ade:	ffffe097          	auipc	ra,0xffffe
    80005ae2:	7c8080e7          	jalr	1992(ra) # 800042a6 <end_op>
    return -1;
    80005ae6:	557d                	li	a0,-1
    80005ae8:	b7ed                	j	80005ad2 <sys_chdir+0x7a>
    iunlockput(ip);
    80005aea:	8526                	mv	a0,s1
    80005aec:	ffffe097          	auipc	ra,0xffffe
    80005af0:	ffc080e7          	jalr	-4(ra) # 80003ae8 <iunlockput>
    end_op();
    80005af4:	ffffe097          	auipc	ra,0xffffe
    80005af8:	7b2080e7          	jalr	1970(ra) # 800042a6 <end_op>
    return -1;
    80005afc:	557d                	li	a0,-1
    80005afe:	bfd1                	j	80005ad2 <sys_chdir+0x7a>

0000000080005b00 <sys_exec>:

uint64
sys_exec(void)
{
    80005b00:	7121                	addi	sp,sp,-448
    80005b02:	ff06                	sd	ra,440(sp)
    80005b04:	fb22                	sd	s0,432(sp)
    80005b06:	f726                	sd	s1,424(sp)
    80005b08:	f34a                	sd	s2,416(sp)
    80005b0a:	ef4e                	sd	s3,408(sp)
    80005b0c:	eb52                	sd	s4,400(sp)
    80005b0e:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005b10:	e4840593          	addi	a1,s0,-440
    80005b14:	4505                	li	a0,1
    80005b16:	ffffd097          	auipc	ra,0xffffd
    80005b1a:	044080e7          	jalr	68(ra) # 80002b5a <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005b1e:	08000613          	li	a2,128
    80005b22:	f5040593          	addi	a1,s0,-176
    80005b26:	4501                	li	a0,0
    80005b28:	ffffd097          	auipc	ra,0xffffd
    80005b2c:	052080e7          	jalr	82(ra) # 80002b7a <argstr>
    80005b30:	87aa                	mv	a5,a0
    return -1;
    80005b32:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005b34:	0c07c263          	bltz	a5,80005bf8 <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    80005b38:	10000613          	li	a2,256
    80005b3c:	4581                	li	a1,0
    80005b3e:	e5040513          	addi	a0,s0,-432
    80005b42:	ffffb097          	auipc	ra,0xffffb
    80005b46:	18c080e7          	jalr	396(ra) # 80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005b4a:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005b4e:	89a6                	mv	s3,s1
    80005b50:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005b52:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005b56:	00391513          	slli	a0,s2,0x3
    80005b5a:	e4040593          	addi	a1,s0,-448
    80005b5e:	e4843783          	ld	a5,-440(s0)
    80005b62:	953e                	add	a0,a0,a5
    80005b64:	ffffd097          	auipc	ra,0xffffd
    80005b68:	f38080e7          	jalr	-200(ra) # 80002a9c <fetchaddr>
    80005b6c:	02054a63          	bltz	a0,80005ba0 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005b70:	e4043783          	ld	a5,-448(s0)
    80005b74:	c3b9                	beqz	a5,80005bba <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005b76:	ffffb097          	auipc	ra,0xffffb
    80005b7a:	f6c080e7          	jalr	-148(ra) # 80000ae2 <kalloc>
    80005b7e:	85aa                	mv	a1,a0
    80005b80:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005b84:	cd11                	beqz	a0,80005ba0 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005b86:	6605                	lui	a2,0x1
    80005b88:	e4043503          	ld	a0,-448(s0)
    80005b8c:	ffffd097          	auipc	ra,0xffffd
    80005b90:	f62080e7          	jalr	-158(ra) # 80002aee <fetchstr>
    80005b94:	00054663          	bltz	a0,80005ba0 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005b98:	0905                	addi	s2,s2,1
    80005b9a:	09a1                	addi	s3,s3,8
    80005b9c:	fb491de3          	bne	s2,s4,80005b56 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ba0:	f5040913          	addi	s2,s0,-176
    80005ba4:	6088                	ld	a0,0(s1)
    80005ba6:	c921                	beqz	a0,80005bf6 <sys_exec+0xf6>
    kfree(argv[i]);
    80005ba8:	ffffb097          	auipc	ra,0xffffb
    80005bac:	e3c080e7          	jalr	-452(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bb0:	04a1                	addi	s1,s1,8
    80005bb2:	ff2499e3          	bne	s1,s2,80005ba4 <sys_exec+0xa4>
  return -1;
    80005bb6:	557d                	li	a0,-1
    80005bb8:	a081                	j	80005bf8 <sys_exec+0xf8>
      argv[i] = 0;
    80005bba:	0009079b          	sext.w	a5,s2
    80005bbe:	078e                	slli	a5,a5,0x3
    80005bc0:	fd078793          	addi	a5,a5,-48
    80005bc4:	97a2                	add	a5,a5,s0
    80005bc6:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005bca:	e5040593          	addi	a1,s0,-432
    80005bce:	f5040513          	addi	a0,s0,-176
    80005bd2:	fffff097          	auipc	ra,0xfffff
    80005bd6:	194080e7          	jalr	404(ra) # 80004d66 <exec>
    80005bda:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bdc:	f5040993          	addi	s3,s0,-176
    80005be0:	6088                	ld	a0,0(s1)
    80005be2:	c901                	beqz	a0,80005bf2 <sys_exec+0xf2>
    kfree(argv[i]);
    80005be4:	ffffb097          	auipc	ra,0xffffb
    80005be8:	e00080e7          	jalr	-512(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bec:	04a1                	addi	s1,s1,8
    80005bee:	ff3499e3          	bne	s1,s3,80005be0 <sys_exec+0xe0>
  return ret;
    80005bf2:	854a                	mv	a0,s2
    80005bf4:	a011                	j	80005bf8 <sys_exec+0xf8>
  return -1;
    80005bf6:	557d                	li	a0,-1
}
    80005bf8:	70fa                	ld	ra,440(sp)
    80005bfa:	745a                	ld	s0,432(sp)
    80005bfc:	74ba                	ld	s1,424(sp)
    80005bfe:	791a                	ld	s2,416(sp)
    80005c00:	69fa                	ld	s3,408(sp)
    80005c02:	6a5a                	ld	s4,400(sp)
    80005c04:	6139                	addi	sp,sp,448
    80005c06:	8082                	ret

0000000080005c08 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005c08:	7139                	addi	sp,sp,-64
    80005c0a:	fc06                	sd	ra,56(sp)
    80005c0c:	f822                	sd	s0,48(sp)
    80005c0e:	f426                	sd	s1,40(sp)
    80005c10:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005c12:	ffffc097          	auipc	ra,0xffffc
    80005c16:	d94080e7          	jalr	-620(ra) # 800019a6 <myproc>
    80005c1a:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005c1c:	fd840593          	addi	a1,s0,-40
    80005c20:	4501                	li	a0,0
    80005c22:	ffffd097          	auipc	ra,0xffffd
    80005c26:	f38080e7          	jalr	-200(ra) # 80002b5a <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005c2a:	fc840593          	addi	a1,s0,-56
    80005c2e:	fd040513          	addi	a0,s0,-48
    80005c32:	fffff097          	auipc	ra,0xfffff
    80005c36:	dea080e7          	jalr	-534(ra) # 80004a1c <pipealloc>
    return -1;
    80005c3a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005c3c:	0c054463          	bltz	a0,80005d04 <sys_pipe+0xfc>
  fd0 = -1;
    80005c40:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005c44:	fd043503          	ld	a0,-48(s0)
    80005c48:	fffff097          	auipc	ra,0xfffff
    80005c4c:	524080e7          	jalr	1316(ra) # 8000516c <fdalloc>
    80005c50:	fca42223          	sw	a0,-60(s0)
    80005c54:	08054b63          	bltz	a0,80005cea <sys_pipe+0xe2>
    80005c58:	fc843503          	ld	a0,-56(s0)
    80005c5c:	fffff097          	auipc	ra,0xfffff
    80005c60:	510080e7          	jalr	1296(ra) # 8000516c <fdalloc>
    80005c64:	fca42023          	sw	a0,-64(s0)
    80005c68:	06054863          	bltz	a0,80005cd8 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c6c:	4691                	li	a3,4
    80005c6e:	fc440613          	addi	a2,s0,-60
    80005c72:	fd843583          	ld	a1,-40(s0)
    80005c76:	68a8                	ld	a0,80(s1)
    80005c78:	ffffc097          	auipc	ra,0xffffc
    80005c7c:	9ee080e7          	jalr	-1554(ra) # 80001666 <copyout>
    80005c80:	02054063          	bltz	a0,80005ca0 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005c84:	4691                	li	a3,4
    80005c86:	fc040613          	addi	a2,s0,-64
    80005c8a:	fd843583          	ld	a1,-40(s0)
    80005c8e:	0591                	addi	a1,a1,4
    80005c90:	68a8                	ld	a0,80(s1)
    80005c92:	ffffc097          	auipc	ra,0xffffc
    80005c96:	9d4080e7          	jalr	-1580(ra) # 80001666 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005c9a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c9c:	06055463          	bgez	a0,80005d04 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005ca0:	fc442783          	lw	a5,-60(s0)
    80005ca4:	07e9                	addi	a5,a5,26
    80005ca6:	078e                	slli	a5,a5,0x3
    80005ca8:	97a6                	add	a5,a5,s1
    80005caa:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005cae:	fc042783          	lw	a5,-64(s0)
    80005cb2:	07e9                	addi	a5,a5,26
    80005cb4:	078e                	slli	a5,a5,0x3
    80005cb6:	94be                	add	s1,s1,a5
    80005cb8:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005cbc:	fd043503          	ld	a0,-48(s0)
    80005cc0:	fffff097          	auipc	ra,0xfffff
    80005cc4:	a30080e7          	jalr	-1488(ra) # 800046f0 <fileclose>
    fileclose(wf);
    80005cc8:	fc843503          	ld	a0,-56(s0)
    80005ccc:	fffff097          	auipc	ra,0xfffff
    80005cd0:	a24080e7          	jalr	-1500(ra) # 800046f0 <fileclose>
    return -1;
    80005cd4:	57fd                	li	a5,-1
    80005cd6:	a03d                	j	80005d04 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005cd8:	fc442783          	lw	a5,-60(s0)
    80005cdc:	0007c763          	bltz	a5,80005cea <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005ce0:	07e9                	addi	a5,a5,26
    80005ce2:	078e                	slli	a5,a5,0x3
    80005ce4:	97a6                	add	a5,a5,s1
    80005ce6:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005cea:	fd043503          	ld	a0,-48(s0)
    80005cee:	fffff097          	auipc	ra,0xfffff
    80005cf2:	a02080e7          	jalr	-1534(ra) # 800046f0 <fileclose>
    fileclose(wf);
    80005cf6:	fc843503          	ld	a0,-56(s0)
    80005cfa:	fffff097          	auipc	ra,0xfffff
    80005cfe:	9f6080e7          	jalr	-1546(ra) # 800046f0 <fileclose>
    return -1;
    80005d02:	57fd                	li	a5,-1
}
    80005d04:	853e                	mv	a0,a5
    80005d06:	70e2                	ld	ra,56(sp)
    80005d08:	7442                	ld	s0,48(sp)
    80005d0a:	74a2                	ld	s1,40(sp)
    80005d0c:	6121                	addi	sp,sp,64
    80005d0e:	8082                	ret

0000000080005d10 <kernelvec>:
    80005d10:	7111                	addi	sp,sp,-256
    80005d12:	e006                	sd	ra,0(sp)
    80005d14:	e40a                	sd	sp,8(sp)
    80005d16:	e80e                	sd	gp,16(sp)
    80005d18:	ec12                	sd	tp,24(sp)
    80005d1a:	f016                	sd	t0,32(sp)
    80005d1c:	f41a                	sd	t1,40(sp)
    80005d1e:	f81e                	sd	t2,48(sp)
    80005d20:	fc22                	sd	s0,56(sp)
    80005d22:	e0a6                	sd	s1,64(sp)
    80005d24:	e4aa                	sd	a0,72(sp)
    80005d26:	e8ae                	sd	a1,80(sp)
    80005d28:	ecb2                	sd	a2,88(sp)
    80005d2a:	f0b6                	sd	a3,96(sp)
    80005d2c:	f4ba                	sd	a4,104(sp)
    80005d2e:	f8be                	sd	a5,112(sp)
    80005d30:	fcc2                	sd	a6,120(sp)
    80005d32:	e146                	sd	a7,128(sp)
    80005d34:	e54a                	sd	s2,136(sp)
    80005d36:	e94e                	sd	s3,144(sp)
    80005d38:	ed52                	sd	s4,152(sp)
    80005d3a:	f156                	sd	s5,160(sp)
    80005d3c:	f55a                	sd	s6,168(sp)
    80005d3e:	f95e                	sd	s7,176(sp)
    80005d40:	fd62                	sd	s8,184(sp)
    80005d42:	e1e6                	sd	s9,192(sp)
    80005d44:	e5ea                	sd	s10,200(sp)
    80005d46:	e9ee                	sd	s11,208(sp)
    80005d48:	edf2                	sd	t3,216(sp)
    80005d4a:	f1f6                	sd	t4,224(sp)
    80005d4c:	f5fa                	sd	t5,232(sp)
    80005d4e:	f9fe                	sd	t6,240(sp)
    80005d50:	c19fc0ef          	jal	ra,80002968 <kerneltrap>
    80005d54:	6082                	ld	ra,0(sp)
    80005d56:	6122                	ld	sp,8(sp)
    80005d58:	61c2                	ld	gp,16(sp)
    80005d5a:	7282                	ld	t0,32(sp)
    80005d5c:	7322                	ld	t1,40(sp)
    80005d5e:	73c2                	ld	t2,48(sp)
    80005d60:	7462                	ld	s0,56(sp)
    80005d62:	6486                	ld	s1,64(sp)
    80005d64:	6526                	ld	a0,72(sp)
    80005d66:	65c6                	ld	a1,80(sp)
    80005d68:	6666                	ld	a2,88(sp)
    80005d6a:	7686                	ld	a3,96(sp)
    80005d6c:	7726                	ld	a4,104(sp)
    80005d6e:	77c6                	ld	a5,112(sp)
    80005d70:	7866                	ld	a6,120(sp)
    80005d72:	688a                	ld	a7,128(sp)
    80005d74:	692a                	ld	s2,136(sp)
    80005d76:	69ca                	ld	s3,144(sp)
    80005d78:	6a6a                	ld	s4,152(sp)
    80005d7a:	7a8a                	ld	s5,160(sp)
    80005d7c:	7b2a                	ld	s6,168(sp)
    80005d7e:	7bca                	ld	s7,176(sp)
    80005d80:	7c6a                	ld	s8,184(sp)
    80005d82:	6c8e                	ld	s9,192(sp)
    80005d84:	6d2e                	ld	s10,200(sp)
    80005d86:	6dce                	ld	s11,208(sp)
    80005d88:	6e6e                	ld	t3,216(sp)
    80005d8a:	7e8e                	ld	t4,224(sp)
    80005d8c:	7f2e                	ld	t5,232(sp)
    80005d8e:	7fce                	ld	t6,240(sp)
    80005d90:	6111                	addi	sp,sp,256
    80005d92:	10200073          	sret
    80005d96:	00000013          	nop
    80005d9a:	00000013          	nop
    80005d9e:	0001                	nop

0000000080005da0 <timervec>:
    80005da0:	34051573          	csrrw	a0,mscratch,a0
    80005da4:	e10c                	sd	a1,0(a0)
    80005da6:	e510                	sd	a2,8(a0)
    80005da8:	e914                	sd	a3,16(a0)
    80005daa:	6d0c                	ld	a1,24(a0)
    80005dac:	7110                	ld	a2,32(a0)
    80005dae:	6194                	ld	a3,0(a1)
    80005db0:	96b2                	add	a3,a3,a2
    80005db2:	e194                	sd	a3,0(a1)
    80005db4:	4589                	li	a1,2
    80005db6:	14459073          	csrw	sip,a1
    80005dba:	6914                	ld	a3,16(a0)
    80005dbc:	6510                	ld	a2,8(a0)
    80005dbe:	610c                	ld	a1,0(a0)
    80005dc0:	34051573          	csrrw	a0,mscratch,a0
    80005dc4:	30200073          	mret
	...

0000000080005dca <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005dca:	1141                	addi	sp,sp,-16
    80005dcc:	e422                	sd	s0,8(sp)
    80005dce:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005dd0:	0c0007b7          	lui	a5,0xc000
    80005dd4:	4705                	li	a4,1
    80005dd6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005dd8:	c3d8                	sw	a4,4(a5)
}
    80005dda:	6422                	ld	s0,8(sp)
    80005ddc:	0141                	addi	sp,sp,16
    80005dde:	8082                	ret

0000000080005de0 <plicinithart>:

void
plicinithart(void)
{
    80005de0:	1141                	addi	sp,sp,-16
    80005de2:	e406                	sd	ra,8(sp)
    80005de4:	e022                	sd	s0,0(sp)
    80005de6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005de8:	ffffc097          	auipc	ra,0xffffc
    80005dec:	b92080e7          	jalr	-1134(ra) # 8000197a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005df0:	0085171b          	slliw	a4,a0,0x8
    80005df4:	0c0027b7          	lui	a5,0xc002
    80005df8:	97ba                	add	a5,a5,a4
    80005dfa:	40200713          	li	a4,1026
    80005dfe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005e02:	00d5151b          	slliw	a0,a0,0xd
    80005e06:	0c2017b7          	lui	a5,0xc201
    80005e0a:	97aa                	add	a5,a5,a0
    80005e0c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005e10:	60a2                	ld	ra,8(sp)
    80005e12:	6402                	ld	s0,0(sp)
    80005e14:	0141                	addi	sp,sp,16
    80005e16:	8082                	ret

0000000080005e18 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005e18:	1141                	addi	sp,sp,-16
    80005e1a:	e406                	sd	ra,8(sp)
    80005e1c:	e022                	sd	s0,0(sp)
    80005e1e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e20:	ffffc097          	auipc	ra,0xffffc
    80005e24:	b5a080e7          	jalr	-1190(ra) # 8000197a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005e28:	00d5151b          	slliw	a0,a0,0xd
    80005e2c:	0c2017b7          	lui	a5,0xc201
    80005e30:	97aa                	add	a5,a5,a0
  return irq;
}
    80005e32:	43c8                	lw	a0,4(a5)
    80005e34:	60a2                	ld	ra,8(sp)
    80005e36:	6402                	ld	s0,0(sp)
    80005e38:	0141                	addi	sp,sp,16
    80005e3a:	8082                	ret

0000000080005e3c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005e3c:	1101                	addi	sp,sp,-32
    80005e3e:	ec06                	sd	ra,24(sp)
    80005e40:	e822                	sd	s0,16(sp)
    80005e42:	e426                	sd	s1,8(sp)
    80005e44:	1000                	addi	s0,sp,32
    80005e46:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005e48:	ffffc097          	auipc	ra,0xffffc
    80005e4c:	b32080e7          	jalr	-1230(ra) # 8000197a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005e50:	00d5151b          	slliw	a0,a0,0xd
    80005e54:	0c2017b7          	lui	a5,0xc201
    80005e58:	97aa                	add	a5,a5,a0
    80005e5a:	c3c4                	sw	s1,4(a5)
}
    80005e5c:	60e2                	ld	ra,24(sp)
    80005e5e:	6442                	ld	s0,16(sp)
    80005e60:	64a2                	ld	s1,8(sp)
    80005e62:	6105                	addi	sp,sp,32
    80005e64:	8082                	ret

0000000080005e66 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005e66:	1141                	addi	sp,sp,-16
    80005e68:	e406                	sd	ra,8(sp)
    80005e6a:	e022                	sd	s0,0(sp)
    80005e6c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005e6e:	479d                	li	a5,7
    80005e70:	04a7cc63          	blt	a5,a0,80005ec8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005e74:	0001c797          	auipc	a5,0x1c
    80005e78:	7cc78793          	addi	a5,a5,1996 # 80022640 <disk>
    80005e7c:	97aa                	add	a5,a5,a0
    80005e7e:	0187c783          	lbu	a5,24(a5)
    80005e82:	ebb9                	bnez	a5,80005ed8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005e84:	00451693          	slli	a3,a0,0x4
    80005e88:	0001c797          	auipc	a5,0x1c
    80005e8c:	7b878793          	addi	a5,a5,1976 # 80022640 <disk>
    80005e90:	6398                	ld	a4,0(a5)
    80005e92:	9736                	add	a4,a4,a3
    80005e94:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005e98:	6398                	ld	a4,0(a5)
    80005e9a:	9736                	add	a4,a4,a3
    80005e9c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005ea0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005ea4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005ea8:	97aa                	add	a5,a5,a0
    80005eaa:	4705                	li	a4,1
    80005eac:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005eb0:	0001c517          	auipc	a0,0x1c
    80005eb4:	7a850513          	addi	a0,a0,1960 # 80022658 <disk+0x18>
    80005eb8:	ffffc097          	auipc	ra,0xffffc
    80005ebc:	21a080e7          	jalr	538(ra) # 800020d2 <wakeup>
}
    80005ec0:	60a2                	ld	ra,8(sp)
    80005ec2:	6402                	ld	s0,0(sp)
    80005ec4:	0141                	addi	sp,sp,16
    80005ec6:	8082                	ret
    panic("free_desc 1");
    80005ec8:	00003517          	auipc	a0,0x3
    80005ecc:	ab850513          	addi	a0,a0,-1352 # 80008980 <syscall_names+0x300>
    80005ed0:	ffffa097          	auipc	ra,0xffffa
    80005ed4:	66c080e7          	jalr	1644(ra) # 8000053c <panic>
    panic("free_desc 2");
    80005ed8:	00003517          	auipc	a0,0x3
    80005edc:	ab850513          	addi	a0,a0,-1352 # 80008990 <syscall_names+0x310>
    80005ee0:	ffffa097          	auipc	ra,0xffffa
    80005ee4:	65c080e7          	jalr	1628(ra) # 8000053c <panic>

0000000080005ee8 <virtio_disk_init>:
{
    80005ee8:	1101                	addi	sp,sp,-32
    80005eea:	ec06                	sd	ra,24(sp)
    80005eec:	e822                	sd	s0,16(sp)
    80005eee:	e426                	sd	s1,8(sp)
    80005ef0:	e04a                	sd	s2,0(sp)
    80005ef2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005ef4:	00003597          	auipc	a1,0x3
    80005ef8:	aac58593          	addi	a1,a1,-1364 # 800089a0 <syscall_names+0x320>
    80005efc:	0001d517          	auipc	a0,0x1d
    80005f00:	86c50513          	addi	a0,a0,-1940 # 80022768 <disk+0x128>
    80005f04:	ffffb097          	auipc	ra,0xffffb
    80005f08:	c3e080e7          	jalr	-962(ra) # 80000b42 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f0c:	100017b7          	lui	a5,0x10001
    80005f10:	4398                	lw	a4,0(a5)
    80005f12:	2701                	sext.w	a4,a4
    80005f14:	747277b7          	lui	a5,0x74727
    80005f18:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005f1c:	14f71b63          	bne	a4,a5,80006072 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005f20:	100017b7          	lui	a5,0x10001
    80005f24:	43dc                	lw	a5,4(a5)
    80005f26:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f28:	4709                	li	a4,2
    80005f2a:	14e79463          	bne	a5,a4,80006072 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f2e:	100017b7          	lui	a5,0x10001
    80005f32:	479c                	lw	a5,8(a5)
    80005f34:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005f36:	12e79e63          	bne	a5,a4,80006072 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005f3a:	100017b7          	lui	a5,0x10001
    80005f3e:	47d8                	lw	a4,12(a5)
    80005f40:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f42:	554d47b7          	lui	a5,0x554d4
    80005f46:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005f4a:	12f71463          	bne	a4,a5,80006072 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f4e:	100017b7          	lui	a5,0x10001
    80005f52:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f56:	4705                	li	a4,1
    80005f58:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f5a:	470d                	li	a4,3
    80005f5c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005f5e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005f60:	c7ffe6b7          	lui	a3,0xc7ffe
    80005f64:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdbfdf>
    80005f68:	8f75                	and	a4,a4,a3
    80005f6a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f6c:	472d                	li	a4,11
    80005f6e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005f70:	5bbc                	lw	a5,112(a5)
    80005f72:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005f76:	8ba1                	andi	a5,a5,8
    80005f78:	10078563          	beqz	a5,80006082 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005f7c:	100017b7          	lui	a5,0x10001
    80005f80:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005f84:	43fc                	lw	a5,68(a5)
    80005f86:	2781                	sext.w	a5,a5
    80005f88:	10079563          	bnez	a5,80006092 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005f8c:	100017b7          	lui	a5,0x10001
    80005f90:	5bdc                	lw	a5,52(a5)
    80005f92:	2781                	sext.w	a5,a5
  if(max == 0)
    80005f94:	10078763          	beqz	a5,800060a2 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80005f98:	471d                	li	a4,7
    80005f9a:	10f77c63          	bgeu	a4,a5,800060b2 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80005f9e:	ffffb097          	auipc	ra,0xffffb
    80005fa2:	b44080e7          	jalr	-1212(ra) # 80000ae2 <kalloc>
    80005fa6:	0001c497          	auipc	s1,0x1c
    80005faa:	69a48493          	addi	s1,s1,1690 # 80022640 <disk>
    80005fae:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005fb0:	ffffb097          	auipc	ra,0xffffb
    80005fb4:	b32080e7          	jalr	-1230(ra) # 80000ae2 <kalloc>
    80005fb8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005fba:	ffffb097          	auipc	ra,0xffffb
    80005fbe:	b28080e7          	jalr	-1240(ra) # 80000ae2 <kalloc>
    80005fc2:	87aa                	mv	a5,a0
    80005fc4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005fc6:	6088                	ld	a0,0(s1)
    80005fc8:	cd6d                	beqz	a0,800060c2 <virtio_disk_init+0x1da>
    80005fca:	0001c717          	auipc	a4,0x1c
    80005fce:	67e73703          	ld	a4,1662(a4) # 80022648 <disk+0x8>
    80005fd2:	cb65                	beqz	a4,800060c2 <virtio_disk_init+0x1da>
    80005fd4:	c7fd                	beqz	a5,800060c2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80005fd6:	6605                	lui	a2,0x1
    80005fd8:	4581                	li	a1,0
    80005fda:	ffffb097          	auipc	ra,0xffffb
    80005fde:	cf4080e7          	jalr	-780(ra) # 80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    80005fe2:	0001c497          	auipc	s1,0x1c
    80005fe6:	65e48493          	addi	s1,s1,1630 # 80022640 <disk>
    80005fea:	6605                	lui	a2,0x1
    80005fec:	4581                	li	a1,0
    80005fee:	6488                	ld	a0,8(s1)
    80005ff0:	ffffb097          	auipc	ra,0xffffb
    80005ff4:	cde080e7          	jalr	-802(ra) # 80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    80005ff8:	6605                	lui	a2,0x1
    80005ffa:	4581                	li	a1,0
    80005ffc:	6888                	ld	a0,16(s1)
    80005ffe:	ffffb097          	auipc	ra,0xffffb
    80006002:	cd0080e7          	jalr	-816(ra) # 80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006006:	100017b7          	lui	a5,0x10001
    8000600a:	4721                	li	a4,8
    8000600c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000600e:	4098                	lw	a4,0(s1)
    80006010:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006014:	40d8                	lw	a4,4(s1)
    80006016:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000601a:	6498                	ld	a4,8(s1)
    8000601c:	0007069b          	sext.w	a3,a4
    80006020:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006024:	9701                	srai	a4,a4,0x20
    80006026:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000602a:	6898                	ld	a4,16(s1)
    8000602c:	0007069b          	sext.w	a3,a4
    80006030:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006034:	9701                	srai	a4,a4,0x20
    80006036:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000603a:	4705                	li	a4,1
    8000603c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000603e:	00e48c23          	sb	a4,24(s1)
    80006042:	00e48ca3          	sb	a4,25(s1)
    80006046:	00e48d23          	sb	a4,26(s1)
    8000604a:	00e48da3          	sb	a4,27(s1)
    8000604e:	00e48e23          	sb	a4,28(s1)
    80006052:	00e48ea3          	sb	a4,29(s1)
    80006056:	00e48f23          	sb	a4,30(s1)
    8000605a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000605e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006062:	0727a823          	sw	s2,112(a5)
}
    80006066:	60e2                	ld	ra,24(sp)
    80006068:	6442                	ld	s0,16(sp)
    8000606a:	64a2                	ld	s1,8(sp)
    8000606c:	6902                	ld	s2,0(sp)
    8000606e:	6105                	addi	sp,sp,32
    80006070:	8082                	ret
    panic("could not find virtio disk");
    80006072:	00003517          	auipc	a0,0x3
    80006076:	93e50513          	addi	a0,a0,-1730 # 800089b0 <syscall_names+0x330>
    8000607a:	ffffa097          	auipc	ra,0xffffa
    8000607e:	4c2080e7          	jalr	1218(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    80006082:	00003517          	auipc	a0,0x3
    80006086:	94e50513          	addi	a0,a0,-1714 # 800089d0 <syscall_names+0x350>
    8000608a:	ffffa097          	auipc	ra,0xffffa
    8000608e:	4b2080e7          	jalr	1202(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    80006092:	00003517          	auipc	a0,0x3
    80006096:	95e50513          	addi	a0,a0,-1698 # 800089f0 <syscall_names+0x370>
    8000609a:	ffffa097          	auipc	ra,0xffffa
    8000609e:	4a2080e7          	jalr	1186(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    800060a2:	00003517          	auipc	a0,0x3
    800060a6:	96e50513          	addi	a0,a0,-1682 # 80008a10 <syscall_names+0x390>
    800060aa:	ffffa097          	auipc	ra,0xffffa
    800060ae:	492080e7          	jalr	1170(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    800060b2:	00003517          	auipc	a0,0x3
    800060b6:	97e50513          	addi	a0,a0,-1666 # 80008a30 <syscall_names+0x3b0>
    800060ba:	ffffa097          	auipc	ra,0xffffa
    800060be:	482080e7          	jalr	1154(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    800060c2:	00003517          	auipc	a0,0x3
    800060c6:	98e50513          	addi	a0,a0,-1650 # 80008a50 <syscall_names+0x3d0>
    800060ca:	ffffa097          	auipc	ra,0xffffa
    800060ce:	472080e7          	jalr	1138(ra) # 8000053c <panic>

00000000800060d2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800060d2:	7159                	addi	sp,sp,-112
    800060d4:	f486                	sd	ra,104(sp)
    800060d6:	f0a2                	sd	s0,96(sp)
    800060d8:	eca6                	sd	s1,88(sp)
    800060da:	e8ca                	sd	s2,80(sp)
    800060dc:	e4ce                	sd	s3,72(sp)
    800060de:	e0d2                	sd	s4,64(sp)
    800060e0:	fc56                	sd	s5,56(sp)
    800060e2:	f85a                	sd	s6,48(sp)
    800060e4:	f45e                	sd	s7,40(sp)
    800060e6:	f062                	sd	s8,32(sp)
    800060e8:	ec66                	sd	s9,24(sp)
    800060ea:	e86a                	sd	s10,16(sp)
    800060ec:	1880                	addi	s0,sp,112
    800060ee:	8a2a                	mv	s4,a0
    800060f0:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800060f2:	00c52c83          	lw	s9,12(a0)
    800060f6:	001c9c9b          	slliw	s9,s9,0x1
    800060fa:	1c82                	slli	s9,s9,0x20
    800060fc:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006100:	0001c517          	auipc	a0,0x1c
    80006104:	66850513          	addi	a0,a0,1640 # 80022768 <disk+0x128>
    80006108:	ffffb097          	auipc	ra,0xffffb
    8000610c:	aca080e7          	jalr	-1334(ra) # 80000bd2 <acquire>
  for(int i = 0; i < 3; i++){
    80006110:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80006112:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006114:	0001cb17          	auipc	s6,0x1c
    80006118:	52cb0b13          	addi	s6,s6,1324 # 80022640 <disk>
  for(int i = 0; i < 3; i++){
    8000611c:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000611e:	0001cc17          	auipc	s8,0x1c
    80006122:	64ac0c13          	addi	s8,s8,1610 # 80022768 <disk+0x128>
    80006126:	a095                	j	8000618a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80006128:	00fb0733          	add	a4,s6,a5
    8000612c:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006130:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    80006132:	0207c563          	bltz	a5,8000615c <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    80006136:	2605                	addiw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    80006138:	0591                	addi	a1,a1,4
    8000613a:	05560d63          	beq	a2,s5,80006194 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    8000613e:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    80006140:	0001c717          	auipc	a4,0x1c
    80006144:	50070713          	addi	a4,a4,1280 # 80022640 <disk>
    80006148:	87ca                	mv	a5,s2
    if(disk.free[i]){
    8000614a:	01874683          	lbu	a3,24(a4)
    8000614e:	fee9                	bnez	a3,80006128 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    80006150:	2785                	addiw	a5,a5,1
    80006152:	0705                	addi	a4,a4,1
    80006154:	fe979be3          	bne	a5,s1,8000614a <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    80006158:	57fd                	li	a5,-1
    8000615a:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    8000615c:	00c05e63          	blez	a2,80006178 <virtio_disk_rw+0xa6>
    80006160:	060a                	slli	a2,a2,0x2
    80006162:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    80006166:	0009a503          	lw	a0,0(s3)
    8000616a:	00000097          	auipc	ra,0x0
    8000616e:	cfc080e7          	jalr	-772(ra) # 80005e66 <free_desc>
      for(int j = 0; j < i; j++)
    80006172:	0991                	addi	s3,s3,4
    80006174:	ffa999e3          	bne	s3,s10,80006166 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006178:	85e2                	mv	a1,s8
    8000617a:	0001c517          	auipc	a0,0x1c
    8000617e:	4de50513          	addi	a0,a0,1246 # 80022658 <disk+0x18>
    80006182:	ffffc097          	auipc	ra,0xffffc
    80006186:	eec080e7          	jalr	-276(ra) # 8000206e <sleep>
  for(int i = 0; i < 3; i++){
    8000618a:	f9040993          	addi	s3,s0,-112
{
    8000618e:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    80006190:	864a                	mv	a2,s2
    80006192:	b775                	j	8000613e <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006194:	f9042503          	lw	a0,-112(s0)
    80006198:	00a50713          	addi	a4,a0,10
    8000619c:	0712                	slli	a4,a4,0x4

  if(write)
    8000619e:	0001c797          	auipc	a5,0x1c
    800061a2:	4a278793          	addi	a5,a5,1186 # 80022640 <disk>
    800061a6:	00e786b3          	add	a3,a5,a4
    800061aa:	01703633          	snez	a2,s7
    800061ae:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800061b0:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800061b4:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800061b8:	f6070613          	addi	a2,a4,-160
    800061bc:	6394                	ld	a3,0(a5)
    800061be:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800061c0:	00870593          	addi	a1,a4,8
    800061c4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800061c6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800061c8:	0007b803          	ld	a6,0(a5)
    800061cc:	9642                	add	a2,a2,a6
    800061ce:	46c1                	li	a3,16
    800061d0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800061d2:	4585                	li	a1,1
    800061d4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800061d8:	f9442683          	lw	a3,-108(s0)
    800061dc:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800061e0:	0692                	slli	a3,a3,0x4
    800061e2:	9836                	add	a6,a6,a3
    800061e4:	058a0613          	addi	a2,s4,88
    800061e8:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800061ec:	0007b803          	ld	a6,0(a5)
    800061f0:	96c2                	add	a3,a3,a6
    800061f2:	40000613          	li	a2,1024
    800061f6:	c690                	sw	a2,8(a3)
  if(write)
    800061f8:	001bb613          	seqz	a2,s7
    800061fc:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006200:	00166613          	ori	a2,a2,1
    80006204:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006208:	f9842603          	lw	a2,-104(s0)
    8000620c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006210:	00250693          	addi	a3,a0,2
    80006214:	0692                	slli	a3,a3,0x4
    80006216:	96be                	add	a3,a3,a5
    80006218:	58fd                	li	a7,-1
    8000621a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000621e:	0612                	slli	a2,a2,0x4
    80006220:	9832                	add	a6,a6,a2
    80006222:	f9070713          	addi	a4,a4,-112
    80006226:	973e                	add	a4,a4,a5
    80006228:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000622c:	6398                	ld	a4,0(a5)
    8000622e:	9732                	add	a4,a4,a2
    80006230:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006232:	4609                	li	a2,2
    80006234:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006238:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000623c:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    80006240:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006244:	6794                	ld	a3,8(a5)
    80006246:	0026d703          	lhu	a4,2(a3)
    8000624a:	8b1d                	andi	a4,a4,7
    8000624c:	0706                	slli	a4,a4,0x1
    8000624e:	96ba                	add	a3,a3,a4
    80006250:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006254:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006258:	6798                	ld	a4,8(a5)
    8000625a:	00275783          	lhu	a5,2(a4)
    8000625e:	2785                	addiw	a5,a5,1
    80006260:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006264:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006268:	100017b7          	lui	a5,0x10001
    8000626c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006270:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006274:	0001c917          	auipc	s2,0x1c
    80006278:	4f490913          	addi	s2,s2,1268 # 80022768 <disk+0x128>
  while(b->disk == 1) {
    8000627c:	4485                	li	s1,1
    8000627e:	00b79c63          	bne	a5,a1,80006296 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006282:	85ca                	mv	a1,s2
    80006284:	8552                	mv	a0,s4
    80006286:	ffffc097          	auipc	ra,0xffffc
    8000628a:	de8080e7          	jalr	-536(ra) # 8000206e <sleep>
  while(b->disk == 1) {
    8000628e:	004a2783          	lw	a5,4(s4)
    80006292:	fe9788e3          	beq	a5,s1,80006282 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006296:	f9042903          	lw	s2,-112(s0)
    8000629a:	00290713          	addi	a4,s2,2
    8000629e:	0712                	slli	a4,a4,0x4
    800062a0:	0001c797          	auipc	a5,0x1c
    800062a4:	3a078793          	addi	a5,a5,928 # 80022640 <disk>
    800062a8:	97ba                	add	a5,a5,a4
    800062aa:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800062ae:	0001c997          	auipc	s3,0x1c
    800062b2:	39298993          	addi	s3,s3,914 # 80022640 <disk>
    800062b6:	00491713          	slli	a4,s2,0x4
    800062ba:	0009b783          	ld	a5,0(s3)
    800062be:	97ba                	add	a5,a5,a4
    800062c0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800062c4:	854a                	mv	a0,s2
    800062c6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800062ca:	00000097          	auipc	ra,0x0
    800062ce:	b9c080e7          	jalr	-1124(ra) # 80005e66 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800062d2:	8885                	andi	s1,s1,1
    800062d4:	f0ed                	bnez	s1,800062b6 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800062d6:	0001c517          	auipc	a0,0x1c
    800062da:	49250513          	addi	a0,a0,1170 # 80022768 <disk+0x128>
    800062de:	ffffb097          	auipc	ra,0xffffb
    800062e2:	9a8080e7          	jalr	-1624(ra) # 80000c86 <release>
}
    800062e6:	70a6                	ld	ra,104(sp)
    800062e8:	7406                	ld	s0,96(sp)
    800062ea:	64e6                	ld	s1,88(sp)
    800062ec:	6946                	ld	s2,80(sp)
    800062ee:	69a6                	ld	s3,72(sp)
    800062f0:	6a06                	ld	s4,64(sp)
    800062f2:	7ae2                	ld	s5,56(sp)
    800062f4:	7b42                	ld	s6,48(sp)
    800062f6:	7ba2                	ld	s7,40(sp)
    800062f8:	7c02                	ld	s8,32(sp)
    800062fa:	6ce2                	ld	s9,24(sp)
    800062fc:	6d42                	ld	s10,16(sp)
    800062fe:	6165                	addi	sp,sp,112
    80006300:	8082                	ret

0000000080006302 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006302:	1101                	addi	sp,sp,-32
    80006304:	ec06                	sd	ra,24(sp)
    80006306:	e822                	sd	s0,16(sp)
    80006308:	e426                	sd	s1,8(sp)
    8000630a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000630c:	0001c497          	auipc	s1,0x1c
    80006310:	33448493          	addi	s1,s1,820 # 80022640 <disk>
    80006314:	0001c517          	auipc	a0,0x1c
    80006318:	45450513          	addi	a0,a0,1108 # 80022768 <disk+0x128>
    8000631c:	ffffb097          	auipc	ra,0xffffb
    80006320:	8b6080e7          	jalr	-1866(ra) # 80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006324:	10001737          	lui	a4,0x10001
    80006328:	533c                	lw	a5,96(a4)
    8000632a:	8b8d                	andi	a5,a5,3
    8000632c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000632e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006332:	689c                	ld	a5,16(s1)
    80006334:	0204d703          	lhu	a4,32(s1)
    80006338:	0027d783          	lhu	a5,2(a5)
    8000633c:	04f70863          	beq	a4,a5,8000638c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006340:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006344:	6898                	ld	a4,16(s1)
    80006346:	0204d783          	lhu	a5,32(s1)
    8000634a:	8b9d                	andi	a5,a5,7
    8000634c:	078e                	slli	a5,a5,0x3
    8000634e:	97ba                	add	a5,a5,a4
    80006350:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006352:	00278713          	addi	a4,a5,2
    80006356:	0712                	slli	a4,a4,0x4
    80006358:	9726                	add	a4,a4,s1
    8000635a:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000635e:	e721                	bnez	a4,800063a6 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006360:	0789                	addi	a5,a5,2
    80006362:	0792                	slli	a5,a5,0x4
    80006364:	97a6                	add	a5,a5,s1
    80006366:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006368:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000636c:	ffffc097          	auipc	ra,0xffffc
    80006370:	d66080e7          	jalr	-666(ra) # 800020d2 <wakeup>

    disk.used_idx += 1;
    80006374:	0204d783          	lhu	a5,32(s1)
    80006378:	2785                	addiw	a5,a5,1
    8000637a:	17c2                	slli	a5,a5,0x30
    8000637c:	93c1                	srli	a5,a5,0x30
    8000637e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006382:	6898                	ld	a4,16(s1)
    80006384:	00275703          	lhu	a4,2(a4)
    80006388:	faf71ce3          	bne	a4,a5,80006340 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000638c:	0001c517          	auipc	a0,0x1c
    80006390:	3dc50513          	addi	a0,a0,988 # 80022768 <disk+0x128>
    80006394:	ffffb097          	auipc	ra,0xffffb
    80006398:	8f2080e7          	jalr	-1806(ra) # 80000c86 <release>
}
    8000639c:	60e2                	ld	ra,24(sp)
    8000639e:	6442                	ld	s0,16(sp)
    800063a0:	64a2                	ld	s1,8(sp)
    800063a2:	6105                	addi	sp,sp,32
    800063a4:	8082                	ret
      panic("virtio_disk_intr status");
    800063a6:	00002517          	auipc	a0,0x2
    800063aa:	6c250513          	addi	a0,a0,1730 # 80008a68 <syscall_names+0x3e8>
    800063ae:	ffffa097          	auipc	ra,0xffffa
    800063b2:	18e080e7          	jalr	398(ra) # 8000053c <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
