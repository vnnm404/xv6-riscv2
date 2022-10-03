
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	c1010113          	addi	sp,sp,-1008 # 80008c10 <stack0>
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
    80000054:	a8070713          	addi	a4,a4,-1408 # 80008ad0 <timer_scratch>
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
    80000066:	c3e78793          	addi	a5,a5,-962 # 80005ca0 <timervec>
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
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc6bf>
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
    8000012e:	38e080e7          	jalr	910(ra) # 800024b8 <either_copyin>
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
    80000188:	a8c50513          	addi	a0,a0,-1396 # 80010c10 <cons>
    8000018c:	00001097          	auipc	ra,0x1
    80000190:	a46080e7          	jalr	-1466(ra) # 80000bd2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000194:	00011497          	auipc	s1,0x11
    80000198:	a7c48493          	addi	s1,s1,-1412 # 80010c10 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000019c:	00011917          	auipc	s2,0x11
    800001a0:	b0c90913          	addi	s2,s2,-1268 # 80010ca8 <cons+0x98>
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
    800001c0:	146080e7          	jalr	326(ra) # 80002302 <killed>
    800001c4:	ed2d                	bnez	a0,8000023e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001c6:	85a6                	mv	a1,s1
    800001c8:	854a                	mv	a0,s2
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	e90080e7          	jalr	-368(ra) # 8000205a <sleep>
    while(cons.r == cons.w){
    800001d2:	0984a783          	lw	a5,152(s1)
    800001d6:	09c4a703          	lw	a4,156(s1)
    800001da:	fcf70de3          	beq	a4,a5,800001b4 <consoleread+0x50>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00011717          	auipc	a4,0x11
    800001e2:	a3270713          	addi	a4,a4,-1486 # 80010c10 <cons>
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
    80000214:	252080e7          	jalr	594(ra) # 80002462 <either_copyout>
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
    8000022c:	9e850513          	addi	a0,a0,-1560 # 80010c10 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a56080e7          	jalr	-1450(ra) # 80000c86 <release>

  return target - n;
    80000238:	413b053b          	subw	a0,s6,s3
    8000023c:	a811                	j	80000250 <consoleread+0xec>
        release(&cons.lock);
    8000023e:	00011517          	auipc	a0,0x11
    80000242:	9d250513          	addi	a0,a0,-1582 # 80010c10 <cons>
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
    80000272:	a2f72d23          	sw	a5,-1478(a4) # 80010ca8 <cons+0x98>
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
    800002cc:	94850513          	addi	a0,a0,-1720 # 80010c10 <cons>
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
    800002f2:	220080e7          	jalr	544(ra) # 8000250e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f6:	00011517          	auipc	a0,0x11
    800002fa:	91a50513          	addi	a0,a0,-1766 # 80010c10 <cons>
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
    8000031e:	8f670713          	addi	a4,a4,-1802 # 80010c10 <cons>
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
    80000348:	8cc78793          	addi	a5,a5,-1844 # 80010c10 <cons>
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
    80000376:	9367a783          	lw	a5,-1738(a5) # 80010ca8 <cons+0x98>
    8000037a:	9f1d                	subw	a4,a4,a5
    8000037c:	08000793          	li	a5,128
    80000380:	f6f71be3          	bne	a4,a5,800002f6 <consoleintr+0x3c>
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000386:	00011717          	auipc	a4,0x11
    8000038a:	88a70713          	addi	a4,a4,-1910 # 80010c10 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000396:	00011497          	auipc	s1,0x11
    8000039a:	87a48493          	addi	s1,s1,-1926 # 80010c10 <cons>
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
    800003d6:	83e70713          	addi	a4,a4,-1986 # 80010c10 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003e6:	37fd                	addiw	a5,a5,-1
    800003e8:	00011717          	auipc	a4,0x11
    800003ec:	8cf72423          	sw	a5,-1848(a4) # 80010cb0 <cons+0xa0>
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
    80000412:	80278793          	addi	a5,a5,-2046 # 80010c10 <cons>
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
    80000436:	86c7ad23          	sw	a2,-1926(a5) # 80010cac <cons+0x9c>
        wakeup(&cons.r);
    8000043a:	00011517          	auipc	a0,0x11
    8000043e:	86e50513          	addi	a0,a0,-1938 # 80010ca8 <cons+0x98>
    80000442:	00002097          	auipc	ra,0x2
    80000446:	c7c080e7          	jalr	-900(ra) # 800020be <wakeup>
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
    80000460:	7b450513          	addi	a0,a0,1972 # 80010c10 <cons>
    80000464:	00000097          	auipc	ra,0x0
    80000468:	6de080e7          	jalr	1758(ra) # 80000b42 <initlock>

  uartinit();
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	32c080e7          	jalr	812(ra) # 80000798 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000474:	00021797          	auipc	a5,0x21
    80000478:	b3478793          	addi	a5,a5,-1228 # 80020fa8 <devsw>
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
    8000054c:	7807a423          	sw	zero,1928(a5) # 80010cd0 <pr+0x18>
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
    80000580:	50f72a23          	sw	a5,1300(a4) # 80008a90 <panicked>
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
    800005bc:	718dad83          	lw	s11,1816(s11) # 80010cd0 <pr+0x18>
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
    800005fa:	6c250513          	addi	a0,a0,1730 # 80010cb8 <pr>
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
    80000758:	56450513          	addi	a0,a0,1380 # 80010cb8 <pr>
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
    80000774:	54848493          	addi	s1,s1,1352 # 80010cb8 <pr>
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
    800007d4:	50850513          	addi	a0,a0,1288 # 80010cd8 <uart_tx_lock>
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
    80000800:	2947a783          	lw	a5,660(a5) # 80008a90 <panicked>
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
    80000838:	2647b783          	ld	a5,612(a5) # 80008a98 <uart_tx_r>
    8000083c:	00008717          	auipc	a4,0x8
    80000840:	26473703          	ld	a4,612(a4) # 80008aa0 <uart_tx_w>
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
    80000862:	47aa0a13          	addi	s4,s4,1146 # 80010cd8 <uart_tx_lock>
    uart_tx_r += 1;
    80000866:	00008497          	auipc	s1,0x8
    8000086a:	23248493          	addi	s1,s1,562 # 80008a98 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086e:	00008997          	auipc	s3,0x8
    80000872:	23298993          	addi	s3,s3,562 # 80008aa0 <uart_tx_w>
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
    80000894:	82e080e7          	jalr	-2002(ra) # 800020be <wakeup>
    
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
    800008d0:	40c50513          	addi	a0,a0,1036 # 80010cd8 <uart_tx_lock>
    800008d4:	00000097          	auipc	ra,0x0
    800008d8:	2fe080e7          	jalr	766(ra) # 80000bd2 <acquire>
  if(panicked){
    800008dc:	00008797          	auipc	a5,0x8
    800008e0:	1b47a783          	lw	a5,436(a5) # 80008a90 <panicked>
    800008e4:	e7c9                	bnez	a5,8000096e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	1ba73703          	ld	a4,442(a4) # 80008aa0 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	1aa7b783          	ld	a5,426(a5) # 80008a98 <uart_tx_r>
    800008f6:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fa:	00010997          	auipc	s3,0x10
    800008fe:	3de98993          	addi	s3,s3,990 # 80010cd8 <uart_tx_lock>
    80000902:	00008497          	auipc	s1,0x8
    80000906:	19648493          	addi	s1,s1,406 # 80008a98 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090a:	00008917          	auipc	s2,0x8
    8000090e:	19690913          	addi	s2,s2,406 # 80008aa0 <uart_tx_w>
    80000912:	00e79f63          	bne	a5,a4,80000930 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00001097          	auipc	ra,0x1
    8000091e:	740080e7          	jalr	1856(ra) # 8000205a <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	addi	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00010497          	auipc	s1,0x10
    80000934:	3a848493          	addi	s1,s1,936 # 80010cd8 <uart_tx_lock>
    80000938:	01f77793          	andi	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000942:	0705                	addi	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	14e7be23          	sd	a4,348(a5) # 80008aa0 <uart_tx_w>
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
    800009ba:	32248493          	addi	s1,s1,802 # 80010cd8 <uart_tx_lock>
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
    800009f8:	00021797          	auipc	a5,0x21
    800009fc:	74878793          	addi	a5,a5,1864 # 80022140 <end>
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
    80000a1c:	2f890913          	addi	s2,s2,760 # 80010d10 <kmem>
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
    80000aba:	25a50513          	addi	a0,a0,602 # 80010d10 <kmem>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	084080e7          	jalr	132(ra) # 80000b42 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac6:	45c5                	li	a1,17
    80000ac8:	05ee                	slli	a1,a1,0x1b
    80000aca:	00021517          	auipc	a0,0x21
    80000ace:	67650513          	addi	a0,a0,1654 # 80022140 <end>
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
    80000af0:	22448493          	addi	s1,s1,548 # 80010d10 <kmem>
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
    80000b08:	20c50513          	addi	a0,a0,524 # 80010d10 <kmem>
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
    80000b34:	1e050513          	addi	a0,a0,480 # 80010d10 <kmem>
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
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b90:	100024f3          	csrr	s1,sstatus
    80000b94:	100027f3          	csrr	a5,sstatus
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
    80000d42:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdcec1>
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
    80000e86:	c2670713          	addi	a4,a4,-986 # 80008aa8 <started>
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
    80000ebc:	79a080e7          	jalr	1946(ra) # 80002652 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	e20080e7          	jalr	-480(ra) # 80005ce0 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	fe0080e7          	jalr	-32(ra) # 80001ea8 <scheduler>
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
    80000f34:	6fa080e7          	jalr	1786(ra) # 8000262a <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00001097          	auipc	ra,0x1
    80000f3c:	71a080e7          	jalr	1818(ra) # 80002652 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	d8a080e7          	jalr	-630(ra) # 80005cca <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	d98080e7          	jalr	-616(ra) # 80005ce0 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	f90080e7          	jalr	-112(ra) # 80002ee0 <binit>
    iinit();         // inode table
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	62e080e7          	jalr	1582(ra) # 80003586 <iinit>
    fileinit();      // file table
    80000f60:	00003097          	auipc	ra,0x3
    80000f64:	5a4080e7          	jalr	1444(ra) # 80004504 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	e80080e7          	jalr	-384(ra) # 80005de8 <virtio_disk_init>
    userinit();      // first user process
    80000f70:	00001097          	auipc	ra,0x1
    80000f74:	d12080e7          	jalr	-750(ra) # 80001c82 <userinit>
    __sync_synchronize();
    80000f78:	0ff0000f          	fence
    started = 1;
    80000f7c:	4785                	li	a5,1
    80000f7e:	00008717          	auipc	a4,0x8
    80000f82:	b2f72523          	sw	a5,-1238(a4) # 80008aa8 <started>
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
    80000f96:	b1e7b783          	ld	a5,-1250(a5) # 80008ab0 <kernel_pagetable>
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
    80001010:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdceb7>
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
    80001252:	86a7b123          	sd	a0,-1950(a5) # 80008ab0 <kernel_pagetable>
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
    80001804:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdcec0>
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
    8000184a:	91a48493          	addi	s1,s1,-1766 # 80011160 <proc>
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
    80001860:	00015a17          	auipc	s4,0x15
    80001864:	500a0a13          	addi	s4,s4,1280 # 80016d60 <tickslock>
    char *pa = kalloc();
    80001868:	fffff097          	auipc	ra,0xfffff
    8000186c:	27a080e7          	jalr	634(ra) # 80000ae2 <kalloc>
    80001870:	862a                	mv	a2,a0
    if(pa == 0)
    80001872:	c131                	beqz	a0,800018b6 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001874:	416485b3          	sub	a1,s1,s6
    80001878:	8591                	srai	a1,a1,0x4
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
    8000189a:	17048493          	addi	s1,s1,368
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
    800018e6:	44e50513          	addi	a0,a0,1102 # 80010d30 <pid_lock>
    800018ea:	fffff097          	auipc	ra,0xfffff
    800018ee:	258080e7          	jalr	600(ra) # 80000b42 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f2:	00007597          	auipc	a1,0x7
    800018f6:	8f658593          	addi	a1,a1,-1802 # 800081e8 <digits+0x1a8>
    800018fa:	0000f517          	auipc	a0,0xf
    800018fe:	44e50513          	addi	a0,a0,1102 # 80010d48 <wait_lock>
    80001902:	fffff097          	auipc	ra,0xfffff
    80001906:	240080e7          	jalr	576(ra) # 80000b42 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000190a:	00010497          	auipc	s1,0x10
    8000190e:	85648493          	addi	s1,s1,-1962 # 80011160 <proc>
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
    8000192c:	00015997          	auipc	s3,0x15
    80001930:	43498993          	addi	s3,s3,1076 # 80016d60 <tickslock>
      initlock(&p->lock, "proc");
    80001934:	85da                	mv	a1,s6
    80001936:	8526                	mv	a0,s1
    80001938:	fffff097          	auipc	ra,0xfffff
    8000193c:	20a080e7          	jalr	522(ra) # 80000b42 <initlock>
      p->state = UNUSED;
    80001940:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001944:	415487b3          	sub	a5,s1,s5
    80001948:	8791                	srai	a5,a5,0x4
    8000194a:	000a3703          	ld	a4,0(s4)
    8000194e:	02e787b3          	mul	a5,a5,a4
    80001952:	2785                	addiw	a5,a5,1
    80001954:	00d7979b          	slliw	a5,a5,0xd
    80001958:	40f907b3          	sub	a5,s2,a5
    8000195c:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000195e:	17048493          	addi	s1,s1,368
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
    8000199a:	3ca50513          	addi	a0,a0,970 # 80010d60 <cpus>
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
    800019c2:	37270713          	addi	a4,a4,882 # 80010d30 <pid_lock>
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
    800019fa:	04a7a783          	lw	a5,74(a5) # 80008a40 <first.1>
    800019fe:	eb89                	bnez	a5,80001a10 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a00:	00001097          	auipc	ra,0x1
    80001a04:	c6a080e7          	jalr	-918(ra) # 8000266a <usertrapret>
}
    80001a08:	60a2                	ld	ra,8(sp)
    80001a0a:	6402                	ld	s0,0(sp)
    80001a0c:	0141                	addi	sp,sp,16
    80001a0e:	8082                	ret
    first = 0;
    80001a10:	00007797          	auipc	a5,0x7
    80001a14:	0207a823          	sw	zero,48(a5) # 80008a40 <first.1>
    fsinit(ROOTDEV);
    80001a18:	4505                	li	a0,1
    80001a1a:	00002097          	auipc	ra,0x2
    80001a1e:	aec080e7          	jalr	-1300(ra) # 80003506 <fsinit>
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
    80001a34:	30090913          	addi	s2,s2,768 # 80010d30 <pid_lock>
    80001a38:	854a                	mv	a0,s2
    80001a3a:	fffff097          	auipc	ra,0xfffff
    80001a3e:	198080e7          	jalr	408(ra) # 80000bd2 <acquire>
  pid = nextpid;
    80001a42:	00007797          	auipc	a5,0x7
    80001a46:	00278793          	addi	a5,a5,2 # 80008a44 <nextpid>
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
}
    80001baa:	60e2                	ld	ra,24(sp)
    80001bac:	6442                	ld	s0,16(sp)
    80001bae:	64a2                	ld	s1,8(sp)
    80001bb0:	6105                	addi	sp,sp,32
    80001bb2:	8082                	ret

0000000080001bb4 <allocproc>:
{
    80001bb4:	1101                	addi	sp,sp,-32
    80001bb6:	ec06                	sd	ra,24(sp)
    80001bb8:	e822                	sd	s0,16(sp)
    80001bba:	e426                	sd	s1,8(sp)
    80001bbc:	e04a                	sd	s2,0(sp)
    80001bbe:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bc0:	0000f497          	auipc	s1,0xf
    80001bc4:	5a048493          	addi	s1,s1,1440 # 80011160 <proc>
    80001bc8:	00015917          	auipc	s2,0x15
    80001bcc:	19890913          	addi	s2,s2,408 # 80016d60 <tickslock>
    acquire(&p->lock);
    80001bd0:	8526                	mv	a0,s1
    80001bd2:	fffff097          	auipc	ra,0xfffff
    80001bd6:	000080e7          	jalr	ra # 80000bd2 <acquire>
    if(p->state == UNUSED) {
    80001bda:	4c9c                	lw	a5,24(s1)
    80001bdc:	cf81                	beqz	a5,80001bf4 <allocproc+0x40>
      release(&p->lock);
    80001bde:	8526                	mv	a0,s1
    80001be0:	fffff097          	auipc	ra,0xfffff
    80001be4:	0a6080e7          	jalr	166(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001be8:	17048493          	addi	s1,s1,368
    80001bec:	ff2492e3          	bne	s1,s2,80001bd0 <allocproc+0x1c>
  return 0;
    80001bf0:	4481                	li	s1,0
    80001bf2:	a889                	j	80001c44 <allocproc+0x90>
  p->pid = allocpid();
    80001bf4:	00000097          	auipc	ra,0x0
    80001bf8:	e30080e7          	jalr	-464(ra) # 80001a24 <allocpid>
    80001bfc:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bfe:	4785                	li	a5,1
    80001c00:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c02:	fffff097          	auipc	ra,0xfffff
    80001c06:	ee0080e7          	jalr	-288(ra) # 80000ae2 <kalloc>
    80001c0a:	892a                	mv	s2,a0
    80001c0c:	eca8                	sd	a0,88(s1)
    80001c0e:	c131                	beqz	a0,80001c52 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c10:	8526                	mv	a0,s1
    80001c12:	00000097          	auipc	ra,0x0
    80001c16:	e58080e7          	jalr	-424(ra) # 80001a6a <proc_pagetable>
    80001c1a:	892a                	mv	s2,a0
    80001c1c:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c1e:	c531                	beqz	a0,80001c6a <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c20:	07000613          	li	a2,112
    80001c24:	4581                	li	a1,0
    80001c26:	06048513          	addi	a0,s1,96
    80001c2a:	fffff097          	auipc	ra,0xfffff
    80001c2e:	0a4080e7          	jalr	164(ra) # 80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001c32:	00000797          	auipc	a5,0x0
    80001c36:	dac78793          	addi	a5,a5,-596 # 800019de <forkret>
    80001c3a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c3c:	60bc                	ld	a5,64(s1)
    80001c3e:	6705                	lui	a4,0x1
    80001c40:	97ba                	add	a5,a5,a4
    80001c42:	f4bc                	sd	a5,104(s1)
}
    80001c44:	8526                	mv	a0,s1
    80001c46:	60e2                	ld	ra,24(sp)
    80001c48:	6442                	ld	s0,16(sp)
    80001c4a:	64a2                	ld	s1,8(sp)
    80001c4c:	6902                	ld	s2,0(sp)
    80001c4e:	6105                	addi	sp,sp,32
    80001c50:	8082                	ret
    freeproc(p);
    80001c52:	8526                	mv	a0,s1
    80001c54:	00000097          	auipc	ra,0x0
    80001c58:	f04080e7          	jalr	-252(ra) # 80001b58 <freeproc>
    release(&p->lock);
    80001c5c:	8526                	mv	a0,s1
    80001c5e:	fffff097          	auipc	ra,0xfffff
    80001c62:	028080e7          	jalr	40(ra) # 80000c86 <release>
    return 0;
    80001c66:	84ca                	mv	s1,s2
    80001c68:	bff1                	j	80001c44 <allocproc+0x90>
    freeproc(p);
    80001c6a:	8526                	mv	a0,s1
    80001c6c:	00000097          	auipc	ra,0x0
    80001c70:	eec080e7          	jalr	-276(ra) # 80001b58 <freeproc>
    release(&p->lock);
    80001c74:	8526                	mv	a0,s1
    80001c76:	fffff097          	auipc	ra,0xfffff
    80001c7a:	010080e7          	jalr	16(ra) # 80000c86 <release>
    return 0;
    80001c7e:	84ca                	mv	s1,s2
    80001c80:	b7d1                	j	80001c44 <allocproc+0x90>

0000000080001c82 <userinit>:
{
    80001c82:	1101                	addi	sp,sp,-32
    80001c84:	ec06                	sd	ra,24(sp)
    80001c86:	e822                	sd	s0,16(sp)
    80001c88:	e426                	sd	s1,8(sp)
    80001c8a:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c8c:	00000097          	auipc	ra,0x0
    80001c90:	f28080e7          	jalr	-216(ra) # 80001bb4 <allocproc>
    80001c94:	84aa                	mv	s1,a0
  initproc = p;
    80001c96:	00007797          	auipc	a5,0x7
    80001c9a:	e2a7b123          	sd	a0,-478(a5) # 80008ab8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001c9e:	03400613          	li	a2,52
    80001ca2:	00007597          	auipc	a1,0x7
    80001ca6:	dae58593          	addi	a1,a1,-594 # 80008a50 <initcode>
    80001caa:	6928                	ld	a0,80(a0)
    80001cac:	fffff097          	auipc	ra,0xfffff
    80001cb0:	6a4080e7          	jalr	1700(ra) # 80001350 <uvmfirst>
  p->sz = PGSIZE;
    80001cb4:	6785                	lui	a5,0x1
    80001cb6:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cb8:	6cb8                	ld	a4,88(s1)
    80001cba:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cbe:	6cb8                	ld	a4,88(s1)
    80001cc0:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cc2:	4641                	li	a2,16
    80001cc4:	00006597          	auipc	a1,0x6
    80001cc8:	53c58593          	addi	a1,a1,1340 # 80008200 <digits+0x1c0>
    80001ccc:	15848513          	addi	a0,s1,344
    80001cd0:	fffff097          	auipc	ra,0xfffff
    80001cd4:	146080e7          	jalr	326(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001cd8:	00006517          	auipc	a0,0x6
    80001cdc:	53850513          	addi	a0,a0,1336 # 80008210 <digits+0x1d0>
    80001ce0:	00002097          	auipc	ra,0x2
    80001ce4:	244080e7          	jalr	580(ra) # 80003f24 <namei>
    80001ce8:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001cec:	478d                	li	a5,3
    80001cee:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001cf0:	8526                	mv	a0,s1
    80001cf2:	fffff097          	auipc	ra,0xfffff
    80001cf6:	f94080e7          	jalr	-108(ra) # 80000c86 <release>
}
    80001cfa:	60e2                	ld	ra,24(sp)
    80001cfc:	6442                	ld	s0,16(sp)
    80001cfe:	64a2                	ld	s1,8(sp)
    80001d00:	6105                	addi	sp,sp,32
    80001d02:	8082                	ret

0000000080001d04 <growproc>:
{
    80001d04:	1101                	addi	sp,sp,-32
    80001d06:	ec06                	sd	ra,24(sp)
    80001d08:	e822                	sd	s0,16(sp)
    80001d0a:	e426                	sd	s1,8(sp)
    80001d0c:	e04a                	sd	s2,0(sp)
    80001d0e:	1000                	addi	s0,sp,32
    80001d10:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d12:	00000097          	auipc	ra,0x0
    80001d16:	c94080e7          	jalr	-876(ra) # 800019a6 <myproc>
    80001d1a:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d1c:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d1e:	01204c63          	bgtz	s2,80001d36 <growproc+0x32>
  } else if(n < 0){
    80001d22:	02094663          	bltz	s2,80001d4e <growproc+0x4a>
  p->sz = sz;
    80001d26:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d28:	4501                	li	a0,0
}
    80001d2a:	60e2                	ld	ra,24(sp)
    80001d2c:	6442                	ld	s0,16(sp)
    80001d2e:	64a2                	ld	s1,8(sp)
    80001d30:	6902                	ld	s2,0(sp)
    80001d32:	6105                	addi	sp,sp,32
    80001d34:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d36:	4691                	li	a3,4
    80001d38:	00b90633          	add	a2,s2,a1
    80001d3c:	6928                	ld	a0,80(a0)
    80001d3e:	fffff097          	auipc	ra,0xfffff
    80001d42:	6cc080e7          	jalr	1740(ra) # 8000140a <uvmalloc>
    80001d46:	85aa                	mv	a1,a0
    80001d48:	fd79                	bnez	a0,80001d26 <growproc+0x22>
      return -1;
    80001d4a:	557d                	li	a0,-1
    80001d4c:	bff9                	j	80001d2a <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d4e:	00b90633          	add	a2,s2,a1
    80001d52:	6928                	ld	a0,80(a0)
    80001d54:	fffff097          	auipc	ra,0xfffff
    80001d58:	66e080e7          	jalr	1646(ra) # 800013c2 <uvmdealloc>
    80001d5c:	85aa                	mv	a1,a0
    80001d5e:	b7e1                	j	80001d26 <growproc+0x22>

0000000080001d60 <fork>:
{
    80001d60:	7139                	addi	sp,sp,-64
    80001d62:	fc06                	sd	ra,56(sp)
    80001d64:	f822                	sd	s0,48(sp)
    80001d66:	f426                	sd	s1,40(sp)
    80001d68:	f04a                	sd	s2,32(sp)
    80001d6a:	ec4e                	sd	s3,24(sp)
    80001d6c:	e852                	sd	s4,16(sp)
    80001d6e:	e456                	sd	s5,8(sp)
    80001d70:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d72:	00000097          	auipc	ra,0x0
    80001d76:	c34080e7          	jalr	-972(ra) # 800019a6 <myproc>
    80001d7a:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d7c:	00000097          	auipc	ra,0x0
    80001d80:	e38080e7          	jalr	-456(ra) # 80001bb4 <allocproc>
    80001d84:	12050063          	beqz	a0,80001ea4 <fork+0x144>
    80001d88:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d8a:	048ab603          	ld	a2,72(s5)
    80001d8e:	692c                	ld	a1,80(a0)
    80001d90:	050ab503          	ld	a0,80(s5)
    80001d94:	fffff097          	auipc	ra,0xfffff
    80001d98:	7ce080e7          	jalr	1998(ra) # 80001562 <uvmcopy>
    80001d9c:	04054863          	bltz	a0,80001dec <fork+0x8c>
  np->sz = p->sz;
    80001da0:	048ab783          	ld	a5,72(s5)
    80001da4:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001da8:	058ab683          	ld	a3,88(s5)
    80001dac:	87b6                	mv	a5,a3
    80001dae:	0589b703          	ld	a4,88(s3)
    80001db2:	12068693          	addi	a3,a3,288
    80001db6:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dba:	6788                	ld	a0,8(a5)
    80001dbc:	6b8c                	ld	a1,16(a5)
    80001dbe:	6f90                	ld	a2,24(a5)
    80001dc0:	01073023          	sd	a6,0(a4)
    80001dc4:	e708                	sd	a0,8(a4)
    80001dc6:	eb0c                	sd	a1,16(a4)
    80001dc8:	ef10                	sd	a2,24(a4)
    80001dca:	02078793          	addi	a5,a5,32
    80001dce:	02070713          	addi	a4,a4,32
    80001dd2:	fed792e3          	bne	a5,a3,80001db6 <fork+0x56>
  np->trapframe->a0 = 0;
    80001dd6:	0589b783          	ld	a5,88(s3)
    80001dda:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001dde:	0d0a8493          	addi	s1,s5,208
    80001de2:	0d098913          	addi	s2,s3,208
    80001de6:	150a8a13          	addi	s4,s5,336
    80001dea:	a00d                	j	80001e0c <fork+0xac>
    freeproc(np);
    80001dec:	854e                	mv	a0,s3
    80001dee:	00000097          	auipc	ra,0x0
    80001df2:	d6a080e7          	jalr	-662(ra) # 80001b58 <freeproc>
    release(&np->lock);
    80001df6:	854e                	mv	a0,s3
    80001df8:	fffff097          	auipc	ra,0xfffff
    80001dfc:	e8e080e7          	jalr	-370(ra) # 80000c86 <release>
    return -1;
    80001e00:	597d                	li	s2,-1
    80001e02:	a079                	j	80001e90 <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001e04:	04a1                	addi	s1,s1,8
    80001e06:	0921                	addi	s2,s2,8
    80001e08:	01448b63          	beq	s1,s4,80001e1e <fork+0xbe>
    if(p->ofile[i])
    80001e0c:	6088                	ld	a0,0(s1)
    80001e0e:	d97d                	beqz	a0,80001e04 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e10:	00002097          	auipc	ra,0x2
    80001e14:	786080e7          	jalr	1926(ra) # 80004596 <filedup>
    80001e18:	00a93023          	sd	a0,0(s2)
    80001e1c:	b7e5                	j	80001e04 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e1e:	150ab503          	ld	a0,336(s5)
    80001e22:	00002097          	auipc	ra,0x2
    80001e26:	91e080e7          	jalr	-1762(ra) # 80003740 <idup>
    80001e2a:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e2e:	4641                	li	a2,16
    80001e30:	158a8593          	addi	a1,s5,344
    80001e34:	15898513          	addi	a0,s3,344
    80001e38:	fffff097          	auipc	ra,0xfffff
    80001e3c:	fde080e7          	jalr	-34(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    80001e40:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001e44:	854e                	mv	a0,s3
    80001e46:	fffff097          	auipc	ra,0xfffff
    80001e4a:	e40080e7          	jalr	-448(ra) # 80000c86 <release>
  acquire(&wait_lock);
    80001e4e:	0000f497          	auipc	s1,0xf
    80001e52:	efa48493          	addi	s1,s1,-262 # 80010d48 <wait_lock>
    80001e56:	8526                	mv	a0,s1
    80001e58:	fffff097          	auipc	ra,0xfffff
    80001e5c:	d7a080e7          	jalr	-646(ra) # 80000bd2 <acquire>
  np->parent = p;
    80001e60:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001e64:	8526                	mv	a0,s1
    80001e66:	fffff097          	auipc	ra,0xfffff
    80001e6a:	e20080e7          	jalr	-480(ra) # 80000c86 <release>
  acquire(&np->lock);
    80001e6e:	854e                	mv	a0,s3
    80001e70:	fffff097          	auipc	ra,0xfffff
    80001e74:	d62080e7          	jalr	-670(ra) # 80000bd2 <acquire>
  np->state = RUNNABLE;
    80001e78:	478d                	li	a5,3
    80001e7a:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001e7e:	854e                	mv	a0,s3
    80001e80:	fffff097          	auipc	ra,0xfffff
    80001e84:	e06080e7          	jalr	-506(ra) # 80000c86 <release>
  np->smask = p->smask;
    80001e88:	168aa783          	lw	a5,360(s5)
    80001e8c:	16f9a423          	sw	a5,360(s3)
}
    80001e90:	854a                	mv	a0,s2
    80001e92:	70e2                	ld	ra,56(sp)
    80001e94:	7442                	ld	s0,48(sp)
    80001e96:	74a2                	ld	s1,40(sp)
    80001e98:	7902                	ld	s2,32(sp)
    80001e9a:	69e2                	ld	s3,24(sp)
    80001e9c:	6a42                	ld	s4,16(sp)
    80001e9e:	6aa2                	ld	s5,8(sp)
    80001ea0:	6121                	addi	sp,sp,64
    80001ea2:	8082                	ret
    return -1;
    80001ea4:	597d                	li	s2,-1
    80001ea6:	b7ed                	j	80001e90 <fork+0x130>

0000000080001ea8 <scheduler>:
{
    80001ea8:	7139                	addi	sp,sp,-64
    80001eaa:	fc06                	sd	ra,56(sp)
    80001eac:	f822                	sd	s0,48(sp)
    80001eae:	f426                	sd	s1,40(sp)
    80001eb0:	f04a                	sd	s2,32(sp)
    80001eb2:	ec4e                	sd	s3,24(sp)
    80001eb4:	e852                	sd	s4,16(sp)
    80001eb6:	e456                	sd	s5,8(sp)
    80001eb8:	e05a                	sd	s6,0(sp)
    80001eba:	0080                	addi	s0,sp,64
    80001ebc:	8792                	mv	a5,tp
  int id = r_tp();
    80001ebe:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ec0:	00779a93          	slli	s5,a5,0x7
    80001ec4:	0000f717          	auipc	a4,0xf
    80001ec8:	e6c70713          	addi	a4,a4,-404 # 80010d30 <pid_lock>
    80001ecc:	9756                	add	a4,a4,s5
    80001ece:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ed2:	0000f717          	auipc	a4,0xf
    80001ed6:	e9670713          	addi	a4,a4,-362 # 80010d68 <cpus+0x8>
    80001eda:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001edc:	498d                	li	s3,3
        p->state = RUNNING;
    80001ede:	4b11                	li	s6,4
        c->proc = p;
    80001ee0:	079e                	slli	a5,a5,0x7
    80001ee2:	0000fa17          	auipc	s4,0xf
    80001ee6:	e4ea0a13          	addi	s4,s4,-434 # 80010d30 <pid_lock>
    80001eea:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001eec:	00015917          	auipc	s2,0x15
    80001ef0:	e7490913          	addi	s2,s2,-396 # 80016d60 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ef4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ef8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001efc:	10079073          	csrw	sstatus,a5
    80001f00:	0000f497          	auipc	s1,0xf
    80001f04:	26048493          	addi	s1,s1,608 # 80011160 <proc>
    80001f08:	a811                	j	80001f1c <scheduler+0x74>
      release(&p->lock);
    80001f0a:	8526                	mv	a0,s1
    80001f0c:	fffff097          	auipc	ra,0xfffff
    80001f10:	d7a080e7          	jalr	-646(ra) # 80000c86 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f14:	17048493          	addi	s1,s1,368
    80001f18:	fd248ee3          	beq	s1,s2,80001ef4 <scheduler+0x4c>
      acquire(&p->lock);
    80001f1c:	8526                	mv	a0,s1
    80001f1e:	fffff097          	auipc	ra,0xfffff
    80001f22:	cb4080e7          	jalr	-844(ra) # 80000bd2 <acquire>
      if(p->state == RUNNABLE) {
    80001f26:	4c9c                	lw	a5,24(s1)
    80001f28:	ff3791e3          	bne	a5,s3,80001f0a <scheduler+0x62>
        p->state = RUNNING;
    80001f2c:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f30:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f34:	06048593          	addi	a1,s1,96
    80001f38:	8556                	mv	a0,s5
    80001f3a:	00000097          	auipc	ra,0x0
    80001f3e:	686080e7          	jalr	1670(ra) # 800025c0 <swtch>
        c->proc = 0;
    80001f42:	020a3823          	sd	zero,48(s4)
    80001f46:	b7d1                	j	80001f0a <scheduler+0x62>

0000000080001f48 <sched>:
{
    80001f48:	7179                	addi	sp,sp,-48
    80001f4a:	f406                	sd	ra,40(sp)
    80001f4c:	f022                	sd	s0,32(sp)
    80001f4e:	ec26                	sd	s1,24(sp)
    80001f50:	e84a                	sd	s2,16(sp)
    80001f52:	e44e                	sd	s3,8(sp)
    80001f54:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f56:	00000097          	auipc	ra,0x0
    80001f5a:	a50080e7          	jalr	-1456(ra) # 800019a6 <myproc>
    80001f5e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f60:	fffff097          	auipc	ra,0xfffff
    80001f64:	bf8080e7          	jalr	-1032(ra) # 80000b58 <holding>
    80001f68:	c93d                	beqz	a0,80001fde <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f6a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f6c:	2781                	sext.w	a5,a5
    80001f6e:	079e                	slli	a5,a5,0x7
    80001f70:	0000f717          	auipc	a4,0xf
    80001f74:	dc070713          	addi	a4,a4,-576 # 80010d30 <pid_lock>
    80001f78:	97ba                	add	a5,a5,a4
    80001f7a:	0a87a703          	lw	a4,168(a5)
    80001f7e:	4785                	li	a5,1
    80001f80:	06f71763          	bne	a4,a5,80001fee <sched+0xa6>
  if(p->state == RUNNING)
    80001f84:	4c98                	lw	a4,24(s1)
    80001f86:	4791                	li	a5,4
    80001f88:	06f70b63          	beq	a4,a5,80001ffe <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f8c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f90:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001f92:	efb5                	bnez	a5,8000200e <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f94:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f96:	0000f917          	auipc	s2,0xf
    80001f9a:	d9a90913          	addi	s2,s2,-614 # 80010d30 <pid_lock>
    80001f9e:	2781                	sext.w	a5,a5
    80001fa0:	079e                	slli	a5,a5,0x7
    80001fa2:	97ca                	add	a5,a5,s2
    80001fa4:	0ac7a983          	lw	s3,172(a5)
    80001fa8:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001faa:	2781                	sext.w	a5,a5
    80001fac:	079e                	slli	a5,a5,0x7
    80001fae:	0000f597          	auipc	a1,0xf
    80001fb2:	dba58593          	addi	a1,a1,-582 # 80010d68 <cpus+0x8>
    80001fb6:	95be                	add	a1,a1,a5
    80001fb8:	06048513          	addi	a0,s1,96
    80001fbc:	00000097          	auipc	ra,0x0
    80001fc0:	604080e7          	jalr	1540(ra) # 800025c0 <swtch>
    80001fc4:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fc6:	2781                	sext.w	a5,a5
    80001fc8:	079e                	slli	a5,a5,0x7
    80001fca:	993e                	add	s2,s2,a5
    80001fcc:	0b392623          	sw	s3,172(s2)
}
    80001fd0:	70a2                	ld	ra,40(sp)
    80001fd2:	7402                	ld	s0,32(sp)
    80001fd4:	64e2                	ld	s1,24(sp)
    80001fd6:	6942                	ld	s2,16(sp)
    80001fd8:	69a2                	ld	s3,8(sp)
    80001fda:	6145                	addi	sp,sp,48
    80001fdc:	8082                	ret
    panic("sched p->lock");
    80001fde:	00006517          	auipc	a0,0x6
    80001fe2:	23a50513          	addi	a0,a0,570 # 80008218 <digits+0x1d8>
    80001fe6:	ffffe097          	auipc	ra,0xffffe
    80001fea:	556080e7          	jalr	1366(ra) # 8000053c <panic>
    panic("sched locks");
    80001fee:	00006517          	auipc	a0,0x6
    80001ff2:	23a50513          	addi	a0,a0,570 # 80008228 <digits+0x1e8>
    80001ff6:	ffffe097          	auipc	ra,0xffffe
    80001ffa:	546080e7          	jalr	1350(ra) # 8000053c <panic>
    panic("sched running");
    80001ffe:	00006517          	auipc	a0,0x6
    80002002:	23a50513          	addi	a0,a0,570 # 80008238 <digits+0x1f8>
    80002006:	ffffe097          	auipc	ra,0xffffe
    8000200a:	536080e7          	jalr	1334(ra) # 8000053c <panic>
    panic("sched interruptible");
    8000200e:	00006517          	auipc	a0,0x6
    80002012:	23a50513          	addi	a0,a0,570 # 80008248 <digits+0x208>
    80002016:	ffffe097          	auipc	ra,0xffffe
    8000201a:	526080e7          	jalr	1318(ra) # 8000053c <panic>

000000008000201e <yield>:
{
    8000201e:	1101                	addi	sp,sp,-32
    80002020:	ec06                	sd	ra,24(sp)
    80002022:	e822                	sd	s0,16(sp)
    80002024:	e426                	sd	s1,8(sp)
    80002026:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002028:	00000097          	auipc	ra,0x0
    8000202c:	97e080e7          	jalr	-1666(ra) # 800019a6 <myproc>
    80002030:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002032:	fffff097          	auipc	ra,0xfffff
    80002036:	ba0080e7          	jalr	-1120(ra) # 80000bd2 <acquire>
  p->state = RUNNABLE;
    8000203a:	478d                	li	a5,3
    8000203c:	cc9c                	sw	a5,24(s1)
  sched();
    8000203e:	00000097          	auipc	ra,0x0
    80002042:	f0a080e7          	jalr	-246(ra) # 80001f48 <sched>
  release(&p->lock);
    80002046:	8526                	mv	a0,s1
    80002048:	fffff097          	auipc	ra,0xfffff
    8000204c:	c3e080e7          	jalr	-962(ra) # 80000c86 <release>
}
    80002050:	60e2                	ld	ra,24(sp)
    80002052:	6442                	ld	s0,16(sp)
    80002054:	64a2                	ld	s1,8(sp)
    80002056:	6105                	addi	sp,sp,32
    80002058:	8082                	ret

000000008000205a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000205a:	7179                	addi	sp,sp,-48
    8000205c:	f406                	sd	ra,40(sp)
    8000205e:	f022                	sd	s0,32(sp)
    80002060:	ec26                	sd	s1,24(sp)
    80002062:	e84a                	sd	s2,16(sp)
    80002064:	e44e                	sd	s3,8(sp)
    80002066:	1800                	addi	s0,sp,48
    80002068:	89aa                	mv	s3,a0
    8000206a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000206c:	00000097          	auipc	ra,0x0
    80002070:	93a080e7          	jalr	-1734(ra) # 800019a6 <myproc>
    80002074:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002076:	fffff097          	auipc	ra,0xfffff
    8000207a:	b5c080e7          	jalr	-1188(ra) # 80000bd2 <acquire>
  release(lk);
    8000207e:	854a                	mv	a0,s2
    80002080:	fffff097          	auipc	ra,0xfffff
    80002084:	c06080e7          	jalr	-1018(ra) # 80000c86 <release>

  // Go to sleep.
  p->chan = chan;
    80002088:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000208c:	4789                	li	a5,2
    8000208e:	cc9c                	sw	a5,24(s1)

  sched();
    80002090:	00000097          	auipc	ra,0x0
    80002094:	eb8080e7          	jalr	-328(ra) # 80001f48 <sched>

  // Tidy up.
  p->chan = 0;
    80002098:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000209c:	8526                	mv	a0,s1
    8000209e:	fffff097          	auipc	ra,0xfffff
    800020a2:	be8080e7          	jalr	-1048(ra) # 80000c86 <release>
  acquire(lk);
    800020a6:	854a                	mv	a0,s2
    800020a8:	fffff097          	auipc	ra,0xfffff
    800020ac:	b2a080e7          	jalr	-1238(ra) # 80000bd2 <acquire>
}
    800020b0:	70a2                	ld	ra,40(sp)
    800020b2:	7402                	ld	s0,32(sp)
    800020b4:	64e2                	ld	s1,24(sp)
    800020b6:	6942                	ld	s2,16(sp)
    800020b8:	69a2                	ld	s3,8(sp)
    800020ba:	6145                	addi	sp,sp,48
    800020bc:	8082                	ret

00000000800020be <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800020be:	7139                	addi	sp,sp,-64
    800020c0:	fc06                	sd	ra,56(sp)
    800020c2:	f822                	sd	s0,48(sp)
    800020c4:	f426                	sd	s1,40(sp)
    800020c6:	f04a                	sd	s2,32(sp)
    800020c8:	ec4e                	sd	s3,24(sp)
    800020ca:	e852                	sd	s4,16(sp)
    800020cc:	e456                	sd	s5,8(sp)
    800020ce:	0080                	addi	s0,sp,64
    800020d0:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800020d2:	0000f497          	auipc	s1,0xf
    800020d6:	08e48493          	addi	s1,s1,142 # 80011160 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800020da:	4989                	li	s3,2
        p->state = RUNNABLE;
    800020dc:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800020de:	00015917          	auipc	s2,0x15
    800020e2:	c8290913          	addi	s2,s2,-894 # 80016d60 <tickslock>
    800020e6:	a811                	j	800020fa <wakeup+0x3c>
      }
      release(&p->lock);
    800020e8:	8526                	mv	a0,s1
    800020ea:	fffff097          	auipc	ra,0xfffff
    800020ee:	b9c080e7          	jalr	-1124(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800020f2:	17048493          	addi	s1,s1,368
    800020f6:	03248663          	beq	s1,s2,80002122 <wakeup+0x64>
    if(p != myproc()){
    800020fa:	00000097          	auipc	ra,0x0
    800020fe:	8ac080e7          	jalr	-1876(ra) # 800019a6 <myproc>
    80002102:	fea488e3          	beq	s1,a0,800020f2 <wakeup+0x34>
      acquire(&p->lock);
    80002106:	8526                	mv	a0,s1
    80002108:	fffff097          	auipc	ra,0xfffff
    8000210c:	aca080e7          	jalr	-1334(ra) # 80000bd2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002110:	4c9c                	lw	a5,24(s1)
    80002112:	fd379be3          	bne	a5,s3,800020e8 <wakeup+0x2a>
    80002116:	709c                	ld	a5,32(s1)
    80002118:	fd4798e3          	bne	a5,s4,800020e8 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000211c:	0154ac23          	sw	s5,24(s1)
    80002120:	b7e1                	j	800020e8 <wakeup+0x2a>
    }
  }
}
    80002122:	70e2                	ld	ra,56(sp)
    80002124:	7442                	ld	s0,48(sp)
    80002126:	74a2                	ld	s1,40(sp)
    80002128:	7902                	ld	s2,32(sp)
    8000212a:	69e2                	ld	s3,24(sp)
    8000212c:	6a42                	ld	s4,16(sp)
    8000212e:	6aa2                	ld	s5,8(sp)
    80002130:	6121                	addi	sp,sp,64
    80002132:	8082                	ret

0000000080002134 <reparent>:
{
    80002134:	7179                	addi	sp,sp,-48
    80002136:	f406                	sd	ra,40(sp)
    80002138:	f022                	sd	s0,32(sp)
    8000213a:	ec26                	sd	s1,24(sp)
    8000213c:	e84a                	sd	s2,16(sp)
    8000213e:	e44e                	sd	s3,8(sp)
    80002140:	e052                	sd	s4,0(sp)
    80002142:	1800                	addi	s0,sp,48
    80002144:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002146:	0000f497          	auipc	s1,0xf
    8000214a:	01a48493          	addi	s1,s1,26 # 80011160 <proc>
      pp->parent = initproc;
    8000214e:	00007a17          	auipc	s4,0x7
    80002152:	96aa0a13          	addi	s4,s4,-1686 # 80008ab8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002156:	00015997          	auipc	s3,0x15
    8000215a:	c0a98993          	addi	s3,s3,-1014 # 80016d60 <tickslock>
    8000215e:	a029                	j	80002168 <reparent+0x34>
    80002160:	17048493          	addi	s1,s1,368
    80002164:	01348d63          	beq	s1,s3,8000217e <reparent+0x4a>
    if(pp->parent == p){
    80002168:	7c9c                	ld	a5,56(s1)
    8000216a:	ff279be3          	bne	a5,s2,80002160 <reparent+0x2c>
      pp->parent = initproc;
    8000216e:	000a3503          	ld	a0,0(s4)
    80002172:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002174:	00000097          	auipc	ra,0x0
    80002178:	f4a080e7          	jalr	-182(ra) # 800020be <wakeup>
    8000217c:	b7d5                	j	80002160 <reparent+0x2c>
}
    8000217e:	70a2                	ld	ra,40(sp)
    80002180:	7402                	ld	s0,32(sp)
    80002182:	64e2                	ld	s1,24(sp)
    80002184:	6942                	ld	s2,16(sp)
    80002186:	69a2                	ld	s3,8(sp)
    80002188:	6a02                	ld	s4,0(sp)
    8000218a:	6145                	addi	sp,sp,48
    8000218c:	8082                	ret

000000008000218e <exit>:
{
    8000218e:	7179                	addi	sp,sp,-48
    80002190:	f406                	sd	ra,40(sp)
    80002192:	f022                	sd	s0,32(sp)
    80002194:	ec26                	sd	s1,24(sp)
    80002196:	e84a                	sd	s2,16(sp)
    80002198:	e44e                	sd	s3,8(sp)
    8000219a:	e052                	sd	s4,0(sp)
    8000219c:	1800                	addi	s0,sp,48
    8000219e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021a0:	00000097          	auipc	ra,0x0
    800021a4:	806080e7          	jalr	-2042(ra) # 800019a6 <myproc>
    800021a8:	89aa                	mv	s3,a0
  if(p == initproc)
    800021aa:	00007797          	auipc	a5,0x7
    800021ae:	90e7b783          	ld	a5,-1778(a5) # 80008ab8 <initproc>
    800021b2:	0d050493          	addi	s1,a0,208
    800021b6:	15050913          	addi	s2,a0,336
    800021ba:	02a79363          	bne	a5,a0,800021e0 <exit+0x52>
    panic("init exiting");
    800021be:	00006517          	auipc	a0,0x6
    800021c2:	0a250513          	addi	a0,a0,162 # 80008260 <digits+0x220>
    800021c6:	ffffe097          	auipc	ra,0xffffe
    800021ca:	376080e7          	jalr	886(ra) # 8000053c <panic>
      fileclose(f);
    800021ce:	00002097          	auipc	ra,0x2
    800021d2:	41a080e7          	jalr	1050(ra) # 800045e8 <fileclose>
      p->ofile[fd] = 0;
    800021d6:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800021da:	04a1                	addi	s1,s1,8
    800021dc:	01248563          	beq	s1,s2,800021e6 <exit+0x58>
    if(p->ofile[fd]){
    800021e0:	6088                	ld	a0,0(s1)
    800021e2:	f575                	bnez	a0,800021ce <exit+0x40>
    800021e4:	bfdd                	j	800021da <exit+0x4c>
  begin_op();
    800021e6:	00002097          	auipc	ra,0x2
    800021ea:	f3e080e7          	jalr	-194(ra) # 80004124 <begin_op>
  iput(p->cwd);
    800021ee:	1509b503          	ld	a0,336(s3)
    800021f2:	00001097          	auipc	ra,0x1
    800021f6:	746080e7          	jalr	1862(ra) # 80003938 <iput>
  end_op();
    800021fa:	00002097          	auipc	ra,0x2
    800021fe:	fa4080e7          	jalr	-92(ra) # 8000419e <end_op>
  p->cwd = 0;
    80002202:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002206:	0000f497          	auipc	s1,0xf
    8000220a:	b4248493          	addi	s1,s1,-1214 # 80010d48 <wait_lock>
    8000220e:	8526                	mv	a0,s1
    80002210:	fffff097          	auipc	ra,0xfffff
    80002214:	9c2080e7          	jalr	-1598(ra) # 80000bd2 <acquire>
  reparent(p);
    80002218:	854e                	mv	a0,s3
    8000221a:	00000097          	auipc	ra,0x0
    8000221e:	f1a080e7          	jalr	-230(ra) # 80002134 <reparent>
  wakeup(p->parent);
    80002222:	0389b503          	ld	a0,56(s3)
    80002226:	00000097          	auipc	ra,0x0
    8000222a:	e98080e7          	jalr	-360(ra) # 800020be <wakeup>
  acquire(&p->lock);
    8000222e:	854e                	mv	a0,s3
    80002230:	fffff097          	auipc	ra,0xfffff
    80002234:	9a2080e7          	jalr	-1630(ra) # 80000bd2 <acquire>
  p->xstate = status;
    80002238:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000223c:	4795                	li	a5,5
    8000223e:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002242:	8526                	mv	a0,s1
    80002244:	fffff097          	auipc	ra,0xfffff
    80002248:	a42080e7          	jalr	-1470(ra) # 80000c86 <release>
  sched();
    8000224c:	00000097          	auipc	ra,0x0
    80002250:	cfc080e7          	jalr	-772(ra) # 80001f48 <sched>
  panic("zombie exit");
    80002254:	00006517          	auipc	a0,0x6
    80002258:	01c50513          	addi	a0,a0,28 # 80008270 <digits+0x230>
    8000225c:	ffffe097          	auipc	ra,0xffffe
    80002260:	2e0080e7          	jalr	736(ra) # 8000053c <panic>

0000000080002264 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002264:	7179                	addi	sp,sp,-48
    80002266:	f406                	sd	ra,40(sp)
    80002268:	f022                	sd	s0,32(sp)
    8000226a:	ec26                	sd	s1,24(sp)
    8000226c:	e84a                	sd	s2,16(sp)
    8000226e:	e44e                	sd	s3,8(sp)
    80002270:	1800                	addi	s0,sp,48
    80002272:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002274:	0000f497          	auipc	s1,0xf
    80002278:	eec48493          	addi	s1,s1,-276 # 80011160 <proc>
    8000227c:	00015997          	auipc	s3,0x15
    80002280:	ae498993          	addi	s3,s3,-1308 # 80016d60 <tickslock>
    acquire(&p->lock);
    80002284:	8526                	mv	a0,s1
    80002286:	fffff097          	auipc	ra,0xfffff
    8000228a:	94c080e7          	jalr	-1716(ra) # 80000bd2 <acquire>
    if(p->pid == pid){
    8000228e:	589c                	lw	a5,48(s1)
    80002290:	01278d63          	beq	a5,s2,800022aa <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002294:	8526                	mv	a0,s1
    80002296:	fffff097          	auipc	ra,0xfffff
    8000229a:	9f0080e7          	jalr	-1552(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000229e:	17048493          	addi	s1,s1,368
    800022a2:	ff3491e3          	bne	s1,s3,80002284 <kill+0x20>
  }
  return -1;
    800022a6:	557d                	li	a0,-1
    800022a8:	a829                	j	800022c2 <kill+0x5e>
      p->killed = 1;
    800022aa:	4785                	li	a5,1
    800022ac:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800022ae:	4c98                	lw	a4,24(s1)
    800022b0:	4789                	li	a5,2
    800022b2:	00f70f63          	beq	a4,a5,800022d0 <kill+0x6c>
      release(&p->lock);
    800022b6:	8526                	mv	a0,s1
    800022b8:	fffff097          	auipc	ra,0xfffff
    800022bc:	9ce080e7          	jalr	-1586(ra) # 80000c86 <release>
      return 0;
    800022c0:	4501                	li	a0,0
}
    800022c2:	70a2                	ld	ra,40(sp)
    800022c4:	7402                	ld	s0,32(sp)
    800022c6:	64e2                	ld	s1,24(sp)
    800022c8:	6942                	ld	s2,16(sp)
    800022ca:	69a2                	ld	s3,8(sp)
    800022cc:	6145                	addi	sp,sp,48
    800022ce:	8082                	ret
        p->state = RUNNABLE;
    800022d0:	478d                	li	a5,3
    800022d2:	cc9c                	sw	a5,24(s1)
    800022d4:	b7cd                	j	800022b6 <kill+0x52>

00000000800022d6 <setkilled>:

void
setkilled(struct proc *p)
{
    800022d6:	1101                	addi	sp,sp,-32
    800022d8:	ec06                	sd	ra,24(sp)
    800022da:	e822                	sd	s0,16(sp)
    800022dc:	e426                	sd	s1,8(sp)
    800022de:	1000                	addi	s0,sp,32
    800022e0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022e2:	fffff097          	auipc	ra,0xfffff
    800022e6:	8f0080e7          	jalr	-1808(ra) # 80000bd2 <acquire>
  p->killed = 1;
    800022ea:	4785                	li	a5,1
    800022ec:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800022ee:	8526                	mv	a0,s1
    800022f0:	fffff097          	auipc	ra,0xfffff
    800022f4:	996080e7          	jalr	-1642(ra) # 80000c86 <release>
}
    800022f8:	60e2                	ld	ra,24(sp)
    800022fa:	6442                	ld	s0,16(sp)
    800022fc:	64a2                	ld	s1,8(sp)
    800022fe:	6105                	addi	sp,sp,32
    80002300:	8082                	ret

0000000080002302 <killed>:

int
killed(struct proc *p)
{
    80002302:	1101                	addi	sp,sp,-32
    80002304:	ec06                	sd	ra,24(sp)
    80002306:	e822                	sd	s0,16(sp)
    80002308:	e426                	sd	s1,8(sp)
    8000230a:	e04a                	sd	s2,0(sp)
    8000230c:	1000                	addi	s0,sp,32
    8000230e:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002310:	fffff097          	auipc	ra,0xfffff
    80002314:	8c2080e7          	jalr	-1854(ra) # 80000bd2 <acquire>
  k = p->killed;
    80002318:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000231c:	8526                	mv	a0,s1
    8000231e:	fffff097          	auipc	ra,0xfffff
    80002322:	968080e7          	jalr	-1688(ra) # 80000c86 <release>
  return k;
}
    80002326:	854a                	mv	a0,s2
    80002328:	60e2                	ld	ra,24(sp)
    8000232a:	6442                	ld	s0,16(sp)
    8000232c:	64a2                	ld	s1,8(sp)
    8000232e:	6902                	ld	s2,0(sp)
    80002330:	6105                	addi	sp,sp,32
    80002332:	8082                	ret

0000000080002334 <wait>:
{
    80002334:	715d                	addi	sp,sp,-80
    80002336:	e486                	sd	ra,72(sp)
    80002338:	e0a2                	sd	s0,64(sp)
    8000233a:	fc26                	sd	s1,56(sp)
    8000233c:	f84a                	sd	s2,48(sp)
    8000233e:	f44e                	sd	s3,40(sp)
    80002340:	f052                	sd	s4,32(sp)
    80002342:	ec56                	sd	s5,24(sp)
    80002344:	e85a                	sd	s6,16(sp)
    80002346:	e45e                	sd	s7,8(sp)
    80002348:	e062                	sd	s8,0(sp)
    8000234a:	0880                	addi	s0,sp,80
    8000234c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000234e:	fffff097          	auipc	ra,0xfffff
    80002352:	658080e7          	jalr	1624(ra) # 800019a6 <myproc>
    80002356:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002358:	0000f517          	auipc	a0,0xf
    8000235c:	9f050513          	addi	a0,a0,-1552 # 80010d48 <wait_lock>
    80002360:	fffff097          	auipc	ra,0xfffff
    80002364:	872080e7          	jalr	-1934(ra) # 80000bd2 <acquire>
    havekids = 0;
    80002368:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000236a:	4a15                	li	s4,5
        havekids = 1;
    8000236c:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000236e:	00015997          	auipc	s3,0x15
    80002372:	9f298993          	addi	s3,s3,-1550 # 80016d60 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002376:	0000fc17          	auipc	s8,0xf
    8000237a:	9d2c0c13          	addi	s8,s8,-1582 # 80010d48 <wait_lock>
    8000237e:	a0d1                	j	80002442 <wait+0x10e>
          pid = pp->pid;
    80002380:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002384:	000b0e63          	beqz	s6,800023a0 <wait+0x6c>
    80002388:	4691                	li	a3,4
    8000238a:	02c48613          	addi	a2,s1,44
    8000238e:	85da                	mv	a1,s6
    80002390:	05093503          	ld	a0,80(s2)
    80002394:	fffff097          	auipc	ra,0xfffff
    80002398:	2d2080e7          	jalr	722(ra) # 80001666 <copyout>
    8000239c:	04054163          	bltz	a0,800023de <wait+0xaa>
          freeproc(pp);
    800023a0:	8526                	mv	a0,s1
    800023a2:	fffff097          	auipc	ra,0xfffff
    800023a6:	7b6080e7          	jalr	1974(ra) # 80001b58 <freeproc>
          release(&pp->lock);
    800023aa:	8526                	mv	a0,s1
    800023ac:	fffff097          	auipc	ra,0xfffff
    800023b0:	8da080e7          	jalr	-1830(ra) # 80000c86 <release>
          release(&wait_lock);
    800023b4:	0000f517          	auipc	a0,0xf
    800023b8:	99450513          	addi	a0,a0,-1644 # 80010d48 <wait_lock>
    800023bc:	fffff097          	auipc	ra,0xfffff
    800023c0:	8ca080e7          	jalr	-1846(ra) # 80000c86 <release>
}
    800023c4:	854e                	mv	a0,s3
    800023c6:	60a6                	ld	ra,72(sp)
    800023c8:	6406                	ld	s0,64(sp)
    800023ca:	74e2                	ld	s1,56(sp)
    800023cc:	7942                	ld	s2,48(sp)
    800023ce:	79a2                	ld	s3,40(sp)
    800023d0:	7a02                	ld	s4,32(sp)
    800023d2:	6ae2                	ld	s5,24(sp)
    800023d4:	6b42                	ld	s6,16(sp)
    800023d6:	6ba2                	ld	s7,8(sp)
    800023d8:	6c02                	ld	s8,0(sp)
    800023da:	6161                	addi	sp,sp,80
    800023dc:	8082                	ret
            release(&pp->lock);
    800023de:	8526                	mv	a0,s1
    800023e0:	fffff097          	auipc	ra,0xfffff
    800023e4:	8a6080e7          	jalr	-1882(ra) # 80000c86 <release>
            release(&wait_lock);
    800023e8:	0000f517          	auipc	a0,0xf
    800023ec:	96050513          	addi	a0,a0,-1696 # 80010d48 <wait_lock>
    800023f0:	fffff097          	auipc	ra,0xfffff
    800023f4:	896080e7          	jalr	-1898(ra) # 80000c86 <release>
            return -1;
    800023f8:	59fd                	li	s3,-1
    800023fa:	b7e9                	j	800023c4 <wait+0x90>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023fc:	17048493          	addi	s1,s1,368
    80002400:	03348463          	beq	s1,s3,80002428 <wait+0xf4>
      if(pp->parent == p){
    80002404:	7c9c                	ld	a5,56(s1)
    80002406:	ff279be3          	bne	a5,s2,800023fc <wait+0xc8>
        acquire(&pp->lock);
    8000240a:	8526                	mv	a0,s1
    8000240c:	ffffe097          	auipc	ra,0xffffe
    80002410:	7c6080e7          	jalr	1990(ra) # 80000bd2 <acquire>
        if(pp->state == ZOMBIE){
    80002414:	4c9c                	lw	a5,24(s1)
    80002416:	f74785e3          	beq	a5,s4,80002380 <wait+0x4c>
        release(&pp->lock);
    8000241a:	8526                	mv	a0,s1
    8000241c:	fffff097          	auipc	ra,0xfffff
    80002420:	86a080e7          	jalr	-1942(ra) # 80000c86 <release>
        havekids = 1;
    80002424:	8756                	mv	a4,s5
    80002426:	bfd9                	j	800023fc <wait+0xc8>
    if(!havekids || killed(p)){
    80002428:	c31d                	beqz	a4,8000244e <wait+0x11a>
    8000242a:	854a                	mv	a0,s2
    8000242c:	00000097          	auipc	ra,0x0
    80002430:	ed6080e7          	jalr	-298(ra) # 80002302 <killed>
    80002434:	ed09                	bnez	a0,8000244e <wait+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002436:	85e2                	mv	a1,s8
    80002438:	854a                	mv	a0,s2
    8000243a:	00000097          	auipc	ra,0x0
    8000243e:	c20080e7          	jalr	-992(ra) # 8000205a <sleep>
    havekids = 0;
    80002442:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002444:	0000f497          	auipc	s1,0xf
    80002448:	d1c48493          	addi	s1,s1,-740 # 80011160 <proc>
    8000244c:	bf65                	j	80002404 <wait+0xd0>
      release(&wait_lock);
    8000244e:	0000f517          	auipc	a0,0xf
    80002452:	8fa50513          	addi	a0,a0,-1798 # 80010d48 <wait_lock>
    80002456:	fffff097          	auipc	ra,0xfffff
    8000245a:	830080e7          	jalr	-2000(ra) # 80000c86 <release>
      return -1;
    8000245e:	59fd                	li	s3,-1
    80002460:	b795                	j	800023c4 <wait+0x90>

0000000080002462 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002462:	7179                	addi	sp,sp,-48
    80002464:	f406                	sd	ra,40(sp)
    80002466:	f022                	sd	s0,32(sp)
    80002468:	ec26                	sd	s1,24(sp)
    8000246a:	e84a                	sd	s2,16(sp)
    8000246c:	e44e                	sd	s3,8(sp)
    8000246e:	e052                	sd	s4,0(sp)
    80002470:	1800                	addi	s0,sp,48
    80002472:	84aa                	mv	s1,a0
    80002474:	892e                	mv	s2,a1
    80002476:	89b2                	mv	s3,a2
    80002478:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000247a:	fffff097          	auipc	ra,0xfffff
    8000247e:	52c080e7          	jalr	1324(ra) # 800019a6 <myproc>
  if(user_dst){
    80002482:	c08d                	beqz	s1,800024a4 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002484:	86d2                	mv	a3,s4
    80002486:	864e                	mv	a2,s3
    80002488:	85ca                	mv	a1,s2
    8000248a:	6928                	ld	a0,80(a0)
    8000248c:	fffff097          	auipc	ra,0xfffff
    80002490:	1da080e7          	jalr	474(ra) # 80001666 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002494:	70a2                	ld	ra,40(sp)
    80002496:	7402                	ld	s0,32(sp)
    80002498:	64e2                	ld	s1,24(sp)
    8000249a:	6942                	ld	s2,16(sp)
    8000249c:	69a2                	ld	s3,8(sp)
    8000249e:	6a02                	ld	s4,0(sp)
    800024a0:	6145                	addi	sp,sp,48
    800024a2:	8082                	ret
    memmove((char *)dst, src, len);
    800024a4:	000a061b          	sext.w	a2,s4
    800024a8:	85ce                	mv	a1,s3
    800024aa:	854a                	mv	a0,s2
    800024ac:	fffff097          	auipc	ra,0xfffff
    800024b0:	87e080e7          	jalr	-1922(ra) # 80000d2a <memmove>
    return 0;
    800024b4:	8526                	mv	a0,s1
    800024b6:	bff9                	j	80002494 <either_copyout+0x32>

00000000800024b8 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024b8:	7179                	addi	sp,sp,-48
    800024ba:	f406                	sd	ra,40(sp)
    800024bc:	f022                	sd	s0,32(sp)
    800024be:	ec26                	sd	s1,24(sp)
    800024c0:	e84a                	sd	s2,16(sp)
    800024c2:	e44e                	sd	s3,8(sp)
    800024c4:	e052                	sd	s4,0(sp)
    800024c6:	1800                	addi	s0,sp,48
    800024c8:	892a                	mv	s2,a0
    800024ca:	84ae                	mv	s1,a1
    800024cc:	89b2                	mv	s3,a2
    800024ce:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024d0:	fffff097          	auipc	ra,0xfffff
    800024d4:	4d6080e7          	jalr	1238(ra) # 800019a6 <myproc>
  if(user_src){
    800024d8:	c08d                	beqz	s1,800024fa <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024da:	86d2                	mv	a3,s4
    800024dc:	864e                	mv	a2,s3
    800024de:	85ca                	mv	a1,s2
    800024e0:	6928                	ld	a0,80(a0)
    800024e2:	fffff097          	auipc	ra,0xfffff
    800024e6:	210080e7          	jalr	528(ra) # 800016f2 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024ea:	70a2                	ld	ra,40(sp)
    800024ec:	7402                	ld	s0,32(sp)
    800024ee:	64e2                	ld	s1,24(sp)
    800024f0:	6942                	ld	s2,16(sp)
    800024f2:	69a2                	ld	s3,8(sp)
    800024f4:	6a02                	ld	s4,0(sp)
    800024f6:	6145                	addi	sp,sp,48
    800024f8:	8082                	ret
    memmove(dst, (char*)src, len);
    800024fa:	000a061b          	sext.w	a2,s4
    800024fe:	85ce                	mv	a1,s3
    80002500:	854a                	mv	a0,s2
    80002502:	fffff097          	auipc	ra,0xfffff
    80002506:	828080e7          	jalr	-2008(ra) # 80000d2a <memmove>
    return 0;
    8000250a:	8526                	mv	a0,s1
    8000250c:	bff9                	j	800024ea <either_copyin+0x32>

000000008000250e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000250e:	715d                	addi	sp,sp,-80
    80002510:	e486                	sd	ra,72(sp)
    80002512:	e0a2                	sd	s0,64(sp)
    80002514:	fc26                	sd	s1,56(sp)
    80002516:	f84a                	sd	s2,48(sp)
    80002518:	f44e                	sd	s3,40(sp)
    8000251a:	f052                	sd	s4,32(sp)
    8000251c:	ec56                	sd	s5,24(sp)
    8000251e:	e85a                	sd	s6,16(sp)
    80002520:	e45e                	sd	s7,8(sp)
    80002522:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002524:	00006517          	auipc	a0,0x6
    80002528:	ba450513          	addi	a0,a0,-1116 # 800080c8 <digits+0x88>
    8000252c:	ffffe097          	auipc	ra,0xffffe
    80002530:	05a080e7          	jalr	90(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002534:	0000f497          	auipc	s1,0xf
    80002538:	d8448493          	addi	s1,s1,-636 # 800112b8 <proc+0x158>
    8000253c:	00015917          	auipc	s2,0x15
    80002540:	97c90913          	addi	s2,s2,-1668 # 80016eb8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002544:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002546:	00006997          	auipc	s3,0x6
    8000254a:	d3a98993          	addi	s3,s3,-710 # 80008280 <digits+0x240>
    printf("%d %s %s %d", p->pid, state, p->name, p->smask);
    8000254e:	00006a97          	auipc	s5,0x6
    80002552:	d3aa8a93          	addi	s5,s5,-710 # 80008288 <digits+0x248>
    printf("\n");
    80002556:	00006a17          	auipc	s4,0x6
    8000255a:	b72a0a13          	addi	s4,s4,-1166 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000255e:	00006b97          	auipc	s7,0x6
    80002562:	d6ab8b93          	addi	s7,s7,-662 # 800082c8 <states.0>
    80002566:	a015                	j	8000258a <procdump+0x7c>
    printf("%d %s %s %d", p->pid, state, p->name, p->smask);
    80002568:	4a98                	lw	a4,16(a3)
    8000256a:	ed86a583          	lw	a1,-296(a3)
    8000256e:	8556                	mv	a0,s5
    80002570:	ffffe097          	auipc	ra,0xffffe
    80002574:	016080e7          	jalr	22(ra) # 80000586 <printf>
    printf("\n");
    80002578:	8552                	mv	a0,s4
    8000257a:	ffffe097          	auipc	ra,0xffffe
    8000257e:	00c080e7          	jalr	12(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002582:	17048493          	addi	s1,s1,368
    80002586:	03248263          	beq	s1,s2,800025aa <procdump+0x9c>
    if(p->state == UNUSED)
    8000258a:	86a6                	mv	a3,s1
    8000258c:	ec04a783          	lw	a5,-320(s1)
    80002590:	dbed                	beqz	a5,80002582 <procdump+0x74>
      state = "???";
    80002592:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002594:	fcfb6ae3          	bltu	s6,a5,80002568 <procdump+0x5a>
    80002598:	02079713          	slli	a4,a5,0x20
    8000259c:	01d75793          	srli	a5,a4,0x1d
    800025a0:	97de                	add	a5,a5,s7
    800025a2:	6390                	ld	a2,0(a5)
    800025a4:	f271                	bnez	a2,80002568 <procdump+0x5a>
      state = "???";
    800025a6:	864e                	mv	a2,s3
    800025a8:	b7c1                	j	80002568 <procdump+0x5a>
  }
}
    800025aa:	60a6                	ld	ra,72(sp)
    800025ac:	6406                	ld	s0,64(sp)
    800025ae:	74e2                	ld	s1,56(sp)
    800025b0:	7942                	ld	s2,48(sp)
    800025b2:	79a2                	ld	s3,40(sp)
    800025b4:	7a02                	ld	s4,32(sp)
    800025b6:	6ae2                	ld	s5,24(sp)
    800025b8:	6b42                	ld	s6,16(sp)
    800025ba:	6ba2                	ld	s7,8(sp)
    800025bc:	6161                	addi	sp,sp,80
    800025be:	8082                	ret

00000000800025c0 <swtch>:
    800025c0:	00153023          	sd	ra,0(a0)
    800025c4:	00253423          	sd	sp,8(a0)
    800025c8:	e900                	sd	s0,16(a0)
    800025ca:	ed04                	sd	s1,24(a0)
    800025cc:	03253023          	sd	s2,32(a0)
    800025d0:	03353423          	sd	s3,40(a0)
    800025d4:	03453823          	sd	s4,48(a0)
    800025d8:	03553c23          	sd	s5,56(a0)
    800025dc:	05653023          	sd	s6,64(a0)
    800025e0:	05753423          	sd	s7,72(a0)
    800025e4:	05853823          	sd	s8,80(a0)
    800025e8:	05953c23          	sd	s9,88(a0)
    800025ec:	07a53023          	sd	s10,96(a0)
    800025f0:	07b53423          	sd	s11,104(a0)
    800025f4:	0005b083          	ld	ra,0(a1)
    800025f8:	0085b103          	ld	sp,8(a1)
    800025fc:	6980                	ld	s0,16(a1)
    800025fe:	6d84                	ld	s1,24(a1)
    80002600:	0205b903          	ld	s2,32(a1)
    80002604:	0285b983          	ld	s3,40(a1)
    80002608:	0305ba03          	ld	s4,48(a1)
    8000260c:	0385ba83          	ld	s5,56(a1)
    80002610:	0405bb03          	ld	s6,64(a1)
    80002614:	0485bb83          	ld	s7,72(a1)
    80002618:	0505bc03          	ld	s8,80(a1)
    8000261c:	0585bc83          	ld	s9,88(a1)
    80002620:	0605bd03          	ld	s10,96(a1)
    80002624:	0685bd83          	ld	s11,104(a1)
    80002628:	8082                	ret

000000008000262a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000262a:	1141                	addi	sp,sp,-16
    8000262c:	e406                	sd	ra,8(sp)
    8000262e:	e022                	sd	s0,0(sp)
    80002630:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002632:	00006597          	auipc	a1,0x6
    80002636:	cc658593          	addi	a1,a1,-826 # 800082f8 <states.0+0x30>
    8000263a:	00014517          	auipc	a0,0x14
    8000263e:	72650513          	addi	a0,a0,1830 # 80016d60 <tickslock>
    80002642:	ffffe097          	auipc	ra,0xffffe
    80002646:	500080e7          	jalr	1280(ra) # 80000b42 <initlock>
}
    8000264a:	60a2                	ld	ra,8(sp)
    8000264c:	6402                	ld	s0,0(sp)
    8000264e:	0141                	addi	sp,sp,16
    80002650:	8082                	ret

0000000080002652 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002652:	1141                	addi	sp,sp,-16
    80002654:	e422                	sd	s0,8(sp)
    80002656:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002658:	00003797          	auipc	a5,0x3
    8000265c:	5b878793          	addi	a5,a5,1464 # 80005c10 <kernelvec>
    80002660:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002664:	6422                	ld	s0,8(sp)
    80002666:	0141                	addi	sp,sp,16
    80002668:	8082                	ret

000000008000266a <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000266a:	1141                	addi	sp,sp,-16
    8000266c:	e406                	sd	ra,8(sp)
    8000266e:	e022                	sd	s0,0(sp)
    80002670:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002672:	fffff097          	auipc	ra,0xfffff
    80002676:	334080e7          	jalr	820(ra) # 800019a6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000267a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000267e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002680:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002684:	00005697          	auipc	a3,0x5
    80002688:	97c68693          	addi	a3,a3,-1668 # 80007000 <_trampoline>
    8000268c:	00005717          	auipc	a4,0x5
    80002690:	97470713          	addi	a4,a4,-1676 # 80007000 <_trampoline>
    80002694:	8f15                	sub	a4,a4,a3
    80002696:	040007b7          	lui	a5,0x4000
    8000269a:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    8000269c:	07b2                	slli	a5,a5,0xc
    8000269e:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026a0:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026a4:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026a6:	18002673          	csrr	a2,satp
    800026aa:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026ac:	6d30                	ld	a2,88(a0)
    800026ae:	6138                	ld	a4,64(a0)
    800026b0:	6585                	lui	a1,0x1
    800026b2:	972e                	add	a4,a4,a1
    800026b4:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026b6:	6d38                	ld	a4,88(a0)
    800026b8:	00000617          	auipc	a2,0x0
    800026bc:	13460613          	addi	a2,a2,308 # 800027ec <usertrap>
    800026c0:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026c2:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026c4:	8612                	mv	a2,tp
    800026c6:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026c8:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026cc:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026d0:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026d4:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026d8:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026da:	6f18                	ld	a4,24(a4)
    800026dc:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800026e0:	6928                	ld	a0,80(a0)
    800026e2:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800026e4:	00005717          	auipc	a4,0x5
    800026e8:	9b870713          	addi	a4,a4,-1608 # 8000709c <userret>
    800026ec:	8f15                	sub	a4,a4,a3
    800026ee:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800026f0:	577d                	li	a4,-1
    800026f2:	177e                	slli	a4,a4,0x3f
    800026f4:	8d59                	or	a0,a0,a4
    800026f6:	9782                	jalr	a5
}
    800026f8:	60a2                	ld	ra,8(sp)
    800026fa:	6402                	ld	s0,0(sp)
    800026fc:	0141                	addi	sp,sp,16
    800026fe:	8082                	ret

0000000080002700 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002700:	1101                	addi	sp,sp,-32
    80002702:	ec06                	sd	ra,24(sp)
    80002704:	e822                	sd	s0,16(sp)
    80002706:	e426                	sd	s1,8(sp)
    80002708:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000270a:	00014497          	auipc	s1,0x14
    8000270e:	65648493          	addi	s1,s1,1622 # 80016d60 <tickslock>
    80002712:	8526                	mv	a0,s1
    80002714:	ffffe097          	auipc	ra,0xffffe
    80002718:	4be080e7          	jalr	1214(ra) # 80000bd2 <acquire>
  ticks++;
    8000271c:	00006517          	auipc	a0,0x6
    80002720:	3a450513          	addi	a0,a0,932 # 80008ac0 <ticks>
    80002724:	411c                	lw	a5,0(a0)
    80002726:	2785                	addiw	a5,a5,1
    80002728:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000272a:	00000097          	auipc	ra,0x0
    8000272e:	994080e7          	jalr	-1644(ra) # 800020be <wakeup>
  release(&tickslock);
    80002732:	8526                	mv	a0,s1
    80002734:	ffffe097          	auipc	ra,0xffffe
    80002738:	552080e7          	jalr	1362(ra) # 80000c86 <release>
}
    8000273c:	60e2                	ld	ra,24(sp)
    8000273e:	6442                	ld	s0,16(sp)
    80002740:	64a2                	ld	s1,8(sp)
    80002742:	6105                	addi	sp,sp,32
    80002744:	8082                	ret

0000000080002746 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002746:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    8000274a:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    8000274c:	0807df63          	bgez	a5,800027ea <devintr+0xa4>
{
    80002750:	1101                	addi	sp,sp,-32
    80002752:	ec06                	sd	ra,24(sp)
    80002754:	e822                	sd	s0,16(sp)
    80002756:	e426                	sd	s1,8(sp)
    80002758:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    8000275a:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    8000275e:	46a5                	li	a3,9
    80002760:	00d70d63          	beq	a4,a3,8000277a <devintr+0x34>
  } else if(scause == 0x8000000000000001L){
    80002764:	577d                	li	a4,-1
    80002766:	177e                	slli	a4,a4,0x3f
    80002768:	0705                	addi	a4,a4,1
    return 0;
    8000276a:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000276c:	04e78e63          	beq	a5,a4,800027c8 <devintr+0x82>
  }
}
    80002770:	60e2                	ld	ra,24(sp)
    80002772:	6442                	ld	s0,16(sp)
    80002774:	64a2                	ld	s1,8(sp)
    80002776:	6105                	addi	sp,sp,32
    80002778:	8082                	ret
    int irq = plic_claim();
    8000277a:	00003097          	auipc	ra,0x3
    8000277e:	59e080e7          	jalr	1438(ra) # 80005d18 <plic_claim>
    80002782:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002784:	47a9                	li	a5,10
    80002786:	02f50763          	beq	a0,a5,800027b4 <devintr+0x6e>
    } else if(irq == VIRTIO0_IRQ){
    8000278a:	4785                	li	a5,1
    8000278c:	02f50963          	beq	a0,a5,800027be <devintr+0x78>
    return 1;
    80002790:	4505                	li	a0,1
    } else if(irq){
    80002792:	dcf9                	beqz	s1,80002770 <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    80002794:	85a6                	mv	a1,s1
    80002796:	00006517          	auipc	a0,0x6
    8000279a:	b6a50513          	addi	a0,a0,-1174 # 80008300 <states.0+0x38>
    8000279e:	ffffe097          	auipc	ra,0xffffe
    800027a2:	de8080e7          	jalr	-536(ra) # 80000586 <printf>
      plic_complete(irq);
    800027a6:	8526                	mv	a0,s1
    800027a8:	00003097          	auipc	ra,0x3
    800027ac:	594080e7          	jalr	1428(ra) # 80005d3c <plic_complete>
    return 1;
    800027b0:	4505                	li	a0,1
    800027b2:	bf7d                	j	80002770 <devintr+0x2a>
      uartintr();
    800027b4:	ffffe097          	auipc	ra,0xffffe
    800027b8:	1e0080e7          	jalr	480(ra) # 80000994 <uartintr>
    if(irq)
    800027bc:	b7ed                	j	800027a6 <devintr+0x60>
      virtio_disk_intr();
    800027be:	00004097          	auipc	ra,0x4
    800027c2:	a44080e7          	jalr	-1468(ra) # 80006202 <virtio_disk_intr>
    if(irq)
    800027c6:	b7c5                	j	800027a6 <devintr+0x60>
    if(cpuid() == 0){
    800027c8:	fffff097          	auipc	ra,0xfffff
    800027cc:	1b2080e7          	jalr	434(ra) # 8000197a <cpuid>
    800027d0:	c901                	beqz	a0,800027e0 <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800027d2:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800027d6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800027d8:	14479073          	csrw	sip,a5
    return 2;
    800027dc:	4509                	li	a0,2
    800027de:	bf49                	j	80002770 <devintr+0x2a>
      clockintr();
    800027e0:	00000097          	auipc	ra,0x0
    800027e4:	f20080e7          	jalr	-224(ra) # 80002700 <clockintr>
    800027e8:	b7ed                	j	800027d2 <devintr+0x8c>
}
    800027ea:	8082                	ret

00000000800027ec <usertrap>:
{
    800027ec:	1101                	addi	sp,sp,-32
    800027ee:	ec06                	sd	ra,24(sp)
    800027f0:	e822                	sd	s0,16(sp)
    800027f2:	e426                	sd	s1,8(sp)
    800027f4:	e04a                	sd	s2,0(sp)
    800027f6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027f8:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800027fc:	1007f793          	andi	a5,a5,256
    80002800:	e3b1                	bnez	a5,80002844 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002802:	00003797          	auipc	a5,0x3
    80002806:	40e78793          	addi	a5,a5,1038 # 80005c10 <kernelvec>
    8000280a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000280e:	fffff097          	auipc	ra,0xfffff
    80002812:	198080e7          	jalr	408(ra) # 800019a6 <myproc>
    80002816:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002818:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000281a:	14102773          	csrr	a4,sepc
    8000281e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002820:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002824:	47a1                	li	a5,8
    80002826:	02f70763          	beq	a4,a5,80002854 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    8000282a:	00000097          	auipc	ra,0x0
    8000282e:	f1c080e7          	jalr	-228(ra) # 80002746 <devintr>
    80002832:	892a                	mv	s2,a0
    80002834:	c151                	beqz	a0,800028b8 <usertrap+0xcc>
  if(killed(p))
    80002836:	8526                	mv	a0,s1
    80002838:	00000097          	auipc	ra,0x0
    8000283c:	aca080e7          	jalr	-1334(ra) # 80002302 <killed>
    80002840:	c929                	beqz	a0,80002892 <usertrap+0xa6>
    80002842:	a099                	j	80002888 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002844:	00006517          	auipc	a0,0x6
    80002848:	adc50513          	addi	a0,a0,-1316 # 80008320 <states.0+0x58>
    8000284c:	ffffe097          	auipc	ra,0xffffe
    80002850:	cf0080e7          	jalr	-784(ra) # 8000053c <panic>
    if(killed(p))
    80002854:	00000097          	auipc	ra,0x0
    80002858:	aae080e7          	jalr	-1362(ra) # 80002302 <killed>
    8000285c:	e921                	bnez	a0,800028ac <usertrap+0xc0>
    p->trapframe->epc += 4;
    8000285e:	6cb8                	ld	a4,88(s1)
    80002860:	6f1c                	ld	a5,24(a4)
    80002862:	0791                	addi	a5,a5,4
    80002864:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002866:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000286a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000286e:	10079073          	csrw	sstatus,a5
    syscall();
    80002872:	00000097          	auipc	ra,0x0
    80002876:	2d4080e7          	jalr	724(ra) # 80002b46 <syscall>
  if(killed(p))
    8000287a:	8526                	mv	a0,s1
    8000287c:	00000097          	auipc	ra,0x0
    80002880:	a86080e7          	jalr	-1402(ra) # 80002302 <killed>
    80002884:	c911                	beqz	a0,80002898 <usertrap+0xac>
    80002886:	4901                	li	s2,0
    exit(-1);
    80002888:	557d                	li	a0,-1
    8000288a:	00000097          	auipc	ra,0x0
    8000288e:	904080e7          	jalr	-1788(ra) # 8000218e <exit>
  if(which_dev == 2)
    80002892:	4789                	li	a5,2
    80002894:	04f90f63          	beq	s2,a5,800028f2 <usertrap+0x106>
  usertrapret();
    80002898:	00000097          	auipc	ra,0x0
    8000289c:	dd2080e7          	jalr	-558(ra) # 8000266a <usertrapret>
}
    800028a0:	60e2                	ld	ra,24(sp)
    800028a2:	6442                	ld	s0,16(sp)
    800028a4:	64a2                	ld	s1,8(sp)
    800028a6:	6902                	ld	s2,0(sp)
    800028a8:	6105                	addi	sp,sp,32
    800028aa:	8082                	ret
      exit(-1);
    800028ac:	557d                	li	a0,-1
    800028ae:	00000097          	auipc	ra,0x0
    800028b2:	8e0080e7          	jalr	-1824(ra) # 8000218e <exit>
    800028b6:	b765                	j	8000285e <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028b8:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028bc:	5890                	lw	a2,48(s1)
    800028be:	00006517          	auipc	a0,0x6
    800028c2:	a8250513          	addi	a0,a0,-1406 # 80008340 <states.0+0x78>
    800028c6:	ffffe097          	auipc	ra,0xffffe
    800028ca:	cc0080e7          	jalr	-832(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028ce:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028d2:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800028d6:	00006517          	auipc	a0,0x6
    800028da:	a9a50513          	addi	a0,a0,-1382 # 80008370 <states.0+0xa8>
    800028de:	ffffe097          	auipc	ra,0xffffe
    800028e2:	ca8080e7          	jalr	-856(ra) # 80000586 <printf>
    setkilled(p);
    800028e6:	8526                	mv	a0,s1
    800028e8:	00000097          	auipc	ra,0x0
    800028ec:	9ee080e7          	jalr	-1554(ra) # 800022d6 <setkilled>
    800028f0:	b769                	j	8000287a <usertrap+0x8e>
    yield();
    800028f2:	fffff097          	auipc	ra,0xfffff
    800028f6:	72c080e7          	jalr	1836(ra) # 8000201e <yield>
    800028fa:	bf79                	j	80002898 <usertrap+0xac>

00000000800028fc <kerneltrap>:
{
    800028fc:	7179                	addi	sp,sp,-48
    800028fe:	f406                	sd	ra,40(sp)
    80002900:	f022                	sd	s0,32(sp)
    80002902:	ec26                	sd	s1,24(sp)
    80002904:	e84a                	sd	s2,16(sp)
    80002906:	e44e                	sd	s3,8(sp)
    80002908:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000290a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000290e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002912:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002916:	1004f793          	andi	a5,s1,256
    8000291a:	cb85                	beqz	a5,8000294a <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000291c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002920:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002922:	ef85                	bnez	a5,8000295a <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002924:	00000097          	auipc	ra,0x0
    80002928:	e22080e7          	jalr	-478(ra) # 80002746 <devintr>
    8000292c:	cd1d                	beqz	a0,8000296a <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000292e:	4789                	li	a5,2
    80002930:	06f50a63          	beq	a0,a5,800029a4 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002934:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002938:	10049073          	csrw	sstatus,s1
}
    8000293c:	70a2                	ld	ra,40(sp)
    8000293e:	7402                	ld	s0,32(sp)
    80002940:	64e2                	ld	s1,24(sp)
    80002942:	6942                	ld	s2,16(sp)
    80002944:	69a2                	ld	s3,8(sp)
    80002946:	6145                	addi	sp,sp,48
    80002948:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000294a:	00006517          	auipc	a0,0x6
    8000294e:	a4650513          	addi	a0,a0,-1466 # 80008390 <states.0+0xc8>
    80002952:	ffffe097          	auipc	ra,0xffffe
    80002956:	bea080e7          	jalr	-1046(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    8000295a:	00006517          	auipc	a0,0x6
    8000295e:	a5e50513          	addi	a0,a0,-1442 # 800083b8 <states.0+0xf0>
    80002962:	ffffe097          	auipc	ra,0xffffe
    80002966:	bda080e7          	jalr	-1062(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    8000296a:	85ce                	mv	a1,s3
    8000296c:	00006517          	auipc	a0,0x6
    80002970:	a6c50513          	addi	a0,a0,-1428 # 800083d8 <states.0+0x110>
    80002974:	ffffe097          	auipc	ra,0xffffe
    80002978:	c12080e7          	jalr	-1006(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000297c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002980:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002984:	00006517          	auipc	a0,0x6
    80002988:	a6450513          	addi	a0,a0,-1436 # 800083e8 <states.0+0x120>
    8000298c:	ffffe097          	auipc	ra,0xffffe
    80002990:	bfa080e7          	jalr	-1030(ra) # 80000586 <printf>
    panic("kerneltrap");
    80002994:	00006517          	auipc	a0,0x6
    80002998:	a6c50513          	addi	a0,a0,-1428 # 80008400 <states.0+0x138>
    8000299c:	ffffe097          	auipc	ra,0xffffe
    800029a0:	ba0080e7          	jalr	-1120(ra) # 8000053c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029a4:	fffff097          	auipc	ra,0xfffff
    800029a8:	002080e7          	jalr	2(ra) # 800019a6 <myproc>
    800029ac:	d541                	beqz	a0,80002934 <kerneltrap+0x38>
    800029ae:	fffff097          	auipc	ra,0xfffff
    800029b2:	ff8080e7          	jalr	-8(ra) # 800019a6 <myproc>
    800029b6:	4d18                	lw	a4,24(a0)
    800029b8:	4791                	li	a5,4
    800029ba:	f6f71de3          	bne	a4,a5,80002934 <kerneltrap+0x38>
    yield();
    800029be:	fffff097          	auipc	ra,0xfffff
    800029c2:	660080e7          	jalr	1632(ra) # 8000201e <yield>
    800029c6:	b7bd                	j	80002934 <kerneltrap+0x38>

00000000800029c8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800029c8:	1101                	addi	sp,sp,-32
    800029ca:	ec06                	sd	ra,24(sp)
    800029cc:	e822                	sd	s0,16(sp)
    800029ce:	e426                	sd	s1,8(sp)
    800029d0:	1000                	addi	s0,sp,32
    800029d2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800029d4:	fffff097          	auipc	ra,0xfffff
    800029d8:	fd2080e7          	jalr	-46(ra) # 800019a6 <myproc>
  switch (n) {
    800029dc:	4795                	li	a5,5
    800029de:	0497e163          	bltu	a5,s1,80002a20 <argraw+0x58>
    800029e2:	048a                	slli	s1,s1,0x2
    800029e4:	00006717          	auipc	a4,0x6
    800029e8:	b3470713          	addi	a4,a4,-1228 # 80008518 <states.0+0x250>
    800029ec:	94ba                	add	s1,s1,a4
    800029ee:	409c                	lw	a5,0(s1)
    800029f0:	97ba                	add	a5,a5,a4
    800029f2:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800029f4:	6d3c                	ld	a5,88(a0)
    800029f6:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800029f8:	60e2                	ld	ra,24(sp)
    800029fa:	6442                	ld	s0,16(sp)
    800029fc:	64a2                	ld	s1,8(sp)
    800029fe:	6105                	addi	sp,sp,32
    80002a00:	8082                	ret
    return p->trapframe->a1;
    80002a02:	6d3c                	ld	a5,88(a0)
    80002a04:	7fa8                	ld	a0,120(a5)
    80002a06:	bfcd                	j	800029f8 <argraw+0x30>
    return p->trapframe->a2;
    80002a08:	6d3c                	ld	a5,88(a0)
    80002a0a:	63c8                	ld	a0,128(a5)
    80002a0c:	b7f5                	j	800029f8 <argraw+0x30>
    return p->trapframe->a3;
    80002a0e:	6d3c                	ld	a5,88(a0)
    80002a10:	67c8                	ld	a0,136(a5)
    80002a12:	b7dd                	j	800029f8 <argraw+0x30>
    return p->trapframe->a4;
    80002a14:	6d3c                	ld	a5,88(a0)
    80002a16:	6bc8                	ld	a0,144(a5)
    80002a18:	b7c5                	j	800029f8 <argraw+0x30>
    return p->trapframe->a5;
    80002a1a:	6d3c                	ld	a5,88(a0)
    80002a1c:	6fc8                	ld	a0,152(a5)
    80002a1e:	bfe9                	j	800029f8 <argraw+0x30>
  panic("argraw");
    80002a20:	00006517          	auipc	a0,0x6
    80002a24:	9f050513          	addi	a0,a0,-1552 # 80008410 <states.0+0x148>
    80002a28:	ffffe097          	auipc	ra,0xffffe
    80002a2c:	b14080e7          	jalr	-1260(ra) # 8000053c <panic>

0000000080002a30 <fetchaddr>:
{
    80002a30:	1101                	addi	sp,sp,-32
    80002a32:	ec06                	sd	ra,24(sp)
    80002a34:	e822                	sd	s0,16(sp)
    80002a36:	e426                	sd	s1,8(sp)
    80002a38:	e04a                	sd	s2,0(sp)
    80002a3a:	1000                	addi	s0,sp,32
    80002a3c:	84aa                	mv	s1,a0
    80002a3e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a40:	fffff097          	auipc	ra,0xfffff
    80002a44:	f66080e7          	jalr	-154(ra) # 800019a6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a48:	653c                	ld	a5,72(a0)
    80002a4a:	02f4f863          	bgeu	s1,a5,80002a7a <fetchaddr+0x4a>
    80002a4e:	00848713          	addi	a4,s1,8
    80002a52:	02e7e663          	bltu	a5,a4,80002a7e <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a56:	46a1                	li	a3,8
    80002a58:	8626                	mv	a2,s1
    80002a5a:	85ca                	mv	a1,s2
    80002a5c:	6928                	ld	a0,80(a0)
    80002a5e:	fffff097          	auipc	ra,0xfffff
    80002a62:	c94080e7          	jalr	-876(ra) # 800016f2 <copyin>
    80002a66:	00a03533          	snez	a0,a0
    80002a6a:	40a00533          	neg	a0,a0
}
    80002a6e:	60e2                	ld	ra,24(sp)
    80002a70:	6442                	ld	s0,16(sp)
    80002a72:	64a2                	ld	s1,8(sp)
    80002a74:	6902                	ld	s2,0(sp)
    80002a76:	6105                	addi	sp,sp,32
    80002a78:	8082                	ret
    return -1;
    80002a7a:	557d                	li	a0,-1
    80002a7c:	bfcd                	j	80002a6e <fetchaddr+0x3e>
    80002a7e:	557d                	li	a0,-1
    80002a80:	b7fd                	j	80002a6e <fetchaddr+0x3e>

0000000080002a82 <fetchstr>:
{
    80002a82:	7179                	addi	sp,sp,-48
    80002a84:	f406                	sd	ra,40(sp)
    80002a86:	f022                	sd	s0,32(sp)
    80002a88:	ec26                	sd	s1,24(sp)
    80002a8a:	e84a                	sd	s2,16(sp)
    80002a8c:	e44e                	sd	s3,8(sp)
    80002a8e:	1800                	addi	s0,sp,48
    80002a90:	892a                	mv	s2,a0
    80002a92:	84ae                	mv	s1,a1
    80002a94:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a96:	fffff097          	auipc	ra,0xfffff
    80002a9a:	f10080e7          	jalr	-240(ra) # 800019a6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002a9e:	86ce                	mv	a3,s3
    80002aa0:	864a                	mv	a2,s2
    80002aa2:	85a6                	mv	a1,s1
    80002aa4:	6928                	ld	a0,80(a0)
    80002aa6:	fffff097          	auipc	ra,0xfffff
    80002aaa:	cda080e7          	jalr	-806(ra) # 80001780 <copyinstr>
    80002aae:	00054e63          	bltz	a0,80002aca <fetchstr+0x48>
  return strlen(buf);
    80002ab2:	8526                	mv	a0,s1
    80002ab4:	ffffe097          	auipc	ra,0xffffe
    80002ab8:	394080e7          	jalr	916(ra) # 80000e48 <strlen>
}
    80002abc:	70a2                	ld	ra,40(sp)
    80002abe:	7402                	ld	s0,32(sp)
    80002ac0:	64e2                	ld	s1,24(sp)
    80002ac2:	6942                	ld	s2,16(sp)
    80002ac4:	69a2                	ld	s3,8(sp)
    80002ac6:	6145                	addi	sp,sp,48
    80002ac8:	8082                	ret
    return -1;
    80002aca:	557d                	li	a0,-1
    80002acc:	bfc5                	j	80002abc <fetchstr+0x3a>

0000000080002ace <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002ace:	1101                	addi	sp,sp,-32
    80002ad0:	ec06                	sd	ra,24(sp)
    80002ad2:	e822                	sd	s0,16(sp)
    80002ad4:	e426                	sd	s1,8(sp)
    80002ad6:	1000                	addi	s0,sp,32
    80002ad8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ada:	00000097          	auipc	ra,0x0
    80002ade:	eee080e7          	jalr	-274(ra) # 800029c8 <argraw>
    80002ae2:	c088                	sw	a0,0(s1)
}
    80002ae4:	60e2                	ld	ra,24(sp)
    80002ae6:	6442                	ld	s0,16(sp)
    80002ae8:	64a2                	ld	s1,8(sp)
    80002aea:	6105                	addi	sp,sp,32
    80002aec:	8082                	ret

0000000080002aee <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002aee:	1101                	addi	sp,sp,-32
    80002af0:	ec06                	sd	ra,24(sp)
    80002af2:	e822                	sd	s0,16(sp)
    80002af4:	e426                	sd	s1,8(sp)
    80002af6:	1000                	addi	s0,sp,32
    80002af8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002afa:	00000097          	auipc	ra,0x0
    80002afe:	ece080e7          	jalr	-306(ra) # 800029c8 <argraw>
    80002b02:	e088                	sd	a0,0(s1)
}
    80002b04:	60e2                	ld	ra,24(sp)
    80002b06:	6442                	ld	s0,16(sp)
    80002b08:	64a2                	ld	s1,8(sp)
    80002b0a:	6105                	addi	sp,sp,32
    80002b0c:	8082                	ret

0000000080002b0e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b0e:	7179                	addi	sp,sp,-48
    80002b10:	f406                	sd	ra,40(sp)
    80002b12:	f022                	sd	s0,32(sp)
    80002b14:	ec26                	sd	s1,24(sp)
    80002b16:	e84a                	sd	s2,16(sp)
    80002b18:	1800                	addi	s0,sp,48
    80002b1a:	84ae                	mv	s1,a1
    80002b1c:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002b1e:	fd840593          	addi	a1,s0,-40
    80002b22:	00000097          	auipc	ra,0x0
    80002b26:	fcc080e7          	jalr	-52(ra) # 80002aee <argaddr>
  return fetchstr(addr, buf, max);
    80002b2a:	864a                	mv	a2,s2
    80002b2c:	85a6                	mv	a1,s1
    80002b2e:	fd843503          	ld	a0,-40(s0)
    80002b32:	00000097          	auipc	ra,0x0
    80002b36:	f50080e7          	jalr	-176(ra) # 80002a82 <fetchstr>
}
    80002b3a:	70a2                	ld	ra,40(sp)
    80002b3c:	7402                	ld	s0,32(sp)
    80002b3e:	64e2                	ld	s1,24(sp)
    80002b40:	6942                	ld	s2,16(sp)
    80002b42:	6145                	addi	sp,sp,48
    80002b44:	8082                	ret

0000000080002b46 <syscall>:
  [SYS_trace]   1,
};

void
syscall(void)
{
    80002b46:	7159                	addi	sp,sp,-112
    80002b48:	f486                	sd	ra,104(sp)
    80002b4a:	f0a2                	sd	s0,96(sp)
    80002b4c:	eca6                	sd	s1,88(sp)
    80002b4e:	e8ca                	sd	s2,80(sp)
    80002b50:	e4ce                	sd	s3,72(sp)
    80002b52:	e0d2                	sd	s4,64(sp)
    80002b54:	fc56                	sd	s5,56(sp)
    80002b56:	f85a                	sd	s6,48(sp)
    80002b58:	f45e                	sd	s7,40(sp)
    80002b5a:	1880                	addi	s0,sp,112
  int num;
  struct proc *p = myproc();
    80002b5c:	fffff097          	auipc	ra,0xfffff
    80002b60:	e4a080e7          	jalr	-438(ra) # 800019a6 <myproc>
    80002b64:	89aa                	mv	s3,a0

  num = p->trapframe->a7;
    80002b66:	6d24                	ld	s1,88(a0)
    80002b68:	74dc                	ld	a5,168(s1)
    80002b6a:	00078b1b          	sext.w	s6,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b6e:	37fd                	addiw	a5,a5,-1
    80002b70:	4755                	li	a4,21
    80002b72:	0cf76363          	bltu	a4,a5,80002c38 <syscall+0xf2>
    80002b76:	003b1713          	slli	a4,s6,0x3
    80002b7a:	00006797          	auipc	a5,0x6
    80002b7e:	9b678793          	addi	a5,a5,-1610 # 80008530 <syscalls>
    80002b82:	97ba                	add	a5,a5,a4
    80002b84:	0007bb83          	ld	s7,0(a5)
    80002b88:	0a0b8863          	beqz	s7,80002c38 <syscall+0xf2>
    // save arguments of syscall if it needs to be traced
    int nargs = syscall_nargs[num];
    80002b8c:	002b1713          	slli	a4,s6,0x2
    80002b90:	00006797          	auipc	a5,0x6
    80002b94:	9a078793          	addi	a5,a5,-1632 # 80008530 <syscalls>
    80002b98:	97ba                	add	a5,a5,a4
    80002b9a:	0b87aa03          	lw	s4,184(a5)
    int args[6];
    for (int i = 0; i < nargs; i++) {
    80002b9e:	0d405963          	blez	s4,80002c70 <syscall+0x12a>
    80002ba2:	f9840a93          	addi	s5,s0,-104
    80002ba6:	8956                	mv	s2,s5
    80002ba8:	4481                	li	s1,0
      argint(i, &args[i]);
    80002baa:	85ca                	mv	a1,s2
    80002bac:	8526                	mv	a0,s1
    80002bae:	00000097          	auipc	ra,0x0
    80002bb2:	f20080e7          	jalr	-224(ra) # 80002ace <argint>
    for (int i = 0; i < nargs; i++) {
    80002bb6:	2485                	addiw	s1,s1,1
    80002bb8:	0911                	addi	s2,s2,4
    80002bba:	fe9a18e3          	bne	s4,s1,80002baa <syscall+0x64>
    }

    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002bbe:	0589b483          	ld	s1,88(s3)
    80002bc2:	9b82                	jalr	s7
    80002bc4:	f8a8                	sd	a0,112(s1)

    // if trace was called
    int trace_call = p->smask & (1 << num);
    80002bc6:	4705                	li	a4,1
    80002bc8:	0167173b          	sllw	a4,a4,s6
    80002bcc:	1689a783          	lw	a5,360(s3)
    80002bd0:	8ff9                	and	a5,a5,a4
    if (trace_call) {
    80002bd2:	2781                	sext.w	a5,a5
    80002bd4:	c3d9                	beqz	a5,80002c5a <syscall+0x114>
      printf("%d: syscall %s (", p->pid, syscall_names[num]);
    80002bd6:	0b0e                	slli	s6,s6,0x3
    80002bd8:	00006797          	auipc	a5,0x6
    80002bdc:	95878793          	addi	a5,a5,-1704 # 80008530 <syscalls>
    80002be0:	97da                	add	a5,a5,s6
    80002be2:	1187b603          	ld	a2,280(a5)
    80002be6:	0309a583          	lw	a1,48(s3)
    80002bea:	00006517          	auipc	a0,0x6
    80002bee:	82e50513          	addi	a0,a0,-2002 # 80008418 <states.0+0x150>
    80002bf2:	ffffe097          	auipc	ra,0xffffe
    80002bf6:	994080e7          	jalr	-1644(ra) # 80000586 <printf>
      for (int i = 0; i < nargs; i++) {
    80002bfa:	4481                	li	s1,0
        printf("%d", args[i]);
    80002bfc:	00006b17          	auipc	s6,0x6
    80002c00:	834b0b13          	addi	s6,s6,-1996 # 80008430 <states.0+0x168>
        if (i != nargs - 1)
    80002c04:	fffa091b          	addiw	s2,s4,-1
          printf(" ");
    80002c08:	00006b97          	auipc	s7,0x6
    80002c0c:	830b8b93          	addi	s7,s7,-2000 # 80008438 <states.0+0x170>
    80002c10:	a029                	j	80002c1a <syscall+0xd4>
      for (int i = 0; i < nargs; i++) {
    80002c12:	2485                	addiw	s1,s1,1
    80002c14:	0a91                	addi	s5,s5,4
    80002c16:	089a0963          	beq	s4,s1,80002ca8 <syscall+0x162>
        printf("%d", args[i]);
    80002c1a:	000aa583          	lw	a1,0(s5)
    80002c1e:	855a                	mv	a0,s6
    80002c20:	ffffe097          	auipc	ra,0xffffe
    80002c24:	966080e7          	jalr	-1690(ra) # 80000586 <printf>
        if (i != nargs - 1)
    80002c28:	fe9905e3          	beq	s2,s1,80002c12 <syscall+0xcc>
          printf(" ");
    80002c2c:	855e                	mv	a0,s7
    80002c2e:	ffffe097          	auipc	ra,0xffffe
    80002c32:	958080e7          	jalr	-1704(ra) # 80000586 <printf>
    80002c36:	bff1                	j	80002c12 <syscall+0xcc>
    // if traced, print return value
    if (trace_call) {
      printf("-> %d\n", p->trapframe->a0);
    }
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002c38:	86da                	mv	a3,s6
    80002c3a:	15898613          	addi	a2,s3,344
    80002c3e:	0309a583          	lw	a1,48(s3)
    80002c42:	00006517          	auipc	a0,0x6
    80002c46:	80e50513          	addi	a0,a0,-2034 # 80008450 <states.0+0x188>
    80002c4a:	ffffe097          	auipc	ra,0xffffe
    80002c4e:	93c080e7          	jalr	-1732(ra) # 80000586 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c52:	0589b783          	ld	a5,88(s3)
    80002c56:	577d                	li	a4,-1
    80002c58:	fbb8                	sd	a4,112(a5)
  }
}
    80002c5a:	70a6                	ld	ra,104(sp)
    80002c5c:	7406                	ld	s0,96(sp)
    80002c5e:	64e6                	ld	s1,88(sp)
    80002c60:	6946                	ld	s2,80(sp)
    80002c62:	69a6                	ld	s3,72(sp)
    80002c64:	6a06                	ld	s4,64(sp)
    80002c66:	7ae2                	ld	s5,56(sp)
    80002c68:	7b42                	ld	s6,48(sp)
    80002c6a:	7ba2                	ld	s7,40(sp)
    80002c6c:	6165                	addi	sp,sp,112
    80002c6e:	8082                	ret
    p->trapframe->a0 = syscalls[num]();
    80002c70:	9b82                	jalr	s7
    80002c72:	f8a8                	sd	a0,112(s1)
    int trace_call = p->smask & (1 << num);
    80002c74:	4705                	li	a4,1
    80002c76:	0167173b          	sllw	a4,a4,s6
    80002c7a:	1689a783          	lw	a5,360(s3)
    80002c7e:	8ff9                	and	a5,a5,a4
    if (trace_call) {
    80002c80:	2781                	sext.w	a5,a5
    80002c82:	dfe1                	beqz	a5,80002c5a <syscall+0x114>
      printf("%d: syscall %s (", p->pid, syscall_names[num]);
    80002c84:	0b0e                	slli	s6,s6,0x3
    80002c86:	00006797          	auipc	a5,0x6
    80002c8a:	8aa78793          	addi	a5,a5,-1878 # 80008530 <syscalls>
    80002c8e:	97da                	add	a5,a5,s6
    80002c90:	1187b603          	ld	a2,280(a5)
    80002c94:	0309a583          	lw	a1,48(s3)
    80002c98:	00005517          	auipc	a0,0x5
    80002c9c:	78050513          	addi	a0,a0,1920 # 80008418 <states.0+0x150>
    80002ca0:	ffffe097          	auipc	ra,0xffffe
    80002ca4:	8e6080e7          	jalr	-1818(ra) # 80000586 <printf>
      printf(") ");
    80002ca8:	00005517          	auipc	a0,0x5
    80002cac:	79850513          	addi	a0,a0,1944 # 80008440 <states.0+0x178>
    80002cb0:	ffffe097          	auipc	ra,0xffffe
    80002cb4:	8d6080e7          	jalr	-1834(ra) # 80000586 <printf>
      printf("-> %d\n", p->trapframe->a0);
    80002cb8:	0589b783          	ld	a5,88(s3)
    80002cbc:	7bac                	ld	a1,112(a5)
    80002cbe:	00005517          	auipc	a0,0x5
    80002cc2:	78a50513          	addi	a0,a0,1930 # 80008448 <states.0+0x180>
    80002cc6:	ffffe097          	auipc	ra,0xffffe
    80002cca:	8c0080e7          	jalr	-1856(ra) # 80000586 <printf>
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002cce:	b771                	j	80002c5a <syscall+0x114>

0000000080002cd0 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002cd0:	1101                	addi	sp,sp,-32
    80002cd2:	ec06                	sd	ra,24(sp)
    80002cd4:	e822                	sd	s0,16(sp)
    80002cd6:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002cd8:	fec40593          	addi	a1,s0,-20
    80002cdc:	4501                	li	a0,0
    80002cde:	00000097          	auipc	ra,0x0
    80002ce2:	df0080e7          	jalr	-528(ra) # 80002ace <argint>
  exit(n);
    80002ce6:	fec42503          	lw	a0,-20(s0)
    80002cea:	fffff097          	auipc	ra,0xfffff
    80002cee:	4a4080e7          	jalr	1188(ra) # 8000218e <exit>
  return 0;  // not reached
}
    80002cf2:	4501                	li	a0,0
    80002cf4:	60e2                	ld	ra,24(sp)
    80002cf6:	6442                	ld	s0,16(sp)
    80002cf8:	6105                	addi	sp,sp,32
    80002cfa:	8082                	ret

0000000080002cfc <sys_getpid>:

uint64
sys_getpid(void)
{
    80002cfc:	1141                	addi	sp,sp,-16
    80002cfe:	e406                	sd	ra,8(sp)
    80002d00:	e022                	sd	s0,0(sp)
    80002d02:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002d04:	fffff097          	auipc	ra,0xfffff
    80002d08:	ca2080e7          	jalr	-862(ra) # 800019a6 <myproc>
}
    80002d0c:	5908                	lw	a0,48(a0)
    80002d0e:	60a2                	ld	ra,8(sp)
    80002d10:	6402                	ld	s0,0(sp)
    80002d12:	0141                	addi	sp,sp,16
    80002d14:	8082                	ret

0000000080002d16 <sys_fork>:

uint64
sys_fork(void)
{
    80002d16:	1141                	addi	sp,sp,-16
    80002d18:	e406                	sd	ra,8(sp)
    80002d1a:	e022                	sd	s0,0(sp)
    80002d1c:	0800                	addi	s0,sp,16
  return fork();
    80002d1e:	fffff097          	auipc	ra,0xfffff
    80002d22:	042080e7          	jalr	66(ra) # 80001d60 <fork>
}
    80002d26:	60a2                	ld	ra,8(sp)
    80002d28:	6402                	ld	s0,0(sp)
    80002d2a:	0141                	addi	sp,sp,16
    80002d2c:	8082                	ret

0000000080002d2e <sys_wait>:

uint64
sys_wait(void)
{
    80002d2e:	1101                	addi	sp,sp,-32
    80002d30:	ec06                	sd	ra,24(sp)
    80002d32:	e822                	sd	s0,16(sp)
    80002d34:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002d36:	fe840593          	addi	a1,s0,-24
    80002d3a:	4501                	li	a0,0
    80002d3c:	00000097          	auipc	ra,0x0
    80002d40:	db2080e7          	jalr	-590(ra) # 80002aee <argaddr>
  return wait(p);
    80002d44:	fe843503          	ld	a0,-24(s0)
    80002d48:	fffff097          	auipc	ra,0xfffff
    80002d4c:	5ec080e7          	jalr	1516(ra) # 80002334 <wait>
}
    80002d50:	60e2                	ld	ra,24(sp)
    80002d52:	6442                	ld	s0,16(sp)
    80002d54:	6105                	addi	sp,sp,32
    80002d56:	8082                	ret

0000000080002d58 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002d58:	7179                	addi	sp,sp,-48
    80002d5a:	f406                	sd	ra,40(sp)
    80002d5c:	f022                	sd	s0,32(sp)
    80002d5e:	ec26                	sd	s1,24(sp)
    80002d60:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002d62:	fdc40593          	addi	a1,s0,-36
    80002d66:	4501                	li	a0,0
    80002d68:	00000097          	auipc	ra,0x0
    80002d6c:	d66080e7          	jalr	-666(ra) # 80002ace <argint>
  addr = myproc()->sz;
    80002d70:	fffff097          	auipc	ra,0xfffff
    80002d74:	c36080e7          	jalr	-970(ra) # 800019a6 <myproc>
    80002d78:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002d7a:	fdc42503          	lw	a0,-36(s0)
    80002d7e:	fffff097          	auipc	ra,0xfffff
    80002d82:	f86080e7          	jalr	-122(ra) # 80001d04 <growproc>
    80002d86:	00054863          	bltz	a0,80002d96 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002d8a:	8526                	mv	a0,s1
    80002d8c:	70a2                	ld	ra,40(sp)
    80002d8e:	7402                	ld	s0,32(sp)
    80002d90:	64e2                	ld	s1,24(sp)
    80002d92:	6145                	addi	sp,sp,48
    80002d94:	8082                	ret
    return -1;
    80002d96:	54fd                	li	s1,-1
    80002d98:	bfcd                	j	80002d8a <sys_sbrk+0x32>

0000000080002d9a <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d9a:	7139                	addi	sp,sp,-64
    80002d9c:	fc06                	sd	ra,56(sp)
    80002d9e:	f822                	sd	s0,48(sp)
    80002da0:	f426                	sd	s1,40(sp)
    80002da2:	f04a                	sd	s2,32(sp)
    80002da4:	ec4e                	sd	s3,24(sp)
    80002da6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002da8:	fcc40593          	addi	a1,s0,-52
    80002dac:	4501                	li	a0,0
    80002dae:	00000097          	auipc	ra,0x0
    80002db2:	d20080e7          	jalr	-736(ra) # 80002ace <argint>
  acquire(&tickslock);
    80002db6:	00014517          	auipc	a0,0x14
    80002dba:	faa50513          	addi	a0,a0,-86 # 80016d60 <tickslock>
    80002dbe:	ffffe097          	auipc	ra,0xffffe
    80002dc2:	e14080e7          	jalr	-492(ra) # 80000bd2 <acquire>
  ticks0 = ticks;
    80002dc6:	00006917          	auipc	s2,0x6
    80002dca:	cfa92903          	lw	s2,-774(s2) # 80008ac0 <ticks>
  while(ticks - ticks0 < n){
    80002dce:	fcc42783          	lw	a5,-52(s0)
    80002dd2:	cf9d                	beqz	a5,80002e10 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002dd4:	00014997          	auipc	s3,0x14
    80002dd8:	f8c98993          	addi	s3,s3,-116 # 80016d60 <tickslock>
    80002ddc:	00006497          	auipc	s1,0x6
    80002de0:	ce448493          	addi	s1,s1,-796 # 80008ac0 <ticks>
    if(killed(myproc())){
    80002de4:	fffff097          	auipc	ra,0xfffff
    80002de8:	bc2080e7          	jalr	-1086(ra) # 800019a6 <myproc>
    80002dec:	fffff097          	auipc	ra,0xfffff
    80002df0:	516080e7          	jalr	1302(ra) # 80002302 <killed>
    80002df4:	ed15                	bnez	a0,80002e30 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002df6:	85ce                	mv	a1,s3
    80002df8:	8526                	mv	a0,s1
    80002dfa:	fffff097          	auipc	ra,0xfffff
    80002dfe:	260080e7          	jalr	608(ra) # 8000205a <sleep>
  while(ticks - ticks0 < n){
    80002e02:	409c                	lw	a5,0(s1)
    80002e04:	412787bb          	subw	a5,a5,s2
    80002e08:	fcc42703          	lw	a4,-52(s0)
    80002e0c:	fce7ece3          	bltu	a5,a4,80002de4 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002e10:	00014517          	auipc	a0,0x14
    80002e14:	f5050513          	addi	a0,a0,-176 # 80016d60 <tickslock>
    80002e18:	ffffe097          	auipc	ra,0xffffe
    80002e1c:	e6e080e7          	jalr	-402(ra) # 80000c86 <release>
  return 0;
    80002e20:	4501                	li	a0,0
}
    80002e22:	70e2                	ld	ra,56(sp)
    80002e24:	7442                	ld	s0,48(sp)
    80002e26:	74a2                	ld	s1,40(sp)
    80002e28:	7902                	ld	s2,32(sp)
    80002e2a:	69e2                	ld	s3,24(sp)
    80002e2c:	6121                	addi	sp,sp,64
    80002e2e:	8082                	ret
      release(&tickslock);
    80002e30:	00014517          	auipc	a0,0x14
    80002e34:	f3050513          	addi	a0,a0,-208 # 80016d60 <tickslock>
    80002e38:	ffffe097          	auipc	ra,0xffffe
    80002e3c:	e4e080e7          	jalr	-434(ra) # 80000c86 <release>
      return -1;
    80002e40:	557d                	li	a0,-1
    80002e42:	b7c5                	j	80002e22 <sys_sleep+0x88>

0000000080002e44 <sys_kill>:

uint64
sys_kill(void)
{
    80002e44:	1101                	addi	sp,sp,-32
    80002e46:	ec06                	sd	ra,24(sp)
    80002e48:	e822                	sd	s0,16(sp)
    80002e4a:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002e4c:	fec40593          	addi	a1,s0,-20
    80002e50:	4501                	li	a0,0
    80002e52:	00000097          	auipc	ra,0x0
    80002e56:	c7c080e7          	jalr	-900(ra) # 80002ace <argint>
  return kill(pid);
    80002e5a:	fec42503          	lw	a0,-20(s0)
    80002e5e:	fffff097          	auipc	ra,0xfffff
    80002e62:	406080e7          	jalr	1030(ra) # 80002264 <kill>
}
    80002e66:	60e2                	ld	ra,24(sp)
    80002e68:	6442                	ld	s0,16(sp)
    80002e6a:	6105                	addi	sp,sp,32
    80002e6c:	8082                	ret

0000000080002e6e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e6e:	1101                	addi	sp,sp,-32
    80002e70:	ec06                	sd	ra,24(sp)
    80002e72:	e822                	sd	s0,16(sp)
    80002e74:	e426                	sd	s1,8(sp)
    80002e76:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e78:	00014517          	auipc	a0,0x14
    80002e7c:	ee850513          	addi	a0,a0,-280 # 80016d60 <tickslock>
    80002e80:	ffffe097          	auipc	ra,0xffffe
    80002e84:	d52080e7          	jalr	-686(ra) # 80000bd2 <acquire>
  xticks = ticks;
    80002e88:	00006497          	auipc	s1,0x6
    80002e8c:	c384a483          	lw	s1,-968(s1) # 80008ac0 <ticks>
  release(&tickslock);
    80002e90:	00014517          	auipc	a0,0x14
    80002e94:	ed050513          	addi	a0,a0,-304 # 80016d60 <tickslock>
    80002e98:	ffffe097          	auipc	ra,0xffffe
    80002e9c:	dee080e7          	jalr	-530(ra) # 80000c86 <release>
  return xticks;
}
    80002ea0:	02049513          	slli	a0,s1,0x20
    80002ea4:	9101                	srli	a0,a0,0x20
    80002ea6:	60e2                	ld	ra,24(sp)
    80002ea8:	6442                	ld	s0,16(sp)
    80002eaa:	64a2                	ld	s1,8(sp)
    80002eac:	6105                	addi	sp,sp,32
    80002eae:	8082                	ret

0000000080002eb0 <sys_trace>:

uint64
sys_trace(void) {
    80002eb0:	1101                	addi	sp,sp,-32
    80002eb2:	ec06                	sd	ra,24(sp)
    80002eb4:	e822                	sd	s0,16(sp)
    80002eb6:	1000                	addi	s0,sp,32
  int mask;
  struct proc *p;

  argint(0, &mask);
    80002eb8:	fec40593          	addi	a1,s0,-20
    80002ebc:	4501                	li	a0,0
    80002ebe:	00000097          	auipc	ra,0x0
    80002ec2:	c10080e7          	jalr	-1008(ra) # 80002ace <argint>
  p = myproc();
    80002ec6:	fffff097          	auipc	ra,0xfffff
    80002eca:	ae0080e7          	jalr	-1312(ra) # 800019a6 <myproc>

  p->smask = mask;
    80002ece:	fec42783          	lw	a5,-20(s0)
    80002ed2:	16f52423          	sw	a5,360(a0)
  return 0;
    80002ed6:	4501                	li	a0,0
    80002ed8:	60e2                	ld	ra,24(sp)
    80002eda:	6442                	ld	s0,16(sp)
    80002edc:	6105                	addi	sp,sp,32
    80002ede:	8082                	ret

0000000080002ee0 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002ee0:	7179                	addi	sp,sp,-48
    80002ee2:	f406                	sd	ra,40(sp)
    80002ee4:	f022                	sd	s0,32(sp)
    80002ee6:	ec26                	sd	s1,24(sp)
    80002ee8:	e84a                	sd	s2,16(sp)
    80002eea:	e44e                	sd	s3,8(sp)
    80002eec:	e052                	sd	s4,0(sp)
    80002eee:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002ef0:	00006597          	auipc	a1,0x6
    80002ef4:	81058593          	addi	a1,a1,-2032 # 80008700 <syscall_names+0xb8>
    80002ef8:	00014517          	auipc	a0,0x14
    80002efc:	e8050513          	addi	a0,a0,-384 # 80016d78 <bcache>
    80002f00:	ffffe097          	auipc	ra,0xffffe
    80002f04:	c42080e7          	jalr	-958(ra) # 80000b42 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002f08:	0001c797          	auipc	a5,0x1c
    80002f0c:	e7078793          	addi	a5,a5,-400 # 8001ed78 <bcache+0x8000>
    80002f10:	0001c717          	auipc	a4,0x1c
    80002f14:	0d070713          	addi	a4,a4,208 # 8001efe0 <bcache+0x8268>
    80002f18:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002f1c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f20:	00014497          	auipc	s1,0x14
    80002f24:	e7048493          	addi	s1,s1,-400 # 80016d90 <bcache+0x18>
    b->next = bcache.head.next;
    80002f28:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f2a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f2c:	00005a17          	auipc	s4,0x5
    80002f30:	7dca0a13          	addi	s4,s4,2012 # 80008708 <syscall_names+0xc0>
    b->next = bcache.head.next;
    80002f34:	2b893783          	ld	a5,696(s2)
    80002f38:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f3a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f3e:	85d2                	mv	a1,s4
    80002f40:	01048513          	addi	a0,s1,16
    80002f44:	00001097          	auipc	ra,0x1
    80002f48:	496080e7          	jalr	1174(ra) # 800043da <initsleeplock>
    bcache.head.next->prev = b;
    80002f4c:	2b893783          	ld	a5,696(s2)
    80002f50:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f52:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f56:	45848493          	addi	s1,s1,1112
    80002f5a:	fd349de3          	bne	s1,s3,80002f34 <binit+0x54>
  }
}
    80002f5e:	70a2                	ld	ra,40(sp)
    80002f60:	7402                	ld	s0,32(sp)
    80002f62:	64e2                	ld	s1,24(sp)
    80002f64:	6942                	ld	s2,16(sp)
    80002f66:	69a2                	ld	s3,8(sp)
    80002f68:	6a02                	ld	s4,0(sp)
    80002f6a:	6145                	addi	sp,sp,48
    80002f6c:	8082                	ret

0000000080002f6e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f6e:	7179                	addi	sp,sp,-48
    80002f70:	f406                	sd	ra,40(sp)
    80002f72:	f022                	sd	s0,32(sp)
    80002f74:	ec26                	sd	s1,24(sp)
    80002f76:	e84a                	sd	s2,16(sp)
    80002f78:	e44e                	sd	s3,8(sp)
    80002f7a:	1800                	addi	s0,sp,48
    80002f7c:	892a                	mv	s2,a0
    80002f7e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002f80:	00014517          	auipc	a0,0x14
    80002f84:	df850513          	addi	a0,a0,-520 # 80016d78 <bcache>
    80002f88:	ffffe097          	auipc	ra,0xffffe
    80002f8c:	c4a080e7          	jalr	-950(ra) # 80000bd2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002f90:	0001c497          	auipc	s1,0x1c
    80002f94:	0a04b483          	ld	s1,160(s1) # 8001f030 <bcache+0x82b8>
    80002f98:	0001c797          	auipc	a5,0x1c
    80002f9c:	04878793          	addi	a5,a5,72 # 8001efe0 <bcache+0x8268>
    80002fa0:	02f48f63          	beq	s1,a5,80002fde <bread+0x70>
    80002fa4:	873e                	mv	a4,a5
    80002fa6:	a021                	j	80002fae <bread+0x40>
    80002fa8:	68a4                	ld	s1,80(s1)
    80002faa:	02e48a63          	beq	s1,a4,80002fde <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002fae:	449c                	lw	a5,8(s1)
    80002fb0:	ff279ce3          	bne	a5,s2,80002fa8 <bread+0x3a>
    80002fb4:	44dc                	lw	a5,12(s1)
    80002fb6:	ff3799e3          	bne	a5,s3,80002fa8 <bread+0x3a>
      b->refcnt++;
    80002fba:	40bc                	lw	a5,64(s1)
    80002fbc:	2785                	addiw	a5,a5,1
    80002fbe:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fc0:	00014517          	auipc	a0,0x14
    80002fc4:	db850513          	addi	a0,a0,-584 # 80016d78 <bcache>
    80002fc8:	ffffe097          	auipc	ra,0xffffe
    80002fcc:	cbe080e7          	jalr	-834(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    80002fd0:	01048513          	addi	a0,s1,16
    80002fd4:	00001097          	auipc	ra,0x1
    80002fd8:	440080e7          	jalr	1088(ra) # 80004414 <acquiresleep>
      return b;
    80002fdc:	a8b9                	j	8000303a <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fde:	0001c497          	auipc	s1,0x1c
    80002fe2:	04a4b483          	ld	s1,74(s1) # 8001f028 <bcache+0x82b0>
    80002fe6:	0001c797          	auipc	a5,0x1c
    80002fea:	ffa78793          	addi	a5,a5,-6 # 8001efe0 <bcache+0x8268>
    80002fee:	00f48863          	beq	s1,a5,80002ffe <bread+0x90>
    80002ff2:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002ff4:	40bc                	lw	a5,64(s1)
    80002ff6:	cf81                	beqz	a5,8000300e <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ff8:	64a4                	ld	s1,72(s1)
    80002ffa:	fee49de3          	bne	s1,a4,80002ff4 <bread+0x86>
  panic("bget: no buffers");
    80002ffe:	00005517          	auipc	a0,0x5
    80003002:	71250513          	addi	a0,a0,1810 # 80008710 <syscall_names+0xc8>
    80003006:	ffffd097          	auipc	ra,0xffffd
    8000300a:	536080e7          	jalr	1334(ra) # 8000053c <panic>
      b->dev = dev;
    8000300e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003012:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003016:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000301a:	4785                	li	a5,1
    8000301c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000301e:	00014517          	auipc	a0,0x14
    80003022:	d5a50513          	addi	a0,a0,-678 # 80016d78 <bcache>
    80003026:	ffffe097          	auipc	ra,0xffffe
    8000302a:	c60080e7          	jalr	-928(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    8000302e:	01048513          	addi	a0,s1,16
    80003032:	00001097          	auipc	ra,0x1
    80003036:	3e2080e7          	jalr	994(ra) # 80004414 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000303a:	409c                	lw	a5,0(s1)
    8000303c:	cb89                	beqz	a5,8000304e <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000303e:	8526                	mv	a0,s1
    80003040:	70a2                	ld	ra,40(sp)
    80003042:	7402                	ld	s0,32(sp)
    80003044:	64e2                	ld	s1,24(sp)
    80003046:	6942                	ld	s2,16(sp)
    80003048:	69a2                	ld	s3,8(sp)
    8000304a:	6145                	addi	sp,sp,48
    8000304c:	8082                	ret
    virtio_disk_rw(b, 0);
    8000304e:	4581                	li	a1,0
    80003050:	8526                	mv	a0,s1
    80003052:	00003097          	auipc	ra,0x3
    80003056:	f80080e7          	jalr	-128(ra) # 80005fd2 <virtio_disk_rw>
    b->valid = 1;
    8000305a:	4785                	li	a5,1
    8000305c:	c09c                	sw	a5,0(s1)
  return b;
    8000305e:	b7c5                	j	8000303e <bread+0xd0>

0000000080003060 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003060:	1101                	addi	sp,sp,-32
    80003062:	ec06                	sd	ra,24(sp)
    80003064:	e822                	sd	s0,16(sp)
    80003066:	e426                	sd	s1,8(sp)
    80003068:	1000                	addi	s0,sp,32
    8000306a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000306c:	0541                	addi	a0,a0,16
    8000306e:	00001097          	auipc	ra,0x1
    80003072:	440080e7          	jalr	1088(ra) # 800044ae <holdingsleep>
    80003076:	cd01                	beqz	a0,8000308e <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003078:	4585                	li	a1,1
    8000307a:	8526                	mv	a0,s1
    8000307c:	00003097          	auipc	ra,0x3
    80003080:	f56080e7          	jalr	-170(ra) # 80005fd2 <virtio_disk_rw>
}
    80003084:	60e2                	ld	ra,24(sp)
    80003086:	6442                	ld	s0,16(sp)
    80003088:	64a2                	ld	s1,8(sp)
    8000308a:	6105                	addi	sp,sp,32
    8000308c:	8082                	ret
    panic("bwrite");
    8000308e:	00005517          	auipc	a0,0x5
    80003092:	69a50513          	addi	a0,a0,1690 # 80008728 <syscall_names+0xe0>
    80003096:	ffffd097          	auipc	ra,0xffffd
    8000309a:	4a6080e7          	jalr	1190(ra) # 8000053c <panic>

000000008000309e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000309e:	1101                	addi	sp,sp,-32
    800030a0:	ec06                	sd	ra,24(sp)
    800030a2:	e822                	sd	s0,16(sp)
    800030a4:	e426                	sd	s1,8(sp)
    800030a6:	e04a                	sd	s2,0(sp)
    800030a8:	1000                	addi	s0,sp,32
    800030aa:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030ac:	01050913          	addi	s2,a0,16
    800030b0:	854a                	mv	a0,s2
    800030b2:	00001097          	auipc	ra,0x1
    800030b6:	3fc080e7          	jalr	1020(ra) # 800044ae <holdingsleep>
    800030ba:	c925                	beqz	a0,8000312a <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    800030bc:	854a                	mv	a0,s2
    800030be:	00001097          	auipc	ra,0x1
    800030c2:	3ac080e7          	jalr	940(ra) # 8000446a <releasesleep>

  acquire(&bcache.lock);
    800030c6:	00014517          	auipc	a0,0x14
    800030ca:	cb250513          	addi	a0,a0,-846 # 80016d78 <bcache>
    800030ce:	ffffe097          	auipc	ra,0xffffe
    800030d2:	b04080e7          	jalr	-1276(ra) # 80000bd2 <acquire>
  b->refcnt--;
    800030d6:	40bc                	lw	a5,64(s1)
    800030d8:	37fd                	addiw	a5,a5,-1
    800030da:	0007871b          	sext.w	a4,a5
    800030de:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800030e0:	e71d                	bnez	a4,8000310e <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800030e2:	68b8                	ld	a4,80(s1)
    800030e4:	64bc                	ld	a5,72(s1)
    800030e6:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800030e8:	68b8                	ld	a4,80(s1)
    800030ea:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800030ec:	0001c797          	auipc	a5,0x1c
    800030f0:	c8c78793          	addi	a5,a5,-884 # 8001ed78 <bcache+0x8000>
    800030f4:	2b87b703          	ld	a4,696(a5)
    800030f8:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800030fa:	0001c717          	auipc	a4,0x1c
    800030fe:	ee670713          	addi	a4,a4,-282 # 8001efe0 <bcache+0x8268>
    80003102:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003104:	2b87b703          	ld	a4,696(a5)
    80003108:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000310a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000310e:	00014517          	auipc	a0,0x14
    80003112:	c6a50513          	addi	a0,a0,-918 # 80016d78 <bcache>
    80003116:	ffffe097          	auipc	ra,0xffffe
    8000311a:	b70080e7          	jalr	-1168(ra) # 80000c86 <release>
}
    8000311e:	60e2                	ld	ra,24(sp)
    80003120:	6442                	ld	s0,16(sp)
    80003122:	64a2                	ld	s1,8(sp)
    80003124:	6902                	ld	s2,0(sp)
    80003126:	6105                	addi	sp,sp,32
    80003128:	8082                	ret
    panic("brelse");
    8000312a:	00005517          	auipc	a0,0x5
    8000312e:	60650513          	addi	a0,a0,1542 # 80008730 <syscall_names+0xe8>
    80003132:	ffffd097          	auipc	ra,0xffffd
    80003136:	40a080e7          	jalr	1034(ra) # 8000053c <panic>

000000008000313a <bpin>:

void
bpin(struct buf *b) {
    8000313a:	1101                	addi	sp,sp,-32
    8000313c:	ec06                	sd	ra,24(sp)
    8000313e:	e822                	sd	s0,16(sp)
    80003140:	e426                	sd	s1,8(sp)
    80003142:	1000                	addi	s0,sp,32
    80003144:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003146:	00014517          	auipc	a0,0x14
    8000314a:	c3250513          	addi	a0,a0,-974 # 80016d78 <bcache>
    8000314e:	ffffe097          	auipc	ra,0xffffe
    80003152:	a84080e7          	jalr	-1404(ra) # 80000bd2 <acquire>
  b->refcnt++;
    80003156:	40bc                	lw	a5,64(s1)
    80003158:	2785                	addiw	a5,a5,1
    8000315a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000315c:	00014517          	auipc	a0,0x14
    80003160:	c1c50513          	addi	a0,a0,-996 # 80016d78 <bcache>
    80003164:	ffffe097          	auipc	ra,0xffffe
    80003168:	b22080e7          	jalr	-1246(ra) # 80000c86 <release>
}
    8000316c:	60e2                	ld	ra,24(sp)
    8000316e:	6442                	ld	s0,16(sp)
    80003170:	64a2                	ld	s1,8(sp)
    80003172:	6105                	addi	sp,sp,32
    80003174:	8082                	ret

0000000080003176 <bunpin>:

void
bunpin(struct buf *b) {
    80003176:	1101                	addi	sp,sp,-32
    80003178:	ec06                	sd	ra,24(sp)
    8000317a:	e822                	sd	s0,16(sp)
    8000317c:	e426                	sd	s1,8(sp)
    8000317e:	1000                	addi	s0,sp,32
    80003180:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003182:	00014517          	auipc	a0,0x14
    80003186:	bf650513          	addi	a0,a0,-1034 # 80016d78 <bcache>
    8000318a:	ffffe097          	auipc	ra,0xffffe
    8000318e:	a48080e7          	jalr	-1464(ra) # 80000bd2 <acquire>
  b->refcnt--;
    80003192:	40bc                	lw	a5,64(s1)
    80003194:	37fd                	addiw	a5,a5,-1
    80003196:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003198:	00014517          	auipc	a0,0x14
    8000319c:	be050513          	addi	a0,a0,-1056 # 80016d78 <bcache>
    800031a0:	ffffe097          	auipc	ra,0xffffe
    800031a4:	ae6080e7          	jalr	-1306(ra) # 80000c86 <release>
}
    800031a8:	60e2                	ld	ra,24(sp)
    800031aa:	6442                	ld	s0,16(sp)
    800031ac:	64a2                	ld	s1,8(sp)
    800031ae:	6105                	addi	sp,sp,32
    800031b0:	8082                	ret

00000000800031b2 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800031b2:	1101                	addi	sp,sp,-32
    800031b4:	ec06                	sd	ra,24(sp)
    800031b6:	e822                	sd	s0,16(sp)
    800031b8:	e426                	sd	s1,8(sp)
    800031ba:	e04a                	sd	s2,0(sp)
    800031bc:	1000                	addi	s0,sp,32
    800031be:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800031c0:	00d5d59b          	srliw	a1,a1,0xd
    800031c4:	0001c797          	auipc	a5,0x1c
    800031c8:	2907a783          	lw	a5,656(a5) # 8001f454 <sb+0x1c>
    800031cc:	9dbd                	addw	a1,a1,a5
    800031ce:	00000097          	auipc	ra,0x0
    800031d2:	da0080e7          	jalr	-608(ra) # 80002f6e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800031d6:	0074f713          	andi	a4,s1,7
    800031da:	4785                	li	a5,1
    800031dc:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800031e0:	14ce                	slli	s1,s1,0x33
    800031e2:	90d9                	srli	s1,s1,0x36
    800031e4:	00950733          	add	a4,a0,s1
    800031e8:	05874703          	lbu	a4,88(a4)
    800031ec:	00e7f6b3          	and	a3,a5,a4
    800031f0:	c69d                	beqz	a3,8000321e <bfree+0x6c>
    800031f2:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800031f4:	94aa                	add	s1,s1,a0
    800031f6:	fff7c793          	not	a5,a5
    800031fa:	8f7d                	and	a4,a4,a5
    800031fc:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003200:	00001097          	auipc	ra,0x1
    80003204:	0f6080e7          	jalr	246(ra) # 800042f6 <log_write>
  brelse(bp);
    80003208:	854a                	mv	a0,s2
    8000320a:	00000097          	auipc	ra,0x0
    8000320e:	e94080e7          	jalr	-364(ra) # 8000309e <brelse>
}
    80003212:	60e2                	ld	ra,24(sp)
    80003214:	6442                	ld	s0,16(sp)
    80003216:	64a2                	ld	s1,8(sp)
    80003218:	6902                	ld	s2,0(sp)
    8000321a:	6105                	addi	sp,sp,32
    8000321c:	8082                	ret
    panic("freeing free block");
    8000321e:	00005517          	auipc	a0,0x5
    80003222:	51a50513          	addi	a0,a0,1306 # 80008738 <syscall_names+0xf0>
    80003226:	ffffd097          	auipc	ra,0xffffd
    8000322a:	316080e7          	jalr	790(ra) # 8000053c <panic>

000000008000322e <balloc>:
{
    8000322e:	711d                	addi	sp,sp,-96
    80003230:	ec86                	sd	ra,88(sp)
    80003232:	e8a2                	sd	s0,80(sp)
    80003234:	e4a6                	sd	s1,72(sp)
    80003236:	e0ca                	sd	s2,64(sp)
    80003238:	fc4e                	sd	s3,56(sp)
    8000323a:	f852                	sd	s4,48(sp)
    8000323c:	f456                	sd	s5,40(sp)
    8000323e:	f05a                	sd	s6,32(sp)
    80003240:	ec5e                	sd	s7,24(sp)
    80003242:	e862                	sd	s8,16(sp)
    80003244:	e466                	sd	s9,8(sp)
    80003246:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003248:	0001c797          	auipc	a5,0x1c
    8000324c:	1f47a783          	lw	a5,500(a5) # 8001f43c <sb+0x4>
    80003250:	cff5                	beqz	a5,8000334c <balloc+0x11e>
    80003252:	8baa                	mv	s7,a0
    80003254:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003256:	0001cb17          	auipc	s6,0x1c
    8000325a:	1e2b0b13          	addi	s6,s6,482 # 8001f438 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000325e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003260:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003262:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003264:	6c89                	lui	s9,0x2
    80003266:	a061                	j	800032ee <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003268:	97ca                	add	a5,a5,s2
    8000326a:	8e55                	or	a2,a2,a3
    8000326c:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003270:	854a                	mv	a0,s2
    80003272:	00001097          	auipc	ra,0x1
    80003276:	084080e7          	jalr	132(ra) # 800042f6 <log_write>
        brelse(bp);
    8000327a:	854a                	mv	a0,s2
    8000327c:	00000097          	auipc	ra,0x0
    80003280:	e22080e7          	jalr	-478(ra) # 8000309e <brelse>
  bp = bread(dev, bno);
    80003284:	85a6                	mv	a1,s1
    80003286:	855e                	mv	a0,s7
    80003288:	00000097          	auipc	ra,0x0
    8000328c:	ce6080e7          	jalr	-794(ra) # 80002f6e <bread>
    80003290:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003292:	40000613          	li	a2,1024
    80003296:	4581                	li	a1,0
    80003298:	05850513          	addi	a0,a0,88
    8000329c:	ffffe097          	auipc	ra,0xffffe
    800032a0:	a32080e7          	jalr	-1486(ra) # 80000cce <memset>
  log_write(bp);
    800032a4:	854a                	mv	a0,s2
    800032a6:	00001097          	auipc	ra,0x1
    800032aa:	050080e7          	jalr	80(ra) # 800042f6 <log_write>
  brelse(bp);
    800032ae:	854a                	mv	a0,s2
    800032b0:	00000097          	auipc	ra,0x0
    800032b4:	dee080e7          	jalr	-530(ra) # 8000309e <brelse>
}
    800032b8:	8526                	mv	a0,s1
    800032ba:	60e6                	ld	ra,88(sp)
    800032bc:	6446                	ld	s0,80(sp)
    800032be:	64a6                	ld	s1,72(sp)
    800032c0:	6906                	ld	s2,64(sp)
    800032c2:	79e2                	ld	s3,56(sp)
    800032c4:	7a42                	ld	s4,48(sp)
    800032c6:	7aa2                	ld	s5,40(sp)
    800032c8:	7b02                	ld	s6,32(sp)
    800032ca:	6be2                	ld	s7,24(sp)
    800032cc:	6c42                	ld	s8,16(sp)
    800032ce:	6ca2                	ld	s9,8(sp)
    800032d0:	6125                	addi	sp,sp,96
    800032d2:	8082                	ret
    brelse(bp);
    800032d4:	854a                	mv	a0,s2
    800032d6:	00000097          	auipc	ra,0x0
    800032da:	dc8080e7          	jalr	-568(ra) # 8000309e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800032de:	015c87bb          	addw	a5,s9,s5
    800032e2:	00078a9b          	sext.w	s5,a5
    800032e6:	004b2703          	lw	a4,4(s6)
    800032ea:	06eaf163          	bgeu	s5,a4,8000334c <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    800032ee:	41fad79b          	sraiw	a5,s5,0x1f
    800032f2:	0137d79b          	srliw	a5,a5,0x13
    800032f6:	015787bb          	addw	a5,a5,s5
    800032fa:	40d7d79b          	sraiw	a5,a5,0xd
    800032fe:	01cb2583          	lw	a1,28(s6)
    80003302:	9dbd                	addw	a1,a1,a5
    80003304:	855e                	mv	a0,s7
    80003306:	00000097          	auipc	ra,0x0
    8000330a:	c68080e7          	jalr	-920(ra) # 80002f6e <bread>
    8000330e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003310:	004b2503          	lw	a0,4(s6)
    80003314:	000a849b          	sext.w	s1,s5
    80003318:	8762                	mv	a4,s8
    8000331a:	faa4fde3          	bgeu	s1,a0,800032d4 <balloc+0xa6>
      m = 1 << (bi % 8);
    8000331e:	00777693          	andi	a3,a4,7
    80003322:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003326:	41f7579b          	sraiw	a5,a4,0x1f
    8000332a:	01d7d79b          	srliw	a5,a5,0x1d
    8000332e:	9fb9                	addw	a5,a5,a4
    80003330:	4037d79b          	sraiw	a5,a5,0x3
    80003334:	00f90633          	add	a2,s2,a5
    80003338:	05864603          	lbu	a2,88(a2)
    8000333c:	00c6f5b3          	and	a1,a3,a2
    80003340:	d585                	beqz	a1,80003268 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003342:	2705                	addiw	a4,a4,1
    80003344:	2485                	addiw	s1,s1,1
    80003346:	fd471ae3          	bne	a4,s4,8000331a <balloc+0xec>
    8000334a:	b769                	j	800032d4 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    8000334c:	00005517          	auipc	a0,0x5
    80003350:	40450513          	addi	a0,a0,1028 # 80008750 <syscall_names+0x108>
    80003354:	ffffd097          	auipc	ra,0xffffd
    80003358:	232080e7          	jalr	562(ra) # 80000586 <printf>
  return 0;
    8000335c:	4481                	li	s1,0
    8000335e:	bfa9                	j	800032b8 <balloc+0x8a>

0000000080003360 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003360:	7179                	addi	sp,sp,-48
    80003362:	f406                	sd	ra,40(sp)
    80003364:	f022                	sd	s0,32(sp)
    80003366:	ec26                	sd	s1,24(sp)
    80003368:	e84a                	sd	s2,16(sp)
    8000336a:	e44e                	sd	s3,8(sp)
    8000336c:	e052                	sd	s4,0(sp)
    8000336e:	1800                	addi	s0,sp,48
    80003370:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003372:	47ad                	li	a5,11
    80003374:	02b7e863          	bltu	a5,a1,800033a4 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003378:	02059793          	slli	a5,a1,0x20
    8000337c:	01e7d593          	srli	a1,a5,0x1e
    80003380:	00b504b3          	add	s1,a0,a1
    80003384:	0504a903          	lw	s2,80(s1)
    80003388:	06091e63          	bnez	s2,80003404 <bmap+0xa4>
      addr = balloc(ip->dev);
    8000338c:	4108                	lw	a0,0(a0)
    8000338e:	00000097          	auipc	ra,0x0
    80003392:	ea0080e7          	jalr	-352(ra) # 8000322e <balloc>
    80003396:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000339a:	06090563          	beqz	s2,80003404 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    8000339e:	0524a823          	sw	s2,80(s1)
    800033a2:	a08d                	j	80003404 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800033a4:	ff45849b          	addiw	s1,a1,-12
    800033a8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800033ac:	0ff00793          	li	a5,255
    800033b0:	08e7e563          	bltu	a5,a4,8000343a <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800033b4:	08052903          	lw	s2,128(a0)
    800033b8:	00091d63          	bnez	s2,800033d2 <bmap+0x72>
      addr = balloc(ip->dev);
    800033bc:	4108                	lw	a0,0(a0)
    800033be:	00000097          	auipc	ra,0x0
    800033c2:	e70080e7          	jalr	-400(ra) # 8000322e <balloc>
    800033c6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800033ca:	02090d63          	beqz	s2,80003404 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800033ce:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800033d2:	85ca                	mv	a1,s2
    800033d4:	0009a503          	lw	a0,0(s3)
    800033d8:	00000097          	auipc	ra,0x0
    800033dc:	b96080e7          	jalr	-1130(ra) # 80002f6e <bread>
    800033e0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800033e2:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800033e6:	02049713          	slli	a4,s1,0x20
    800033ea:	01e75593          	srli	a1,a4,0x1e
    800033ee:	00b784b3          	add	s1,a5,a1
    800033f2:	0004a903          	lw	s2,0(s1)
    800033f6:	02090063          	beqz	s2,80003416 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800033fa:	8552                	mv	a0,s4
    800033fc:	00000097          	auipc	ra,0x0
    80003400:	ca2080e7          	jalr	-862(ra) # 8000309e <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003404:	854a                	mv	a0,s2
    80003406:	70a2                	ld	ra,40(sp)
    80003408:	7402                	ld	s0,32(sp)
    8000340a:	64e2                	ld	s1,24(sp)
    8000340c:	6942                	ld	s2,16(sp)
    8000340e:	69a2                	ld	s3,8(sp)
    80003410:	6a02                	ld	s4,0(sp)
    80003412:	6145                	addi	sp,sp,48
    80003414:	8082                	ret
      addr = balloc(ip->dev);
    80003416:	0009a503          	lw	a0,0(s3)
    8000341a:	00000097          	auipc	ra,0x0
    8000341e:	e14080e7          	jalr	-492(ra) # 8000322e <balloc>
    80003422:	0005091b          	sext.w	s2,a0
      if(addr){
    80003426:	fc090ae3          	beqz	s2,800033fa <bmap+0x9a>
        a[bn] = addr;
    8000342a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000342e:	8552                	mv	a0,s4
    80003430:	00001097          	auipc	ra,0x1
    80003434:	ec6080e7          	jalr	-314(ra) # 800042f6 <log_write>
    80003438:	b7c9                	j	800033fa <bmap+0x9a>
  panic("bmap: out of range");
    8000343a:	00005517          	auipc	a0,0x5
    8000343e:	32e50513          	addi	a0,a0,814 # 80008768 <syscall_names+0x120>
    80003442:	ffffd097          	auipc	ra,0xffffd
    80003446:	0fa080e7          	jalr	250(ra) # 8000053c <panic>

000000008000344a <iget>:
{
    8000344a:	7179                	addi	sp,sp,-48
    8000344c:	f406                	sd	ra,40(sp)
    8000344e:	f022                	sd	s0,32(sp)
    80003450:	ec26                	sd	s1,24(sp)
    80003452:	e84a                	sd	s2,16(sp)
    80003454:	e44e                	sd	s3,8(sp)
    80003456:	e052                	sd	s4,0(sp)
    80003458:	1800                	addi	s0,sp,48
    8000345a:	89aa                	mv	s3,a0
    8000345c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000345e:	0001c517          	auipc	a0,0x1c
    80003462:	ffa50513          	addi	a0,a0,-6 # 8001f458 <itable>
    80003466:	ffffd097          	auipc	ra,0xffffd
    8000346a:	76c080e7          	jalr	1900(ra) # 80000bd2 <acquire>
  empty = 0;
    8000346e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003470:	0001c497          	auipc	s1,0x1c
    80003474:	00048493          	mv	s1,s1
    80003478:	0001e697          	auipc	a3,0x1e
    8000347c:	a8868693          	addi	a3,a3,-1400 # 80020f00 <log>
    80003480:	a039                	j	8000348e <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003482:	02090b63          	beqz	s2,800034b8 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003486:	08848493          	addi	s1,s1,136 # 8001f4f8 <itable+0xa0>
    8000348a:	02d48a63          	beq	s1,a3,800034be <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000348e:	449c                	lw	a5,8(s1)
    80003490:	fef059e3          	blez	a5,80003482 <iget+0x38>
    80003494:	4098                	lw	a4,0(s1)
    80003496:	ff3716e3          	bne	a4,s3,80003482 <iget+0x38>
    8000349a:	40d8                	lw	a4,4(s1)
    8000349c:	ff4713e3          	bne	a4,s4,80003482 <iget+0x38>
      ip->ref++;
    800034a0:	2785                	addiw	a5,a5,1
    800034a2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800034a4:	0001c517          	auipc	a0,0x1c
    800034a8:	fb450513          	addi	a0,a0,-76 # 8001f458 <itable>
    800034ac:	ffffd097          	auipc	ra,0xffffd
    800034b0:	7da080e7          	jalr	2010(ra) # 80000c86 <release>
      return ip;
    800034b4:	8926                	mv	s2,s1
    800034b6:	a03d                	j	800034e4 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034b8:	f7f9                	bnez	a5,80003486 <iget+0x3c>
    800034ba:	8926                	mv	s2,s1
    800034bc:	b7e9                	j	80003486 <iget+0x3c>
  if(empty == 0)
    800034be:	02090c63          	beqz	s2,800034f6 <iget+0xac>
  ip->dev = dev;
    800034c2:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800034c6:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800034ca:	4785                	li	a5,1
    800034cc:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800034d0:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800034d4:	0001c517          	auipc	a0,0x1c
    800034d8:	f8450513          	addi	a0,a0,-124 # 8001f458 <itable>
    800034dc:	ffffd097          	auipc	ra,0xffffd
    800034e0:	7aa080e7          	jalr	1962(ra) # 80000c86 <release>
}
    800034e4:	854a                	mv	a0,s2
    800034e6:	70a2                	ld	ra,40(sp)
    800034e8:	7402                	ld	s0,32(sp)
    800034ea:	64e2                	ld	s1,24(sp)
    800034ec:	6942                	ld	s2,16(sp)
    800034ee:	69a2                	ld	s3,8(sp)
    800034f0:	6a02                	ld	s4,0(sp)
    800034f2:	6145                	addi	sp,sp,48
    800034f4:	8082                	ret
    panic("iget: no inodes");
    800034f6:	00005517          	auipc	a0,0x5
    800034fa:	28a50513          	addi	a0,a0,650 # 80008780 <syscall_names+0x138>
    800034fe:	ffffd097          	auipc	ra,0xffffd
    80003502:	03e080e7          	jalr	62(ra) # 8000053c <panic>

0000000080003506 <fsinit>:
fsinit(int dev) {
    80003506:	7179                	addi	sp,sp,-48
    80003508:	f406                	sd	ra,40(sp)
    8000350a:	f022                	sd	s0,32(sp)
    8000350c:	ec26                	sd	s1,24(sp)
    8000350e:	e84a                	sd	s2,16(sp)
    80003510:	e44e                	sd	s3,8(sp)
    80003512:	1800                	addi	s0,sp,48
    80003514:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003516:	4585                	li	a1,1
    80003518:	00000097          	auipc	ra,0x0
    8000351c:	a56080e7          	jalr	-1450(ra) # 80002f6e <bread>
    80003520:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003522:	0001c997          	auipc	s3,0x1c
    80003526:	f1698993          	addi	s3,s3,-234 # 8001f438 <sb>
    8000352a:	02000613          	li	a2,32
    8000352e:	05850593          	addi	a1,a0,88
    80003532:	854e                	mv	a0,s3
    80003534:	ffffd097          	auipc	ra,0xffffd
    80003538:	7f6080e7          	jalr	2038(ra) # 80000d2a <memmove>
  brelse(bp);
    8000353c:	8526                	mv	a0,s1
    8000353e:	00000097          	auipc	ra,0x0
    80003542:	b60080e7          	jalr	-1184(ra) # 8000309e <brelse>
  if(sb.magic != FSMAGIC)
    80003546:	0009a703          	lw	a4,0(s3)
    8000354a:	102037b7          	lui	a5,0x10203
    8000354e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003552:	02f71263          	bne	a4,a5,80003576 <fsinit+0x70>
  initlog(dev, &sb);
    80003556:	0001c597          	auipc	a1,0x1c
    8000355a:	ee258593          	addi	a1,a1,-286 # 8001f438 <sb>
    8000355e:	854a                	mv	a0,s2
    80003560:	00001097          	auipc	ra,0x1
    80003564:	b2c080e7          	jalr	-1236(ra) # 8000408c <initlog>
}
    80003568:	70a2                	ld	ra,40(sp)
    8000356a:	7402                	ld	s0,32(sp)
    8000356c:	64e2                	ld	s1,24(sp)
    8000356e:	6942                	ld	s2,16(sp)
    80003570:	69a2                	ld	s3,8(sp)
    80003572:	6145                	addi	sp,sp,48
    80003574:	8082                	ret
    panic("invalid file system");
    80003576:	00005517          	auipc	a0,0x5
    8000357a:	21a50513          	addi	a0,a0,538 # 80008790 <syscall_names+0x148>
    8000357e:	ffffd097          	auipc	ra,0xffffd
    80003582:	fbe080e7          	jalr	-66(ra) # 8000053c <panic>

0000000080003586 <iinit>:
{
    80003586:	7179                	addi	sp,sp,-48
    80003588:	f406                	sd	ra,40(sp)
    8000358a:	f022                	sd	s0,32(sp)
    8000358c:	ec26                	sd	s1,24(sp)
    8000358e:	e84a                	sd	s2,16(sp)
    80003590:	e44e                	sd	s3,8(sp)
    80003592:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003594:	00005597          	auipc	a1,0x5
    80003598:	21458593          	addi	a1,a1,532 # 800087a8 <syscall_names+0x160>
    8000359c:	0001c517          	auipc	a0,0x1c
    800035a0:	ebc50513          	addi	a0,a0,-324 # 8001f458 <itable>
    800035a4:	ffffd097          	auipc	ra,0xffffd
    800035a8:	59e080e7          	jalr	1438(ra) # 80000b42 <initlock>
  for(i = 0; i < NINODE; i++) {
    800035ac:	0001c497          	auipc	s1,0x1c
    800035b0:	ed448493          	addi	s1,s1,-300 # 8001f480 <itable+0x28>
    800035b4:	0001e997          	auipc	s3,0x1e
    800035b8:	95c98993          	addi	s3,s3,-1700 # 80020f10 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800035bc:	00005917          	auipc	s2,0x5
    800035c0:	1f490913          	addi	s2,s2,500 # 800087b0 <syscall_names+0x168>
    800035c4:	85ca                	mv	a1,s2
    800035c6:	8526                	mv	a0,s1
    800035c8:	00001097          	auipc	ra,0x1
    800035cc:	e12080e7          	jalr	-494(ra) # 800043da <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800035d0:	08848493          	addi	s1,s1,136
    800035d4:	ff3498e3          	bne	s1,s3,800035c4 <iinit+0x3e>
}
    800035d8:	70a2                	ld	ra,40(sp)
    800035da:	7402                	ld	s0,32(sp)
    800035dc:	64e2                	ld	s1,24(sp)
    800035de:	6942                	ld	s2,16(sp)
    800035e0:	69a2                	ld	s3,8(sp)
    800035e2:	6145                	addi	sp,sp,48
    800035e4:	8082                	ret

00000000800035e6 <ialloc>:
{
    800035e6:	7139                	addi	sp,sp,-64
    800035e8:	fc06                	sd	ra,56(sp)
    800035ea:	f822                	sd	s0,48(sp)
    800035ec:	f426                	sd	s1,40(sp)
    800035ee:	f04a                	sd	s2,32(sp)
    800035f0:	ec4e                	sd	s3,24(sp)
    800035f2:	e852                	sd	s4,16(sp)
    800035f4:	e456                	sd	s5,8(sp)
    800035f6:	e05a                	sd	s6,0(sp)
    800035f8:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800035fa:	0001c717          	auipc	a4,0x1c
    800035fe:	e4a72703          	lw	a4,-438(a4) # 8001f444 <sb+0xc>
    80003602:	4785                	li	a5,1
    80003604:	04e7f863          	bgeu	a5,a4,80003654 <ialloc+0x6e>
    80003608:	8aaa                	mv	s5,a0
    8000360a:	8b2e                	mv	s6,a1
    8000360c:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000360e:	0001ca17          	auipc	s4,0x1c
    80003612:	e2aa0a13          	addi	s4,s4,-470 # 8001f438 <sb>
    80003616:	00495593          	srli	a1,s2,0x4
    8000361a:	018a2783          	lw	a5,24(s4)
    8000361e:	9dbd                	addw	a1,a1,a5
    80003620:	8556                	mv	a0,s5
    80003622:	00000097          	auipc	ra,0x0
    80003626:	94c080e7          	jalr	-1716(ra) # 80002f6e <bread>
    8000362a:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000362c:	05850993          	addi	s3,a0,88
    80003630:	00f97793          	andi	a5,s2,15
    80003634:	079a                	slli	a5,a5,0x6
    80003636:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003638:	00099783          	lh	a5,0(s3)
    8000363c:	cf9d                	beqz	a5,8000367a <ialloc+0x94>
    brelse(bp);
    8000363e:	00000097          	auipc	ra,0x0
    80003642:	a60080e7          	jalr	-1440(ra) # 8000309e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003646:	0905                	addi	s2,s2,1
    80003648:	00ca2703          	lw	a4,12(s4)
    8000364c:	0009079b          	sext.w	a5,s2
    80003650:	fce7e3e3          	bltu	a5,a4,80003616 <ialloc+0x30>
  printf("ialloc: no inodes\n");
    80003654:	00005517          	auipc	a0,0x5
    80003658:	16450513          	addi	a0,a0,356 # 800087b8 <syscall_names+0x170>
    8000365c:	ffffd097          	auipc	ra,0xffffd
    80003660:	f2a080e7          	jalr	-214(ra) # 80000586 <printf>
  return 0;
    80003664:	4501                	li	a0,0
}
    80003666:	70e2                	ld	ra,56(sp)
    80003668:	7442                	ld	s0,48(sp)
    8000366a:	74a2                	ld	s1,40(sp)
    8000366c:	7902                	ld	s2,32(sp)
    8000366e:	69e2                	ld	s3,24(sp)
    80003670:	6a42                	ld	s4,16(sp)
    80003672:	6aa2                	ld	s5,8(sp)
    80003674:	6b02                	ld	s6,0(sp)
    80003676:	6121                	addi	sp,sp,64
    80003678:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000367a:	04000613          	li	a2,64
    8000367e:	4581                	li	a1,0
    80003680:	854e                	mv	a0,s3
    80003682:	ffffd097          	auipc	ra,0xffffd
    80003686:	64c080e7          	jalr	1612(ra) # 80000cce <memset>
      dip->type = type;
    8000368a:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000368e:	8526                	mv	a0,s1
    80003690:	00001097          	auipc	ra,0x1
    80003694:	c66080e7          	jalr	-922(ra) # 800042f6 <log_write>
      brelse(bp);
    80003698:	8526                	mv	a0,s1
    8000369a:	00000097          	auipc	ra,0x0
    8000369e:	a04080e7          	jalr	-1532(ra) # 8000309e <brelse>
      return iget(dev, inum);
    800036a2:	0009059b          	sext.w	a1,s2
    800036a6:	8556                	mv	a0,s5
    800036a8:	00000097          	auipc	ra,0x0
    800036ac:	da2080e7          	jalr	-606(ra) # 8000344a <iget>
    800036b0:	bf5d                	j	80003666 <ialloc+0x80>

00000000800036b2 <iupdate>:
{
    800036b2:	1101                	addi	sp,sp,-32
    800036b4:	ec06                	sd	ra,24(sp)
    800036b6:	e822                	sd	s0,16(sp)
    800036b8:	e426                	sd	s1,8(sp)
    800036ba:	e04a                	sd	s2,0(sp)
    800036bc:	1000                	addi	s0,sp,32
    800036be:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036c0:	415c                	lw	a5,4(a0)
    800036c2:	0047d79b          	srliw	a5,a5,0x4
    800036c6:	0001c597          	auipc	a1,0x1c
    800036ca:	d8a5a583          	lw	a1,-630(a1) # 8001f450 <sb+0x18>
    800036ce:	9dbd                	addw	a1,a1,a5
    800036d0:	4108                	lw	a0,0(a0)
    800036d2:	00000097          	auipc	ra,0x0
    800036d6:	89c080e7          	jalr	-1892(ra) # 80002f6e <bread>
    800036da:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036dc:	05850793          	addi	a5,a0,88
    800036e0:	40d8                	lw	a4,4(s1)
    800036e2:	8b3d                	andi	a4,a4,15
    800036e4:	071a                	slli	a4,a4,0x6
    800036e6:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800036e8:	04449703          	lh	a4,68(s1)
    800036ec:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800036f0:	04649703          	lh	a4,70(s1)
    800036f4:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800036f8:	04849703          	lh	a4,72(s1)
    800036fc:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003700:	04a49703          	lh	a4,74(s1)
    80003704:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003708:	44f8                	lw	a4,76(s1)
    8000370a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000370c:	03400613          	li	a2,52
    80003710:	05048593          	addi	a1,s1,80
    80003714:	00c78513          	addi	a0,a5,12
    80003718:	ffffd097          	auipc	ra,0xffffd
    8000371c:	612080e7          	jalr	1554(ra) # 80000d2a <memmove>
  log_write(bp);
    80003720:	854a                	mv	a0,s2
    80003722:	00001097          	auipc	ra,0x1
    80003726:	bd4080e7          	jalr	-1068(ra) # 800042f6 <log_write>
  brelse(bp);
    8000372a:	854a                	mv	a0,s2
    8000372c:	00000097          	auipc	ra,0x0
    80003730:	972080e7          	jalr	-1678(ra) # 8000309e <brelse>
}
    80003734:	60e2                	ld	ra,24(sp)
    80003736:	6442                	ld	s0,16(sp)
    80003738:	64a2                	ld	s1,8(sp)
    8000373a:	6902                	ld	s2,0(sp)
    8000373c:	6105                	addi	sp,sp,32
    8000373e:	8082                	ret

0000000080003740 <idup>:
{
    80003740:	1101                	addi	sp,sp,-32
    80003742:	ec06                	sd	ra,24(sp)
    80003744:	e822                	sd	s0,16(sp)
    80003746:	e426                	sd	s1,8(sp)
    80003748:	1000                	addi	s0,sp,32
    8000374a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000374c:	0001c517          	auipc	a0,0x1c
    80003750:	d0c50513          	addi	a0,a0,-756 # 8001f458 <itable>
    80003754:	ffffd097          	auipc	ra,0xffffd
    80003758:	47e080e7          	jalr	1150(ra) # 80000bd2 <acquire>
  ip->ref++;
    8000375c:	449c                	lw	a5,8(s1)
    8000375e:	2785                	addiw	a5,a5,1
    80003760:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003762:	0001c517          	auipc	a0,0x1c
    80003766:	cf650513          	addi	a0,a0,-778 # 8001f458 <itable>
    8000376a:	ffffd097          	auipc	ra,0xffffd
    8000376e:	51c080e7          	jalr	1308(ra) # 80000c86 <release>
}
    80003772:	8526                	mv	a0,s1
    80003774:	60e2                	ld	ra,24(sp)
    80003776:	6442                	ld	s0,16(sp)
    80003778:	64a2                	ld	s1,8(sp)
    8000377a:	6105                	addi	sp,sp,32
    8000377c:	8082                	ret

000000008000377e <ilock>:
{
    8000377e:	1101                	addi	sp,sp,-32
    80003780:	ec06                	sd	ra,24(sp)
    80003782:	e822                	sd	s0,16(sp)
    80003784:	e426                	sd	s1,8(sp)
    80003786:	e04a                	sd	s2,0(sp)
    80003788:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000378a:	c115                	beqz	a0,800037ae <ilock+0x30>
    8000378c:	84aa                	mv	s1,a0
    8000378e:	451c                	lw	a5,8(a0)
    80003790:	00f05f63          	blez	a5,800037ae <ilock+0x30>
  acquiresleep(&ip->lock);
    80003794:	0541                	addi	a0,a0,16
    80003796:	00001097          	auipc	ra,0x1
    8000379a:	c7e080e7          	jalr	-898(ra) # 80004414 <acquiresleep>
  if(ip->valid == 0){
    8000379e:	40bc                	lw	a5,64(s1)
    800037a0:	cf99                	beqz	a5,800037be <ilock+0x40>
}
    800037a2:	60e2                	ld	ra,24(sp)
    800037a4:	6442                	ld	s0,16(sp)
    800037a6:	64a2                	ld	s1,8(sp)
    800037a8:	6902                	ld	s2,0(sp)
    800037aa:	6105                	addi	sp,sp,32
    800037ac:	8082                	ret
    panic("ilock");
    800037ae:	00005517          	auipc	a0,0x5
    800037b2:	02250513          	addi	a0,a0,34 # 800087d0 <syscall_names+0x188>
    800037b6:	ffffd097          	auipc	ra,0xffffd
    800037ba:	d86080e7          	jalr	-634(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037be:	40dc                	lw	a5,4(s1)
    800037c0:	0047d79b          	srliw	a5,a5,0x4
    800037c4:	0001c597          	auipc	a1,0x1c
    800037c8:	c8c5a583          	lw	a1,-884(a1) # 8001f450 <sb+0x18>
    800037cc:	9dbd                	addw	a1,a1,a5
    800037ce:	4088                	lw	a0,0(s1)
    800037d0:	fffff097          	auipc	ra,0xfffff
    800037d4:	79e080e7          	jalr	1950(ra) # 80002f6e <bread>
    800037d8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037da:	05850593          	addi	a1,a0,88
    800037de:	40dc                	lw	a5,4(s1)
    800037e0:	8bbd                	andi	a5,a5,15
    800037e2:	079a                	slli	a5,a5,0x6
    800037e4:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800037e6:	00059783          	lh	a5,0(a1)
    800037ea:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800037ee:	00259783          	lh	a5,2(a1)
    800037f2:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800037f6:	00459783          	lh	a5,4(a1)
    800037fa:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800037fe:	00659783          	lh	a5,6(a1)
    80003802:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003806:	459c                	lw	a5,8(a1)
    80003808:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000380a:	03400613          	li	a2,52
    8000380e:	05b1                	addi	a1,a1,12
    80003810:	05048513          	addi	a0,s1,80
    80003814:	ffffd097          	auipc	ra,0xffffd
    80003818:	516080e7          	jalr	1302(ra) # 80000d2a <memmove>
    brelse(bp);
    8000381c:	854a                	mv	a0,s2
    8000381e:	00000097          	auipc	ra,0x0
    80003822:	880080e7          	jalr	-1920(ra) # 8000309e <brelse>
    ip->valid = 1;
    80003826:	4785                	li	a5,1
    80003828:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000382a:	04449783          	lh	a5,68(s1)
    8000382e:	fbb5                	bnez	a5,800037a2 <ilock+0x24>
      panic("ilock: no type");
    80003830:	00005517          	auipc	a0,0x5
    80003834:	fa850513          	addi	a0,a0,-88 # 800087d8 <syscall_names+0x190>
    80003838:	ffffd097          	auipc	ra,0xffffd
    8000383c:	d04080e7          	jalr	-764(ra) # 8000053c <panic>

0000000080003840 <iunlock>:
{
    80003840:	1101                	addi	sp,sp,-32
    80003842:	ec06                	sd	ra,24(sp)
    80003844:	e822                	sd	s0,16(sp)
    80003846:	e426                	sd	s1,8(sp)
    80003848:	e04a                	sd	s2,0(sp)
    8000384a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000384c:	c905                	beqz	a0,8000387c <iunlock+0x3c>
    8000384e:	84aa                	mv	s1,a0
    80003850:	01050913          	addi	s2,a0,16
    80003854:	854a                	mv	a0,s2
    80003856:	00001097          	auipc	ra,0x1
    8000385a:	c58080e7          	jalr	-936(ra) # 800044ae <holdingsleep>
    8000385e:	cd19                	beqz	a0,8000387c <iunlock+0x3c>
    80003860:	449c                	lw	a5,8(s1)
    80003862:	00f05d63          	blez	a5,8000387c <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003866:	854a                	mv	a0,s2
    80003868:	00001097          	auipc	ra,0x1
    8000386c:	c02080e7          	jalr	-1022(ra) # 8000446a <releasesleep>
}
    80003870:	60e2                	ld	ra,24(sp)
    80003872:	6442                	ld	s0,16(sp)
    80003874:	64a2                	ld	s1,8(sp)
    80003876:	6902                	ld	s2,0(sp)
    80003878:	6105                	addi	sp,sp,32
    8000387a:	8082                	ret
    panic("iunlock");
    8000387c:	00005517          	auipc	a0,0x5
    80003880:	f6c50513          	addi	a0,a0,-148 # 800087e8 <syscall_names+0x1a0>
    80003884:	ffffd097          	auipc	ra,0xffffd
    80003888:	cb8080e7          	jalr	-840(ra) # 8000053c <panic>

000000008000388c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000388c:	7179                	addi	sp,sp,-48
    8000388e:	f406                	sd	ra,40(sp)
    80003890:	f022                	sd	s0,32(sp)
    80003892:	ec26                	sd	s1,24(sp)
    80003894:	e84a                	sd	s2,16(sp)
    80003896:	e44e                	sd	s3,8(sp)
    80003898:	e052                	sd	s4,0(sp)
    8000389a:	1800                	addi	s0,sp,48
    8000389c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000389e:	05050493          	addi	s1,a0,80
    800038a2:	08050913          	addi	s2,a0,128
    800038a6:	a021                	j	800038ae <itrunc+0x22>
    800038a8:	0491                	addi	s1,s1,4
    800038aa:	01248d63          	beq	s1,s2,800038c4 <itrunc+0x38>
    if(ip->addrs[i]){
    800038ae:	408c                	lw	a1,0(s1)
    800038b0:	dde5                	beqz	a1,800038a8 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800038b2:	0009a503          	lw	a0,0(s3)
    800038b6:	00000097          	auipc	ra,0x0
    800038ba:	8fc080e7          	jalr	-1796(ra) # 800031b2 <bfree>
      ip->addrs[i] = 0;
    800038be:	0004a023          	sw	zero,0(s1)
    800038c2:	b7dd                	j	800038a8 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800038c4:	0809a583          	lw	a1,128(s3)
    800038c8:	e185                	bnez	a1,800038e8 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800038ca:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800038ce:	854e                	mv	a0,s3
    800038d0:	00000097          	auipc	ra,0x0
    800038d4:	de2080e7          	jalr	-542(ra) # 800036b2 <iupdate>
}
    800038d8:	70a2                	ld	ra,40(sp)
    800038da:	7402                	ld	s0,32(sp)
    800038dc:	64e2                	ld	s1,24(sp)
    800038de:	6942                	ld	s2,16(sp)
    800038e0:	69a2                	ld	s3,8(sp)
    800038e2:	6a02                	ld	s4,0(sp)
    800038e4:	6145                	addi	sp,sp,48
    800038e6:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800038e8:	0009a503          	lw	a0,0(s3)
    800038ec:	fffff097          	auipc	ra,0xfffff
    800038f0:	682080e7          	jalr	1666(ra) # 80002f6e <bread>
    800038f4:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800038f6:	05850493          	addi	s1,a0,88
    800038fa:	45850913          	addi	s2,a0,1112
    800038fe:	a021                	j	80003906 <itrunc+0x7a>
    80003900:	0491                	addi	s1,s1,4
    80003902:	01248b63          	beq	s1,s2,80003918 <itrunc+0x8c>
      if(a[j])
    80003906:	408c                	lw	a1,0(s1)
    80003908:	dde5                	beqz	a1,80003900 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    8000390a:	0009a503          	lw	a0,0(s3)
    8000390e:	00000097          	auipc	ra,0x0
    80003912:	8a4080e7          	jalr	-1884(ra) # 800031b2 <bfree>
    80003916:	b7ed                	j	80003900 <itrunc+0x74>
    brelse(bp);
    80003918:	8552                	mv	a0,s4
    8000391a:	fffff097          	auipc	ra,0xfffff
    8000391e:	784080e7          	jalr	1924(ra) # 8000309e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003922:	0809a583          	lw	a1,128(s3)
    80003926:	0009a503          	lw	a0,0(s3)
    8000392a:	00000097          	auipc	ra,0x0
    8000392e:	888080e7          	jalr	-1912(ra) # 800031b2 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003932:	0809a023          	sw	zero,128(s3)
    80003936:	bf51                	j	800038ca <itrunc+0x3e>

0000000080003938 <iput>:
{
    80003938:	1101                	addi	sp,sp,-32
    8000393a:	ec06                	sd	ra,24(sp)
    8000393c:	e822                	sd	s0,16(sp)
    8000393e:	e426                	sd	s1,8(sp)
    80003940:	e04a                	sd	s2,0(sp)
    80003942:	1000                	addi	s0,sp,32
    80003944:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003946:	0001c517          	auipc	a0,0x1c
    8000394a:	b1250513          	addi	a0,a0,-1262 # 8001f458 <itable>
    8000394e:	ffffd097          	auipc	ra,0xffffd
    80003952:	284080e7          	jalr	644(ra) # 80000bd2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003956:	4498                	lw	a4,8(s1)
    80003958:	4785                	li	a5,1
    8000395a:	02f70363          	beq	a4,a5,80003980 <iput+0x48>
  ip->ref--;
    8000395e:	449c                	lw	a5,8(s1)
    80003960:	37fd                	addiw	a5,a5,-1
    80003962:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003964:	0001c517          	auipc	a0,0x1c
    80003968:	af450513          	addi	a0,a0,-1292 # 8001f458 <itable>
    8000396c:	ffffd097          	auipc	ra,0xffffd
    80003970:	31a080e7          	jalr	794(ra) # 80000c86 <release>
}
    80003974:	60e2                	ld	ra,24(sp)
    80003976:	6442                	ld	s0,16(sp)
    80003978:	64a2                	ld	s1,8(sp)
    8000397a:	6902                	ld	s2,0(sp)
    8000397c:	6105                	addi	sp,sp,32
    8000397e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003980:	40bc                	lw	a5,64(s1)
    80003982:	dff1                	beqz	a5,8000395e <iput+0x26>
    80003984:	04a49783          	lh	a5,74(s1)
    80003988:	fbf9                	bnez	a5,8000395e <iput+0x26>
    acquiresleep(&ip->lock);
    8000398a:	01048913          	addi	s2,s1,16
    8000398e:	854a                	mv	a0,s2
    80003990:	00001097          	auipc	ra,0x1
    80003994:	a84080e7          	jalr	-1404(ra) # 80004414 <acquiresleep>
    release(&itable.lock);
    80003998:	0001c517          	auipc	a0,0x1c
    8000399c:	ac050513          	addi	a0,a0,-1344 # 8001f458 <itable>
    800039a0:	ffffd097          	auipc	ra,0xffffd
    800039a4:	2e6080e7          	jalr	742(ra) # 80000c86 <release>
    itrunc(ip);
    800039a8:	8526                	mv	a0,s1
    800039aa:	00000097          	auipc	ra,0x0
    800039ae:	ee2080e7          	jalr	-286(ra) # 8000388c <itrunc>
    ip->type = 0;
    800039b2:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800039b6:	8526                	mv	a0,s1
    800039b8:	00000097          	auipc	ra,0x0
    800039bc:	cfa080e7          	jalr	-774(ra) # 800036b2 <iupdate>
    ip->valid = 0;
    800039c0:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800039c4:	854a                	mv	a0,s2
    800039c6:	00001097          	auipc	ra,0x1
    800039ca:	aa4080e7          	jalr	-1372(ra) # 8000446a <releasesleep>
    acquire(&itable.lock);
    800039ce:	0001c517          	auipc	a0,0x1c
    800039d2:	a8a50513          	addi	a0,a0,-1398 # 8001f458 <itable>
    800039d6:	ffffd097          	auipc	ra,0xffffd
    800039da:	1fc080e7          	jalr	508(ra) # 80000bd2 <acquire>
    800039de:	b741                	j	8000395e <iput+0x26>

00000000800039e0 <iunlockput>:
{
    800039e0:	1101                	addi	sp,sp,-32
    800039e2:	ec06                	sd	ra,24(sp)
    800039e4:	e822                	sd	s0,16(sp)
    800039e6:	e426                	sd	s1,8(sp)
    800039e8:	1000                	addi	s0,sp,32
    800039ea:	84aa                	mv	s1,a0
  iunlock(ip);
    800039ec:	00000097          	auipc	ra,0x0
    800039f0:	e54080e7          	jalr	-428(ra) # 80003840 <iunlock>
  iput(ip);
    800039f4:	8526                	mv	a0,s1
    800039f6:	00000097          	auipc	ra,0x0
    800039fa:	f42080e7          	jalr	-190(ra) # 80003938 <iput>
}
    800039fe:	60e2                	ld	ra,24(sp)
    80003a00:	6442                	ld	s0,16(sp)
    80003a02:	64a2                	ld	s1,8(sp)
    80003a04:	6105                	addi	sp,sp,32
    80003a06:	8082                	ret

0000000080003a08 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003a08:	1141                	addi	sp,sp,-16
    80003a0a:	e422                	sd	s0,8(sp)
    80003a0c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003a0e:	411c                	lw	a5,0(a0)
    80003a10:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003a12:	415c                	lw	a5,4(a0)
    80003a14:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003a16:	04451783          	lh	a5,68(a0)
    80003a1a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003a1e:	04a51783          	lh	a5,74(a0)
    80003a22:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a26:	04c56783          	lwu	a5,76(a0)
    80003a2a:	e99c                	sd	a5,16(a1)
}
    80003a2c:	6422                	ld	s0,8(sp)
    80003a2e:	0141                	addi	sp,sp,16
    80003a30:	8082                	ret

0000000080003a32 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a32:	457c                	lw	a5,76(a0)
    80003a34:	0ed7e963          	bltu	a5,a3,80003b26 <readi+0xf4>
{
    80003a38:	7159                	addi	sp,sp,-112
    80003a3a:	f486                	sd	ra,104(sp)
    80003a3c:	f0a2                	sd	s0,96(sp)
    80003a3e:	eca6                	sd	s1,88(sp)
    80003a40:	e8ca                	sd	s2,80(sp)
    80003a42:	e4ce                	sd	s3,72(sp)
    80003a44:	e0d2                	sd	s4,64(sp)
    80003a46:	fc56                	sd	s5,56(sp)
    80003a48:	f85a                	sd	s6,48(sp)
    80003a4a:	f45e                	sd	s7,40(sp)
    80003a4c:	f062                	sd	s8,32(sp)
    80003a4e:	ec66                	sd	s9,24(sp)
    80003a50:	e86a                	sd	s10,16(sp)
    80003a52:	e46e                	sd	s11,8(sp)
    80003a54:	1880                	addi	s0,sp,112
    80003a56:	8b2a                	mv	s6,a0
    80003a58:	8bae                	mv	s7,a1
    80003a5a:	8a32                	mv	s4,a2
    80003a5c:	84b6                	mv	s1,a3
    80003a5e:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003a60:	9f35                	addw	a4,a4,a3
    return 0;
    80003a62:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003a64:	0ad76063          	bltu	a4,a3,80003b04 <readi+0xd2>
  if(off + n > ip->size)
    80003a68:	00e7f463          	bgeu	a5,a4,80003a70 <readi+0x3e>
    n = ip->size - off;
    80003a6c:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a70:	0a0a8963          	beqz	s5,80003b22 <readi+0xf0>
    80003a74:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a76:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003a7a:	5c7d                	li	s8,-1
    80003a7c:	a82d                	j	80003ab6 <readi+0x84>
    80003a7e:	020d1d93          	slli	s11,s10,0x20
    80003a82:	020ddd93          	srli	s11,s11,0x20
    80003a86:	05890613          	addi	a2,s2,88
    80003a8a:	86ee                	mv	a3,s11
    80003a8c:	963a                	add	a2,a2,a4
    80003a8e:	85d2                	mv	a1,s4
    80003a90:	855e                	mv	a0,s7
    80003a92:	fffff097          	auipc	ra,0xfffff
    80003a96:	9d0080e7          	jalr	-1584(ra) # 80002462 <either_copyout>
    80003a9a:	05850d63          	beq	a0,s8,80003af4 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003a9e:	854a                	mv	a0,s2
    80003aa0:	fffff097          	auipc	ra,0xfffff
    80003aa4:	5fe080e7          	jalr	1534(ra) # 8000309e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003aa8:	013d09bb          	addw	s3,s10,s3
    80003aac:	009d04bb          	addw	s1,s10,s1
    80003ab0:	9a6e                	add	s4,s4,s11
    80003ab2:	0559f763          	bgeu	s3,s5,80003b00 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003ab6:	00a4d59b          	srliw	a1,s1,0xa
    80003aba:	855a                	mv	a0,s6
    80003abc:	00000097          	auipc	ra,0x0
    80003ac0:	8a4080e7          	jalr	-1884(ra) # 80003360 <bmap>
    80003ac4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003ac8:	cd85                	beqz	a1,80003b00 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003aca:	000b2503          	lw	a0,0(s6)
    80003ace:	fffff097          	auipc	ra,0xfffff
    80003ad2:	4a0080e7          	jalr	1184(ra) # 80002f6e <bread>
    80003ad6:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ad8:	3ff4f713          	andi	a4,s1,1023
    80003adc:	40ec87bb          	subw	a5,s9,a4
    80003ae0:	413a86bb          	subw	a3,s5,s3
    80003ae4:	8d3e                	mv	s10,a5
    80003ae6:	2781                	sext.w	a5,a5
    80003ae8:	0006861b          	sext.w	a2,a3
    80003aec:	f8f679e3          	bgeu	a2,a5,80003a7e <readi+0x4c>
    80003af0:	8d36                	mv	s10,a3
    80003af2:	b771                	j	80003a7e <readi+0x4c>
      brelse(bp);
    80003af4:	854a                	mv	a0,s2
    80003af6:	fffff097          	auipc	ra,0xfffff
    80003afa:	5a8080e7          	jalr	1448(ra) # 8000309e <brelse>
      tot = -1;
    80003afe:	59fd                	li	s3,-1
  }
  return tot;
    80003b00:	0009851b          	sext.w	a0,s3
}
    80003b04:	70a6                	ld	ra,104(sp)
    80003b06:	7406                	ld	s0,96(sp)
    80003b08:	64e6                	ld	s1,88(sp)
    80003b0a:	6946                	ld	s2,80(sp)
    80003b0c:	69a6                	ld	s3,72(sp)
    80003b0e:	6a06                	ld	s4,64(sp)
    80003b10:	7ae2                	ld	s5,56(sp)
    80003b12:	7b42                	ld	s6,48(sp)
    80003b14:	7ba2                	ld	s7,40(sp)
    80003b16:	7c02                	ld	s8,32(sp)
    80003b18:	6ce2                	ld	s9,24(sp)
    80003b1a:	6d42                	ld	s10,16(sp)
    80003b1c:	6da2                	ld	s11,8(sp)
    80003b1e:	6165                	addi	sp,sp,112
    80003b20:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b22:	89d6                	mv	s3,s5
    80003b24:	bff1                	j	80003b00 <readi+0xce>
    return 0;
    80003b26:	4501                	li	a0,0
}
    80003b28:	8082                	ret

0000000080003b2a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b2a:	457c                	lw	a5,76(a0)
    80003b2c:	10d7e863          	bltu	a5,a3,80003c3c <writei+0x112>
{
    80003b30:	7159                	addi	sp,sp,-112
    80003b32:	f486                	sd	ra,104(sp)
    80003b34:	f0a2                	sd	s0,96(sp)
    80003b36:	eca6                	sd	s1,88(sp)
    80003b38:	e8ca                	sd	s2,80(sp)
    80003b3a:	e4ce                	sd	s3,72(sp)
    80003b3c:	e0d2                	sd	s4,64(sp)
    80003b3e:	fc56                	sd	s5,56(sp)
    80003b40:	f85a                	sd	s6,48(sp)
    80003b42:	f45e                	sd	s7,40(sp)
    80003b44:	f062                	sd	s8,32(sp)
    80003b46:	ec66                	sd	s9,24(sp)
    80003b48:	e86a                	sd	s10,16(sp)
    80003b4a:	e46e                	sd	s11,8(sp)
    80003b4c:	1880                	addi	s0,sp,112
    80003b4e:	8aaa                	mv	s5,a0
    80003b50:	8bae                	mv	s7,a1
    80003b52:	8a32                	mv	s4,a2
    80003b54:	8936                	mv	s2,a3
    80003b56:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b58:	00e687bb          	addw	a5,a3,a4
    80003b5c:	0ed7e263          	bltu	a5,a3,80003c40 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003b60:	00043737          	lui	a4,0x43
    80003b64:	0ef76063          	bltu	a4,a5,80003c44 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b68:	0c0b0863          	beqz	s6,80003c38 <writei+0x10e>
    80003b6c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b6e:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b72:	5c7d                	li	s8,-1
    80003b74:	a091                	j	80003bb8 <writei+0x8e>
    80003b76:	020d1d93          	slli	s11,s10,0x20
    80003b7a:	020ddd93          	srli	s11,s11,0x20
    80003b7e:	05848513          	addi	a0,s1,88
    80003b82:	86ee                	mv	a3,s11
    80003b84:	8652                	mv	a2,s4
    80003b86:	85de                	mv	a1,s7
    80003b88:	953a                	add	a0,a0,a4
    80003b8a:	fffff097          	auipc	ra,0xfffff
    80003b8e:	92e080e7          	jalr	-1746(ra) # 800024b8 <either_copyin>
    80003b92:	07850263          	beq	a0,s8,80003bf6 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003b96:	8526                	mv	a0,s1
    80003b98:	00000097          	auipc	ra,0x0
    80003b9c:	75e080e7          	jalr	1886(ra) # 800042f6 <log_write>
    brelse(bp);
    80003ba0:	8526                	mv	a0,s1
    80003ba2:	fffff097          	auipc	ra,0xfffff
    80003ba6:	4fc080e7          	jalr	1276(ra) # 8000309e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003baa:	013d09bb          	addw	s3,s10,s3
    80003bae:	012d093b          	addw	s2,s10,s2
    80003bb2:	9a6e                	add	s4,s4,s11
    80003bb4:	0569f663          	bgeu	s3,s6,80003c00 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003bb8:	00a9559b          	srliw	a1,s2,0xa
    80003bbc:	8556                	mv	a0,s5
    80003bbe:	fffff097          	auipc	ra,0xfffff
    80003bc2:	7a2080e7          	jalr	1954(ra) # 80003360 <bmap>
    80003bc6:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003bca:	c99d                	beqz	a1,80003c00 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003bcc:	000aa503          	lw	a0,0(s5)
    80003bd0:	fffff097          	auipc	ra,0xfffff
    80003bd4:	39e080e7          	jalr	926(ra) # 80002f6e <bread>
    80003bd8:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bda:	3ff97713          	andi	a4,s2,1023
    80003bde:	40ec87bb          	subw	a5,s9,a4
    80003be2:	413b06bb          	subw	a3,s6,s3
    80003be6:	8d3e                	mv	s10,a5
    80003be8:	2781                	sext.w	a5,a5
    80003bea:	0006861b          	sext.w	a2,a3
    80003bee:	f8f674e3          	bgeu	a2,a5,80003b76 <writei+0x4c>
    80003bf2:	8d36                	mv	s10,a3
    80003bf4:	b749                	j	80003b76 <writei+0x4c>
      brelse(bp);
    80003bf6:	8526                	mv	a0,s1
    80003bf8:	fffff097          	auipc	ra,0xfffff
    80003bfc:	4a6080e7          	jalr	1190(ra) # 8000309e <brelse>
  }

  if(off > ip->size)
    80003c00:	04caa783          	lw	a5,76(s5)
    80003c04:	0127f463          	bgeu	a5,s2,80003c0c <writei+0xe2>
    ip->size = off;
    80003c08:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003c0c:	8556                	mv	a0,s5
    80003c0e:	00000097          	auipc	ra,0x0
    80003c12:	aa4080e7          	jalr	-1372(ra) # 800036b2 <iupdate>

  return tot;
    80003c16:	0009851b          	sext.w	a0,s3
}
    80003c1a:	70a6                	ld	ra,104(sp)
    80003c1c:	7406                	ld	s0,96(sp)
    80003c1e:	64e6                	ld	s1,88(sp)
    80003c20:	6946                	ld	s2,80(sp)
    80003c22:	69a6                	ld	s3,72(sp)
    80003c24:	6a06                	ld	s4,64(sp)
    80003c26:	7ae2                	ld	s5,56(sp)
    80003c28:	7b42                	ld	s6,48(sp)
    80003c2a:	7ba2                	ld	s7,40(sp)
    80003c2c:	7c02                	ld	s8,32(sp)
    80003c2e:	6ce2                	ld	s9,24(sp)
    80003c30:	6d42                	ld	s10,16(sp)
    80003c32:	6da2                	ld	s11,8(sp)
    80003c34:	6165                	addi	sp,sp,112
    80003c36:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c38:	89da                	mv	s3,s6
    80003c3a:	bfc9                	j	80003c0c <writei+0xe2>
    return -1;
    80003c3c:	557d                	li	a0,-1
}
    80003c3e:	8082                	ret
    return -1;
    80003c40:	557d                	li	a0,-1
    80003c42:	bfe1                	j	80003c1a <writei+0xf0>
    return -1;
    80003c44:	557d                	li	a0,-1
    80003c46:	bfd1                	j	80003c1a <writei+0xf0>

0000000080003c48 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c48:	1141                	addi	sp,sp,-16
    80003c4a:	e406                	sd	ra,8(sp)
    80003c4c:	e022                	sd	s0,0(sp)
    80003c4e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003c50:	4639                	li	a2,14
    80003c52:	ffffd097          	auipc	ra,0xffffd
    80003c56:	14c080e7          	jalr	332(ra) # 80000d9e <strncmp>
}
    80003c5a:	60a2                	ld	ra,8(sp)
    80003c5c:	6402                	ld	s0,0(sp)
    80003c5e:	0141                	addi	sp,sp,16
    80003c60:	8082                	ret

0000000080003c62 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003c62:	7139                	addi	sp,sp,-64
    80003c64:	fc06                	sd	ra,56(sp)
    80003c66:	f822                	sd	s0,48(sp)
    80003c68:	f426                	sd	s1,40(sp)
    80003c6a:	f04a                	sd	s2,32(sp)
    80003c6c:	ec4e                	sd	s3,24(sp)
    80003c6e:	e852                	sd	s4,16(sp)
    80003c70:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c72:	04451703          	lh	a4,68(a0)
    80003c76:	4785                	li	a5,1
    80003c78:	00f71a63          	bne	a4,a5,80003c8c <dirlookup+0x2a>
    80003c7c:	892a                	mv	s2,a0
    80003c7e:	89ae                	mv	s3,a1
    80003c80:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c82:	457c                	lw	a5,76(a0)
    80003c84:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c86:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c88:	e79d                	bnez	a5,80003cb6 <dirlookup+0x54>
    80003c8a:	a8a5                	j	80003d02 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003c8c:	00005517          	auipc	a0,0x5
    80003c90:	b6450513          	addi	a0,a0,-1180 # 800087f0 <syscall_names+0x1a8>
    80003c94:	ffffd097          	auipc	ra,0xffffd
    80003c98:	8a8080e7          	jalr	-1880(ra) # 8000053c <panic>
      panic("dirlookup read");
    80003c9c:	00005517          	auipc	a0,0x5
    80003ca0:	b6c50513          	addi	a0,a0,-1172 # 80008808 <syscall_names+0x1c0>
    80003ca4:	ffffd097          	auipc	ra,0xffffd
    80003ca8:	898080e7          	jalr	-1896(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cac:	24c1                	addiw	s1,s1,16
    80003cae:	04c92783          	lw	a5,76(s2)
    80003cb2:	04f4f763          	bgeu	s1,a5,80003d00 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003cb6:	4741                	li	a4,16
    80003cb8:	86a6                	mv	a3,s1
    80003cba:	fc040613          	addi	a2,s0,-64
    80003cbe:	4581                	li	a1,0
    80003cc0:	854a                	mv	a0,s2
    80003cc2:	00000097          	auipc	ra,0x0
    80003cc6:	d70080e7          	jalr	-656(ra) # 80003a32 <readi>
    80003cca:	47c1                	li	a5,16
    80003ccc:	fcf518e3          	bne	a0,a5,80003c9c <dirlookup+0x3a>
    if(de.inum == 0)
    80003cd0:	fc045783          	lhu	a5,-64(s0)
    80003cd4:	dfe1                	beqz	a5,80003cac <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003cd6:	fc240593          	addi	a1,s0,-62
    80003cda:	854e                	mv	a0,s3
    80003cdc:	00000097          	auipc	ra,0x0
    80003ce0:	f6c080e7          	jalr	-148(ra) # 80003c48 <namecmp>
    80003ce4:	f561                	bnez	a0,80003cac <dirlookup+0x4a>
      if(poff)
    80003ce6:	000a0463          	beqz	s4,80003cee <dirlookup+0x8c>
        *poff = off;
    80003cea:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003cee:	fc045583          	lhu	a1,-64(s0)
    80003cf2:	00092503          	lw	a0,0(s2)
    80003cf6:	fffff097          	auipc	ra,0xfffff
    80003cfa:	754080e7          	jalr	1876(ra) # 8000344a <iget>
    80003cfe:	a011                	j	80003d02 <dirlookup+0xa0>
  return 0;
    80003d00:	4501                	li	a0,0
}
    80003d02:	70e2                	ld	ra,56(sp)
    80003d04:	7442                	ld	s0,48(sp)
    80003d06:	74a2                	ld	s1,40(sp)
    80003d08:	7902                	ld	s2,32(sp)
    80003d0a:	69e2                	ld	s3,24(sp)
    80003d0c:	6a42                	ld	s4,16(sp)
    80003d0e:	6121                	addi	sp,sp,64
    80003d10:	8082                	ret

0000000080003d12 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003d12:	711d                	addi	sp,sp,-96
    80003d14:	ec86                	sd	ra,88(sp)
    80003d16:	e8a2                	sd	s0,80(sp)
    80003d18:	e4a6                	sd	s1,72(sp)
    80003d1a:	e0ca                	sd	s2,64(sp)
    80003d1c:	fc4e                	sd	s3,56(sp)
    80003d1e:	f852                	sd	s4,48(sp)
    80003d20:	f456                	sd	s5,40(sp)
    80003d22:	f05a                	sd	s6,32(sp)
    80003d24:	ec5e                	sd	s7,24(sp)
    80003d26:	e862                	sd	s8,16(sp)
    80003d28:	e466                	sd	s9,8(sp)
    80003d2a:	1080                	addi	s0,sp,96
    80003d2c:	84aa                	mv	s1,a0
    80003d2e:	8b2e                	mv	s6,a1
    80003d30:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003d32:	00054703          	lbu	a4,0(a0)
    80003d36:	02f00793          	li	a5,47
    80003d3a:	02f70263          	beq	a4,a5,80003d5e <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003d3e:	ffffe097          	auipc	ra,0xffffe
    80003d42:	c68080e7          	jalr	-920(ra) # 800019a6 <myproc>
    80003d46:	15053503          	ld	a0,336(a0)
    80003d4a:	00000097          	auipc	ra,0x0
    80003d4e:	9f6080e7          	jalr	-1546(ra) # 80003740 <idup>
    80003d52:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003d54:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003d58:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003d5a:	4b85                	li	s7,1
    80003d5c:	a875                	j	80003e18 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003d5e:	4585                	li	a1,1
    80003d60:	4505                	li	a0,1
    80003d62:	fffff097          	auipc	ra,0xfffff
    80003d66:	6e8080e7          	jalr	1768(ra) # 8000344a <iget>
    80003d6a:	8a2a                	mv	s4,a0
    80003d6c:	b7e5                	j	80003d54 <namex+0x42>
      iunlockput(ip);
    80003d6e:	8552                	mv	a0,s4
    80003d70:	00000097          	auipc	ra,0x0
    80003d74:	c70080e7          	jalr	-912(ra) # 800039e0 <iunlockput>
      return 0;
    80003d78:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003d7a:	8552                	mv	a0,s4
    80003d7c:	60e6                	ld	ra,88(sp)
    80003d7e:	6446                	ld	s0,80(sp)
    80003d80:	64a6                	ld	s1,72(sp)
    80003d82:	6906                	ld	s2,64(sp)
    80003d84:	79e2                	ld	s3,56(sp)
    80003d86:	7a42                	ld	s4,48(sp)
    80003d88:	7aa2                	ld	s5,40(sp)
    80003d8a:	7b02                	ld	s6,32(sp)
    80003d8c:	6be2                	ld	s7,24(sp)
    80003d8e:	6c42                	ld	s8,16(sp)
    80003d90:	6ca2                	ld	s9,8(sp)
    80003d92:	6125                	addi	sp,sp,96
    80003d94:	8082                	ret
      iunlock(ip);
    80003d96:	8552                	mv	a0,s4
    80003d98:	00000097          	auipc	ra,0x0
    80003d9c:	aa8080e7          	jalr	-1368(ra) # 80003840 <iunlock>
      return ip;
    80003da0:	bfe9                	j	80003d7a <namex+0x68>
      iunlockput(ip);
    80003da2:	8552                	mv	a0,s4
    80003da4:	00000097          	auipc	ra,0x0
    80003da8:	c3c080e7          	jalr	-964(ra) # 800039e0 <iunlockput>
      return 0;
    80003dac:	8a4e                	mv	s4,s3
    80003dae:	b7f1                	j	80003d7a <namex+0x68>
  len = path - s;
    80003db0:	40998633          	sub	a2,s3,s1
    80003db4:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003db8:	099c5863          	bge	s8,s9,80003e48 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003dbc:	4639                	li	a2,14
    80003dbe:	85a6                	mv	a1,s1
    80003dc0:	8556                	mv	a0,s5
    80003dc2:	ffffd097          	auipc	ra,0xffffd
    80003dc6:	f68080e7          	jalr	-152(ra) # 80000d2a <memmove>
    80003dca:	84ce                	mv	s1,s3
  while(*path == '/')
    80003dcc:	0004c783          	lbu	a5,0(s1)
    80003dd0:	01279763          	bne	a5,s2,80003dde <namex+0xcc>
    path++;
    80003dd4:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003dd6:	0004c783          	lbu	a5,0(s1)
    80003dda:	ff278de3          	beq	a5,s2,80003dd4 <namex+0xc2>
    ilock(ip);
    80003dde:	8552                	mv	a0,s4
    80003de0:	00000097          	auipc	ra,0x0
    80003de4:	99e080e7          	jalr	-1634(ra) # 8000377e <ilock>
    if(ip->type != T_DIR){
    80003de8:	044a1783          	lh	a5,68(s4)
    80003dec:	f97791e3          	bne	a5,s7,80003d6e <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003df0:	000b0563          	beqz	s6,80003dfa <namex+0xe8>
    80003df4:	0004c783          	lbu	a5,0(s1)
    80003df8:	dfd9                	beqz	a5,80003d96 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003dfa:	4601                	li	a2,0
    80003dfc:	85d6                	mv	a1,s5
    80003dfe:	8552                	mv	a0,s4
    80003e00:	00000097          	auipc	ra,0x0
    80003e04:	e62080e7          	jalr	-414(ra) # 80003c62 <dirlookup>
    80003e08:	89aa                	mv	s3,a0
    80003e0a:	dd41                	beqz	a0,80003da2 <namex+0x90>
    iunlockput(ip);
    80003e0c:	8552                	mv	a0,s4
    80003e0e:	00000097          	auipc	ra,0x0
    80003e12:	bd2080e7          	jalr	-1070(ra) # 800039e0 <iunlockput>
    ip = next;
    80003e16:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003e18:	0004c783          	lbu	a5,0(s1)
    80003e1c:	01279763          	bne	a5,s2,80003e2a <namex+0x118>
    path++;
    80003e20:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e22:	0004c783          	lbu	a5,0(s1)
    80003e26:	ff278de3          	beq	a5,s2,80003e20 <namex+0x10e>
  if(*path == 0)
    80003e2a:	cb9d                	beqz	a5,80003e60 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80003e2c:	0004c783          	lbu	a5,0(s1)
    80003e30:	89a6                	mv	s3,s1
  len = path - s;
    80003e32:	4c81                	li	s9,0
    80003e34:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003e36:	01278963          	beq	a5,s2,80003e48 <namex+0x136>
    80003e3a:	dbbd                	beqz	a5,80003db0 <namex+0x9e>
    path++;
    80003e3c:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003e3e:	0009c783          	lbu	a5,0(s3)
    80003e42:	ff279ce3          	bne	a5,s2,80003e3a <namex+0x128>
    80003e46:	b7ad                	j	80003db0 <namex+0x9e>
    memmove(name, s, len);
    80003e48:	2601                	sext.w	a2,a2
    80003e4a:	85a6                	mv	a1,s1
    80003e4c:	8556                	mv	a0,s5
    80003e4e:	ffffd097          	auipc	ra,0xffffd
    80003e52:	edc080e7          	jalr	-292(ra) # 80000d2a <memmove>
    name[len] = 0;
    80003e56:	9cd6                	add	s9,s9,s5
    80003e58:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003e5c:	84ce                	mv	s1,s3
    80003e5e:	b7bd                	j	80003dcc <namex+0xba>
  if(nameiparent){
    80003e60:	f00b0de3          	beqz	s6,80003d7a <namex+0x68>
    iput(ip);
    80003e64:	8552                	mv	a0,s4
    80003e66:	00000097          	auipc	ra,0x0
    80003e6a:	ad2080e7          	jalr	-1326(ra) # 80003938 <iput>
    return 0;
    80003e6e:	4a01                	li	s4,0
    80003e70:	b729                	j	80003d7a <namex+0x68>

0000000080003e72 <dirlink>:
{
    80003e72:	7139                	addi	sp,sp,-64
    80003e74:	fc06                	sd	ra,56(sp)
    80003e76:	f822                	sd	s0,48(sp)
    80003e78:	f426                	sd	s1,40(sp)
    80003e7a:	f04a                	sd	s2,32(sp)
    80003e7c:	ec4e                	sd	s3,24(sp)
    80003e7e:	e852                	sd	s4,16(sp)
    80003e80:	0080                	addi	s0,sp,64
    80003e82:	892a                	mv	s2,a0
    80003e84:	8a2e                	mv	s4,a1
    80003e86:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e88:	4601                	li	a2,0
    80003e8a:	00000097          	auipc	ra,0x0
    80003e8e:	dd8080e7          	jalr	-552(ra) # 80003c62 <dirlookup>
    80003e92:	e93d                	bnez	a0,80003f08 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e94:	04c92483          	lw	s1,76(s2)
    80003e98:	c49d                	beqz	s1,80003ec6 <dirlink+0x54>
    80003e9a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e9c:	4741                	li	a4,16
    80003e9e:	86a6                	mv	a3,s1
    80003ea0:	fc040613          	addi	a2,s0,-64
    80003ea4:	4581                	li	a1,0
    80003ea6:	854a                	mv	a0,s2
    80003ea8:	00000097          	auipc	ra,0x0
    80003eac:	b8a080e7          	jalr	-1142(ra) # 80003a32 <readi>
    80003eb0:	47c1                	li	a5,16
    80003eb2:	06f51163          	bne	a0,a5,80003f14 <dirlink+0xa2>
    if(de.inum == 0)
    80003eb6:	fc045783          	lhu	a5,-64(s0)
    80003eba:	c791                	beqz	a5,80003ec6 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ebc:	24c1                	addiw	s1,s1,16
    80003ebe:	04c92783          	lw	a5,76(s2)
    80003ec2:	fcf4ede3          	bltu	s1,a5,80003e9c <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003ec6:	4639                	li	a2,14
    80003ec8:	85d2                	mv	a1,s4
    80003eca:	fc240513          	addi	a0,s0,-62
    80003ece:	ffffd097          	auipc	ra,0xffffd
    80003ed2:	f0c080e7          	jalr	-244(ra) # 80000dda <strncpy>
  de.inum = inum;
    80003ed6:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003eda:	4741                	li	a4,16
    80003edc:	86a6                	mv	a3,s1
    80003ede:	fc040613          	addi	a2,s0,-64
    80003ee2:	4581                	li	a1,0
    80003ee4:	854a                	mv	a0,s2
    80003ee6:	00000097          	auipc	ra,0x0
    80003eea:	c44080e7          	jalr	-956(ra) # 80003b2a <writei>
    80003eee:	1541                	addi	a0,a0,-16
    80003ef0:	00a03533          	snez	a0,a0
    80003ef4:	40a00533          	neg	a0,a0
}
    80003ef8:	70e2                	ld	ra,56(sp)
    80003efa:	7442                	ld	s0,48(sp)
    80003efc:	74a2                	ld	s1,40(sp)
    80003efe:	7902                	ld	s2,32(sp)
    80003f00:	69e2                	ld	s3,24(sp)
    80003f02:	6a42                	ld	s4,16(sp)
    80003f04:	6121                	addi	sp,sp,64
    80003f06:	8082                	ret
    iput(ip);
    80003f08:	00000097          	auipc	ra,0x0
    80003f0c:	a30080e7          	jalr	-1488(ra) # 80003938 <iput>
    return -1;
    80003f10:	557d                	li	a0,-1
    80003f12:	b7dd                	j	80003ef8 <dirlink+0x86>
      panic("dirlink read");
    80003f14:	00005517          	auipc	a0,0x5
    80003f18:	90450513          	addi	a0,a0,-1788 # 80008818 <syscall_names+0x1d0>
    80003f1c:	ffffc097          	auipc	ra,0xffffc
    80003f20:	620080e7          	jalr	1568(ra) # 8000053c <panic>

0000000080003f24 <namei>:

struct inode*
namei(char *path)
{
    80003f24:	1101                	addi	sp,sp,-32
    80003f26:	ec06                	sd	ra,24(sp)
    80003f28:	e822                	sd	s0,16(sp)
    80003f2a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003f2c:	fe040613          	addi	a2,s0,-32
    80003f30:	4581                	li	a1,0
    80003f32:	00000097          	auipc	ra,0x0
    80003f36:	de0080e7          	jalr	-544(ra) # 80003d12 <namex>
}
    80003f3a:	60e2                	ld	ra,24(sp)
    80003f3c:	6442                	ld	s0,16(sp)
    80003f3e:	6105                	addi	sp,sp,32
    80003f40:	8082                	ret

0000000080003f42 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003f42:	1141                	addi	sp,sp,-16
    80003f44:	e406                	sd	ra,8(sp)
    80003f46:	e022                	sd	s0,0(sp)
    80003f48:	0800                	addi	s0,sp,16
    80003f4a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003f4c:	4585                	li	a1,1
    80003f4e:	00000097          	auipc	ra,0x0
    80003f52:	dc4080e7          	jalr	-572(ra) # 80003d12 <namex>
}
    80003f56:	60a2                	ld	ra,8(sp)
    80003f58:	6402                	ld	s0,0(sp)
    80003f5a:	0141                	addi	sp,sp,16
    80003f5c:	8082                	ret

0000000080003f5e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003f5e:	1101                	addi	sp,sp,-32
    80003f60:	ec06                	sd	ra,24(sp)
    80003f62:	e822                	sd	s0,16(sp)
    80003f64:	e426                	sd	s1,8(sp)
    80003f66:	e04a                	sd	s2,0(sp)
    80003f68:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003f6a:	0001d917          	auipc	s2,0x1d
    80003f6e:	f9690913          	addi	s2,s2,-106 # 80020f00 <log>
    80003f72:	01892583          	lw	a1,24(s2)
    80003f76:	02892503          	lw	a0,40(s2)
    80003f7a:	fffff097          	auipc	ra,0xfffff
    80003f7e:	ff4080e7          	jalr	-12(ra) # 80002f6e <bread>
    80003f82:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003f84:	02c92603          	lw	a2,44(s2)
    80003f88:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003f8a:	00c05f63          	blez	a2,80003fa8 <write_head+0x4a>
    80003f8e:	0001d717          	auipc	a4,0x1d
    80003f92:	fa270713          	addi	a4,a4,-94 # 80020f30 <log+0x30>
    80003f96:	87aa                	mv	a5,a0
    80003f98:	060a                	slli	a2,a2,0x2
    80003f9a:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003f9c:	4314                	lw	a3,0(a4)
    80003f9e:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003fa0:	0711                	addi	a4,a4,4
    80003fa2:	0791                	addi	a5,a5,4
    80003fa4:	fec79ce3          	bne	a5,a2,80003f9c <write_head+0x3e>
  }
  bwrite(buf);
    80003fa8:	8526                	mv	a0,s1
    80003faa:	fffff097          	auipc	ra,0xfffff
    80003fae:	0b6080e7          	jalr	182(ra) # 80003060 <bwrite>
  brelse(buf);
    80003fb2:	8526                	mv	a0,s1
    80003fb4:	fffff097          	auipc	ra,0xfffff
    80003fb8:	0ea080e7          	jalr	234(ra) # 8000309e <brelse>
}
    80003fbc:	60e2                	ld	ra,24(sp)
    80003fbe:	6442                	ld	s0,16(sp)
    80003fc0:	64a2                	ld	s1,8(sp)
    80003fc2:	6902                	ld	s2,0(sp)
    80003fc4:	6105                	addi	sp,sp,32
    80003fc6:	8082                	ret

0000000080003fc8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fc8:	0001d797          	auipc	a5,0x1d
    80003fcc:	f647a783          	lw	a5,-156(a5) # 80020f2c <log+0x2c>
    80003fd0:	0af05d63          	blez	a5,8000408a <install_trans+0xc2>
{
    80003fd4:	7139                	addi	sp,sp,-64
    80003fd6:	fc06                	sd	ra,56(sp)
    80003fd8:	f822                	sd	s0,48(sp)
    80003fda:	f426                	sd	s1,40(sp)
    80003fdc:	f04a                	sd	s2,32(sp)
    80003fde:	ec4e                	sd	s3,24(sp)
    80003fe0:	e852                	sd	s4,16(sp)
    80003fe2:	e456                	sd	s5,8(sp)
    80003fe4:	e05a                	sd	s6,0(sp)
    80003fe6:	0080                	addi	s0,sp,64
    80003fe8:	8b2a                	mv	s6,a0
    80003fea:	0001da97          	auipc	s5,0x1d
    80003fee:	f46a8a93          	addi	s5,s5,-186 # 80020f30 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ff2:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003ff4:	0001d997          	auipc	s3,0x1d
    80003ff8:	f0c98993          	addi	s3,s3,-244 # 80020f00 <log>
    80003ffc:	a00d                	j	8000401e <install_trans+0x56>
    brelse(lbuf);
    80003ffe:	854a                	mv	a0,s2
    80004000:	fffff097          	auipc	ra,0xfffff
    80004004:	09e080e7          	jalr	158(ra) # 8000309e <brelse>
    brelse(dbuf);
    80004008:	8526                	mv	a0,s1
    8000400a:	fffff097          	auipc	ra,0xfffff
    8000400e:	094080e7          	jalr	148(ra) # 8000309e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004012:	2a05                	addiw	s4,s4,1
    80004014:	0a91                	addi	s5,s5,4
    80004016:	02c9a783          	lw	a5,44(s3)
    8000401a:	04fa5e63          	bge	s4,a5,80004076 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000401e:	0189a583          	lw	a1,24(s3)
    80004022:	014585bb          	addw	a1,a1,s4
    80004026:	2585                	addiw	a1,a1,1
    80004028:	0289a503          	lw	a0,40(s3)
    8000402c:	fffff097          	auipc	ra,0xfffff
    80004030:	f42080e7          	jalr	-190(ra) # 80002f6e <bread>
    80004034:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004036:	000aa583          	lw	a1,0(s5)
    8000403a:	0289a503          	lw	a0,40(s3)
    8000403e:	fffff097          	auipc	ra,0xfffff
    80004042:	f30080e7          	jalr	-208(ra) # 80002f6e <bread>
    80004046:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004048:	40000613          	li	a2,1024
    8000404c:	05890593          	addi	a1,s2,88
    80004050:	05850513          	addi	a0,a0,88
    80004054:	ffffd097          	auipc	ra,0xffffd
    80004058:	cd6080e7          	jalr	-810(ra) # 80000d2a <memmove>
    bwrite(dbuf);  // write dst to disk
    8000405c:	8526                	mv	a0,s1
    8000405e:	fffff097          	auipc	ra,0xfffff
    80004062:	002080e7          	jalr	2(ra) # 80003060 <bwrite>
    if(recovering == 0)
    80004066:	f80b1ce3          	bnez	s6,80003ffe <install_trans+0x36>
      bunpin(dbuf);
    8000406a:	8526                	mv	a0,s1
    8000406c:	fffff097          	auipc	ra,0xfffff
    80004070:	10a080e7          	jalr	266(ra) # 80003176 <bunpin>
    80004074:	b769                	j	80003ffe <install_trans+0x36>
}
    80004076:	70e2                	ld	ra,56(sp)
    80004078:	7442                	ld	s0,48(sp)
    8000407a:	74a2                	ld	s1,40(sp)
    8000407c:	7902                	ld	s2,32(sp)
    8000407e:	69e2                	ld	s3,24(sp)
    80004080:	6a42                	ld	s4,16(sp)
    80004082:	6aa2                	ld	s5,8(sp)
    80004084:	6b02                	ld	s6,0(sp)
    80004086:	6121                	addi	sp,sp,64
    80004088:	8082                	ret
    8000408a:	8082                	ret

000000008000408c <initlog>:
{
    8000408c:	7179                	addi	sp,sp,-48
    8000408e:	f406                	sd	ra,40(sp)
    80004090:	f022                	sd	s0,32(sp)
    80004092:	ec26                	sd	s1,24(sp)
    80004094:	e84a                	sd	s2,16(sp)
    80004096:	e44e                	sd	s3,8(sp)
    80004098:	1800                	addi	s0,sp,48
    8000409a:	892a                	mv	s2,a0
    8000409c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000409e:	0001d497          	auipc	s1,0x1d
    800040a2:	e6248493          	addi	s1,s1,-414 # 80020f00 <log>
    800040a6:	00004597          	auipc	a1,0x4
    800040aa:	78258593          	addi	a1,a1,1922 # 80008828 <syscall_names+0x1e0>
    800040ae:	8526                	mv	a0,s1
    800040b0:	ffffd097          	auipc	ra,0xffffd
    800040b4:	a92080e7          	jalr	-1390(ra) # 80000b42 <initlock>
  log.start = sb->logstart;
    800040b8:	0149a583          	lw	a1,20(s3)
    800040bc:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800040be:	0109a783          	lw	a5,16(s3)
    800040c2:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800040c4:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800040c8:	854a                	mv	a0,s2
    800040ca:	fffff097          	auipc	ra,0xfffff
    800040ce:	ea4080e7          	jalr	-348(ra) # 80002f6e <bread>
  log.lh.n = lh->n;
    800040d2:	4d30                	lw	a2,88(a0)
    800040d4:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800040d6:	00c05f63          	blez	a2,800040f4 <initlog+0x68>
    800040da:	87aa                	mv	a5,a0
    800040dc:	0001d717          	auipc	a4,0x1d
    800040e0:	e5470713          	addi	a4,a4,-428 # 80020f30 <log+0x30>
    800040e4:	060a                	slli	a2,a2,0x2
    800040e6:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800040e8:	4ff4                	lw	a3,92(a5)
    800040ea:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800040ec:	0791                	addi	a5,a5,4
    800040ee:	0711                	addi	a4,a4,4
    800040f0:	fec79ce3          	bne	a5,a2,800040e8 <initlog+0x5c>
  brelse(buf);
    800040f4:	fffff097          	auipc	ra,0xfffff
    800040f8:	faa080e7          	jalr	-86(ra) # 8000309e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800040fc:	4505                	li	a0,1
    800040fe:	00000097          	auipc	ra,0x0
    80004102:	eca080e7          	jalr	-310(ra) # 80003fc8 <install_trans>
  log.lh.n = 0;
    80004106:	0001d797          	auipc	a5,0x1d
    8000410a:	e207a323          	sw	zero,-474(a5) # 80020f2c <log+0x2c>
  write_head(); // clear the log
    8000410e:	00000097          	auipc	ra,0x0
    80004112:	e50080e7          	jalr	-432(ra) # 80003f5e <write_head>
}
    80004116:	70a2                	ld	ra,40(sp)
    80004118:	7402                	ld	s0,32(sp)
    8000411a:	64e2                	ld	s1,24(sp)
    8000411c:	6942                	ld	s2,16(sp)
    8000411e:	69a2                	ld	s3,8(sp)
    80004120:	6145                	addi	sp,sp,48
    80004122:	8082                	ret

0000000080004124 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004124:	1101                	addi	sp,sp,-32
    80004126:	ec06                	sd	ra,24(sp)
    80004128:	e822                	sd	s0,16(sp)
    8000412a:	e426                	sd	s1,8(sp)
    8000412c:	e04a                	sd	s2,0(sp)
    8000412e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004130:	0001d517          	auipc	a0,0x1d
    80004134:	dd050513          	addi	a0,a0,-560 # 80020f00 <log>
    80004138:	ffffd097          	auipc	ra,0xffffd
    8000413c:	a9a080e7          	jalr	-1382(ra) # 80000bd2 <acquire>
  while(1){
    if(log.committing){
    80004140:	0001d497          	auipc	s1,0x1d
    80004144:	dc048493          	addi	s1,s1,-576 # 80020f00 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004148:	4979                	li	s2,30
    8000414a:	a039                	j	80004158 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000414c:	85a6                	mv	a1,s1
    8000414e:	8526                	mv	a0,s1
    80004150:	ffffe097          	auipc	ra,0xffffe
    80004154:	f0a080e7          	jalr	-246(ra) # 8000205a <sleep>
    if(log.committing){
    80004158:	50dc                	lw	a5,36(s1)
    8000415a:	fbed                	bnez	a5,8000414c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000415c:	5098                	lw	a4,32(s1)
    8000415e:	2705                	addiw	a4,a4,1
    80004160:	0027179b          	slliw	a5,a4,0x2
    80004164:	9fb9                	addw	a5,a5,a4
    80004166:	0017979b          	slliw	a5,a5,0x1
    8000416a:	54d4                	lw	a3,44(s1)
    8000416c:	9fb5                	addw	a5,a5,a3
    8000416e:	00f95963          	bge	s2,a5,80004180 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004172:	85a6                	mv	a1,s1
    80004174:	8526                	mv	a0,s1
    80004176:	ffffe097          	auipc	ra,0xffffe
    8000417a:	ee4080e7          	jalr	-284(ra) # 8000205a <sleep>
    8000417e:	bfe9                	j	80004158 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004180:	0001d517          	auipc	a0,0x1d
    80004184:	d8050513          	addi	a0,a0,-640 # 80020f00 <log>
    80004188:	d118                	sw	a4,32(a0)
      release(&log.lock);
    8000418a:	ffffd097          	auipc	ra,0xffffd
    8000418e:	afc080e7          	jalr	-1284(ra) # 80000c86 <release>
      break;
    }
  }
}
    80004192:	60e2                	ld	ra,24(sp)
    80004194:	6442                	ld	s0,16(sp)
    80004196:	64a2                	ld	s1,8(sp)
    80004198:	6902                	ld	s2,0(sp)
    8000419a:	6105                	addi	sp,sp,32
    8000419c:	8082                	ret

000000008000419e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000419e:	7139                	addi	sp,sp,-64
    800041a0:	fc06                	sd	ra,56(sp)
    800041a2:	f822                	sd	s0,48(sp)
    800041a4:	f426                	sd	s1,40(sp)
    800041a6:	f04a                	sd	s2,32(sp)
    800041a8:	ec4e                	sd	s3,24(sp)
    800041aa:	e852                	sd	s4,16(sp)
    800041ac:	e456                	sd	s5,8(sp)
    800041ae:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800041b0:	0001d497          	auipc	s1,0x1d
    800041b4:	d5048493          	addi	s1,s1,-688 # 80020f00 <log>
    800041b8:	8526                	mv	a0,s1
    800041ba:	ffffd097          	auipc	ra,0xffffd
    800041be:	a18080e7          	jalr	-1512(ra) # 80000bd2 <acquire>
  log.outstanding -= 1;
    800041c2:	509c                	lw	a5,32(s1)
    800041c4:	37fd                	addiw	a5,a5,-1
    800041c6:	0007891b          	sext.w	s2,a5
    800041ca:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800041cc:	50dc                	lw	a5,36(s1)
    800041ce:	e7b9                	bnez	a5,8000421c <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800041d0:	04091e63          	bnez	s2,8000422c <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800041d4:	0001d497          	auipc	s1,0x1d
    800041d8:	d2c48493          	addi	s1,s1,-724 # 80020f00 <log>
    800041dc:	4785                	li	a5,1
    800041de:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800041e0:	8526                	mv	a0,s1
    800041e2:	ffffd097          	auipc	ra,0xffffd
    800041e6:	aa4080e7          	jalr	-1372(ra) # 80000c86 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800041ea:	54dc                	lw	a5,44(s1)
    800041ec:	06f04763          	bgtz	a5,8000425a <end_op+0xbc>
    acquire(&log.lock);
    800041f0:	0001d497          	auipc	s1,0x1d
    800041f4:	d1048493          	addi	s1,s1,-752 # 80020f00 <log>
    800041f8:	8526                	mv	a0,s1
    800041fa:	ffffd097          	auipc	ra,0xffffd
    800041fe:	9d8080e7          	jalr	-1576(ra) # 80000bd2 <acquire>
    log.committing = 0;
    80004202:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004206:	8526                	mv	a0,s1
    80004208:	ffffe097          	auipc	ra,0xffffe
    8000420c:	eb6080e7          	jalr	-330(ra) # 800020be <wakeup>
    release(&log.lock);
    80004210:	8526                	mv	a0,s1
    80004212:	ffffd097          	auipc	ra,0xffffd
    80004216:	a74080e7          	jalr	-1420(ra) # 80000c86 <release>
}
    8000421a:	a03d                	j	80004248 <end_op+0xaa>
    panic("log.committing");
    8000421c:	00004517          	auipc	a0,0x4
    80004220:	61450513          	addi	a0,a0,1556 # 80008830 <syscall_names+0x1e8>
    80004224:	ffffc097          	auipc	ra,0xffffc
    80004228:	318080e7          	jalr	792(ra) # 8000053c <panic>
    wakeup(&log);
    8000422c:	0001d497          	auipc	s1,0x1d
    80004230:	cd448493          	addi	s1,s1,-812 # 80020f00 <log>
    80004234:	8526                	mv	a0,s1
    80004236:	ffffe097          	auipc	ra,0xffffe
    8000423a:	e88080e7          	jalr	-376(ra) # 800020be <wakeup>
  release(&log.lock);
    8000423e:	8526                	mv	a0,s1
    80004240:	ffffd097          	auipc	ra,0xffffd
    80004244:	a46080e7          	jalr	-1466(ra) # 80000c86 <release>
}
    80004248:	70e2                	ld	ra,56(sp)
    8000424a:	7442                	ld	s0,48(sp)
    8000424c:	74a2                	ld	s1,40(sp)
    8000424e:	7902                	ld	s2,32(sp)
    80004250:	69e2                	ld	s3,24(sp)
    80004252:	6a42                	ld	s4,16(sp)
    80004254:	6aa2                	ld	s5,8(sp)
    80004256:	6121                	addi	sp,sp,64
    80004258:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000425a:	0001da97          	auipc	s5,0x1d
    8000425e:	cd6a8a93          	addi	s5,s5,-810 # 80020f30 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004262:	0001da17          	auipc	s4,0x1d
    80004266:	c9ea0a13          	addi	s4,s4,-866 # 80020f00 <log>
    8000426a:	018a2583          	lw	a1,24(s4)
    8000426e:	012585bb          	addw	a1,a1,s2
    80004272:	2585                	addiw	a1,a1,1
    80004274:	028a2503          	lw	a0,40(s4)
    80004278:	fffff097          	auipc	ra,0xfffff
    8000427c:	cf6080e7          	jalr	-778(ra) # 80002f6e <bread>
    80004280:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004282:	000aa583          	lw	a1,0(s5)
    80004286:	028a2503          	lw	a0,40(s4)
    8000428a:	fffff097          	auipc	ra,0xfffff
    8000428e:	ce4080e7          	jalr	-796(ra) # 80002f6e <bread>
    80004292:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004294:	40000613          	li	a2,1024
    80004298:	05850593          	addi	a1,a0,88
    8000429c:	05848513          	addi	a0,s1,88
    800042a0:	ffffd097          	auipc	ra,0xffffd
    800042a4:	a8a080e7          	jalr	-1398(ra) # 80000d2a <memmove>
    bwrite(to);  // write the log
    800042a8:	8526                	mv	a0,s1
    800042aa:	fffff097          	auipc	ra,0xfffff
    800042ae:	db6080e7          	jalr	-586(ra) # 80003060 <bwrite>
    brelse(from);
    800042b2:	854e                	mv	a0,s3
    800042b4:	fffff097          	auipc	ra,0xfffff
    800042b8:	dea080e7          	jalr	-534(ra) # 8000309e <brelse>
    brelse(to);
    800042bc:	8526                	mv	a0,s1
    800042be:	fffff097          	auipc	ra,0xfffff
    800042c2:	de0080e7          	jalr	-544(ra) # 8000309e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042c6:	2905                	addiw	s2,s2,1
    800042c8:	0a91                	addi	s5,s5,4
    800042ca:	02ca2783          	lw	a5,44(s4)
    800042ce:	f8f94ee3          	blt	s2,a5,8000426a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800042d2:	00000097          	auipc	ra,0x0
    800042d6:	c8c080e7          	jalr	-884(ra) # 80003f5e <write_head>
    install_trans(0); // Now install writes to home locations
    800042da:	4501                	li	a0,0
    800042dc:	00000097          	auipc	ra,0x0
    800042e0:	cec080e7          	jalr	-788(ra) # 80003fc8 <install_trans>
    log.lh.n = 0;
    800042e4:	0001d797          	auipc	a5,0x1d
    800042e8:	c407a423          	sw	zero,-952(a5) # 80020f2c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800042ec:	00000097          	auipc	ra,0x0
    800042f0:	c72080e7          	jalr	-910(ra) # 80003f5e <write_head>
    800042f4:	bdf5                	j	800041f0 <end_op+0x52>

00000000800042f6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800042f6:	1101                	addi	sp,sp,-32
    800042f8:	ec06                	sd	ra,24(sp)
    800042fa:	e822                	sd	s0,16(sp)
    800042fc:	e426                	sd	s1,8(sp)
    800042fe:	e04a                	sd	s2,0(sp)
    80004300:	1000                	addi	s0,sp,32
    80004302:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004304:	0001d917          	auipc	s2,0x1d
    80004308:	bfc90913          	addi	s2,s2,-1028 # 80020f00 <log>
    8000430c:	854a                	mv	a0,s2
    8000430e:	ffffd097          	auipc	ra,0xffffd
    80004312:	8c4080e7          	jalr	-1852(ra) # 80000bd2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004316:	02c92603          	lw	a2,44(s2)
    8000431a:	47f5                	li	a5,29
    8000431c:	06c7c563          	blt	a5,a2,80004386 <log_write+0x90>
    80004320:	0001d797          	auipc	a5,0x1d
    80004324:	bfc7a783          	lw	a5,-1028(a5) # 80020f1c <log+0x1c>
    80004328:	37fd                	addiw	a5,a5,-1
    8000432a:	04f65e63          	bge	a2,a5,80004386 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000432e:	0001d797          	auipc	a5,0x1d
    80004332:	bf27a783          	lw	a5,-1038(a5) # 80020f20 <log+0x20>
    80004336:	06f05063          	blez	a5,80004396 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000433a:	4781                	li	a5,0
    8000433c:	06c05563          	blez	a2,800043a6 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004340:	44cc                	lw	a1,12(s1)
    80004342:	0001d717          	auipc	a4,0x1d
    80004346:	bee70713          	addi	a4,a4,-1042 # 80020f30 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000434a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000434c:	4314                	lw	a3,0(a4)
    8000434e:	04b68c63          	beq	a3,a1,800043a6 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004352:	2785                	addiw	a5,a5,1
    80004354:	0711                	addi	a4,a4,4
    80004356:	fef61be3          	bne	a2,a5,8000434c <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000435a:	0621                	addi	a2,a2,8
    8000435c:	060a                	slli	a2,a2,0x2
    8000435e:	0001d797          	auipc	a5,0x1d
    80004362:	ba278793          	addi	a5,a5,-1118 # 80020f00 <log>
    80004366:	97b2                	add	a5,a5,a2
    80004368:	44d8                	lw	a4,12(s1)
    8000436a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000436c:	8526                	mv	a0,s1
    8000436e:	fffff097          	auipc	ra,0xfffff
    80004372:	dcc080e7          	jalr	-564(ra) # 8000313a <bpin>
    log.lh.n++;
    80004376:	0001d717          	auipc	a4,0x1d
    8000437a:	b8a70713          	addi	a4,a4,-1142 # 80020f00 <log>
    8000437e:	575c                	lw	a5,44(a4)
    80004380:	2785                	addiw	a5,a5,1
    80004382:	d75c                	sw	a5,44(a4)
    80004384:	a82d                	j	800043be <log_write+0xc8>
    panic("too big a transaction");
    80004386:	00004517          	auipc	a0,0x4
    8000438a:	4ba50513          	addi	a0,a0,1210 # 80008840 <syscall_names+0x1f8>
    8000438e:	ffffc097          	auipc	ra,0xffffc
    80004392:	1ae080e7          	jalr	430(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    80004396:	00004517          	auipc	a0,0x4
    8000439a:	4c250513          	addi	a0,a0,1218 # 80008858 <syscall_names+0x210>
    8000439e:	ffffc097          	auipc	ra,0xffffc
    800043a2:	19e080e7          	jalr	414(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    800043a6:	00878693          	addi	a3,a5,8
    800043aa:	068a                	slli	a3,a3,0x2
    800043ac:	0001d717          	auipc	a4,0x1d
    800043b0:	b5470713          	addi	a4,a4,-1196 # 80020f00 <log>
    800043b4:	9736                	add	a4,a4,a3
    800043b6:	44d4                	lw	a3,12(s1)
    800043b8:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800043ba:	faf609e3          	beq	a2,a5,8000436c <log_write+0x76>
  }
  release(&log.lock);
    800043be:	0001d517          	auipc	a0,0x1d
    800043c2:	b4250513          	addi	a0,a0,-1214 # 80020f00 <log>
    800043c6:	ffffd097          	auipc	ra,0xffffd
    800043ca:	8c0080e7          	jalr	-1856(ra) # 80000c86 <release>
}
    800043ce:	60e2                	ld	ra,24(sp)
    800043d0:	6442                	ld	s0,16(sp)
    800043d2:	64a2                	ld	s1,8(sp)
    800043d4:	6902                	ld	s2,0(sp)
    800043d6:	6105                	addi	sp,sp,32
    800043d8:	8082                	ret

00000000800043da <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800043da:	1101                	addi	sp,sp,-32
    800043dc:	ec06                	sd	ra,24(sp)
    800043de:	e822                	sd	s0,16(sp)
    800043e0:	e426                	sd	s1,8(sp)
    800043e2:	e04a                	sd	s2,0(sp)
    800043e4:	1000                	addi	s0,sp,32
    800043e6:	84aa                	mv	s1,a0
    800043e8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800043ea:	00004597          	auipc	a1,0x4
    800043ee:	48e58593          	addi	a1,a1,1166 # 80008878 <syscall_names+0x230>
    800043f2:	0521                	addi	a0,a0,8
    800043f4:	ffffc097          	auipc	ra,0xffffc
    800043f8:	74e080e7          	jalr	1870(ra) # 80000b42 <initlock>
  lk->name = name;
    800043fc:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004400:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004404:	0204a423          	sw	zero,40(s1)
}
    80004408:	60e2                	ld	ra,24(sp)
    8000440a:	6442                	ld	s0,16(sp)
    8000440c:	64a2                	ld	s1,8(sp)
    8000440e:	6902                	ld	s2,0(sp)
    80004410:	6105                	addi	sp,sp,32
    80004412:	8082                	ret

0000000080004414 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004414:	1101                	addi	sp,sp,-32
    80004416:	ec06                	sd	ra,24(sp)
    80004418:	e822                	sd	s0,16(sp)
    8000441a:	e426                	sd	s1,8(sp)
    8000441c:	e04a                	sd	s2,0(sp)
    8000441e:	1000                	addi	s0,sp,32
    80004420:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004422:	00850913          	addi	s2,a0,8
    80004426:	854a                	mv	a0,s2
    80004428:	ffffc097          	auipc	ra,0xffffc
    8000442c:	7aa080e7          	jalr	1962(ra) # 80000bd2 <acquire>
  while (lk->locked) {
    80004430:	409c                	lw	a5,0(s1)
    80004432:	cb89                	beqz	a5,80004444 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004434:	85ca                	mv	a1,s2
    80004436:	8526                	mv	a0,s1
    80004438:	ffffe097          	auipc	ra,0xffffe
    8000443c:	c22080e7          	jalr	-990(ra) # 8000205a <sleep>
  while (lk->locked) {
    80004440:	409c                	lw	a5,0(s1)
    80004442:	fbed                	bnez	a5,80004434 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004444:	4785                	li	a5,1
    80004446:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004448:	ffffd097          	auipc	ra,0xffffd
    8000444c:	55e080e7          	jalr	1374(ra) # 800019a6 <myproc>
    80004450:	591c                	lw	a5,48(a0)
    80004452:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004454:	854a                	mv	a0,s2
    80004456:	ffffd097          	auipc	ra,0xffffd
    8000445a:	830080e7          	jalr	-2000(ra) # 80000c86 <release>
}
    8000445e:	60e2                	ld	ra,24(sp)
    80004460:	6442                	ld	s0,16(sp)
    80004462:	64a2                	ld	s1,8(sp)
    80004464:	6902                	ld	s2,0(sp)
    80004466:	6105                	addi	sp,sp,32
    80004468:	8082                	ret

000000008000446a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000446a:	1101                	addi	sp,sp,-32
    8000446c:	ec06                	sd	ra,24(sp)
    8000446e:	e822                	sd	s0,16(sp)
    80004470:	e426                	sd	s1,8(sp)
    80004472:	e04a                	sd	s2,0(sp)
    80004474:	1000                	addi	s0,sp,32
    80004476:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004478:	00850913          	addi	s2,a0,8
    8000447c:	854a                	mv	a0,s2
    8000447e:	ffffc097          	auipc	ra,0xffffc
    80004482:	754080e7          	jalr	1876(ra) # 80000bd2 <acquire>
  lk->locked = 0;
    80004486:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000448a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000448e:	8526                	mv	a0,s1
    80004490:	ffffe097          	auipc	ra,0xffffe
    80004494:	c2e080e7          	jalr	-978(ra) # 800020be <wakeup>
  release(&lk->lk);
    80004498:	854a                	mv	a0,s2
    8000449a:	ffffc097          	auipc	ra,0xffffc
    8000449e:	7ec080e7          	jalr	2028(ra) # 80000c86 <release>
}
    800044a2:	60e2                	ld	ra,24(sp)
    800044a4:	6442                	ld	s0,16(sp)
    800044a6:	64a2                	ld	s1,8(sp)
    800044a8:	6902                	ld	s2,0(sp)
    800044aa:	6105                	addi	sp,sp,32
    800044ac:	8082                	ret

00000000800044ae <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800044ae:	7179                	addi	sp,sp,-48
    800044b0:	f406                	sd	ra,40(sp)
    800044b2:	f022                	sd	s0,32(sp)
    800044b4:	ec26                	sd	s1,24(sp)
    800044b6:	e84a                	sd	s2,16(sp)
    800044b8:	e44e                	sd	s3,8(sp)
    800044ba:	1800                	addi	s0,sp,48
    800044bc:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800044be:	00850913          	addi	s2,a0,8
    800044c2:	854a                	mv	a0,s2
    800044c4:	ffffc097          	auipc	ra,0xffffc
    800044c8:	70e080e7          	jalr	1806(ra) # 80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800044cc:	409c                	lw	a5,0(s1)
    800044ce:	ef99                	bnez	a5,800044ec <holdingsleep+0x3e>
    800044d0:	4481                	li	s1,0
  release(&lk->lk);
    800044d2:	854a                	mv	a0,s2
    800044d4:	ffffc097          	auipc	ra,0xffffc
    800044d8:	7b2080e7          	jalr	1970(ra) # 80000c86 <release>
  return r;
}
    800044dc:	8526                	mv	a0,s1
    800044de:	70a2                	ld	ra,40(sp)
    800044e0:	7402                	ld	s0,32(sp)
    800044e2:	64e2                	ld	s1,24(sp)
    800044e4:	6942                	ld	s2,16(sp)
    800044e6:	69a2                	ld	s3,8(sp)
    800044e8:	6145                	addi	sp,sp,48
    800044ea:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800044ec:	0284a983          	lw	s3,40(s1)
    800044f0:	ffffd097          	auipc	ra,0xffffd
    800044f4:	4b6080e7          	jalr	1206(ra) # 800019a6 <myproc>
    800044f8:	5904                	lw	s1,48(a0)
    800044fa:	413484b3          	sub	s1,s1,s3
    800044fe:	0014b493          	seqz	s1,s1
    80004502:	bfc1                	j	800044d2 <holdingsleep+0x24>

0000000080004504 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004504:	1141                	addi	sp,sp,-16
    80004506:	e406                	sd	ra,8(sp)
    80004508:	e022                	sd	s0,0(sp)
    8000450a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000450c:	00004597          	auipc	a1,0x4
    80004510:	37c58593          	addi	a1,a1,892 # 80008888 <syscall_names+0x240>
    80004514:	0001d517          	auipc	a0,0x1d
    80004518:	b3450513          	addi	a0,a0,-1228 # 80021048 <ftable>
    8000451c:	ffffc097          	auipc	ra,0xffffc
    80004520:	626080e7          	jalr	1574(ra) # 80000b42 <initlock>
}
    80004524:	60a2                	ld	ra,8(sp)
    80004526:	6402                	ld	s0,0(sp)
    80004528:	0141                	addi	sp,sp,16
    8000452a:	8082                	ret

000000008000452c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000452c:	1101                	addi	sp,sp,-32
    8000452e:	ec06                	sd	ra,24(sp)
    80004530:	e822                	sd	s0,16(sp)
    80004532:	e426                	sd	s1,8(sp)
    80004534:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004536:	0001d517          	auipc	a0,0x1d
    8000453a:	b1250513          	addi	a0,a0,-1262 # 80021048 <ftable>
    8000453e:	ffffc097          	auipc	ra,0xffffc
    80004542:	694080e7          	jalr	1684(ra) # 80000bd2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004546:	0001d497          	auipc	s1,0x1d
    8000454a:	b1a48493          	addi	s1,s1,-1254 # 80021060 <ftable+0x18>
    8000454e:	0001e717          	auipc	a4,0x1e
    80004552:	ab270713          	addi	a4,a4,-1358 # 80022000 <disk>
    if(f->ref == 0){
    80004556:	40dc                	lw	a5,4(s1)
    80004558:	cf99                	beqz	a5,80004576 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000455a:	02848493          	addi	s1,s1,40
    8000455e:	fee49ce3          	bne	s1,a4,80004556 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004562:	0001d517          	auipc	a0,0x1d
    80004566:	ae650513          	addi	a0,a0,-1306 # 80021048 <ftable>
    8000456a:	ffffc097          	auipc	ra,0xffffc
    8000456e:	71c080e7          	jalr	1820(ra) # 80000c86 <release>
  return 0;
    80004572:	4481                	li	s1,0
    80004574:	a819                	j	8000458a <filealloc+0x5e>
      f->ref = 1;
    80004576:	4785                	li	a5,1
    80004578:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000457a:	0001d517          	auipc	a0,0x1d
    8000457e:	ace50513          	addi	a0,a0,-1330 # 80021048 <ftable>
    80004582:	ffffc097          	auipc	ra,0xffffc
    80004586:	704080e7          	jalr	1796(ra) # 80000c86 <release>
}
    8000458a:	8526                	mv	a0,s1
    8000458c:	60e2                	ld	ra,24(sp)
    8000458e:	6442                	ld	s0,16(sp)
    80004590:	64a2                	ld	s1,8(sp)
    80004592:	6105                	addi	sp,sp,32
    80004594:	8082                	ret

0000000080004596 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004596:	1101                	addi	sp,sp,-32
    80004598:	ec06                	sd	ra,24(sp)
    8000459a:	e822                	sd	s0,16(sp)
    8000459c:	e426                	sd	s1,8(sp)
    8000459e:	1000                	addi	s0,sp,32
    800045a0:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800045a2:	0001d517          	auipc	a0,0x1d
    800045a6:	aa650513          	addi	a0,a0,-1370 # 80021048 <ftable>
    800045aa:	ffffc097          	auipc	ra,0xffffc
    800045ae:	628080e7          	jalr	1576(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    800045b2:	40dc                	lw	a5,4(s1)
    800045b4:	02f05263          	blez	a5,800045d8 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800045b8:	2785                	addiw	a5,a5,1
    800045ba:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800045bc:	0001d517          	auipc	a0,0x1d
    800045c0:	a8c50513          	addi	a0,a0,-1396 # 80021048 <ftable>
    800045c4:	ffffc097          	auipc	ra,0xffffc
    800045c8:	6c2080e7          	jalr	1730(ra) # 80000c86 <release>
  return f;
}
    800045cc:	8526                	mv	a0,s1
    800045ce:	60e2                	ld	ra,24(sp)
    800045d0:	6442                	ld	s0,16(sp)
    800045d2:	64a2                	ld	s1,8(sp)
    800045d4:	6105                	addi	sp,sp,32
    800045d6:	8082                	ret
    panic("filedup");
    800045d8:	00004517          	auipc	a0,0x4
    800045dc:	2b850513          	addi	a0,a0,696 # 80008890 <syscall_names+0x248>
    800045e0:	ffffc097          	auipc	ra,0xffffc
    800045e4:	f5c080e7          	jalr	-164(ra) # 8000053c <panic>

00000000800045e8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800045e8:	7139                	addi	sp,sp,-64
    800045ea:	fc06                	sd	ra,56(sp)
    800045ec:	f822                	sd	s0,48(sp)
    800045ee:	f426                	sd	s1,40(sp)
    800045f0:	f04a                	sd	s2,32(sp)
    800045f2:	ec4e                	sd	s3,24(sp)
    800045f4:	e852                	sd	s4,16(sp)
    800045f6:	e456                	sd	s5,8(sp)
    800045f8:	0080                	addi	s0,sp,64
    800045fa:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800045fc:	0001d517          	auipc	a0,0x1d
    80004600:	a4c50513          	addi	a0,a0,-1460 # 80021048 <ftable>
    80004604:	ffffc097          	auipc	ra,0xffffc
    80004608:	5ce080e7          	jalr	1486(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    8000460c:	40dc                	lw	a5,4(s1)
    8000460e:	06f05163          	blez	a5,80004670 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004612:	37fd                	addiw	a5,a5,-1
    80004614:	0007871b          	sext.w	a4,a5
    80004618:	c0dc                	sw	a5,4(s1)
    8000461a:	06e04363          	bgtz	a4,80004680 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000461e:	0004a903          	lw	s2,0(s1)
    80004622:	0094ca83          	lbu	s5,9(s1)
    80004626:	0104ba03          	ld	s4,16(s1)
    8000462a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000462e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004632:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004636:	0001d517          	auipc	a0,0x1d
    8000463a:	a1250513          	addi	a0,a0,-1518 # 80021048 <ftable>
    8000463e:	ffffc097          	auipc	ra,0xffffc
    80004642:	648080e7          	jalr	1608(ra) # 80000c86 <release>

  if(ff.type == FD_PIPE){
    80004646:	4785                	li	a5,1
    80004648:	04f90d63          	beq	s2,a5,800046a2 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000464c:	3979                	addiw	s2,s2,-2
    8000464e:	4785                	li	a5,1
    80004650:	0527e063          	bltu	a5,s2,80004690 <fileclose+0xa8>
    begin_op();
    80004654:	00000097          	auipc	ra,0x0
    80004658:	ad0080e7          	jalr	-1328(ra) # 80004124 <begin_op>
    iput(ff.ip);
    8000465c:	854e                	mv	a0,s3
    8000465e:	fffff097          	auipc	ra,0xfffff
    80004662:	2da080e7          	jalr	730(ra) # 80003938 <iput>
    end_op();
    80004666:	00000097          	auipc	ra,0x0
    8000466a:	b38080e7          	jalr	-1224(ra) # 8000419e <end_op>
    8000466e:	a00d                	j	80004690 <fileclose+0xa8>
    panic("fileclose");
    80004670:	00004517          	auipc	a0,0x4
    80004674:	22850513          	addi	a0,a0,552 # 80008898 <syscall_names+0x250>
    80004678:	ffffc097          	auipc	ra,0xffffc
    8000467c:	ec4080e7          	jalr	-316(ra) # 8000053c <panic>
    release(&ftable.lock);
    80004680:	0001d517          	auipc	a0,0x1d
    80004684:	9c850513          	addi	a0,a0,-1592 # 80021048 <ftable>
    80004688:	ffffc097          	auipc	ra,0xffffc
    8000468c:	5fe080e7          	jalr	1534(ra) # 80000c86 <release>
  }
}
    80004690:	70e2                	ld	ra,56(sp)
    80004692:	7442                	ld	s0,48(sp)
    80004694:	74a2                	ld	s1,40(sp)
    80004696:	7902                	ld	s2,32(sp)
    80004698:	69e2                	ld	s3,24(sp)
    8000469a:	6a42                	ld	s4,16(sp)
    8000469c:	6aa2                	ld	s5,8(sp)
    8000469e:	6121                	addi	sp,sp,64
    800046a0:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800046a2:	85d6                	mv	a1,s5
    800046a4:	8552                	mv	a0,s4
    800046a6:	00000097          	auipc	ra,0x0
    800046aa:	348080e7          	jalr	840(ra) # 800049ee <pipeclose>
    800046ae:	b7cd                	j	80004690 <fileclose+0xa8>

00000000800046b0 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800046b0:	715d                	addi	sp,sp,-80
    800046b2:	e486                	sd	ra,72(sp)
    800046b4:	e0a2                	sd	s0,64(sp)
    800046b6:	fc26                	sd	s1,56(sp)
    800046b8:	f84a                	sd	s2,48(sp)
    800046ba:	f44e                	sd	s3,40(sp)
    800046bc:	0880                	addi	s0,sp,80
    800046be:	84aa                	mv	s1,a0
    800046c0:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800046c2:	ffffd097          	auipc	ra,0xffffd
    800046c6:	2e4080e7          	jalr	740(ra) # 800019a6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800046ca:	409c                	lw	a5,0(s1)
    800046cc:	37f9                	addiw	a5,a5,-2
    800046ce:	4705                	li	a4,1
    800046d0:	04f76763          	bltu	a4,a5,8000471e <filestat+0x6e>
    800046d4:	892a                	mv	s2,a0
    ilock(f->ip);
    800046d6:	6c88                	ld	a0,24(s1)
    800046d8:	fffff097          	auipc	ra,0xfffff
    800046dc:	0a6080e7          	jalr	166(ra) # 8000377e <ilock>
    stati(f->ip, &st);
    800046e0:	fb840593          	addi	a1,s0,-72
    800046e4:	6c88                	ld	a0,24(s1)
    800046e6:	fffff097          	auipc	ra,0xfffff
    800046ea:	322080e7          	jalr	802(ra) # 80003a08 <stati>
    iunlock(f->ip);
    800046ee:	6c88                	ld	a0,24(s1)
    800046f0:	fffff097          	auipc	ra,0xfffff
    800046f4:	150080e7          	jalr	336(ra) # 80003840 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800046f8:	46e1                	li	a3,24
    800046fa:	fb840613          	addi	a2,s0,-72
    800046fe:	85ce                	mv	a1,s3
    80004700:	05093503          	ld	a0,80(s2)
    80004704:	ffffd097          	auipc	ra,0xffffd
    80004708:	f62080e7          	jalr	-158(ra) # 80001666 <copyout>
    8000470c:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004710:	60a6                	ld	ra,72(sp)
    80004712:	6406                	ld	s0,64(sp)
    80004714:	74e2                	ld	s1,56(sp)
    80004716:	7942                	ld	s2,48(sp)
    80004718:	79a2                	ld	s3,40(sp)
    8000471a:	6161                	addi	sp,sp,80
    8000471c:	8082                	ret
  return -1;
    8000471e:	557d                	li	a0,-1
    80004720:	bfc5                	j	80004710 <filestat+0x60>

0000000080004722 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004722:	7179                	addi	sp,sp,-48
    80004724:	f406                	sd	ra,40(sp)
    80004726:	f022                	sd	s0,32(sp)
    80004728:	ec26                	sd	s1,24(sp)
    8000472a:	e84a                	sd	s2,16(sp)
    8000472c:	e44e                	sd	s3,8(sp)
    8000472e:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004730:	00854783          	lbu	a5,8(a0)
    80004734:	c3d5                	beqz	a5,800047d8 <fileread+0xb6>
    80004736:	84aa                	mv	s1,a0
    80004738:	89ae                	mv	s3,a1
    8000473a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000473c:	411c                	lw	a5,0(a0)
    8000473e:	4705                	li	a4,1
    80004740:	04e78963          	beq	a5,a4,80004792 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004744:	470d                	li	a4,3
    80004746:	04e78d63          	beq	a5,a4,800047a0 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000474a:	4709                	li	a4,2
    8000474c:	06e79e63          	bne	a5,a4,800047c8 <fileread+0xa6>
    ilock(f->ip);
    80004750:	6d08                	ld	a0,24(a0)
    80004752:	fffff097          	auipc	ra,0xfffff
    80004756:	02c080e7          	jalr	44(ra) # 8000377e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000475a:	874a                	mv	a4,s2
    8000475c:	5094                	lw	a3,32(s1)
    8000475e:	864e                	mv	a2,s3
    80004760:	4585                	li	a1,1
    80004762:	6c88                	ld	a0,24(s1)
    80004764:	fffff097          	auipc	ra,0xfffff
    80004768:	2ce080e7          	jalr	718(ra) # 80003a32 <readi>
    8000476c:	892a                	mv	s2,a0
    8000476e:	00a05563          	blez	a0,80004778 <fileread+0x56>
      f->off += r;
    80004772:	509c                	lw	a5,32(s1)
    80004774:	9fa9                	addw	a5,a5,a0
    80004776:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004778:	6c88                	ld	a0,24(s1)
    8000477a:	fffff097          	auipc	ra,0xfffff
    8000477e:	0c6080e7          	jalr	198(ra) # 80003840 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004782:	854a                	mv	a0,s2
    80004784:	70a2                	ld	ra,40(sp)
    80004786:	7402                	ld	s0,32(sp)
    80004788:	64e2                	ld	s1,24(sp)
    8000478a:	6942                	ld	s2,16(sp)
    8000478c:	69a2                	ld	s3,8(sp)
    8000478e:	6145                	addi	sp,sp,48
    80004790:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004792:	6908                	ld	a0,16(a0)
    80004794:	00000097          	auipc	ra,0x0
    80004798:	3c2080e7          	jalr	962(ra) # 80004b56 <piperead>
    8000479c:	892a                	mv	s2,a0
    8000479e:	b7d5                	j	80004782 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800047a0:	02451783          	lh	a5,36(a0)
    800047a4:	03079693          	slli	a3,a5,0x30
    800047a8:	92c1                	srli	a3,a3,0x30
    800047aa:	4725                	li	a4,9
    800047ac:	02d76863          	bltu	a4,a3,800047dc <fileread+0xba>
    800047b0:	0792                	slli	a5,a5,0x4
    800047b2:	0001c717          	auipc	a4,0x1c
    800047b6:	7f670713          	addi	a4,a4,2038 # 80020fa8 <devsw>
    800047ba:	97ba                	add	a5,a5,a4
    800047bc:	639c                	ld	a5,0(a5)
    800047be:	c38d                	beqz	a5,800047e0 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800047c0:	4505                	li	a0,1
    800047c2:	9782                	jalr	a5
    800047c4:	892a                	mv	s2,a0
    800047c6:	bf75                	j	80004782 <fileread+0x60>
    panic("fileread");
    800047c8:	00004517          	auipc	a0,0x4
    800047cc:	0e050513          	addi	a0,a0,224 # 800088a8 <syscall_names+0x260>
    800047d0:	ffffc097          	auipc	ra,0xffffc
    800047d4:	d6c080e7          	jalr	-660(ra) # 8000053c <panic>
    return -1;
    800047d8:	597d                	li	s2,-1
    800047da:	b765                	j	80004782 <fileread+0x60>
      return -1;
    800047dc:	597d                	li	s2,-1
    800047de:	b755                	j	80004782 <fileread+0x60>
    800047e0:	597d                	li	s2,-1
    800047e2:	b745                	j	80004782 <fileread+0x60>

00000000800047e4 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800047e4:	00954783          	lbu	a5,9(a0)
    800047e8:	10078e63          	beqz	a5,80004904 <filewrite+0x120>
{
    800047ec:	715d                	addi	sp,sp,-80
    800047ee:	e486                	sd	ra,72(sp)
    800047f0:	e0a2                	sd	s0,64(sp)
    800047f2:	fc26                	sd	s1,56(sp)
    800047f4:	f84a                	sd	s2,48(sp)
    800047f6:	f44e                	sd	s3,40(sp)
    800047f8:	f052                	sd	s4,32(sp)
    800047fa:	ec56                	sd	s5,24(sp)
    800047fc:	e85a                	sd	s6,16(sp)
    800047fe:	e45e                	sd	s7,8(sp)
    80004800:	e062                	sd	s8,0(sp)
    80004802:	0880                	addi	s0,sp,80
    80004804:	892a                	mv	s2,a0
    80004806:	8b2e                	mv	s6,a1
    80004808:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000480a:	411c                	lw	a5,0(a0)
    8000480c:	4705                	li	a4,1
    8000480e:	02e78263          	beq	a5,a4,80004832 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004812:	470d                	li	a4,3
    80004814:	02e78563          	beq	a5,a4,8000483e <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004818:	4709                	li	a4,2
    8000481a:	0ce79d63          	bne	a5,a4,800048f4 <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000481e:	0ac05b63          	blez	a2,800048d4 <filewrite+0xf0>
    int i = 0;
    80004822:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004824:	6b85                	lui	s7,0x1
    80004826:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000482a:	6c05                	lui	s8,0x1
    8000482c:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004830:	a851                	j	800048c4 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004832:	6908                	ld	a0,16(a0)
    80004834:	00000097          	auipc	ra,0x0
    80004838:	22a080e7          	jalr	554(ra) # 80004a5e <pipewrite>
    8000483c:	a045                	j	800048dc <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000483e:	02451783          	lh	a5,36(a0)
    80004842:	03079693          	slli	a3,a5,0x30
    80004846:	92c1                	srli	a3,a3,0x30
    80004848:	4725                	li	a4,9
    8000484a:	0ad76f63          	bltu	a4,a3,80004908 <filewrite+0x124>
    8000484e:	0792                	slli	a5,a5,0x4
    80004850:	0001c717          	auipc	a4,0x1c
    80004854:	75870713          	addi	a4,a4,1880 # 80020fa8 <devsw>
    80004858:	97ba                	add	a5,a5,a4
    8000485a:	679c                	ld	a5,8(a5)
    8000485c:	cbc5                	beqz	a5,8000490c <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    8000485e:	4505                	li	a0,1
    80004860:	9782                	jalr	a5
    80004862:	a8ad                	j	800048dc <filewrite+0xf8>
      if(n1 > max)
    80004864:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004868:	00000097          	auipc	ra,0x0
    8000486c:	8bc080e7          	jalr	-1860(ra) # 80004124 <begin_op>
      ilock(f->ip);
    80004870:	01893503          	ld	a0,24(s2)
    80004874:	fffff097          	auipc	ra,0xfffff
    80004878:	f0a080e7          	jalr	-246(ra) # 8000377e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000487c:	8756                	mv	a4,s5
    8000487e:	02092683          	lw	a3,32(s2)
    80004882:	01698633          	add	a2,s3,s6
    80004886:	4585                	li	a1,1
    80004888:	01893503          	ld	a0,24(s2)
    8000488c:	fffff097          	auipc	ra,0xfffff
    80004890:	29e080e7          	jalr	670(ra) # 80003b2a <writei>
    80004894:	84aa                	mv	s1,a0
    80004896:	00a05763          	blez	a0,800048a4 <filewrite+0xc0>
        f->off += r;
    8000489a:	02092783          	lw	a5,32(s2)
    8000489e:	9fa9                	addw	a5,a5,a0
    800048a0:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800048a4:	01893503          	ld	a0,24(s2)
    800048a8:	fffff097          	auipc	ra,0xfffff
    800048ac:	f98080e7          	jalr	-104(ra) # 80003840 <iunlock>
      end_op();
    800048b0:	00000097          	auipc	ra,0x0
    800048b4:	8ee080e7          	jalr	-1810(ra) # 8000419e <end_op>

      if(r != n1){
    800048b8:	009a9f63          	bne	s5,s1,800048d6 <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    800048bc:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800048c0:	0149db63          	bge	s3,s4,800048d6 <filewrite+0xf2>
      int n1 = n - i;
    800048c4:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800048c8:	0004879b          	sext.w	a5,s1
    800048cc:	f8fbdce3          	bge	s7,a5,80004864 <filewrite+0x80>
    800048d0:	84e2                	mv	s1,s8
    800048d2:	bf49                	j	80004864 <filewrite+0x80>
    int i = 0;
    800048d4:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800048d6:	033a1d63          	bne	s4,s3,80004910 <filewrite+0x12c>
    800048da:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    800048dc:	60a6                	ld	ra,72(sp)
    800048de:	6406                	ld	s0,64(sp)
    800048e0:	74e2                	ld	s1,56(sp)
    800048e2:	7942                	ld	s2,48(sp)
    800048e4:	79a2                	ld	s3,40(sp)
    800048e6:	7a02                	ld	s4,32(sp)
    800048e8:	6ae2                	ld	s5,24(sp)
    800048ea:	6b42                	ld	s6,16(sp)
    800048ec:	6ba2                	ld	s7,8(sp)
    800048ee:	6c02                	ld	s8,0(sp)
    800048f0:	6161                	addi	sp,sp,80
    800048f2:	8082                	ret
    panic("filewrite");
    800048f4:	00004517          	auipc	a0,0x4
    800048f8:	fc450513          	addi	a0,a0,-60 # 800088b8 <syscall_names+0x270>
    800048fc:	ffffc097          	auipc	ra,0xffffc
    80004900:	c40080e7          	jalr	-960(ra) # 8000053c <panic>
    return -1;
    80004904:	557d                	li	a0,-1
}
    80004906:	8082                	ret
      return -1;
    80004908:	557d                	li	a0,-1
    8000490a:	bfc9                	j	800048dc <filewrite+0xf8>
    8000490c:	557d                	li	a0,-1
    8000490e:	b7f9                	j	800048dc <filewrite+0xf8>
    ret = (i == n ? n : -1);
    80004910:	557d                	li	a0,-1
    80004912:	b7e9                	j	800048dc <filewrite+0xf8>

0000000080004914 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004914:	7179                	addi	sp,sp,-48
    80004916:	f406                	sd	ra,40(sp)
    80004918:	f022                	sd	s0,32(sp)
    8000491a:	ec26                	sd	s1,24(sp)
    8000491c:	e84a                	sd	s2,16(sp)
    8000491e:	e44e                	sd	s3,8(sp)
    80004920:	e052                	sd	s4,0(sp)
    80004922:	1800                	addi	s0,sp,48
    80004924:	84aa                	mv	s1,a0
    80004926:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004928:	0005b023          	sd	zero,0(a1)
    8000492c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004930:	00000097          	auipc	ra,0x0
    80004934:	bfc080e7          	jalr	-1028(ra) # 8000452c <filealloc>
    80004938:	e088                	sd	a0,0(s1)
    8000493a:	c551                	beqz	a0,800049c6 <pipealloc+0xb2>
    8000493c:	00000097          	auipc	ra,0x0
    80004940:	bf0080e7          	jalr	-1040(ra) # 8000452c <filealloc>
    80004944:	00aa3023          	sd	a0,0(s4)
    80004948:	c92d                	beqz	a0,800049ba <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000494a:	ffffc097          	auipc	ra,0xffffc
    8000494e:	198080e7          	jalr	408(ra) # 80000ae2 <kalloc>
    80004952:	892a                	mv	s2,a0
    80004954:	c125                	beqz	a0,800049b4 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004956:	4985                	li	s3,1
    80004958:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000495c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004960:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004964:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004968:	00004597          	auipc	a1,0x4
    8000496c:	b2058593          	addi	a1,a1,-1248 # 80008488 <states.0+0x1c0>
    80004970:	ffffc097          	auipc	ra,0xffffc
    80004974:	1d2080e7          	jalr	466(ra) # 80000b42 <initlock>
  (*f0)->type = FD_PIPE;
    80004978:	609c                	ld	a5,0(s1)
    8000497a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000497e:	609c                	ld	a5,0(s1)
    80004980:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004984:	609c                	ld	a5,0(s1)
    80004986:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000498a:	609c                	ld	a5,0(s1)
    8000498c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004990:	000a3783          	ld	a5,0(s4)
    80004994:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004998:	000a3783          	ld	a5,0(s4)
    8000499c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800049a0:	000a3783          	ld	a5,0(s4)
    800049a4:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800049a8:	000a3783          	ld	a5,0(s4)
    800049ac:	0127b823          	sd	s2,16(a5)
  return 0;
    800049b0:	4501                	li	a0,0
    800049b2:	a025                	j	800049da <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800049b4:	6088                	ld	a0,0(s1)
    800049b6:	e501                	bnez	a0,800049be <pipealloc+0xaa>
    800049b8:	a039                	j	800049c6 <pipealloc+0xb2>
    800049ba:	6088                	ld	a0,0(s1)
    800049bc:	c51d                	beqz	a0,800049ea <pipealloc+0xd6>
    fileclose(*f0);
    800049be:	00000097          	auipc	ra,0x0
    800049c2:	c2a080e7          	jalr	-982(ra) # 800045e8 <fileclose>
  if(*f1)
    800049c6:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800049ca:	557d                	li	a0,-1
  if(*f1)
    800049cc:	c799                	beqz	a5,800049da <pipealloc+0xc6>
    fileclose(*f1);
    800049ce:	853e                	mv	a0,a5
    800049d0:	00000097          	auipc	ra,0x0
    800049d4:	c18080e7          	jalr	-1000(ra) # 800045e8 <fileclose>
  return -1;
    800049d8:	557d                	li	a0,-1
}
    800049da:	70a2                	ld	ra,40(sp)
    800049dc:	7402                	ld	s0,32(sp)
    800049de:	64e2                	ld	s1,24(sp)
    800049e0:	6942                	ld	s2,16(sp)
    800049e2:	69a2                	ld	s3,8(sp)
    800049e4:	6a02                	ld	s4,0(sp)
    800049e6:	6145                	addi	sp,sp,48
    800049e8:	8082                	ret
  return -1;
    800049ea:	557d                	li	a0,-1
    800049ec:	b7fd                	j	800049da <pipealloc+0xc6>

00000000800049ee <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800049ee:	1101                	addi	sp,sp,-32
    800049f0:	ec06                	sd	ra,24(sp)
    800049f2:	e822                	sd	s0,16(sp)
    800049f4:	e426                	sd	s1,8(sp)
    800049f6:	e04a                	sd	s2,0(sp)
    800049f8:	1000                	addi	s0,sp,32
    800049fa:	84aa                	mv	s1,a0
    800049fc:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800049fe:	ffffc097          	auipc	ra,0xffffc
    80004a02:	1d4080e7          	jalr	468(ra) # 80000bd2 <acquire>
  if(writable){
    80004a06:	02090d63          	beqz	s2,80004a40 <pipeclose+0x52>
    pi->writeopen = 0;
    80004a0a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004a0e:	21848513          	addi	a0,s1,536
    80004a12:	ffffd097          	auipc	ra,0xffffd
    80004a16:	6ac080e7          	jalr	1708(ra) # 800020be <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004a1a:	2204b783          	ld	a5,544(s1)
    80004a1e:	eb95                	bnez	a5,80004a52 <pipeclose+0x64>
    release(&pi->lock);
    80004a20:	8526                	mv	a0,s1
    80004a22:	ffffc097          	auipc	ra,0xffffc
    80004a26:	264080e7          	jalr	612(ra) # 80000c86 <release>
    kfree((char*)pi);
    80004a2a:	8526                	mv	a0,s1
    80004a2c:	ffffc097          	auipc	ra,0xffffc
    80004a30:	fb8080e7          	jalr	-72(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    80004a34:	60e2                	ld	ra,24(sp)
    80004a36:	6442                	ld	s0,16(sp)
    80004a38:	64a2                	ld	s1,8(sp)
    80004a3a:	6902                	ld	s2,0(sp)
    80004a3c:	6105                	addi	sp,sp,32
    80004a3e:	8082                	ret
    pi->readopen = 0;
    80004a40:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a44:	21c48513          	addi	a0,s1,540
    80004a48:	ffffd097          	auipc	ra,0xffffd
    80004a4c:	676080e7          	jalr	1654(ra) # 800020be <wakeup>
    80004a50:	b7e9                	j	80004a1a <pipeclose+0x2c>
    release(&pi->lock);
    80004a52:	8526                	mv	a0,s1
    80004a54:	ffffc097          	auipc	ra,0xffffc
    80004a58:	232080e7          	jalr	562(ra) # 80000c86 <release>
}
    80004a5c:	bfe1                	j	80004a34 <pipeclose+0x46>

0000000080004a5e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a5e:	711d                	addi	sp,sp,-96
    80004a60:	ec86                	sd	ra,88(sp)
    80004a62:	e8a2                	sd	s0,80(sp)
    80004a64:	e4a6                	sd	s1,72(sp)
    80004a66:	e0ca                	sd	s2,64(sp)
    80004a68:	fc4e                	sd	s3,56(sp)
    80004a6a:	f852                	sd	s4,48(sp)
    80004a6c:	f456                	sd	s5,40(sp)
    80004a6e:	f05a                	sd	s6,32(sp)
    80004a70:	ec5e                	sd	s7,24(sp)
    80004a72:	e862                	sd	s8,16(sp)
    80004a74:	1080                	addi	s0,sp,96
    80004a76:	84aa                	mv	s1,a0
    80004a78:	8aae                	mv	s5,a1
    80004a7a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004a7c:	ffffd097          	auipc	ra,0xffffd
    80004a80:	f2a080e7          	jalr	-214(ra) # 800019a6 <myproc>
    80004a84:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004a86:	8526                	mv	a0,s1
    80004a88:	ffffc097          	auipc	ra,0xffffc
    80004a8c:	14a080e7          	jalr	330(ra) # 80000bd2 <acquire>
  while(i < n){
    80004a90:	0b405663          	blez	s4,80004b3c <pipewrite+0xde>
  int i = 0;
    80004a94:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a96:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004a98:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a9c:	21c48b93          	addi	s7,s1,540
    80004aa0:	a089                	j	80004ae2 <pipewrite+0x84>
      release(&pi->lock);
    80004aa2:	8526                	mv	a0,s1
    80004aa4:	ffffc097          	auipc	ra,0xffffc
    80004aa8:	1e2080e7          	jalr	482(ra) # 80000c86 <release>
      return -1;
    80004aac:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004aae:	854a                	mv	a0,s2
    80004ab0:	60e6                	ld	ra,88(sp)
    80004ab2:	6446                	ld	s0,80(sp)
    80004ab4:	64a6                	ld	s1,72(sp)
    80004ab6:	6906                	ld	s2,64(sp)
    80004ab8:	79e2                	ld	s3,56(sp)
    80004aba:	7a42                	ld	s4,48(sp)
    80004abc:	7aa2                	ld	s5,40(sp)
    80004abe:	7b02                	ld	s6,32(sp)
    80004ac0:	6be2                	ld	s7,24(sp)
    80004ac2:	6c42                	ld	s8,16(sp)
    80004ac4:	6125                	addi	sp,sp,96
    80004ac6:	8082                	ret
      wakeup(&pi->nread);
    80004ac8:	8562                	mv	a0,s8
    80004aca:	ffffd097          	auipc	ra,0xffffd
    80004ace:	5f4080e7          	jalr	1524(ra) # 800020be <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004ad2:	85a6                	mv	a1,s1
    80004ad4:	855e                	mv	a0,s7
    80004ad6:	ffffd097          	auipc	ra,0xffffd
    80004ada:	584080e7          	jalr	1412(ra) # 8000205a <sleep>
  while(i < n){
    80004ade:	07495063          	bge	s2,s4,80004b3e <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004ae2:	2204a783          	lw	a5,544(s1)
    80004ae6:	dfd5                	beqz	a5,80004aa2 <pipewrite+0x44>
    80004ae8:	854e                	mv	a0,s3
    80004aea:	ffffe097          	auipc	ra,0xffffe
    80004aee:	818080e7          	jalr	-2024(ra) # 80002302 <killed>
    80004af2:	f945                	bnez	a0,80004aa2 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004af4:	2184a783          	lw	a5,536(s1)
    80004af8:	21c4a703          	lw	a4,540(s1)
    80004afc:	2007879b          	addiw	a5,a5,512
    80004b00:	fcf704e3          	beq	a4,a5,80004ac8 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b04:	4685                	li	a3,1
    80004b06:	01590633          	add	a2,s2,s5
    80004b0a:	faf40593          	addi	a1,s0,-81
    80004b0e:	0509b503          	ld	a0,80(s3)
    80004b12:	ffffd097          	auipc	ra,0xffffd
    80004b16:	be0080e7          	jalr	-1056(ra) # 800016f2 <copyin>
    80004b1a:	03650263          	beq	a0,s6,80004b3e <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004b1e:	21c4a783          	lw	a5,540(s1)
    80004b22:	0017871b          	addiw	a4,a5,1
    80004b26:	20e4ae23          	sw	a4,540(s1)
    80004b2a:	1ff7f793          	andi	a5,a5,511
    80004b2e:	97a6                	add	a5,a5,s1
    80004b30:	faf44703          	lbu	a4,-81(s0)
    80004b34:	00e78c23          	sb	a4,24(a5)
      i++;
    80004b38:	2905                	addiw	s2,s2,1
    80004b3a:	b755                	j	80004ade <pipewrite+0x80>
  int i = 0;
    80004b3c:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004b3e:	21848513          	addi	a0,s1,536
    80004b42:	ffffd097          	auipc	ra,0xffffd
    80004b46:	57c080e7          	jalr	1404(ra) # 800020be <wakeup>
  release(&pi->lock);
    80004b4a:	8526                	mv	a0,s1
    80004b4c:	ffffc097          	auipc	ra,0xffffc
    80004b50:	13a080e7          	jalr	314(ra) # 80000c86 <release>
  return i;
    80004b54:	bfa9                	j	80004aae <pipewrite+0x50>

0000000080004b56 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004b56:	715d                	addi	sp,sp,-80
    80004b58:	e486                	sd	ra,72(sp)
    80004b5a:	e0a2                	sd	s0,64(sp)
    80004b5c:	fc26                	sd	s1,56(sp)
    80004b5e:	f84a                	sd	s2,48(sp)
    80004b60:	f44e                	sd	s3,40(sp)
    80004b62:	f052                	sd	s4,32(sp)
    80004b64:	ec56                	sd	s5,24(sp)
    80004b66:	e85a                	sd	s6,16(sp)
    80004b68:	0880                	addi	s0,sp,80
    80004b6a:	84aa                	mv	s1,a0
    80004b6c:	892e                	mv	s2,a1
    80004b6e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b70:	ffffd097          	auipc	ra,0xffffd
    80004b74:	e36080e7          	jalr	-458(ra) # 800019a6 <myproc>
    80004b78:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b7a:	8526                	mv	a0,s1
    80004b7c:	ffffc097          	auipc	ra,0xffffc
    80004b80:	056080e7          	jalr	86(ra) # 80000bd2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b84:	2184a703          	lw	a4,536(s1)
    80004b88:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b8c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b90:	02f71763          	bne	a4,a5,80004bbe <piperead+0x68>
    80004b94:	2244a783          	lw	a5,548(s1)
    80004b98:	c39d                	beqz	a5,80004bbe <piperead+0x68>
    if(killed(pr)){
    80004b9a:	8552                	mv	a0,s4
    80004b9c:	ffffd097          	auipc	ra,0xffffd
    80004ba0:	766080e7          	jalr	1894(ra) # 80002302 <killed>
    80004ba4:	e949                	bnez	a0,80004c36 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ba6:	85a6                	mv	a1,s1
    80004ba8:	854e                	mv	a0,s3
    80004baa:	ffffd097          	auipc	ra,0xffffd
    80004bae:	4b0080e7          	jalr	1200(ra) # 8000205a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bb2:	2184a703          	lw	a4,536(s1)
    80004bb6:	21c4a783          	lw	a5,540(s1)
    80004bba:	fcf70de3          	beq	a4,a5,80004b94 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bbe:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004bc0:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bc2:	05505463          	blez	s5,80004c0a <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004bc6:	2184a783          	lw	a5,536(s1)
    80004bca:	21c4a703          	lw	a4,540(s1)
    80004bce:	02f70e63          	beq	a4,a5,80004c0a <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004bd2:	0017871b          	addiw	a4,a5,1
    80004bd6:	20e4ac23          	sw	a4,536(s1)
    80004bda:	1ff7f793          	andi	a5,a5,511
    80004bde:	97a6                	add	a5,a5,s1
    80004be0:	0187c783          	lbu	a5,24(a5)
    80004be4:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004be8:	4685                	li	a3,1
    80004bea:	fbf40613          	addi	a2,s0,-65
    80004bee:	85ca                	mv	a1,s2
    80004bf0:	050a3503          	ld	a0,80(s4)
    80004bf4:	ffffd097          	auipc	ra,0xffffd
    80004bf8:	a72080e7          	jalr	-1422(ra) # 80001666 <copyout>
    80004bfc:	01650763          	beq	a0,s6,80004c0a <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c00:	2985                	addiw	s3,s3,1
    80004c02:	0905                	addi	s2,s2,1
    80004c04:	fd3a91e3          	bne	s5,s3,80004bc6 <piperead+0x70>
    80004c08:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004c0a:	21c48513          	addi	a0,s1,540
    80004c0e:	ffffd097          	auipc	ra,0xffffd
    80004c12:	4b0080e7          	jalr	1200(ra) # 800020be <wakeup>
  release(&pi->lock);
    80004c16:	8526                	mv	a0,s1
    80004c18:	ffffc097          	auipc	ra,0xffffc
    80004c1c:	06e080e7          	jalr	110(ra) # 80000c86 <release>
  return i;
}
    80004c20:	854e                	mv	a0,s3
    80004c22:	60a6                	ld	ra,72(sp)
    80004c24:	6406                	ld	s0,64(sp)
    80004c26:	74e2                	ld	s1,56(sp)
    80004c28:	7942                	ld	s2,48(sp)
    80004c2a:	79a2                	ld	s3,40(sp)
    80004c2c:	7a02                	ld	s4,32(sp)
    80004c2e:	6ae2                	ld	s5,24(sp)
    80004c30:	6b42                	ld	s6,16(sp)
    80004c32:	6161                	addi	sp,sp,80
    80004c34:	8082                	ret
      release(&pi->lock);
    80004c36:	8526                	mv	a0,s1
    80004c38:	ffffc097          	auipc	ra,0xffffc
    80004c3c:	04e080e7          	jalr	78(ra) # 80000c86 <release>
      return -1;
    80004c40:	59fd                	li	s3,-1
    80004c42:	bff9                	j	80004c20 <piperead+0xca>

0000000080004c44 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004c44:	1141                	addi	sp,sp,-16
    80004c46:	e422                	sd	s0,8(sp)
    80004c48:	0800                	addi	s0,sp,16
    80004c4a:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004c4c:	8905                	andi	a0,a0,1
    80004c4e:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004c50:	8b89                	andi	a5,a5,2
    80004c52:	c399                	beqz	a5,80004c58 <flags2perm+0x14>
      perm |= PTE_W;
    80004c54:	00456513          	ori	a0,a0,4
    return perm;
}
    80004c58:	6422                	ld	s0,8(sp)
    80004c5a:	0141                	addi	sp,sp,16
    80004c5c:	8082                	ret

0000000080004c5e <exec>:

int
exec(char *path, char **argv)
{
    80004c5e:	df010113          	addi	sp,sp,-528
    80004c62:	20113423          	sd	ra,520(sp)
    80004c66:	20813023          	sd	s0,512(sp)
    80004c6a:	ffa6                	sd	s1,504(sp)
    80004c6c:	fbca                	sd	s2,496(sp)
    80004c6e:	f7ce                	sd	s3,488(sp)
    80004c70:	f3d2                	sd	s4,480(sp)
    80004c72:	efd6                	sd	s5,472(sp)
    80004c74:	ebda                	sd	s6,464(sp)
    80004c76:	e7de                	sd	s7,456(sp)
    80004c78:	e3e2                	sd	s8,448(sp)
    80004c7a:	ff66                	sd	s9,440(sp)
    80004c7c:	fb6a                	sd	s10,432(sp)
    80004c7e:	f76e                	sd	s11,424(sp)
    80004c80:	0c00                	addi	s0,sp,528
    80004c82:	892a                	mv	s2,a0
    80004c84:	dea43c23          	sd	a0,-520(s0)
    80004c88:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004c8c:	ffffd097          	auipc	ra,0xffffd
    80004c90:	d1a080e7          	jalr	-742(ra) # 800019a6 <myproc>
    80004c94:	84aa                	mv	s1,a0

  begin_op();
    80004c96:	fffff097          	auipc	ra,0xfffff
    80004c9a:	48e080e7          	jalr	1166(ra) # 80004124 <begin_op>

  if((ip = namei(path)) == 0){
    80004c9e:	854a                	mv	a0,s2
    80004ca0:	fffff097          	auipc	ra,0xfffff
    80004ca4:	284080e7          	jalr	644(ra) # 80003f24 <namei>
    80004ca8:	c92d                	beqz	a0,80004d1a <exec+0xbc>
    80004caa:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004cac:	fffff097          	auipc	ra,0xfffff
    80004cb0:	ad2080e7          	jalr	-1326(ra) # 8000377e <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004cb4:	04000713          	li	a4,64
    80004cb8:	4681                	li	a3,0
    80004cba:	e5040613          	addi	a2,s0,-432
    80004cbe:	4581                	li	a1,0
    80004cc0:	8552                	mv	a0,s4
    80004cc2:	fffff097          	auipc	ra,0xfffff
    80004cc6:	d70080e7          	jalr	-656(ra) # 80003a32 <readi>
    80004cca:	04000793          	li	a5,64
    80004cce:	00f51a63          	bne	a0,a5,80004ce2 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004cd2:	e5042703          	lw	a4,-432(s0)
    80004cd6:	464c47b7          	lui	a5,0x464c4
    80004cda:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004cde:	04f70463          	beq	a4,a5,80004d26 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004ce2:	8552                	mv	a0,s4
    80004ce4:	fffff097          	auipc	ra,0xfffff
    80004ce8:	cfc080e7          	jalr	-772(ra) # 800039e0 <iunlockput>
    end_op();
    80004cec:	fffff097          	auipc	ra,0xfffff
    80004cf0:	4b2080e7          	jalr	1202(ra) # 8000419e <end_op>
  }
  return -1;
    80004cf4:	557d                	li	a0,-1
}
    80004cf6:	20813083          	ld	ra,520(sp)
    80004cfa:	20013403          	ld	s0,512(sp)
    80004cfe:	74fe                	ld	s1,504(sp)
    80004d00:	795e                	ld	s2,496(sp)
    80004d02:	79be                	ld	s3,488(sp)
    80004d04:	7a1e                	ld	s4,480(sp)
    80004d06:	6afe                	ld	s5,472(sp)
    80004d08:	6b5e                	ld	s6,464(sp)
    80004d0a:	6bbe                	ld	s7,456(sp)
    80004d0c:	6c1e                	ld	s8,448(sp)
    80004d0e:	7cfa                	ld	s9,440(sp)
    80004d10:	7d5a                	ld	s10,432(sp)
    80004d12:	7dba                	ld	s11,424(sp)
    80004d14:	21010113          	addi	sp,sp,528
    80004d18:	8082                	ret
    end_op();
    80004d1a:	fffff097          	auipc	ra,0xfffff
    80004d1e:	484080e7          	jalr	1156(ra) # 8000419e <end_op>
    return -1;
    80004d22:	557d                	li	a0,-1
    80004d24:	bfc9                	j	80004cf6 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004d26:	8526                	mv	a0,s1
    80004d28:	ffffd097          	auipc	ra,0xffffd
    80004d2c:	d42080e7          	jalr	-702(ra) # 80001a6a <proc_pagetable>
    80004d30:	8b2a                	mv	s6,a0
    80004d32:	d945                	beqz	a0,80004ce2 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d34:	e7042d03          	lw	s10,-400(s0)
    80004d38:	e8845783          	lhu	a5,-376(s0)
    80004d3c:	10078463          	beqz	a5,80004e44 <exec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d40:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d42:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004d44:	6c85                	lui	s9,0x1
    80004d46:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004d4a:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004d4e:	6a85                	lui	s5,0x1
    80004d50:	a0b5                	j	80004dbc <exec+0x15e>
      panic("loadseg: address should exist");
    80004d52:	00004517          	auipc	a0,0x4
    80004d56:	b7650513          	addi	a0,a0,-1162 # 800088c8 <syscall_names+0x280>
    80004d5a:	ffffb097          	auipc	ra,0xffffb
    80004d5e:	7e2080e7          	jalr	2018(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    80004d62:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004d64:	8726                	mv	a4,s1
    80004d66:	012c06bb          	addw	a3,s8,s2
    80004d6a:	4581                	li	a1,0
    80004d6c:	8552                	mv	a0,s4
    80004d6e:	fffff097          	auipc	ra,0xfffff
    80004d72:	cc4080e7          	jalr	-828(ra) # 80003a32 <readi>
    80004d76:	2501                	sext.w	a0,a0
    80004d78:	24a49863          	bne	s1,a0,80004fc8 <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    80004d7c:	012a893b          	addw	s2,s5,s2
    80004d80:	03397563          	bgeu	s2,s3,80004daa <exec+0x14c>
    pa = walkaddr(pagetable, va + i);
    80004d84:	02091593          	slli	a1,s2,0x20
    80004d88:	9181                	srli	a1,a1,0x20
    80004d8a:	95de                	add	a1,a1,s7
    80004d8c:	855a                	mv	a0,s6
    80004d8e:	ffffc097          	auipc	ra,0xffffc
    80004d92:	2c8080e7          	jalr	712(ra) # 80001056 <walkaddr>
    80004d96:	862a                	mv	a2,a0
    if(pa == 0)
    80004d98:	dd4d                	beqz	a0,80004d52 <exec+0xf4>
    if(sz - i < PGSIZE)
    80004d9a:	412984bb          	subw	s1,s3,s2
    80004d9e:	0004879b          	sext.w	a5,s1
    80004da2:	fcfcf0e3          	bgeu	s9,a5,80004d62 <exec+0x104>
    80004da6:	84d6                	mv	s1,s5
    80004da8:	bf6d                	j	80004d62 <exec+0x104>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004daa:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004dae:	2d85                	addiw	s11,s11,1
    80004db0:	038d0d1b          	addiw	s10,s10,56
    80004db4:	e8845783          	lhu	a5,-376(s0)
    80004db8:	08fdd763          	bge	s11,a5,80004e46 <exec+0x1e8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004dbc:	2d01                	sext.w	s10,s10
    80004dbe:	03800713          	li	a4,56
    80004dc2:	86ea                	mv	a3,s10
    80004dc4:	e1840613          	addi	a2,s0,-488
    80004dc8:	4581                	li	a1,0
    80004dca:	8552                	mv	a0,s4
    80004dcc:	fffff097          	auipc	ra,0xfffff
    80004dd0:	c66080e7          	jalr	-922(ra) # 80003a32 <readi>
    80004dd4:	03800793          	li	a5,56
    80004dd8:	1ef51663          	bne	a0,a5,80004fc4 <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    80004ddc:	e1842783          	lw	a5,-488(s0)
    80004de0:	4705                	li	a4,1
    80004de2:	fce796e3          	bne	a5,a4,80004dae <exec+0x150>
    if(ph.memsz < ph.filesz)
    80004de6:	e4043483          	ld	s1,-448(s0)
    80004dea:	e3843783          	ld	a5,-456(s0)
    80004dee:	1ef4e863          	bltu	s1,a5,80004fde <exec+0x380>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004df2:	e2843783          	ld	a5,-472(s0)
    80004df6:	94be                	add	s1,s1,a5
    80004df8:	1ef4e663          	bltu	s1,a5,80004fe4 <exec+0x386>
    if(ph.vaddr % PGSIZE != 0)
    80004dfc:	df043703          	ld	a4,-528(s0)
    80004e00:	8ff9                	and	a5,a5,a4
    80004e02:	1e079463          	bnez	a5,80004fea <exec+0x38c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004e06:	e1c42503          	lw	a0,-484(s0)
    80004e0a:	00000097          	auipc	ra,0x0
    80004e0e:	e3a080e7          	jalr	-454(ra) # 80004c44 <flags2perm>
    80004e12:	86aa                	mv	a3,a0
    80004e14:	8626                	mv	a2,s1
    80004e16:	85ca                	mv	a1,s2
    80004e18:	855a                	mv	a0,s6
    80004e1a:	ffffc097          	auipc	ra,0xffffc
    80004e1e:	5f0080e7          	jalr	1520(ra) # 8000140a <uvmalloc>
    80004e22:	e0a43423          	sd	a0,-504(s0)
    80004e26:	1c050563          	beqz	a0,80004ff0 <exec+0x392>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004e2a:	e2843b83          	ld	s7,-472(s0)
    80004e2e:	e2042c03          	lw	s8,-480(s0)
    80004e32:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004e36:	00098463          	beqz	s3,80004e3e <exec+0x1e0>
    80004e3a:	4901                	li	s2,0
    80004e3c:	b7a1                	j	80004d84 <exec+0x126>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004e3e:	e0843903          	ld	s2,-504(s0)
    80004e42:	b7b5                	j	80004dae <exec+0x150>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e44:	4901                	li	s2,0
  iunlockput(ip);
    80004e46:	8552                	mv	a0,s4
    80004e48:	fffff097          	auipc	ra,0xfffff
    80004e4c:	b98080e7          	jalr	-1128(ra) # 800039e0 <iunlockput>
  end_op();
    80004e50:	fffff097          	auipc	ra,0xfffff
    80004e54:	34e080e7          	jalr	846(ra) # 8000419e <end_op>
  p = myproc();
    80004e58:	ffffd097          	auipc	ra,0xffffd
    80004e5c:	b4e080e7          	jalr	-1202(ra) # 800019a6 <myproc>
    80004e60:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004e62:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004e66:	6985                	lui	s3,0x1
    80004e68:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004e6a:	99ca                	add	s3,s3,s2
    80004e6c:	77fd                	lui	a5,0xfffff
    80004e6e:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004e72:	4691                	li	a3,4
    80004e74:	6609                	lui	a2,0x2
    80004e76:	964e                	add	a2,a2,s3
    80004e78:	85ce                	mv	a1,s3
    80004e7a:	855a                	mv	a0,s6
    80004e7c:	ffffc097          	auipc	ra,0xffffc
    80004e80:	58e080e7          	jalr	1422(ra) # 8000140a <uvmalloc>
    80004e84:	892a                	mv	s2,a0
    80004e86:	e0a43423          	sd	a0,-504(s0)
    80004e8a:	e509                	bnez	a0,80004e94 <exec+0x236>
  if(pagetable)
    80004e8c:	e1343423          	sd	s3,-504(s0)
    80004e90:	4a01                	li	s4,0
    80004e92:	aa1d                	j	80004fc8 <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004e94:	75f9                	lui	a1,0xffffe
    80004e96:	95aa                	add	a1,a1,a0
    80004e98:	855a                	mv	a0,s6
    80004e9a:	ffffc097          	auipc	ra,0xffffc
    80004e9e:	79a080e7          	jalr	1946(ra) # 80001634 <uvmclear>
  stackbase = sp - PGSIZE;
    80004ea2:	7bfd                	lui	s7,0xfffff
    80004ea4:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004ea6:	e0043783          	ld	a5,-512(s0)
    80004eaa:	6388                	ld	a0,0(a5)
    80004eac:	c52d                	beqz	a0,80004f16 <exec+0x2b8>
    80004eae:	e9040993          	addi	s3,s0,-368
    80004eb2:	f9040c13          	addi	s8,s0,-112
    80004eb6:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004eb8:	ffffc097          	auipc	ra,0xffffc
    80004ebc:	f90080e7          	jalr	-112(ra) # 80000e48 <strlen>
    80004ec0:	0015079b          	addiw	a5,a0,1
    80004ec4:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004ec8:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004ecc:	13796563          	bltu	s2,s7,80004ff6 <exec+0x398>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ed0:	e0043d03          	ld	s10,-512(s0)
    80004ed4:	000d3a03          	ld	s4,0(s10)
    80004ed8:	8552                	mv	a0,s4
    80004eda:	ffffc097          	auipc	ra,0xffffc
    80004ede:	f6e080e7          	jalr	-146(ra) # 80000e48 <strlen>
    80004ee2:	0015069b          	addiw	a3,a0,1
    80004ee6:	8652                	mv	a2,s4
    80004ee8:	85ca                	mv	a1,s2
    80004eea:	855a                	mv	a0,s6
    80004eec:	ffffc097          	auipc	ra,0xffffc
    80004ef0:	77a080e7          	jalr	1914(ra) # 80001666 <copyout>
    80004ef4:	10054363          	bltz	a0,80004ffa <exec+0x39c>
    ustack[argc] = sp;
    80004ef8:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004efc:	0485                	addi	s1,s1,1
    80004efe:	008d0793          	addi	a5,s10,8
    80004f02:	e0f43023          	sd	a5,-512(s0)
    80004f06:	008d3503          	ld	a0,8(s10)
    80004f0a:	c909                	beqz	a0,80004f1c <exec+0x2be>
    if(argc >= MAXARG)
    80004f0c:	09a1                	addi	s3,s3,8
    80004f0e:	fb8995e3          	bne	s3,s8,80004eb8 <exec+0x25a>
  ip = 0;
    80004f12:	4a01                	li	s4,0
    80004f14:	a855                	j	80004fc8 <exec+0x36a>
  sp = sz;
    80004f16:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004f1a:	4481                	li	s1,0
  ustack[argc] = 0;
    80004f1c:	00349793          	slli	a5,s1,0x3
    80004f20:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdce50>
    80004f24:	97a2                	add	a5,a5,s0
    80004f26:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004f2a:	00148693          	addi	a3,s1,1
    80004f2e:	068e                	slli	a3,a3,0x3
    80004f30:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004f34:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004f38:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004f3c:	f57968e3          	bltu	s2,s7,80004e8c <exec+0x22e>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004f40:	e9040613          	addi	a2,s0,-368
    80004f44:	85ca                	mv	a1,s2
    80004f46:	855a                	mv	a0,s6
    80004f48:	ffffc097          	auipc	ra,0xffffc
    80004f4c:	71e080e7          	jalr	1822(ra) # 80001666 <copyout>
    80004f50:	0a054763          	bltz	a0,80004ffe <exec+0x3a0>
  p->trapframe->a1 = sp;
    80004f54:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004f58:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004f5c:	df843783          	ld	a5,-520(s0)
    80004f60:	0007c703          	lbu	a4,0(a5)
    80004f64:	cf11                	beqz	a4,80004f80 <exec+0x322>
    80004f66:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004f68:	02f00693          	li	a3,47
    80004f6c:	a039                	j	80004f7a <exec+0x31c>
      last = s+1;
    80004f6e:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004f72:	0785                	addi	a5,a5,1
    80004f74:	fff7c703          	lbu	a4,-1(a5)
    80004f78:	c701                	beqz	a4,80004f80 <exec+0x322>
    if(*s == '/')
    80004f7a:	fed71ce3          	bne	a4,a3,80004f72 <exec+0x314>
    80004f7e:	bfc5                	j	80004f6e <exec+0x310>
  safestrcpy(p->name, last, sizeof(p->name));
    80004f80:	4641                	li	a2,16
    80004f82:	df843583          	ld	a1,-520(s0)
    80004f86:	158a8513          	addi	a0,s5,344
    80004f8a:	ffffc097          	auipc	ra,0xffffc
    80004f8e:	e8c080e7          	jalr	-372(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    80004f92:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004f96:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004f9a:	e0843783          	ld	a5,-504(s0)
    80004f9e:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004fa2:	058ab783          	ld	a5,88(s5)
    80004fa6:	e6843703          	ld	a4,-408(s0)
    80004faa:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004fac:	058ab783          	ld	a5,88(s5)
    80004fb0:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004fb4:	85e6                	mv	a1,s9
    80004fb6:	ffffd097          	auipc	ra,0xffffd
    80004fba:	b50080e7          	jalr	-1200(ra) # 80001b06 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004fbe:	0004851b          	sext.w	a0,s1
    80004fc2:	bb15                	j	80004cf6 <exec+0x98>
    80004fc4:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80004fc8:	e0843583          	ld	a1,-504(s0)
    80004fcc:	855a                	mv	a0,s6
    80004fce:	ffffd097          	auipc	ra,0xffffd
    80004fd2:	b38080e7          	jalr	-1224(ra) # 80001b06 <proc_freepagetable>
  return -1;
    80004fd6:	557d                	li	a0,-1
  if(ip){
    80004fd8:	d00a0fe3          	beqz	s4,80004cf6 <exec+0x98>
    80004fdc:	b319                	j	80004ce2 <exec+0x84>
    80004fde:	e1243423          	sd	s2,-504(s0)
    80004fe2:	b7dd                	j	80004fc8 <exec+0x36a>
    80004fe4:	e1243423          	sd	s2,-504(s0)
    80004fe8:	b7c5                	j	80004fc8 <exec+0x36a>
    80004fea:	e1243423          	sd	s2,-504(s0)
    80004fee:	bfe9                	j	80004fc8 <exec+0x36a>
    80004ff0:	e1243423          	sd	s2,-504(s0)
    80004ff4:	bfd1                	j	80004fc8 <exec+0x36a>
  ip = 0;
    80004ff6:	4a01                	li	s4,0
    80004ff8:	bfc1                	j	80004fc8 <exec+0x36a>
    80004ffa:	4a01                	li	s4,0
  if(pagetable)
    80004ffc:	b7f1                	j	80004fc8 <exec+0x36a>
  sz = sz1;
    80004ffe:	e0843983          	ld	s3,-504(s0)
    80005002:	b569                	j	80004e8c <exec+0x22e>

0000000080005004 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005004:	7179                	addi	sp,sp,-48
    80005006:	f406                	sd	ra,40(sp)
    80005008:	f022                	sd	s0,32(sp)
    8000500a:	ec26                	sd	s1,24(sp)
    8000500c:	e84a                	sd	s2,16(sp)
    8000500e:	1800                	addi	s0,sp,48
    80005010:	892e                	mv	s2,a1
    80005012:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005014:	fdc40593          	addi	a1,s0,-36
    80005018:	ffffe097          	auipc	ra,0xffffe
    8000501c:	ab6080e7          	jalr	-1354(ra) # 80002ace <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005020:	fdc42703          	lw	a4,-36(s0)
    80005024:	47bd                	li	a5,15
    80005026:	02e7eb63          	bltu	a5,a4,8000505c <argfd+0x58>
    8000502a:	ffffd097          	auipc	ra,0xffffd
    8000502e:	97c080e7          	jalr	-1668(ra) # 800019a6 <myproc>
    80005032:	fdc42703          	lw	a4,-36(s0)
    80005036:	01a70793          	addi	a5,a4,26
    8000503a:	078e                	slli	a5,a5,0x3
    8000503c:	953e                	add	a0,a0,a5
    8000503e:	611c                	ld	a5,0(a0)
    80005040:	c385                	beqz	a5,80005060 <argfd+0x5c>
    return -1;
  if(pfd)
    80005042:	00090463          	beqz	s2,8000504a <argfd+0x46>
    *pfd = fd;
    80005046:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000504a:	4501                	li	a0,0
  if(pf)
    8000504c:	c091                	beqz	s1,80005050 <argfd+0x4c>
    *pf = f;
    8000504e:	e09c                	sd	a5,0(s1)
}
    80005050:	70a2                	ld	ra,40(sp)
    80005052:	7402                	ld	s0,32(sp)
    80005054:	64e2                	ld	s1,24(sp)
    80005056:	6942                	ld	s2,16(sp)
    80005058:	6145                	addi	sp,sp,48
    8000505a:	8082                	ret
    return -1;
    8000505c:	557d                	li	a0,-1
    8000505e:	bfcd                	j	80005050 <argfd+0x4c>
    80005060:	557d                	li	a0,-1
    80005062:	b7fd                	j	80005050 <argfd+0x4c>

0000000080005064 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005064:	1101                	addi	sp,sp,-32
    80005066:	ec06                	sd	ra,24(sp)
    80005068:	e822                	sd	s0,16(sp)
    8000506a:	e426                	sd	s1,8(sp)
    8000506c:	1000                	addi	s0,sp,32
    8000506e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005070:	ffffd097          	auipc	ra,0xffffd
    80005074:	936080e7          	jalr	-1738(ra) # 800019a6 <myproc>
    80005078:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000507a:	0d050793          	addi	a5,a0,208
    8000507e:	4501                	li	a0,0
    80005080:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005082:	6398                	ld	a4,0(a5)
    80005084:	cb19                	beqz	a4,8000509a <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005086:	2505                	addiw	a0,a0,1
    80005088:	07a1                	addi	a5,a5,8
    8000508a:	fed51ce3          	bne	a0,a3,80005082 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000508e:	557d                	li	a0,-1
}
    80005090:	60e2                	ld	ra,24(sp)
    80005092:	6442                	ld	s0,16(sp)
    80005094:	64a2                	ld	s1,8(sp)
    80005096:	6105                	addi	sp,sp,32
    80005098:	8082                	ret
      p->ofile[fd] = f;
    8000509a:	01a50793          	addi	a5,a0,26
    8000509e:	078e                	slli	a5,a5,0x3
    800050a0:	963e                	add	a2,a2,a5
    800050a2:	e204                	sd	s1,0(a2)
      return fd;
    800050a4:	b7f5                	j	80005090 <fdalloc+0x2c>

00000000800050a6 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800050a6:	715d                	addi	sp,sp,-80
    800050a8:	e486                	sd	ra,72(sp)
    800050aa:	e0a2                	sd	s0,64(sp)
    800050ac:	fc26                	sd	s1,56(sp)
    800050ae:	f84a                	sd	s2,48(sp)
    800050b0:	f44e                	sd	s3,40(sp)
    800050b2:	f052                	sd	s4,32(sp)
    800050b4:	ec56                	sd	s5,24(sp)
    800050b6:	e85a                	sd	s6,16(sp)
    800050b8:	0880                	addi	s0,sp,80
    800050ba:	8b2e                	mv	s6,a1
    800050bc:	89b2                	mv	s3,a2
    800050be:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800050c0:	fb040593          	addi	a1,s0,-80
    800050c4:	fffff097          	auipc	ra,0xfffff
    800050c8:	e7e080e7          	jalr	-386(ra) # 80003f42 <nameiparent>
    800050cc:	84aa                	mv	s1,a0
    800050ce:	14050b63          	beqz	a0,80005224 <create+0x17e>
    return 0;

  ilock(dp);
    800050d2:	ffffe097          	auipc	ra,0xffffe
    800050d6:	6ac080e7          	jalr	1708(ra) # 8000377e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800050da:	4601                	li	a2,0
    800050dc:	fb040593          	addi	a1,s0,-80
    800050e0:	8526                	mv	a0,s1
    800050e2:	fffff097          	auipc	ra,0xfffff
    800050e6:	b80080e7          	jalr	-1152(ra) # 80003c62 <dirlookup>
    800050ea:	8aaa                	mv	s5,a0
    800050ec:	c921                	beqz	a0,8000513c <create+0x96>
    iunlockput(dp);
    800050ee:	8526                	mv	a0,s1
    800050f0:	fffff097          	auipc	ra,0xfffff
    800050f4:	8f0080e7          	jalr	-1808(ra) # 800039e0 <iunlockput>
    ilock(ip);
    800050f8:	8556                	mv	a0,s5
    800050fa:	ffffe097          	auipc	ra,0xffffe
    800050fe:	684080e7          	jalr	1668(ra) # 8000377e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005102:	4789                	li	a5,2
    80005104:	02fb1563          	bne	s6,a5,8000512e <create+0x88>
    80005108:	044ad783          	lhu	a5,68(s5)
    8000510c:	37f9                	addiw	a5,a5,-2
    8000510e:	17c2                	slli	a5,a5,0x30
    80005110:	93c1                	srli	a5,a5,0x30
    80005112:	4705                	li	a4,1
    80005114:	00f76d63          	bltu	a4,a5,8000512e <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005118:	8556                	mv	a0,s5
    8000511a:	60a6                	ld	ra,72(sp)
    8000511c:	6406                	ld	s0,64(sp)
    8000511e:	74e2                	ld	s1,56(sp)
    80005120:	7942                	ld	s2,48(sp)
    80005122:	79a2                	ld	s3,40(sp)
    80005124:	7a02                	ld	s4,32(sp)
    80005126:	6ae2                	ld	s5,24(sp)
    80005128:	6b42                	ld	s6,16(sp)
    8000512a:	6161                	addi	sp,sp,80
    8000512c:	8082                	ret
    iunlockput(ip);
    8000512e:	8556                	mv	a0,s5
    80005130:	fffff097          	auipc	ra,0xfffff
    80005134:	8b0080e7          	jalr	-1872(ra) # 800039e0 <iunlockput>
    return 0;
    80005138:	4a81                	li	s5,0
    8000513a:	bff9                	j	80005118 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000513c:	85da                	mv	a1,s6
    8000513e:	4088                	lw	a0,0(s1)
    80005140:	ffffe097          	auipc	ra,0xffffe
    80005144:	4a6080e7          	jalr	1190(ra) # 800035e6 <ialloc>
    80005148:	8a2a                	mv	s4,a0
    8000514a:	c529                	beqz	a0,80005194 <create+0xee>
  ilock(ip);
    8000514c:	ffffe097          	auipc	ra,0xffffe
    80005150:	632080e7          	jalr	1586(ra) # 8000377e <ilock>
  ip->major = major;
    80005154:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005158:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000515c:	4905                	li	s2,1
    8000515e:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005162:	8552                	mv	a0,s4
    80005164:	ffffe097          	auipc	ra,0xffffe
    80005168:	54e080e7          	jalr	1358(ra) # 800036b2 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000516c:	032b0b63          	beq	s6,s2,800051a2 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005170:	004a2603          	lw	a2,4(s4)
    80005174:	fb040593          	addi	a1,s0,-80
    80005178:	8526                	mv	a0,s1
    8000517a:	fffff097          	auipc	ra,0xfffff
    8000517e:	cf8080e7          	jalr	-776(ra) # 80003e72 <dirlink>
    80005182:	06054f63          	bltz	a0,80005200 <create+0x15a>
  iunlockput(dp);
    80005186:	8526                	mv	a0,s1
    80005188:	fffff097          	auipc	ra,0xfffff
    8000518c:	858080e7          	jalr	-1960(ra) # 800039e0 <iunlockput>
  return ip;
    80005190:	8ad2                	mv	s5,s4
    80005192:	b759                	j	80005118 <create+0x72>
    iunlockput(dp);
    80005194:	8526                	mv	a0,s1
    80005196:	fffff097          	auipc	ra,0xfffff
    8000519a:	84a080e7          	jalr	-1974(ra) # 800039e0 <iunlockput>
    return 0;
    8000519e:	8ad2                	mv	s5,s4
    800051a0:	bfa5                	j	80005118 <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800051a2:	004a2603          	lw	a2,4(s4)
    800051a6:	00003597          	auipc	a1,0x3
    800051aa:	74258593          	addi	a1,a1,1858 # 800088e8 <syscall_names+0x2a0>
    800051ae:	8552                	mv	a0,s4
    800051b0:	fffff097          	auipc	ra,0xfffff
    800051b4:	cc2080e7          	jalr	-830(ra) # 80003e72 <dirlink>
    800051b8:	04054463          	bltz	a0,80005200 <create+0x15a>
    800051bc:	40d0                	lw	a2,4(s1)
    800051be:	00003597          	auipc	a1,0x3
    800051c2:	73258593          	addi	a1,a1,1842 # 800088f0 <syscall_names+0x2a8>
    800051c6:	8552                	mv	a0,s4
    800051c8:	fffff097          	auipc	ra,0xfffff
    800051cc:	caa080e7          	jalr	-854(ra) # 80003e72 <dirlink>
    800051d0:	02054863          	bltz	a0,80005200 <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    800051d4:	004a2603          	lw	a2,4(s4)
    800051d8:	fb040593          	addi	a1,s0,-80
    800051dc:	8526                	mv	a0,s1
    800051de:	fffff097          	auipc	ra,0xfffff
    800051e2:	c94080e7          	jalr	-876(ra) # 80003e72 <dirlink>
    800051e6:	00054d63          	bltz	a0,80005200 <create+0x15a>
    dp->nlink++;  // for ".."
    800051ea:	04a4d783          	lhu	a5,74(s1)
    800051ee:	2785                	addiw	a5,a5,1
    800051f0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800051f4:	8526                	mv	a0,s1
    800051f6:	ffffe097          	auipc	ra,0xffffe
    800051fa:	4bc080e7          	jalr	1212(ra) # 800036b2 <iupdate>
    800051fe:	b761                	j	80005186 <create+0xe0>
  ip->nlink = 0;
    80005200:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005204:	8552                	mv	a0,s4
    80005206:	ffffe097          	auipc	ra,0xffffe
    8000520a:	4ac080e7          	jalr	1196(ra) # 800036b2 <iupdate>
  iunlockput(ip);
    8000520e:	8552                	mv	a0,s4
    80005210:	ffffe097          	auipc	ra,0xffffe
    80005214:	7d0080e7          	jalr	2000(ra) # 800039e0 <iunlockput>
  iunlockput(dp);
    80005218:	8526                	mv	a0,s1
    8000521a:	ffffe097          	auipc	ra,0xffffe
    8000521e:	7c6080e7          	jalr	1990(ra) # 800039e0 <iunlockput>
  return 0;
    80005222:	bddd                	j	80005118 <create+0x72>
    return 0;
    80005224:	8aaa                	mv	s5,a0
    80005226:	bdcd                	j	80005118 <create+0x72>

0000000080005228 <sys_dup>:
{
    80005228:	7179                	addi	sp,sp,-48
    8000522a:	f406                	sd	ra,40(sp)
    8000522c:	f022                	sd	s0,32(sp)
    8000522e:	ec26                	sd	s1,24(sp)
    80005230:	e84a                	sd	s2,16(sp)
    80005232:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005234:	fd840613          	addi	a2,s0,-40
    80005238:	4581                	li	a1,0
    8000523a:	4501                	li	a0,0
    8000523c:	00000097          	auipc	ra,0x0
    80005240:	dc8080e7          	jalr	-568(ra) # 80005004 <argfd>
    return -1;
    80005244:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005246:	02054363          	bltz	a0,8000526c <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    8000524a:	fd843903          	ld	s2,-40(s0)
    8000524e:	854a                	mv	a0,s2
    80005250:	00000097          	auipc	ra,0x0
    80005254:	e14080e7          	jalr	-492(ra) # 80005064 <fdalloc>
    80005258:	84aa                	mv	s1,a0
    return -1;
    8000525a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000525c:	00054863          	bltz	a0,8000526c <sys_dup+0x44>
  filedup(f);
    80005260:	854a                	mv	a0,s2
    80005262:	fffff097          	auipc	ra,0xfffff
    80005266:	334080e7          	jalr	820(ra) # 80004596 <filedup>
  return fd;
    8000526a:	87a6                	mv	a5,s1
}
    8000526c:	853e                	mv	a0,a5
    8000526e:	70a2                	ld	ra,40(sp)
    80005270:	7402                	ld	s0,32(sp)
    80005272:	64e2                	ld	s1,24(sp)
    80005274:	6942                	ld	s2,16(sp)
    80005276:	6145                	addi	sp,sp,48
    80005278:	8082                	ret

000000008000527a <sys_read>:
{
    8000527a:	7179                	addi	sp,sp,-48
    8000527c:	f406                	sd	ra,40(sp)
    8000527e:	f022                	sd	s0,32(sp)
    80005280:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005282:	fd840593          	addi	a1,s0,-40
    80005286:	4505                	li	a0,1
    80005288:	ffffe097          	auipc	ra,0xffffe
    8000528c:	866080e7          	jalr	-1946(ra) # 80002aee <argaddr>
  argint(2, &n);
    80005290:	fe440593          	addi	a1,s0,-28
    80005294:	4509                	li	a0,2
    80005296:	ffffe097          	auipc	ra,0xffffe
    8000529a:	838080e7          	jalr	-1992(ra) # 80002ace <argint>
  if(argfd(0, 0, &f) < 0)
    8000529e:	fe840613          	addi	a2,s0,-24
    800052a2:	4581                	li	a1,0
    800052a4:	4501                	li	a0,0
    800052a6:	00000097          	auipc	ra,0x0
    800052aa:	d5e080e7          	jalr	-674(ra) # 80005004 <argfd>
    800052ae:	87aa                	mv	a5,a0
    return -1;
    800052b0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800052b2:	0007cc63          	bltz	a5,800052ca <sys_read+0x50>
  return fileread(f, p, n);
    800052b6:	fe442603          	lw	a2,-28(s0)
    800052ba:	fd843583          	ld	a1,-40(s0)
    800052be:	fe843503          	ld	a0,-24(s0)
    800052c2:	fffff097          	auipc	ra,0xfffff
    800052c6:	460080e7          	jalr	1120(ra) # 80004722 <fileread>
}
    800052ca:	70a2                	ld	ra,40(sp)
    800052cc:	7402                	ld	s0,32(sp)
    800052ce:	6145                	addi	sp,sp,48
    800052d0:	8082                	ret

00000000800052d2 <sys_write>:
{
    800052d2:	7179                	addi	sp,sp,-48
    800052d4:	f406                	sd	ra,40(sp)
    800052d6:	f022                	sd	s0,32(sp)
    800052d8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800052da:	fd840593          	addi	a1,s0,-40
    800052de:	4505                	li	a0,1
    800052e0:	ffffe097          	auipc	ra,0xffffe
    800052e4:	80e080e7          	jalr	-2034(ra) # 80002aee <argaddr>
  argint(2, &n);
    800052e8:	fe440593          	addi	a1,s0,-28
    800052ec:	4509                	li	a0,2
    800052ee:	ffffd097          	auipc	ra,0xffffd
    800052f2:	7e0080e7          	jalr	2016(ra) # 80002ace <argint>
  if(argfd(0, 0, &f) < 0)
    800052f6:	fe840613          	addi	a2,s0,-24
    800052fa:	4581                	li	a1,0
    800052fc:	4501                	li	a0,0
    800052fe:	00000097          	auipc	ra,0x0
    80005302:	d06080e7          	jalr	-762(ra) # 80005004 <argfd>
    80005306:	87aa                	mv	a5,a0
    return -1;
    80005308:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000530a:	0007cc63          	bltz	a5,80005322 <sys_write+0x50>
  return filewrite(f, p, n);
    8000530e:	fe442603          	lw	a2,-28(s0)
    80005312:	fd843583          	ld	a1,-40(s0)
    80005316:	fe843503          	ld	a0,-24(s0)
    8000531a:	fffff097          	auipc	ra,0xfffff
    8000531e:	4ca080e7          	jalr	1226(ra) # 800047e4 <filewrite>
}
    80005322:	70a2                	ld	ra,40(sp)
    80005324:	7402                	ld	s0,32(sp)
    80005326:	6145                	addi	sp,sp,48
    80005328:	8082                	ret

000000008000532a <sys_close>:
{
    8000532a:	1101                	addi	sp,sp,-32
    8000532c:	ec06                	sd	ra,24(sp)
    8000532e:	e822                	sd	s0,16(sp)
    80005330:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005332:	fe040613          	addi	a2,s0,-32
    80005336:	fec40593          	addi	a1,s0,-20
    8000533a:	4501                	li	a0,0
    8000533c:	00000097          	auipc	ra,0x0
    80005340:	cc8080e7          	jalr	-824(ra) # 80005004 <argfd>
    return -1;
    80005344:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005346:	02054463          	bltz	a0,8000536e <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000534a:	ffffc097          	auipc	ra,0xffffc
    8000534e:	65c080e7          	jalr	1628(ra) # 800019a6 <myproc>
    80005352:	fec42783          	lw	a5,-20(s0)
    80005356:	07e9                	addi	a5,a5,26
    80005358:	078e                	slli	a5,a5,0x3
    8000535a:	953e                	add	a0,a0,a5
    8000535c:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005360:	fe043503          	ld	a0,-32(s0)
    80005364:	fffff097          	auipc	ra,0xfffff
    80005368:	284080e7          	jalr	644(ra) # 800045e8 <fileclose>
  return 0;
    8000536c:	4781                	li	a5,0
}
    8000536e:	853e                	mv	a0,a5
    80005370:	60e2                	ld	ra,24(sp)
    80005372:	6442                	ld	s0,16(sp)
    80005374:	6105                	addi	sp,sp,32
    80005376:	8082                	ret

0000000080005378 <sys_fstat>:
{
    80005378:	1101                	addi	sp,sp,-32
    8000537a:	ec06                	sd	ra,24(sp)
    8000537c:	e822                	sd	s0,16(sp)
    8000537e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005380:	fe040593          	addi	a1,s0,-32
    80005384:	4505                	li	a0,1
    80005386:	ffffd097          	auipc	ra,0xffffd
    8000538a:	768080e7          	jalr	1896(ra) # 80002aee <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000538e:	fe840613          	addi	a2,s0,-24
    80005392:	4581                	li	a1,0
    80005394:	4501                	li	a0,0
    80005396:	00000097          	auipc	ra,0x0
    8000539a:	c6e080e7          	jalr	-914(ra) # 80005004 <argfd>
    8000539e:	87aa                	mv	a5,a0
    return -1;
    800053a0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800053a2:	0007ca63          	bltz	a5,800053b6 <sys_fstat+0x3e>
  return filestat(f, st);
    800053a6:	fe043583          	ld	a1,-32(s0)
    800053aa:	fe843503          	ld	a0,-24(s0)
    800053ae:	fffff097          	auipc	ra,0xfffff
    800053b2:	302080e7          	jalr	770(ra) # 800046b0 <filestat>
}
    800053b6:	60e2                	ld	ra,24(sp)
    800053b8:	6442                	ld	s0,16(sp)
    800053ba:	6105                	addi	sp,sp,32
    800053bc:	8082                	ret

00000000800053be <sys_link>:
{
    800053be:	7169                	addi	sp,sp,-304
    800053c0:	f606                	sd	ra,296(sp)
    800053c2:	f222                	sd	s0,288(sp)
    800053c4:	ee26                	sd	s1,280(sp)
    800053c6:	ea4a                	sd	s2,272(sp)
    800053c8:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053ca:	08000613          	li	a2,128
    800053ce:	ed040593          	addi	a1,s0,-304
    800053d2:	4501                	li	a0,0
    800053d4:	ffffd097          	auipc	ra,0xffffd
    800053d8:	73a080e7          	jalr	1850(ra) # 80002b0e <argstr>
    return -1;
    800053dc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053de:	10054e63          	bltz	a0,800054fa <sys_link+0x13c>
    800053e2:	08000613          	li	a2,128
    800053e6:	f5040593          	addi	a1,s0,-176
    800053ea:	4505                	li	a0,1
    800053ec:	ffffd097          	auipc	ra,0xffffd
    800053f0:	722080e7          	jalr	1826(ra) # 80002b0e <argstr>
    return -1;
    800053f4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053f6:	10054263          	bltz	a0,800054fa <sys_link+0x13c>
  begin_op();
    800053fa:	fffff097          	auipc	ra,0xfffff
    800053fe:	d2a080e7          	jalr	-726(ra) # 80004124 <begin_op>
  if((ip = namei(old)) == 0){
    80005402:	ed040513          	addi	a0,s0,-304
    80005406:	fffff097          	auipc	ra,0xfffff
    8000540a:	b1e080e7          	jalr	-1250(ra) # 80003f24 <namei>
    8000540e:	84aa                	mv	s1,a0
    80005410:	c551                	beqz	a0,8000549c <sys_link+0xde>
  ilock(ip);
    80005412:	ffffe097          	auipc	ra,0xffffe
    80005416:	36c080e7          	jalr	876(ra) # 8000377e <ilock>
  if(ip->type == T_DIR){
    8000541a:	04449703          	lh	a4,68(s1)
    8000541e:	4785                	li	a5,1
    80005420:	08f70463          	beq	a4,a5,800054a8 <sys_link+0xea>
  ip->nlink++;
    80005424:	04a4d783          	lhu	a5,74(s1)
    80005428:	2785                	addiw	a5,a5,1
    8000542a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000542e:	8526                	mv	a0,s1
    80005430:	ffffe097          	auipc	ra,0xffffe
    80005434:	282080e7          	jalr	642(ra) # 800036b2 <iupdate>
  iunlock(ip);
    80005438:	8526                	mv	a0,s1
    8000543a:	ffffe097          	auipc	ra,0xffffe
    8000543e:	406080e7          	jalr	1030(ra) # 80003840 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005442:	fd040593          	addi	a1,s0,-48
    80005446:	f5040513          	addi	a0,s0,-176
    8000544a:	fffff097          	auipc	ra,0xfffff
    8000544e:	af8080e7          	jalr	-1288(ra) # 80003f42 <nameiparent>
    80005452:	892a                	mv	s2,a0
    80005454:	c935                	beqz	a0,800054c8 <sys_link+0x10a>
  ilock(dp);
    80005456:	ffffe097          	auipc	ra,0xffffe
    8000545a:	328080e7          	jalr	808(ra) # 8000377e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000545e:	00092703          	lw	a4,0(s2)
    80005462:	409c                	lw	a5,0(s1)
    80005464:	04f71d63          	bne	a4,a5,800054be <sys_link+0x100>
    80005468:	40d0                	lw	a2,4(s1)
    8000546a:	fd040593          	addi	a1,s0,-48
    8000546e:	854a                	mv	a0,s2
    80005470:	fffff097          	auipc	ra,0xfffff
    80005474:	a02080e7          	jalr	-1534(ra) # 80003e72 <dirlink>
    80005478:	04054363          	bltz	a0,800054be <sys_link+0x100>
  iunlockput(dp);
    8000547c:	854a                	mv	a0,s2
    8000547e:	ffffe097          	auipc	ra,0xffffe
    80005482:	562080e7          	jalr	1378(ra) # 800039e0 <iunlockput>
  iput(ip);
    80005486:	8526                	mv	a0,s1
    80005488:	ffffe097          	auipc	ra,0xffffe
    8000548c:	4b0080e7          	jalr	1200(ra) # 80003938 <iput>
  end_op();
    80005490:	fffff097          	auipc	ra,0xfffff
    80005494:	d0e080e7          	jalr	-754(ra) # 8000419e <end_op>
  return 0;
    80005498:	4781                	li	a5,0
    8000549a:	a085                	j	800054fa <sys_link+0x13c>
    end_op();
    8000549c:	fffff097          	auipc	ra,0xfffff
    800054a0:	d02080e7          	jalr	-766(ra) # 8000419e <end_op>
    return -1;
    800054a4:	57fd                	li	a5,-1
    800054a6:	a891                	j	800054fa <sys_link+0x13c>
    iunlockput(ip);
    800054a8:	8526                	mv	a0,s1
    800054aa:	ffffe097          	auipc	ra,0xffffe
    800054ae:	536080e7          	jalr	1334(ra) # 800039e0 <iunlockput>
    end_op();
    800054b2:	fffff097          	auipc	ra,0xfffff
    800054b6:	cec080e7          	jalr	-788(ra) # 8000419e <end_op>
    return -1;
    800054ba:	57fd                	li	a5,-1
    800054bc:	a83d                	j	800054fa <sys_link+0x13c>
    iunlockput(dp);
    800054be:	854a                	mv	a0,s2
    800054c0:	ffffe097          	auipc	ra,0xffffe
    800054c4:	520080e7          	jalr	1312(ra) # 800039e0 <iunlockput>
  ilock(ip);
    800054c8:	8526                	mv	a0,s1
    800054ca:	ffffe097          	auipc	ra,0xffffe
    800054ce:	2b4080e7          	jalr	692(ra) # 8000377e <ilock>
  ip->nlink--;
    800054d2:	04a4d783          	lhu	a5,74(s1)
    800054d6:	37fd                	addiw	a5,a5,-1
    800054d8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800054dc:	8526                	mv	a0,s1
    800054de:	ffffe097          	auipc	ra,0xffffe
    800054e2:	1d4080e7          	jalr	468(ra) # 800036b2 <iupdate>
  iunlockput(ip);
    800054e6:	8526                	mv	a0,s1
    800054e8:	ffffe097          	auipc	ra,0xffffe
    800054ec:	4f8080e7          	jalr	1272(ra) # 800039e0 <iunlockput>
  end_op();
    800054f0:	fffff097          	auipc	ra,0xfffff
    800054f4:	cae080e7          	jalr	-850(ra) # 8000419e <end_op>
  return -1;
    800054f8:	57fd                	li	a5,-1
}
    800054fa:	853e                	mv	a0,a5
    800054fc:	70b2                	ld	ra,296(sp)
    800054fe:	7412                	ld	s0,288(sp)
    80005500:	64f2                	ld	s1,280(sp)
    80005502:	6952                	ld	s2,272(sp)
    80005504:	6155                	addi	sp,sp,304
    80005506:	8082                	ret

0000000080005508 <sys_unlink>:
{
    80005508:	7151                	addi	sp,sp,-240
    8000550a:	f586                	sd	ra,232(sp)
    8000550c:	f1a2                	sd	s0,224(sp)
    8000550e:	eda6                	sd	s1,216(sp)
    80005510:	e9ca                	sd	s2,208(sp)
    80005512:	e5ce                	sd	s3,200(sp)
    80005514:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005516:	08000613          	li	a2,128
    8000551a:	f3040593          	addi	a1,s0,-208
    8000551e:	4501                	li	a0,0
    80005520:	ffffd097          	auipc	ra,0xffffd
    80005524:	5ee080e7          	jalr	1518(ra) # 80002b0e <argstr>
    80005528:	18054163          	bltz	a0,800056aa <sys_unlink+0x1a2>
  begin_op();
    8000552c:	fffff097          	auipc	ra,0xfffff
    80005530:	bf8080e7          	jalr	-1032(ra) # 80004124 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005534:	fb040593          	addi	a1,s0,-80
    80005538:	f3040513          	addi	a0,s0,-208
    8000553c:	fffff097          	auipc	ra,0xfffff
    80005540:	a06080e7          	jalr	-1530(ra) # 80003f42 <nameiparent>
    80005544:	84aa                	mv	s1,a0
    80005546:	c979                	beqz	a0,8000561c <sys_unlink+0x114>
  ilock(dp);
    80005548:	ffffe097          	auipc	ra,0xffffe
    8000554c:	236080e7          	jalr	566(ra) # 8000377e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005550:	00003597          	auipc	a1,0x3
    80005554:	39858593          	addi	a1,a1,920 # 800088e8 <syscall_names+0x2a0>
    80005558:	fb040513          	addi	a0,s0,-80
    8000555c:	ffffe097          	auipc	ra,0xffffe
    80005560:	6ec080e7          	jalr	1772(ra) # 80003c48 <namecmp>
    80005564:	14050a63          	beqz	a0,800056b8 <sys_unlink+0x1b0>
    80005568:	00003597          	auipc	a1,0x3
    8000556c:	38858593          	addi	a1,a1,904 # 800088f0 <syscall_names+0x2a8>
    80005570:	fb040513          	addi	a0,s0,-80
    80005574:	ffffe097          	auipc	ra,0xffffe
    80005578:	6d4080e7          	jalr	1748(ra) # 80003c48 <namecmp>
    8000557c:	12050e63          	beqz	a0,800056b8 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005580:	f2c40613          	addi	a2,s0,-212
    80005584:	fb040593          	addi	a1,s0,-80
    80005588:	8526                	mv	a0,s1
    8000558a:	ffffe097          	auipc	ra,0xffffe
    8000558e:	6d8080e7          	jalr	1752(ra) # 80003c62 <dirlookup>
    80005592:	892a                	mv	s2,a0
    80005594:	12050263          	beqz	a0,800056b8 <sys_unlink+0x1b0>
  ilock(ip);
    80005598:	ffffe097          	auipc	ra,0xffffe
    8000559c:	1e6080e7          	jalr	486(ra) # 8000377e <ilock>
  if(ip->nlink < 1)
    800055a0:	04a91783          	lh	a5,74(s2)
    800055a4:	08f05263          	blez	a5,80005628 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800055a8:	04491703          	lh	a4,68(s2)
    800055ac:	4785                	li	a5,1
    800055ae:	08f70563          	beq	a4,a5,80005638 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800055b2:	4641                	li	a2,16
    800055b4:	4581                	li	a1,0
    800055b6:	fc040513          	addi	a0,s0,-64
    800055ba:	ffffb097          	auipc	ra,0xffffb
    800055be:	714080e7          	jalr	1812(ra) # 80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055c2:	4741                	li	a4,16
    800055c4:	f2c42683          	lw	a3,-212(s0)
    800055c8:	fc040613          	addi	a2,s0,-64
    800055cc:	4581                	li	a1,0
    800055ce:	8526                	mv	a0,s1
    800055d0:	ffffe097          	auipc	ra,0xffffe
    800055d4:	55a080e7          	jalr	1370(ra) # 80003b2a <writei>
    800055d8:	47c1                	li	a5,16
    800055da:	0af51563          	bne	a0,a5,80005684 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800055de:	04491703          	lh	a4,68(s2)
    800055e2:	4785                	li	a5,1
    800055e4:	0af70863          	beq	a4,a5,80005694 <sys_unlink+0x18c>
  iunlockput(dp);
    800055e8:	8526                	mv	a0,s1
    800055ea:	ffffe097          	auipc	ra,0xffffe
    800055ee:	3f6080e7          	jalr	1014(ra) # 800039e0 <iunlockput>
  ip->nlink--;
    800055f2:	04a95783          	lhu	a5,74(s2)
    800055f6:	37fd                	addiw	a5,a5,-1
    800055f8:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800055fc:	854a                	mv	a0,s2
    800055fe:	ffffe097          	auipc	ra,0xffffe
    80005602:	0b4080e7          	jalr	180(ra) # 800036b2 <iupdate>
  iunlockput(ip);
    80005606:	854a                	mv	a0,s2
    80005608:	ffffe097          	auipc	ra,0xffffe
    8000560c:	3d8080e7          	jalr	984(ra) # 800039e0 <iunlockput>
  end_op();
    80005610:	fffff097          	auipc	ra,0xfffff
    80005614:	b8e080e7          	jalr	-1138(ra) # 8000419e <end_op>
  return 0;
    80005618:	4501                	li	a0,0
    8000561a:	a84d                	j	800056cc <sys_unlink+0x1c4>
    end_op();
    8000561c:	fffff097          	auipc	ra,0xfffff
    80005620:	b82080e7          	jalr	-1150(ra) # 8000419e <end_op>
    return -1;
    80005624:	557d                	li	a0,-1
    80005626:	a05d                	j	800056cc <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005628:	00003517          	auipc	a0,0x3
    8000562c:	2d050513          	addi	a0,a0,720 # 800088f8 <syscall_names+0x2b0>
    80005630:	ffffb097          	auipc	ra,0xffffb
    80005634:	f0c080e7          	jalr	-244(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005638:	04c92703          	lw	a4,76(s2)
    8000563c:	02000793          	li	a5,32
    80005640:	f6e7f9e3          	bgeu	a5,a4,800055b2 <sys_unlink+0xaa>
    80005644:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005648:	4741                	li	a4,16
    8000564a:	86ce                	mv	a3,s3
    8000564c:	f1840613          	addi	a2,s0,-232
    80005650:	4581                	li	a1,0
    80005652:	854a                	mv	a0,s2
    80005654:	ffffe097          	auipc	ra,0xffffe
    80005658:	3de080e7          	jalr	990(ra) # 80003a32 <readi>
    8000565c:	47c1                	li	a5,16
    8000565e:	00f51b63          	bne	a0,a5,80005674 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005662:	f1845783          	lhu	a5,-232(s0)
    80005666:	e7a1                	bnez	a5,800056ae <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005668:	29c1                	addiw	s3,s3,16
    8000566a:	04c92783          	lw	a5,76(s2)
    8000566e:	fcf9ede3          	bltu	s3,a5,80005648 <sys_unlink+0x140>
    80005672:	b781                	j	800055b2 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005674:	00003517          	auipc	a0,0x3
    80005678:	29c50513          	addi	a0,a0,668 # 80008910 <syscall_names+0x2c8>
    8000567c:	ffffb097          	auipc	ra,0xffffb
    80005680:	ec0080e7          	jalr	-320(ra) # 8000053c <panic>
    panic("unlink: writei");
    80005684:	00003517          	auipc	a0,0x3
    80005688:	2a450513          	addi	a0,a0,676 # 80008928 <syscall_names+0x2e0>
    8000568c:	ffffb097          	auipc	ra,0xffffb
    80005690:	eb0080e7          	jalr	-336(ra) # 8000053c <panic>
    dp->nlink--;
    80005694:	04a4d783          	lhu	a5,74(s1)
    80005698:	37fd                	addiw	a5,a5,-1
    8000569a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000569e:	8526                	mv	a0,s1
    800056a0:	ffffe097          	auipc	ra,0xffffe
    800056a4:	012080e7          	jalr	18(ra) # 800036b2 <iupdate>
    800056a8:	b781                	j	800055e8 <sys_unlink+0xe0>
    return -1;
    800056aa:	557d                	li	a0,-1
    800056ac:	a005                	j	800056cc <sys_unlink+0x1c4>
    iunlockput(ip);
    800056ae:	854a                	mv	a0,s2
    800056b0:	ffffe097          	auipc	ra,0xffffe
    800056b4:	330080e7          	jalr	816(ra) # 800039e0 <iunlockput>
  iunlockput(dp);
    800056b8:	8526                	mv	a0,s1
    800056ba:	ffffe097          	auipc	ra,0xffffe
    800056be:	326080e7          	jalr	806(ra) # 800039e0 <iunlockput>
  end_op();
    800056c2:	fffff097          	auipc	ra,0xfffff
    800056c6:	adc080e7          	jalr	-1316(ra) # 8000419e <end_op>
  return -1;
    800056ca:	557d                	li	a0,-1
}
    800056cc:	70ae                	ld	ra,232(sp)
    800056ce:	740e                	ld	s0,224(sp)
    800056d0:	64ee                	ld	s1,216(sp)
    800056d2:	694e                	ld	s2,208(sp)
    800056d4:	69ae                	ld	s3,200(sp)
    800056d6:	616d                	addi	sp,sp,240
    800056d8:	8082                	ret

00000000800056da <sys_open>:

uint64
sys_open(void)
{
    800056da:	7131                	addi	sp,sp,-192
    800056dc:	fd06                	sd	ra,184(sp)
    800056de:	f922                	sd	s0,176(sp)
    800056e0:	f526                	sd	s1,168(sp)
    800056e2:	f14a                	sd	s2,160(sp)
    800056e4:	ed4e                	sd	s3,152(sp)
    800056e6:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800056e8:	f4c40593          	addi	a1,s0,-180
    800056ec:	4505                	li	a0,1
    800056ee:	ffffd097          	auipc	ra,0xffffd
    800056f2:	3e0080e7          	jalr	992(ra) # 80002ace <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800056f6:	08000613          	li	a2,128
    800056fa:	f5040593          	addi	a1,s0,-176
    800056fe:	4501                	li	a0,0
    80005700:	ffffd097          	auipc	ra,0xffffd
    80005704:	40e080e7          	jalr	1038(ra) # 80002b0e <argstr>
    80005708:	87aa                	mv	a5,a0
    return -1;
    8000570a:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000570c:	0a07c863          	bltz	a5,800057bc <sys_open+0xe2>

  begin_op();
    80005710:	fffff097          	auipc	ra,0xfffff
    80005714:	a14080e7          	jalr	-1516(ra) # 80004124 <begin_op>

  if(omode & O_CREATE){
    80005718:	f4c42783          	lw	a5,-180(s0)
    8000571c:	2007f793          	andi	a5,a5,512
    80005720:	cbdd                	beqz	a5,800057d6 <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    80005722:	4681                	li	a3,0
    80005724:	4601                	li	a2,0
    80005726:	4589                	li	a1,2
    80005728:	f5040513          	addi	a0,s0,-176
    8000572c:	00000097          	auipc	ra,0x0
    80005730:	97a080e7          	jalr	-1670(ra) # 800050a6 <create>
    80005734:	84aa                	mv	s1,a0
    if(ip == 0){
    80005736:	c951                	beqz	a0,800057ca <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005738:	04449703          	lh	a4,68(s1)
    8000573c:	478d                	li	a5,3
    8000573e:	00f71763          	bne	a4,a5,8000574c <sys_open+0x72>
    80005742:	0464d703          	lhu	a4,70(s1)
    80005746:	47a5                	li	a5,9
    80005748:	0ce7ec63          	bltu	a5,a4,80005820 <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000574c:	fffff097          	auipc	ra,0xfffff
    80005750:	de0080e7          	jalr	-544(ra) # 8000452c <filealloc>
    80005754:	892a                	mv	s2,a0
    80005756:	c56d                	beqz	a0,80005840 <sys_open+0x166>
    80005758:	00000097          	auipc	ra,0x0
    8000575c:	90c080e7          	jalr	-1780(ra) # 80005064 <fdalloc>
    80005760:	89aa                	mv	s3,a0
    80005762:	0c054a63          	bltz	a0,80005836 <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005766:	04449703          	lh	a4,68(s1)
    8000576a:	478d                	li	a5,3
    8000576c:	0ef70563          	beq	a4,a5,80005856 <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005770:	4789                	li	a5,2
    80005772:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005776:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000577a:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000577e:	f4c42783          	lw	a5,-180(s0)
    80005782:	0017c713          	xori	a4,a5,1
    80005786:	8b05                	andi	a4,a4,1
    80005788:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000578c:	0037f713          	andi	a4,a5,3
    80005790:	00e03733          	snez	a4,a4
    80005794:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005798:	4007f793          	andi	a5,a5,1024
    8000579c:	c791                	beqz	a5,800057a8 <sys_open+0xce>
    8000579e:	04449703          	lh	a4,68(s1)
    800057a2:	4789                	li	a5,2
    800057a4:	0cf70063          	beq	a4,a5,80005864 <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    800057a8:	8526                	mv	a0,s1
    800057aa:	ffffe097          	auipc	ra,0xffffe
    800057ae:	096080e7          	jalr	150(ra) # 80003840 <iunlock>
  end_op();
    800057b2:	fffff097          	auipc	ra,0xfffff
    800057b6:	9ec080e7          	jalr	-1556(ra) # 8000419e <end_op>

  return fd;
    800057ba:	854e                	mv	a0,s3
}
    800057bc:	70ea                	ld	ra,184(sp)
    800057be:	744a                	ld	s0,176(sp)
    800057c0:	74aa                	ld	s1,168(sp)
    800057c2:	790a                	ld	s2,160(sp)
    800057c4:	69ea                	ld	s3,152(sp)
    800057c6:	6129                	addi	sp,sp,192
    800057c8:	8082                	ret
      end_op();
    800057ca:	fffff097          	auipc	ra,0xfffff
    800057ce:	9d4080e7          	jalr	-1580(ra) # 8000419e <end_op>
      return -1;
    800057d2:	557d                	li	a0,-1
    800057d4:	b7e5                	j	800057bc <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    800057d6:	f5040513          	addi	a0,s0,-176
    800057da:	ffffe097          	auipc	ra,0xffffe
    800057de:	74a080e7          	jalr	1866(ra) # 80003f24 <namei>
    800057e2:	84aa                	mv	s1,a0
    800057e4:	c905                	beqz	a0,80005814 <sys_open+0x13a>
    ilock(ip);
    800057e6:	ffffe097          	auipc	ra,0xffffe
    800057ea:	f98080e7          	jalr	-104(ra) # 8000377e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800057ee:	04449703          	lh	a4,68(s1)
    800057f2:	4785                	li	a5,1
    800057f4:	f4f712e3          	bne	a4,a5,80005738 <sys_open+0x5e>
    800057f8:	f4c42783          	lw	a5,-180(s0)
    800057fc:	dba1                	beqz	a5,8000574c <sys_open+0x72>
      iunlockput(ip);
    800057fe:	8526                	mv	a0,s1
    80005800:	ffffe097          	auipc	ra,0xffffe
    80005804:	1e0080e7          	jalr	480(ra) # 800039e0 <iunlockput>
      end_op();
    80005808:	fffff097          	auipc	ra,0xfffff
    8000580c:	996080e7          	jalr	-1642(ra) # 8000419e <end_op>
      return -1;
    80005810:	557d                	li	a0,-1
    80005812:	b76d                	j	800057bc <sys_open+0xe2>
      end_op();
    80005814:	fffff097          	auipc	ra,0xfffff
    80005818:	98a080e7          	jalr	-1654(ra) # 8000419e <end_op>
      return -1;
    8000581c:	557d                	li	a0,-1
    8000581e:	bf79                	j	800057bc <sys_open+0xe2>
    iunlockput(ip);
    80005820:	8526                	mv	a0,s1
    80005822:	ffffe097          	auipc	ra,0xffffe
    80005826:	1be080e7          	jalr	446(ra) # 800039e0 <iunlockput>
    end_op();
    8000582a:	fffff097          	auipc	ra,0xfffff
    8000582e:	974080e7          	jalr	-1676(ra) # 8000419e <end_op>
    return -1;
    80005832:	557d                	li	a0,-1
    80005834:	b761                	j	800057bc <sys_open+0xe2>
      fileclose(f);
    80005836:	854a                	mv	a0,s2
    80005838:	fffff097          	auipc	ra,0xfffff
    8000583c:	db0080e7          	jalr	-592(ra) # 800045e8 <fileclose>
    iunlockput(ip);
    80005840:	8526                	mv	a0,s1
    80005842:	ffffe097          	auipc	ra,0xffffe
    80005846:	19e080e7          	jalr	414(ra) # 800039e0 <iunlockput>
    end_op();
    8000584a:	fffff097          	auipc	ra,0xfffff
    8000584e:	954080e7          	jalr	-1708(ra) # 8000419e <end_op>
    return -1;
    80005852:	557d                	li	a0,-1
    80005854:	b7a5                	j	800057bc <sys_open+0xe2>
    f->type = FD_DEVICE;
    80005856:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    8000585a:	04649783          	lh	a5,70(s1)
    8000585e:	02f91223          	sh	a5,36(s2)
    80005862:	bf21                	j	8000577a <sys_open+0xa0>
    itrunc(ip);
    80005864:	8526                	mv	a0,s1
    80005866:	ffffe097          	auipc	ra,0xffffe
    8000586a:	026080e7          	jalr	38(ra) # 8000388c <itrunc>
    8000586e:	bf2d                	j	800057a8 <sys_open+0xce>

0000000080005870 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005870:	7175                	addi	sp,sp,-144
    80005872:	e506                	sd	ra,136(sp)
    80005874:	e122                	sd	s0,128(sp)
    80005876:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005878:	fffff097          	auipc	ra,0xfffff
    8000587c:	8ac080e7          	jalr	-1876(ra) # 80004124 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005880:	08000613          	li	a2,128
    80005884:	f7040593          	addi	a1,s0,-144
    80005888:	4501                	li	a0,0
    8000588a:	ffffd097          	auipc	ra,0xffffd
    8000588e:	284080e7          	jalr	644(ra) # 80002b0e <argstr>
    80005892:	02054963          	bltz	a0,800058c4 <sys_mkdir+0x54>
    80005896:	4681                	li	a3,0
    80005898:	4601                	li	a2,0
    8000589a:	4585                	li	a1,1
    8000589c:	f7040513          	addi	a0,s0,-144
    800058a0:	00000097          	auipc	ra,0x0
    800058a4:	806080e7          	jalr	-2042(ra) # 800050a6 <create>
    800058a8:	cd11                	beqz	a0,800058c4 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800058aa:	ffffe097          	auipc	ra,0xffffe
    800058ae:	136080e7          	jalr	310(ra) # 800039e0 <iunlockput>
  end_op();
    800058b2:	fffff097          	auipc	ra,0xfffff
    800058b6:	8ec080e7          	jalr	-1812(ra) # 8000419e <end_op>
  return 0;
    800058ba:	4501                	li	a0,0
}
    800058bc:	60aa                	ld	ra,136(sp)
    800058be:	640a                	ld	s0,128(sp)
    800058c0:	6149                	addi	sp,sp,144
    800058c2:	8082                	ret
    end_op();
    800058c4:	fffff097          	auipc	ra,0xfffff
    800058c8:	8da080e7          	jalr	-1830(ra) # 8000419e <end_op>
    return -1;
    800058cc:	557d                	li	a0,-1
    800058ce:	b7fd                	j	800058bc <sys_mkdir+0x4c>

00000000800058d0 <sys_mknod>:

uint64
sys_mknod(void)
{
    800058d0:	7135                	addi	sp,sp,-160
    800058d2:	ed06                	sd	ra,152(sp)
    800058d4:	e922                	sd	s0,144(sp)
    800058d6:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800058d8:	fffff097          	auipc	ra,0xfffff
    800058dc:	84c080e7          	jalr	-1972(ra) # 80004124 <begin_op>
  argint(1, &major);
    800058e0:	f6c40593          	addi	a1,s0,-148
    800058e4:	4505                	li	a0,1
    800058e6:	ffffd097          	auipc	ra,0xffffd
    800058ea:	1e8080e7          	jalr	488(ra) # 80002ace <argint>
  argint(2, &minor);
    800058ee:	f6840593          	addi	a1,s0,-152
    800058f2:	4509                	li	a0,2
    800058f4:	ffffd097          	auipc	ra,0xffffd
    800058f8:	1da080e7          	jalr	474(ra) # 80002ace <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800058fc:	08000613          	li	a2,128
    80005900:	f7040593          	addi	a1,s0,-144
    80005904:	4501                	li	a0,0
    80005906:	ffffd097          	auipc	ra,0xffffd
    8000590a:	208080e7          	jalr	520(ra) # 80002b0e <argstr>
    8000590e:	02054b63          	bltz	a0,80005944 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005912:	f6841683          	lh	a3,-152(s0)
    80005916:	f6c41603          	lh	a2,-148(s0)
    8000591a:	458d                	li	a1,3
    8000591c:	f7040513          	addi	a0,s0,-144
    80005920:	fffff097          	auipc	ra,0xfffff
    80005924:	786080e7          	jalr	1926(ra) # 800050a6 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005928:	cd11                	beqz	a0,80005944 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000592a:	ffffe097          	auipc	ra,0xffffe
    8000592e:	0b6080e7          	jalr	182(ra) # 800039e0 <iunlockput>
  end_op();
    80005932:	fffff097          	auipc	ra,0xfffff
    80005936:	86c080e7          	jalr	-1940(ra) # 8000419e <end_op>
  return 0;
    8000593a:	4501                	li	a0,0
}
    8000593c:	60ea                	ld	ra,152(sp)
    8000593e:	644a                	ld	s0,144(sp)
    80005940:	610d                	addi	sp,sp,160
    80005942:	8082                	ret
    end_op();
    80005944:	fffff097          	auipc	ra,0xfffff
    80005948:	85a080e7          	jalr	-1958(ra) # 8000419e <end_op>
    return -1;
    8000594c:	557d                	li	a0,-1
    8000594e:	b7fd                	j	8000593c <sys_mknod+0x6c>

0000000080005950 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005950:	7135                	addi	sp,sp,-160
    80005952:	ed06                	sd	ra,152(sp)
    80005954:	e922                	sd	s0,144(sp)
    80005956:	e526                	sd	s1,136(sp)
    80005958:	e14a                	sd	s2,128(sp)
    8000595a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000595c:	ffffc097          	auipc	ra,0xffffc
    80005960:	04a080e7          	jalr	74(ra) # 800019a6 <myproc>
    80005964:	892a                	mv	s2,a0
  
  begin_op();
    80005966:	ffffe097          	auipc	ra,0xffffe
    8000596a:	7be080e7          	jalr	1982(ra) # 80004124 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000596e:	08000613          	li	a2,128
    80005972:	f6040593          	addi	a1,s0,-160
    80005976:	4501                	li	a0,0
    80005978:	ffffd097          	auipc	ra,0xffffd
    8000597c:	196080e7          	jalr	406(ra) # 80002b0e <argstr>
    80005980:	04054b63          	bltz	a0,800059d6 <sys_chdir+0x86>
    80005984:	f6040513          	addi	a0,s0,-160
    80005988:	ffffe097          	auipc	ra,0xffffe
    8000598c:	59c080e7          	jalr	1436(ra) # 80003f24 <namei>
    80005990:	84aa                	mv	s1,a0
    80005992:	c131                	beqz	a0,800059d6 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005994:	ffffe097          	auipc	ra,0xffffe
    80005998:	dea080e7          	jalr	-534(ra) # 8000377e <ilock>
  if(ip->type != T_DIR){
    8000599c:	04449703          	lh	a4,68(s1)
    800059a0:	4785                	li	a5,1
    800059a2:	04f71063          	bne	a4,a5,800059e2 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800059a6:	8526                	mv	a0,s1
    800059a8:	ffffe097          	auipc	ra,0xffffe
    800059ac:	e98080e7          	jalr	-360(ra) # 80003840 <iunlock>
  iput(p->cwd);
    800059b0:	15093503          	ld	a0,336(s2)
    800059b4:	ffffe097          	auipc	ra,0xffffe
    800059b8:	f84080e7          	jalr	-124(ra) # 80003938 <iput>
  end_op();
    800059bc:	ffffe097          	auipc	ra,0xffffe
    800059c0:	7e2080e7          	jalr	2018(ra) # 8000419e <end_op>
  p->cwd = ip;
    800059c4:	14993823          	sd	s1,336(s2)
  return 0;
    800059c8:	4501                	li	a0,0
}
    800059ca:	60ea                	ld	ra,152(sp)
    800059cc:	644a                	ld	s0,144(sp)
    800059ce:	64aa                	ld	s1,136(sp)
    800059d0:	690a                	ld	s2,128(sp)
    800059d2:	610d                	addi	sp,sp,160
    800059d4:	8082                	ret
    end_op();
    800059d6:	ffffe097          	auipc	ra,0xffffe
    800059da:	7c8080e7          	jalr	1992(ra) # 8000419e <end_op>
    return -1;
    800059de:	557d                	li	a0,-1
    800059e0:	b7ed                	j	800059ca <sys_chdir+0x7a>
    iunlockput(ip);
    800059e2:	8526                	mv	a0,s1
    800059e4:	ffffe097          	auipc	ra,0xffffe
    800059e8:	ffc080e7          	jalr	-4(ra) # 800039e0 <iunlockput>
    end_op();
    800059ec:	ffffe097          	auipc	ra,0xffffe
    800059f0:	7b2080e7          	jalr	1970(ra) # 8000419e <end_op>
    return -1;
    800059f4:	557d                	li	a0,-1
    800059f6:	bfd1                	j	800059ca <sys_chdir+0x7a>

00000000800059f8 <sys_exec>:

uint64
sys_exec(void)
{
    800059f8:	7121                	addi	sp,sp,-448
    800059fa:	ff06                	sd	ra,440(sp)
    800059fc:	fb22                	sd	s0,432(sp)
    800059fe:	f726                	sd	s1,424(sp)
    80005a00:	f34a                	sd	s2,416(sp)
    80005a02:	ef4e                	sd	s3,408(sp)
    80005a04:	eb52                	sd	s4,400(sp)
    80005a06:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005a08:	e4840593          	addi	a1,s0,-440
    80005a0c:	4505                	li	a0,1
    80005a0e:	ffffd097          	auipc	ra,0xffffd
    80005a12:	0e0080e7          	jalr	224(ra) # 80002aee <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005a16:	08000613          	li	a2,128
    80005a1a:	f5040593          	addi	a1,s0,-176
    80005a1e:	4501                	li	a0,0
    80005a20:	ffffd097          	auipc	ra,0xffffd
    80005a24:	0ee080e7          	jalr	238(ra) # 80002b0e <argstr>
    80005a28:	87aa                	mv	a5,a0
    return -1;
    80005a2a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005a2c:	0c07c263          	bltz	a5,80005af0 <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    80005a30:	10000613          	li	a2,256
    80005a34:	4581                	li	a1,0
    80005a36:	e5040513          	addi	a0,s0,-432
    80005a3a:	ffffb097          	auipc	ra,0xffffb
    80005a3e:	294080e7          	jalr	660(ra) # 80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005a42:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005a46:	89a6                	mv	s3,s1
    80005a48:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005a4a:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005a4e:	00391513          	slli	a0,s2,0x3
    80005a52:	e4040593          	addi	a1,s0,-448
    80005a56:	e4843783          	ld	a5,-440(s0)
    80005a5a:	953e                	add	a0,a0,a5
    80005a5c:	ffffd097          	auipc	ra,0xffffd
    80005a60:	fd4080e7          	jalr	-44(ra) # 80002a30 <fetchaddr>
    80005a64:	02054a63          	bltz	a0,80005a98 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005a68:	e4043783          	ld	a5,-448(s0)
    80005a6c:	c3b9                	beqz	a5,80005ab2 <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005a6e:	ffffb097          	auipc	ra,0xffffb
    80005a72:	074080e7          	jalr	116(ra) # 80000ae2 <kalloc>
    80005a76:	85aa                	mv	a1,a0
    80005a78:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005a7c:	cd11                	beqz	a0,80005a98 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005a7e:	6605                	lui	a2,0x1
    80005a80:	e4043503          	ld	a0,-448(s0)
    80005a84:	ffffd097          	auipc	ra,0xffffd
    80005a88:	ffe080e7          	jalr	-2(ra) # 80002a82 <fetchstr>
    80005a8c:	00054663          	bltz	a0,80005a98 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005a90:	0905                	addi	s2,s2,1
    80005a92:	09a1                	addi	s3,s3,8
    80005a94:	fb491de3          	bne	s2,s4,80005a4e <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a98:	f5040913          	addi	s2,s0,-176
    80005a9c:	6088                	ld	a0,0(s1)
    80005a9e:	c921                	beqz	a0,80005aee <sys_exec+0xf6>
    kfree(argv[i]);
    80005aa0:	ffffb097          	auipc	ra,0xffffb
    80005aa4:	f44080e7          	jalr	-188(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005aa8:	04a1                	addi	s1,s1,8
    80005aaa:	ff2499e3          	bne	s1,s2,80005a9c <sys_exec+0xa4>
  return -1;
    80005aae:	557d                	li	a0,-1
    80005ab0:	a081                	j	80005af0 <sys_exec+0xf8>
      argv[i] = 0;
    80005ab2:	0009079b          	sext.w	a5,s2
    80005ab6:	078e                	slli	a5,a5,0x3
    80005ab8:	fd078793          	addi	a5,a5,-48
    80005abc:	97a2                	add	a5,a5,s0
    80005abe:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005ac2:	e5040593          	addi	a1,s0,-432
    80005ac6:	f5040513          	addi	a0,s0,-176
    80005aca:	fffff097          	auipc	ra,0xfffff
    80005ace:	194080e7          	jalr	404(ra) # 80004c5e <exec>
    80005ad2:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ad4:	f5040993          	addi	s3,s0,-176
    80005ad8:	6088                	ld	a0,0(s1)
    80005ada:	c901                	beqz	a0,80005aea <sys_exec+0xf2>
    kfree(argv[i]);
    80005adc:	ffffb097          	auipc	ra,0xffffb
    80005ae0:	f08080e7          	jalr	-248(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ae4:	04a1                	addi	s1,s1,8
    80005ae6:	ff3499e3          	bne	s1,s3,80005ad8 <sys_exec+0xe0>
  return ret;
    80005aea:	854a                	mv	a0,s2
    80005aec:	a011                	j	80005af0 <sys_exec+0xf8>
  return -1;
    80005aee:	557d                	li	a0,-1
}
    80005af0:	70fa                	ld	ra,440(sp)
    80005af2:	745a                	ld	s0,432(sp)
    80005af4:	74ba                	ld	s1,424(sp)
    80005af6:	791a                	ld	s2,416(sp)
    80005af8:	69fa                	ld	s3,408(sp)
    80005afa:	6a5a                	ld	s4,400(sp)
    80005afc:	6139                	addi	sp,sp,448
    80005afe:	8082                	ret

0000000080005b00 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005b00:	7139                	addi	sp,sp,-64
    80005b02:	fc06                	sd	ra,56(sp)
    80005b04:	f822                	sd	s0,48(sp)
    80005b06:	f426                	sd	s1,40(sp)
    80005b08:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005b0a:	ffffc097          	auipc	ra,0xffffc
    80005b0e:	e9c080e7          	jalr	-356(ra) # 800019a6 <myproc>
    80005b12:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005b14:	fd840593          	addi	a1,s0,-40
    80005b18:	4501                	li	a0,0
    80005b1a:	ffffd097          	auipc	ra,0xffffd
    80005b1e:	fd4080e7          	jalr	-44(ra) # 80002aee <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005b22:	fc840593          	addi	a1,s0,-56
    80005b26:	fd040513          	addi	a0,s0,-48
    80005b2a:	fffff097          	auipc	ra,0xfffff
    80005b2e:	dea080e7          	jalr	-534(ra) # 80004914 <pipealloc>
    return -1;
    80005b32:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005b34:	0c054463          	bltz	a0,80005bfc <sys_pipe+0xfc>
  fd0 = -1;
    80005b38:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005b3c:	fd043503          	ld	a0,-48(s0)
    80005b40:	fffff097          	auipc	ra,0xfffff
    80005b44:	524080e7          	jalr	1316(ra) # 80005064 <fdalloc>
    80005b48:	fca42223          	sw	a0,-60(s0)
    80005b4c:	08054b63          	bltz	a0,80005be2 <sys_pipe+0xe2>
    80005b50:	fc843503          	ld	a0,-56(s0)
    80005b54:	fffff097          	auipc	ra,0xfffff
    80005b58:	510080e7          	jalr	1296(ra) # 80005064 <fdalloc>
    80005b5c:	fca42023          	sw	a0,-64(s0)
    80005b60:	06054863          	bltz	a0,80005bd0 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b64:	4691                	li	a3,4
    80005b66:	fc440613          	addi	a2,s0,-60
    80005b6a:	fd843583          	ld	a1,-40(s0)
    80005b6e:	68a8                	ld	a0,80(s1)
    80005b70:	ffffc097          	auipc	ra,0xffffc
    80005b74:	af6080e7          	jalr	-1290(ra) # 80001666 <copyout>
    80005b78:	02054063          	bltz	a0,80005b98 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005b7c:	4691                	li	a3,4
    80005b7e:	fc040613          	addi	a2,s0,-64
    80005b82:	fd843583          	ld	a1,-40(s0)
    80005b86:	0591                	addi	a1,a1,4
    80005b88:	68a8                	ld	a0,80(s1)
    80005b8a:	ffffc097          	auipc	ra,0xffffc
    80005b8e:	adc080e7          	jalr	-1316(ra) # 80001666 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005b92:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b94:	06055463          	bgez	a0,80005bfc <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005b98:	fc442783          	lw	a5,-60(s0)
    80005b9c:	07e9                	addi	a5,a5,26
    80005b9e:	078e                	slli	a5,a5,0x3
    80005ba0:	97a6                	add	a5,a5,s1
    80005ba2:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005ba6:	fc042783          	lw	a5,-64(s0)
    80005baa:	07e9                	addi	a5,a5,26
    80005bac:	078e                	slli	a5,a5,0x3
    80005bae:	94be                	add	s1,s1,a5
    80005bb0:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005bb4:	fd043503          	ld	a0,-48(s0)
    80005bb8:	fffff097          	auipc	ra,0xfffff
    80005bbc:	a30080e7          	jalr	-1488(ra) # 800045e8 <fileclose>
    fileclose(wf);
    80005bc0:	fc843503          	ld	a0,-56(s0)
    80005bc4:	fffff097          	auipc	ra,0xfffff
    80005bc8:	a24080e7          	jalr	-1500(ra) # 800045e8 <fileclose>
    return -1;
    80005bcc:	57fd                	li	a5,-1
    80005bce:	a03d                	j	80005bfc <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005bd0:	fc442783          	lw	a5,-60(s0)
    80005bd4:	0007c763          	bltz	a5,80005be2 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005bd8:	07e9                	addi	a5,a5,26
    80005bda:	078e                	slli	a5,a5,0x3
    80005bdc:	97a6                	add	a5,a5,s1
    80005bde:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005be2:	fd043503          	ld	a0,-48(s0)
    80005be6:	fffff097          	auipc	ra,0xfffff
    80005bea:	a02080e7          	jalr	-1534(ra) # 800045e8 <fileclose>
    fileclose(wf);
    80005bee:	fc843503          	ld	a0,-56(s0)
    80005bf2:	fffff097          	auipc	ra,0xfffff
    80005bf6:	9f6080e7          	jalr	-1546(ra) # 800045e8 <fileclose>
    return -1;
    80005bfa:	57fd                	li	a5,-1
}
    80005bfc:	853e                	mv	a0,a5
    80005bfe:	70e2                	ld	ra,56(sp)
    80005c00:	7442                	ld	s0,48(sp)
    80005c02:	74a2                	ld	s1,40(sp)
    80005c04:	6121                	addi	sp,sp,64
    80005c06:	8082                	ret
	...

0000000080005c10 <kernelvec>:
    80005c10:	7111                	addi	sp,sp,-256
    80005c12:	e006                	sd	ra,0(sp)
    80005c14:	e40a                	sd	sp,8(sp)
    80005c16:	e80e                	sd	gp,16(sp)
    80005c18:	ec12                	sd	tp,24(sp)
    80005c1a:	f016                	sd	t0,32(sp)
    80005c1c:	f41a                	sd	t1,40(sp)
    80005c1e:	f81e                	sd	t2,48(sp)
    80005c20:	fc22                	sd	s0,56(sp)
    80005c22:	e0a6                	sd	s1,64(sp)
    80005c24:	e4aa                	sd	a0,72(sp)
    80005c26:	e8ae                	sd	a1,80(sp)
    80005c28:	ecb2                	sd	a2,88(sp)
    80005c2a:	f0b6                	sd	a3,96(sp)
    80005c2c:	f4ba                	sd	a4,104(sp)
    80005c2e:	f8be                	sd	a5,112(sp)
    80005c30:	fcc2                	sd	a6,120(sp)
    80005c32:	e146                	sd	a7,128(sp)
    80005c34:	e54a                	sd	s2,136(sp)
    80005c36:	e94e                	sd	s3,144(sp)
    80005c38:	ed52                	sd	s4,152(sp)
    80005c3a:	f156                	sd	s5,160(sp)
    80005c3c:	f55a                	sd	s6,168(sp)
    80005c3e:	f95e                	sd	s7,176(sp)
    80005c40:	fd62                	sd	s8,184(sp)
    80005c42:	e1e6                	sd	s9,192(sp)
    80005c44:	e5ea                	sd	s10,200(sp)
    80005c46:	e9ee                	sd	s11,208(sp)
    80005c48:	edf2                	sd	t3,216(sp)
    80005c4a:	f1f6                	sd	t4,224(sp)
    80005c4c:	f5fa                	sd	t5,232(sp)
    80005c4e:	f9fe                	sd	t6,240(sp)
    80005c50:	cadfc0ef          	jal	ra,800028fc <kerneltrap>
    80005c54:	6082                	ld	ra,0(sp)
    80005c56:	6122                	ld	sp,8(sp)
    80005c58:	61c2                	ld	gp,16(sp)
    80005c5a:	7282                	ld	t0,32(sp)
    80005c5c:	7322                	ld	t1,40(sp)
    80005c5e:	73c2                	ld	t2,48(sp)
    80005c60:	7462                	ld	s0,56(sp)
    80005c62:	6486                	ld	s1,64(sp)
    80005c64:	6526                	ld	a0,72(sp)
    80005c66:	65c6                	ld	a1,80(sp)
    80005c68:	6666                	ld	a2,88(sp)
    80005c6a:	7686                	ld	a3,96(sp)
    80005c6c:	7726                	ld	a4,104(sp)
    80005c6e:	77c6                	ld	a5,112(sp)
    80005c70:	7866                	ld	a6,120(sp)
    80005c72:	688a                	ld	a7,128(sp)
    80005c74:	692a                	ld	s2,136(sp)
    80005c76:	69ca                	ld	s3,144(sp)
    80005c78:	6a6a                	ld	s4,152(sp)
    80005c7a:	7a8a                	ld	s5,160(sp)
    80005c7c:	7b2a                	ld	s6,168(sp)
    80005c7e:	7bca                	ld	s7,176(sp)
    80005c80:	7c6a                	ld	s8,184(sp)
    80005c82:	6c8e                	ld	s9,192(sp)
    80005c84:	6d2e                	ld	s10,200(sp)
    80005c86:	6dce                	ld	s11,208(sp)
    80005c88:	6e6e                	ld	t3,216(sp)
    80005c8a:	7e8e                	ld	t4,224(sp)
    80005c8c:	7f2e                	ld	t5,232(sp)
    80005c8e:	7fce                	ld	t6,240(sp)
    80005c90:	6111                	addi	sp,sp,256
    80005c92:	10200073          	sret
    80005c96:	00000013          	nop
    80005c9a:	00000013          	nop
    80005c9e:	0001                	nop

0000000080005ca0 <timervec>:
    80005ca0:	34051573          	csrrw	a0,mscratch,a0
    80005ca4:	e10c                	sd	a1,0(a0)
    80005ca6:	e510                	sd	a2,8(a0)
    80005ca8:	e914                	sd	a3,16(a0)
    80005caa:	6d0c                	ld	a1,24(a0)
    80005cac:	7110                	ld	a2,32(a0)
    80005cae:	6194                	ld	a3,0(a1)
    80005cb0:	96b2                	add	a3,a3,a2
    80005cb2:	e194                	sd	a3,0(a1)
    80005cb4:	4589                	li	a1,2
    80005cb6:	14459073          	csrw	sip,a1
    80005cba:	6914                	ld	a3,16(a0)
    80005cbc:	6510                	ld	a2,8(a0)
    80005cbe:	610c                	ld	a1,0(a0)
    80005cc0:	34051573          	csrrw	a0,mscratch,a0
    80005cc4:	30200073          	mret
	...

0000000080005cca <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005cca:	1141                	addi	sp,sp,-16
    80005ccc:	e422                	sd	s0,8(sp)
    80005cce:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005cd0:	0c0007b7          	lui	a5,0xc000
    80005cd4:	4705                	li	a4,1
    80005cd6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005cd8:	c3d8                	sw	a4,4(a5)
}
    80005cda:	6422                	ld	s0,8(sp)
    80005cdc:	0141                	addi	sp,sp,16
    80005cde:	8082                	ret

0000000080005ce0 <plicinithart>:

void
plicinithart(void)
{
    80005ce0:	1141                	addi	sp,sp,-16
    80005ce2:	e406                	sd	ra,8(sp)
    80005ce4:	e022                	sd	s0,0(sp)
    80005ce6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ce8:	ffffc097          	auipc	ra,0xffffc
    80005cec:	c92080e7          	jalr	-878(ra) # 8000197a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005cf0:	0085171b          	slliw	a4,a0,0x8
    80005cf4:	0c0027b7          	lui	a5,0xc002
    80005cf8:	97ba                	add	a5,a5,a4
    80005cfa:	40200713          	li	a4,1026
    80005cfe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005d02:	00d5151b          	slliw	a0,a0,0xd
    80005d06:	0c2017b7          	lui	a5,0xc201
    80005d0a:	97aa                	add	a5,a5,a0
    80005d0c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005d10:	60a2                	ld	ra,8(sp)
    80005d12:	6402                	ld	s0,0(sp)
    80005d14:	0141                	addi	sp,sp,16
    80005d16:	8082                	ret

0000000080005d18 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005d18:	1141                	addi	sp,sp,-16
    80005d1a:	e406                	sd	ra,8(sp)
    80005d1c:	e022                	sd	s0,0(sp)
    80005d1e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d20:	ffffc097          	auipc	ra,0xffffc
    80005d24:	c5a080e7          	jalr	-934(ra) # 8000197a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005d28:	00d5151b          	slliw	a0,a0,0xd
    80005d2c:	0c2017b7          	lui	a5,0xc201
    80005d30:	97aa                	add	a5,a5,a0
  return irq;
}
    80005d32:	43c8                	lw	a0,4(a5)
    80005d34:	60a2                	ld	ra,8(sp)
    80005d36:	6402                	ld	s0,0(sp)
    80005d38:	0141                	addi	sp,sp,16
    80005d3a:	8082                	ret

0000000080005d3c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005d3c:	1101                	addi	sp,sp,-32
    80005d3e:	ec06                	sd	ra,24(sp)
    80005d40:	e822                	sd	s0,16(sp)
    80005d42:	e426                	sd	s1,8(sp)
    80005d44:	1000                	addi	s0,sp,32
    80005d46:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005d48:	ffffc097          	auipc	ra,0xffffc
    80005d4c:	c32080e7          	jalr	-974(ra) # 8000197a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005d50:	00d5151b          	slliw	a0,a0,0xd
    80005d54:	0c2017b7          	lui	a5,0xc201
    80005d58:	97aa                	add	a5,a5,a0
    80005d5a:	c3c4                	sw	s1,4(a5)
}
    80005d5c:	60e2                	ld	ra,24(sp)
    80005d5e:	6442                	ld	s0,16(sp)
    80005d60:	64a2                	ld	s1,8(sp)
    80005d62:	6105                	addi	sp,sp,32
    80005d64:	8082                	ret

0000000080005d66 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005d66:	1141                	addi	sp,sp,-16
    80005d68:	e406                	sd	ra,8(sp)
    80005d6a:	e022                	sd	s0,0(sp)
    80005d6c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005d6e:	479d                	li	a5,7
    80005d70:	04a7cc63          	blt	a5,a0,80005dc8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005d74:	0001c797          	auipc	a5,0x1c
    80005d78:	28c78793          	addi	a5,a5,652 # 80022000 <disk>
    80005d7c:	97aa                	add	a5,a5,a0
    80005d7e:	0187c783          	lbu	a5,24(a5)
    80005d82:	ebb9                	bnez	a5,80005dd8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005d84:	00451693          	slli	a3,a0,0x4
    80005d88:	0001c797          	auipc	a5,0x1c
    80005d8c:	27878793          	addi	a5,a5,632 # 80022000 <disk>
    80005d90:	6398                	ld	a4,0(a5)
    80005d92:	9736                	add	a4,a4,a3
    80005d94:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005d98:	6398                	ld	a4,0(a5)
    80005d9a:	9736                	add	a4,a4,a3
    80005d9c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005da0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005da4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005da8:	97aa                	add	a5,a5,a0
    80005daa:	4705                	li	a4,1
    80005dac:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005db0:	0001c517          	auipc	a0,0x1c
    80005db4:	26850513          	addi	a0,a0,616 # 80022018 <disk+0x18>
    80005db8:	ffffc097          	auipc	ra,0xffffc
    80005dbc:	306080e7          	jalr	774(ra) # 800020be <wakeup>
}
    80005dc0:	60a2                	ld	ra,8(sp)
    80005dc2:	6402                	ld	s0,0(sp)
    80005dc4:	0141                	addi	sp,sp,16
    80005dc6:	8082                	ret
    panic("free_desc 1");
    80005dc8:	00003517          	auipc	a0,0x3
    80005dcc:	b7050513          	addi	a0,a0,-1168 # 80008938 <syscall_names+0x2f0>
    80005dd0:	ffffa097          	auipc	ra,0xffffa
    80005dd4:	76c080e7          	jalr	1900(ra) # 8000053c <panic>
    panic("free_desc 2");
    80005dd8:	00003517          	auipc	a0,0x3
    80005ddc:	b7050513          	addi	a0,a0,-1168 # 80008948 <syscall_names+0x300>
    80005de0:	ffffa097          	auipc	ra,0xffffa
    80005de4:	75c080e7          	jalr	1884(ra) # 8000053c <panic>

0000000080005de8 <virtio_disk_init>:
{
    80005de8:	1101                	addi	sp,sp,-32
    80005dea:	ec06                	sd	ra,24(sp)
    80005dec:	e822                	sd	s0,16(sp)
    80005dee:	e426                	sd	s1,8(sp)
    80005df0:	e04a                	sd	s2,0(sp)
    80005df2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005df4:	00003597          	auipc	a1,0x3
    80005df8:	b6458593          	addi	a1,a1,-1180 # 80008958 <syscall_names+0x310>
    80005dfc:	0001c517          	auipc	a0,0x1c
    80005e00:	32c50513          	addi	a0,a0,812 # 80022128 <disk+0x128>
    80005e04:	ffffb097          	auipc	ra,0xffffb
    80005e08:	d3e080e7          	jalr	-706(ra) # 80000b42 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e0c:	100017b7          	lui	a5,0x10001
    80005e10:	4398                	lw	a4,0(a5)
    80005e12:	2701                	sext.w	a4,a4
    80005e14:	747277b7          	lui	a5,0x74727
    80005e18:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005e1c:	14f71b63          	bne	a4,a5,80005f72 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005e20:	100017b7          	lui	a5,0x10001
    80005e24:	43dc                	lw	a5,4(a5)
    80005e26:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e28:	4709                	li	a4,2
    80005e2a:	14e79463          	bne	a5,a4,80005f72 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e2e:	100017b7          	lui	a5,0x10001
    80005e32:	479c                	lw	a5,8(a5)
    80005e34:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005e36:	12e79e63          	bne	a5,a4,80005f72 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005e3a:	100017b7          	lui	a5,0x10001
    80005e3e:	47d8                	lw	a4,12(a5)
    80005e40:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e42:	554d47b7          	lui	a5,0x554d4
    80005e46:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005e4a:	12f71463          	bne	a4,a5,80005f72 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e4e:	100017b7          	lui	a5,0x10001
    80005e52:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e56:	4705                	li	a4,1
    80005e58:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e5a:	470d                	li	a4,3
    80005e5c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005e5e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005e60:	c7ffe6b7          	lui	a3,0xc7ffe
    80005e64:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc61f>
    80005e68:	8f75                	and	a4,a4,a3
    80005e6a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e6c:	472d                	li	a4,11
    80005e6e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005e70:	5bbc                	lw	a5,112(a5)
    80005e72:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005e76:	8ba1                	andi	a5,a5,8
    80005e78:	10078563          	beqz	a5,80005f82 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005e7c:	100017b7          	lui	a5,0x10001
    80005e80:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005e84:	43fc                	lw	a5,68(a5)
    80005e86:	2781                	sext.w	a5,a5
    80005e88:	10079563          	bnez	a5,80005f92 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005e8c:	100017b7          	lui	a5,0x10001
    80005e90:	5bdc                	lw	a5,52(a5)
    80005e92:	2781                	sext.w	a5,a5
  if(max == 0)
    80005e94:	10078763          	beqz	a5,80005fa2 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80005e98:	471d                	li	a4,7
    80005e9a:	10f77c63          	bgeu	a4,a5,80005fb2 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80005e9e:	ffffb097          	auipc	ra,0xffffb
    80005ea2:	c44080e7          	jalr	-956(ra) # 80000ae2 <kalloc>
    80005ea6:	0001c497          	auipc	s1,0x1c
    80005eaa:	15a48493          	addi	s1,s1,346 # 80022000 <disk>
    80005eae:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005eb0:	ffffb097          	auipc	ra,0xffffb
    80005eb4:	c32080e7          	jalr	-974(ra) # 80000ae2 <kalloc>
    80005eb8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005eba:	ffffb097          	auipc	ra,0xffffb
    80005ebe:	c28080e7          	jalr	-984(ra) # 80000ae2 <kalloc>
    80005ec2:	87aa                	mv	a5,a0
    80005ec4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005ec6:	6088                	ld	a0,0(s1)
    80005ec8:	cd6d                	beqz	a0,80005fc2 <virtio_disk_init+0x1da>
    80005eca:	0001c717          	auipc	a4,0x1c
    80005ece:	13e73703          	ld	a4,318(a4) # 80022008 <disk+0x8>
    80005ed2:	cb65                	beqz	a4,80005fc2 <virtio_disk_init+0x1da>
    80005ed4:	c7fd                	beqz	a5,80005fc2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80005ed6:	6605                	lui	a2,0x1
    80005ed8:	4581                	li	a1,0
    80005eda:	ffffb097          	auipc	ra,0xffffb
    80005ede:	df4080e7          	jalr	-524(ra) # 80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    80005ee2:	0001c497          	auipc	s1,0x1c
    80005ee6:	11e48493          	addi	s1,s1,286 # 80022000 <disk>
    80005eea:	6605                	lui	a2,0x1
    80005eec:	4581                	li	a1,0
    80005eee:	6488                	ld	a0,8(s1)
    80005ef0:	ffffb097          	auipc	ra,0xffffb
    80005ef4:	dde080e7          	jalr	-546(ra) # 80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    80005ef8:	6605                	lui	a2,0x1
    80005efa:	4581                	li	a1,0
    80005efc:	6888                	ld	a0,16(s1)
    80005efe:	ffffb097          	auipc	ra,0xffffb
    80005f02:	dd0080e7          	jalr	-560(ra) # 80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005f06:	100017b7          	lui	a5,0x10001
    80005f0a:	4721                	li	a4,8
    80005f0c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005f0e:	4098                	lw	a4,0(s1)
    80005f10:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005f14:	40d8                	lw	a4,4(s1)
    80005f16:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005f1a:	6498                	ld	a4,8(s1)
    80005f1c:	0007069b          	sext.w	a3,a4
    80005f20:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005f24:	9701                	srai	a4,a4,0x20
    80005f26:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005f2a:	6898                	ld	a4,16(s1)
    80005f2c:	0007069b          	sext.w	a3,a4
    80005f30:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005f34:	9701                	srai	a4,a4,0x20
    80005f36:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005f3a:	4705                	li	a4,1
    80005f3c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005f3e:	00e48c23          	sb	a4,24(s1)
    80005f42:	00e48ca3          	sb	a4,25(s1)
    80005f46:	00e48d23          	sb	a4,26(s1)
    80005f4a:	00e48da3          	sb	a4,27(s1)
    80005f4e:	00e48e23          	sb	a4,28(s1)
    80005f52:	00e48ea3          	sb	a4,29(s1)
    80005f56:	00e48f23          	sb	a4,30(s1)
    80005f5a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005f5e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f62:	0727a823          	sw	s2,112(a5)
}
    80005f66:	60e2                	ld	ra,24(sp)
    80005f68:	6442                	ld	s0,16(sp)
    80005f6a:	64a2                	ld	s1,8(sp)
    80005f6c:	6902                	ld	s2,0(sp)
    80005f6e:	6105                	addi	sp,sp,32
    80005f70:	8082                	ret
    panic("could not find virtio disk");
    80005f72:	00003517          	auipc	a0,0x3
    80005f76:	9f650513          	addi	a0,a0,-1546 # 80008968 <syscall_names+0x320>
    80005f7a:	ffffa097          	auipc	ra,0xffffa
    80005f7e:	5c2080e7          	jalr	1474(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    80005f82:	00003517          	auipc	a0,0x3
    80005f86:	a0650513          	addi	a0,a0,-1530 # 80008988 <syscall_names+0x340>
    80005f8a:	ffffa097          	auipc	ra,0xffffa
    80005f8e:	5b2080e7          	jalr	1458(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    80005f92:	00003517          	auipc	a0,0x3
    80005f96:	a1650513          	addi	a0,a0,-1514 # 800089a8 <syscall_names+0x360>
    80005f9a:	ffffa097          	auipc	ra,0xffffa
    80005f9e:	5a2080e7          	jalr	1442(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    80005fa2:	00003517          	auipc	a0,0x3
    80005fa6:	a2650513          	addi	a0,a0,-1498 # 800089c8 <syscall_names+0x380>
    80005faa:	ffffa097          	auipc	ra,0xffffa
    80005fae:	592080e7          	jalr	1426(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    80005fb2:	00003517          	auipc	a0,0x3
    80005fb6:	a3650513          	addi	a0,a0,-1482 # 800089e8 <syscall_names+0x3a0>
    80005fba:	ffffa097          	auipc	ra,0xffffa
    80005fbe:	582080e7          	jalr	1410(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    80005fc2:	00003517          	auipc	a0,0x3
    80005fc6:	a4650513          	addi	a0,a0,-1466 # 80008a08 <syscall_names+0x3c0>
    80005fca:	ffffa097          	auipc	ra,0xffffa
    80005fce:	572080e7          	jalr	1394(ra) # 8000053c <panic>

0000000080005fd2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005fd2:	7159                	addi	sp,sp,-112
    80005fd4:	f486                	sd	ra,104(sp)
    80005fd6:	f0a2                	sd	s0,96(sp)
    80005fd8:	eca6                	sd	s1,88(sp)
    80005fda:	e8ca                	sd	s2,80(sp)
    80005fdc:	e4ce                	sd	s3,72(sp)
    80005fde:	e0d2                	sd	s4,64(sp)
    80005fe0:	fc56                	sd	s5,56(sp)
    80005fe2:	f85a                	sd	s6,48(sp)
    80005fe4:	f45e                	sd	s7,40(sp)
    80005fe6:	f062                	sd	s8,32(sp)
    80005fe8:	ec66                	sd	s9,24(sp)
    80005fea:	e86a                	sd	s10,16(sp)
    80005fec:	1880                	addi	s0,sp,112
    80005fee:	8a2a                	mv	s4,a0
    80005ff0:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005ff2:	00c52c83          	lw	s9,12(a0)
    80005ff6:	001c9c9b          	slliw	s9,s9,0x1
    80005ffa:	1c82                	slli	s9,s9,0x20
    80005ffc:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006000:	0001c517          	auipc	a0,0x1c
    80006004:	12850513          	addi	a0,a0,296 # 80022128 <disk+0x128>
    80006008:	ffffb097          	auipc	ra,0xffffb
    8000600c:	bca080e7          	jalr	-1078(ra) # 80000bd2 <acquire>
  for(int i = 0; i < 3; i++){
    80006010:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80006012:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006014:	0001cb17          	auipc	s6,0x1c
    80006018:	fecb0b13          	addi	s6,s6,-20 # 80022000 <disk>
  for(int i = 0; i < 3; i++){
    8000601c:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000601e:	0001cc17          	auipc	s8,0x1c
    80006022:	10ac0c13          	addi	s8,s8,266 # 80022128 <disk+0x128>
    80006026:	a095                	j	8000608a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80006028:	00fb0733          	add	a4,s6,a5
    8000602c:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006030:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    80006032:	0207c563          	bltz	a5,8000605c <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    80006036:	2605                	addiw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    80006038:	0591                	addi	a1,a1,4
    8000603a:	05560d63          	beq	a2,s5,80006094 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    8000603e:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    80006040:	0001c717          	auipc	a4,0x1c
    80006044:	fc070713          	addi	a4,a4,-64 # 80022000 <disk>
    80006048:	87ca                	mv	a5,s2
    if(disk.free[i]){
    8000604a:	01874683          	lbu	a3,24(a4)
    8000604e:	fee9                	bnez	a3,80006028 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    80006050:	2785                	addiw	a5,a5,1
    80006052:	0705                	addi	a4,a4,1
    80006054:	fe979be3          	bne	a5,s1,8000604a <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    80006058:	57fd                	li	a5,-1
    8000605a:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    8000605c:	00c05e63          	blez	a2,80006078 <virtio_disk_rw+0xa6>
    80006060:	060a                	slli	a2,a2,0x2
    80006062:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    80006066:	0009a503          	lw	a0,0(s3)
    8000606a:	00000097          	auipc	ra,0x0
    8000606e:	cfc080e7          	jalr	-772(ra) # 80005d66 <free_desc>
      for(int j = 0; j < i; j++)
    80006072:	0991                	addi	s3,s3,4
    80006074:	ffa999e3          	bne	s3,s10,80006066 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006078:	85e2                	mv	a1,s8
    8000607a:	0001c517          	auipc	a0,0x1c
    8000607e:	f9e50513          	addi	a0,a0,-98 # 80022018 <disk+0x18>
    80006082:	ffffc097          	auipc	ra,0xffffc
    80006086:	fd8080e7          	jalr	-40(ra) # 8000205a <sleep>
  for(int i = 0; i < 3; i++){
    8000608a:	f9040993          	addi	s3,s0,-112
{
    8000608e:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    80006090:	864a                	mv	a2,s2
    80006092:	b775                	j	8000603e <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006094:	f9042503          	lw	a0,-112(s0)
    80006098:	00a50713          	addi	a4,a0,10
    8000609c:	0712                	slli	a4,a4,0x4

  if(write)
    8000609e:	0001c797          	auipc	a5,0x1c
    800060a2:	f6278793          	addi	a5,a5,-158 # 80022000 <disk>
    800060a6:	00e786b3          	add	a3,a5,a4
    800060aa:	01703633          	snez	a2,s7
    800060ae:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800060b0:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800060b4:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800060b8:	f6070613          	addi	a2,a4,-160
    800060bc:	6394                	ld	a3,0(a5)
    800060be:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800060c0:	00870593          	addi	a1,a4,8
    800060c4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800060c6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800060c8:	0007b803          	ld	a6,0(a5)
    800060cc:	9642                	add	a2,a2,a6
    800060ce:	46c1                	li	a3,16
    800060d0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800060d2:	4585                	li	a1,1
    800060d4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800060d8:	f9442683          	lw	a3,-108(s0)
    800060dc:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800060e0:	0692                	slli	a3,a3,0x4
    800060e2:	9836                	add	a6,a6,a3
    800060e4:	058a0613          	addi	a2,s4,88
    800060e8:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800060ec:	0007b803          	ld	a6,0(a5)
    800060f0:	96c2                	add	a3,a3,a6
    800060f2:	40000613          	li	a2,1024
    800060f6:	c690                	sw	a2,8(a3)
  if(write)
    800060f8:	001bb613          	seqz	a2,s7
    800060fc:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006100:	00166613          	ori	a2,a2,1
    80006104:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006108:	f9842603          	lw	a2,-104(s0)
    8000610c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006110:	00250693          	addi	a3,a0,2
    80006114:	0692                	slli	a3,a3,0x4
    80006116:	96be                	add	a3,a3,a5
    80006118:	58fd                	li	a7,-1
    8000611a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000611e:	0612                	slli	a2,a2,0x4
    80006120:	9832                	add	a6,a6,a2
    80006122:	f9070713          	addi	a4,a4,-112
    80006126:	973e                	add	a4,a4,a5
    80006128:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000612c:	6398                	ld	a4,0(a5)
    8000612e:	9732                	add	a4,a4,a2
    80006130:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006132:	4609                	li	a2,2
    80006134:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006138:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000613c:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    80006140:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006144:	6794                	ld	a3,8(a5)
    80006146:	0026d703          	lhu	a4,2(a3)
    8000614a:	8b1d                	andi	a4,a4,7
    8000614c:	0706                	slli	a4,a4,0x1
    8000614e:	96ba                	add	a3,a3,a4
    80006150:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006154:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006158:	6798                	ld	a4,8(a5)
    8000615a:	00275783          	lhu	a5,2(a4)
    8000615e:	2785                	addiw	a5,a5,1
    80006160:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006164:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006168:	100017b7          	lui	a5,0x10001
    8000616c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006170:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006174:	0001c917          	auipc	s2,0x1c
    80006178:	fb490913          	addi	s2,s2,-76 # 80022128 <disk+0x128>
  while(b->disk == 1) {
    8000617c:	4485                	li	s1,1
    8000617e:	00b79c63          	bne	a5,a1,80006196 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006182:	85ca                	mv	a1,s2
    80006184:	8552                	mv	a0,s4
    80006186:	ffffc097          	auipc	ra,0xffffc
    8000618a:	ed4080e7          	jalr	-300(ra) # 8000205a <sleep>
  while(b->disk == 1) {
    8000618e:	004a2783          	lw	a5,4(s4)
    80006192:	fe9788e3          	beq	a5,s1,80006182 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006196:	f9042903          	lw	s2,-112(s0)
    8000619a:	00290713          	addi	a4,s2,2
    8000619e:	0712                	slli	a4,a4,0x4
    800061a0:	0001c797          	auipc	a5,0x1c
    800061a4:	e6078793          	addi	a5,a5,-416 # 80022000 <disk>
    800061a8:	97ba                	add	a5,a5,a4
    800061aa:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800061ae:	0001c997          	auipc	s3,0x1c
    800061b2:	e5298993          	addi	s3,s3,-430 # 80022000 <disk>
    800061b6:	00491713          	slli	a4,s2,0x4
    800061ba:	0009b783          	ld	a5,0(s3)
    800061be:	97ba                	add	a5,a5,a4
    800061c0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800061c4:	854a                	mv	a0,s2
    800061c6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800061ca:	00000097          	auipc	ra,0x0
    800061ce:	b9c080e7          	jalr	-1124(ra) # 80005d66 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800061d2:	8885                	andi	s1,s1,1
    800061d4:	f0ed                	bnez	s1,800061b6 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800061d6:	0001c517          	auipc	a0,0x1c
    800061da:	f5250513          	addi	a0,a0,-174 # 80022128 <disk+0x128>
    800061de:	ffffb097          	auipc	ra,0xffffb
    800061e2:	aa8080e7          	jalr	-1368(ra) # 80000c86 <release>
}
    800061e6:	70a6                	ld	ra,104(sp)
    800061e8:	7406                	ld	s0,96(sp)
    800061ea:	64e6                	ld	s1,88(sp)
    800061ec:	6946                	ld	s2,80(sp)
    800061ee:	69a6                	ld	s3,72(sp)
    800061f0:	6a06                	ld	s4,64(sp)
    800061f2:	7ae2                	ld	s5,56(sp)
    800061f4:	7b42                	ld	s6,48(sp)
    800061f6:	7ba2                	ld	s7,40(sp)
    800061f8:	7c02                	ld	s8,32(sp)
    800061fa:	6ce2                	ld	s9,24(sp)
    800061fc:	6d42                	ld	s10,16(sp)
    800061fe:	6165                	addi	sp,sp,112
    80006200:	8082                	ret

0000000080006202 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006202:	1101                	addi	sp,sp,-32
    80006204:	ec06                	sd	ra,24(sp)
    80006206:	e822                	sd	s0,16(sp)
    80006208:	e426                	sd	s1,8(sp)
    8000620a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000620c:	0001c497          	auipc	s1,0x1c
    80006210:	df448493          	addi	s1,s1,-524 # 80022000 <disk>
    80006214:	0001c517          	auipc	a0,0x1c
    80006218:	f1450513          	addi	a0,a0,-236 # 80022128 <disk+0x128>
    8000621c:	ffffb097          	auipc	ra,0xffffb
    80006220:	9b6080e7          	jalr	-1610(ra) # 80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006224:	10001737          	lui	a4,0x10001
    80006228:	533c                	lw	a5,96(a4)
    8000622a:	8b8d                	andi	a5,a5,3
    8000622c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000622e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006232:	689c                	ld	a5,16(s1)
    80006234:	0204d703          	lhu	a4,32(s1)
    80006238:	0027d783          	lhu	a5,2(a5)
    8000623c:	04f70863          	beq	a4,a5,8000628c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006240:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006244:	6898                	ld	a4,16(s1)
    80006246:	0204d783          	lhu	a5,32(s1)
    8000624a:	8b9d                	andi	a5,a5,7
    8000624c:	078e                	slli	a5,a5,0x3
    8000624e:	97ba                	add	a5,a5,a4
    80006250:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006252:	00278713          	addi	a4,a5,2
    80006256:	0712                	slli	a4,a4,0x4
    80006258:	9726                	add	a4,a4,s1
    8000625a:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000625e:	e721                	bnez	a4,800062a6 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006260:	0789                	addi	a5,a5,2
    80006262:	0792                	slli	a5,a5,0x4
    80006264:	97a6                	add	a5,a5,s1
    80006266:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006268:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000626c:	ffffc097          	auipc	ra,0xffffc
    80006270:	e52080e7          	jalr	-430(ra) # 800020be <wakeup>

    disk.used_idx += 1;
    80006274:	0204d783          	lhu	a5,32(s1)
    80006278:	2785                	addiw	a5,a5,1
    8000627a:	17c2                	slli	a5,a5,0x30
    8000627c:	93c1                	srli	a5,a5,0x30
    8000627e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006282:	6898                	ld	a4,16(s1)
    80006284:	00275703          	lhu	a4,2(a4)
    80006288:	faf71ce3          	bne	a4,a5,80006240 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000628c:	0001c517          	auipc	a0,0x1c
    80006290:	e9c50513          	addi	a0,a0,-356 # 80022128 <disk+0x128>
    80006294:	ffffb097          	auipc	ra,0xffffb
    80006298:	9f2080e7          	jalr	-1550(ra) # 80000c86 <release>
}
    8000629c:	60e2                	ld	ra,24(sp)
    8000629e:	6442                	ld	s0,16(sp)
    800062a0:	64a2                	ld	s1,8(sp)
    800062a2:	6105                	addi	sp,sp,32
    800062a4:	8082                	ret
      panic("virtio_disk_intr status");
    800062a6:	00002517          	auipc	a0,0x2
    800062aa:	77a50513          	addi	a0,a0,1914 # 80008a20 <syscall_names+0x3d8>
    800062ae:	ffffa097          	auipc	ra,0xffffa
    800062b2:	28e080e7          	jalr	654(ra) # 8000053c <panic>
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
