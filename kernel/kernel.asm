
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	cc010113          	addi	sp,sp,-832 # 80008cc0 <stack0>
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
    80000054:	b3070713          	addi	a4,a4,-1232 # 80008b80 <timer_scratch>
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
    80000066:	68e78793          	addi	a5,a5,1678 # 800066f0 <timervec>
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
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffadfef>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	f6078793          	addi	a5,a5,-160 # 8000100c <main>
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
    8000012a:	00003097          	auipc	ra,0x3
    8000012e:	9aa080e7          	jalr	-1622(ra) # 80002ad4 <either_copyin>
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
    80000188:	b3c50513          	addi	a0,a0,-1220 # 80010cc0 <cons>
    8000018c:	00001097          	auipc	ra,0x1
    80000190:	be0080e7          	jalr	-1056(ra) # 80000d6c <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000194:	00011497          	auipc	s1,0x11
    80000198:	b2c48493          	addi	s1,s1,-1236 # 80010cc0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000019c:	00011917          	auipc	s2,0x11
    800001a0:	bbc90913          	addi	s2,s2,-1092 # 80010d58 <cons+0x98>
  while(n > 0){
    800001a4:	09305263          	blez	s3,80000228 <consoleread+0xc4>
    while(cons.r == cons.w){
    800001a8:	0984a783          	lw	a5,152(s1)
    800001ac:	09c4a703          	lw	a4,156(s1)
    800001b0:	02f71763          	bne	a4,a5,800001de <consoleread+0x7a>
      if(killed(myproc())){
    800001b4:	00002097          	auipc	ra,0x2
    800001b8:	a16080e7          	jalr	-1514(ra) # 80001bca <myproc>
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	762080e7          	jalr	1890(ra) # 8000291e <killed>
    800001c4:	ed2d                	bnez	a0,8000023e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001c6:	85a6                	mv	a1,s1
    800001c8:	854a                	mv	a0,s2
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	340080e7          	jalr	832(ra) # 8000250a <sleep>
    while(cons.r == cons.w){
    800001d2:	0984a783          	lw	a5,152(s1)
    800001d6:	09c4a703          	lw	a4,156(s1)
    800001da:	fcf70de3          	beq	a4,a5,800001b4 <consoleread+0x50>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00011717          	auipc	a4,0x11
    800001e2:	ae270713          	addi	a4,a4,-1310 # 80010cc0 <cons>
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
    80000210:	00003097          	auipc	ra,0x3
    80000214:	86e080e7          	jalr	-1938(ra) # 80002a7e <either_copyout>
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
    8000022c:	a9850513          	addi	a0,a0,-1384 # 80010cc0 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	bf0080e7          	jalr	-1040(ra) # 80000e20 <release>

  return target - n;
    80000238:	413b053b          	subw	a0,s6,s3
    8000023c:	a811                	j	80000250 <consoleread+0xec>
        release(&cons.lock);
    8000023e:	00011517          	auipc	a0,0x11
    80000242:	a8250513          	addi	a0,a0,-1406 # 80010cc0 <cons>
    80000246:	00001097          	auipc	ra,0x1
    8000024a:	bda080e7          	jalr	-1062(ra) # 80000e20 <release>
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
    80000272:	aef72523          	sw	a5,-1302(a4) # 80010d58 <cons+0x98>
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
    800002cc:	9f850513          	addi	a0,a0,-1544 # 80010cc0 <cons>
    800002d0:	00001097          	auipc	ra,0x1
    800002d4:	a9c080e7          	jalr	-1380(ra) # 80000d6c <acquire>

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
    800002ee:	00003097          	auipc	ra,0x3
    800002f2:	83c080e7          	jalr	-1988(ra) # 80002b2a <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f6:	00011517          	auipc	a0,0x11
    800002fa:	9ca50513          	addi	a0,a0,-1590 # 80010cc0 <cons>
    800002fe:	00001097          	auipc	ra,0x1
    80000302:	b22080e7          	jalr	-1246(ra) # 80000e20 <release>
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
    8000031e:	9a670713          	addi	a4,a4,-1626 # 80010cc0 <cons>
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
    80000348:	97c78793          	addi	a5,a5,-1668 # 80010cc0 <cons>
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
    80000376:	9e67a783          	lw	a5,-1562(a5) # 80010d58 <cons+0x98>
    8000037a:	9f1d                	subw	a4,a4,a5
    8000037c:	08000793          	li	a5,128
    80000380:	f6f71be3          	bne	a4,a5,800002f6 <consoleintr+0x3c>
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000386:	00011717          	auipc	a4,0x11
    8000038a:	93a70713          	addi	a4,a4,-1734 # 80010cc0 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000396:	00011497          	auipc	s1,0x11
    8000039a:	92a48493          	addi	s1,s1,-1750 # 80010cc0 <cons>
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
    800003d6:	8ee70713          	addi	a4,a4,-1810 # 80010cc0 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003e6:	37fd                	addiw	a5,a5,-1
    800003e8:	00011717          	auipc	a4,0x11
    800003ec:	96f72c23          	sw	a5,-1672(a4) # 80010d60 <cons+0xa0>
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
    80000412:	8b278793          	addi	a5,a5,-1870 # 80010cc0 <cons>
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
    80000436:	92c7a523          	sw	a2,-1750(a5) # 80010d5c <cons+0x9c>
        wakeup(&cons.r);
    8000043a:	00011517          	auipc	a0,0x11
    8000043e:	91e50513          	addi	a0,a0,-1762 # 80010d58 <cons+0x98>
    80000442:	00002097          	auipc	ra,0x2
    80000446:	278080e7          	jalr	632(ra) # 800026ba <wakeup>
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
    8000045c:	00011517          	auipc	a0,0x11
    80000460:	86450513          	addi	a0,a0,-1948 # 80010cc0 <cons>
    80000464:	00001097          	auipc	ra,0x1
    80000468:	878080e7          	jalr	-1928(ra) # 80000cdc <initlock>

  uartinit();
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	32c080e7          	jalr	812(ra) # 80000798 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000474:	0004f797          	auipc	a5,0x4f
    80000478:	20478793          	addi	a5,a5,516 # 8004f678 <devsw>
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
    80000548:	00011797          	auipc	a5,0x11
    8000054c:	8207ac23          	sw	zero,-1992(a5) # 80010d80 <pr+0x18>
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
    8000056e:	b6650513          	addi	a0,a0,-1178 # 800080d0 <digits+0x90>
    80000572:	00000097          	auipc	ra,0x0
    80000576:	014080e7          	jalr	20(ra) # 80000586 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057a:	4785                	li	a5,1
    8000057c:	00008717          	auipc	a4,0x8
    80000580:	5cf72223          	sw	a5,1476(a4) # 80008b40 <panicked>
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
    800005bc:	7c8dad83          	lw	s11,1992(s11) # 80010d80 <pr+0x18>
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
    800005fa:	77250513          	addi	a0,a0,1906 # 80010d68 <pr>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	76e080e7          	jalr	1902(ra) # 80000d6c <acquire>
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
    80000758:	61450513          	addi	a0,a0,1556 # 80010d68 <pr>
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	6c4080e7          	jalr	1732(ra) # 80000e20 <release>
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
    80000774:	5f848493          	addi	s1,s1,1528 # 80010d68 <pr>
    80000778:	00008597          	auipc	a1,0x8
    8000077c:	8c058593          	addi	a1,a1,-1856 # 80008038 <etext+0x38>
    80000780:	8526                	mv	a0,s1
    80000782:	00000097          	auipc	ra,0x0
    80000786:	55a080e7          	jalr	1370(ra) # 80000cdc <initlock>
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
    800007d4:	5b850513          	addi	a0,a0,1464 # 80010d88 <uart_tx_lock>
    800007d8:	00000097          	auipc	ra,0x0
    800007dc:	504080e7          	jalr	1284(ra) # 80000cdc <initlock>
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
    800007f8:	52c080e7          	jalr	1324(ra) # 80000d20 <push_off>

  if(panicked){
    800007fc:	00008797          	auipc	a5,0x8
    80000800:	3447a783          	lw	a5,836(a5) # 80008b40 <panicked>
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
    80000826:	59e080e7          	jalr	1438(ra) # 80000dc0 <pop_off>
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
    80000838:	3147b783          	ld	a5,788(a5) # 80008b48 <uart_tx_r>
    8000083c:	00008717          	auipc	a4,0x8
    80000840:	31473703          	ld	a4,788(a4) # 80008b50 <uart_tx_w>
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
    80000862:	52aa0a13          	addi	s4,s4,1322 # 80010d88 <uart_tx_lock>
    uart_tx_r += 1;
    80000866:	00008497          	auipc	s1,0x8
    8000086a:	2e248493          	addi	s1,s1,738 # 80008b48 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086e:	00008997          	auipc	s3,0x8
    80000872:	2e298993          	addi	s3,s3,738 # 80008b50 <uart_tx_w>
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
    80000894:	e2a080e7          	jalr	-470(ra) # 800026ba <wakeup>
    
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
    800008d0:	4bc50513          	addi	a0,a0,1212 # 80010d88 <uart_tx_lock>
    800008d4:	00000097          	auipc	ra,0x0
    800008d8:	498080e7          	jalr	1176(ra) # 80000d6c <acquire>
  if(panicked){
    800008dc:	00008797          	auipc	a5,0x8
    800008e0:	2647a783          	lw	a5,612(a5) # 80008b40 <panicked>
    800008e4:	e7c9                	bnez	a5,8000096e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	26a73703          	ld	a4,618(a4) # 80008b50 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	25a7b783          	ld	a5,602(a5) # 80008b48 <uart_tx_r>
    800008f6:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fa:	00010997          	auipc	s3,0x10
    800008fe:	48e98993          	addi	s3,s3,1166 # 80010d88 <uart_tx_lock>
    80000902:	00008497          	auipc	s1,0x8
    80000906:	24648493          	addi	s1,s1,582 # 80008b48 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090a:	00008917          	auipc	s2,0x8
    8000090e:	24690913          	addi	s2,s2,582 # 80008b50 <uart_tx_w>
    80000912:	00e79f63          	bne	a5,a4,80000930 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00002097          	auipc	ra,0x2
    8000091e:	bf0080e7          	jalr	-1040(ra) # 8000250a <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	addi	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00010497          	auipc	s1,0x10
    80000934:	45848493          	addi	s1,s1,1112 # 80010d88 <uart_tx_lock>
    80000938:	01f77793          	andi	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000942:	0705                	addi	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	20e7b623          	sd	a4,524(a5) # 80008b50 <uart_tx_w>
  uartstart();
    8000094c:	00000097          	auipc	ra,0x0
    80000950:	ee8080e7          	jalr	-280(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    80000954:	8526                	mv	a0,s1
    80000956:	00000097          	auipc	ra,0x0
    8000095a:	4ca080e7          	jalr	1226(ra) # 80000e20 <release>
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
    800009ba:	3d248493          	addi	s1,s1,978 # 80010d88 <uart_tx_lock>
    800009be:	8526                	mv	a0,s1
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	3ac080e7          	jalr	940(ra) # 80000d6c <acquire>
  uartstart();
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	e6c080e7          	jalr	-404(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    800009d0:	8526                	mv	a0,s1
    800009d2:	00000097          	auipc	ra,0x0
    800009d6:	44e080e7          	jalr	1102(ra) # 80000e20 <release>
}
    800009da:	60e2                	ld	ra,24(sp)
    800009dc:	6442                	ld	s0,16(sp)
    800009de:	64a2                	ld	s1,8(sp)
    800009e0:	6105                	addi	sp,sp,32
    800009e2:	8082                	ret

00000000800009e4 <memref_lock>:
  freerange(end, (void*)PHYSTOP);
  memref.lock_kalloc = 1;
  memset((void*)memref.fr, 0, fn(PHYSTOP) + 1);
}

void memref_lock() {
    800009e4:	1141                	addi	sp,sp,-16
    800009e6:	e406                	sd	ra,8(sp)
    800009e8:	e022                	sd	s0,0(sp)
    800009ea:	0800                	addi	s0,sp,16
  acquire(&memref.lock);
    800009ec:	00010517          	auipc	a0,0x10
    800009f0:	3f450513          	addi	a0,a0,1012 # 80010de0 <memref>
    800009f4:	00000097          	auipc	ra,0x0
    800009f8:	378080e7          	jalr	888(ra) # 80000d6c <acquire>
}
    800009fc:	60a2                	ld	ra,8(sp)
    800009fe:	6402                	ld	s0,0(sp)
    80000a00:	0141                	addi	sp,sp,16
    80000a02:	8082                	ret

0000000080000a04 <memref_unlock>:

void memref_unlock() {
    80000a04:	1141                	addi	sp,sp,-16
    80000a06:	e406                	sd	ra,8(sp)
    80000a08:	e022                	sd	s0,0(sp)
    80000a0a:	0800                	addi	s0,sp,16
  release(&memref.lock);
    80000a0c:	00010517          	auipc	a0,0x10
    80000a10:	3d450513          	addi	a0,a0,980 # 80010de0 <memref>
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	40c080e7          	jalr	1036(ra) # 80000e20 <release>
}
    80000a1c:	60a2                	ld	ra,8(sp)
    80000a1e:	6402                	ld	s0,0(sp)
    80000a20:	0141                	addi	sp,sp,16
    80000a22:	8082                	ret

0000000080000a24 <memref_get>:

int memref_get(void *pa) {
    80000a24:	1141                	addi	sp,sp,-16
    80000a26:	e422                	sd	s0,8(sp)
    80000a28:	0800                	addi	s0,sp,16
  return memref.fr[fn(pa)];
    80000a2a:	800007b7          	lui	a5,0x80000
    80000a2e:	97aa                	add	a5,a5,a0
    80000a30:	83b1                	srli	a5,a5,0xc
    80000a32:	0791                	addi	a5,a5,4 # ffffffff80000004 <end+0xfffffffefffaf7f4>
    80000a34:	078a                	slli	a5,a5,0x2
    80000a36:	00010717          	auipc	a4,0x10
    80000a3a:	3aa70713          	addi	a4,a4,938 # 80010de0 <memref>
    80000a3e:	97ba                	add	a5,a5,a4
}
    80000a40:	4788                	lw	a0,8(a5)
    80000a42:	6422                	ld	s0,8(sp)
    80000a44:	0141                	addi	sp,sp,16
    80000a46:	8082                	ret

0000000080000a48 <memref_set>:

void memref_set(void *pa, int fq) {
    80000a48:	1141                	addi	sp,sp,-16
    80000a4a:	e422                	sd	s0,8(sp)
    80000a4c:	0800                	addi	s0,sp,16
  memref.fr[fn(pa)] = fq;
    80000a4e:	800007b7          	lui	a5,0x80000
    80000a52:	953e                	add	a0,a0,a5
    80000a54:	8131                	srli	a0,a0,0xc
    80000a56:	0511                	addi	a0,a0,4
    80000a58:	050a                	slli	a0,a0,0x2
    80000a5a:	00010797          	auipc	a5,0x10
    80000a5e:	38678793          	addi	a5,a5,902 # 80010de0 <memref>
    80000a62:	97aa                	add	a5,a5,a0
    80000a64:	c78c                	sw	a1,8(a5)
}
    80000a66:	6422                	ld	s0,8(sp)
    80000a68:	0141                	addi	sp,sp,16
    80000a6a:	8082                	ret

0000000080000a6c <memref_lock_kalloc>:

void memref_lock_kalloc() {
    80000a6c:	1141                	addi	sp,sp,-16
    80000a6e:	e422                	sd	s0,8(sp)
    80000a70:	0800                	addi	s0,sp,16
  memref.lock_kalloc = 1;
    80000a72:	4785                	li	a5,1
    80000a74:	00030717          	auipc	a4,0x30
    80000a78:	38f70423          	sb	a5,904(a4) # 80030dfc <memref+0x2001c>
}
    80000a7c:	6422                	ld	s0,8(sp)
    80000a7e:	0141                	addi	sp,sp,16
    80000a80:	8082                	ret

0000000080000a82 <memref_unlock_kalloc>:

void memref_unlock_kalloc() {
    80000a82:	1141                	addi	sp,sp,-16
    80000a84:	e422                	sd	s0,8(sp)
    80000a86:	0800                	addi	s0,sp,16
  memref.lock_kalloc = 0;
    80000a88:	00030797          	auipc	a5,0x30
    80000a8c:	36078a23          	sb	zero,884(a5) # 80030dfc <memref+0x2001c>
}
    80000a90:	6422                	ld	s0,8(sp)
    80000a92:	0141                	addi	sp,sp,16
    80000a94:	8082                	ret

0000000080000a96 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a96:	1101                	addi	sp,sp,-32
    80000a98:	ec06                	sd	ra,24(sp)
    80000a9a:	e822                	sd	s0,16(sp)
    80000a9c:	e426                	sd	s1,8(sp)
    80000a9e:	e04a                	sd	s2,0(sp)
    80000aa0:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000aa2:	03451793          	slli	a5,a0,0x34
    80000aa6:	efc9                	bnez	a5,80000b40 <kfree+0xaa>
    80000aa8:	84aa                	mv	s1,a0
    80000aaa:	00050797          	auipc	a5,0x50
    80000aae:	d6678793          	addi	a5,a5,-666 # 80050810 <end>
    80000ab2:	08f56763          	bltu	a0,a5,80000b40 <kfree+0xaa>
    80000ab6:	47c5                	li	a5,17
    80000ab8:	07ee                	slli	a5,a5,0x1b
    80000aba:	08f57363          	bgeu	a0,a5,80000b40 <kfree+0xaa>
    panic("kfree");

  memref_lock();
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	f26080e7          	jalr	-218(ra) # 800009e4 <memref_lock>
  if (memref.fr[fn(pa)] > 1) {
    80000ac6:	800007b7          	lui	a5,0x80000
    80000aca:	97a6                	add	a5,a5,s1
    80000acc:	83b1                	srli	a5,a5,0xc
    80000ace:	00478693          	addi	a3,a5,4 # ffffffff80000004 <end+0xfffffffefffaf7f4>
    80000ad2:	068a                	slli	a3,a3,0x2
    80000ad4:	00010717          	auipc	a4,0x10
    80000ad8:	30c70713          	addi	a4,a4,780 # 80010de0 <memref>
    80000adc:	9736                	add	a4,a4,a3
    80000ade:	4718                	lw	a4,8(a4)
    80000ae0:	4685                	li	a3,1
    80000ae2:	06e6c763          	blt	a3,a4,80000b50 <kfree+0xba>
    memref.fr[fn(pa)]--;
    memref_unlock();
    return;
  }

  memref.fr[fn(pa)] = 0;
    80000ae6:	0791                	addi	a5,a5,4
    80000ae8:	078a                	slli	a5,a5,0x2
    80000aea:	00010717          	auipc	a4,0x10
    80000aee:	2f670713          	addi	a4,a4,758 # 80010de0 <memref>
    80000af2:	97ba                	add	a5,a5,a4
    80000af4:	0007a423          	sw	zero,8(a5)
  memref_unlock();
    80000af8:	00000097          	auipc	ra,0x0
    80000afc:	f0c080e7          	jalr	-244(ra) # 80000a04 <memref_unlock>

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000b00:	6605                	lui	a2,0x1
    80000b02:	4585                	li	a1,1
    80000b04:	8526                	mv	a0,s1
    80000b06:	00000097          	auipc	ra,0x0
    80000b0a:	362080e7          	jalr	866(ra) # 80000e68 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000b0e:	00010917          	auipc	s2,0x10
    80000b12:	2b290913          	addi	s2,s2,690 # 80010dc0 <kmem>
    80000b16:	854a                	mv	a0,s2
    80000b18:	00000097          	auipc	ra,0x0
    80000b1c:	254080e7          	jalr	596(ra) # 80000d6c <acquire>
  r->next = kmem.freelist;
    80000b20:	01893783          	ld	a5,24(s2)
    80000b24:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000b26:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000b2a:	854a                	mv	a0,s2
    80000b2c:	00000097          	auipc	ra,0x0
    80000b30:	2f4080e7          	jalr	756(ra) # 80000e20 <release>
}
    80000b34:	60e2                	ld	ra,24(sp)
    80000b36:	6442                	ld	s0,16(sp)
    80000b38:	64a2                	ld	s1,8(sp)
    80000b3a:	6902                	ld	s2,0(sp)
    80000b3c:	6105                	addi	sp,sp,32
    80000b3e:	8082                	ret
    panic("kfree");
    80000b40:	00007517          	auipc	a0,0x7
    80000b44:	52050513          	addi	a0,a0,1312 # 80008060 <digits+0x20>
    80000b48:	00000097          	auipc	ra,0x0
    80000b4c:	9f4080e7          	jalr	-1548(ra) # 8000053c <panic>
    memref.fr[fn(pa)]--;
    80000b50:	0791                	addi	a5,a5,4
    80000b52:	078a                	slli	a5,a5,0x2
    80000b54:	00010697          	auipc	a3,0x10
    80000b58:	28c68693          	addi	a3,a3,652 # 80010de0 <memref>
    80000b5c:	97b6                	add	a5,a5,a3
    80000b5e:	377d                	addiw	a4,a4,-1
    80000b60:	c798                	sw	a4,8(a5)
    memref_unlock();
    80000b62:	00000097          	auipc	ra,0x0
    80000b66:	ea2080e7          	jalr	-350(ra) # 80000a04 <memref_unlock>
    return;
    80000b6a:	b7e9                	j	80000b34 <kfree+0x9e>

0000000080000b6c <freerange>:
{
    80000b6c:	7179                	addi	sp,sp,-48
    80000b6e:	f406                	sd	ra,40(sp)
    80000b70:	f022                	sd	s0,32(sp)
    80000b72:	ec26                	sd	s1,24(sp)
    80000b74:	e84a                	sd	s2,16(sp)
    80000b76:	e44e                	sd	s3,8(sp)
    80000b78:	e052                	sd	s4,0(sp)
    80000b7a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000b7c:	6785                	lui	a5,0x1
    80000b7e:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000b82:	00e504b3          	add	s1,a0,a4
    80000b86:	777d                	lui	a4,0xfffff
    80000b88:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b8a:	94be                	add	s1,s1,a5
    80000b8c:	0095ee63          	bltu	a1,s1,80000ba8 <freerange+0x3c>
    80000b90:	892e                	mv	s2,a1
    kfree(p);
    80000b92:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b94:	6985                	lui	s3,0x1
    kfree(p);
    80000b96:	01448533          	add	a0,s1,s4
    80000b9a:	00000097          	auipc	ra,0x0
    80000b9e:	efc080e7          	jalr	-260(ra) # 80000a96 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ba2:	94ce                	add	s1,s1,s3
    80000ba4:	fe9979e3          	bgeu	s2,s1,80000b96 <freerange+0x2a>
}
    80000ba8:	70a2                	ld	ra,40(sp)
    80000baa:	7402                	ld	s0,32(sp)
    80000bac:	64e2                	ld	s1,24(sp)
    80000bae:	6942                	ld	s2,16(sp)
    80000bb0:	69a2                	ld	s3,8(sp)
    80000bb2:	6a02                	ld	s4,0(sp)
    80000bb4:	6145                	addi	sp,sp,48
    80000bb6:	8082                	ret

0000000080000bb8 <kinit>:
{
    80000bb8:	1141                	addi	sp,sp,-16
    80000bba:	e406                	sd	ra,8(sp)
    80000bbc:	e022                	sd	s0,0(sp)
    80000bbe:	0800                	addi	s0,sp,16
  initlock(&memref.lock, "memref");
    80000bc0:	00007597          	auipc	a1,0x7
    80000bc4:	4a858593          	addi	a1,a1,1192 # 80008068 <digits+0x28>
    80000bc8:	00010517          	auipc	a0,0x10
    80000bcc:	21850513          	addi	a0,a0,536 # 80010de0 <memref>
    80000bd0:	00000097          	auipc	ra,0x0
    80000bd4:	10c080e7          	jalr	268(ra) # 80000cdc <initlock>
  initlock(&kmem.lock, "kmem");
    80000bd8:	00007597          	auipc	a1,0x7
    80000bdc:	49858593          	addi	a1,a1,1176 # 80008070 <digits+0x30>
    80000be0:	00010517          	auipc	a0,0x10
    80000be4:	1e050513          	addi	a0,a0,480 # 80010dc0 <kmem>
    80000be8:	00000097          	auipc	ra,0x0
    80000bec:	0f4080e7          	jalr	244(ra) # 80000cdc <initlock>
  freerange(end, (void*)PHYSTOP);
    80000bf0:	45c5                	li	a1,17
    80000bf2:	05ee                	slli	a1,a1,0x1b
    80000bf4:	00050517          	auipc	a0,0x50
    80000bf8:	c1c50513          	addi	a0,a0,-996 # 80050810 <end>
    80000bfc:	00000097          	auipc	ra,0x0
    80000c00:	f70080e7          	jalr	-144(ra) # 80000b6c <freerange>
  memref.lock_kalloc = 1;
    80000c04:	4785                	li	a5,1
    80000c06:	00030717          	auipc	a4,0x30
    80000c0a:	1ef70b23          	sb	a5,502(a4) # 80030dfc <memref+0x2001c>
  memset((void*)memref.fr, 0, fn(PHYSTOP) + 1);
    80000c0e:	6621                	lui	a2,0x8
    80000c10:	0605                	addi	a2,a2,1 # 8001 <_entry-0x7fff7fff>
    80000c12:	4581                	li	a1,0
    80000c14:	00010517          	auipc	a0,0x10
    80000c18:	1e450513          	addi	a0,a0,484 # 80010df8 <memref+0x18>
    80000c1c:	00000097          	auipc	ra,0x0
    80000c20:	24c080e7          	jalr	588(ra) # 80000e68 <memset>
}
    80000c24:	60a2                	ld	ra,8(sp)
    80000c26:	6402                	ld	s0,0(sp)
    80000c28:	0141                	addi	sp,sp,16
    80000c2a:	8082                	ret

0000000080000c2c <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000c2c:	1101                	addi	sp,sp,-32
    80000c2e:	ec06                	sd	ra,24(sp)
    80000c30:	e822                	sd	s0,16(sp)
    80000c32:	e426                	sd	s1,8(sp)
    80000c34:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000c36:	00010497          	auipc	s1,0x10
    80000c3a:	18a48493          	addi	s1,s1,394 # 80010dc0 <kmem>
    80000c3e:	8526                	mv	a0,s1
    80000c40:	00000097          	auipc	ra,0x0
    80000c44:	12c080e7          	jalr	300(ra) # 80000d6c <acquire>
  r = kmem.freelist;
    80000c48:	6c84                	ld	s1,24(s1)
  if(r)
    80000c4a:	c0c1                	beqz	s1,80000cca <kalloc+0x9e>
    kmem.freelist = r->next;
    80000c4c:	609c                	ld	a5,0(s1)
    80000c4e:	00010517          	auipc	a0,0x10
    80000c52:	17250513          	addi	a0,a0,370 # 80010dc0 <kmem>
    80000c56:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000c58:	00000097          	auipc	ra,0x0
    80000c5c:	1c8080e7          	jalr	456(ra) # 80000e20 <release>

  if(r) {
    if (memref.lock_kalloc) {
    80000c60:	00030797          	auipc	a5,0x30
    80000c64:	19c7c783          	lbu	a5,412(a5) # 80030dfc <memref+0x2001c>
    80000c68:	eb9d                	bnez	a5,80000c9e <kalloc+0x72>
      memref_lock();
      memref.fr[fn(r)] = 1;
      memref_unlock();
    } else {
      memref.fr[fn(r)] = 1;
    80000c6a:	800007b7          	lui	a5,0x80000
    80000c6e:	97a6                	add	a5,a5,s1
    80000c70:	83b1                	srli	a5,a5,0xc
    80000c72:	0791                	addi	a5,a5,4 # ffffffff80000004 <end+0xfffffffefffaf7f4>
    80000c74:	078a                	slli	a5,a5,0x2
    80000c76:	00010717          	auipc	a4,0x10
    80000c7a:	16a70713          	addi	a4,a4,362 # 80010de0 <memref>
    80000c7e:	97ba                	add	a5,a5,a4
    80000c80:	4705                	li	a4,1
    80000c82:	c798                	sw	a4,8(a5)
    }

    memset((char*)r, 5, PGSIZE); // fill with junk
    80000c84:	6605                	lui	a2,0x1
    80000c86:	4595                	li	a1,5
    80000c88:	8526                	mv	a0,s1
    80000c8a:	00000097          	auipc	ra,0x0
    80000c8e:	1de080e7          	jalr	478(ra) # 80000e68 <memset>
  }
  return (void*)r;
}
    80000c92:	8526                	mv	a0,s1
    80000c94:	60e2                	ld	ra,24(sp)
    80000c96:	6442                	ld	s0,16(sp)
    80000c98:	64a2                	ld	s1,8(sp)
    80000c9a:	6105                	addi	sp,sp,32
    80000c9c:	8082                	ret
      memref_lock();
    80000c9e:	00000097          	auipc	ra,0x0
    80000ca2:	d46080e7          	jalr	-698(ra) # 800009e4 <memref_lock>
      memref.fr[fn(r)] = 1;
    80000ca6:	800007b7          	lui	a5,0x80000
    80000caa:	97a6                	add	a5,a5,s1
    80000cac:	83b1                	srli	a5,a5,0xc
    80000cae:	0791                	addi	a5,a5,4 # ffffffff80000004 <end+0xfffffffefffaf7f4>
    80000cb0:	078a                	slli	a5,a5,0x2
    80000cb2:	00010717          	auipc	a4,0x10
    80000cb6:	12e70713          	addi	a4,a4,302 # 80010de0 <memref>
    80000cba:	97ba                	add	a5,a5,a4
    80000cbc:	4705                	li	a4,1
    80000cbe:	c798                	sw	a4,8(a5)
      memref_unlock();
    80000cc0:	00000097          	auipc	ra,0x0
    80000cc4:	d44080e7          	jalr	-700(ra) # 80000a04 <memref_unlock>
    80000cc8:	bf75                	j	80000c84 <kalloc+0x58>
  release(&kmem.lock);
    80000cca:	00010517          	auipc	a0,0x10
    80000cce:	0f650513          	addi	a0,a0,246 # 80010dc0 <kmem>
    80000cd2:	00000097          	auipc	ra,0x0
    80000cd6:	14e080e7          	jalr	334(ra) # 80000e20 <release>
  if(r) {
    80000cda:	bf65                	j	80000c92 <kalloc+0x66>

0000000080000cdc <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000cdc:	1141                	addi	sp,sp,-16
    80000cde:	e422                	sd	s0,8(sp)
    80000ce0:	0800                	addi	s0,sp,16
  lk->name = name;
    80000ce2:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000ce4:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000ce8:	00053823          	sd	zero,16(a0)
}
    80000cec:	6422                	ld	s0,8(sp)
    80000cee:	0141                	addi	sp,sp,16
    80000cf0:	8082                	ret

0000000080000cf2 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000cf2:	411c                	lw	a5,0(a0)
    80000cf4:	e399                	bnez	a5,80000cfa <holding+0x8>
    80000cf6:	4501                	li	a0,0
  return r;
}
    80000cf8:	8082                	ret
{
    80000cfa:	1101                	addi	sp,sp,-32
    80000cfc:	ec06                	sd	ra,24(sp)
    80000cfe:	e822                	sd	s0,16(sp)
    80000d00:	e426                	sd	s1,8(sp)
    80000d02:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000d04:	6904                	ld	s1,16(a0)
    80000d06:	00001097          	auipc	ra,0x1
    80000d0a:	ea8080e7          	jalr	-344(ra) # 80001bae <mycpu>
    80000d0e:	40a48533          	sub	a0,s1,a0
    80000d12:	00153513          	seqz	a0,a0
}
    80000d16:	60e2                	ld	ra,24(sp)
    80000d18:	6442                	ld	s0,16(sp)
    80000d1a:	64a2                	ld	s1,8(sp)
    80000d1c:	6105                	addi	sp,sp,32
    80000d1e:	8082                	ret

0000000080000d20 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000d20:	1101                	addi	sp,sp,-32
    80000d22:	ec06                	sd	ra,24(sp)
    80000d24:	e822                	sd	s0,16(sp)
    80000d26:	e426                	sd	s1,8(sp)
    80000d28:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d2a:	100024f3          	csrr	s1,sstatus
    80000d2e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000d32:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d34:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000d38:	00001097          	auipc	ra,0x1
    80000d3c:	e76080e7          	jalr	-394(ra) # 80001bae <mycpu>
    80000d40:	5d3c                	lw	a5,120(a0)
    80000d42:	cf89                	beqz	a5,80000d5c <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000d44:	00001097          	auipc	ra,0x1
    80000d48:	e6a080e7          	jalr	-406(ra) # 80001bae <mycpu>
    80000d4c:	5d3c                	lw	a5,120(a0)
    80000d4e:	2785                	addiw	a5,a5,1
    80000d50:	dd3c                	sw	a5,120(a0)
}
    80000d52:	60e2                	ld	ra,24(sp)
    80000d54:	6442                	ld	s0,16(sp)
    80000d56:	64a2                	ld	s1,8(sp)
    80000d58:	6105                	addi	sp,sp,32
    80000d5a:	8082                	ret
    mycpu()->intena = old;
    80000d5c:	00001097          	auipc	ra,0x1
    80000d60:	e52080e7          	jalr	-430(ra) # 80001bae <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000d64:	8085                	srli	s1,s1,0x1
    80000d66:	8885                	andi	s1,s1,1
    80000d68:	dd64                	sw	s1,124(a0)
    80000d6a:	bfe9                	j	80000d44 <push_off+0x24>

0000000080000d6c <acquire>:
{
    80000d6c:	1101                	addi	sp,sp,-32
    80000d6e:	ec06                	sd	ra,24(sp)
    80000d70:	e822                	sd	s0,16(sp)
    80000d72:	e426                	sd	s1,8(sp)
    80000d74:	1000                	addi	s0,sp,32
    80000d76:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000d78:	00000097          	auipc	ra,0x0
    80000d7c:	fa8080e7          	jalr	-88(ra) # 80000d20 <push_off>
  if(holding(lk))
    80000d80:	8526                	mv	a0,s1
    80000d82:	00000097          	auipc	ra,0x0
    80000d86:	f70080e7          	jalr	-144(ra) # 80000cf2 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d8a:	4705                	li	a4,1
  if(holding(lk))
    80000d8c:	e115                	bnez	a0,80000db0 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d8e:	87ba                	mv	a5,a4
    80000d90:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000d94:	2781                	sext.w	a5,a5
    80000d96:	ffe5                	bnez	a5,80000d8e <acquire+0x22>
  __sync_synchronize();
    80000d98:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000d9c:	00001097          	auipc	ra,0x1
    80000da0:	e12080e7          	jalr	-494(ra) # 80001bae <mycpu>
    80000da4:	e888                	sd	a0,16(s1)
}
    80000da6:	60e2                	ld	ra,24(sp)
    80000da8:	6442                	ld	s0,16(sp)
    80000daa:	64a2                	ld	s1,8(sp)
    80000dac:	6105                	addi	sp,sp,32
    80000dae:	8082                	ret
    panic("acquire");
    80000db0:	00007517          	auipc	a0,0x7
    80000db4:	2c850513          	addi	a0,a0,712 # 80008078 <digits+0x38>
    80000db8:	fffff097          	auipc	ra,0xfffff
    80000dbc:	784080e7          	jalr	1924(ra) # 8000053c <panic>

0000000080000dc0 <pop_off>:

void
pop_off(void)
{
    80000dc0:	1141                	addi	sp,sp,-16
    80000dc2:	e406                	sd	ra,8(sp)
    80000dc4:	e022                	sd	s0,0(sp)
    80000dc6:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000dc8:	00001097          	auipc	ra,0x1
    80000dcc:	de6080e7          	jalr	-538(ra) # 80001bae <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000dd0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000dd4:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000dd6:	e78d                	bnez	a5,80000e00 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000dd8:	5d3c                	lw	a5,120(a0)
    80000dda:	02f05b63          	blez	a5,80000e10 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000dde:	37fd                	addiw	a5,a5,-1
    80000de0:	0007871b          	sext.w	a4,a5
    80000de4:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000de6:	eb09                	bnez	a4,80000df8 <pop_off+0x38>
    80000de8:	5d7c                	lw	a5,124(a0)
    80000dea:	c799                	beqz	a5,80000df8 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000dec:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000df0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000df4:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000df8:	60a2                	ld	ra,8(sp)
    80000dfa:	6402                	ld	s0,0(sp)
    80000dfc:	0141                	addi	sp,sp,16
    80000dfe:	8082                	ret
    panic("pop_off - interruptible");
    80000e00:	00007517          	auipc	a0,0x7
    80000e04:	28050513          	addi	a0,a0,640 # 80008080 <digits+0x40>
    80000e08:	fffff097          	auipc	ra,0xfffff
    80000e0c:	734080e7          	jalr	1844(ra) # 8000053c <panic>
    panic("pop_off");
    80000e10:	00007517          	auipc	a0,0x7
    80000e14:	28850513          	addi	a0,a0,648 # 80008098 <digits+0x58>
    80000e18:	fffff097          	auipc	ra,0xfffff
    80000e1c:	724080e7          	jalr	1828(ra) # 8000053c <panic>

0000000080000e20 <release>:
{
    80000e20:	1101                	addi	sp,sp,-32
    80000e22:	ec06                	sd	ra,24(sp)
    80000e24:	e822                	sd	s0,16(sp)
    80000e26:	e426                	sd	s1,8(sp)
    80000e28:	1000                	addi	s0,sp,32
    80000e2a:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000e2c:	00000097          	auipc	ra,0x0
    80000e30:	ec6080e7          	jalr	-314(ra) # 80000cf2 <holding>
    80000e34:	c115                	beqz	a0,80000e58 <release+0x38>
  lk->cpu = 0;
    80000e36:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000e3a:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000e3e:	0f50000f          	fence	iorw,ow
    80000e42:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000e46:	00000097          	auipc	ra,0x0
    80000e4a:	f7a080e7          	jalr	-134(ra) # 80000dc0 <pop_off>
}
    80000e4e:	60e2                	ld	ra,24(sp)
    80000e50:	6442                	ld	s0,16(sp)
    80000e52:	64a2                	ld	s1,8(sp)
    80000e54:	6105                	addi	sp,sp,32
    80000e56:	8082                	ret
    panic("release");
    80000e58:	00007517          	auipc	a0,0x7
    80000e5c:	24850513          	addi	a0,a0,584 # 800080a0 <digits+0x60>
    80000e60:	fffff097          	auipc	ra,0xfffff
    80000e64:	6dc080e7          	jalr	1756(ra) # 8000053c <panic>

0000000080000e68 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000e68:	1141                	addi	sp,sp,-16
    80000e6a:	e422                	sd	s0,8(sp)
    80000e6c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000e6e:	ca19                	beqz	a2,80000e84 <memset+0x1c>
    80000e70:	87aa                	mv	a5,a0
    80000e72:	1602                	slli	a2,a2,0x20
    80000e74:	9201                	srli	a2,a2,0x20
    80000e76:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000e7a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000e7e:	0785                	addi	a5,a5,1
    80000e80:	fee79de3          	bne	a5,a4,80000e7a <memset+0x12>
  }
  return dst;
}
    80000e84:	6422                	ld	s0,8(sp)
    80000e86:	0141                	addi	sp,sp,16
    80000e88:	8082                	ret

0000000080000e8a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000e8a:	1141                	addi	sp,sp,-16
    80000e8c:	e422                	sd	s0,8(sp)
    80000e8e:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000e90:	ca05                	beqz	a2,80000ec0 <memcmp+0x36>
    80000e92:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000e96:	1682                	slli	a3,a3,0x20
    80000e98:	9281                	srli	a3,a3,0x20
    80000e9a:	0685                	addi	a3,a3,1
    80000e9c:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000e9e:	00054783          	lbu	a5,0(a0)
    80000ea2:	0005c703          	lbu	a4,0(a1)
    80000ea6:	00e79863          	bne	a5,a4,80000eb6 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000eaa:	0505                	addi	a0,a0,1
    80000eac:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000eae:	fed518e3          	bne	a0,a3,80000e9e <memcmp+0x14>
  }

  return 0;
    80000eb2:	4501                	li	a0,0
    80000eb4:	a019                	j	80000eba <memcmp+0x30>
      return *s1 - *s2;
    80000eb6:	40e7853b          	subw	a0,a5,a4
}
    80000eba:	6422                	ld	s0,8(sp)
    80000ebc:	0141                	addi	sp,sp,16
    80000ebe:	8082                	ret
  return 0;
    80000ec0:	4501                	li	a0,0
    80000ec2:	bfe5                	j	80000eba <memcmp+0x30>

0000000080000ec4 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000ec4:	1141                	addi	sp,sp,-16
    80000ec6:	e422                	sd	s0,8(sp)
    80000ec8:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000eca:	c205                	beqz	a2,80000eea <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000ecc:	02a5e263          	bltu	a1,a0,80000ef0 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000ed0:	1602                	slli	a2,a2,0x20
    80000ed2:	9201                	srli	a2,a2,0x20
    80000ed4:	00c587b3          	add	a5,a1,a2
{
    80000ed8:	872a                	mv	a4,a0
      *d++ = *s++;
    80000eda:	0585                	addi	a1,a1,1
    80000edc:	0705                	addi	a4,a4,1
    80000ede:	fff5c683          	lbu	a3,-1(a1)
    80000ee2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000ee6:	fef59ae3          	bne	a1,a5,80000eda <memmove+0x16>

  return dst;
}
    80000eea:	6422                	ld	s0,8(sp)
    80000eec:	0141                	addi	sp,sp,16
    80000eee:	8082                	ret
  if(s < d && s + n > d){
    80000ef0:	02061693          	slli	a3,a2,0x20
    80000ef4:	9281                	srli	a3,a3,0x20
    80000ef6:	00d58733          	add	a4,a1,a3
    80000efa:	fce57be3          	bgeu	a0,a4,80000ed0 <memmove+0xc>
    d += n;
    80000efe:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000f00:	fff6079b          	addiw	a5,a2,-1
    80000f04:	1782                	slli	a5,a5,0x20
    80000f06:	9381                	srli	a5,a5,0x20
    80000f08:	fff7c793          	not	a5,a5
    80000f0c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000f0e:	177d                	addi	a4,a4,-1
    80000f10:	16fd                	addi	a3,a3,-1
    80000f12:	00074603          	lbu	a2,0(a4)
    80000f16:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000f1a:	fee79ae3          	bne	a5,a4,80000f0e <memmove+0x4a>
    80000f1e:	b7f1                	j	80000eea <memmove+0x26>

0000000080000f20 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000f20:	1141                	addi	sp,sp,-16
    80000f22:	e406                	sd	ra,8(sp)
    80000f24:	e022                	sd	s0,0(sp)
    80000f26:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000f28:	00000097          	auipc	ra,0x0
    80000f2c:	f9c080e7          	jalr	-100(ra) # 80000ec4 <memmove>
}
    80000f30:	60a2                	ld	ra,8(sp)
    80000f32:	6402                	ld	s0,0(sp)
    80000f34:	0141                	addi	sp,sp,16
    80000f36:	8082                	ret

0000000080000f38 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000f38:	1141                	addi	sp,sp,-16
    80000f3a:	e422                	sd	s0,8(sp)
    80000f3c:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000f3e:	ce11                	beqz	a2,80000f5a <strncmp+0x22>
    80000f40:	00054783          	lbu	a5,0(a0)
    80000f44:	cf89                	beqz	a5,80000f5e <strncmp+0x26>
    80000f46:	0005c703          	lbu	a4,0(a1)
    80000f4a:	00f71a63          	bne	a4,a5,80000f5e <strncmp+0x26>
    n--, p++, q++;
    80000f4e:	367d                	addiw	a2,a2,-1
    80000f50:	0505                	addi	a0,a0,1
    80000f52:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000f54:	f675                	bnez	a2,80000f40 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000f56:	4501                	li	a0,0
    80000f58:	a809                	j	80000f6a <strncmp+0x32>
    80000f5a:	4501                	li	a0,0
    80000f5c:	a039                	j	80000f6a <strncmp+0x32>
  if(n == 0)
    80000f5e:	ca09                	beqz	a2,80000f70 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000f60:	00054503          	lbu	a0,0(a0)
    80000f64:	0005c783          	lbu	a5,0(a1)
    80000f68:	9d1d                	subw	a0,a0,a5
}
    80000f6a:	6422                	ld	s0,8(sp)
    80000f6c:	0141                	addi	sp,sp,16
    80000f6e:	8082                	ret
    return 0;
    80000f70:	4501                	li	a0,0
    80000f72:	bfe5                	j	80000f6a <strncmp+0x32>

0000000080000f74 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000f74:	1141                	addi	sp,sp,-16
    80000f76:	e422                	sd	s0,8(sp)
    80000f78:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000f7a:	87aa                	mv	a5,a0
    80000f7c:	86b2                	mv	a3,a2
    80000f7e:	367d                	addiw	a2,a2,-1
    80000f80:	00d05963          	blez	a3,80000f92 <strncpy+0x1e>
    80000f84:	0785                	addi	a5,a5,1
    80000f86:	0005c703          	lbu	a4,0(a1)
    80000f8a:	fee78fa3          	sb	a4,-1(a5)
    80000f8e:	0585                	addi	a1,a1,1
    80000f90:	f775                	bnez	a4,80000f7c <strncpy+0x8>
    ;
  while(n-- > 0)
    80000f92:	873e                	mv	a4,a5
    80000f94:	9fb5                	addw	a5,a5,a3
    80000f96:	37fd                	addiw	a5,a5,-1
    80000f98:	00c05963          	blez	a2,80000faa <strncpy+0x36>
    *s++ = 0;
    80000f9c:	0705                	addi	a4,a4,1
    80000f9e:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000fa2:	40e786bb          	subw	a3,a5,a4
    80000fa6:	fed04be3          	bgtz	a3,80000f9c <strncpy+0x28>
  return os;
}
    80000faa:	6422                	ld	s0,8(sp)
    80000fac:	0141                	addi	sp,sp,16
    80000fae:	8082                	ret

0000000080000fb0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000fb0:	1141                	addi	sp,sp,-16
    80000fb2:	e422                	sd	s0,8(sp)
    80000fb4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000fb6:	02c05363          	blez	a2,80000fdc <safestrcpy+0x2c>
    80000fba:	fff6069b          	addiw	a3,a2,-1
    80000fbe:	1682                	slli	a3,a3,0x20
    80000fc0:	9281                	srli	a3,a3,0x20
    80000fc2:	96ae                	add	a3,a3,a1
    80000fc4:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000fc6:	00d58963          	beq	a1,a3,80000fd8 <safestrcpy+0x28>
    80000fca:	0585                	addi	a1,a1,1
    80000fcc:	0785                	addi	a5,a5,1
    80000fce:	fff5c703          	lbu	a4,-1(a1)
    80000fd2:	fee78fa3          	sb	a4,-1(a5)
    80000fd6:	fb65                	bnez	a4,80000fc6 <safestrcpy+0x16>
    ;
  *s = 0;
    80000fd8:	00078023          	sb	zero,0(a5)
  return os;
}
    80000fdc:	6422                	ld	s0,8(sp)
    80000fde:	0141                	addi	sp,sp,16
    80000fe0:	8082                	ret

0000000080000fe2 <strlen>:

int
strlen(const char *s)
{
    80000fe2:	1141                	addi	sp,sp,-16
    80000fe4:	e422                	sd	s0,8(sp)
    80000fe6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000fe8:	00054783          	lbu	a5,0(a0)
    80000fec:	cf91                	beqz	a5,80001008 <strlen+0x26>
    80000fee:	0505                	addi	a0,a0,1
    80000ff0:	87aa                	mv	a5,a0
    80000ff2:	86be                	mv	a3,a5
    80000ff4:	0785                	addi	a5,a5,1
    80000ff6:	fff7c703          	lbu	a4,-1(a5)
    80000ffa:	ff65                	bnez	a4,80000ff2 <strlen+0x10>
    80000ffc:	40a6853b          	subw	a0,a3,a0
    80001000:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80001002:	6422                	ld	s0,8(sp)
    80001004:	0141                	addi	sp,sp,16
    80001006:	8082                	ret
  for(n = 0; s[n]; n++)
    80001008:	4501                	li	a0,0
    8000100a:	bfe5                	j	80001002 <strlen+0x20>

000000008000100c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    8000100c:	1141                	addi	sp,sp,-16
    8000100e:	e406                	sd	ra,8(sp)
    80001010:	e022                	sd	s0,0(sp)
    80001012:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80001014:	00001097          	auipc	ra,0x1
    80001018:	b8a080e7          	jalr	-1142(ra) # 80001b9e <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    8000101c:	00008717          	auipc	a4,0x8
    80001020:	b3c70713          	addi	a4,a4,-1220 # 80008b58 <started>
  if(cpuid() == 0){
    80001024:	c139                	beqz	a0,8000106a <main+0x5e>
    while(started == 0)
    80001026:	431c                	lw	a5,0(a4)
    80001028:	2781                	sext.w	a5,a5
    8000102a:	dff5                	beqz	a5,80001026 <main+0x1a>
      ;
    __sync_synchronize();
    8000102c:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80001030:	00001097          	auipc	ra,0x1
    80001034:	b6e080e7          	jalr	-1170(ra) # 80001b9e <cpuid>
    80001038:	85aa                	mv	a1,a0
    8000103a:	00007517          	auipc	a0,0x7
    8000103e:	08650513          	addi	a0,a0,134 # 800080c0 <digits+0x80>
    80001042:	fffff097          	auipc	ra,0xfffff
    80001046:	544080e7          	jalr	1348(ra) # 80000586 <printf>
    kvminithart();    // turn on paging
    8000104a:	00000097          	auipc	ra,0x0
    8000104e:	0d8080e7          	jalr	216(ra) # 80001122 <kvminithart>
    trapinithart();   // install kernel trap vector
    80001052:	00002097          	auipc	ra,0x2
    80001056:	c22080e7          	jalr	-990(ra) # 80002c74 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    8000105a:	00005097          	auipc	ra,0x5
    8000105e:	6d6080e7          	jalr	1750(ra) # 80006730 <plicinithart>
  }

  scheduler();        
    80001062:	00001097          	auipc	ra,0x1
    80001066:	208080e7          	jalr	520(ra) # 8000226a <scheduler>
    consoleinit();
    8000106a:	fffff097          	auipc	ra,0xfffff
    8000106e:	3e2080e7          	jalr	994(ra) # 8000044c <consoleinit>
    printfinit();
    80001072:	fffff097          	auipc	ra,0xfffff
    80001076:	6f4080e7          	jalr	1780(ra) # 80000766 <printfinit>
    printf("\n");
    8000107a:	00007517          	auipc	a0,0x7
    8000107e:	05650513          	addi	a0,a0,86 # 800080d0 <digits+0x90>
    80001082:	fffff097          	auipc	ra,0xfffff
    80001086:	504080e7          	jalr	1284(ra) # 80000586 <printf>
    printf("xv6 kernel is booting\n");
    8000108a:	00007517          	auipc	a0,0x7
    8000108e:	01e50513          	addi	a0,a0,30 # 800080a8 <digits+0x68>
    80001092:	fffff097          	auipc	ra,0xfffff
    80001096:	4f4080e7          	jalr	1268(ra) # 80000586 <printf>
    printf("\n");
    8000109a:	00007517          	auipc	a0,0x7
    8000109e:	03650513          	addi	a0,a0,54 # 800080d0 <digits+0x90>
    800010a2:	fffff097          	auipc	ra,0xfffff
    800010a6:	4e4080e7          	jalr	1252(ra) # 80000586 <printf>
    kinit();         // physical page allocator
    800010aa:	00000097          	auipc	ra,0x0
    800010ae:	b0e080e7          	jalr	-1266(ra) # 80000bb8 <kinit>
    kvminit();       // create kernel page table
    800010b2:	00000097          	auipc	ra,0x0
    800010b6:	326080e7          	jalr	806(ra) # 800013d8 <kvminit>
    kvminithart();   // turn on paging
    800010ba:	00000097          	auipc	ra,0x0
    800010be:	068080e7          	jalr	104(ra) # 80001122 <kvminithart>
    procinit();      // process table
    800010c2:	00001097          	auipc	ra,0x1
    800010c6:	a02080e7          	jalr	-1534(ra) # 80001ac4 <procinit>
    trapinit();      // trap vectors
    800010ca:	00002097          	auipc	ra,0x2
    800010ce:	b82080e7          	jalr	-1150(ra) # 80002c4c <trapinit>
    trapinithart();  // install kernel trap vector
    800010d2:	00002097          	auipc	ra,0x2
    800010d6:	ba2080e7          	jalr	-1118(ra) # 80002c74 <trapinithart>
    plicinit();      // set up interrupt controller
    800010da:	00005097          	auipc	ra,0x5
    800010de:	640080e7          	jalr	1600(ra) # 8000671a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    800010e2:	00005097          	auipc	ra,0x5
    800010e6:	64e080e7          	jalr	1614(ra) # 80006730 <plicinithart>
    binit();         // buffer cache
    800010ea:	00003097          	auipc	ra,0x3
    800010ee:	84c080e7          	jalr	-1972(ra) # 80003936 <binit>
    iinit();         // inode table
    800010f2:	00003097          	auipc	ra,0x3
    800010f6:	eea080e7          	jalr	-278(ra) # 80003fdc <iinit>
    fileinit();      // file table
    800010fa:	00004097          	auipc	ra,0x4
    800010fe:	e60080e7          	jalr	-416(ra) # 80004f5a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001102:	00005097          	auipc	ra,0x5
    80001106:	736080e7          	jalr	1846(ra) # 80006838 <virtio_disk_init>
    userinit();      // first user process
    8000110a:	00001097          	auipc	ra,0x1
    8000110e:	e06080e7          	jalr	-506(ra) # 80001f10 <userinit>
    __sync_synchronize();
    80001112:	0ff0000f          	fence
    started = 1;
    80001116:	4785                	li	a5,1
    80001118:	00008717          	auipc	a4,0x8
    8000111c:	a4f72023          	sw	a5,-1472(a4) # 80008b58 <started>
    80001120:	b789                	j	80001062 <main+0x56>

0000000080001122 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001122:	1141                	addi	sp,sp,-16
    80001124:	e422                	sd	s0,8(sp)
    80001126:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001128:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    8000112c:	00008797          	auipc	a5,0x8
    80001130:	a347b783          	ld	a5,-1484(a5) # 80008b60 <kernel_pagetable>
    80001134:	83b1                	srli	a5,a5,0xc
    80001136:	577d                	li	a4,-1
    80001138:	177e                	slli	a4,a4,0x3f
    8000113a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000113c:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001140:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80001144:	6422                	ld	s0,8(sp)
    80001146:	0141                	addi	sp,sp,16
    80001148:	8082                	ret

000000008000114a <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000114a:	7139                	addi	sp,sp,-64
    8000114c:	fc06                	sd	ra,56(sp)
    8000114e:	f822                	sd	s0,48(sp)
    80001150:	f426                	sd	s1,40(sp)
    80001152:	f04a                	sd	s2,32(sp)
    80001154:	ec4e                	sd	s3,24(sp)
    80001156:	e852                	sd	s4,16(sp)
    80001158:	e456                	sd	s5,8(sp)
    8000115a:	e05a                	sd	s6,0(sp)
    8000115c:	0080                	addi	s0,sp,64
    8000115e:	84aa                	mv	s1,a0
    80001160:	89ae                	mv	s3,a1
    80001162:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001164:	57fd                	li	a5,-1
    80001166:	83e9                	srli	a5,a5,0x1a
    80001168:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000116a:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000116c:	04b7f263          	bgeu	a5,a1,800011b0 <walk+0x66>
    panic("walk");
    80001170:	00007517          	auipc	a0,0x7
    80001174:	f6850513          	addi	a0,a0,-152 # 800080d8 <digits+0x98>
    80001178:	fffff097          	auipc	ra,0xfffff
    8000117c:	3c4080e7          	jalr	964(ra) # 8000053c <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001180:	060a8663          	beqz	s5,800011ec <walk+0xa2>
    80001184:	00000097          	auipc	ra,0x0
    80001188:	aa8080e7          	jalr	-1368(ra) # 80000c2c <kalloc>
    8000118c:	84aa                	mv	s1,a0
    8000118e:	c529                	beqz	a0,800011d8 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001190:	6605                	lui	a2,0x1
    80001192:	4581                	li	a1,0
    80001194:	00000097          	auipc	ra,0x0
    80001198:	cd4080e7          	jalr	-812(ra) # 80000e68 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000119c:	00c4d793          	srli	a5,s1,0xc
    800011a0:	07aa                	slli	a5,a5,0xa
    800011a2:	0017e793          	ori	a5,a5,1
    800011a6:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800011aa:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffae7e7>
    800011ac:	036a0063          	beq	s4,s6,800011cc <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800011b0:	0149d933          	srl	s2,s3,s4
    800011b4:	1ff97913          	andi	s2,s2,511
    800011b8:	090e                	slli	s2,s2,0x3
    800011ba:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800011bc:	00093483          	ld	s1,0(s2)
    800011c0:	0014f793          	andi	a5,s1,1
    800011c4:	dfd5                	beqz	a5,80001180 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800011c6:	80a9                	srli	s1,s1,0xa
    800011c8:	04b2                	slli	s1,s1,0xc
    800011ca:	b7c5                	j	800011aa <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800011cc:	00c9d513          	srli	a0,s3,0xc
    800011d0:	1ff57513          	andi	a0,a0,511
    800011d4:	050e                	slli	a0,a0,0x3
    800011d6:	9526                	add	a0,a0,s1
}
    800011d8:	70e2                	ld	ra,56(sp)
    800011da:	7442                	ld	s0,48(sp)
    800011dc:	74a2                	ld	s1,40(sp)
    800011de:	7902                	ld	s2,32(sp)
    800011e0:	69e2                	ld	s3,24(sp)
    800011e2:	6a42                	ld	s4,16(sp)
    800011e4:	6aa2                	ld	s5,8(sp)
    800011e6:	6b02                	ld	s6,0(sp)
    800011e8:	6121                	addi	sp,sp,64
    800011ea:	8082                	ret
        return 0;
    800011ec:	4501                	li	a0,0
    800011ee:	b7ed                	j	800011d8 <walk+0x8e>

00000000800011f0 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800011f0:	57fd                	li	a5,-1
    800011f2:	83e9                	srli	a5,a5,0x1a
    800011f4:	00b7f463          	bgeu	a5,a1,800011fc <walkaddr+0xc>
    return 0;
    800011f8:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800011fa:	8082                	ret
{
    800011fc:	1141                	addi	sp,sp,-16
    800011fe:	e406                	sd	ra,8(sp)
    80001200:	e022                	sd	s0,0(sp)
    80001202:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001204:	4601                	li	a2,0
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f44080e7          	jalr	-188(ra) # 8000114a <walk>
  if(pte == 0)
    8000120e:	c105                	beqz	a0,8000122e <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001210:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001212:	0117f693          	andi	a3,a5,17
    80001216:	4745                	li	a4,17
    return 0;
    80001218:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000121a:	00e68663          	beq	a3,a4,80001226 <walkaddr+0x36>
}
    8000121e:	60a2                	ld	ra,8(sp)
    80001220:	6402                	ld	s0,0(sp)
    80001222:	0141                	addi	sp,sp,16
    80001224:	8082                	ret
  pa = PTE2PA(*pte);
    80001226:	83a9                	srli	a5,a5,0xa
    80001228:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000122c:	bfcd                	j	8000121e <walkaddr+0x2e>
    return 0;
    8000122e:	4501                	li	a0,0
    80001230:	b7fd                	j	8000121e <walkaddr+0x2e>

0000000080001232 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001232:	715d                	addi	sp,sp,-80
    80001234:	e486                	sd	ra,72(sp)
    80001236:	e0a2                	sd	s0,64(sp)
    80001238:	fc26                	sd	s1,56(sp)
    8000123a:	f84a                	sd	s2,48(sp)
    8000123c:	f44e                	sd	s3,40(sp)
    8000123e:	f052                	sd	s4,32(sp)
    80001240:	ec56                	sd	s5,24(sp)
    80001242:	e85a                	sd	s6,16(sp)
    80001244:	e45e                	sd	s7,8(sp)
    80001246:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    80001248:	c639                	beqz	a2,80001296 <mappages+0x64>
    8000124a:	8aaa                	mv	s5,a0
    8000124c:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    8000124e:	777d                	lui	a4,0xfffff
    80001250:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001254:	fff58993          	addi	s3,a1,-1
    80001258:	99b2                	add	s3,s3,a2
    8000125a:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    8000125e:	893e                	mv	s2,a5
    80001260:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001264:	6b85                	lui	s7,0x1
    80001266:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000126a:	4605                	li	a2,1
    8000126c:	85ca                	mv	a1,s2
    8000126e:	8556                	mv	a0,s5
    80001270:	00000097          	auipc	ra,0x0
    80001274:	eda080e7          	jalr	-294(ra) # 8000114a <walk>
    80001278:	cd1d                	beqz	a0,800012b6 <mappages+0x84>
    if(*pte & PTE_V)
    8000127a:	611c                	ld	a5,0(a0)
    8000127c:	8b85                	andi	a5,a5,1
    8000127e:	e785                	bnez	a5,800012a6 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001280:	80b1                	srli	s1,s1,0xc
    80001282:	04aa                	slli	s1,s1,0xa
    80001284:	0164e4b3          	or	s1,s1,s6
    80001288:	0014e493          	ori	s1,s1,1
    8000128c:	e104                	sd	s1,0(a0)
    if(a == last)
    8000128e:	05390063          	beq	s2,s3,800012ce <mappages+0x9c>
    a += PGSIZE;
    80001292:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001294:	bfc9                	j	80001266 <mappages+0x34>
    panic("mappages: size");
    80001296:	00007517          	auipc	a0,0x7
    8000129a:	e4a50513          	addi	a0,a0,-438 # 800080e0 <digits+0xa0>
    8000129e:	fffff097          	auipc	ra,0xfffff
    800012a2:	29e080e7          	jalr	670(ra) # 8000053c <panic>
      panic("mappages: remap");
    800012a6:	00007517          	auipc	a0,0x7
    800012aa:	e4a50513          	addi	a0,a0,-438 # 800080f0 <digits+0xb0>
    800012ae:	fffff097          	auipc	ra,0xfffff
    800012b2:	28e080e7          	jalr	654(ra) # 8000053c <panic>
      return -1;
    800012b6:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800012b8:	60a6                	ld	ra,72(sp)
    800012ba:	6406                	ld	s0,64(sp)
    800012bc:	74e2                	ld	s1,56(sp)
    800012be:	7942                	ld	s2,48(sp)
    800012c0:	79a2                	ld	s3,40(sp)
    800012c2:	7a02                	ld	s4,32(sp)
    800012c4:	6ae2                	ld	s5,24(sp)
    800012c6:	6b42                	ld	s6,16(sp)
    800012c8:	6ba2                	ld	s7,8(sp)
    800012ca:	6161                	addi	sp,sp,80
    800012cc:	8082                	ret
  return 0;
    800012ce:	4501                	li	a0,0
    800012d0:	b7e5                	j	800012b8 <mappages+0x86>

00000000800012d2 <kvmmap>:
{
    800012d2:	1141                	addi	sp,sp,-16
    800012d4:	e406                	sd	ra,8(sp)
    800012d6:	e022                	sd	s0,0(sp)
    800012d8:	0800                	addi	s0,sp,16
    800012da:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800012dc:	86b2                	mv	a3,a2
    800012de:	863e                	mv	a2,a5
    800012e0:	00000097          	auipc	ra,0x0
    800012e4:	f52080e7          	jalr	-174(ra) # 80001232 <mappages>
    800012e8:	e509                	bnez	a0,800012f2 <kvmmap+0x20>
}
    800012ea:	60a2                	ld	ra,8(sp)
    800012ec:	6402                	ld	s0,0(sp)
    800012ee:	0141                	addi	sp,sp,16
    800012f0:	8082                	ret
    panic("kvmmap");
    800012f2:	00007517          	auipc	a0,0x7
    800012f6:	e0e50513          	addi	a0,a0,-498 # 80008100 <digits+0xc0>
    800012fa:	fffff097          	auipc	ra,0xfffff
    800012fe:	242080e7          	jalr	578(ra) # 8000053c <panic>

0000000080001302 <kvmmake>:
{
    80001302:	1101                	addi	sp,sp,-32
    80001304:	ec06                	sd	ra,24(sp)
    80001306:	e822                	sd	s0,16(sp)
    80001308:	e426                	sd	s1,8(sp)
    8000130a:	e04a                	sd	s2,0(sp)
    8000130c:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000130e:	00000097          	auipc	ra,0x0
    80001312:	91e080e7          	jalr	-1762(ra) # 80000c2c <kalloc>
    80001316:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001318:	6605                	lui	a2,0x1
    8000131a:	4581                	li	a1,0
    8000131c:	00000097          	auipc	ra,0x0
    80001320:	b4c080e7          	jalr	-1204(ra) # 80000e68 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001324:	4719                	li	a4,6
    80001326:	6685                	lui	a3,0x1
    80001328:	10000637          	lui	a2,0x10000
    8000132c:	100005b7          	lui	a1,0x10000
    80001330:	8526                	mv	a0,s1
    80001332:	00000097          	auipc	ra,0x0
    80001336:	fa0080e7          	jalr	-96(ra) # 800012d2 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000133a:	4719                	li	a4,6
    8000133c:	6685                	lui	a3,0x1
    8000133e:	10001637          	lui	a2,0x10001
    80001342:	100015b7          	lui	a1,0x10001
    80001346:	8526                	mv	a0,s1
    80001348:	00000097          	auipc	ra,0x0
    8000134c:	f8a080e7          	jalr	-118(ra) # 800012d2 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001350:	4719                	li	a4,6
    80001352:	004006b7          	lui	a3,0x400
    80001356:	0c000637          	lui	a2,0xc000
    8000135a:	0c0005b7          	lui	a1,0xc000
    8000135e:	8526                	mv	a0,s1
    80001360:	00000097          	auipc	ra,0x0
    80001364:	f72080e7          	jalr	-142(ra) # 800012d2 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001368:	00007917          	auipc	s2,0x7
    8000136c:	c9890913          	addi	s2,s2,-872 # 80008000 <etext>
    80001370:	4729                	li	a4,10
    80001372:	80007697          	auipc	a3,0x80007
    80001376:	c8e68693          	addi	a3,a3,-882 # 8000 <_entry-0x7fff8000>
    8000137a:	4605                	li	a2,1
    8000137c:	067e                	slli	a2,a2,0x1f
    8000137e:	85b2                	mv	a1,a2
    80001380:	8526                	mv	a0,s1
    80001382:	00000097          	auipc	ra,0x0
    80001386:	f50080e7          	jalr	-176(ra) # 800012d2 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000138a:	4719                	li	a4,6
    8000138c:	46c5                	li	a3,17
    8000138e:	06ee                	slli	a3,a3,0x1b
    80001390:	412686b3          	sub	a3,a3,s2
    80001394:	864a                	mv	a2,s2
    80001396:	85ca                	mv	a1,s2
    80001398:	8526                	mv	a0,s1
    8000139a:	00000097          	auipc	ra,0x0
    8000139e:	f38080e7          	jalr	-200(ra) # 800012d2 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800013a2:	4729                	li	a4,10
    800013a4:	6685                	lui	a3,0x1
    800013a6:	00006617          	auipc	a2,0x6
    800013aa:	c5a60613          	addi	a2,a2,-934 # 80007000 <_trampoline>
    800013ae:	040005b7          	lui	a1,0x4000
    800013b2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800013b4:	05b2                	slli	a1,a1,0xc
    800013b6:	8526                	mv	a0,s1
    800013b8:	00000097          	auipc	ra,0x0
    800013bc:	f1a080e7          	jalr	-230(ra) # 800012d2 <kvmmap>
  proc_mapstacks(kpgtbl);
    800013c0:	8526                	mv	a0,s1
    800013c2:	00000097          	auipc	ra,0x0
    800013c6:	66c080e7          	jalr	1644(ra) # 80001a2e <proc_mapstacks>
}
    800013ca:	8526                	mv	a0,s1
    800013cc:	60e2                	ld	ra,24(sp)
    800013ce:	6442                	ld	s0,16(sp)
    800013d0:	64a2                	ld	s1,8(sp)
    800013d2:	6902                	ld	s2,0(sp)
    800013d4:	6105                	addi	sp,sp,32
    800013d6:	8082                	ret

00000000800013d8 <kvminit>:
{
    800013d8:	1141                	addi	sp,sp,-16
    800013da:	e406                	sd	ra,8(sp)
    800013dc:	e022                	sd	s0,0(sp)
    800013de:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800013e0:	00000097          	auipc	ra,0x0
    800013e4:	f22080e7          	jalr	-222(ra) # 80001302 <kvmmake>
    800013e8:	00007797          	auipc	a5,0x7
    800013ec:	76a7bc23          	sd	a0,1912(a5) # 80008b60 <kernel_pagetable>
}
    800013f0:	60a2                	ld	ra,8(sp)
    800013f2:	6402                	ld	s0,0(sp)
    800013f4:	0141                	addi	sp,sp,16
    800013f6:	8082                	ret

00000000800013f8 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800013f8:	715d                	addi	sp,sp,-80
    800013fa:	e486                	sd	ra,72(sp)
    800013fc:	e0a2                	sd	s0,64(sp)
    800013fe:	fc26                	sd	s1,56(sp)
    80001400:	f84a                	sd	s2,48(sp)
    80001402:	f44e                	sd	s3,40(sp)
    80001404:	f052                	sd	s4,32(sp)
    80001406:	ec56                	sd	s5,24(sp)
    80001408:	e85a                	sd	s6,16(sp)
    8000140a:	e45e                	sd	s7,8(sp)
    8000140c:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000140e:	03459793          	slli	a5,a1,0x34
    80001412:	e795                	bnez	a5,8000143e <uvmunmap+0x46>
    80001414:	8a2a                	mv	s4,a0
    80001416:	892e                	mv	s2,a1
    80001418:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000141a:	0632                	slli	a2,a2,0xc
    8000141c:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001420:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001422:	6b05                	lui	s6,0x1
    80001424:	0735e263          	bltu	a1,s3,80001488 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001428:	60a6                	ld	ra,72(sp)
    8000142a:	6406                	ld	s0,64(sp)
    8000142c:	74e2                	ld	s1,56(sp)
    8000142e:	7942                	ld	s2,48(sp)
    80001430:	79a2                	ld	s3,40(sp)
    80001432:	7a02                	ld	s4,32(sp)
    80001434:	6ae2                	ld	s5,24(sp)
    80001436:	6b42                	ld	s6,16(sp)
    80001438:	6ba2                	ld	s7,8(sp)
    8000143a:	6161                	addi	sp,sp,80
    8000143c:	8082                	ret
    panic("uvmunmap: not aligned");
    8000143e:	00007517          	auipc	a0,0x7
    80001442:	cca50513          	addi	a0,a0,-822 # 80008108 <digits+0xc8>
    80001446:	fffff097          	auipc	ra,0xfffff
    8000144a:	0f6080e7          	jalr	246(ra) # 8000053c <panic>
      panic("uvmunmap: walk");
    8000144e:	00007517          	auipc	a0,0x7
    80001452:	cd250513          	addi	a0,a0,-814 # 80008120 <digits+0xe0>
    80001456:	fffff097          	auipc	ra,0xfffff
    8000145a:	0e6080e7          	jalr	230(ra) # 8000053c <panic>
      panic("uvmunmap: not mapped");
    8000145e:	00007517          	auipc	a0,0x7
    80001462:	cd250513          	addi	a0,a0,-814 # 80008130 <digits+0xf0>
    80001466:	fffff097          	auipc	ra,0xfffff
    8000146a:	0d6080e7          	jalr	214(ra) # 8000053c <panic>
      panic("uvmunmap: not a leaf");
    8000146e:	00007517          	auipc	a0,0x7
    80001472:	cda50513          	addi	a0,a0,-806 # 80008148 <digits+0x108>
    80001476:	fffff097          	auipc	ra,0xfffff
    8000147a:	0c6080e7          	jalr	198(ra) # 8000053c <panic>
    *pte = 0;
    8000147e:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001482:	995a                	add	s2,s2,s6
    80001484:	fb3972e3          	bgeu	s2,s3,80001428 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001488:	4601                	li	a2,0
    8000148a:	85ca                	mv	a1,s2
    8000148c:	8552                	mv	a0,s4
    8000148e:	00000097          	auipc	ra,0x0
    80001492:	cbc080e7          	jalr	-836(ra) # 8000114a <walk>
    80001496:	84aa                	mv	s1,a0
    80001498:	d95d                	beqz	a0,8000144e <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    8000149a:	6108                	ld	a0,0(a0)
    8000149c:	00157793          	andi	a5,a0,1
    800014a0:	dfdd                	beqz	a5,8000145e <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800014a2:	3ff57793          	andi	a5,a0,1023
    800014a6:	fd7784e3          	beq	a5,s7,8000146e <uvmunmap+0x76>
    if(do_free){
    800014aa:	fc0a8ae3          	beqz	s5,8000147e <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    800014ae:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800014b0:	0532                	slli	a0,a0,0xc
    800014b2:	fffff097          	auipc	ra,0xfffff
    800014b6:	5e4080e7          	jalr	1508(ra) # 80000a96 <kfree>
    800014ba:	b7d1                	j	8000147e <uvmunmap+0x86>

00000000800014bc <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800014bc:	1101                	addi	sp,sp,-32
    800014be:	ec06                	sd	ra,24(sp)
    800014c0:	e822                	sd	s0,16(sp)
    800014c2:	e426                	sd	s1,8(sp)
    800014c4:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800014c6:	fffff097          	auipc	ra,0xfffff
    800014ca:	766080e7          	jalr	1894(ra) # 80000c2c <kalloc>
    800014ce:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800014d0:	c519                	beqz	a0,800014de <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800014d2:	6605                	lui	a2,0x1
    800014d4:	4581                	li	a1,0
    800014d6:	00000097          	auipc	ra,0x0
    800014da:	992080e7          	jalr	-1646(ra) # 80000e68 <memset>
  return pagetable;
}
    800014de:	8526                	mv	a0,s1
    800014e0:	60e2                	ld	ra,24(sp)
    800014e2:	6442                	ld	s0,16(sp)
    800014e4:	64a2                	ld	s1,8(sp)
    800014e6:	6105                	addi	sp,sp,32
    800014e8:	8082                	ret

00000000800014ea <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800014ea:	7179                	addi	sp,sp,-48
    800014ec:	f406                	sd	ra,40(sp)
    800014ee:	f022                	sd	s0,32(sp)
    800014f0:	ec26                	sd	s1,24(sp)
    800014f2:	e84a                	sd	s2,16(sp)
    800014f4:	e44e                	sd	s3,8(sp)
    800014f6:	e052                	sd	s4,0(sp)
    800014f8:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800014fa:	6785                	lui	a5,0x1
    800014fc:	04f67863          	bgeu	a2,a5,8000154c <uvmfirst+0x62>
    80001500:	8a2a                	mv	s4,a0
    80001502:	89ae                	mv	s3,a1
    80001504:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001506:	fffff097          	auipc	ra,0xfffff
    8000150a:	726080e7          	jalr	1830(ra) # 80000c2c <kalloc>
    8000150e:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001510:	6605                	lui	a2,0x1
    80001512:	4581                	li	a1,0
    80001514:	00000097          	auipc	ra,0x0
    80001518:	954080e7          	jalr	-1708(ra) # 80000e68 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000151c:	4779                	li	a4,30
    8000151e:	86ca                	mv	a3,s2
    80001520:	6605                	lui	a2,0x1
    80001522:	4581                	li	a1,0
    80001524:	8552                	mv	a0,s4
    80001526:	00000097          	auipc	ra,0x0
    8000152a:	d0c080e7          	jalr	-756(ra) # 80001232 <mappages>
  memmove(mem, src, sz);
    8000152e:	8626                	mv	a2,s1
    80001530:	85ce                	mv	a1,s3
    80001532:	854a                	mv	a0,s2
    80001534:	00000097          	auipc	ra,0x0
    80001538:	990080e7          	jalr	-1648(ra) # 80000ec4 <memmove>
}
    8000153c:	70a2                	ld	ra,40(sp)
    8000153e:	7402                	ld	s0,32(sp)
    80001540:	64e2                	ld	s1,24(sp)
    80001542:	6942                	ld	s2,16(sp)
    80001544:	69a2                	ld	s3,8(sp)
    80001546:	6a02                	ld	s4,0(sp)
    80001548:	6145                	addi	sp,sp,48
    8000154a:	8082                	ret
    panic("uvmfirst: more than a page");
    8000154c:	00007517          	auipc	a0,0x7
    80001550:	c1450513          	addi	a0,a0,-1004 # 80008160 <digits+0x120>
    80001554:	fffff097          	auipc	ra,0xfffff
    80001558:	fe8080e7          	jalr	-24(ra) # 8000053c <panic>

000000008000155c <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000155c:	1101                	addi	sp,sp,-32
    8000155e:	ec06                	sd	ra,24(sp)
    80001560:	e822                	sd	s0,16(sp)
    80001562:	e426                	sd	s1,8(sp)
    80001564:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001566:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001568:	00b67d63          	bgeu	a2,a1,80001582 <uvmdealloc+0x26>
    8000156c:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000156e:	6785                	lui	a5,0x1
    80001570:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001572:	00f60733          	add	a4,a2,a5
    80001576:	76fd                	lui	a3,0xfffff
    80001578:	8f75                	and	a4,a4,a3
    8000157a:	97ae                	add	a5,a5,a1
    8000157c:	8ff5                	and	a5,a5,a3
    8000157e:	00f76863          	bltu	a4,a5,8000158e <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001582:	8526                	mv	a0,s1
    80001584:	60e2                	ld	ra,24(sp)
    80001586:	6442                	ld	s0,16(sp)
    80001588:	64a2                	ld	s1,8(sp)
    8000158a:	6105                	addi	sp,sp,32
    8000158c:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000158e:	8f99                	sub	a5,a5,a4
    80001590:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001592:	4685                	li	a3,1
    80001594:	0007861b          	sext.w	a2,a5
    80001598:	85ba                	mv	a1,a4
    8000159a:	00000097          	auipc	ra,0x0
    8000159e:	e5e080e7          	jalr	-418(ra) # 800013f8 <uvmunmap>
    800015a2:	b7c5                	j	80001582 <uvmdealloc+0x26>

00000000800015a4 <uvmalloc>:
  if(newsz < oldsz)
    800015a4:	0ab66563          	bltu	a2,a1,8000164e <uvmalloc+0xaa>
{
    800015a8:	7139                	addi	sp,sp,-64
    800015aa:	fc06                	sd	ra,56(sp)
    800015ac:	f822                	sd	s0,48(sp)
    800015ae:	f426                	sd	s1,40(sp)
    800015b0:	f04a                	sd	s2,32(sp)
    800015b2:	ec4e                	sd	s3,24(sp)
    800015b4:	e852                	sd	s4,16(sp)
    800015b6:	e456                	sd	s5,8(sp)
    800015b8:	e05a                	sd	s6,0(sp)
    800015ba:	0080                	addi	s0,sp,64
    800015bc:	8aaa                	mv	s5,a0
    800015be:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800015c0:	6785                	lui	a5,0x1
    800015c2:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015c4:	95be                	add	a1,a1,a5
    800015c6:	77fd                	lui	a5,0xfffff
    800015c8:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800015cc:	08c9f363          	bgeu	s3,a2,80001652 <uvmalloc+0xae>
    800015d0:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800015d2:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800015d6:	fffff097          	auipc	ra,0xfffff
    800015da:	656080e7          	jalr	1622(ra) # 80000c2c <kalloc>
    800015de:	84aa                	mv	s1,a0
    if(mem == 0){
    800015e0:	c51d                	beqz	a0,8000160e <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    800015e2:	6605                	lui	a2,0x1
    800015e4:	4581                	li	a1,0
    800015e6:	00000097          	auipc	ra,0x0
    800015ea:	882080e7          	jalr	-1918(ra) # 80000e68 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800015ee:	875a                	mv	a4,s6
    800015f0:	86a6                	mv	a3,s1
    800015f2:	6605                	lui	a2,0x1
    800015f4:	85ca                	mv	a1,s2
    800015f6:	8556                	mv	a0,s5
    800015f8:	00000097          	auipc	ra,0x0
    800015fc:	c3a080e7          	jalr	-966(ra) # 80001232 <mappages>
    80001600:	e90d                	bnez	a0,80001632 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001602:	6785                	lui	a5,0x1
    80001604:	993e                	add	s2,s2,a5
    80001606:	fd4968e3          	bltu	s2,s4,800015d6 <uvmalloc+0x32>
  return newsz;
    8000160a:	8552                	mv	a0,s4
    8000160c:	a809                	j	8000161e <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000160e:	864e                	mv	a2,s3
    80001610:	85ca                	mv	a1,s2
    80001612:	8556                	mv	a0,s5
    80001614:	00000097          	auipc	ra,0x0
    80001618:	f48080e7          	jalr	-184(ra) # 8000155c <uvmdealloc>
      return 0;
    8000161c:	4501                	li	a0,0
}
    8000161e:	70e2                	ld	ra,56(sp)
    80001620:	7442                	ld	s0,48(sp)
    80001622:	74a2                	ld	s1,40(sp)
    80001624:	7902                	ld	s2,32(sp)
    80001626:	69e2                	ld	s3,24(sp)
    80001628:	6a42                	ld	s4,16(sp)
    8000162a:	6aa2                	ld	s5,8(sp)
    8000162c:	6b02                	ld	s6,0(sp)
    8000162e:	6121                	addi	sp,sp,64
    80001630:	8082                	ret
      kfree(mem);
    80001632:	8526                	mv	a0,s1
    80001634:	fffff097          	auipc	ra,0xfffff
    80001638:	462080e7          	jalr	1122(ra) # 80000a96 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000163c:	864e                	mv	a2,s3
    8000163e:	85ca                	mv	a1,s2
    80001640:	8556                	mv	a0,s5
    80001642:	00000097          	auipc	ra,0x0
    80001646:	f1a080e7          	jalr	-230(ra) # 8000155c <uvmdealloc>
      return 0;
    8000164a:	4501                	li	a0,0
    8000164c:	bfc9                	j	8000161e <uvmalloc+0x7a>
    return oldsz;
    8000164e:	852e                	mv	a0,a1
}
    80001650:	8082                	ret
  return newsz;
    80001652:	8532                	mv	a0,a2
    80001654:	b7e9                	j	8000161e <uvmalloc+0x7a>

0000000080001656 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001656:	7179                	addi	sp,sp,-48
    80001658:	f406                	sd	ra,40(sp)
    8000165a:	f022                	sd	s0,32(sp)
    8000165c:	ec26                	sd	s1,24(sp)
    8000165e:	e84a                	sd	s2,16(sp)
    80001660:	e44e                	sd	s3,8(sp)
    80001662:	e052                	sd	s4,0(sp)
    80001664:	1800                	addi	s0,sp,48
    80001666:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001668:	84aa                	mv	s1,a0
    8000166a:	6905                	lui	s2,0x1
    8000166c:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000166e:	4985                	li	s3,1
    80001670:	a829                	j	8000168a <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001672:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001674:	00c79513          	slli	a0,a5,0xc
    80001678:	00000097          	auipc	ra,0x0
    8000167c:	fde080e7          	jalr	-34(ra) # 80001656 <freewalk>
      pagetable[i] = 0;
    80001680:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001684:	04a1                	addi	s1,s1,8
    80001686:	03248163          	beq	s1,s2,800016a8 <freewalk+0x52>
    pte_t pte = pagetable[i];
    8000168a:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000168c:	00f7f713          	andi	a4,a5,15
    80001690:	ff3701e3          	beq	a4,s3,80001672 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001694:	8b85                	andi	a5,a5,1
    80001696:	d7fd                	beqz	a5,80001684 <freewalk+0x2e>
      panic("freewalk: leaf");
    80001698:	00007517          	auipc	a0,0x7
    8000169c:	ae850513          	addi	a0,a0,-1304 # 80008180 <digits+0x140>
    800016a0:	fffff097          	auipc	ra,0xfffff
    800016a4:	e9c080e7          	jalr	-356(ra) # 8000053c <panic>
    }
  }
  kfree((void*)pagetable);
    800016a8:	8552                	mv	a0,s4
    800016aa:	fffff097          	auipc	ra,0xfffff
    800016ae:	3ec080e7          	jalr	1004(ra) # 80000a96 <kfree>
}
    800016b2:	70a2                	ld	ra,40(sp)
    800016b4:	7402                	ld	s0,32(sp)
    800016b6:	64e2                	ld	s1,24(sp)
    800016b8:	6942                	ld	s2,16(sp)
    800016ba:	69a2                	ld	s3,8(sp)
    800016bc:	6a02                	ld	s4,0(sp)
    800016be:	6145                	addi	sp,sp,48
    800016c0:	8082                	ret

00000000800016c2 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800016c2:	1101                	addi	sp,sp,-32
    800016c4:	ec06                	sd	ra,24(sp)
    800016c6:	e822                	sd	s0,16(sp)
    800016c8:	e426                	sd	s1,8(sp)
    800016ca:	1000                	addi	s0,sp,32
    800016cc:	84aa                	mv	s1,a0
  if(sz > 0)
    800016ce:	e999                	bnez	a1,800016e4 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800016d0:	8526                	mv	a0,s1
    800016d2:	00000097          	auipc	ra,0x0
    800016d6:	f84080e7          	jalr	-124(ra) # 80001656 <freewalk>
}
    800016da:	60e2                	ld	ra,24(sp)
    800016dc:	6442                	ld	s0,16(sp)
    800016de:	64a2                	ld	s1,8(sp)
    800016e0:	6105                	addi	sp,sp,32
    800016e2:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800016e4:	6785                	lui	a5,0x1
    800016e6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800016e8:	95be                	add	a1,a1,a5
    800016ea:	4685                	li	a3,1
    800016ec:	00c5d613          	srli	a2,a1,0xc
    800016f0:	4581                	li	a1,0
    800016f2:	00000097          	auipc	ra,0x0
    800016f6:	d06080e7          	jalr	-762(ra) # 800013f8 <uvmunmap>
    800016fa:	bfd9                	j	800016d0 <uvmfree+0xe>

00000000800016fc <uvmcopy>:
// physical memory.
// returns 0 on success, -1 on failure.
// frees any allocated pages on failure.
int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
    800016fc:	7139                	addi	sp,sp,-64
    800016fe:	fc06                	sd	ra,56(sp)
    80001700:	f822                	sd	s0,48(sp)
    80001702:	f426                	sd	s1,40(sp)
    80001704:	f04a                	sd	s2,32(sp)
    80001706:	ec4e                	sd	s3,24(sp)
    80001708:	e852                	sd	s4,16(sp)
    8000170a:	e456                	sd	s5,8(sp)
    8000170c:	e05a                	sd	s6,0(sp)
    8000170e:	0080                	addi	s0,sp,64
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  // char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001710:	c669                	beqz	a2,800017da <uvmcopy+0xde>
    80001712:	8b2a                	mv	s6,a0
    80001714:	8aae                	mv	s5,a1
    80001716:	8a32                	mv	s4,a2
    80001718:	4901                	li	s2,0
    if((pte = walk(old, i, 0)) == 0)
    8000171a:	4601                	li	a2,0
    8000171c:	85ca                	mv	a1,s2
    8000171e:	855a                	mv	a0,s6
    80001720:	00000097          	auipc	ra,0x0
    80001724:	a2a080e7          	jalr	-1494(ra) # 8000114a <walk>
    80001728:	c525                	beqz	a0,80001790 <uvmcopy+0x94>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000172a:	6118                	ld	a4,0(a0)
    8000172c:	00177793          	andi	a5,a4,1
    80001730:	cba5                	beqz	a5,800017a0 <uvmcopy+0xa4>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001732:	00a75493          	srli	s1,a4,0xa
    80001736:	04b2                	slli	s1,s1,0xc
    flags = PTE_FLAGS(*pte);
    // if((mem = kalloc()) == 0)
    //   goto err;
    // memmove(mem, (char*)pa, PGSIZE);
    *pte = (*pte & (~PTE_W)) | PTE_COW;
    80001738:	dfb77793          	andi	a5,a4,-517
    8000173c:	2007e793          	ori	a5,a5,512
    80001740:	e11c                	sd	a5,0(a0)
    flags = (flags & (~PTE_W)) | PTE_COW;
    80001742:	1fb77713          	andi	a4,a4,507
    if(mappages(new, i, PGSIZE, (uint64)pa, flags) != 0){
    80001746:	20076713          	ori	a4,a4,512
    8000174a:	86a6                	mv	a3,s1
    8000174c:	6605                	lui	a2,0x1
    8000174e:	85ca                	mv	a1,s2
    80001750:	8556                	mv	a0,s5
    80001752:	00000097          	auipc	ra,0x0
    80001756:	ae0080e7          	jalr	-1312(ra) # 80001232 <mappages>
    8000175a:	89aa                	mv	s3,a0
    8000175c:	e931                	bnez	a0,800017b0 <uvmcopy+0xb4>
      // kfree(mem);
      goto err;
    }
    memref_lock();
    8000175e:	fffff097          	auipc	ra,0xfffff
    80001762:	286080e7          	jalr	646(ra) # 800009e4 <memref_lock>
    int fq = memref_get((void*)pa);
    80001766:	8526                	mv	a0,s1
    80001768:	fffff097          	auipc	ra,0xfffff
    8000176c:	2bc080e7          	jalr	700(ra) # 80000a24 <memref_get>
    memref_set((void*)pa, fq + 1);
    80001770:	0015059b          	addiw	a1,a0,1
    80001774:	8526                	mv	a0,s1
    80001776:	fffff097          	auipc	ra,0xfffff
    8000177a:	2d2080e7          	jalr	722(ra) # 80000a48 <memref_set>
    memref_unlock();
    8000177e:	fffff097          	auipc	ra,0xfffff
    80001782:	286080e7          	jalr	646(ra) # 80000a04 <memref_unlock>
  for(i = 0; i < sz; i += PGSIZE){
    80001786:	6785                	lui	a5,0x1
    80001788:	993e                	add	s2,s2,a5
    8000178a:	f94968e3          	bltu	s2,s4,8000171a <uvmcopy+0x1e>
    8000178e:	a81d                	j	800017c4 <uvmcopy+0xc8>
      panic("uvmcopy: pte should exist");
    80001790:	00007517          	auipc	a0,0x7
    80001794:	a0050513          	addi	a0,a0,-1536 # 80008190 <digits+0x150>
    80001798:	fffff097          	auipc	ra,0xfffff
    8000179c:	da4080e7          	jalr	-604(ra) # 8000053c <panic>
      panic("uvmcopy: page not present");
    800017a0:	00007517          	auipc	a0,0x7
    800017a4:	a1050513          	addi	a0,a0,-1520 # 800081b0 <digits+0x170>
    800017a8:	fffff097          	auipc	ra,0xfffff
    800017ac:	d94080e7          	jalr	-620(ra) # 8000053c <panic>
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800017b0:	4685                	li	a3,1
    800017b2:	00c95613          	srli	a2,s2,0xc
    800017b6:	4581                	li	a1,0
    800017b8:	8556                	mv	a0,s5
    800017ba:	00000097          	auipc	ra,0x0
    800017be:	c3e080e7          	jalr	-962(ra) # 800013f8 <uvmunmap>
  return -1;
    800017c2:	59fd                	li	s3,-1
}
    800017c4:	854e                	mv	a0,s3
    800017c6:	70e2                	ld	ra,56(sp)
    800017c8:	7442                	ld	s0,48(sp)
    800017ca:	74a2                	ld	s1,40(sp)
    800017cc:	7902                	ld	s2,32(sp)
    800017ce:	69e2                	ld	s3,24(sp)
    800017d0:	6a42                	ld	s4,16(sp)
    800017d2:	6aa2                	ld	s5,8(sp)
    800017d4:	6b02                	ld	s6,0(sp)
    800017d6:	6121                	addi	sp,sp,64
    800017d8:	8082                	ret
  return 0;
    800017da:	4981                	li	s3,0
    800017dc:	b7e5                	j	800017c4 <uvmcopy+0xc8>

00000000800017de <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800017de:	1141                	addi	sp,sp,-16
    800017e0:	e406                	sd	ra,8(sp)
    800017e2:	e022                	sd	s0,0(sp)
    800017e4:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800017e6:	4601                	li	a2,0
    800017e8:	00000097          	auipc	ra,0x0
    800017ec:	962080e7          	jalr	-1694(ra) # 8000114a <walk>
  if(pte == 0)
    800017f0:	c901                	beqz	a0,80001800 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800017f2:	611c                	ld	a5,0(a0)
    800017f4:	9bbd                	andi	a5,a5,-17
    800017f6:	e11c                	sd	a5,0(a0)
}
    800017f8:	60a2                	ld	ra,8(sp)
    800017fa:	6402                	ld	s0,0(sp)
    800017fc:	0141                	addi	sp,sp,16
    800017fe:	8082                	ret
    panic("uvmclear");
    80001800:	00007517          	auipc	a0,0x7
    80001804:	9d050513          	addi	a0,a0,-1584 # 800081d0 <digits+0x190>
    80001808:	fffff097          	auipc	ra,0xfffff
    8000180c:	d34080e7          	jalr	-716(ra) # 8000053c <panic>

0000000080001810 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001810:	c6bd                	beqz	a3,8000187e <copyout+0x6e>
{
    80001812:	715d                	addi	sp,sp,-80
    80001814:	e486                	sd	ra,72(sp)
    80001816:	e0a2                	sd	s0,64(sp)
    80001818:	fc26                	sd	s1,56(sp)
    8000181a:	f84a                	sd	s2,48(sp)
    8000181c:	f44e                	sd	s3,40(sp)
    8000181e:	f052                	sd	s4,32(sp)
    80001820:	ec56                	sd	s5,24(sp)
    80001822:	e85a                	sd	s6,16(sp)
    80001824:	e45e                	sd	s7,8(sp)
    80001826:	e062                	sd	s8,0(sp)
    80001828:	0880                	addi	s0,sp,80
    8000182a:	8b2a                	mv	s6,a0
    8000182c:	8c2e                	mv	s8,a1
    8000182e:	8a32                	mv	s4,a2
    80001830:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001832:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001834:	6a85                	lui	s5,0x1
    80001836:	a015                	j	8000185a <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001838:	9562                	add	a0,a0,s8
    8000183a:	0004861b          	sext.w	a2,s1
    8000183e:	85d2                	mv	a1,s4
    80001840:	41250533          	sub	a0,a0,s2
    80001844:	fffff097          	auipc	ra,0xfffff
    80001848:	680080e7          	jalr	1664(ra) # 80000ec4 <memmove>

    len -= n;
    8000184c:	409989b3          	sub	s3,s3,s1
    src += n;
    80001850:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001852:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001856:	02098263          	beqz	s3,8000187a <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000185a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000185e:	85ca                	mv	a1,s2
    80001860:	855a                	mv	a0,s6
    80001862:	00000097          	auipc	ra,0x0
    80001866:	98e080e7          	jalr	-1650(ra) # 800011f0 <walkaddr>
    if(pa0 == 0)
    8000186a:	cd01                	beqz	a0,80001882 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000186c:	418904b3          	sub	s1,s2,s8
    80001870:	94d6                	add	s1,s1,s5
    80001872:	fc99f3e3          	bgeu	s3,s1,80001838 <copyout+0x28>
    80001876:	84ce                	mv	s1,s3
    80001878:	b7c1                	j	80001838 <copyout+0x28>
  }
  return 0;
    8000187a:	4501                	li	a0,0
    8000187c:	a021                	j	80001884 <copyout+0x74>
    8000187e:	4501                	li	a0,0
}
    80001880:	8082                	ret
      return -1;
    80001882:	557d                	li	a0,-1
}
    80001884:	60a6                	ld	ra,72(sp)
    80001886:	6406                	ld	s0,64(sp)
    80001888:	74e2                	ld	s1,56(sp)
    8000188a:	7942                	ld	s2,48(sp)
    8000188c:	79a2                	ld	s3,40(sp)
    8000188e:	7a02                	ld	s4,32(sp)
    80001890:	6ae2                	ld	s5,24(sp)
    80001892:	6b42                	ld	s6,16(sp)
    80001894:	6ba2                	ld	s7,8(sp)
    80001896:	6c02                	ld	s8,0(sp)
    80001898:	6161                	addi	sp,sp,80
    8000189a:	8082                	ret

000000008000189c <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000189c:	caa5                	beqz	a3,8000190c <copyin+0x70>
{
    8000189e:	715d                	addi	sp,sp,-80
    800018a0:	e486                	sd	ra,72(sp)
    800018a2:	e0a2                	sd	s0,64(sp)
    800018a4:	fc26                	sd	s1,56(sp)
    800018a6:	f84a                	sd	s2,48(sp)
    800018a8:	f44e                	sd	s3,40(sp)
    800018aa:	f052                	sd	s4,32(sp)
    800018ac:	ec56                	sd	s5,24(sp)
    800018ae:	e85a                	sd	s6,16(sp)
    800018b0:	e45e                	sd	s7,8(sp)
    800018b2:	e062                	sd	s8,0(sp)
    800018b4:	0880                	addi	s0,sp,80
    800018b6:	8b2a                	mv	s6,a0
    800018b8:	8a2e                	mv	s4,a1
    800018ba:	8c32                	mv	s8,a2
    800018bc:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800018be:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800018c0:	6a85                	lui	s5,0x1
    800018c2:	a01d                	j	800018e8 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800018c4:	018505b3          	add	a1,a0,s8
    800018c8:	0004861b          	sext.w	a2,s1
    800018cc:	412585b3          	sub	a1,a1,s2
    800018d0:	8552                	mv	a0,s4
    800018d2:	fffff097          	auipc	ra,0xfffff
    800018d6:	5f2080e7          	jalr	1522(ra) # 80000ec4 <memmove>

    len -= n;
    800018da:	409989b3          	sub	s3,s3,s1
    dst += n;
    800018de:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800018e0:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800018e4:	02098263          	beqz	s3,80001908 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800018e8:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800018ec:	85ca                	mv	a1,s2
    800018ee:	855a                	mv	a0,s6
    800018f0:	00000097          	auipc	ra,0x0
    800018f4:	900080e7          	jalr	-1792(ra) # 800011f0 <walkaddr>
    if(pa0 == 0)
    800018f8:	cd01                	beqz	a0,80001910 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800018fa:	418904b3          	sub	s1,s2,s8
    800018fe:	94d6                	add	s1,s1,s5
    80001900:	fc99f2e3          	bgeu	s3,s1,800018c4 <copyin+0x28>
    80001904:	84ce                	mv	s1,s3
    80001906:	bf7d                	j	800018c4 <copyin+0x28>
  }
  return 0;
    80001908:	4501                	li	a0,0
    8000190a:	a021                	j	80001912 <copyin+0x76>
    8000190c:	4501                	li	a0,0
}
    8000190e:	8082                	ret
      return -1;
    80001910:	557d                	li	a0,-1
}
    80001912:	60a6                	ld	ra,72(sp)
    80001914:	6406                	ld	s0,64(sp)
    80001916:	74e2                	ld	s1,56(sp)
    80001918:	7942                	ld	s2,48(sp)
    8000191a:	79a2                	ld	s3,40(sp)
    8000191c:	7a02                	ld	s4,32(sp)
    8000191e:	6ae2                	ld	s5,24(sp)
    80001920:	6b42                	ld	s6,16(sp)
    80001922:	6ba2                	ld	s7,8(sp)
    80001924:	6c02                	ld	s8,0(sp)
    80001926:	6161                	addi	sp,sp,80
    80001928:	8082                	ret

000000008000192a <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000192a:	c2dd                	beqz	a3,800019d0 <copyinstr+0xa6>
{
    8000192c:	715d                	addi	sp,sp,-80
    8000192e:	e486                	sd	ra,72(sp)
    80001930:	e0a2                	sd	s0,64(sp)
    80001932:	fc26                	sd	s1,56(sp)
    80001934:	f84a                	sd	s2,48(sp)
    80001936:	f44e                	sd	s3,40(sp)
    80001938:	f052                	sd	s4,32(sp)
    8000193a:	ec56                	sd	s5,24(sp)
    8000193c:	e85a                	sd	s6,16(sp)
    8000193e:	e45e                	sd	s7,8(sp)
    80001940:	0880                	addi	s0,sp,80
    80001942:	8a2a                	mv	s4,a0
    80001944:	8b2e                	mv	s6,a1
    80001946:	8bb2                	mv	s7,a2
    80001948:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000194a:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000194c:	6985                	lui	s3,0x1
    8000194e:	a02d                	j	80001978 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001950:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001954:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001956:	37fd                	addiw	a5,a5,-1
    80001958:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000195c:	60a6                	ld	ra,72(sp)
    8000195e:	6406                	ld	s0,64(sp)
    80001960:	74e2                	ld	s1,56(sp)
    80001962:	7942                	ld	s2,48(sp)
    80001964:	79a2                	ld	s3,40(sp)
    80001966:	7a02                	ld	s4,32(sp)
    80001968:	6ae2                	ld	s5,24(sp)
    8000196a:	6b42                	ld	s6,16(sp)
    8000196c:	6ba2                	ld	s7,8(sp)
    8000196e:	6161                	addi	sp,sp,80
    80001970:	8082                	ret
    srcva = va0 + PGSIZE;
    80001972:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001976:	c8a9                	beqz	s1,800019c8 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    80001978:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000197c:	85ca                	mv	a1,s2
    8000197e:	8552                	mv	a0,s4
    80001980:	00000097          	auipc	ra,0x0
    80001984:	870080e7          	jalr	-1936(ra) # 800011f0 <walkaddr>
    if(pa0 == 0)
    80001988:	c131                	beqz	a0,800019cc <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    8000198a:	417906b3          	sub	a3,s2,s7
    8000198e:	96ce                	add	a3,a3,s3
    80001990:	00d4f363          	bgeu	s1,a3,80001996 <copyinstr+0x6c>
    80001994:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001996:	955e                	add	a0,a0,s7
    80001998:	41250533          	sub	a0,a0,s2
    while(n > 0){
    8000199c:	daf9                	beqz	a3,80001972 <copyinstr+0x48>
    8000199e:	87da                	mv	a5,s6
    800019a0:	885a                	mv	a6,s6
      if(*p == '\0'){
    800019a2:	41650633          	sub	a2,a0,s6
    while(n > 0){
    800019a6:	96da                	add	a3,a3,s6
    800019a8:	85be                	mv	a1,a5
      if(*p == '\0'){
    800019aa:	00f60733          	add	a4,a2,a5
    800019ae:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffae7f0>
    800019b2:	df59                	beqz	a4,80001950 <copyinstr+0x26>
        *dst = *p;
    800019b4:	00e78023          	sb	a4,0(a5)
      dst++;
    800019b8:	0785                	addi	a5,a5,1
    while(n > 0){
    800019ba:	fed797e3          	bne	a5,a3,800019a8 <copyinstr+0x7e>
    800019be:	14fd                	addi	s1,s1,-1
    800019c0:	94c2                	add	s1,s1,a6
      --max;
    800019c2:	8c8d                	sub	s1,s1,a1
      dst++;
    800019c4:	8b3e                	mv	s6,a5
    800019c6:	b775                	j	80001972 <copyinstr+0x48>
    800019c8:	4781                	li	a5,0
    800019ca:	b771                	j	80001956 <copyinstr+0x2c>
      return -1;
    800019cc:	557d                	li	a0,-1
    800019ce:	b779                	j	8000195c <copyinstr+0x32>
  int got_null = 0;
    800019d0:	4781                	li	a5,0
  if(got_null){
    800019d2:	37fd                	addiw	a5,a5,-1
    800019d4:	0007851b          	sext.w	a0,a5
}
    800019d8:	8082                	ret

00000000800019da <rand>:

#define RAND_MAX    32767

// src (https://stackoverflow.com/questions/4768180/rand-implementation)
int rand(uint64 seed) // RAND_MAX assumed to be 32767
{
    800019da:	1141                	addi	sp,sp,-16
    800019dc:	e422                	sd	s0,8(sp)
    800019de:	0800                	addi	s0,sp,16
  seed = seed * 1103515245 + 12345;
    800019e0:	41c657b7          	lui	a5,0x41c65
    800019e4:	e6d78793          	addi	a5,a5,-403 # 41c64e6d <_entry-0x3e39b193>
    800019e8:	02f50533          	mul	a0,a0,a5
    800019ec:	678d                	lui	a5,0x3
    800019ee:	03978793          	addi	a5,a5,57 # 3039 <_entry-0x7fffcfc7>
    800019f2:	953e                	add	a0,a0,a5
  return (unsigned int)(seed/65536) % 32768;
    800019f4:	1506                	slli	a0,a0,0x21
    800019f6:	9145                	srli	a0,a0,0x31
    800019f8:	6422                	ld	s0,8(sp)
    800019fa:	0141                	addi	sp,sp,16
    800019fc:	8082                	ret

00000000800019fe <max>:
// parents are not lost. helps obey the
// memory model when using p->parent.
// must be acquired before any p->lock.
struct spinlock wait_lock;

int max(int A, int B){
    800019fe:	1141                	addi	sp,sp,-16
    80001a00:	e422                	sd	s0,8(sp)
    80001a02:	0800                	addi	s0,sp,16
  return A>B ? A:B;
    80001a04:	87ae                	mv	a5,a1
    80001a06:	00a5d363          	bge	a1,a0,80001a0c <max+0xe>
    80001a0a:	87aa                	mv	a5,a0
}
    80001a0c:	0007851b          	sext.w	a0,a5
    80001a10:	6422                	ld	s0,8(sp)
    80001a12:	0141                	addi	sp,sp,16
    80001a14:	8082                	ret

0000000080001a16 <min>:

int min(int A, int B){
    80001a16:	1141                	addi	sp,sp,-16
    80001a18:	e422                	sd	s0,8(sp)
    80001a1a:	0800                	addi	s0,sp,16
  return A>B ? B:A;
    80001a1c:	87aa                	mv	a5,a0
    80001a1e:	00a5d363          	bge	a1,a0,80001a24 <min+0xe>
    80001a22:	87ae                	mv	a5,a1
}
    80001a24:	0007851b          	sext.w	a0,a5
    80001a28:	6422                	ld	s0,8(sp)
    80001a2a:	0141                	addi	sp,sp,16
    80001a2c:	8082                	ret

0000000080001a2e <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001a2e:	7139                	addi	sp,sp,-64
    80001a30:	fc06                	sd	ra,56(sp)
    80001a32:	f822                	sd	s0,48(sp)
    80001a34:	f426                	sd	s1,40(sp)
    80001a36:	f04a                	sd	s2,32(sp)
    80001a38:	ec4e                	sd	s3,24(sp)
    80001a3a:	e852                	sd	s4,16(sp)
    80001a3c:	e456                	sd	s5,8(sp)
    80001a3e:	e05a                	sd	s6,0(sp)
    80001a40:	0080                	addi	s0,sp,64
    80001a42:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a44:	00030497          	auipc	s1,0x30
    80001a48:	1ec48493          	addi	s1,s1,492 # 80031c30 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001a4c:	8b26                	mv	s6,s1
    80001a4e:	00006a97          	auipc	s5,0x6
    80001a52:	5b2a8a93          	addi	s5,s5,1458 # 80008000 <etext>
    80001a56:	04000937          	lui	s2,0x4000
    80001a5a:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001a5c:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a5e:	00044a17          	auipc	s4,0x44
    80001a62:	9d2a0a13          	addi	s4,s4,-1582 # 80045430 <tickslock>
    char *pa = kalloc();
    80001a66:	fffff097          	auipc	ra,0xfffff
    80001a6a:	1c6080e7          	jalr	454(ra) # 80000c2c <kalloc>
    80001a6e:	862a                	mv	a2,a0
    if(pa == 0)
    80001a70:	c131                	beqz	a0,80001ab4 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001a72:	416485b3          	sub	a1,s1,s6
    80001a76:	8595                	srai	a1,a1,0x5
    80001a78:	000ab783          	ld	a5,0(s5)
    80001a7c:	02f585b3          	mul	a1,a1,a5
    80001a80:	2585                	addiw	a1,a1,1
    80001a82:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a86:	4719                	li	a4,6
    80001a88:	6685                	lui	a3,0x1
    80001a8a:	40b905b3          	sub	a1,s2,a1
    80001a8e:	854e                	mv	a0,s3
    80001a90:	00000097          	auipc	ra,0x0
    80001a94:	842080e7          	jalr	-1982(ra) # 800012d2 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a98:	4e048493          	addi	s1,s1,1248
    80001a9c:	fd4495e3          	bne	s1,s4,80001a66 <proc_mapstacks+0x38>
  }
}
    80001aa0:	70e2                	ld	ra,56(sp)
    80001aa2:	7442                	ld	s0,48(sp)
    80001aa4:	74a2                	ld	s1,40(sp)
    80001aa6:	7902                	ld	s2,32(sp)
    80001aa8:	69e2                	ld	s3,24(sp)
    80001aaa:	6a42                	ld	s4,16(sp)
    80001aac:	6aa2                	ld	s5,8(sp)
    80001aae:	6b02                	ld	s6,0(sp)
    80001ab0:	6121                	addi	sp,sp,64
    80001ab2:	8082                	ret
      panic("kalloc");
    80001ab4:	00006517          	auipc	a0,0x6
    80001ab8:	72c50513          	addi	a0,a0,1836 # 800081e0 <digits+0x1a0>
    80001abc:	fffff097          	auipc	ra,0xfffff
    80001ac0:	a80080e7          	jalr	-1408(ra) # 8000053c <panic>

0000000080001ac4 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001ac4:	7139                	addi	sp,sp,-64
    80001ac6:	fc06                	sd	ra,56(sp)
    80001ac8:	f822                	sd	s0,48(sp)
    80001aca:	f426                	sd	s1,40(sp)
    80001acc:	f04a                	sd	s2,32(sp)
    80001ace:	ec4e                	sd	s3,24(sp)
    80001ad0:	e852                	sd	s4,16(sp)
    80001ad2:	e456                	sd	s5,8(sp)
    80001ad4:	e05a                	sd	s6,0(sp)
    80001ad6:	0080                	addi	s0,sp,64
  int i, j;
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001ad8:	00006597          	auipc	a1,0x6
    80001adc:	71058593          	addi	a1,a1,1808 # 800081e8 <digits+0x1a8>
    80001ae0:	0002f517          	auipc	a0,0x2f
    80001ae4:	32050513          	addi	a0,a0,800 # 80030e00 <pid_lock>
    80001ae8:	fffff097          	auipc	ra,0xfffff
    80001aec:	1f4080e7          	jalr	500(ra) # 80000cdc <initlock>
  initlock(&wait_lock, "wait_lock");
    80001af0:	00006597          	auipc	a1,0x6
    80001af4:	70058593          	addi	a1,a1,1792 # 800081f0 <digits+0x1b0>
    80001af8:	0002f517          	auipc	a0,0x2f
    80001afc:	32050513          	addi	a0,a0,800 # 80030e18 <wait_lock>
    80001b00:	fffff097          	auipc	ra,0xfffff
    80001b04:	1dc080e7          	jalr	476(ra) # 80000cdc <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b08:	00030497          	auipc	s1,0x30
    80001b0c:	12848493          	addi	s1,s1,296 # 80031c30 <proc>
      initlock(&p->lock, "proc");
    80001b10:	00006b17          	auipc	s6,0x6
    80001b14:	6f0b0b13          	addi	s6,s6,1776 # 80008200 <digits+0x1c0>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001b18:	8aa6                	mv	s5,s1
    80001b1a:	00006a17          	auipc	s4,0x6
    80001b1e:	4e6a0a13          	addi	s4,s4,1254 # 80008000 <etext>
    80001b22:	04000937          	lui	s2,0x4000
    80001b26:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001b28:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b2a:	00044997          	auipc	s3,0x44
    80001b2e:	90698993          	addi	s3,s3,-1786 # 80045430 <tickslock>
      initlock(&p->lock, "proc");
    80001b32:	85da                	mv	a1,s6
    80001b34:	8526                	mv	a0,s1
    80001b36:	fffff097          	auipc	ra,0xfffff
    80001b3a:	1a6080e7          	jalr	422(ra) # 80000cdc <initlock>
      p->state = UNUSED;
    80001b3e:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001b42:	415487b3          	sub	a5,s1,s5
    80001b46:	8795                	srai	a5,a5,0x5
    80001b48:	000a3703          	ld	a4,0(s4)
    80001b4c:	02e787b3          	mul	a5,a5,a4
    80001b50:	2785                	addiw	a5,a5,1
    80001b52:	00d7979b          	slliw	a5,a5,0xd
    80001b56:	40f907b3          	sub	a5,s2,a5
    80001b5a:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b5c:	4e048493          	addi	s1,s1,1248
    80001b60:	fd3499e3          	bne	s1,s3,80001b32 <procinit+0x6e>
    80001b64:	00030717          	auipc	a4,0x30
    80001b68:	8cc70713          	addi	a4,a4,-1844 # 80031430 <queue+0x200>
    80001b6c:	00030697          	auipc	a3,0x30
    80001b70:	2c468693          	addi	a3,a3,708 # 80031e30 <proc+0x200>
  }
  for(i = 0; i < NPR; i++) {
    for (j = 0; j < NPROC; j++) {
    80001b74:	e0070793          	addi	a5,a4,-512
      queue[i][j] = 0;
    80001b78:	0007b023          	sd	zero,0(a5)
    for (j = 0; j < NPROC; j++) {
    80001b7c:	07a1                	addi	a5,a5,8
    80001b7e:	fee79de3          	bne	a5,a4,80001b78 <procinit+0xb4>
  for(i = 0; i < NPR; i++) {
    80001b82:	20070713          	addi	a4,a4,512
    80001b86:	fed717e3          	bne	a4,a3,80001b74 <procinit+0xb0>
    }
  }
}
    80001b8a:	70e2                	ld	ra,56(sp)
    80001b8c:	7442                	ld	s0,48(sp)
    80001b8e:	74a2                	ld	s1,40(sp)
    80001b90:	7902                	ld	s2,32(sp)
    80001b92:	69e2                	ld	s3,24(sp)
    80001b94:	6a42                	ld	s4,16(sp)
    80001b96:	6aa2                	ld	s5,8(sp)
    80001b98:	6b02                	ld	s6,0(sp)
    80001b9a:	6121                	addi	sp,sp,64
    80001b9c:	8082                	ret

0000000080001b9e <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001b9e:	1141                	addi	sp,sp,-16
    80001ba0:	e422                	sd	s0,8(sp)
    80001ba2:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ba4:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001ba6:	2501                	sext.w	a0,a0
    80001ba8:	6422                	ld	s0,8(sp)
    80001baa:	0141                	addi	sp,sp,16
    80001bac:	8082                	ret

0000000080001bae <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001bae:	1141                	addi	sp,sp,-16
    80001bb0:	e422                	sd	s0,8(sp)
    80001bb2:	0800                	addi	s0,sp,16
    80001bb4:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001bb6:	2781                	sext.w	a5,a5
    80001bb8:	079e                	slli	a5,a5,0x7
  return c;
}
    80001bba:	0002f517          	auipc	a0,0x2f
    80001bbe:	27650513          	addi	a0,a0,630 # 80030e30 <cpus>
    80001bc2:	953e                	add	a0,a0,a5
    80001bc4:	6422                	ld	s0,8(sp)
    80001bc6:	0141                	addi	sp,sp,16
    80001bc8:	8082                	ret

0000000080001bca <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001bca:	1101                	addi	sp,sp,-32
    80001bcc:	ec06                	sd	ra,24(sp)
    80001bce:	e822                	sd	s0,16(sp)
    80001bd0:	e426                	sd	s1,8(sp)
    80001bd2:	1000                	addi	s0,sp,32
  push_off();
    80001bd4:	fffff097          	auipc	ra,0xfffff
    80001bd8:	14c080e7          	jalr	332(ra) # 80000d20 <push_off>
    80001bdc:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001bde:	2781                	sext.w	a5,a5
    80001be0:	079e                	slli	a5,a5,0x7
    80001be2:	0002f717          	auipc	a4,0x2f
    80001be6:	21e70713          	addi	a4,a4,542 # 80030e00 <pid_lock>
    80001bea:	97ba                	add	a5,a5,a4
    80001bec:	7b84                	ld	s1,48(a5)
  pop_off();
    80001bee:	fffff097          	auipc	ra,0xfffff
    80001bf2:	1d2080e7          	jalr	466(ra) # 80000dc0 <pop_off>
  return p;
}
    80001bf6:	8526                	mv	a0,s1
    80001bf8:	60e2                	ld	ra,24(sp)
    80001bfa:	6442                	ld	s0,16(sp)
    80001bfc:	64a2                	ld	s1,8(sp)
    80001bfe:	6105                	addi	sp,sp,32
    80001c00:	8082                	ret

0000000080001c02 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001c02:	1141                	addi	sp,sp,-16
    80001c04:	e406                	sd	ra,8(sp)
    80001c06:	e022                	sd	s0,0(sp)
    80001c08:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001c0a:	00000097          	auipc	ra,0x0
    80001c0e:	fc0080e7          	jalr	-64(ra) # 80001bca <myproc>
    80001c12:	fffff097          	auipc	ra,0xfffff
    80001c16:	20e080e7          	jalr	526(ra) # 80000e20 <release>

  if (first) {
    80001c1a:	00007797          	auipc	a5,0x7
    80001c1e:	ed67a783          	lw	a5,-298(a5) # 80008af0 <first.1>
    80001c22:	eb89                	bnez	a5,80001c34 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001c24:	00001097          	auipc	ra,0x1
    80001c28:	18e080e7          	jalr	398(ra) # 80002db2 <usertrapret>
}
    80001c2c:	60a2                	ld	ra,8(sp)
    80001c2e:	6402                	ld	s0,0(sp)
    80001c30:	0141                	addi	sp,sp,16
    80001c32:	8082                	ret
    first = 0;
    80001c34:	00007797          	auipc	a5,0x7
    80001c38:	ea07ae23          	sw	zero,-324(a5) # 80008af0 <first.1>
    fsinit(ROOTDEV);
    80001c3c:	4505                	li	a0,1
    80001c3e:	00002097          	auipc	ra,0x2
    80001c42:	31e080e7          	jalr	798(ra) # 80003f5c <fsinit>
    80001c46:	bff9                	j	80001c24 <forkret+0x22>

0000000080001c48 <allocpid>:
{
    80001c48:	1101                	addi	sp,sp,-32
    80001c4a:	ec06                	sd	ra,24(sp)
    80001c4c:	e822                	sd	s0,16(sp)
    80001c4e:	e426                	sd	s1,8(sp)
    80001c50:	e04a                	sd	s2,0(sp)
    80001c52:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001c54:	0002f917          	auipc	s2,0x2f
    80001c58:	1ac90913          	addi	s2,s2,428 # 80030e00 <pid_lock>
    80001c5c:	854a                	mv	a0,s2
    80001c5e:	fffff097          	auipc	ra,0xfffff
    80001c62:	10e080e7          	jalr	270(ra) # 80000d6c <acquire>
  pid = nextpid;
    80001c66:	00007797          	auipc	a5,0x7
    80001c6a:	e8e78793          	addi	a5,a5,-370 # 80008af4 <nextpid>
    80001c6e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001c70:	0014871b          	addiw	a4,s1,1
    80001c74:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001c76:	854a                	mv	a0,s2
    80001c78:	fffff097          	auipc	ra,0xfffff
    80001c7c:	1a8080e7          	jalr	424(ra) # 80000e20 <release>
}
    80001c80:	8526                	mv	a0,s1
    80001c82:	60e2                	ld	ra,24(sp)
    80001c84:	6442                	ld	s0,16(sp)
    80001c86:	64a2                	ld	s1,8(sp)
    80001c88:	6902                	ld	s2,0(sp)
    80001c8a:	6105                	addi	sp,sp,32
    80001c8c:	8082                	ret

0000000080001c8e <proc_pagetable>:
{
    80001c8e:	1101                	addi	sp,sp,-32
    80001c90:	ec06                	sd	ra,24(sp)
    80001c92:	e822                	sd	s0,16(sp)
    80001c94:	e426                	sd	s1,8(sp)
    80001c96:	e04a                	sd	s2,0(sp)
    80001c98:	1000                	addi	s0,sp,32
    80001c9a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c9c:	00000097          	auipc	ra,0x0
    80001ca0:	820080e7          	jalr	-2016(ra) # 800014bc <uvmcreate>
    80001ca4:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001ca6:	c121                	beqz	a0,80001ce6 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ca8:	4729                	li	a4,10
    80001caa:	00005697          	auipc	a3,0x5
    80001cae:	35668693          	addi	a3,a3,854 # 80007000 <_trampoline>
    80001cb2:	6605                	lui	a2,0x1
    80001cb4:	040005b7          	lui	a1,0x4000
    80001cb8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001cba:	05b2                	slli	a1,a1,0xc
    80001cbc:	fffff097          	auipc	ra,0xfffff
    80001cc0:	576080e7          	jalr	1398(ra) # 80001232 <mappages>
    80001cc4:	02054863          	bltz	a0,80001cf4 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001cc8:	4719                	li	a4,6
    80001cca:	05893683          	ld	a3,88(s2)
    80001cce:	6605                	lui	a2,0x1
    80001cd0:	020005b7          	lui	a1,0x2000
    80001cd4:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001cd6:	05b6                	slli	a1,a1,0xd
    80001cd8:	8526                	mv	a0,s1
    80001cda:	fffff097          	auipc	ra,0xfffff
    80001cde:	558080e7          	jalr	1368(ra) # 80001232 <mappages>
    80001ce2:	02054163          	bltz	a0,80001d04 <proc_pagetable+0x76>
}
    80001ce6:	8526                	mv	a0,s1
    80001ce8:	60e2                	ld	ra,24(sp)
    80001cea:	6442                	ld	s0,16(sp)
    80001cec:	64a2                	ld	s1,8(sp)
    80001cee:	6902                	ld	s2,0(sp)
    80001cf0:	6105                	addi	sp,sp,32
    80001cf2:	8082                	ret
    uvmfree(pagetable, 0);
    80001cf4:	4581                	li	a1,0
    80001cf6:	8526                	mv	a0,s1
    80001cf8:	00000097          	auipc	ra,0x0
    80001cfc:	9ca080e7          	jalr	-1590(ra) # 800016c2 <uvmfree>
    return 0;
    80001d00:	4481                	li	s1,0
    80001d02:	b7d5                	j	80001ce6 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d04:	4681                	li	a3,0
    80001d06:	4605                	li	a2,1
    80001d08:	040005b7          	lui	a1,0x4000
    80001d0c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d0e:	05b2                	slli	a1,a1,0xc
    80001d10:	8526                	mv	a0,s1
    80001d12:	fffff097          	auipc	ra,0xfffff
    80001d16:	6e6080e7          	jalr	1766(ra) # 800013f8 <uvmunmap>
    uvmfree(pagetable, 0);
    80001d1a:	4581                	li	a1,0
    80001d1c:	8526                	mv	a0,s1
    80001d1e:	00000097          	auipc	ra,0x0
    80001d22:	9a4080e7          	jalr	-1628(ra) # 800016c2 <uvmfree>
    return 0;
    80001d26:	4481                	li	s1,0
    80001d28:	bf7d                	j	80001ce6 <proc_pagetable+0x58>

0000000080001d2a <proc_freepagetable>:
{
    80001d2a:	1101                	addi	sp,sp,-32
    80001d2c:	ec06                	sd	ra,24(sp)
    80001d2e:	e822                	sd	s0,16(sp)
    80001d30:	e426                	sd	s1,8(sp)
    80001d32:	e04a                	sd	s2,0(sp)
    80001d34:	1000                	addi	s0,sp,32
    80001d36:	84aa                	mv	s1,a0
    80001d38:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d3a:	4681                	li	a3,0
    80001d3c:	4605                	li	a2,1
    80001d3e:	040005b7          	lui	a1,0x4000
    80001d42:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d44:	05b2                	slli	a1,a1,0xc
    80001d46:	fffff097          	auipc	ra,0xfffff
    80001d4a:	6b2080e7          	jalr	1714(ra) # 800013f8 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001d4e:	4681                	li	a3,0
    80001d50:	4605                	li	a2,1
    80001d52:	020005b7          	lui	a1,0x2000
    80001d56:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d58:	05b6                	slli	a1,a1,0xd
    80001d5a:	8526                	mv	a0,s1
    80001d5c:	fffff097          	auipc	ra,0xfffff
    80001d60:	69c080e7          	jalr	1692(ra) # 800013f8 <uvmunmap>
  uvmfree(pagetable, sz);
    80001d64:	85ca                	mv	a1,s2
    80001d66:	8526                	mv	a0,s1
    80001d68:	00000097          	auipc	ra,0x0
    80001d6c:	95a080e7          	jalr	-1702(ra) # 800016c2 <uvmfree>
}
    80001d70:	60e2                	ld	ra,24(sp)
    80001d72:	6442                	ld	s0,16(sp)
    80001d74:	64a2                	ld	s1,8(sp)
    80001d76:	6902                	ld	s2,0(sp)
    80001d78:	6105                	addi	sp,sp,32
    80001d7a:	8082                	ret

0000000080001d7c <freeproc>:
{
    80001d7c:	1101                	addi	sp,sp,-32
    80001d7e:	ec06                	sd	ra,24(sp)
    80001d80:	e822                	sd	s0,16(sp)
    80001d82:	e426                	sd	s1,8(sp)
    80001d84:	1000                	addi	s0,sp,32
    80001d86:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001d88:	6d28                	ld	a0,88(a0)
    80001d8a:	c509                	beqz	a0,80001d94 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001d8c:	fffff097          	auipc	ra,0xfffff
    80001d90:	d0a080e7          	jalr	-758(ra) # 80000a96 <kfree>
  p->trapframe = 0;
    80001d94:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001d98:	68a8                	ld	a0,80(s1)
    80001d9a:	c511                	beqz	a0,80001da6 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001d9c:	64ac                	ld	a1,72(s1)
    80001d9e:	00000097          	auipc	ra,0x0
    80001da2:	f8c080e7          	jalr	-116(ra) # 80001d2a <proc_freepagetable>
  p->pagetable = 0;
    80001da6:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001daa:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001dae:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001db2:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001db6:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001dba:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001dbe:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001dc2:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001dc6:	0004ac23          	sw	zero,24(s1)
  p->smask = 0;
    80001dca:	1604a423          	sw	zero,360(s1)
  p->interval = 0;
    80001dce:	1604a623          	sw	zero,364(s1)
  p->nticks =0;
    80001dd2:	1604ac23          	sw	zero,376(s1)
  p->handler = 0;
    80001dd6:	1604b823          	sd	zero,368(s1)
  p->ctime = 0;
    80001dda:	1804a423          	sw	zero,392(s1)
  p->rticks = 0;
    80001dde:	1a04a823          	sw	zero,432(s1)
  p->wticks = 0;
    80001de2:	1a04aa23          	sw	zero,436(s1)
  p->pr = 0;
    80001de6:	1a04ac23          	sw	zero,440(s1)
}
    80001dea:	60e2                	ld	ra,24(sp)
    80001dec:	6442                	ld	s0,16(sp)
    80001dee:	64a2                	ld	s1,8(sp)
    80001df0:	6105                	addi	sp,sp,32
    80001df2:	8082                	ret

0000000080001df4 <allocproc>:
{
    80001df4:	1101                	addi	sp,sp,-32
    80001df6:	ec06                	sd	ra,24(sp)
    80001df8:	e822                	sd	s0,16(sp)
    80001dfa:	e426                	sd	s1,8(sp)
    80001dfc:	e04a                	sd	s2,0(sp)
    80001dfe:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e00:	00030497          	auipc	s1,0x30
    80001e04:	e3048493          	addi	s1,s1,-464 # 80031c30 <proc>
    80001e08:	00043917          	auipc	s2,0x43
    80001e0c:	62890913          	addi	s2,s2,1576 # 80045430 <tickslock>
    acquire(&p->lock);
    80001e10:	8526                	mv	a0,s1
    80001e12:	fffff097          	auipc	ra,0xfffff
    80001e16:	f5a080e7          	jalr	-166(ra) # 80000d6c <acquire>
    if(p->state == UNUSED) {
    80001e1a:	4c9c                	lw	a5,24(s1)
    80001e1c:	cf81                	beqz	a5,80001e34 <allocproc+0x40>
      release(&p->lock);
    80001e1e:	8526                	mv	a0,s1
    80001e20:	fffff097          	auipc	ra,0xfffff
    80001e24:	000080e7          	jalr	ra # 80000e20 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e28:	4e048493          	addi	s1,s1,1248
    80001e2c:	ff2492e3          	bne	s1,s2,80001e10 <allocproc+0x1c>
  return 0;
    80001e30:	4481                	li	s1,0
    80001e32:	a045                	j	80001ed2 <allocproc+0xde>
  p->pid = allocpid();
    80001e34:	00000097          	auipc	ra,0x0
    80001e38:	e14080e7          	jalr	-492(ra) # 80001c48 <allocpid>
    80001e3c:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001e3e:	4785                	li	a5,1
    80001e40:	cc9c                	sw	a5,24(s1)
  p->smask = 0;
    80001e42:	1604a423          	sw	zero,360(s1)
  p->nticks = 0;
    80001e46:	1604ac23          	sw	zero,376(s1)
  p->alarmOn = 0;
    80001e4a:	1604ae23          	sw	zero,380(s1)
  p->ctime = ticks; // 'ticks' is an inbuilt unit in xv6
    80001e4e:	00007717          	auipc	a4,0x7
    80001e52:	d2272703          	lw	a4,-734(a4) # 80008b70 <ticks>
    80001e56:	18e4a423          	sw	a4,392(s1)
  p->etime = 0;
    80001e5a:	1a04a623          	sw	zero,428(s1)
  p->tickets = 1;
    80001e5e:	18f4a623          	sw	a5,396(s1)
  p->pbs_rtime = 0;
    80001e62:	1804a823          	sw	zero,400(s1)
  p->rtime = 0;
    80001e66:	1804aa23          	sw	zero,404(s1)
  p->stime = 0;
    80001e6a:	1804ac23          	sw	zero,408(s1)
  p->staticP = 60;
    80001e6e:	03c00793          	li	a5,60
    80001e72:	18f4ae23          	sw	a5,412(s1)
  p->niceness = 5;
    80001e76:	4795                	li	a5,5
    80001e78:	1af4a023          	sw	a5,416(s1)
  p->wtime = 0;
    80001e7c:	1a04a223          	sw	zero,420(s1)
  p->sch_no = 0;
    80001e80:	1a04a423          	sw	zero,424(s1)
  p->rticks = 0;
    80001e84:	1a04a823          	sw	zero,432(s1)
  p->wticks = 0;
    80001e88:	1a04aa23          	sw	zero,436(s1)
  p->pr = P0;
    80001e8c:	1a04ac23          	sw	zero,440(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001e90:	fffff097          	auipc	ra,0xfffff
    80001e94:	d9c080e7          	jalr	-612(ra) # 80000c2c <kalloc>
    80001e98:	892a                	mv	s2,a0
    80001e9a:	eca8                	sd	a0,88(s1)
    80001e9c:	c131                	beqz	a0,80001ee0 <allocproc+0xec>
  p->pagetable = proc_pagetable(p);
    80001e9e:	8526                	mv	a0,s1
    80001ea0:	00000097          	auipc	ra,0x0
    80001ea4:	dee080e7          	jalr	-530(ra) # 80001c8e <proc_pagetable>
    80001ea8:	892a                	mv	s2,a0
    80001eaa:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001eac:	c531                	beqz	a0,80001ef8 <allocproc+0x104>
  memset(&p->context, 0, sizeof(p->context));
    80001eae:	07000613          	li	a2,112
    80001eb2:	4581                	li	a1,0
    80001eb4:	06048513          	addi	a0,s1,96
    80001eb8:	fffff097          	auipc	ra,0xfffff
    80001ebc:	fb0080e7          	jalr	-80(ra) # 80000e68 <memset>
  p->context.ra = (uint64)forkret;
    80001ec0:	00000797          	auipc	a5,0x0
    80001ec4:	d4278793          	addi	a5,a5,-702 # 80001c02 <forkret>
    80001ec8:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001eca:	60bc                	ld	a5,64(s1)
    80001ecc:	6705                	lui	a4,0x1
    80001ece:	97ba                	add	a5,a5,a4
    80001ed0:	f4bc                	sd	a5,104(s1)
}
    80001ed2:	8526                	mv	a0,s1
    80001ed4:	60e2                	ld	ra,24(sp)
    80001ed6:	6442                	ld	s0,16(sp)
    80001ed8:	64a2                	ld	s1,8(sp)
    80001eda:	6902                	ld	s2,0(sp)
    80001edc:	6105                	addi	sp,sp,32
    80001ede:	8082                	ret
    freeproc(p);
    80001ee0:	8526                	mv	a0,s1
    80001ee2:	00000097          	auipc	ra,0x0
    80001ee6:	e9a080e7          	jalr	-358(ra) # 80001d7c <freeproc>
    release(&p->lock);
    80001eea:	8526                	mv	a0,s1
    80001eec:	fffff097          	auipc	ra,0xfffff
    80001ef0:	f34080e7          	jalr	-204(ra) # 80000e20 <release>
    return 0;
    80001ef4:	84ca                	mv	s1,s2
    80001ef6:	bff1                	j	80001ed2 <allocproc+0xde>
    freeproc(p);
    80001ef8:	8526                	mv	a0,s1
    80001efa:	00000097          	auipc	ra,0x0
    80001efe:	e82080e7          	jalr	-382(ra) # 80001d7c <freeproc>
    release(&p->lock);
    80001f02:	8526                	mv	a0,s1
    80001f04:	fffff097          	auipc	ra,0xfffff
    80001f08:	f1c080e7          	jalr	-228(ra) # 80000e20 <release>
    return 0;
    80001f0c:	84ca                	mv	s1,s2
    80001f0e:	b7d1                	j	80001ed2 <allocproc+0xde>

0000000080001f10 <userinit>:
{
    80001f10:	1101                	addi	sp,sp,-32
    80001f12:	ec06                	sd	ra,24(sp)
    80001f14:	e822                	sd	s0,16(sp)
    80001f16:	e426                	sd	s1,8(sp)
    80001f18:	1000                	addi	s0,sp,32
  p = allocproc();
    80001f1a:	00000097          	auipc	ra,0x0
    80001f1e:	eda080e7          	jalr	-294(ra) # 80001df4 <allocproc>
    80001f22:	84aa                	mv	s1,a0
  initproc = p;
    80001f24:	00007797          	auipc	a5,0x7
    80001f28:	c4a7b223          	sd	a0,-956(a5) # 80008b68 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001f2c:	03400613          	li	a2,52
    80001f30:	00007597          	auipc	a1,0x7
    80001f34:	bd058593          	addi	a1,a1,-1072 # 80008b00 <initcode>
    80001f38:	6928                	ld	a0,80(a0)
    80001f3a:	fffff097          	auipc	ra,0xfffff
    80001f3e:	5b0080e7          	jalr	1456(ra) # 800014ea <uvmfirst>
  p->sz = PGSIZE;
    80001f42:	6785                	lui	a5,0x1
    80001f44:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001f46:	6cb8                	ld	a4,88(s1)
    80001f48:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001f4c:	6cb8                	ld	a4,88(s1)
    80001f4e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f50:	4641                	li	a2,16
    80001f52:	00006597          	auipc	a1,0x6
    80001f56:	2b658593          	addi	a1,a1,694 # 80008208 <digits+0x1c8>
    80001f5a:	15848513          	addi	a0,s1,344
    80001f5e:	fffff097          	auipc	ra,0xfffff
    80001f62:	052080e7          	jalr	82(ra) # 80000fb0 <safestrcpy>
  p->cwd = namei("/");
    80001f66:	00006517          	auipc	a0,0x6
    80001f6a:	2b250513          	addi	a0,a0,690 # 80008218 <digits+0x1d8>
    80001f6e:	00003097          	auipc	ra,0x3
    80001f72:	a0c080e7          	jalr	-1524(ra) # 8000497a <namei>
    80001f76:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001f7a:	478d                	li	a5,3
    80001f7c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001f7e:	8526                	mv	a0,s1
    80001f80:	fffff097          	auipc	ra,0xfffff
    80001f84:	ea0080e7          	jalr	-352(ra) # 80000e20 <release>
}
    80001f88:	60e2                	ld	ra,24(sp)
    80001f8a:	6442                	ld	s0,16(sp)
    80001f8c:	64a2                	ld	s1,8(sp)
    80001f8e:	6105                	addi	sp,sp,32
    80001f90:	8082                	ret

0000000080001f92 <growproc>:
{
    80001f92:	1101                	addi	sp,sp,-32
    80001f94:	ec06                	sd	ra,24(sp)
    80001f96:	e822                	sd	s0,16(sp)
    80001f98:	e426                	sd	s1,8(sp)
    80001f9a:	e04a                	sd	s2,0(sp)
    80001f9c:	1000                	addi	s0,sp,32
    80001f9e:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001fa0:	00000097          	auipc	ra,0x0
    80001fa4:	c2a080e7          	jalr	-982(ra) # 80001bca <myproc>
    80001fa8:	84aa                	mv	s1,a0
  sz = p->sz;
    80001faa:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001fac:	01204c63          	bgtz	s2,80001fc4 <growproc+0x32>
  } else if(n < 0){
    80001fb0:	02094663          	bltz	s2,80001fdc <growproc+0x4a>
  p->sz = sz;
    80001fb4:	e4ac                	sd	a1,72(s1)
  return 0;
    80001fb6:	4501                	li	a0,0
}
    80001fb8:	60e2                	ld	ra,24(sp)
    80001fba:	6442                	ld	s0,16(sp)
    80001fbc:	64a2                	ld	s1,8(sp)
    80001fbe:	6902                	ld	s2,0(sp)
    80001fc0:	6105                	addi	sp,sp,32
    80001fc2:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001fc4:	4691                	li	a3,4
    80001fc6:	00b90633          	add	a2,s2,a1
    80001fca:	6928                	ld	a0,80(a0)
    80001fcc:	fffff097          	auipc	ra,0xfffff
    80001fd0:	5d8080e7          	jalr	1496(ra) # 800015a4 <uvmalloc>
    80001fd4:	85aa                	mv	a1,a0
    80001fd6:	fd79                	bnez	a0,80001fb4 <growproc+0x22>
      return -1;
    80001fd8:	557d                	li	a0,-1
    80001fda:	bff9                	j	80001fb8 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001fdc:	00b90633          	add	a2,s2,a1
    80001fe0:	6928                	ld	a0,80(a0)
    80001fe2:	fffff097          	auipc	ra,0xfffff
    80001fe6:	57a080e7          	jalr	1402(ra) # 8000155c <uvmdealloc>
    80001fea:	85aa                	mv	a1,a0
    80001fec:	b7e1                	j	80001fb4 <growproc+0x22>

0000000080001fee <fork>:
{
    80001fee:	7139                	addi	sp,sp,-64
    80001ff0:	fc06                	sd	ra,56(sp)
    80001ff2:	f822                	sd	s0,48(sp)
    80001ff4:	f426                	sd	s1,40(sp)
    80001ff6:	f04a                	sd	s2,32(sp)
    80001ff8:	ec4e                	sd	s3,24(sp)
    80001ffa:	e852                	sd	s4,16(sp)
    80001ffc:	e456                	sd	s5,8(sp)
    80001ffe:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002000:	00000097          	auipc	ra,0x0
    80002004:	bca080e7          	jalr	-1078(ra) # 80001bca <myproc>
    80002008:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    8000200a:	00000097          	auipc	ra,0x0
    8000200e:	dea080e7          	jalr	-534(ra) # 80001df4 <allocproc>
    80002012:	12050863          	beqz	a0,80002142 <fork+0x154>
    80002016:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80002018:	048ab603          	ld	a2,72(s5)
    8000201c:	692c                	ld	a1,80(a0)
    8000201e:	050ab503          	ld	a0,80(s5)
    80002022:	fffff097          	auipc	ra,0xfffff
    80002026:	6da080e7          	jalr	1754(ra) # 800016fc <uvmcopy>
    8000202a:	04054c63          	bltz	a0,80002082 <fork+0x94>
  np->sz = p->sz;
    8000202e:	048ab783          	ld	a5,72(s5)
    80002032:	04f9b423          	sd	a5,72(s3)
  np->staticP = p->staticP;
    80002036:	19caa783          	lw	a5,412(s5)
    8000203a:	18f9ae23          	sw	a5,412(s3)
  *(np->trapframe) = *(p->trapframe);
    8000203e:	058ab683          	ld	a3,88(s5)
    80002042:	87b6                	mv	a5,a3
    80002044:	0589b703          	ld	a4,88(s3)
    80002048:	12068693          	addi	a3,a3,288
    8000204c:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80002050:	6788                	ld	a0,8(a5)
    80002052:	6b8c                	ld	a1,16(a5)
    80002054:	6f90                	ld	a2,24(a5)
    80002056:	01073023          	sd	a6,0(a4)
    8000205a:	e708                	sd	a0,8(a4)
    8000205c:	eb0c                	sd	a1,16(a4)
    8000205e:	ef10                	sd	a2,24(a4)
    80002060:	02078793          	addi	a5,a5,32
    80002064:	02070713          	addi	a4,a4,32
    80002068:	fed792e3          	bne	a5,a3,8000204c <fork+0x5e>
  np->trapframe->a0 = 0;
    8000206c:	0589b783          	ld	a5,88(s3)
    80002070:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80002074:	0d0a8493          	addi	s1,s5,208
    80002078:	0d098913          	addi	s2,s3,208
    8000207c:	150a8a13          	addi	s4,s5,336
    80002080:	a00d                	j	800020a2 <fork+0xb4>
    freeproc(np);
    80002082:	854e                	mv	a0,s3
    80002084:	00000097          	auipc	ra,0x0
    80002088:	cf8080e7          	jalr	-776(ra) # 80001d7c <freeproc>
    release(&np->lock);
    8000208c:	854e                	mv	a0,s3
    8000208e:	fffff097          	auipc	ra,0xfffff
    80002092:	d92080e7          	jalr	-622(ra) # 80000e20 <release>
    return -1;
    80002096:	597d                	li	s2,-1
    80002098:	a859                	j	8000212e <fork+0x140>
  for(i = 0; i < NOFILE; i++)
    8000209a:	04a1                	addi	s1,s1,8
    8000209c:	0921                	addi	s2,s2,8
    8000209e:	01448b63          	beq	s1,s4,800020b4 <fork+0xc6>
    if(p->ofile[i])
    800020a2:	6088                	ld	a0,0(s1)
    800020a4:	d97d                	beqz	a0,8000209a <fork+0xac>
      np->ofile[i] = filedup(p->ofile[i]);
    800020a6:	00003097          	auipc	ra,0x3
    800020aa:	f46080e7          	jalr	-186(ra) # 80004fec <filedup>
    800020ae:	00a93023          	sd	a0,0(s2)
    800020b2:	b7e5                	j	8000209a <fork+0xac>
  np->cwd = idup(p->cwd);
    800020b4:	150ab503          	ld	a0,336(s5)
    800020b8:	00002097          	auipc	ra,0x2
    800020bc:	0de080e7          	jalr	222(ra) # 80004196 <idup>
    800020c0:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800020c4:	4641                	li	a2,16
    800020c6:	158a8593          	addi	a1,s5,344
    800020ca:	15898513          	addi	a0,s3,344
    800020ce:	fffff097          	auipc	ra,0xfffff
    800020d2:	ee2080e7          	jalr	-286(ra) # 80000fb0 <safestrcpy>
  pid = np->pid;
    800020d6:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    800020da:	854e                	mv	a0,s3
    800020dc:	fffff097          	auipc	ra,0xfffff
    800020e0:	d44080e7          	jalr	-700(ra) # 80000e20 <release>
  acquire(&wait_lock);
    800020e4:	0002f497          	auipc	s1,0x2f
    800020e8:	d3448493          	addi	s1,s1,-716 # 80030e18 <wait_lock>
    800020ec:	8526                	mv	a0,s1
    800020ee:	fffff097          	auipc	ra,0xfffff
    800020f2:	c7e080e7          	jalr	-898(ra) # 80000d6c <acquire>
  np->parent = p;
    800020f6:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    800020fa:	8526                	mv	a0,s1
    800020fc:	fffff097          	auipc	ra,0xfffff
    80002100:	d24080e7          	jalr	-732(ra) # 80000e20 <release>
  acquire(&np->lock);
    80002104:	854e                	mv	a0,s3
    80002106:	fffff097          	auipc	ra,0xfffff
    8000210a:	c66080e7          	jalr	-922(ra) # 80000d6c <acquire>
  np->state = RUNNABLE;
    8000210e:	478d                	li	a5,3
    80002110:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80002114:	854e                	mv	a0,s3
    80002116:	fffff097          	auipc	ra,0xfffff
    8000211a:	d0a080e7          	jalr	-758(ra) # 80000e20 <release>
  np->smask = p->smask;
    8000211e:	168aa783          	lw	a5,360(s5)
    80002122:	16f9a423          	sw	a5,360(s3)
  np->tickets = p->tickets;
    80002126:	18caa783          	lw	a5,396(s5)
    8000212a:	18f9a623          	sw	a5,396(s3)
}
    8000212e:	854a                	mv	a0,s2
    80002130:	70e2                	ld	ra,56(sp)
    80002132:	7442                	ld	s0,48(sp)
    80002134:	74a2                	ld	s1,40(sp)
    80002136:	7902                	ld	s2,32(sp)
    80002138:	69e2                	ld	s3,24(sp)
    8000213a:	6a42                	ld	s4,16(sp)
    8000213c:	6aa2                	ld	s5,8(sp)
    8000213e:	6121                	addi	sp,sp,64
    80002140:	8082                	ret
    return -1;
    80002142:	597d                	li	s2,-1
    80002144:	b7ed                	j	8000212e <fork+0x140>

0000000080002146 <update_time>:
 {
    80002146:	7179                	addi	sp,sp,-48
    80002148:	f406                	sd	ra,40(sp)
    8000214a:	f022                	sd	s0,32(sp)
    8000214c:	ec26                	sd	s1,24(sp)
    8000214e:	e84a                	sd	s2,16(sp)
    80002150:	e44e                	sd	s3,8(sp)
    80002152:	1800                	addi	s0,sp,48
   for (p = proc; p < &proc[NPROC]; p++) {
    80002154:	00030497          	auipc	s1,0x30
    80002158:	adc48493          	addi	s1,s1,-1316 # 80031c30 <proc>
     if (p->state == RUNNING) {
    8000215c:	4991                	li	s3,4
   for (p = proc; p < &proc[NPROC]; p++) {
    8000215e:	00043917          	auipc	s2,0x43
    80002162:	2d290913          	addi	s2,s2,722 # 80045430 <tickslock>
    80002166:	a811                	j	8000217a <update_time+0x34>
     release(&p->lock); 
    80002168:	8526                	mv	a0,s1
    8000216a:	fffff097          	auipc	ra,0xfffff
    8000216e:	cb6080e7          	jalr	-842(ra) # 80000e20 <release>
   for (p = proc; p < &proc[NPROC]; p++) {
    80002172:	4e048493          	addi	s1,s1,1248
    80002176:	03248063          	beq	s1,s2,80002196 <update_time+0x50>
     acquire(&p->lock);
    8000217a:	8526                	mv	a0,s1
    8000217c:	fffff097          	auipc	ra,0xfffff
    80002180:	bf0080e7          	jalr	-1040(ra) # 80000d6c <acquire>
     if (p->state == RUNNING) {
    80002184:	4c9c                	lw	a5,24(s1)
    80002186:	ff3791e3          	bne	a5,s3,80002168 <update_time+0x22>
       p->rtime++;
    8000218a:	1944a783          	lw	a5,404(s1)
    8000218e:	2785                	addiw	a5,a5,1
    80002190:	18f4aa23          	sw	a5,404(s1)
    80002194:	bfd1                	j	80002168 <update_time+0x22>
 }
    80002196:	70a2                	ld	ra,40(sp)
    80002198:	7402                	ld	s0,32(sp)
    8000219a:	64e2                	ld	s1,24(sp)
    8000219c:	6942                	ld	s2,16(sp)
    8000219e:	69a2                	ld	s3,8(sp)
    800021a0:	6145                	addi	sp,sp,48
    800021a2:	8082                	ret

00000000800021a4 <dequeue_proc>:
void dequeue_proc(struct proc *p) {
    800021a4:	1141                	addi	sp,sp,-16
    800021a6:	e422                	sd	s0,8(sp)
    800021a8:	0800                	addi	s0,sp,16
  for(i = 0; i < NPROC; i++) {
    800021aa:	1b856703          	lwu	a4,440(a0)
    800021ae:	0726                	slli	a4,a4,0x9
    800021b0:	0002f797          	auipc	a5,0x2f
    800021b4:	08078793          	addi	a5,a5,128 # 80031230 <queue>
    800021b8:	973e                	add	a4,a4,a5
    800021ba:	4781                	li	a5,0
    800021bc:	04000593          	li	a1,64
    800021c0:	a029                	j	800021ca <dequeue_proc+0x26>
    800021c2:	2785                	addiw	a5,a5,1
    800021c4:	0721                	addi	a4,a4,8
    800021c6:	04b78463          	beq	a5,a1,8000220e <dequeue_proc+0x6a>
    struct proc *fp = queue[p->pr][i];
    800021ca:	6314                	ld	a3,0(a4)
    if (fp && fp->pid == p->pid) {
    800021cc:	dafd                	beqz	a3,800021c2 <dequeue_proc+0x1e>
    800021ce:	5a90                	lw	a2,48(a3)
    800021d0:	5914                	lw	a3,48(a0)
    800021d2:	fed618e3          	bne	a2,a3,800021c2 <dequeue_proc+0x1e>
      for(j = i + 1; j < NPROC; j++)
    800021d6:	2785                	addiw	a5,a5,1
    800021d8:	03f00713          	li	a4,63
    800021dc:	02f74963          	blt	a4,a5,8000220e <dequeue_proc+0x6a>
        queue[p->pr][j - 1] = queue[p->pr][j];
    800021e0:	0002f617          	auipc	a2,0x2f
    800021e4:	05060613          	addi	a2,a2,80 # 80031230 <queue>
      for(j = i + 1; j < NPROC; j++)
    800021e8:	04000813          	li	a6,64
        queue[p->pr][j - 1] = queue[p->pr][j];
    800021ec:	1b856703          	lwu	a4,440(a0)
    800021f0:	071a                	slli	a4,a4,0x6
    800021f2:	00f706b3          	add	a3,a4,a5
    800021f6:	068e                	slli	a3,a3,0x3
    800021f8:	96b2                	add	a3,a3,a2
    800021fa:	6294                	ld	a3,0(a3)
    800021fc:	fff7859b          	addiw	a1,a5,-1
    80002200:	972e                	add	a4,a4,a1
    80002202:	070e                	slli	a4,a4,0x3
    80002204:	9732                	add	a4,a4,a2
    80002206:	e314                	sd	a3,0(a4)
      for(j = i + 1; j < NPROC; j++)
    80002208:	2785                	addiw	a5,a5,1
    8000220a:	ff0791e3          	bne	a5,a6,800021ec <dequeue_proc+0x48>
}
    8000220e:	6422                	ld	s0,8(sp)
    80002210:	0141                	addi	sp,sp,16
    80002212:	8082                	ret

0000000080002214 <queue_proc>:
void queue_proc(struct proc *p) {
    80002214:	1141                	addi	sp,sp,-16
    80002216:	e422                	sd	s0,8(sp)
    80002218:	0800                	addi	s0,sp,16
    struct proc *fp = queue[p->pr][i];
    8000221a:	1b852803          	lw	a6,440(a0)
    8000221e:	02081713          	slli	a4,a6,0x20
    80002222:	01775793          	srli	a5,a4,0x17
    80002226:	0002f717          	auipc	a4,0x2f
    8000222a:	00a70713          	addi	a4,a4,10 # 80031230 <queue>
    8000222e:	97ba                	add	a5,a5,a4
  for(i = 0; i < NPROC; i++) {
    80002230:	4681                	li	a3,0
    80002232:	04000593          	li	a1,64
    struct proc *fp = queue[p->pr][i];
    80002236:	6398                	ld	a4,0(a5)
    if (fp && fp->pid == p->pid)
    80002238:	cb11                	beqz	a4,8000224c <queue_proc+0x38>
    8000223a:	5b10                	lw	a2,48(a4)
    8000223c:	5918                	lw	a4,48(a0)
    8000223e:	02e60363          	beq	a2,a4,80002264 <queue_proc+0x50>
  for(i = 0; i < NPROC; i++) {
    80002242:	2685                	addiw	a3,a3,1
    80002244:	07a1                	addi	a5,a5,8
    80002246:	feb698e3          	bne	a3,a1,80002236 <queue_proc+0x22>
    8000224a:	a829                	j	80002264 <queue_proc+0x50>
      queue[p->pr][i] = p;
    8000224c:	02081713          	slli	a4,a6,0x20
    80002250:	01a75793          	srli	a5,a4,0x1a
    80002254:	97b6                	add	a5,a5,a3
    80002256:	078e                	slli	a5,a5,0x3
    80002258:	0002f717          	auipc	a4,0x2f
    8000225c:	fd870713          	addi	a4,a4,-40 # 80031230 <queue>
    80002260:	97ba                	add	a5,a5,a4
    80002262:	e388                	sd	a0,0(a5)
}
    80002264:	6422                	ld	s0,8(sp)
    80002266:	0141                	addi	sp,sp,16
    80002268:	8082                	ret

000000008000226a <scheduler>:
{
    8000226a:	7119                	addi	sp,sp,-128
    8000226c:	fc86                	sd	ra,120(sp)
    8000226e:	f8a2                	sd	s0,112(sp)
    80002270:	f4a6                	sd	s1,104(sp)
    80002272:	f0ca                	sd	s2,96(sp)
    80002274:	ecce                	sd	s3,88(sp)
    80002276:	e8d2                	sd	s4,80(sp)
    80002278:	e4d6                	sd	s5,72(sp)
    8000227a:	e0da                	sd	s6,64(sp)
    8000227c:	fc5e                	sd	s7,56(sp)
    8000227e:	f862                	sd	s8,48(sp)
    80002280:	f466                	sd	s9,40(sp)
    80002282:	f06a                	sd	s10,32(sp)
    80002284:	ec6e                	sd	s11,24(sp)
    80002286:	0100                	addi	s0,sp,128
    80002288:	8792                	mv	a5,tp
  int id = r_tp();
    8000228a:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000228c:	00779693          	slli	a3,a5,0x7
    80002290:	0002f717          	auipc	a4,0x2f
    80002294:	b7070713          	addi	a4,a4,-1168 # 80030e00 <pid_lock>
    80002298:	9736                	add	a4,a4,a3
    8000229a:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    8000229e:	0002f717          	auipc	a4,0x2f
    800022a2:	b9a70713          	addi	a4,a4,-1126 # 80030e38 <cpus+0x8>
    800022a6:	9736                	add	a4,a4,a3
    800022a8:	f8e43423          	sd	a4,-120(s0)
    for(fp = proc; fp < &proc[NPROC]; fp++) {
    800022ac:	00043997          	auipc	s3,0x43
    800022b0:	18498993          	addi	s3,s3,388 # 80045430 <tickslock>
  return A>B ? B:A;
    800022b4:	06400a93          	li	s5,100
        c->proc = p;
    800022b8:	0002fd97          	auipc	s11,0x2f
    800022bc:	b48d8d93          	addi	s11,s11,-1208 # 80030e00 <pid_lock>
    800022c0:	9db6                	add	s11,s11,a3
    800022c2:	a215                	j	800023e6 <scheduler+0x17c>
          fp->niceness = (int)((sleep/(sleep + fp->pbs_rtime)) * 10);
    800022c4:	1904a703          	lw	a4,400(s1)
    800022c8:	9f3d                	addw	a4,a4,a5
    800022ca:	02e7c7bb          	divw	a5,a5,a4
    800022ce:	0027971b          	slliw	a4,a5,0x2
    800022d2:	9f3d                	addw	a4,a4,a5
    800022d4:	0017171b          	slliw	a4,a4,0x1
    800022d8:	1ae4a023          	sw	a4,416(s1)
        int dp = max(0,min(fp->staticP - fp->niceness + 5 , 100));
    800022dc:	19c4a783          	lw	a5,412(s1)
    800022e0:	9f99                	subw	a5,a5,a4
    800022e2:	2795                	addiw	a5,a5,5
  return A>B ? B:A;
    800022e4:	0007871b          	sext.w	a4,a5
    800022e8:	00ead363          	bge	s5,a4,800022ee <scheduler+0x84>
    800022ec:	87e2                	mv	a5,s8
  return A>B ? A:B;
    800022ee:	0007871b          	sext.w	a4,a5
    800022f2:	fff74713          	not	a4,a4
    800022f6:	977d                	srai	a4,a4,0x3f
    800022f8:	8ff9                	and	a5,a5,a4
    800022fa:	2781                	sext.w	a5,a5
        if(dp < min_dp){
    800022fc:	0747cd63          	blt	a5,s4,80002376 <scheduler+0x10c>
        else if(dp == min_dp){
    80002300:	03478b63          	beq	a5,s4,80002336 <scheduler+0xcc>
      release(&fp->lock);
    80002304:	8526                	mv	a0,s1
    80002306:	fffff097          	auipc	ra,0xfffff
    8000230a:	b1a080e7          	jalr	-1254(ra) # 80000e20 <release>
    for(fp = proc; fp < &proc[NPROC]; fp++) {
    8000230e:	4e048493          	addi	s1,s1,1248
    80002312:	05348263          	beq	s1,s3,80002356 <scheduler+0xec>
      acquire(&fp->lock);
    80002316:	8526                	mv	a0,s1
    80002318:	fffff097          	auipc	ra,0xfffff
    8000231c:	a54080e7          	jalr	-1452(ra) # 80000d6c <acquire>
      if (fp->state == RUNNABLE){
    80002320:	4c9c                	lw	a5,24(s1)
    80002322:	ff2791e3          	bne	a5,s2,80002304 <scheduler+0x9a>
        int sleep = fp->stime;
    80002326:	1984a783          	lw	a5,408(s1)
        if(!sleep && !fp->pbs_rtime){
    8000232a:	ffc9                	bnez	a5,800022c4 <scheduler+0x5a>
    8000232c:	1904a683          	lw	a3,400(s1)
          fp->niceness = 5;
    80002330:	875e                	mv	a4,s7
        if(!sleep && !fp->pbs_rtime){
    80002332:	d2dd                	beqz	a3,800022d8 <scheduler+0x6e>
    80002334:	bf41                	j	800022c4 <scheduler+0x5a>
          if(fp->sch_no < p->sch_no){
    80002336:	1a84a703          	lw	a4,424(s1)
    8000233a:	1a8b2783          	lw	a5,424(s6)
    8000233e:	0af74b63          	blt	a4,a5,800023f4 <scheduler+0x18a>
          else if(fp->sch_no == p->sch_no){
    80002342:	02f71c63          	bne	a4,a5,8000237a <scheduler+0x110>
            if(fp->ctime < p->ctime){
    80002346:	1884a703          	lw	a4,392(s1)
    8000234a:	188b2783          	lw	a5,392(s6)
    8000234e:	02f77663          	bgeu	a4,a5,8000237a <scheduler+0x110>
    80002352:	8b26                	mv	s6,s1
    80002354:	a01d                	j	8000237a <scheduler+0x110>
    if (p) {
    80002356:	020b1b63          	bnez	s6,8000238c <scheduler+0x122>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000235a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000235e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002362:	10079073          	csrw	sstatus,a5
    int min_dp = 103;
    80002366:	8a6a                	mv	s4,s10
    for(fp = proc; fp < &proc[NPROC]; fp++) {
    80002368:	00030497          	auipc	s1,0x30
    8000236c:	8c848493          	addi	s1,s1,-1848 # 80031c30 <proc>
    p = 0;
    80002370:	8b66                	mv	s6,s9
      if (fp->state == RUNNABLE){
    80002372:	490d                	li	s2,3
    80002374:	b74d                	j	80002316 <scheduler+0xac>
          min_dp = dp;
    80002376:	8a3e                	mv	s4,a5
    80002378:	8b26                	mv	s6,s1
      release(&fp->lock);
    8000237a:	8526                	mv	a0,s1
    8000237c:	fffff097          	auipc	ra,0xfffff
    80002380:	aa4080e7          	jalr	-1372(ra) # 80000e20 <release>
    for(fp = proc; fp < &proc[NPROC]; fp++) {
    80002384:	4e048493          	addi	s1,s1,1248
    80002388:	f93497e3          	bne	s1,s3,80002316 <scheduler+0xac>
      acquire(&p->lock);
    8000238c:	84da                	mv	s1,s6
    8000238e:	855a                	mv	a0,s6
    80002390:	fffff097          	auipc	ra,0xfffff
    80002394:	9dc080e7          	jalr	-1572(ra) # 80000d6c <acquire>
      if (p->state == RUNNABLE) {
    80002398:	018b2703          	lw	a4,24(s6)
    8000239c:	478d                	li	a5,3
    8000239e:	02f71f63          	bne	a4,a5,800023dc <scheduler+0x172>
        p->state = RUNNING;
    800023a2:	4791                	li	a5,4
    800023a4:	00fb2c23          	sw	a5,24(s6)
        p->pbs_rtime = 0;
    800023a8:	180b2823          	sw	zero,400(s6)
        p->stime = 0;
    800023ac:	180b2c23          	sw	zero,408(s6)
        p->niceness = 5;
    800023b0:	4795                	li	a5,5
    800023b2:	1afb2023          	sw	a5,416(s6)
        p->wtime = 0;
    800023b6:	1a0b2223          	sw	zero,420(s6)
        p->sch_no += 1;
    800023ba:	1a8b2783          	lw	a5,424(s6)
    800023be:	2785                	addiw	a5,a5,1
    800023c0:	1afb2423          	sw	a5,424(s6)
        c->proc = p;
    800023c4:	036db823          	sd	s6,48(s11)
        swtch(&c->context, &p->context);
    800023c8:	060b0593          	addi	a1,s6,96
    800023cc:	f8843503          	ld	a0,-120(s0)
    800023d0:	00001097          	auipc	ra,0x1
    800023d4:	812080e7          	jalr	-2030(ra) # 80002be2 <swtch>
        c->proc = 0;
    800023d8:	020db823          	sd	zero,48(s11)
      release(&p->lock);
    800023dc:	8526                	mv	a0,s1
    800023de:	fffff097          	auipc	ra,0xfffff
    800023e2:	a42080e7          	jalr	-1470(ra) # 80000e20 <release>
    int min_dp = 103;
    800023e6:	06700d13          	li	s10,103
    p = 0;
    800023ea:	4c81                	li	s9,0
  return A>B ? B:A;
    800023ec:	06400c13          	li	s8,100
          fp->niceness = 5;
    800023f0:	4b95                	li	s7,5
    800023f2:	b7a5                	j	8000235a <scheduler+0xf0>
    800023f4:	8b26                	mv	s6,s1
    800023f6:	b751                	j	8000237a <scheduler+0x110>

00000000800023f8 <sched>:
{
    800023f8:	7179                	addi	sp,sp,-48
    800023fa:	f406                	sd	ra,40(sp)
    800023fc:	f022                	sd	s0,32(sp)
    800023fe:	ec26                	sd	s1,24(sp)
    80002400:	e84a                	sd	s2,16(sp)
    80002402:	e44e                	sd	s3,8(sp)
    80002404:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002406:	fffff097          	auipc	ra,0xfffff
    8000240a:	7c4080e7          	jalr	1988(ra) # 80001bca <myproc>
    8000240e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	8e2080e7          	jalr	-1822(ra) # 80000cf2 <holding>
    80002418:	c93d                	beqz	a0,8000248e <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000241a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000241c:	2781                	sext.w	a5,a5
    8000241e:	079e                	slli	a5,a5,0x7
    80002420:	0002f717          	auipc	a4,0x2f
    80002424:	9e070713          	addi	a4,a4,-1568 # 80030e00 <pid_lock>
    80002428:	97ba                	add	a5,a5,a4
    8000242a:	0a87a703          	lw	a4,168(a5)
    8000242e:	4785                	li	a5,1
    80002430:	06f71763          	bne	a4,a5,8000249e <sched+0xa6>
  if(p->state == RUNNING)
    80002434:	4c98                	lw	a4,24(s1)
    80002436:	4791                	li	a5,4
    80002438:	06f70b63          	beq	a4,a5,800024ae <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000243c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002440:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002442:	efb5                	bnez	a5,800024be <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002444:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002446:	0002f917          	auipc	s2,0x2f
    8000244a:	9ba90913          	addi	s2,s2,-1606 # 80030e00 <pid_lock>
    8000244e:	2781                	sext.w	a5,a5
    80002450:	079e                	slli	a5,a5,0x7
    80002452:	97ca                	add	a5,a5,s2
    80002454:	0ac7a983          	lw	s3,172(a5)
    80002458:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000245a:	2781                	sext.w	a5,a5
    8000245c:	079e                	slli	a5,a5,0x7
    8000245e:	0002f597          	auipc	a1,0x2f
    80002462:	9da58593          	addi	a1,a1,-1574 # 80030e38 <cpus+0x8>
    80002466:	95be                	add	a1,a1,a5
    80002468:	06048513          	addi	a0,s1,96
    8000246c:	00000097          	auipc	ra,0x0
    80002470:	776080e7          	jalr	1910(ra) # 80002be2 <swtch>
    80002474:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002476:	2781                	sext.w	a5,a5
    80002478:	079e                	slli	a5,a5,0x7
    8000247a:	993e                	add	s2,s2,a5
    8000247c:	0b392623          	sw	s3,172(s2)
}
    80002480:	70a2                	ld	ra,40(sp)
    80002482:	7402                	ld	s0,32(sp)
    80002484:	64e2                	ld	s1,24(sp)
    80002486:	6942                	ld	s2,16(sp)
    80002488:	69a2                	ld	s3,8(sp)
    8000248a:	6145                	addi	sp,sp,48
    8000248c:	8082                	ret
    panic("sched p->lock");
    8000248e:	00006517          	auipc	a0,0x6
    80002492:	d9250513          	addi	a0,a0,-622 # 80008220 <digits+0x1e0>
    80002496:	ffffe097          	auipc	ra,0xffffe
    8000249a:	0a6080e7          	jalr	166(ra) # 8000053c <panic>
    panic("sched locks");
    8000249e:	00006517          	auipc	a0,0x6
    800024a2:	d9250513          	addi	a0,a0,-622 # 80008230 <digits+0x1f0>
    800024a6:	ffffe097          	auipc	ra,0xffffe
    800024aa:	096080e7          	jalr	150(ra) # 8000053c <panic>
    panic("sched running");
    800024ae:	00006517          	auipc	a0,0x6
    800024b2:	d9250513          	addi	a0,a0,-622 # 80008240 <digits+0x200>
    800024b6:	ffffe097          	auipc	ra,0xffffe
    800024ba:	086080e7          	jalr	134(ra) # 8000053c <panic>
    panic("sched interruptible");
    800024be:	00006517          	auipc	a0,0x6
    800024c2:	d9250513          	addi	a0,a0,-622 # 80008250 <digits+0x210>
    800024c6:	ffffe097          	auipc	ra,0xffffe
    800024ca:	076080e7          	jalr	118(ra) # 8000053c <panic>

00000000800024ce <yield>:
{
    800024ce:	1101                	addi	sp,sp,-32
    800024d0:	ec06                	sd	ra,24(sp)
    800024d2:	e822                	sd	s0,16(sp)
    800024d4:	e426                	sd	s1,8(sp)
    800024d6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800024d8:	fffff097          	auipc	ra,0xfffff
    800024dc:	6f2080e7          	jalr	1778(ra) # 80001bca <myproc>
    800024e0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800024e2:	fffff097          	auipc	ra,0xfffff
    800024e6:	88a080e7          	jalr	-1910(ra) # 80000d6c <acquire>
  p->state = RUNNABLE;
    800024ea:	478d                	li	a5,3
    800024ec:	cc9c                	sw	a5,24(s1)
  sched();
    800024ee:	00000097          	auipc	ra,0x0
    800024f2:	f0a080e7          	jalr	-246(ra) # 800023f8 <sched>
  release(&p->lock);
    800024f6:	8526                	mv	a0,s1
    800024f8:	fffff097          	auipc	ra,0xfffff
    800024fc:	928080e7          	jalr	-1752(ra) # 80000e20 <release>
}
    80002500:	60e2                	ld	ra,24(sp)
    80002502:	6442                	ld	s0,16(sp)
    80002504:	64a2                	ld	s1,8(sp)
    80002506:	6105                	addi	sp,sp,32
    80002508:	8082                	ret

000000008000250a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000250a:	7179                	addi	sp,sp,-48
    8000250c:	f406                	sd	ra,40(sp)
    8000250e:	f022                	sd	s0,32(sp)
    80002510:	ec26                	sd	s1,24(sp)
    80002512:	e84a                	sd	s2,16(sp)
    80002514:	e44e                	sd	s3,8(sp)
    80002516:	1800                	addi	s0,sp,48
    80002518:	89aa                	mv	s3,a0
    8000251a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000251c:	fffff097          	auipc	ra,0xfffff
    80002520:	6ae080e7          	jalr	1710(ra) # 80001bca <myproc>
    80002524:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002526:	fffff097          	auipc	ra,0xfffff
    8000252a:	846080e7          	jalr	-1978(ra) # 80000d6c <acquire>
  release(lk);
    8000252e:	854a                	mv	a0,s2
    80002530:	fffff097          	auipc	ra,0xfffff
    80002534:	8f0080e7          	jalr	-1808(ra) # 80000e20 <release>

  // Go to sleep.
  p->chan = chan;
    80002538:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000253c:	4789                	li	a5,2
    8000253e:	cc9c                	sw	a5,24(s1)
  // Specification 2 PBS
  //p->stime = ticks;

  sched();
    80002540:	00000097          	auipc	ra,0x0
    80002544:	eb8080e7          	jalr	-328(ra) # 800023f8 <sched>

  // Tidy up.
  p->chan = 0;
    80002548:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000254c:	8526                	mv	a0,s1
    8000254e:	fffff097          	auipc	ra,0xfffff
    80002552:	8d2080e7          	jalr	-1838(ra) # 80000e20 <release>
  acquire(lk);
    80002556:	854a                	mv	a0,s2
    80002558:	fffff097          	auipc	ra,0xfffff
    8000255c:	814080e7          	jalr	-2028(ra) # 80000d6c <acquire>
}
    80002560:	70a2                	ld	ra,40(sp)
    80002562:	7402                	ld	s0,32(sp)
    80002564:	64e2                	ld	s1,24(sp)
    80002566:	6942                	ld	s2,16(sp)
    80002568:	69a2                	ld	s3,8(sp)
    8000256a:	6145                	addi	sp,sp,48
    8000256c:	8082                	ret

000000008000256e <waitx>:
{
    8000256e:	711d                	addi	sp,sp,-96
    80002570:	ec86                	sd	ra,88(sp)
    80002572:	e8a2                	sd	s0,80(sp)
    80002574:	e4a6                	sd	s1,72(sp)
    80002576:	e0ca                	sd	s2,64(sp)
    80002578:	fc4e                	sd	s3,56(sp)
    8000257a:	f852                	sd	s4,48(sp)
    8000257c:	f456                	sd	s5,40(sp)
    8000257e:	f05a                	sd	s6,32(sp)
    80002580:	ec5e                	sd	s7,24(sp)
    80002582:	e862                	sd	s8,16(sp)
    80002584:	e466                	sd	s9,8(sp)
    80002586:	e06a                	sd	s10,0(sp)
    80002588:	1080                	addi	s0,sp,96
    8000258a:	8b2a                	mv	s6,a0
    8000258c:	8bae                	mv	s7,a1
    8000258e:	8c32                	mv	s8,a2
  struct proc *p = myproc();
    80002590:	fffff097          	auipc	ra,0xfffff
    80002594:	63a080e7          	jalr	1594(ra) # 80001bca <myproc>
    80002598:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000259a:	0002f517          	auipc	a0,0x2f
    8000259e:	87e50513          	addi	a0,a0,-1922 # 80030e18 <wait_lock>
    800025a2:	ffffe097          	auipc	ra,0xffffe
    800025a6:	7ca080e7          	jalr	1994(ra) # 80000d6c <acquire>
    havekids = 0;
    800025aa:	4c81                	li	s9,0
        if(np->state == ZOMBIE){
    800025ac:	4a15                	li	s4,5
        havekids = 1;
    800025ae:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800025b0:	00043997          	auipc	s3,0x43
    800025b4:	e8098993          	addi	s3,s3,-384 # 80045430 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800025b8:	0002fd17          	auipc	s10,0x2f
    800025bc:	860d0d13          	addi	s10,s10,-1952 # 80030e18 <wait_lock>
    800025c0:	a8e9                	j	8000269a <waitx+0x12c>
          pid = np->pid;
    800025c2:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    800025c6:	1944a783          	lw	a5,404(s1)
    800025ca:	00fc2023          	sw	a5,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    800025ce:	1884a703          	lw	a4,392(s1)
    800025d2:	9f3d                	addw	a4,a4,a5
    800025d4:	1ac4a783          	lw	a5,428(s1)
    800025d8:	9f99                	subw	a5,a5,a4
    800025da:	00fba023          	sw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7ffae7f0>
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800025de:	000b0e63          	beqz	s6,800025fa <waitx+0x8c>
    800025e2:	4691                	li	a3,4
    800025e4:	02c48613          	addi	a2,s1,44
    800025e8:	85da                	mv	a1,s6
    800025ea:	05093503          	ld	a0,80(s2)
    800025ee:	fffff097          	auipc	ra,0xfffff
    800025f2:	222080e7          	jalr	546(ra) # 80001810 <copyout>
    800025f6:	04054363          	bltz	a0,8000263c <waitx+0xce>
          freeproc(np);
    800025fa:	8526                	mv	a0,s1
    800025fc:	fffff097          	auipc	ra,0xfffff
    80002600:	780080e7          	jalr	1920(ra) # 80001d7c <freeproc>
          release(&np->lock);
    80002604:	8526                	mv	a0,s1
    80002606:	fffff097          	auipc	ra,0xfffff
    8000260a:	81a080e7          	jalr	-2022(ra) # 80000e20 <release>
          release(&wait_lock);
    8000260e:	0002f517          	auipc	a0,0x2f
    80002612:	80a50513          	addi	a0,a0,-2038 # 80030e18 <wait_lock>
    80002616:	fffff097          	auipc	ra,0xfffff
    8000261a:	80a080e7          	jalr	-2038(ra) # 80000e20 <release>
}
    8000261e:	854e                	mv	a0,s3
    80002620:	60e6                	ld	ra,88(sp)
    80002622:	6446                	ld	s0,80(sp)
    80002624:	64a6                	ld	s1,72(sp)
    80002626:	6906                	ld	s2,64(sp)
    80002628:	79e2                	ld	s3,56(sp)
    8000262a:	7a42                	ld	s4,48(sp)
    8000262c:	7aa2                	ld	s5,40(sp)
    8000262e:	7b02                	ld	s6,32(sp)
    80002630:	6be2                	ld	s7,24(sp)
    80002632:	6c42                	ld	s8,16(sp)
    80002634:	6ca2                	ld	s9,8(sp)
    80002636:	6d02                	ld	s10,0(sp)
    80002638:	6125                	addi	sp,sp,96
    8000263a:	8082                	ret
            release(&np->lock);
    8000263c:	8526                	mv	a0,s1
    8000263e:	ffffe097          	auipc	ra,0xffffe
    80002642:	7e2080e7          	jalr	2018(ra) # 80000e20 <release>
            release(&wait_lock);
    80002646:	0002e517          	auipc	a0,0x2e
    8000264a:	7d250513          	addi	a0,a0,2002 # 80030e18 <wait_lock>
    8000264e:	ffffe097          	auipc	ra,0xffffe
    80002652:	7d2080e7          	jalr	2002(ra) # 80000e20 <release>
            return -1;
    80002656:	59fd                	li	s3,-1
    80002658:	b7d9                	j	8000261e <waitx+0xb0>
    for(np = proc; np < &proc[NPROC]; np++){
    8000265a:	4e048493          	addi	s1,s1,1248
    8000265e:	03348463          	beq	s1,s3,80002686 <waitx+0x118>
      if(np->parent == p){
    80002662:	7c9c                	ld	a5,56(s1)
    80002664:	ff279be3          	bne	a5,s2,8000265a <waitx+0xec>
        acquire(&np->lock);
    80002668:	8526                	mv	a0,s1
    8000266a:	ffffe097          	auipc	ra,0xffffe
    8000266e:	702080e7          	jalr	1794(ra) # 80000d6c <acquire>
        if(np->state == ZOMBIE){
    80002672:	4c9c                	lw	a5,24(s1)
    80002674:	f54787e3          	beq	a5,s4,800025c2 <waitx+0x54>
        release(&np->lock);
    80002678:	8526                	mv	a0,s1
    8000267a:	ffffe097          	auipc	ra,0xffffe
    8000267e:	7a6080e7          	jalr	1958(ra) # 80000e20 <release>
        havekids = 1;
    80002682:	8756                	mv	a4,s5
    80002684:	bfd9                	j	8000265a <waitx+0xec>
    if(!havekids || p->killed){
    80002686:	c305                	beqz	a4,800026a6 <waitx+0x138>
    80002688:	02892783          	lw	a5,40(s2)
    8000268c:	ef89                	bnez	a5,800026a6 <waitx+0x138>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000268e:	85ea                	mv	a1,s10
    80002690:	854a                	mv	a0,s2
    80002692:	00000097          	auipc	ra,0x0
    80002696:	e78080e7          	jalr	-392(ra) # 8000250a <sleep>
    havekids = 0;
    8000269a:	8766                	mv	a4,s9
    for(np = proc; np < &proc[NPROC]; np++){
    8000269c:	0002f497          	auipc	s1,0x2f
    800026a0:	59448493          	addi	s1,s1,1428 # 80031c30 <proc>
    800026a4:	bf7d                	j	80002662 <waitx+0xf4>
      release(&wait_lock);
    800026a6:	0002e517          	auipc	a0,0x2e
    800026aa:	77250513          	addi	a0,a0,1906 # 80030e18 <wait_lock>
    800026ae:	ffffe097          	auipc	ra,0xffffe
    800026b2:	772080e7          	jalr	1906(ra) # 80000e20 <release>
      return -1;
    800026b6:	59fd                	li	s3,-1
    800026b8:	b79d                	j	8000261e <waitx+0xb0>

00000000800026ba <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800026ba:	7139                	addi	sp,sp,-64
    800026bc:	fc06                	sd	ra,56(sp)
    800026be:	f822                	sd	s0,48(sp)
    800026c0:	f426                	sd	s1,40(sp)
    800026c2:	f04a                	sd	s2,32(sp)
    800026c4:	ec4e                	sd	s3,24(sp)
    800026c6:	e852                	sd	s4,16(sp)
    800026c8:	e456                	sd	s5,8(sp)
    800026ca:	e05a                	sd	s6,0(sp)
    800026cc:	0080                	addi	s0,sp,64
    800026ce:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800026d0:	0002f497          	auipc	s1,0x2f
    800026d4:	56048493          	addi	s1,s1,1376 # 80031c30 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800026d8:	4989                	li	s3,2
        p->state = RUNNABLE;
    800026da:	4b0d                	li	s6,3
        // Specification 2
        p->wtime = ticks;
    800026dc:	00006a97          	auipc	s5,0x6
    800026e0:	494a8a93          	addi	s5,s5,1172 # 80008b70 <ticks>
  for(p = proc; p < &proc[NPROC]; p++) {
    800026e4:	00043917          	auipc	s2,0x43
    800026e8:	d4c90913          	addi	s2,s2,-692 # 80045430 <tickslock>
    800026ec:	a811                	j	80002700 <wakeup+0x46>
      }
      release(&p->lock);
    800026ee:	8526                	mv	a0,s1
    800026f0:	ffffe097          	auipc	ra,0xffffe
    800026f4:	730080e7          	jalr	1840(ra) # 80000e20 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800026f8:	4e048493          	addi	s1,s1,1248
    800026fc:	03248a63          	beq	s1,s2,80002730 <wakeup+0x76>
    if(p != myproc()){
    80002700:	fffff097          	auipc	ra,0xfffff
    80002704:	4ca080e7          	jalr	1226(ra) # 80001bca <myproc>
    80002708:	fea488e3          	beq	s1,a0,800026f8 <wakeup+0x3e>
      acquire(&p->lock);
    8000270c:	8526                	mv	a0,s1
    8000270e:	ffffe097          	auipc	ra,0xffffe
    80002712:	65e080e7          	jalr	1630(ra) # 80000d6c <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002716:	4c9c                	lw	a5,24(s1)
    80002718:	fd379be3          	bne	a5,s3,800026ee <wakeup+0x34>
    8000271c:	709c                	ld	a5,32(s1)
    8000271e:	fd4798e3          	bne	a5,s4,800026ee <wakeup+0x34>
        p->state = RUNNABLE;
    80002722:	0164ac23          	sw	s6,24(s1)
        p->wtime = ticks;
    80002726:	000aa783          	lw	a5,0(s5)
    8000272a:	1af4a223          	sw	a5,420(s1)
    8000272e:	b7c1                	j	800026ee <wakeup+0x34>
    }
  }
}
    80002730:	70e2                	ld	ra,56(sp)
    80002732:	7442                	ld	s0,48(sp)
    80002734:	74a2                	ld	s1,40(sp)
    80002736:	7902                	ld	s2,32(sp)
    80002738:	69e2                	ld	s3,24(sp)
    8000273a:	6a42                	ld	s4,16(sp)
    8000273c:	6aa2                	ld	s5,8(sp)
    8000273e:	6b02                	ld	s6,0(sp)
    80002740:	6121                	addi	sp,sp,64
    80002742:	8082                	ret

0000000080002744 <reparent>:
{
    80002744:	7179                	addi	sp,sp,-48
    80002746:	f406                	sd	ra,40(sp)
    80002748:	f022                	sd	s0,32(sp)
    8000274a:	ec26                	sd	s1,24(sp)
    8000274c:	e84a                	sd	s2,16(sp)
    8000274e:	e44e                	sd	s3,8(sp)
    80002750:	e052                	sd	s4,0(sp)
    80002752:	1800                	addi	s0,sp,48
    80002754:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002756:	0002f497          	auipc	s1,0x2f
    8000275a:	4da48493          	addi	s1,s1,1242 # 80031c30 <proc>
      pp->parent = initproc;
    8000275e:	00006a17          	auipc	s4,0x6
    80002762:	40aa0a13          	addi	s4,s4,1034 # 80008b68 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002766:	00043997          	auipc	s3,0x43
    8000276a:	cca98993          	addi	s3,s3,-822 # 80045430 <tickslock>
    8000276e:	a029                	j	80002778 <reparent+0x34>
    80002770:	4e048493          	addi	s1,s1,1248
    80002774:	01348d63          	beq	s1,s3,8000278e <reparent+0x4a>
    if(pp->parent == p){
    80002778:	7c9c                	ld	a5,56(s1)
    8000277a:	ff279be3          	bne	a5,s2,80002770 <reparent+0x2c>
      pp->parent = initproc;
    8000277e:	000a3503          	ld	a0,0(s4)
    80002782:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002784:	00000097          	auipc	ra,0x0
    80002788:	f36080e7          	jalr	-202(ra) # 800026ba <wakeup>
    8000278c:	b7d5                	j	80002770 <reparent+0x2c>
}
    8000278e:	70a2                	ld	ra,40(sp)
    80002790:	7402                	ld	s0,32(sp)
    80002792:	64e2                	ld	s1,24(sp)
    80002794:	6942                	ld	s2,16(sp)
    80002796:	69a2                	ld	s3,8(sp)
    80002798:	6a02                	ld	s4,0(sp)
    8000279a:	6145                	addi	sp,sp,48
    8000279c:	8082                	ret

000000008000279e <exit>:
{
    8000279e:	7179                	addi	sp,sp,-48
    800027a0:	f406                	sd	ra,40(sp)
    800027a2:	f022                	sd	s0,32(sp)
    800027a4:	ec26                	sd	s1,24(sp)
    800027a6:	e84a                	sd	s2,16(sp)
    800027a8:	e44e                	sd	s3,8(sp)
    800027aa:	e052                	sd	s4,0(sp)
    800027ac:	1800                	addi	s0,sp,48
    800027ae:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800027b0:	fffff097          	auipc	ra,0xfffff
    800027b4:	41a080e7          	jalr	1050(ra) # 80001bca <myproc>
    800027b8:	89aa                	mv	s3,a0
  if(p == initproc)
    800027ba:	00006797          	auipc	a5,0x6
    800027be:	3ae7b783          	ld	a5,942(a5) # 80008b68 <initproc>
    800027c2:	0d050493          	addi	s1,a0,208
    800027c6:	15050913          	addi	s2,a0,336
    800027ca:	02a79363          	bne	a5,a0,800027f0 <exit+0x52>
    panic("init exiting");
    800027ce:	00006517          	auipc	a0,0x6
    800027d2:	a9a50513          	addi	a0,a0,-1382 # 80008268 <digits+0x228>
    800027d6:	ffffe097          	auipc	ra,0xffffe
    800027da:	d66080e7          	jalr	-666(ra) # 8000053c <panic>
      fileclose(f);
    800027de:	00003097          	auipc	ra,0x3
    800027e2:	860080e7          	jalr	-1952(ra) # 8000503e <fileclose>
      p->ofile[fd] = 0;
    800027e6:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800027ea:	04a1                	addi	s1,s1,8
    800027ec:	01248563          	beq	s1,s2,800027f6 <exit+0x58>
    if(p->ofile[fd]){
    800027f0:	6088                	ld	a0,0(s1)
    800027f2:	f575                	bnez	a0,800027de <exit+0x40>
    800027f4:	bfdd                	j	800027ea <exit+0x4c>
  begin_op();
    800027f6:	00002097          	auipc	ra,0x2
    800027fa:	384080e7          	jalr	900(ra) # 80004b7a <begin_op>
  iput(p->cwd);
    800027fe:	1509b503          	ld	a0,336(s3)
    80002802:	00002097          	auipc	ra,0x2
    80002806:	b8c080e7          	jalr	-1140(ra) # 8000438e <iput>
  end_op();
    8000280a:	00002097          	auipc	ra,0x2
    8000280e:	3ea080e7          	jalr	1002(ra) # 80004bf4 <end_op>
  p->cwd = 0;
    80002812:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002816:	0002e497          	auipc	s1,0x2e
    8000281a:	60248493          	addi	s1,s1,1538 # 80030e18 <wait_lock>
    8000281e:	8526                	mv	a0,s1
    80002820:	ffffe097          	auipc	ra,0xffffe
    80002824:	54c080e7          	jalr	1356(ra) # 80000d6c <acquire>
  reparent(p);
    80002828:	854e                	mv	a0,s3
    8000282a:	00000097          	auipc	ra,0x0
    8000282e:	f1a080e7          	jalr	-230(ra) # 80002744 <reparent>
  wakeup(p->parent);
    80002832:	0389b503          	ld	a0,56(s3)
    80002836:	00000097          	auipc	ra,0x0
    8000283a:	e84080e7          	jalr	-380(ra) # 800026ba <wakeup>
  acquire(&p->lock);
    8000283e:	854e                	mv	a0,s3
    80002840:	ffffe097          	auipc	ra,0xffffe
    80002844:	52c080e7          	jalr	1324(ra) # 80000d6c <acquire>
  p->xstate = status;
    80002848:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000284c:	4795                	li	a5,5
    8000284e:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    80002852:	00006797          	auipc	a5,0x6
    80002856:	31e7a783          	lw	a5,798(a5) # 80008b70 <ticks>
    8000285a:	1af9a623          	sw	a5,428(s3)
  release(&wait_lock);
    8000285e:	8526                	mv	a0,s1
    80002860:	ffffe097          	auipc	ra,0xffffe
    80002864:	5c0080e7          	jalr	1472(ra) # 80000e20 <release>
  sched();
    80002868:	00000097          	auipc	ra,0x0
    8000286c:	b90080e7          	jalr	-1136(ra) # 800023f8 <sched>
  panic("zombie exit");
    80002870:	00006517          	auipc	a0,0x6
    80002874:	a0850513          	addi	a0,a0,-1528 # 80008278 <digits+0x238>
    80002878:	ffffe097          	auipc	ra,0xffffe
    8000287c:	cc4080e7          	jalr	-828(ra) # 8000053c <panic>

0000000080002880 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002880:	7179                	addi	sp,sp,-48
    80002882:	f406                	sd	ra,40(sp)
    80002884:	f022                	sd	s0,32(sp)
    80002886:	ec26                	sd	s1,24(sp)
    80002888:	e84a                	sd	s2,16(sp)
    8000288a:	e44e                	sd	s3,8(sp)
    8000288c:	1800                	addi	s0,sp,48
    8000288e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002890:	0002f497          	auipc	s1,0x2f
    80002894:	3a048493          	addi	s1,s1,928 # 80031c30 <proc>
    80002898:	00043997          	auipc	s3,0x43
    8000289c:	b9898993          	addi	s3,s3,-1128 # 80045430 <tickslock>
    acquire(&p->lock);
    800028a0:	8526                	mv	a0,s1
    800028a2:	ffffe097          	auipc	ra,0xffffe
    800028a6:	4ca080e7          	jalr	1226(ra) # 80000d6c <acquire>
    if(p->pid == pid){
    800028aa:	589c                	lw	a5,48(s1)
    800028ac:	01278d63          	beq	a5,s2,800028c6 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800028b0:	8526                	mv	a0,s1
    800028b2:	ffffe097          	auipc	ra,0xffffe
    800028b6:	56e080e7          	jalr	1390(ra) # 80000e20 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800028ba:	4e048493          	addi	s1,s1,1248
    800028be:	ff3491e3          	bne	s1,s3,800028a0 <kill+0x20>
  }
  return -1;
    800028c2:	557d                	li	a0,-1
    800028c4:	a829                	j	800028de <kill+0x5e>
      p->killed = 1;
    800028c6:	4785                	li	a5,1
    800028c8:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800028ca:	4c98                	lw	a4,24(s1)
    800028cc:	4789                	li	a5,2
    800028ce:	00f70f63          	beq	a4,a5,800028ec <kill+0x6c>
      release(&p->lock);
    800028d2:	8526                	mv	a0,s1
    800028d4:	ffffe097          	auipc	ra,0xffffe
    800028d8:	54c080e7          	jalr	1356(ra) # 80000e20 <release>
      return 0;
    800028dc:	4501                	li	a0,0
}
    800028de:	70a2                	ld	ra,40(sp)
    800028e0:	7402                	ld	s0,32(sp)
    800028e2:	64e2                	ld	s1,24(sp)
    800028e4:	6942                	ld	s2,16(sp)
    800028e6:	69a2                	ld	s3,8(sp)
    800028e8:	6145                	addi	sp,sp,48
    800028ea:	8082                	ret
        p->state = RUNNABLE;
    800028ec:	478d                	li	a5,3
    800028ee:	cc9c                	sw	a5,24(s1)
    800028f0:	b7cd                	j	800028d2 <kill+0x52>

00000000800028f2 <setkilled>:

void
setkilled(struct proc *p)
{
    800028f2:	1101                	addi	sp,sp,-32
    800028f4:	ec06                	sd	ra,24(sp)
    800028f6:	e822                	sd	s0,16(sp)
    800028f8:	e426                	sd	s1,8(sp)
    800028fa:	1000                	addi	s0,sp,32
    800028fc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800028fe:	ffffe097          	auipc	ra,0xffffe
    80002902:	46e080e7          	jalr	1134(ra) # 80000d6c <acquire>
  p->killed = 1;
    80002906:	4785                	li	a5,1
    80002908:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000290a:	8526                	mv	a0,s1
    8000290c:	ffffe097          	auipc	ra,0xffffe
    80002910:	514080e7          	jalr	1300(ra) # 80000e20 <release>
}
    80002914:	60e2                	ld	ra,24(sp)
    80002916:	6442                	ld	s0,16(sp)
    80002918:	64a2                	ld	s1,8(sp)
    8000291a:	6105                	addi	sp,sp,32
    8000291c:	8082                	ret

000000008000291e <killed>:

int
killed(struct proc *p)
{
    8000291e:	1101                	addi	sp,sp,-32
    80002920:	ec06                	sd	ra,24(sp)
    80002922:	e822                	sd	s0,16(sp)
    80002924:	e426                	sd	s1,8(sp)
    80002926:	e04a                	sd	s2,0(sp)
    80002928:	1000                	addi	s0,sp,32
    8000292a:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000292c:	ffffe097          	auipc	ra,0xffffe
    80002930:	440080e7          	jalr	1088(ra) # 80000d6c <acquire>
  k = p->killed;
    80002934:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002938:	8526                	mv	a0,s1
    8000293a:	ffffe097          	auipc	ra,0xffffe
    8000293e:	4e6080e7          	jalr	1254(ra) # 80000e20 <release>
  return k;
}
    80002942:	854a                	mv	a0,s2
    80002944:	60e2                	ld	ra,24(sp)
    80002946:	6442                	ld	s0,16(sp)
    80002948:	64a2                	ld	s1,8(sp)
    8000294a:	6902                	ld	s2,0(sp)
    8000294c:	6105                	addi	sp,sp,32
    8000294e:	8082                	ret

0000000080002950 <wait>:
{
    80002950:	715d                	addi	sp,sp,-80
    80002952:	e486                	sd	ra,72(sp)
    80002954:	e0a2                	sd	s0,64(sp)
    80002956:	fc26                	sd	s1,56(sp)
    80002958:	f84a                	sd	s2,48(sp)
    8000295a:	f44e                	sd	s3,40(sp)
    8000295c:	f052                	sd	s4,32(sp)
    8000295e:	ec56                	sd	s5,24(sp)
    80002960:	e85a                	sd	s6,16(sp)
    80002962:	e45e                	sd	s7,8(sp)
    80002964:	e062                	sd	s8,0(sp)
    80002966:	0880                	addi	s0,sp,80
    80002968:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000296a:	fffff097          	auipc	ra,0xfffff
    8000296e:	260080e7          	jalr	608(ra) # 80001bca <myproc>
    80002972:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002974:	0002e517          	auipc	a0,0x2e
    80002978:	4a450513          	addi	a0,a0,1188 # 80030e18 <wait_lock>
    8000297c:	ffffe097          	auipc	ra,0xffffe
    80002980:	3f0080e7          	jalr	1008(ra) # 80000d6c <acquire>
    havekids = 0;
    80002984:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002986:	4a15                	li	s4,5
        havekids = 1;
    80002988:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000298a:	00043997          	auipc	s3,0x43
    8000298e:	aa698993          	addi	s3,s3,-1370 # 80045430 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002992:	0002ec17          	auipc	s8,0x2e
    80002996:	486c0c13          	addi	s8,s8,1158 # 80030e18 <wait_lock>
    8000299a:	a0d1                	j	80002a5e <wait+0x10e>
          pid = pp->pid;
    8000299c:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800029a0:	000b0e63          	beqz	s6,800029bc <wait+0x6c>
    800029a4:	4691                	li	a3,4
    800029a6:	02c48613          	addi	a2,s1,44
    800029aa:	85da                	mv	a1,s6
    800029ac:	05093503          	ld	a0,80(s2)
    800029b0:	fffff097          	auipc	ra,0xfffff
    800029b4:	e60080e7          	jalr	-416(ra) # 80001810 <copyout>
    800029b8:	04054163          	bltz	a0,800029fa <wait+0xaa>
          freeproc(pp);
    800029bc:	8526                	mv	a0,s1
    800029be:	fffff097          	auipc	ra,0xfffff
    800029c2:	3be080e7          	jalr	958(ra) # 80001d7c <freeproc>
          release(&pp->lock);
    800029c6:	8526                	mv	a0,s1
    800029c8:	ffffe097          	auipc	ra,0xffffe
    800029cc:	458080e7          	jalr	1112(ra) # 80000e20 <release>
          release(&wait_lock);
    800029d0:	0002e517          	auipc	a0,0x2e
    800029d4:	44850513          	addi	a0,a0,1096 # 80030e18 <wait_lock>
    800029d8:	ffffe097          	auipc	ra,0xffffe
    800029dc:	448080e7          	jalr	1096(ra) # 80000e20 <release>
}
    800029e0:	854e                	mv	a0,s3
    800029e2:	60a6                	ld	ra,72(sp)
    800029e4:	6406                	ld	s0,64(sp)
    800029e6:	74e2                	ld	s1,56(sp)
    800029e8:	7942                	ld	s2,48(sp)
    800029ea:	79a2                	ld	s3,40(sp)
    800029ec:	7a02                	ld	s4,32(sp)
    800029ee:	6ae2                	ld	s5,24(sp)
    800029f0:	6b42                	ld	s6,16(sp)
    800029f2:	6ba2                	ld	s7,8(sp)
    800029f4:	6c02                	ld	s8,0(sp)
    800029f6:	6161                	addi	sp,sp,80
    800029f8:	8082                	ret
            release(&pp->lock);
    800029fa:	8526                	mv	a0,s1
    800029fc:	ffffe097          	auipc	ra,0xffffe
    80002a00:	424080e7          	jalr	1060(ra) # 80000e20 <release>
            release(&wait_lock);
    80002a04:	0002e517          	auipc	a0,0x2e
    80002a08:	41450513          	addi	a0,a0,1044 # 80030e18 <wait_lock>
    80002a0c:	ffffe097          	auipc	ra,0xffffe
    80002a10:	414080e7          	jalr	1044(ra) # 80000e20 <release>
            return -1;
    80002a14:	59fd                	li	s3,-1
    80002a16:	b7e9                	j	800029e0 <wait+0x90>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002a18:	4e048493          	addi	s1,s1,1248
    80002a1c:	03348463          	beq	s1,s3,80002a44 <wait+0xf4>
      if(pp->parent == p){
    80002a20:	7c9c                	ld	a5,56(s1)
    80002a22:	ff279be3          	bne	a5,s2,80002a18 <wait+0xc8>
        acquire(&pp->lock);
    80002a26:	8526                	mv	a0,s1
    80002a28:	ffffe097          	auipc	ra,0xffffe
    80002a2c:	344080e7          	jalr	836(ra) # 80000d6c <acquire>
        if(pp->state == ZOMBIE){
    80002a30:	4c9c                	lw	a5,24(s1)
    80002a32:	f74785e3          	beq	a5,s4,8000299c <wait+0x4c>
        release(&pp->lock);
    80002a36:	8526                	mv	a0,s1
    80002a38:	ffffe097          	auipc	ra,0xffffe
    80002a3c:	3e8080e7          	jalr	1000(ra) # 80000e20 <release>
        havekids = 1;
    80002a40:	8756                	mv	a4,s5
    80002a42:	bfd9                	j	80002a18 <wait+0xc8>
    if(!havekids || killed(p)){
    80002a44:	c31d                	beqz	a4,80002a6a <wait+0x11a>
    80002a46:	854a                	mv	a0,s2
    80002a48:	00000097          	auipc	ra,0x0
    80002a4c:	ed6080e7          	jalr	-298(ra) # 8000291e <killed>
    80002a50:	ed09                	bnez	a0,80002a6a <wait+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002a52:	85e2                	mv	a1,s8
    80002a54:	854a                	mv	a0,s2
    80002a56:	00000097          	auipc	ra,0x0
    80002a5a:	ab4080e7          	jalr	-1356(ra) # 8000250a <sleep>
    havekids = 0;
    80002a5e:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002a60:	0002f497          	auipc	s1,0x2f
    80002a64:	1d048493          	addi	s1,s1,464 # 80031c30 <proc>
    80002a68:	bf65                	j	80002a20 <wait+0xd0>
      release(&wait_lock);
    80002a6a:	0002e517          	auipc	a0,0x2e
    80002a6e:	3ae50513          	addi	a0,a0,942 # 80030e18 <wait_lock>
    80002a72:	ffffe097          	auipc	ra,0xffffe
    80002a76:	3ae080e7          	jalr	942(ra) # 80000e20 <release>
      return -1;
    80002a7a:	59fd                	li	s3,-1
    80002a7c:	b795                	j	800029e0 <wait+0x90>

0000000080002a7e <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002a7e:	7179                	addi	sp,sp,-48
    80002a80:	f406                	sd	ra,40(sp)
    80002a82:	f022                	sd	s0,32(sp)
    80002a84:	ec26                	sd	s1,24(sp)
    80002a86:	e84a                	sd	s2,16(sp)
    80002a88:	e44e                	sd	s3,8(sp)
    80002a8a:	e052                	sd	s4,0(sp)
    80002a8c:	1800                	addi	s0,sp,48
    80002a8e:	84aa                	mv	s1,a0
    80002a90:	892e                	mv	s2,a1
    80002a92:	89b2                	mv	s3,a2
    80002a94:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002a96:	fffff097          	auipc	ra,0xfffff
    80002a9a:	134080e7          	jalr	308(ra) # 80001bca <myproc>
  if(user_dst){
    80002a9e:	c08d                	beqz	s1,80002ac0 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002aa0:	86d2                	mv	a3,s4
    80002aa2:	864e                	mv	a2,s3
    80002aa4:	85ca                	mv	a1,s2
    80002aa6:	6928                	ld	a0,80(a0)
    80002aa8:	fffff097          	auipc	ra,0xfffff
    80002aac:	d68080e7          	jalr	-664(ra) # 80001810 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002ab0:	70a2                	ld	ra,40(sp)
    80002ab2:	7402                	ld	s0,32(sp)
    80002ab4:	64e2                	ld	s1,24(sp)
    80002ab6:	6942                	ld	s2,16(sp)
    80002ab8:	69a2                	ld	s3,8(sp)
    80002aba:	6a02                	ld	s4,0(sp)
    80002abc:	6145                	addi	sp,sp,48
    80002abe:	8082                	ret
    memmove((char *)dst, src, len);
    80002ac0:	000a061b          	sext.w	a2,s4
    80002ac4:	85ce                	mv	a1,s3
    80002ac6:	854a                	mv	a0,s2
    80002ac8:	ffffe097          	auipc	ra,0xffffe
    80002acc:	3fc080e7          	jalr	1020(ra) # 80000ec4 <memmove>
    return 0;
    80002ad0:	8526                	mv	a0,s1
    80002ad2:	bff9                	j	80002ab0 <either_copyout+0x32>

0000000080002ad4 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002ad4:	7179                	addi	sp,sp,-48
    80002ad6:	f406                	sd	ra,40(sp)
    80002ad8:	f022                	sd	s0,32(sp)
    80002ada:	ec26                	sd	s1,24(sp)
    80002adc:	e84a                	sd	s2,16(sp)
    80002ade:	e44e                	sd	s3,8(sp)
    80002ae0:	e052                	sd	s4,0(sp)
    80002ae2:	1800                	addi	s0,sp,48
    80002ae4:	892a                	mv	s2,a0
    80002ae6:	84ae                	mv	s1,a1
    80002ae8:	89b2                	mv	s3,a2
    80002aea:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002aec:	fffff097          	auipc	ra,0xfffff
    80002af0:	0de080e7          	jalr	222(ra) # 80001bca <myproc>
  if(user_src){
    80002af4:	c08d                	beqz	s1,80002b16 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002af6:	86d2                	mv	a3,s4
    80002af8:	864e                	mv	a2,s3
    80002afa:	85ca                	mv	a1,s2
    80002afc:	6928                	ld	a0,80(a0)
    80002afe:	fffff097          	auipc	ra,0xfffff
    80002b02:	d9e080e7          	jalr	-610(ra) # 8000189c <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002b06:	70a2                	ld	ra,40(sp)
    80002b08:	7402                	ld	s0,32(sp)
    80002b0a:	64e2                	ld	s1,24(sp)
    80002b0c:	6942                	ld	s2,16(sp)
    80002b0e:	69a2                	ld	s3,8(sp)
    80002b10:	6a02                	ld	s4,0(sp)
    80002b12:	6145                	addi	sp,sp,48
    80002b14:	8082                	ret
    memmove(dst, (char*)src, len);
    80002b16:	000a061b          	sext.w	a2,s4
    80002b1a:	85ce                	mv	a1,s3
    80002b1c:	854a                	mv	a0,s2
    80002b1e:	ffffe097          	auipc	ra,0xffffe
    80002b22:	3a6080e7          	jalr	934(ra) # 80000ec4 <memmove>
    return 0;
    80002b26:	8526                	mv	a0,s1
    80002b28:	bff9                	j	80002b06 <either_copyin+0x32>

0000000080002b2a <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002b2a:	715d                	addi	sp,sp,-80
    80002b2c:	e486                	sd	ra,72(sp)
    80002b2e:	e0a2                	sd	s0,64(sp)
    80002b30:	fc26                	sd	s1,56(sp)
    80002b32:	f84a                	sd	s2,48(sp)
    80002b34:	f44e                	sd	s3,40(sp)
    80002b36:	f052                	sd	s4,32(sp)
    80002b38:	ec56                	sd	s5,24(sp)
    80002b3a:	e85a                	sd	s6,16(sp)
    80002b3c:	e45e                	sd	s7,8(sp)
    80002b3e:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002b40:	00005517          	auipc	a0,0x5
    80002b44:	59050513          	addi	a0,a0,1424 # 800080d0 <digits+0x90>
    80002b48:	ffffe097          	auipc	ra,0xffffe
    80002b4c:	a3e080e7          	jalr	-1474(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002b50:	0002f497          	auipc	s1,0x2f
    80002b54:	23848493          	addi	s1,s1,568 # 80031d88 <proc+0x158>
    80002b58:	00043917          	auipc	s2,0x43
    80002b5c:	a3090913          	addi	s2,s2,-1488 # 80045588 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b60:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002b62:	00005997          	auipc	s3,0x5
    80002b66:	72698993          	addi	s3,s3,1830 # 80008288 <digits+0x248>
    // Specification 1
    printf("%d %s %s %d %d %d", p->pid, state, p->name, p->smask, p->stime,p->wtime);
    80002b6a:	00005a97          	auipc	s5,0x5
    80002b6e:	726a8a93          	addi	s5,s5,1830 # 80008290 <digits+0x250>
    printf("\n");
    80002b72:	00005a17          	auipc	s4,0x5
    80002b76:	55ea0a13          	addi	s4,s4,1374 # 800080d0 <digits+0x90>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b7a:	00005b97          	auipc	s7,0x5
    80002b7e:	75eb8b93          	addi	s7,s7,1886 # 800082d8 <states.0>
    80002b82:	a02d                	j	80002bac <procdump+0x82>
    printf("%d %s %s %d %d %d", p->pid, state, p->name, p->smask, p->stime,p->wtime);
    80002b84:	04c6a803          	lw	a6,76(a3)
    80002b88:	42bc                	lw	a5,64(a3)
    80002b8a:	4a98                	lw	a4,16(a3)
    80002b8c:	ed86a583          	lw	a1,-296(a3)
    80002b90:	8556                	mv	a0,s5
    80002b92:	ffffe097          	auipc	ra,0xffffe
    80002b96:	9f4080e7          	jalr	-1548(ra) # 80000586 <printf>
    printf("\n");
    80002b9a:	8552                	mv	a0,s4
    80002b9c:	ffffe097          	auipc	ra,0xffffe
    80002ba0:	9ea080e7          	jalr	-1558(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002ba4:	4e048493          	addi	s1,s1,1248
    80002ba8:	03248263          	beq	s1,s2,80002bcc <procdump+0xa2>
    if(p->state == UNUSED)
    80002bac:	86a6                	mv	a3,s1
    80002bae:	ec04a783          	lw	a5,-320(s1)
    80002bb2:	dbed                	beqz	a5,80002ba4 <procdump+0x7a>
      state = "???";
    80002bb4:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002bb6:	fcfb67e3          	bltu	s6,a5,80002b84 <procdump+0x5a>
    80002bba:	02079713          	slli	a4,a5,0x20
    80002bbe:	01d75793          	srli	a5,a4,0x1d
    80002bc2:	97de                	add	a5,a5,s7
    80002bc4:	6390                	ld	a2,0(a5)
    80002bc6:	fe5d                	bnez	a2,80002b84 <procdump+0x5a>
      state = "???";
    80002bc8:	864e                	mv	a2,s3
    80002bca:	bf6d                	j	80002b84 <procdump+0x5a>
  }
}
    80002bcc:	60a6                	ld	ra,72(sp)
    80002bce:	6406                	ld	s0,64(sp)
    80002bd0:	74e2                	ld	s1,56(sp)
    80002bd2:	7942                	ld	s2,48(sp)
    80002bd4:	79a2                	ld	s3,40(sp)
    80002bd6:	7a02                	ld	s4,32(sp)
    80002bd8:	6ae2                	ld	s5,24(sp)
    80002bda:	6b42                	ld	s6,16(sp)
    80002bdc:	6ba2                	ld	s7,8(sp)
    80002bde:	6161                	addi	sp,sp,80
    80002be0:	8082                	ret

0000000080002be2 <swtch>:
    80002be2:	00153023          	sd	ra,0(a0)
    80002be6:	00253423          	sd	sp,8(a0)
    80002bea:	e900                	sd	s0,16(a0)
    80002bec:	ed04                	sd	s1,24(a0)
    80002bee:	03253023          	sd	s2,32(a0)
    80002bf2:	03353423          	sd	s3,40(a0)
    80002bf6:	03453823          	sd	s4,48(a0)
    80002bfa:	03553c23          	sd	s5,56(a0)
    80002bfe:	05653023          	sd	s6,64(a0)
    80002c02:	05753423          	sd	s7,72(a0)
    80002c06:	05853823          	sd	s8,80(a0)
    80002c0a:	05953c23          	sd	s9,88(a0)
    80002c0e:	07a53023          	sd	s10,96(a0)
    80002c12:	07b53423          	sd	s11,104(a0)
    80002c16:	0005b083          	ld	ra,0(a1)
    80002c1a:	0085b103          	ld	sp,8(a1)
    80002c1e:	6980                	ld	s0,16(a1)
    80002c20:	6d84                	ld	s1,24(a1)
    80002c22:	0205b903          	ld	s2,32(a1)
    80002c26:	0285b983          	ld	s3,40(a1)
    80002c2a:	0305ba03          	ld	s4,48(a1)
    80002c2e:	0385ba83          	ld	s5,56(a1)
    80002c32:	0405bb03          	ld	s6,64(a1)
    80002c36:	0485bb83          	ld	s7,72(a1)
    80002c3a:	0505bc03          	ld	s8,80(a1)
    80002c3e:	0585bc83          	ld	s9,88(a1)
    80002c42:	0605bd03          	ld	s10,96(a1)
    80002c46:	0685bd83          	ld	s11,104(a1)
    80002c4a:	8082                	ret

0000000080002c4c <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002c4c:	1141                	addi	sp,sp,-16
    80002c4e:	e406                	sd	ra,8(sp)
    80002c50:	e022                	sd	s0,0(sp)
    80002c52:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002c54:	00005597          	auipc	a1,0x5
    80002c58:	6b458593          	addi	a1,a1,1716 # 80008308 <states.0+0x30>
    80002c5c:	00042517          	auipc	a0,0x42
    80002c60:	7d450513          	addi	a0,a0,2004 # 80045430 <tickslock>
    80002c64:	ffffe097          	auipc	ra,0xffffe
    80002c68:	078080e7          	jalr	120(ra) # 80000cdc <initlock>
}
    80002c6c:	60a2                	ld	ra,8(sp)
    80002c6e:	6402                	ld	s0,0(sp)
    80002c70:	0141                	addi	sp,sp,16
    80002c72:	8082                	ret

0000000080002c74 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002c74:	1141                	addi	sp,sp,-16
    80002c76:	e422                	sd	s0,8(sp)
    80002c78:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c7a:	00004797          	auipc	a5,0x4
    80002c7e:	9e678793          	addi	a5,a5,-1562 # 80006660 <kernelvec>
    80002c82:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002c86:	6422                	ld	s0,8(sp)
    80002c88:	0141                	addi	sp,sp,16
    80002c8a:	8082                	ret

0000000080002c8c <handleCOW>:
  pte_t *pte;
  uint64 pa;
  uint flags;
  char *mem;
  
  if (va >= MAXVA)
    80002c8c:	57fd                	li	a5,-1
    80002c8e:	83e9                	srli	a5,a5,0x1a
    80002c90:	00b7f463          	bgeu	a5,a1,80002c98 <handleCOW+0xc>
    return 1;
    80002c94:	4505                	li	a0,1
  }
  memref_lock_kalloc();
  memref_unlock();

  return 0;
}
    80002c96:	8082                	ret
int handleCOW(pagetable_t pagetable, uint64 va) {
    80002c98:	7139                	addi	sp,sp,-64
    80002c9a:	fc06                	sd	ra,56(sp)
    80002c9c:	f822                	sd	s0,48(sp)
    80002c9e:	f426                	sd	s1,40(sp)
    80002ca0:	f04a                	sd	s2,32(sp)
    80002ca2:	ec4e                	sd	s3,24(sp)
    80002ca4:	e852                	sd	s4,16(sp)
    80002ca6:	e456                	sd	s5,8(sp)
    80002ca8:	e05a                	sd	s6,0(sp)
    80002caa:	0080                	addi	s0,sp,64
    80002cac:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    80002cae:	77fd                	lui	a5,0xfffff
    80002cb0:	00f5f4b3          	and	s1,a1,a5
  pte = walk(pagetable, va, 0);
    80002cb4:	4601                	li	a2,0
    80002cb6:	85a6                	mv	a1,s1
    80002cb8:	ffffe097          	auipc	ra,0xffffe
    80002cbc:	492080e7          	jalr	1170(ra) # 8000114a <walk>
    80002cc0:	8a2a                	mv	s4,a0
    return 1;
    80002cc2:	4505                	li	a0,1
  if (va == 0 || (flags & PTE_COW) == 0 || pte == 0 || (flags & PTE_V) == 0 || (flags & PTE_U) == 0) {
    80002cc4:	cc89                	beqz	s1,80002cde <handleCOW+0x52>
  pa = PTE2PA(*pte);
    80002cc6:	000a3983          	ld	s3,0(s4)
  flags = PTE_FLAGS(*pte);
    80002cca:	00098a9b          	sext.w	s5,s3
  if (va == 0 || (flags & PTE_COW) == 0 || pte == 0 || (flags & PTE_V) == 0 || (flags & PTE_U) == 0) {
    80002cce:	2009f793          	andi	a5,s3,512
    80002cd2:	c791                	beqz	a5,80002cde <handleCOW+0x52>
    80002cd4:	011af793          	andi	a5,s5,17
    80002cd8:	4745                	li	a4,17
    80002cda:	00e78c63          	beq	a5,a4,80002cf2 <handleCOW+0x66>
}
    80002cde:	70e2                	ld	ra,56(sp)
    80002ce0:	7442                	ld	s0,48(sp)
    80002ce2:	74a2                	ld	s1,40(sp)
    80002ce4:	7902                	ld	s2,32(sp)
    80002ce6:	69e2                	ld	s3,24(sp)
    80002ce8:	6a42                	ld	s4,16(sp)
    80002cea:	6aa2                	ld	s5,8(sp)
    80002cec:	6b02                	ld	s6,0(sp)
    80002cee:	6121                	addi	sp,sp,64
    80002cf0:	8082                	ret
  memref_lock();
    80002cf2:	ffffe097          	auipc	ra,0xffffe
    80002cf6:	cf2080e7          	jalr	-782(ra) # 800009e4 <memref_lock>
  memref_unlock_kalloc();
    80002cfa:	ffffe097          	auipc	ra,0xffffe
    80002cfe:	d88080e7          	jalr	-632(ra) # 80000a82 <memref_unlock_kalloc>
  pa = PTE2PA(*pte);
    80002d02:	00a9d993          	srli	s3,s3,0xa
    80002d06:	09b2                	slli	s3,s3,0xc
  int fq = memref_get((void*)pa);
    80002d08:	854e                	mv	a0,s3
    80002d0a:	ffffe097          	auipc	ra,0xffffe
    80002d0e:	d1a080e7          	jalr	-742(ra) # 80000a24 <memref_get>
    80002d12:	8b2a                	mv	s6,a0
  if (fq == 1) {
    80002d14:	4785                	li	a5,1
    80002d16:	02f51463          	bne	a0,a5,80002d3e <handleCOW+0xb2>
    *pte = (*pte & (~PTE_COW)) | PTE_W;
    80002d1a:	000a3783          	ld	a5,0(s4)
    80002d1e:	dfb7f793          	andi	a5,a5,-517
    80002d22:	0047e793          	ori	a5,a5,4
    80002d26:	00fa3023          	sd	a5,0(s4)
  memref_lock_kalloc();
    80002d2a:	ffffe097          	auipc	ra,0xffffe
    80002d2e:	d42080e7          	jalr	-702(ra) # 80000a6c <memref_lock_kalloc>
  memref_unlock();
    80002d32:	ffffe097          	auipc	ra,0xffffe
    80002d36:	cd2080e7          	jalr	-814(ra) # 80000a04 <memref_unlock>
  return 0;
    80002d3a:	4501                	li	a0,0
    80002d3c:	b74d                	j	80002cde <handleCOW+0x52>
    if ((mem = kalloc()) == 0) {
    80002d3e:	ffffe097          	auipc	ra,0xffffe
    80002d42:	eee080e7          	jalr	-274(ra) # 80000c2c <kalloc>
    80002d46:	8a2a                	mv	s4,a0
    80002d48:	c521                	beqz	a0,80002d90 <handleCOW+0x104>
    memmove((void*)mem, (void*)pa, PGSIZE);
    80002d4a:	6605                	lui	a2,0x1
    80002d4c:	85ce                	mv	a1,s3
    80002d4e:	ffffe097          	auipc	ra,0xffffe
    80002d52:	176080e7          	jalr	374(ra) # 80000ec4 <memmove>
    uvmunmap(pagetable, va, 1, 0);
    80002d56:	4681                	li	a3,0
    80002d58:	4605                	li	a2,1
    80002d5a:	85a6                	mv	a1,s1
    80002d5c:	854a                	mv	a0,s2
    80002d5e:	ffffe097          	auipc	ra,0xffffe
    80002d62:	69a080e7          	jalr	1690(ra) # 800013f8 <uvmunmap>
  flags = (flags & (~PTE_COW)) | PTE_W;
    80002d66:	1fbaf713          	andi	a4,s5,507
    if (mappages(pagetable, va, PGSIZE, (uint64)mem, flags) != 0) {
    80002d6a:	00476713          	ori	a4,a4,4
    80002d6e:	86d2                	mv	a3,s4
    80002d70:	6605                	lui	a2,0x1
    80002d72:	85a6                	mv	a1,s1
    80002d74:	854a                	mv	a0,s2
    80002d76:	ffffe097          	auipc	ra,0xffffe
    80002d7a:	4bc080e7          	jalr	1212(ra) # 80001232 <mappages>
    80002d7e:	ed19                	bnez	a0,80002d9c <handleCOW+0x110>
    memref_set((void*)pa, fq - 1);
    80002d80:	fffb059b          	addiw	a1,s6,-1
    80002d84:	854e                	mv	a0,s3
    80002d86:	ffffe097          	auipc	ra,0xffffe
    80002d8a:	cc2080e7          	jalr	-830(ra) # 80000a48 <memref_set>
    80002d8e:	bf71                	j	80002d2a <handleCOW+0x9e>
      memref_unlock();
    80002d90:	ffffe097          	auipc	ra,0xffffe
    80002d94:	c74080e7          	jalr	-908(ra) # 80000a04 <memref_unlock>
      return 1;
    80002d98:	4505                	li	a0,1
    80002d9a:	b791                	j	80002cde <handleCOW+0x52>
      kfree(mem);
    80002d9c:	8552                	mv	a0,s4
    80002d9e:	ffffe097          	auipc	ra,0xffffe
    80002da2:	cf8080e7          	jalr	-776(ra) # 80000a96 <kfree>
      memref_unlock();
    80002da6:	ffffe097          	auipc	ra,0xffffe
    80002daa:	c5e080e7          	jalr	-930(ra) # 80000a04 <memref_unlock>
      return 1;
    80002dae:	4505                	li	a0,1
    80002db0:	b73d                	j	80002cde <handleCOW+0x52>

0000000080002db2 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002db2:	1141                	addi	sp,sp,-16
    80002db4:	e406                	sd	ra,8(sp)
    80002db6:	e022                	sd	s0,0(sp)
    80002db8:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002dba:	fffff097          	auipc	ra,0xfffff
    80002dbe:	e10080e7          	jalr	-496(ra) # 80001bca <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002dc2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002dc6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002dc8:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002dcc:	00004697          	auipc	a3,0x4
    80002dd0:	23468693          	addi	a3,a3,564 # 80007000 <_trampoline>
    80002dd4:	00004717          	auipc	a4,0x4
    80002dd8:	22c70713          	addi	a4,a4,556 # 80007000 <_trampoline>
    80002ddc:	8f15                	sub	a4,a4,a3
    80002dde:	040007b7          	lui	a5,0x4000
    80002de2:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002de4:	07b2                	slli	a5,a5,0xc
    80002de6:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002de8:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002dec:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002dee:	18002673          	csrr	a2,satp
    80002df2:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002df4:	6d30                	ld	a2,88(a0)
    80002df6:	6138                	ld	a4,64(a0)
    80002df8:	6585                	lui	a1,0x1
    80002dfa:	972e                	add	a4,a4,a1
    80002dfc:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002dfe:	6d38                	ld	a4,88(a0)
    80002e00:	00000617          	auipc	a2,0x0
    80002e04:	14260613          	addi	a2,a2,322 # 80002f42 <usertrap>
    80002e08:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002e0a:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002e0c:	8612                	mv	a2,tp
    80002e0e:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e10:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002e14:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002e18:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e1c:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002e20:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002e22:	6f18                	ld	a4,24(a4)
    80002e24:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002e28:	6928                	ld	a0,80(a0)
    80002e2a:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002e2c:	00004717          	auipc	a4,0x4
    80002e30:	27070713          	addi	a4,a4,624 # 8000709c <userret>
    80002e34:	8f15                	sub	a4,a4,a3
    80002e36:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002e38:	577d                	li	a4,-1
    80002e3a:	177e                	slli	a4,a4,0x3f
    80002e3c:	8d59                	or	a0,a0,a4
    80002e3e:	9782                	jalr	a5
}
    80002e40:	60a2                	ld	ra,8(sp)
    80002e42:	6402                	ld	s0,0(sp)
    80002e44:	0141                	addi	sp,sp,16
    80002e46:	8082                	ret

0000000080002e48 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002e48:	1101                	addi	sp,sp,-32
    80002e4a:	ec06                	sd	ra,24(sp)
    80002e4c:	e822                	sd	s0,16(sp)
    80002e4e:	e426                	sd	s1,8(sp)
    80002e50:	e04a                	sd	s2,0(sp)
    80002e52:	1000                	addi	s0,sp,32
  acquire(&tickslock);    
    80002e54:	00042917          	auipc	s2,0x42
    80002e58:	5dc90913          	addi	s2,s2,1500 # 80045430 <tickslock>
    80002e5c:	854a                	mv	a0,s2
    80002e5e:	ffffe097          	auipc	ra,0xffffe
    80002e62:	f0e080e7          	jalr	-242(ra) # 80000d6c <acquire>
  ticks++;
    80002e66:	00006497          	auipc	s1,0x6
    80002e6a:	d0a48493          	addi	s1,s1,-758 # 80008b70 <ticks>
    80002e6e:	409c                	lw	a5,0(s1)
    80002e70:	2785                	addiw	a5,a5,1
    80002e72:	c09c                	sw	a5,0(s1)
  update_time();
    80002e74:	fffff097          	auipc	ra,0xfffff
    80002e78:	2d2080e7          	jalr	722(ra) # 80002146 <update_time>
  wakeup(&ticks);
    80002e7c:	8526                	mv	a0,s1
    80002e7e:	00000097          	auipc	ra,0x0
    80002e82:	83c080e7          	jalr	-1988(ra) # 800026ba <wakeup>
  release(&tickslock);
    80002e86:	854a                	mv	a0,s2
    80002e88:	ffffe097          	auipc	ra,0xffffe
    80002e8c:	f98080e7          	jalr	-104(ra) # 80000e20 <release>
}
    80002e90:	60e2                	ld	ra,24(sp)
    80002e92:	6442                	ld	s0,16(sp)
    80002e94:	64a2                	ld	s1,8(sp)
    80002e96:	6902                	ld	s2,0(sp)
    80002e98:	6105                	addi	sp,sp,32
    80002e9a:	8082                	ret

0000000080002e9c <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e9c:	142027f3          	csrr	a5,scause

    return 2;
  }
  else
  {
    return 0;
    80002ea0:	4501                	li	a0,0
  if ((scause & 0x8000000000000000L) &&
    80002ea2:	0807df63          	bgez	a5,80002f40 <devintr+0xa4>
{
    80002ea6:	1101                	addi	sp,sp,-32
    80002ea8:	ec06                	sd	ra,24(sp)
    80002eaa:	e822                	sd	s0,16(sp)
    80002eac:	e426                	sd	s1,8(sp)
    80002eae:	1000                	addi	s0,sp,32
      (scause & 0xff) == 9)
    80002eb0:	0ff7f713          	zext.b	a4,a5
  if ((scause & 0x8000000000000000L) &&
    80002eb4:	46a5                	li	a3,9
    80002eb6:	00d70d63          	beq	a4,a3,80002ed0 <devintr+0x34>
  else if (scause == 0x8000000000000001L)
    80002eba:	577d                	li	a4,-1
    80002ebc:	177e                	slli	a4,a4,0x3f
    80002ebe:	0705                	addi	a4,a4,1
    return 0;
    80002ec0:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002ec2:	04e78e63          	beq	a5,a4,80002f1e <devintr+0x82>
  }
}
    80002ec6:	60e2                	ld	ra,24(sp)
    80002ec8:	6442                	ld	s0,16(sp)
    80002eca:	64a2                	ld	s1,8(sp)
    80002ecc:	6105                	addi	sp,sp,32
    80002ece:	8082                	ret
    int irq = plic_claim();
    80002ed0:	00004097          	auipc	ra,0x4
    80002ed4:	898080e7          	jalr	-1896(ra) # 80006768 <plic_claim>
    80002ed8:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002eda:	47a9                	li	a5,10
    80002edc:	02f50763          	beq	a0,a5,80002f0a <devintr+0x6e>
    else if (irq == VIRTIO0_IRQ)
    80002ee0:	4785                	li	a5,1
    80002ee2:	02f50963          	beq	a0,a5,80002f14 <devintr+0x78>
    return 1;
    80002ee6:	4505                	li	a0,1
    else if (irq)
    80002ee8:	dcf9                	beqz	s1,80002ec6 <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    80002eea:	85a6                	mv	a1,s1
    80002eec:	00005517          	auipc	a0,0x5
    80002ef0:	42450513          	addi	a0,a0,1060 # 80008310 <states.0+0x38>
    80002ef4:	ffffd097          	auipc	ra,0xffffd
    80002ef8:	692080e7          	jalr	1682(ra) # 80000586 <printf>
      plic_complete(irq);
    80002efc:	8526                	mv	a0,s1
    80002efe:	00004097          	auipc	ra,0x4
    80002f02:	88e080e7          	jalr	-1906(ra) # 8000678c <plic_complete>
    return 1;
    80002f06:	4505                	li	a0,1
    80002f08:	bf7d                	j	80002ec6 <devintr+0x2a>
      uartintr();
    80002f0a:	ffffe097          	auipc	ra,0xffffe
    80002f0e:	a8a080e7          	jalr	-1398(ra) # 80000994 <uartintr>
    if (irq)
    80002f12:	b7ed                	j	80002efc <devintr+0x60>
      virtio_disk_intr();
    80002f14:	00004097          	auipc	ra,0x4
    80002f18:	d3e080e7          	jalr	-706(ra) # 80006c52 <virtio_disk_intr>
    if (irq)
    80002f1c:	b7c5                	j	80002efc <devintr+0x60>
    if (cpuid() == 0)
    80002f1e:	fffff097          	auipc	ra,0xfffff
    80002f22:	c80080e7          	jalr	-896(ra) # 80001b9e <cpuid>
    80002f26:	c901                	beqz	a0,80002f36 <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002f28:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002f2c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002f2e:	14479073          	csrw	sip,a5
    return 2;
    80002f32:	4509                	li	a0,2
    80002f34:	bf49                	j	80002ec6 <devintr+0x2a>
      clockintr();
    80002f36:	00000097          	auipc	ra,0x0
    80002f3a:	f12080e7          	jalr	-238(ra) # 80002e48 <clockintr>
    80002f3e:	b7ed                	j	80002f28 <devintr+0x8c>
}
    80002f40:	8082                	ret

0000000080002f42 <usertrap>:
{
    80002f42:	7139                	addi	sp,sp,-64
    80002f44:	fc06                	sd	ra,56(sp)
    80002f46:	f822                	sd	s0,48(sp)
    80002f48:	f426                	sd	s1,40(sp)
    80002f4a:	f04a                	sd	s2,32(sp)
    80002f4c:	ec4e                	sd	s3,24(sp)
    80002f4e:	e852                	sd	s4,16(sp)
    80002f50:	e456                	sd	s5,8(sp)
    80002f52:	0080                	addi	s0,sp,64
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f54:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002f58:	1007f793          	andi	a5,a5,256
    80002f5c:	e7bd                	bnez	a5,80002fca <usertrap+0x88>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002f5e:	00003797          	auipc	a5,0x3
    80002f62:	70278793          	addi	a5,a5,1794 # 80006660 <kernelvec>
    80002f66:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002f6a:	fffff097          	auipc	ra,0xfffff
    80002f6e:	c60080e7          	jalr	-928(ra) # 80001bca <myproc>
    80002f72:	892a                	mv	s2,a0
  p->trapframe->epc = r_sepc();
    80002f74:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f76:	14102773          	csrr	a4,sepc
    80002f7a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f7c:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002f80:	47a1                	li	a5,8
    80002f82:	04f70c63          	beq	a4,a5,80002fda <usertrap+0x98>
    80002f86:	14202773          	csrr	a4,scause
  else if (r_scause() == 15) // 0xf is a pagefault trap (like writing to read only PTEs)
    80002f8a:	47bd                	li	a5,15
    80002f8c:	08f70263          	beq	a4,a5,80003010 <usertrap+0xce>
  else if ((which_dev = devintr()) != 0)
    80002f90:	00000097          	auipc	ra,0x0
    80002f94:	f0c080e7          	jalr	-244(ra) # 80002e9c <devintr>
    80002f98:	18050263          	beqz	a0,8000311c <usertrap+0x1da>
    if (which_dev == 2) {
    80002f9c:	4789                	li	a5,2
    80002f9e:	08f50763          	beq	a0,a5,8000302c <usertrap+0xea>
  if (killed(p))
    80002fa2:	854a                	mv	a0,s2
    80002fa4:	00000097          	auipc	ra,0x0
    80002fa8:	97a080e7          	jalr	-1670(ra) # 8000291e <killed>
    80002fac:	1a051663          	bnez	a0,80003158 <usertrap+0x216>
  usertrapret();
    80002fb0:	00000097          	auipc	ra,0x0
    80002fb4:	e02080e7          	jalr	-510(ra) # 80002db2 <usertrapret>
}
    80002fb8:	70e2                	ld	ra,56(sp)
    80002fba:	7442                	ld	s0,48(sp)
    80002fbc:	74a2                	ld	s1,40(sp)
    80002fbe:	7902                	ld	s2,32(sp)
    80002fc0:	69e2                	ld	s3,24(sp)
    80002fc2:	6a42                	ld	s4,16(sp)
    80002fc4:	6aa2                	ld	s5,8(sp)
    80002fc6:	6121                	addi	sp,sp,64
    80002fc8:	8082                	ret
    panic("usertrap: not from user mode");
    80002fca:	00005517          	auipc	a0,0x5
    80002fce:	36650513          	addi	a0,a0,870 # 80008330 <states.0+0x58>
    80002fd2:	ffffd097          	auipc	ra,0xffffd
    80002fd6:	56a080e7          	jalr	1386(ra) # 8000053c <panic>
    if (killed(p))
    80002fda:	00000097          	auipc	ra,0x0
    80002fde:	944080e7          	jalr	-1724(ra) # 8000291e <killed>
    80002fe2:	e10d                	bnez	a0,80003004 <usertrap+0xc2>
    p->trapframe->epc += 4;
    80002fe4:	05893703          	ld	a4,88(s2)
    80002fe8:	6f1c                	ld	a5,24(a4)
    80002fea:	0791                	addi	a5,a5,4
    80002fec:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002fee:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ff2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ff6:	10079073          	csrw	sstatus,a5
    syscall();
    80002ffa:	00000097          	auipc	ra,0x0
    80002ffe:	38a080e7          	jalr	906(ra) # 80003384 <syscall>
    80003002:	b745                	j	80002fa2 <usertrap+0x60>
      exit(-1);
    80003004:	557d                	li	a0,-1
    80003006:	fffff097          	auipc	ra,0xfffff
    8000300a:	798080e7          	jalr	1944(ra) # 8000279e <exit>
    8000300e:	bfd9                	j	80002fe4 <usertrap+0xa2>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003010:	143025f3          	csrr	a1,stval
    if (handleCOW(p->pagetable, va)) {
    80003014:	6928                	ld	a0,80(a0)
    80003016:	00000097          	auipc	ra,0x0
    8000301a:	c76080e7          	jalr	-906(ra) # 80002c8c <handleCOW>
    8000301e:	d151                	beqz	a0,80002fa2 <usertrap+0x60>
      setkilled(p);
    80003020:	854a                	mv	a0,s2
    80003022:	00000097          	auipc	ra,0x0
    80003026:	8d0080e7          	jalr	-1840(ra) # 800028f2 <setkilled>
    8000302a:	bfa5                	j	80002fa2 <usertrap+0x60>
      for(fp = proc; fp < &proc[NPROC]; fp++) {
    8000302c:	0002f497          	auipc	s1,0x2f
    80003030:	c0448493          	addi	s1,s1,-1020 # 80031c30 <proc>
        if (fp->state == RUNNING) fp->pbs_rtime +=1;
    80003034:	4a11                	li	s4,4
        else if(fp->state == SLEEPING) fp->stime +=1;
    80003036:	4a89                	li	s5,2
      for(fp = proc; fp < &proc[NPROC]; fp++) {
    80003038:	00042997          	auipc	s3,0x42
    8000303c:	3f898993          	addi	s3,s3,1016 # 80045430 <tickslock>
    80003040:	a839                	j	8000305e <usertrap+0x11c>
        if (fp->state == RUNNING) fp->pbs_rtime +=1;
    80003042:	1904a783          	lw	a5,400(s1)
    80003046:	2785                	addiw	a5,a5,1
    80003048:	18f4a823          	sw	a5,400(s1)
        release(&fp->lock);
    8000304c:	8526                	mv	a0,s1
    8000304e:	ffffe097          	auipc	ra,0xffffe
    80003052:	dd2080e7          	jalr	-558(ra) # 80000e20 <release>
      for(fp = proc; fp < &proc[NPROC]; fp++) {
    80003056:	4e048493          	addi	s1,s1,1248
    8000305a:	03348263          	beq	s1,s3,8000307e <usertrap+0x13c>
        acquire(&fp->lock);
    8000305e:	8526                	mv	a0,s1
    80003060:	ffffe097          	auipc	ra,0xffffe
    80003064:	d0c080e7          	jalr	-756(ra) # 80000d6c <acquire>
        if (fp->state == RUNNING) fp->pbs_rtime +=1;
    80003068:	4c9c                	lw	a5,24(s1)
    8000306a:	fd478ce3          	beq	a5,s4,80003042 <usertrap+0x100>
        else if(fp->state == SLEEPING) fp->stime +=1;
    8000306e:	fd579fe3          	bne	a5,s5,8000304c <usertrap+0x10a>
    80003072:	1984a783          	lw	a5,408(s1)
    80003076:	2785                	addiw	a5,a5,1
    80003078:	18f4ac23          	sw	a5,408(s1)
    8000307c:	bfc1                	j	8000304c <usertrap+0x10a>
    if (which_dev == 2 && p->alarmOn == 0)
    8000307e:	17c92783          	lw	a5,380(s2)
    80003082:	ef81                	bnez	a5,8000309a <usertrap+0x158>
      p->nticks += 1;
    80003084:	17892783          	lw	a5,376(s2)
    80003088:	2785                	addiw	a5,a5,1
    8000308a:	0007871b          	sext.w	a4,a5
    8000308e:	16f92c23          	sw	a5,376(s2)
      if (p->nticks == p->interval)
    80003092:	16c92783          	lw	a5,364(s2)
    80003096:	02e78163          	beq	a5,a4,800030b8 <usertrap+0x176>
      if (p->state == RUNNING)
    8000309a:	01892703          	lw	a4,24(s2)
    8000309e:	4791                	li	a5,4
    800030a0:	04f70363          	beq	a4,a5,800030e6 <usertrap+0x1a4>
      for(i = 0; i < NPR; i++) {
    800030a4:	0002e617          	auipc	a2,0x2e
    800030a8:	38c60613          	addi	a2,a2,908 # 80031430 <queue+0x200>
    800030ac:	0002f517          	auipc	a0,0x2f
    800030b0:	d8450513          	addi	a0,a0,-636 # 80031e30 <proc+0x200>
          if (fp && fp->state == RUNNABLE) {
    800030b4:	458d                	li	a1,3
    800030b6:	a085                	j	80003116 <usertrap+0x1d4>
        struct trapframe *context = kalloc();
    800030b8:	ffffe097          	auipc	ra,0xffffe
    800030bc:	b74080e7          	jalr	-1164(ra) # 80000c2c <kalloc>
    800030c0:	84aa                	mv	s1,a0
        memmove(context, p->trapframe, PGSIZE);
    800030c2:	6605                	lui	a2,0x1
    800030c4:	05893583          	ld	a1,88(s2)
    800030c8:	ffffe097          	auipc	ra,0xffffe
    800030cc:	dfc080e7          	jalr	-516(ra) # 80000ec4 <memmove>
        p->alarmContext = context;
    800030d0:	18993023          	sd	s1,384(s2)
        p->alarmOn = 1; // done to prevent reentrance (test 2)
    800030d4:	4785                	li	a5,1
    800030d6:	16f92e23          	sw	a5,380(s2)
        p->trapframe->epc = p->handler;
    800030da:	05893783          	ld	a5,88(s2)
    800030de:	17093703          	ld	a4,368(s2)
    800030e2:	ef98                	sd	a4,24(a5)
    800030e4:	bf5d                	j	8000309a <usertrap+0x158>
        p->rticks++;
    800030e6:	1b092783          	lw	a5,432(s2)
    800030ea:	2785                	addiw	a5,a5,1
    800030ec:	1af92823          	sw	a5,432(s2)
    800030f0:	bf55                	j	800030a4 <usertrap+0x162>
        for(j = 0; j < NPROC; j++) {
    800030f2:	07a1                	addi	a5,a5,8
    800030f4:	00c78d63          	beq	a5,a2,8000310e <usertrap+0x1cc>
          struct proc *fp = queue[i][j];
    800030f8:	6398                	ld	a4,0(a5)
          if (fp && fp->state == RUNNABLE) {
    800030fa:	df65                	beqz	a4,800030f2 <usertrap+0x1b0>
    800030fc:	4f14                	lw	a3,24(a4)
    800030fe:	feb69ae3          	bne	a3,a1,800030f2 <usertrap+0x1b0>
            fp->wticks++;
    80003102:	1b472683          	lw	a3,436(a4)
    80003106:	2685                	addiw	a3,a3,1
    80003108:	1ad72a23          	sw	a3,436(a4)
    8000310c:	b7dd                	j	800030f2 <usertrap+0x1b0>
      for(i = 0; i < NPR; i++) {
    8000310e:	20060613          	addi	a2,a2,512 # 1200 <_entry-0x7fffee00>
    80003112:	e8a608e3          	beq	a2,a0,80002fa2 <usertrap+0x60>
        for(j = 0; j < NPROC; j++) {
    80003116:	e0060793          	addi	a5,a2,-512
    8000311a:	bff9                	j	800030f8 <usertrap+0x1b6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000311c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80003120:	03092603          	lw	a2,48(s2)
    80003124:	00005517          	auipc	a0,0x5
    80003128:	22c50513          	addi	a0,a0,556 # 80008350 <states.0+0x78>
    8000312c:	ffffd097          	auipc	ra,0xffffd
    80003130:	45a080e7          	jalr	1114(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003134:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003138:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000313c:	00005517          	auipc	a0,0x5
    80003140:	24450513          	addi	a0,a0,580 # 80008380 <states.0+0xa8>
    80003144:	ffffd097          	auipc	ra,0xffffd
    80003148:	442080e7          	jalr	1090(ra) # 80000586 <printf>
    setkilled(p);
    8000314c:	854a                	mv	a0,s2
    8000314e:	fffff097          	auipc	ra,0xfffff
    80003152:	7a4080e7          	jalr	1956(ra) # 800028f2 <setkilled>
    80003156:	b5b1                	j	80002fa2 <usertrap+0x60>
    exit(-1);
    80003158:	557d                	li	a0,-1
    8000315a:	fffff097          	auipc	ra,0xfffff
    8000315e:	644080e7          	jalr	1604(ra) # 8000279e <exit>
    80003162:	b5b9                	j	80002fb0 <usertrap+0x6e>

0000000080003164 <kerneltrap>:
{
    80003164:	7179                	addi	sp,sp,-48
    80003166:	f406                	sd	ra,40(sp)
    80003168:	f022                	sd	s0,32(sp)
    8000316a:	ec26                	sd	s1,24(sp)
    8000316c:	e84a                	sd	s2,16(sp)
    8000316e:	e44e                	sd	s3,8(sp)
    80003170:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003172:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003176:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000317a:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    8000317e:	1004f793          	andi	a5,s1,256
    80003182:	c78d                	beqz	a5,800031ac <kerneltrap+0x48>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003184:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003188:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    8000318a:	eb8d                	bnez	a5,800031bc <kerneltrap+0x58>
  if ((which_dev = devintr()) == 0)
    8000318c:	00000097          	auipc	ra,0x0
    80003190:	d10080e7          	jalr	-752(ra) # 80002e9c <devintr>
    80003194:	cd05                	beqz	a0,800031cc <kerneltrap+0x68>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003196:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000319a:	10049073          	csrw	sstatus,s1
}
    8000319e:	70a2                	ld	ra,40(sp)
    800031a0:	7402                	ld	s0,32(sp)
    800031a2:	64e2                	ld	s1,24(sp)
    800031a4:	6942                	ld	s2,16(sp)
    800031a6:	69a2                	ld	s3,8(sp)
    800031a8:	6145                	addi	sp,sp,48
    800031aa:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800031ac:	00005517          	auipc	a0,0x5
    800031b0:	1f450513          	addi	a0,a0,500 # 800083a0 <states.0+0xc8>
    800031b4:	ffffd097          	auipc	ra,0xffffd
    800031b8:	388080e7          	jalr	904(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    800031bc:	00005517          	auipc	a0,0x5
    800031c0:	20c50513          	addi	a0,a0,524 # 800083c8 <states.0+0xf0>
    800031c4:	ffffd097          	auipc	ra,0xffffd
    800031c8:	378080e7          	jalr	888(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    800031cc:	85ce                	mv	a1,s3
    800031ce:	00005517          	auipc	a0,0x5
    800031d2:	21a50513          	addi	a0,a0,538 # 800083e8 <states.0+0x110>
    800031d6:	ffffd097          	auipc	ra,0xffffd
    800031da:	3b0080e7          	jalr	944(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800031de:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800031e2:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800031e6:	00005517          	auipc	a0,0x5
    800031ea:	21250513          	addi	a0,a0,530 # 800083f8 <states.0+0x120>
    800031ee:	ffffd097          	auipc	ra,0xffffd
    800031f2:	398080e7          	jalr	920(ra) # 80000586 <printf>
    panic("kerneltrap");
    800031f6:	00005517          	auipc	a0,0x5
    800031fa:	21a50513          	addi	a0,a0,538 # 80008410 <states.0+0x138>
    800031fe:	ffffd097          	auipc	ra,0xffffd
    80003202:	33e080e7          	jalr	830(ra) # 8000053c <panic>

0000000080003206 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003206:	1101                	addi	sp,sp,-32
    80003208:	ec06                	sd	ra,24(sp)
    8000320a:	e822                	sd	s0,16(sp)
    8000320c:	e426                	sd	s1,8(sp)
    8000320e:	1000                	addi	s0,sp,32
    80003210:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80003212:	fffff097          	auipc	ra,0xfffff
    80003216:	9b8080e7          	jalr	-1608(ra) # 80001bca <myproc>
  switch (n) {
    8000321a:	4795                	li	a5,5
    8000321c:	0497e163          	bltu	a5,s1,8000325e <argraw+0x58>
    80003220:	048a                	slli	s1,s1,0x2
    80003222:	00005717          	auipc	a4,0x5
    80003226:	34e70713          	addi	a4,a4,846 # 80008570 <states.0+0x298>
    8000322a:	94ba                	add	s1,s1,a4
    8000322c:	409c                	lw	a5,0(s1)
    8000322e:	97ba                	add	a5,a5,a4
    80003230:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80003232:	6d3c                	ld	a5,88(a0)
    80003234:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003236:	60e2                	ld	ra,24(sp)
    80003238:	6442                	ld	s0,16(sp)
    8000323a:	64a2                	ld	s1,8(sp)
    8000323c:	6105                	addi	sp,sp,32
    8000323e:	8082                	ret
    return p->trapframe->a1;
    80003240:	6d3c                	ld	a5,88(a0)
    80003242:	7fa8                	ld	a0,120(a5)
    80003244:	bfcd                	j	80003236 <argraw+0x30>
    return p->trapframe->a2;
    80003246:	6d3c                	ld	a5,88(a0)
    80003248:	63c8                	ld	a0,128(a5)
    8000324a:	b7f5                	j	80003236 <argraw+0x30>
    return p->trapframe->a3;
    8000324c:	6d3c                	ld	a5,88(a0)
    8000324e:	67c8                	ld	a0,136(a5)
    80003250:	b7dd                	j	80003236 <argraw+0x30>
    return p->trapframe->a4;
    80003252:	6d3c                	ld	a5,88(a0)
    80003254:	6bc8                	ld	a0,144(a5)
    80003256:	b7c5                	j	80003236 <argraw+0x30>
    return p->trapframe->a5;
    80003258:	6d3c                	ld	a5,88(a0)
    8000325a:	6fc8                	ld	a0,152(a5)
    8000325c:	bfe9                	j	80003236 <argraw+0x30>
  panic("argraw");
    8000325e:	00005517          	auipc	a0,0x5
    80003262:	1c250513          	addi	a0,a0,450 # 80008420 <states.0+0x148>
    80003266:	ffffd097          	auipc	ra,0xffffd
    8000326a:	2d6080e7          	jalr	726(ra) # 8000053c <panic>

000000008000326e <fetchaddr>:
{
    8000326e:	1101                	addi	sp,sp,-32
    80003270:	ec06                	sd	ra,24(sp)
    80003272:	e822                	sd	s0,16(sp)
    80003274:	e426                	sd	s1,8(sp)
    80003276:	e04a                	sd	s2,0(sp)
    80003278:	1000                	addi	s0,sp,32
    8000327a:	84aa                	mv	s1,a0
    8000327c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000327e:	fffff097          	auipc	ra,0xfffff
    80003282:	94c080e7          	jalr	-1716(ra) # 80001bca <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80003286:	653c                	ld	a5,72(a0)
    80003288:	02f4f863          	bgeu	s1,a5,800032b8 <fetchaddr+0x4a>
    8000328c:	00848713          	addi	a4,s1,8
    80003290:	02e7e663          	bltu	a5,a4,800032bc <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003294:	46a1                	li	a3,8
    80003296:	8626                	mv	a2,s1
    80003298:	85ca                	mv	a1,s2
    8000329a:	6928                	ld	a0,80(a0)
    8000329c:	ffffe097          	auipc	ra,0xffffe
    800032a0:	600080e7          	jalr	1536(ra) # 8000189c <copyin>
    800032a4:	00a03533          	snez	a0,a0
    800032a8:	40a00533          	neg	a0,a0
}
    800032ac:	60e2                	ld	ra,24(sp)
    800032ae:	6442                	ld	s0,16(sp)
    800032b0:	64a2                	ld	s1,8(sp)
    800032b2:	6902                	ld	s2,0(sp)
    800032b4:	6105                	addi	sp,sp,32
    800032b6:	8082                	ret
    return -1;
    800032b8:	557d                	li	a0,-1
    800032ba:	bfcd                	j	800032ac <fetchaddr+0x3e>
    800032bc:	557d                	li	a0,-1
    800032be:	b7fd                	j	800032ac <fetchaddr+0x3e>

00000000800032c0 <fetchstr>:
{
    800032c0:	7179                	addi	sp,sp,-48
    800032c2:	f406                	sd	ra,40(sp)
    800032c4:	f022                	sd	s0,32(sp)
    800032c6:	ec26                	sd	s1,24(sp)
    800032c8:	e84a                	sd	s2,16(sp)
    800032ca:	e44e                	sd	s3,8(sp)
    800032cc:	1800                	addi	s0,sp,48
    800032ce:	892a                	mv	s2,a0
    800032d0:	84ae                	mv	s1,a1
    800032d2:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800032d4:	fffff097          	auipc	ra,0xfffff
    800032d8:	8f6080e7          	jalr	-1802(ra) # 80001bca <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800032dc:	86ce                	mv	a3,s3
    800032de:	864a                	mv	a2,s2
    800032e0:	85a6                	mv	a1,s1
    800032e2:	6928                	ld	a0,80(a0)
    800032e4:	ffffe097          	auipc	ra,0xffffe
    800032e8:	646080e7          	jalr	1606(ra) # 8000192a <copyinstr>
    800032ec:	00054e63          	bltz	a0,80003308 <fetchstr+0x48>
  return strlen(buf);
    800032f0:	8526                	mv	a0,s1
    800032f2:	ffffe097          	auipc	ra,0xffffe
    800032f6:	cf0080e7          	jalr	-784(ra) # 80000fe2 <strlen>
}
    800032fa:	70a2                	ld	ra,40(sp)
    800032fc:	7402                	ld	s0,32(sp)
    800032fe:	64e2                	ld	s1,24(sp)
    80003300:	6942                	ld	s2,16(sp)
    80003302:	69a2                	ld	s3,8(sp)
    80003304:	6145                	addi	sp,sp,48
    80003306:	8082                	ret
    return -1;
    80003308:	557d                	li	a0,-1
    8000330a:	bfc5                	j	800032fa <fetchstr+0x3a>

000000008000330c <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    8000330c:	1101                	addi	sp,sp,-32
    8000330e:	ec06                	sd	ra,24(sp)
    80003310:	e822                	sd	s0,16(sp)
    80003312:	e426                	sd	s1,8(sp)
    80003314:	1000                	addi	s0,sp,32
    80003316:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003318:	00000097          	auipc	ra,0x0
    8000331c:	eee080e7          	jalr	-274(ra) # 80003206 <argraw>
    80003320:	c088                	sw	a0,0(s1)
}
    80003322:	60e2                	ld	ra,24(sp)
    80003324:	6442                	ld	s0,16(sp)
    80003326:	64a2                	ld	s1,8(sp)
    80003328:	6105                	addi	sp,sp,32
    8000332a:	8082                	ret

000000008000332c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    8000332c:	1101                	addi	sp,sp,-32
    8000332e:	ec06                	sd	ra,24(sp)
    80003330:	e822                	sd	s0,16(sp)
    80003332:	e426                	sd	s1,8(sp)
    80003334:	1000                	addi	s0,sp,32
    80003336:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003338:	00000097          	auipc	ra,0x0
    8000333c:	ece080e7          	jalr	-306(ra) # 80003206 <argraw>
    80003340:	e088                	sd	a0,0(s1)
}
    80003342:	60e2                	ld	ra,24(sp)
    80003344:	6442                	ld	s0,16(sp)
    80003346:	64a2                	ld	s1,8(sp)
    80003348:	6105                	addi	sp,sp,32
    8000334a:	8082                	ret

000000008000334c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000334c:	7179                	addi	sp,sp,-48
    8000334e:	f406                	sd	ra,40(sp)
    80003350:	f022                	sd	s0,32(sp)
    80003352:	ec26                	sd	s1,24(sp)
    80003354:	e84a                	sd	s2,16(sp)
    80003356:	1800                	addi	s0,sp,48
    80003358:	84ae                	mv	s1,a1
    8000335a:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    8000335c:	fd840593          	addi	a1,s0,-40
    80003360:	00000097          	auipc	ra,0x0
    80003364:	fcc080e7          	jalr	-52(ra) # 8000332c <argaddr>
  return fetchstr(addr, buf, max);
    80003368:	864a                	mv	a2,s2
    8000336a:	85a6                	mv	a1,s1
    8000336c:	fd843503          	ld	a0,-40(s0)
    80003370:	00000097          	auipc	ra,0x0
    80003374:	f50080e7          	jalr	-176(ra) # 800032c0 <fetchstr>
}
    80003378:	70a2                	ld	ra,40(sp)
    8000337a:	7402                	ld	s0,32(sp)
    8000337c:	64e2                	ld	s1,24(sp)
    8000337e:	6942                	ld	s2,16(sp)
    80003380:	6145                	addi	sp,sp,48
    80003382:	8082                	ret

0000000080003384 <syscall>:
  [SYS_waitx] 3,
};

void
syscall(void)
{
    80003384:	7159                	addi	sp,sp,-112
    80003386:	f486                	sd	ra,104(sp)
    80003388:	f0a2                	sd	s0,96(sp)
    8000338a:	eca6                	sd	s1,88(sp)
    8000338c:	e8ca                	sd	s2,80(sp)
    8000338e:	e4ce                	sd	s3,72(sp)
    80003390:	e0d2                	sd	s4,64(sp)
    80003392:	fc56                	sd	s5,56(sp)
    80003394:	f85a                	sd	s6,48(sp)
    80003396:	f45e                	sd	s7,40(sp)
    80003398:	1880                	addi	s0,sp,112
  int num;
  struct proc *p = myproc();
    8000339a:	fffff097          	auipc	ra,0xfffff
    8000339e:	830080e7          	jalr	-2000(ra) # 80001bca <myproc>
    800033a2:	89aa                	mv	s3,a0

  num = p->trapframe->a7;
    800033a4:	6d24                	ld	s1,88(a0)
    800033a6:	74dc                	ld	a5,168(s1)
    800033a8:	00078b1b          	sext.w	s6,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800033ac:	37fd                	addiw	a5,a5,-1
    800033ae:	4769                	li	a4,26
    800033b0:	0cf76363          	bltu	a4,a5,80003476 <syscall+0xf2>
    800033b4:	003b1713          	slli	a4,s6,0x3
    800033b8:	00005797          	auipc	a5,0x5
    800033bc:	1d078793          	addi	a5,a5,464 # 80008588 <syscalls>
    800033c0:	97ba                	add	a5,a5,a4
    800033c2:	0007bb83          	ld	s7,0(a5)
    800033c6:	0a0b8863          	beqz	s7,80003476 <syscall+0xf2>
    // save arguments of syscall if it needs to be traced
    int nargs = syscall_nargs[num];
    800033ca:	002b1713          	slli	a4,s6,0x2
    800033ce:	00005797          	auipc	a5,0x5
    800033d2:	1ba78793          	addi	a5,a5,442 # 80008588 <syscalls>
    800033d6:	97ba                	add	a5,a5,a4
    800033d8:	0e07aa03          	lw	s4,224(a5)
    int args[6];
    for (int i = 0; i < nargs; i++) {
    800033dc:	0d405963          	blez	s4,800034ae <syscall+0x12a>
    800033e0:	f9840a93          	addi	s5,s0,-104
    800033e4:	8956                	mv	s2,s5
    800033e6:	4481                	li	s1,0
      argint(i, &args[i]);
    800033e8:	85ca                	mv	a1,s2
    800033ea:	8526                	mv	a0,s1
    800033ec:	00000097          	auipc	ra,0x0
    800033f0:	f20080e7          	jalr	-224(ra) # 8000330c <argint>
    for (int i = 0; i < nargs; i++) {
    800033f4:	2485                	addiw	s1,s1,1
    800033f6:	0911                	addi	s2,s2,4
    800033f8:	fe9a18e3          	bne	s4,s1,800033e8 <syscall+0x64>
    }

    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800033fc:	0589b483          	ld	s1,88(s3)
    80003400:	9b82                	jalr	s7
    80003402:	f8a8                	sd	a0,112(s1)

    // if trace was called
    // Specification 1        
    int trace_call = p->smask & (1 << num);
    80003404:	4705                	li	a4,1
    80003406:	0167173b          	sllw	a4,a4,s6
    8000340a:	1689a783          	lw	a5,360(s3)
    8000340e:	8ff9                	and	a5,a5,a4
    if (trace_call) { 
    80003410:	2781                	sext.w	a5,a5
    80003412:	c3d9                	beqz	a5,80003498 <syscall+0x114>
      printf("%d: syscall %s (", p->pid, syscall_names[num]);
    80003414:	0b0e                	slli	s6,s6,0x3
    80003416:	00005797          	auipc	a5,0x5
    8000341a:	17278793          	addi	a5,a5,370 # 80008588 <syscalls>
    8000341e:	97da                	add	a5,a5,s6
    80003420:	1507b603          	ld	a2,336(a5)
    80003424:	0309a583          	lw	a1,48(s3)
    80003428:	00005517          	auipc	a0,0x5
    8000342c:	00050513          	mv	a0,a0
    80003430:	ffffd097          	auipc	ra,0xffffd
    80003434:	156080e7          	jalr	342(ra) # 80000586 <printf>
      for (int i = 0; i < nargs; i++) { 
    80003438:	4481                	li	s1,0
        printf("%d", args[i]);
    8000343a:	00005b17          	auipc	s6,0x5
    8000343e:	006b0b13          	addi	s6,s6,6 # 80008440 <states.0+0x168>
        if (i != nargs - 1)
    80003442:	fffa091b          	addiw	s2,s4,-1
          printf(" ");
    80003446:	00005b97          	auipc	s7,0x5
    8000344a:	002b8b93          	addi	s7,s7,2 # 80008448 <states.0+0x170>
    8000344e:	a029                	j	80003458 <syscall+0xd4>
      for (int i = 0; i < nargs; i++) { 
    80003450:	2485                	addiw	s1,s1,1
    80003452:	0a91                	addi	s5,s5,4
    80003454:	089a0963          	beq	s4,s1,800034e6 <syscall+0x162>
        printf("%d", args[i]);
    80003458:	000aa583          	lw	a1,0(s5)
    8000345c:	855a                	mv	a0,s6
    8000345e:	ffffd097          	auipc	ra,0xffffd
    80003462:	128080e7          	jalr	296(ra) # 80000586 <printf>
        if (i != nargs - 1)
    80003466:	fe9905e3          	beq	s2,s1,80003450 <syscall+0xcc>
          printf(" ");
    8000346a:	855e                	mv	a0,s7
    8000346c:	ffffd097          	auipc	ra,0xffffd
    80003470:	11a080e7          	jalr	282(ra) # 80000586 <printf>
    80003474:	bff1                	j	80003450 <syscall+0xcc>
    // if traced, print return value
    if (trace_call) {
      printf("-> %d\n", p->trapframe->a0);
    }
  } else {         
    printf("%d %s: unknown sys call %d\n",
    80003476:	86da                	mv	a3,s6
    80003478:	15898613          	addi	a2,s3,344
    8000347c:	0309a583          	lw	a1,48(s3)
    80003480:	00005517          	auipc	a0,0x5
    80003484:	fe050513          	addi	a0,a0,-32 # 80008460 <states.0+0x188>
    80003488:	ffffd097          	auipc	ra,0xffffd
    8000348c:	0fe080e7          	jalr	254(ra) # 80000586 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003490:	0589b783          	ld	a5,88(s3)
    80003494:	577d                	li	a4,-1
    80003496:	fbb8                	sd	a4,112(a5)
  }
}
    80003498:	70a6                	ld	ra,104(sp)
    8000349a:	7406                	ld	s0,96(sp)
    8000349c:	64e6                	ld	s1,88(sp)
    8000349e:	6946                	ld	s2,80(sp)
    800034a0:	69a6                	ld	s3,72(sp)
    800034a2:	6a06                	ld	s4,64(sp)
    800034a4:	7ae2                	ld	s5,56(sp)
    800034a6:	7b42                	ld	s6,48(sp)
    800034a8:	7ba2                	ld	s7,40(sp)
    800034aa:	6165                	addi	sp,sp,112
    800034ac:	8082                	ret
    p->trapframe->a0 = syscalls[num]();
    800034ae:	9b82                	jalr	s7
    800034b0:	f8a8                	sd	a0,112(s1)
    int trace_call = p->smask & (1 << num);
    800034b2:	4705                	li	a4,1
    800034b4:	0167173b          	sllw	a4,a4,s6
    800034b8:	1689a783          	lw	a5,360(s3)
    800034bc:	8ff9                	and	a5,a5,a4
    if (trace_call) { 
    800034be:	2781                	sext.w	a5,a5
    800034c0:	dfe1                	beqz	a5,80003498 <syscall+0x114>
      printf("%d: syscall %s (", p->pid, syscall_names[num]);
    800034c2:	0b0e                	slli	s6,s6,0x3
    800034c4:	00005797          	auipc	a5,0x5
    800034c8:	0c478793          	addi	a5,a5,196 # 80008588 <syscalls>
    800034cc:	97da                	add	a5,a5,s6
    800034ce:	1507b603          	ld	a2,336(a5)
    800034d2:	0309a583          	lw	a1,48(s3)
    800034d6:	00005517          	auipc	a0,0x5
    800034da:	f5250513          	addi	a0,a0,-174 # 80008428 <states.0+0x150>
    800034de:	ffffd097          	auipc	ra,0xffffd
    800034e2:	0a8080e7          	jalr	168(ra) # 80000586 <printf>
      printf(") ");
    800034e6:	00005517          	auipc	a0,0x5
    800034ea:	f6a50513          	addi	a0,a0,-150 # 80008450 <states.0+0x178>
    800034ee:	ffffd097          	auipc	ra,0xffffd
    800034f2:	098080e7          	jalr	152(ra) # 80000586 <printf>
      printf("-> %d\n", p->trapframe->a0);
    800034f6:	0589b783          	ld	a5,88(s3)
    800034fa:	7bac                	ld	a1,112(a5)
    800034fc:	00005517          	auipc	a0,0x5
    80003500:	f5c50513          	addi	a0,a0,-164 # 80008458 <states.0+0x180>
    80003504:	ffffd097          	auipc	ra,0xffffd
    80003508:	082080e7          	jalr	130(ra) # 80000586 <printf>
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000350c:	b771                	j	80003498 <syscall+0x114>

000000008000350e <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    8000350e:	1101                	addi	sp,sp,-32
    80003510:	ec06                	sd	ra,24(sp)
    80003512:	e822                	sd	s0,16(sp)
    80003514:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003516:	fec40593          	addi	a1,s0,-20
    8000351a:	4501                	li	a0,0
    8000351c:	00000097          	auipc	ra,0x0
    80003520:	df0080e7          	jalr	-528(ra) # 8000330c <argint>
  exit(n);
    80003524:	fec42503          	lw	a0,-20(s0)
    80003528:	fffff097          	auipc	ra,0xfffff
    8000352c:	276080e7          	jalr	630(ra) # 8000279e <exit>
  return 0; // not reached
}
    80003530:	4501                	li	a0,0
    80003532:	60e2                	ld	ra,24(sp)
    80003534:	6442                	ld	s0,16(sp)
    80003536:	6105                	addi	sp,sp,32
    80003538:	8082                	ret

000000008000353a <sys_getpid>:

uint64
sys_getpid(void)
{
    8000353a:	1141                	addi	sp,sp,-16
    8000353c:	e406                	sd	ra,8(sp)
    8000353e:	e022                	sd	s0,0(sp)
    80003540:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003542:	ffffe097          	auipc	ra,0xffffe
    80003546:	688080e7          	jalr	1672(ra) # 80001bca <myproc>
}
    8000354a:	5908                	lw	a0,48(a0)
    8000354c:	60a2                	ld	ra,8(sp)
    8000354e:	6402                	ld	s0,0(sp)
    80003550:	0141                	addi	sp,sp,16
    80003552:	8082                	ret

0000000080003554 <sys_fork>:

uint64
sys_fork(void)
{
    80003554:	1141                	addi	sp,sp,-16
    80003556:	e406                	sd	ra,8(sp)
    80003558:	e022                	sd	s0,0(sp)
    8000355a:	0800                	addi	s0,sp,16
  return fork();
    8000355c:	fffff097          	auipc	ra,0xfffff
    80003560:	a92080e7          	jalr	-1390(ra) # 80001fee <fork>
}
    80003564:	60a2                	ld	ra,8(sp)
    80003566:	6402                	ld	s0,0(sp)
    80003568:	0141                	addi	sp,sp,16
    8000356a:	8082                	ret

000000008000356c <sys_wait>:

uint64
sys_wait(void)
{
    8000356c:	1101                	addi	sp,sp,-32
    8000356e:	ec06                	sd	ra,24(sp)
    80003570:	e822                	sd	s0,16(sp)
    80003572:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003574:	fe840593          	addi	a1,s0,-24
    80003578:	4501                	li	a0,0
    8000357a:	00000097          	auipc	ra,0x0
    8000357e:	db2080e7          	jalr	-590(ra) # 8000332c <argaddr>
  return wait(p);
    80003582:	fe843503          	ld	a0,-24(s0)
    80003586:	fffff097          	auipc	ra,0xfffff
    8000358a:	3ca080e7          	jalr	970(ra) # 80002950 <wait>
}
    8000358e:	60e2                	ld	ra,24(sp)
    80003590:	6442                	ld	s0,16(sp)
    80003592:	6105                	addi	sp,sp,32
    80003594:	8082                	ret

0000000080003596 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003596:	7179                	addi	sp,sp,-48
    80003598:	f406                	sd	ra,40(sp)
    8000359a:	f022                	sd	s0,32(sp)
    8000359c:	ec26                	sd	s1,24(sp)
    8000359e:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800035a0:	fdc40593          	addi	a1,s0,-36
    800035a4:	4501                	li	a0,0
    800035a6:	00000097          	auipc	ra,0x0
    800035aa:	d66080e7          	jalr	-666(ra) # 8000330c <argint>
  addr = myproc()->sz;
    800035ae:	ffffe097          	auipc	ra,0xffffe
    800035b2:	61c080e7          	jalr	1564(ra) # 80001bca <myproc>
    800035b6:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    800035b8:	fdc42503          	lw	a0,-36(s0)
    800035bc:	fffff097          	auipc	ra,0xfffff
    800035c0:	9d6080e7          	jalr	-1578(ra) # 80001f92 <growproc>
    800035c4:	00054863          	bltz	a0,800035d4 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    800035c8:	8526                	mv	a0,s1
    800035ca:	70a2                	ld	ra,40(sp)
    800035cc:	7402                	ld	s0,32(sp)
    800035ce:	64e2                	ld	s1,24(sp)
    800035d0:	6145                	addi	sp,sp,48
    800035d2:	8082                	ret
    return -1;
    800035d4:	54fd                	li	s1,-1
    800035d6:	bfcd                	j	800035c8 <sys_sbrk+0x32>

00000000800035d8 <sys_sleep>:

uint64
sys_sleep(void)
{
    800035d8:	7139                	addi	sp,sp,-64
    800035da:	fc06                	sd	ra,56(sp)
    800035dc:	f822                	sd	s0,48(sp)
    800035de:	f426                	sd	s1,40(sp)
    800035e0:	f04a                	sd	s2,32(sp)
    800035e2:	ec4e                	sd	s3,24(sp)
    800035e4:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800035e6:	fcc40593          	addi	a1,s0,-52
    800035ea:	4501                	li	a0,0
    800035ec:	00000097          	auipc	ra,0x0
    800035f0:	d20080e7          	jalr	-736(ra) # 8000330c <argint>
  acquire(&tickslock);
    800035f4:	00042517          	auipc	a0,0x42
    800035f8:	e3c50513          	addi	a0,a0,-452 # 80045430 <tickslock>
    800035fc:	ffffd097          	auipc	ra,0xffffd
    80003600:	770080e7          	jalr	1904(ra) # 80000d6c <acquire>
  ticks0 = ticks;
    80003604:	00005917          	auipc	s2,0x5
    80003608:	56c92903          	lw	s2,1388(s2) # 80008b70 <ticks>
  while (ticks - ticks0 < n)
    8000360c:	fcc42783          	lw	a5,-52(s0)
    80003610:	cf9d                	beqz	a5,8000364e <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003612:	00042997          	auipc	s3,0x42
    80003616:	e1e98993          	addi	s3,s3,-482 # 80045430 <tickslock>
    8000361a:	00005497          	auipc	s1,0x5
    8000361e:	55648493          	addi	s1,s1,1366 # 80008b70 <ticks>
    if (killed(myproc()))
    80003622:	ffffe097          	auipc	ra,0xffffe
    80003626:	5a8080e7          	jalr	1448(ra) # 80001bca <myproc>
    8000362a:	fffff097          	auipc	ra,0xfffff
    8000362e:	2f4080e7          	jalr	756(ra) # 8000291e <killed>
    80003632:	ed15                	bnez	a0,8000366e <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003634:	85ce                	mv	a1,s3
    80003636:	8526                	mv	a0,s1
    80003638:	fffff097          	auipc	ra,0xfffff
    8000363c:	ed2080e7          	jalr	-302(ra) # 8000250a <sleep>
  while (ticks - ticks0 < n)
    80003640:	409c                	lw	a5,0(s1)
    80003642:	412787bb          	subw	a5,a5,s2
    80003646:	fcc42703          	lw	a4,-52(s0)
    8000364a:	fce7ece3          	bltu	a5,a4,80003622 <sys_sleep+0x4a>
  }
  release(&tickslock);
    8000364e:	00042517          	auipc	a0,0x42
    80003652:	de250513          	addi	a0,a0,-542 # 80045430 <tickslock>
    80003656:	ffffd097          	auipc	ra,0xffffd
    8000365a:	7ca080e7          	jalr	1994(ra) # 80000e20 <release>
  return 0;
    8000365e:	4501                	li	a0,0
}
    80003660:	70e2                	ld	ra,56(sp)
    80003662:	7442                	ld	s0,48(sp)
    80003664:	74a2                	ld	s1,40(sp)
    80003666:	7902                	ld	s2,32(sp)
    80003668:	69e2                	ld	s3,24(sp)
    8000366a:	6121                	addi	sp,sp,64
    8000366c:	8082                	ret
      release(&tickslock);
    8000366e:	00042517          	auipc	a0,0x42
    80003672:	dc250513          	addi	a0,a0,-574 # 80045430 <tickslock>
    80003676:	ffffd097          	auipc	ra,0xffffd
    8000367a:	7aa080e7          	jalr	1962(ra) # 80000e20 <release>
      return -1;
    8000367e:	557d                	li	a0,-1
    80003680:	b7c5                	j	80003660 <sys_sleep+0x88>

0000000080003682 <sys_kill>:

uint64
sys_kill(void)
{
    80003682:	1101                	addi	sp,sp,-32
    80003684:	ec06                	sd	ra,24(sp)
    80003686:	e822                	sd	s0,16(sp)
    80003688:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    8000368a:	fec40593          	addi	a1,s0,-20
    8000368e:	4501                	li	a0,0
    80003690:	00000097          	auipc	ra,0x0
    80003694:	c7c080e7          	jalr	-900(ra) # 8000330c <argint>
  return kill(pid);
    80003698:	fec42503          	lw	a0,-20(s0)
    8000369c:	fffff097          	auipc	ra,0xfffff
    800036a0:	1e4080e7          	jalr	484(ra) # 80002880 <kill>
}
    800036a4:	60e2                	ld	ra,24(sp)
    800036a6:	6442                	ld	s0,16(sp)
    800036a8:	6105                	addi	sp,sp,32
    800036aa:	8082                	ret

00000000800036ac <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800036ac:	1101                	addi	sp,sp,-32
    800036ae:	ec06                	sd	ra,24(sp)
    800036b0:	e822                	sd	s0,16(sp)
    800036b2:	e426                	sd	s1,8(sp)
    800036b4:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800036b6:	00042517          	auipc	a0,0x42
    800036ba:	d7a50513          	addi	a0,a0,-646 # 80045430 <tickslock>
    800036be:	ffffd097          	auipc	ra,0xffffd
    800036c2:	6ae080e7          	jalr	1710(ra) # 80000d6c <acquire>
  xticks = ticks;
    800036c6:	00005497          	auipc	s1,0x5
    800036ca:	4aa4a483          	lw	s1,1194(s1) # 80008b70 <ticks>
  release(&tickslock);
    800036ce:	00042517          	auipc	a0,0x42
    800036d2:	d6250513          	addi	a0,a0,-670 # 80045430 <tickslock>
    800036d6:	ffffd097          	auipc	ra,0xffffd
    800036da:	74a080e7          	jalr	1866(ra) # 80000e20 <release>
  return xticks;
}
    800036de:	02049513          	slli	a0,s1,0x20
    800036e2:	9101                	srli	a0,a0,0x20
    800036e4:	60e2                	ld	ra,24(sp)
    800036e6:	6442                	ld	s0,16(sp)
    800036e8:	64a2                	ld	s1,8(sp)
    800036ea:	6105                	addi	sp,sp,32
    800036ec:	8082                	ret

00000000800036ee <sys_trace>:

// Specification 1

uint64
sys_trace(void)
{
    800036ee:	1101                	addi	sp,sp,-32
    800036f0:	ec06                	sd	ra,24(sp)
    800036f2:	e822                	sd	s0,16(sp)
    800036f4:	1000                	addi	s0,sp,32
  int mask;
  struct proc *p;

  argint(0, &mask);
    800036f6:	fec40593          	addi	a1,s0,-20
    800036fa:	4501                	li	a0,0
    800036fc:	00000097          	auipc	ra,0x0
    80003700:	c10080e7          	jalr	-1008(ra) # 8000330c <argint>
  p = myproc();
    80003704:	ffffe097          	auipc	ra,0xffffe
    80003708:	4c6080e7          	jalr	1222(ra) # 80001bca <myproc>

  p->smask = mask;
    8000370c:	fec42783          	lw	a5,-20(s0)
    80003710:	16f52423          	sw	a5,360(a0)
  return 0;
}
    80003714:	4501                	li	a0,0
    80003716:	60e2                	ld	ra,24(sp)
    80003718:	6442                	ld	s0,16(sp)
    8000371a:	6105                	addi	sp,sp,32
    8000371c:	8082                	ret

000000008000371e <sys_sigalarm>:

uint64 sys_sigalarm(void)
{
    8000371e:	7179                	addi	sp,sp,-48
    80003720:	f406                	sd	ra,40(sp)
    80003722:	f022                	sd	s0,32(sp)
    80003724:	ec26                	sd	s1,24(sp)
    80003726:	1800                	addi	s0,sp,48
  struct proc *p;
  p = myproc();
    80003728:	ffffe097          	auipc	ra,0xffffe
    8000372c:	4a2080e7          	jalr	1186(ra) # 80001bca <myproc>
    80003730:	84aa                	mv	s1,a0

  int interval;
  uint64 handler;

  argint(0, &interval);
    80003732:	fdc40593          	addi	a1,s0,-36
    80003736:	4501                	li	a0,0
    80003738:	00000097          	auipc	ra,0x0
    8000373c:	bd4080e7          	jalr	-1068(ra) # 8000330c <argint>
  argaddr(1, &handler);
    80003740:	fd040593          	addi	a1,s0,-48
    80003744:	4505                	li	a0,1
    80003746:	00000097          	auipc	ra,0x0
    8000374a:	be6080e7          	jalr	-1050(ra) # 8000332c <argaddr>

  p->interval = interval;
    8000374e:	fdc42783          	lw	a5,-36(s0)
    80003752:	16f4a623          	sw	a5,364(s1)
  p->handler = handler;
    80003756:	fd043783          	ld	a5,-48(s0)
    8000375a:	16f4b823          	sd	a5,368(s1)

  return 0;
}
    8000375e:	4501                	li	a0,0
    80003760:	70a2                	ld	ra,40(sp)
    80003762:	7402                	ld	s0,32(sp)
    80003764:	64e2                	ld	s1,24(sp)
    80003766:	6145                	addi	sp,sp,48
    80003768:	8082                	ret

000000008000376a <sys_sigreturn>:

uint64 sys_sigreturn(void)
{
    8000376a:	1101                	addi	sp,sp,-32
    8000376c:	ec06                	sd	ra,24(sp)
    8000376e:	e822                	sd	s0,16(sp)
    80003770:	e426                	sd	s1,8(sp)
    80003772:	e04a                	sd	s2,0(sp)
    80003774:	1000                	addi	s0,sp,32
  struct proc *p;
  p = myproc();
    80003776:	ffffe097          	auipc	ra,0xffffe
    8000377a:	454080e7          	jalr	1108(ra) # 80001bca <myproc>
    8000377e:	84aa                	mv	s1,a0

  memmove(p->trapframe, p->alarmContext, PGSIZE);
    80003780:	6605                	lui	a2,0x1
    80003782:	18053583          	ld	a1,384(a0)
    80003786:	6d28                	ld	a0,88(a0)
    80003788:	ffffd097          	auipc	ra,0xffffd
    8000378c:	73c080e7          	jalr	1852(ra) # 80000ec4 <memmove>
  int a0 = p->alarmContext->a0;
    80003790:	1804b503          	ld	a0,384(s1)
    80003794:	07052903          	lw	s2,112(a0)
  kfree(p->alarmContext);
    80003798:	ffffd097          	auipc	ra,0xffffd
    8000379c:	2fe080e7          	jalr	766(ra) # 80000a96 <kfree>
  p->alarmOn = 0;
    800037a0:	1604ae23          	sw	zero,380(s1)
  p->nticks = 0;
    800037a4:	1604ac23          	sw	zero,376(s1)
  p->alarmContext = 0;
    800037a8:	1804b023          	sd	zero,384(s1)
  // this is done to restore the original value of the a0 register
  // as sys_sigreturn is also a systemcall its return value will be stored in the a0 register
  return a0;
}
    800037ac:	854a                	mv	a0,s2
    800037ae:	60e2                	ld	ra,24(sp)
    800037b0:	6442                	ld	s0,16(sp)
    800037b2:	64a2                	ld	s1,8(sp)
    800037b4:	6902                	ld	s2,0(sp)
    800037b6:	6105                	addi	sp,sp,32
    800037b8:	8082                	ret

00000000800037ba <sys_settickets>:

uint64 sys_settickets(void) {
    800037ba:	1101                	addi	sp,sp,-32
    800037bc:	ec06                	sd	ra,24(sp)
    800037be:	e822                	sd	s0,16(sp)
    800037c0:	1000                	addi	s0,sp,32
  struct proc *p;
  int tk;

  argint(0, &tk);
    800037c2:	fec40593          	addi	a1,s0,-20
    800037c6:	4501                	li	a0,0
    800037c8:	00000097          	auipc	ra,0x0
    800037cc:	b44080e7          	jalr	-1212(ra) # 8000330c <argint>
  p = myproc();
    800037d0:	ffffe097          	auipc	ra,0xffffe
    800037d4:	3fa080e7          	jalr	1018(ra) # 80001bca <myproc>

  p->tickets += tk;
    800037d8:	18c52703          	lw	a4,396(a0)
    800037dc:	fec42783          	lw	a5,-20(s0)
    800037e0:	9fb9                	addw	a5,a5,a4
    800037e2:	18f52623          	sw	a5,396(a0)
  return 0;
}
    800037e6:	4501                	li	a0,0
    800037e8:	60e2                	ld	ra,24(sp)
    800037ea:	6442                	ld	s0,16(sp)
    800037ec:	6105                	addi	sp,sp,32
    800037ee:	8082                	ret

00000000800037f0 <sys_set_priority>:

uint64 sys_set_priority(void){
    800037f0:	7179                	addi	sp,sp,-48
    800037f2:	f406                	sd	ra,40(sp)
    800037f4:	f022                	sd	s0,32(sp)
    800037f6:	ec26                	sd	s1,24(sp)
    800037f8:	e84a                	sd	s2,16(sp)
    800037fa:	1800                	addi	s0,sp,48
  struct proc *p;
  int sp,pid;

  argint(0,&sp);
    800037fc:	fdc40593          	addi	a1,s0,-36
    80003800:	4501                	li	a0,0
    80003802:	00000097          	auipc	ra,0x0
    80003806:	b0a080e7          	jalr	-1270(ra) # 8000330c <argint>
  argint(1,&pid);
    8000380a:	fd840593          	addi	a1,s0,-40
    8000380e:	4505                	li	a0,1
    80003810:	00000097          	auipc	ra,0x0
    80003814:	afc080e7          	jalr	-1284(ra) # 8000330c <argint>

  for(p=proc;p<&proc[NPROC];p++){
    80003818:	0002e497          	auipc	s1,0x2e
    8000381c:	41848493          	addi	s1,s1,1048 # 80031c30 <proc>
    80003820:	00042917          	auipc	s2,0x42
    80003824:	c1090913          	addi	s2,s2,-1008 # 80045430 <tickslock>
    acquire(&p->lock);
    80003828:	8526                	mv	a0,s1
    8000382a:	ffffd097          	auipc	ra,0xffffd
    8000382e:	542080e7          	jalr	1346(ra) # 80000d6c <acquire>
    if(p->pid==pid){
    80003832:	5898                	lw	a4,48(s1)
    80003834:	fd842783          	lw	a5,-40(s0)
    80003838:	00f70d63          	beq	a4,a5,80003852 <sys_set_priority+0x62>
      if(old_sp > sp){
        yield();
      }
      return old_sp;
    }
    release(&p->lock);
    8000383c:	8526                	mv	a0,s1
    8000383e:	ffffd097          	auipc	ra,0xffffd
    80003842:	5e2080e7          	jalr	1506(ra) # 80000e20 <release>
  for(p=proc;p<&proc[NPROC];p++){
    80003846:	4e048493          	addi	s1,s1,1248
    8000384a:	fd249fe3          	bne	s1,s2,80003828 <sys_set_priority+0x38>
  }
  return -1;
    8000384e:	557d                	li	a0,-1
    80003850:	a815                	j	80003884 <sys_set_priority+0x94>
      int old_sp = p->staticP;
    80003852:	19c4a903          	lw	s2,412(s1)
      p->staticP = sp;
    80003856:	fdc42783          	lw	a5,-36(s0)
    8000385a:	18f4ae23          	sw	a5,412(s1)
      p->niceness = 5;
    8000385e:	4795                	li	a5,5
    80003860:	1af4a023          	sw	a5,416(s1)
      p->pbs_rtime =0;
    80003864:	1804a823          	sw	zero,400(s1)
      p->stime =0;
    80003868:	1804ac23          	sw	zero,408(s1)
      p->wtime =0;
    8000386c:	1a04a223          	sw	zero,420(s1)
      release(&p->lock);
    80003870:	8526                	mv	a0,s1
    80003872:	ffffd097          	auipc	ra,0xffffd
    80003876:	5ae080e7          	jalr	1454(ra) # 80000e20 <release>
      if(old_sp > sp){
    8000387a:	fdc42783          	lw	a5,-36(s0)
    8000387e:	0127c963          	blt	a5,s2,80003890 <sys_set_priority+0xa0>
      return old_sp;
    80003882:	854a                	mv	a0,s2
}
    80003884:	70a2                	ld	ra,40(sp)
    80003886:	7402                	ld	s0,32(sp)
    80003888:	64e2                	ld	s1,24(sp)
    8000388a:	6942                	ld	s2,16(sp)
    8000388c:	6145                	addi	sp,sp,48
    8000388e:	8082                	ret
        yield();
    80003890:	fffff097          	auipc	ra,0xfffff
    80003894:	c3e080e7          	jalr	-962(ra) # 800024ce <yield>
    80003898:	b7ed                	j	80003882 <sys_set_priority+0x92>

000000008000389a <sys_waitx>:

uint64
sys_waitx(void)
{
    8000389a:	7139                	addi	sp,sp,-64
    8000389c:	fc06                	sd	ra,56(sp)
    8000389e:	f822                	sd	s0,48(sp)
    800038a0:	f426                	sd	s1,40(sp)
    800038a2:	f04a                	sd	s2,32(sp)
    800038a4:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    800038a6:	fd840593          	addi	a1,s0,-40
    800038aa:	4501                	li	a0,0
    800038ac:	00000097          	auipc	ra,0x0
    800038b0:	a80080e7          	jalr	-1408(ra) # 8000332c <argaddr>
  argaddr(1, &addr1); // user virtual memory
    800038b4:	fd040593          	addi	a1,s0,-48
    800038b8:	4505                	li	a0,1
    800038ba:	00000097          	auipc	ra,0x0
    800038be:	a72080e7          	jalr	-1422(ra) # 8000332c <argaddr>
  argaddr(2, &addr2);
    800038c2:	fc840593          	addi	a1,s0,-56
    800038c6:	4509                	li	a0,2
    800038c8:	00000097          	auipc	ra,0x0
    800038cc:	a64080e7          	jalr	-1436(ra) # 8000332c <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    800038d0:	fc040613          	addi	a2,s0,-64
    800038d4:	fc440593          	addi	a1,s0,-60
    800038d8:	fd843503          	ld	a0,-40(s0)
    800038dc:	fffff097          	auipc	ra,0xfffff
    800038e0:	c92080e7          	jalr	-878(ra) # 8000256e <waitx>
    800038e4:	892a                	mv	s2,a0
  struct proc* p = myproc();
    800038e6:	ffffe097          	auipc	ra,0xffffe
    800038ea:	2e4080e7          	jalr	740(ra) # 80001bca <myproc>
    800038ee:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    800038f0:	4691                	li	a3,4
    800038f2:	fc440613          	addi	a2,s0,-60
    800038f6:	fd043583          	ld	a1,-48(s0)
    800038fa:	6928                	ld	a0,80(a0)
    800038fc:	ffffe097          	auipc	ra,0xffffe
    80003900:	f14080e7          	jalr	-236(ra) # 80001810 <copyout>
    return -1;
    80003904:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    80003906:	00054f63          	bltz	a0,80003924 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2,(char*)&rtime, sizeof(int)) < 0)
    8000390a:	4691                	li	a3,4
    8000390c:	fc040613          	addi	a2,s0,-64
    80003910:	fc843583          	ld	a1,-56(s0)
    80003914:	68a8                	ld	a0,80(s1)
    80003916:	ffffe097          	auipc	ra,0xffffe
    8000391a:	efa080e7          	jalr	-262(ra) # 80001810 <copyout>
    8000391e:	00054a63          	bltz	a0,80003932 <sys_waitx+0x98>
    return -1;
  return ret;
    80003922:	87ca                	mv	a5,s2
    80003924:	853e                	mv	a0,a5
    80003926:	70e2                	ld	ra,56(sp)
    80003928:	7442                	ld	s0,48(sp)
    8000392a:	74a2                	ld	s1,40(sp)
    8000392c:	7902                	ld	s2,32(sp)
    8000392e:	6121                	addi	sp,sp,64
    80003930:	8082                	ret
    return -1;
    80003932:	57fd                	li	a5,-1
    80003934:	bfc5                	j	80003924 <sys_waitx+0x8a>

0000000080003936 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003936:	7179                	addi	sp,sp,-48
    80003938:	f406                	sd	ra,40(sp)
    8000393a:	f022                	sd	s0,32(sp)
    8000393c:	ec26                	sd	s1,24(sp)
    8000393e:	e84a                	sd	s2,16(sp)
    80003940:	e44e                	sd	s3,8(sp)
    80003942:	e052                	sd	s4,0(sp)
    80003944:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003946:	00005597          	auipc	a1,0x5
    8000394a:	e7258593          	addi	a1,a1,-398 # 800087b8 <syscall_names+0xe0>
    8000394e:	00042517          	auipc	a0,0x42
    80003952:	afa50513          	addi	a0,a0,-1286 # 80045448 <bcache>
    80003956:	ffffd097          	auipc	ra,0xffffd
    8000395a:	386080e7          	jalr	902(ra) # 80000cdc <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000395e:	0004a797          	auipc	a5,0x4a
    80003962:	aea78793          	addi	a5,a5,-1302 # 8004d448 <bcache+0x8000>
    80003966:	0004a717          	auipc	a4,0x4a
    8000396a:	d4a70713          	addi	a4,a4,-694 # 8004d6b0 <bcache+0x8268>
    8000396e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003972:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003976:	00042497          	auipc	s1,0x42
    8000397a:	aea48493          	addi	s1,s1,-1302 # 80045460 <bcache+0x18>
    b->next = bcache.head.next;
    8000397e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003980:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003982:	00005a17          	auipc	s4,0x5
    80003986:	e3ea0a13          	addi	s4,s4,-450 # 800087c0 <syscall_names+0xe8>
    b->next = bcache.head.next;
    8000398a:	2b893783          	ld	a5,696(s2)
    8000398e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003990:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003994:	85d2                	mv	a1,s4
    80003996:	01048513          	addi	a0,s1,16
    8000399a:	00001097          	auipc	ra,0x1
    8000399e:	496080e7          	jalr	1174(ra) # 80004e30 <initsleeplock>
    bcache.head.next->prev = b;
    800039a2:	2b893783          	ld	a5,696(s2)
    800039a6:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800039a8:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800039ac:	45848493          	addi	s1,s1,1112
    800039b0:	fd349de3          	bne	s1,s3,8000398a <binit+0x54>
  }
}
    800039b4:	70a2                	ld	ra,40(sp)
    800039b6:	7402                	ld	s0,32(sp)
    800039b8:	64e2                	ld	s1,24(sp)
    800039ba:	6942                	ld	s2,16(sp)
    800039bc:	69a2                	ld	s3,8(sp)
    800039be:	6a02                	ld	s4,0(sp)
    800039c0:	6145                	addi	sp,sp,48
    800039c2:	8082                	ret

00000000800039c4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800039c4:	7179                	addi	sp,sp,-48
    800039c6:	f406                	sd	ra,40(sp)
    800039c8:	f022                	sd	s0,32(sp)
    800039ca:	ec26                	sd	s1,24(sp)
    800039cc:	e84a                	sd	s2,16(sp)
    800039ce:	e44e                	sd	s3,8(sp)
    800039d0:	1800                	addi	s0,sp,48
    800039d2:	892a                	mv	s2,a0
    800039d4:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800039d6:	00042517          	auipc	a0,0x42
    800039da:	a7250513          	addi	a0,a0,-1422 # 80045448 <bcache>
    800039de:	ffffd097          	auipc	ra,0xffffd
    800039e2:	38e080e7          	jalr	910(ra) # 80000d6c <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800039e6:	0004a497          	auipc	s1,0x4a
    800039ea:	d1a4b483          	ld	s1,-742(s1) # 8004d700 <bcache+0x82b8>
    800039ee:	0004a797          	auipc	a5,0x4a
    800039f2:	cc278793          	addi	a5,a5,-830 # 8004d6b0 <bcache+0x8268>
    800039f6:	02f48f63          	beq	s1,a5,80003a34 <bread+0x70>
    800039fa:	873e                	mv	a4,a5
    800039fc:	a021                	j	80003a04 <bread+0x40>
    800039fe:	68a4                	ld	s1,80(s1)
    80003a00:	02e48a63          	beq	s1,a4,80003a34 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003a04:	449c                	lw	a5,8(s1)
    80003a06:	ff279ce3          	bne	a5,s2,800039fe <bread+0x3a>
    80003a0a:	44dc                	lw	a5,12(s1)
    80003a0c:	ff3799e3          	bne	a5,s3,800039fe <bread+0x3a>
      b->refcnt++;
    80003a10:	40bc                	lw	a5,64(s1)
    80003a12:	2785                	addiw	a5,a5,1
    80003a14:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003a16:	00042517          	auipc	a0,0x42
    80003a1a:	a3250513          	addi	a0,a0,-1486 # 80045448 <bcache>
    80003a1e:	ffffd097          	auipc	ra,0xffffd
    80003a22:	402080e7          	jalr	1026(ra) # 80000e20 <release>
      acquiresleep(&b->lock);
    80003a26:	01048513          	addi	a0,s1,16
    80003a2a:	00001097          	auipc	ra,0x1
    80003a2e:	440080e7          	jalr	1088(ra) # 80004e6a <acquiresleep>
      return b;
    80003a32:	a8b9                	j	80003a90 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003a34:	0004a497          	auipc	s1,0x4a
    80003a38:	cc44b483          	ld	s1,-828(s1) # 8004d6f8 <bcache+0x82b0>
    80003a3c:	0004a797          	auipc	a5,0x4a
    80003a40:	c7478793          	addi	a5,a5,-908 # 8004d6b0 <bcache+0x8268>
    80003a44:	00f48863          	beq	s1,a5,80003a54 <bread+0x90>
    80003a48:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003a4a:	40bc                	lw	a5,64(s1)
    80003a4c:	cf81                	beqz	a5,80003a64 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003a4e:	64a4                	ld	s1,72(s1)
    80003a50:	fee49de3          	bne	s1,a4,80003a4a <bread+0x86>
  panic("bget: no buffers");
    80003a54:	00005517          	auipc	a0,0x5
    80003a58:	d7450513          	addi	a0,a0,-652 # 800087c8 <syscall_names+0xf0>
    80003a5c:	ffffd097          	auipc	ra,0xffffd
    80003a60:	ae0080e7          	jalr	-1312(ra) # 8000053c <panic>
      b->dev = dev;
    80003a64:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003a68:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003a6c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003a70:	4785                	li	a5,1
    80003a72:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003a74:	00042517          	auipc	a0,0x42
    80003a78:	9d450513          	addi	a0,a0,-1580 # 80045448 <bcache>
    80003a7c:	ffffd097          	auipc	ra,0xffffd
    80003a80:	3a4080e7          	jalr	932(ra) # 80000e20 <release>
      acquiresleep(&b->lock);
    80003a84:	01048513          	addi	a0,s1,16
    80003a88:	00001097          	auipc	ra,0x1
    80003a8c:	3e2080e7          	jalr	994(ra) # 80004e6a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003a90:	409c                	lw	a5,0(s1)
    80003a92:	cb89                	beqz	a5,80003aa4 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003a94:	8526                	mv	a0,s1
    80003a96:	70a2                	ld	ra,40(sp)
    80003a98:	7402                	ld	s0,32(sp)
    80003a9a:	64e2                	ld	s1,24(sp)
    80003a9c:	6942                	ld	s2,16(sp)
    80003a9e:	69a2                	ld	s3,8(sp)
    80003aa0:	6145                	addi	sp,sp,48
    80003aa2:	8082                	ret
    virtio_disk_rw(b, 0);
    80003aa4:	4581                	li	a1,0
    80003aa6:	8526                	mv	a0,s1
    80003aa8:	00003097          	auipc	ra,0x3
    80003aac:	f7a080e7          	jalr	-134(ra) # 80006a22 <virtio_disk_rw>
    b->valid = 1;
    80003ab0:	4785                	li	a5,1
    80003ab2:	c09c                	sw	a5,0(s1)
  return b;
    80003ab4:	b7c5                	j	80003a94 <bread+0xd0>

0000000080003ab6 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003ab6:	1101                	addi	sp,sp,-32
    80003ab8:	ec06                	sd	ra,24(sp)
    80003aba:	e822                	sd	s0,16(sp)
    80003abc:	e426                	sd	s1,8(sp)
    80003abe:	1000                	addi	s0,sp,32
    80003ac0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003ac2:	0541                	addi	a0,a0,16
    80003ac4:	00001097          	auipc	ra,0x1
    80003ac8:	440080e7          	jalr	1088(ra) # 80004f04 <holdingsleep>
    80003acc:	cd01                	beqz	a0,80003ae4 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003ace:	4585                	li	a1,1
    80003ad0:	8526                	mv	a0,s1
    80003ad2:	00003097          	auipc	ra,0x3
    80003ad6:	f50080e7          	jalr	-176(ra) # 80006a22 <virtio_disk_rw>
}
    80003ada:	60e2                	ld	ra,24(sp)
    80003adc:	6442                	ld	s0,16(sp)
    80003ade:	64a2                	ld	s1,8(sp)
    80003ae0:	6105                	addi	sp,sp,32
    80003ae2:	8082                	ret
    panic("bwrite");
    80003ae4:	00005517          	auipc	a0,0x5
    80003ae8:	cfc50513          	addi	a0,a0,-772 # 800087e0 <syscall_names+0x108>
    80003aec:	ffffd097          	auipc	ra,0xffffd
    80003af0:	a50080e7          	jalr	-1456(ra) # 8000053c <panic>

0000000080003af4 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003af4:	1101                	addi	sp,sp,-32
    80003af6:	ec06                	sd	ra,24(sp)
    80003af8:	e822                	sd	s0,16(sp)
    80003afa:	e426                	sd	s1,8(sp)
    80003afc:	e04a                	sd	s2,0(sp)
    80003afe:	1000                	addi	s0,sp,32
    80003b00:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003b02:	01050913          	addi	s2,a0,16
    80003b06:	854a                	mv	a0,s2
    80003b08:	00001097          	auipc	ra,0x1
    80003b0c:	3fc080e7          	jalr	1020(ra) # 80004f04 <holdingsleep>
    80003b10:	c925                	beqz	a0,80003b80 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    80003b12:	854a                	mv	a0,s2
    80003b14:	00001097          	auipc	ra,0x1
    80003b18:	3ac080e7          	jalr	940(ra) # 80004ec0 <releasesleep>

  acquire(&bcache.lock);
    80003b1c:	00042517          	auipc	a0,0x42
    80003b20:	92c50513          	addi	a0,a0,-1748 # 80045448 <bcache>
    80003b24:	ffffd097          	auipc	ra,0xffffd
    80003b28:	248080e7          	jalr	584(ra) # 80000d6c <acquire>
  b->refcnt--;
    80003b2c:	40bc                	lw	a5,64(s1)
    80003b2e:	37fd                	addiw	a5,a5,-1
    80003b30:	0007871b          	sext.w	a4,a5
    80003b34:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003b36:	e71d                	bnez	a4,80003b64 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003b38:	68b8                	ld	a4,80(s1)
    80003b3a:	64bc                	ld	a5,72(s1)
    80003b3c:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003b3e:	68b8                	ld	a4,80(s1)
    80003b40:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003b42:	0004a797          	auipc	a5,0x4a
    80003b46:	90678793          	addi	a5,a5,-1786 # 8004d448 <bcache+0x8000>
    80003b4a:	2b87b703          	ld	a4,696(a5)
    80003b4e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003b50:	0004a717          	auipc	a4,0x4a
    80003b54:	b6070713          	addi	a4,a4,-1184 # 8004d6b0 <bcache+0x8268>
    80003b58:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003b5a:	2b87b703          	ld	a4,696(a5)
    80003b5e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003b60:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003b64:	00042517          	auipc	a0,0x42
    80003b68:	8e450513          	addi	a0,a0,-1820 # 80045448 <bcache>
    80003b6c:	ffffd097          	auipc	ra,0xffffd
    80003b70:	2b4080e7          	jalr	692(ra) # 80000e20 <release>
}
    80003b74:	60e2                	ld	ra,24(sp)
    80003b76:	6442                	ld	s0,16(sp)
    80003b78:	64a2                	ld	s1,8(sp)
    80003b7a:	6902                	ld	s2,0(sp)
    80003b7c:	6105                	addi	sp,sp,32
    80003b7e:	8082                	ret
    panic("brelse");
    80003b80:	00005517          	auipc	a0,0x5
    80003b84:	c6850513          	addi	a0,a0,-920 # 800087e8 <syscall_names+0x110>
    80003b88:	ffffd097          	auipc	ra,0xffffd
    80003b8c:	9b4080e7          	jalr	-1612(ra) # 8000053c <panic>

0000000080003b90 <bpin>:

void
bpin(struct buf *b) {
    80003b90:	1101                	addi	sp,sp,-32
    80003b92:	ec06                	sd	ra,24(sp)
    80003b94:	e822                	sd	s0,16(sp)
    80003b96:	e426                	sd	s1,8(sp)
    80003b98:	1000                	addi	s0,sp,32
    80003b9a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003b9c:	00042517          	auipc	a0,0x42
    80003ba0:	8ac50513          	addi	a0,a0,-1876 # 80045448 <bcache>
    80003ba4:	ffffd097          	auipc	ra,0xffffd
    80003ba8:	1c8080e7          	jalr	456(ra) # 80000d6c <acquire>
  b->refcnt++;
    80003bac:	40bc                	lw	a5,64(s1)
    80003bae:	2785                	addiw	a5,a5,1
    80003bb0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003bb2:	00042517          	auipc	a0,0x42
    80003bb6:	89650513          	addi	a0,a0,-1898 # 80045448 <bcache>
    80003bba:	ffffd097          	auipc	ra,0xffffd
    80003bbe:	266080e7          	jalr	614(ra) # 80000e20 <release>
}
    80003bc2:	60e2                	ld	ra,24(sp)
    80003bc4:	6442                	ld	s0,16(sp)
    80003bc6:	64a2                	ld	s1,8(sp)
    80003bc8:	6105                	addi	sp,sp,32
    80003bca:	8082                	ret

0000000080003bcc <bunpin>:

void
bunpin(struct buf *b) {
    80003bcc:	1101                	addi	sp,sp,-32
    80003bce:	ec06                	sd	ra,24(sp)
    80003bd0:	e822                	sd	s0,16(sp)
    80003bd2:	e426                	sd	s1,8(sp)
    80003bd4:	1000                	addi	s0,sp,32
    80003bd6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003bd8:	00042517          	auipc	a0,0x42
    80003bdc:	87050513          	addi	a0,a0,-1936 # 80045448 <bcache>
    80003be0:	ffffd097          	auipc	ra,0xffffd
    80003be4:	18c080e7          	jalr	396(ra) # 80000d6c <acquire>
  b->refcnt--;
    80003be8:	40bc                	lw	a5,64(s1)
    80003bea:	37fd                	addiw	a5,a5,-1
    80003bec:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003bee:	00042517          	auipc	a0,0x42
    80003bf2:	85a50513          	addi	a0,a0,-1958 # 80045448 <bcache>
    80003bf6:	ffffd097          	auipc	ra,0xffffd
    80003bfa:	22a080e7          	jalr	554(ra) # 80000e20 <release>
}
    80003bfe:	60e2                	ld	ra,24(sp)
    80003c00:	6442                	ld	s0,16(sp)
    80003c02:	64a2                	ld	s1,8(sp)
    80003c04:	6105                	addi	sp,sp,32
    80003c06:	8082                	ret

0000000080003c08 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003c08:	1101                	addi	sp,sp,-32
    80003c0a:	ec06                	sd	ra,24(sp)
    80003c0c:	e822                	sd	s0,16(sp)
    80003c0e:	e426                	sd	s1,8(sp)
    80003c10:	e04a                	sd	s2,0(sp)
    80003c12:	1000                	addi	s0,sp,32
    80003c14:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003c16:	00d5d59b          	srliw	a1,a1,0xd
    80003c1a:	0004a797          	auipc	a5,0x4a
    80003c1e:	f0a7a783          	lw	a5,-246(a5) # 8004db24 <sb+0x1c>
    80003c22:	9dbd                	addw	a1,a1,a5
    80003c24:	00000097          	auipc	ra,0x0
    80003c28:	da0080e7          	jalr	-608(ra) # 800039c4 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003c2c:	0074f713          	andi	a4,s1,7
    80003c30:	4785                	li	a5,1
    80003c32:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003c36:	14ce                	slli	s1,s1,0x33
    80003c38:	90d9                	srli	s1,s1,0x36
    80003c3a:	00950733          	add	a4,a0,s1
    80003c3e:	05874703          	lbu	a4,88(a4)
    80003c42:	00e7f6b3          	and	a3,a5,a4
    80003c46:	c69d                	beqz	a3,80003c74 <bfree+0x6c>
    80003c48:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003c4a:	94aa                	add	s1,s1,a0
    80003c4c:	fff7c793          	not	a5,a5
    80003c50:	8f7d                	and	a4,a4,a5
    80003c52:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003c56:	00001097          	auipc	ra,0x1
    80003c5a:	0f6080e7          	jalr	246(ra) # 80004d4c <log_write>
  brelse(bp);
    80003c5e:	854a                	mv	a0,s2
    80003c60:	00000097          	auipc	ra,0x0
    80003c64:	e94080e7          	jalr	-364(ra) # 80003af4 <brelse>
}
    80003c68:	60e2                	ld	ra,24(sp)
    80003c6a:	6442                	ld	s0,16(sp)
    80003c6c:	64a2                	ld	s1,8(sp)
    80003c6e:	6902                	ld	s2,0(sp)
    80003c70:	6105                	addi	sp,sp,32
    80003c72:	8082                	ret
    panic("freeing free block");
    80003c74:	00005517          	auipc	a0,0x5
    80003c78:	b7c50513          	addi	a0,a0,-1156 # 800087f0 <syscall_names+0x118>
    80003c7c:	ffffd097          	auipc	ra,0xffffd
    80003c80:	8c0080e7          	jalr	-1856(ra) # 8000053c <panic>

0000000080003c84 <balloc>:
{
    80003c84:	711d                	addi	sp,sp,-96
    80003c86:	ec86                	sd	ra,88(sp)
    80003c88:	e8a2                	sd	s0,80(sp)
    80003c8a:	e4a6                	sd	s1,72(sp)
    80003c8c:	e0ca                	sd	s2,64(sp)
    80003c8e:	fc4e                	sd	s3,56(sp)
    80003c90:	f852                	sd	s4,48(sp)
    80003c92:	f456                	sd	s5,40(sp)
    80003c94:	f05a                	sd	s6,32(sp)
    80003c96:	ec5e                	sd	s7,24(sp)
    80003c98:	e862                	sd	s8,16(sp)
    80003c9a:	e466                	sd	s9,8(sp)
    80003c9c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003c9e:	0004a797          	auipc	a5,0x4a
    80003ca2:	e6e7a783          	lw	a5,-402(a5) # 8004db0c <sb+0x4>
    80003ca6:	cff5                	beqz	a5,80003da2 <balloc+0x11e>
    80003ca8:	8baa                	mv	s7,a0
    80003caa:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003cac:	0004ab17          	auipc	s6,0x4a
    80003cb0:	e5cb0b13          	addi	s6,s6,-420 # 8004db08 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003cb4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003cb6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003cb8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003cba:	6c89                	lui	s9,0x2
    80003cbc:	a061                	j	80003d44 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003cbe:	97ca                	add	a5,a5,s2
    80003cc0:	8e55                	or	a2,a2,a3
    80003cc2:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003cc6:	854a                	mv	a0,s2
    80003cc8:	00001097          	auipc	ra,0x1
    80003ccc:	084080e7          	jalr	132(ra) # 80004d4c <log_write>
        brelse(bp);
    80003cd0:	854a                	mv	a0,s2
    80003cd2:	00000097          	auipc	ra,0x0
    80003cd6:	e22080e7          	jalr	-478(ra) # 80003af4 <brelse>
  bp = bread(dev, bno);
    80003cda:	85a6                	mv	a1,s1
    80003cdc:	855e                	mv	a0,s7
    80003cde:	00000097          	auipc	ra,0x0
    80003ce2:	ce6080e7          	jalr	-794(ra) # 800039c4 <bread>
    80003ce6:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003ce8:	40000613          	li	a2,1024
    80003cec:	4581                	li	a1,0
    80003cee:	05850513          	addi	a0,a0,88
    80003cf2:	ffffd097          	auipc	ra,0xffffd
    80003cf6:	176080e7          	jalr	374(ra) # 80000e68 <memset>
  log_write(bp);
    80003cfa:	854a                	mv	a0,s2
    80003cfc:	00001097          	auipc	ra,0x1
    80003d00:	050080e7          	jalr	80(ra) # 80004d4c <log_write>
  brelse(bp);
    80003d04:	854a                	mv	a0,s2
    80003d06:	00000097          	auipc	ra,0x0
    80003d0a:	dee080e7          	jalr	-530(ra) # 80003af4 <brelse>
}
    80003d0e:	8526                	mv	a0,s1
    80003d10:	60e6                	ld	ra,88(sp)
    80003d12:	6446                	ld	s0,80(sp)
    80003d14:	64a6                	ld	s1,72(sp)
    80003d16:	6906                	ld	s2,64(sp)
    80003d18:	79e2                	ld	s3,56(sp)
    80003d1a:	7a42                	ld	s4,48(sp)
    80003d1c:	7aa2                	ld	s5,40(sp)
    80003d1e:	7b02                	ld	s6,32(sp)
    80003d20:	6be2                	ld	s7,24(sp)
    80003d22:	6c42                	ld	s8,16(sp)
    80003d24:	6ca2                	ld	s9,8(sp)
    80003d26:	6125                	addi	sp,sp,96
    80003d28:	8082                	ret
    brelse(bp);
    80003d2a:	854a                	mv	a0,s2
    80003d2c:	00000097          	auipc	ra,0x0
    80003d30:	dc8080e7          	jalr	-568(ra) # 80003af4 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003d34:	015c87bb          	addw	a5,s9,s5
    80003d38:	00078a9b          	sext.w	s5,a5
    80003d3c:	004b2703          	lw	a4,4(s6)
    80003d40:	06eaf163          	bgeu	s5,a4,80003da2 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003d44:	41fad79b          	sraiw	a5,s5,0x1f
    80003d48:	0137d79b          	srliw	a5,a5,0x13
    80003d4c:	015787bb          	addw	a5,a5,s5
    80003d50:	40d7d79b          	sraiw	a5,a5,0xd
    80003d54:	01cb2583          	lw	a1,28(s6)
    80003d58:	9dbd                	addw	a1,a1,a5
    80003d5a:	855e                	mv	a0,s7
    80003d5c:	00000097          	auipc	ra,0x0
    80003d60:	c68080e7          	jalr	-920(ra) # 800039c4 <bread>
    80003d64:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003d66:	004b2503          	lw	a0,4(s6)
    80003d6a:	000a849b          	sext.w	s1,s5
    80003d6e:	8762                	mv	a4,s8
    80003d70:	faa4fde3          	bgeu	s1,a0,80003d2a <balloc+0xa6>
      m = 1 << (bi % 8);
    80003d74:	00777693          	andi	a3,a4,7
    80003d78:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003d7c:	41f7579b          	sraiw	a5,a4,0x1f
    80003d80:	01d7d79b          	srliw	a5,a5,0x1d
    80003d84:	9fb9                	addw	a5,a5,a4
    80003d86:	4037d79b          	sraiw	a5,a5,0x3
    80003d8a:	00f90633          	add	a2,s2,a5
    80003d8e:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80003d92:	00c6f5b3          	and	a1,a3,a2
    80003d96:	d585                	beqz	a1,80003cbe <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003d98:	2705                	addiw	a4,a4,1
    80003d9a:	2485                	addiw	s1,s1,1
    80003d9c:	fd471ae3          	bne	a4,s4,80003d70 <balloc+0xec>
    80003da0:	b769                	j	80003d2a <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80003da2:	00005517          	auipc	a0,0x5
    80003da6:	a6650513          	addi	a0,a0,-1434 # 80008808 <syscall_names+0x130>
    80003daa:	ffffc097          	auipc	ra,0xffffc
    80003dae:	7dc080e7          	jalr	2012(ra) # 80000586 <printf>
  return 0;
    80003db2:	4481                	li	s1,0
    80003db4:	bfa9                	j	80003d0e <balloc+0x8a>

0000000080003db6 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003db6:	7179                	addi	sp,sp,-48
    80003db8:	f406                	sd	ra,40(sp)
    80003dba:	f022                	sd	s0,32(sp)
    80003dbc:	ec26                	sd	s1,24(sp)
    80003dbe:	e84a                	sd	s2,16(sp)
    80003dc0:	e44e                	sd	s3,8(sp)
    80003dc2:	e052                	sd	s4,0(sp)
    80003dc4:	1800                	addi	s0,sp,48
    80003dc6:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003dc8:	47ad                	li	a5,11
    80003dca:	02b7e863          	bltu	a5,a1,80003dfa <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003dce:	02059793          	slli	a5,a1,0x20
    80003dd2:	01e7d593          	srli	a1,a5,0x1e
    80003dd6:	00b504b3          	add	s1,a0,a1
    80003dda:	0504a903          	lw	s2,80(s1)
    80003dde:	06091e63          	bnez	s2,80003e5a <bmap+0xa4>
      addr = balloc(ip->dev);
    80003de2:	4108                	lw	a0,0(a0)
    80003de4:	00000097          	auipc	ra,0x0
    80003de8:	ea0080e7          	jalr	-352(ra) # 80003c84 <balloc>
    80003dec:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003df0:	06090563          	beqz	s2,80003e5a <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003df4:	0524a823          	sw	s2,80(s1)
    80003df8:	a08d                	j	80003e5a <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003dfa:	ff45849b          	addiw	s1,a1,-12
    80003dfe:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003e02:	0ff00793          	li	a5,255
    80003e06:	08e7e563          	bltu	a5,a4,80003e90 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003e0a:	08052903          	lw	s2,128(a0)
    80003e0e:	00091d63          	bnez	s2,80003e28 <bmap+0x72>
      addr = balloc(ip->dev);
    80003e12:	4108                	lw	a0,0(a0)
    80003e14:	00000097          	auipc	ra,0x0
    80003e18:	e70080e7          	jalr	-400(ra) # 80003c84 <balloc>
    80003e1c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003e20:	02090d63          	beqz	s2,80003e5a <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003e24:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003e28:	85ca                	mv	a1,s2
    80003e2a:	0009a503          	lw	a0,0(s3)
    80003e2e:	00000097          	auipc	ra,0x0
    80003e32:	b96080e7          	jalr	-1130(ra) # 800039c4 <bread>
    80003e36:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003e38:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003e3c:	02049713          	slli	a4,s1,0x20
    80003e40:	01e75593          	srli	a1,a4,0x1e
    80003e44:	00b784b3          	add	s1,a5,a1
    80003e48:	0004a903          	lw	s2,0(s1)
    80003e4c:	02090063          	beqz	s2,80003e6c <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003e50:	8552                	mv	a0,s4
    80003e52:	00000097          	auipc	ra,0x0
    80003e56:	ca2080e7          	jalr	-862(ra) # 80003af4 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003e5a:	854a                	mv	a0,s2
    80003e5c:	70a2                	ld	ra,40(sp)
    80003e5e:	7402                	ld	s0,32(sp)
    80003e60:	64e2                	ld	s1,24(sp)
    80003e62:	6942                	ld	s2,16(sp)
    80003e64:	69a2                	ld	s3,8(sp)
    80003e66:	6a02                	ld	s4,0(sp)
    80003e68:	6145                	addi	sp,sp,48
    80003e6a:	8082                	ret
      addr = balloc(ip->dev);
    80003e6c:	0009a503          	lw	a0,0(s3)
    80003e70:	00000097          	auipc	ra,0x0
    80003e74:	e14080e7          	jalr	-492(ra) # 80003c84 <balloc>
    80003e78:	0005091b          	sext.w	s2,a0
      if(addr){
    80003e7c:	fc090ae3          	beqz	s2,80003e50 <bmap+0x9a>
        a[bn] = addr;
    80003e80:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003e84:	8552                	mv	a0,s4
    80003e86:	00001097          	auipc	ra,0x1
    80003e8a:	ec6080e7          	jalr	-314(ra) # 80004d4c <log_write>
    80003e8e:	b7c9                	j	80003e50 <bmap+0x9a>
  panic("bmap: out of range");
    80003e90:	00005517          	auipc	a0,0x5
    80003e94:	99050513          	addi	a0,a0,-1648 # 80008820 <syscall_names+0x148>
    80003e98:	ffffc097          	auipc	ra,0xffffc
    80003e9c:	6a4080e7          	jalr	1700(ra) # 8000053c <panic>

0000000080003ea0 <iget>:
{
    80003ea0:	7179                	addi	sp,sp,-48
    80003ea2:	f406                	sd	ra,40(sp)
    80003ea4:	f022                	sd	s0,32(sp)
    80003ea6:	ec26                	sd	s1,24(sp)
    80003ea8:	e84a                	sd	s2,16(sp)
    80003eaa:	e44e                	sd	s3,8(sp)
    80003eac:	e052                	sd	s4,0(sp)
    80003eae:	1800                	addi	s0,sp,48
    80003eb0:	89aa                	mv	s3,a0
    80003eb2:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003eb4:	0004a517          	auipc	a0,0x4a
    80003eb8:	c7450513          	addi	a0,a0,-908 # 8004db28 <itable>
    80003ebc:	ffffd097          	auipc	ra,0xffffd
    80003ec0:	eb0080e7          	jalr	-336(ra) # 80000d6c <acquire>
  empty = 0;
    80003ec4:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003ec6:	0004a497          	auipc	s1,0x4a
    80003eca:	c7a48493          	addi	s1,s1,-902 # 8004db40 <itable+0x18>
    80003ece:	0004b697          	auipc	a3,0x4b
    80003ed2:	70268693          	addi	a3,a3,1794 # 8004f5d0 <log>
    80003ed6:	a039                	j	80003ee4 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003ed8:	02090b63          	beqz	s2,80003f0e <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003edc:	08848493          	addi	s1,s1,136
    80003ee0:	02d48a63          	beq	s1,a3,80003f14 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003ee4:	449c                	lw	a5,8(s1)
    80003ee6:	fef059e3          	blez	a5,80003ed8 <iget+0x38>
    80003eea:	4098                	lw	a4,0(s1)
    80003eec:	ff3716e3          	bne	a4,s3,80003ed8 <iget+0x38>
    80003ef0:	40d8                	lw	a4,4(s1)
    80003ef2:	ff4713e3          	bne	a4,s4,80003ed8 <iget+0x38>
      ip->ref++;
    80003ef6:	2785                	addiw	a5,a5,1
    80003ef8:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003efa:	0004a517          	auipc	a0,0x4a
    80003efe:	c2e50513          	addi	a0,a0,-978 # 8004db28 <itable>
    80003f02:	ffffd097          	auipc	ra,0xffffd
    80003f06:	f1e080e7          	jalr	-226(ra) # 80000e20 <release>
      return ip;
    80003f0a:	8926                	mv	s2,s1
    80003f0c:	a03d                	j	80003f3a <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003f0e:	f7f9                	bnez	a5,80003edc <iget+0x3c>
    80003f10:	8926                	mv	s2,s1
    80003f12:	b7e9                	j	80003edc <iget+0x3c>
  if(empty == 0)
    80003f14:	02090c63          	beqz	s2,80003f4c <iget+0xac>
  ip->dev = dev;
    80003f18:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003f1c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003f20:	4785                	li	a5,1
    80003f22:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003f26:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003f2a:	0004a517          	auipc	a0,0x4a
    80003f2e:	bfe50513          	addi	a0,a0,-1026 # 8004db28 <itable>
    80003f32:	ffffd097          	auipc	ra,0xffffd
    80003f36:	eee080e7          	jalr	-274(ra) # 80000e20 <release>
}
    80003f3a:	854a                	mv	a0,s2
    80003f3c:	70a2                	ld	ra,40(sp)
    80003f3e:	7402                	ld	s0,32(sp)
    80003f40:	64e2                	ld	s1,24(sp)
    80003f42:	6942                	ld	s2,16(sp)
    80003f44:	69a2                	ld	s3,8(sp)
    80003f46:	6a02                	ld	s4,0(sp)
    80003f48:	6145                	addi	sp,sp,48
    80003f4a:	8082                	ret
    panic("iget: no inodes");
    80003f4c:	00005517          	auipc	a0,0x5
    80003f50:	8ec50513          	addi	a0,a0,-1812 # 80008838 <syscall_names+0x160>
    80003f54:	ffffc097          	auipc	ra,0xffffc
    80003f58:	5e8080e7          	jalr	1512(ra) # 8000053c <panic>

0000000080003f5c <fsinit>:
fsinit(int dev) {
    80003f5c:	7179                	addi	sp,sp,-48
    80003f5e:	f406                	sd	ra,40(sp)
    80003f60:	f022                	sd	s0,32(sp)
    80003f62:	ec26                	sd	s1,24(sp)
    80003f64:	e84a                	sd	s2,16(sp)
    80003f66:	e44e                	sd	s3,8(sp)
    80003f68:	1800                	addi	s0,sp,48
    80003f6a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003f6c:	4585                	li	a1,1
    80003f6e:	00000097          	auipc	ra,0x0
    80003f72:	a56080e7          	jalr	-1450(ra) # 800039c4 <bread>
    80003f76:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003f78:	0004a997          	auipc	s3,0x4a
    80003f7c:	b9098993          	addi	s3,s3,-1136 # 8004db08 <sb>
    80003f80:	02000613          	li	a2,32
    80003f84:	05850593          	addi	a1,a0,88
    80003f88:	854e                	mv	a0,s3
    80003f8a:	ffffd097          	auipc	ra,0xffffd
    80003f8e:	f3a080e7          	jalr	-198(ra) # 80000ec4 <memmove>
  brelse(bp);
    80003f92:	8526                	mv	a0,s1
    80003f94:	00000097          	auipc	ra,0x0
    80003f98:	b60080e7          	jalr	-1184(ra) # 80003af4 <brelse>
  if(sb.magic != FSMAGIC)
    80003f9c:	0009a703          	lw	a4,0(s3)
    80003fa0:	102037b7          	lui	a5,0x10203
    80003fa4:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003fa8:	02f71263          	bne	a4,a5,80003fcc <fsinit+0x70>
  initlog(dev, &sb);
    80003fac:	0004a597          	auipc	a1,0x4a
    80003fb0:	b5c58593          	addi	a1,a1,-1188 # 8004db08 <sb>
    80003fb4:	854a                	mv	a0,s2
    80003fb6:	00001097          	auipc	ra,0x1
    80003fba:	b2c080e7          	jalr	-1236(ra) # 80004ae2 <initlog>
}
    80003fbe:	70a2                	ld	ra,40(sp)
    80003fc0:	7402                	ld	s0,32(sp)
    80003fc2:	64e2                	ld	s1,24(sp)
    80003fc4:	6942                	ld	s2,16(sp)
    80003fc6:	69a2                	ld	s3,8(sp)
    80003fc8:	6145                	addi	sp,sp,48
    80003fca:	8082                	ret
    panic("invalid file system");
    80003fcc:	00005517          	auipc	a0,0x5
    80003fd0:	87c50513          	addi	a0,a0,-1924 # 80008848 <syscall_names+0x170>
    80003fd4:	ffffc097          	auipc	ra,0xffffc
    80003fd8:	568080e7          	jalr	1384(ra) # 8000053c <panic>

0000000080003fdc <iinit>:
{
    80003fdc:	7179                	addi	sp,sp,-48
    80003fde:	f406                	sd	ra,40(sp)
    80003fe0:	f022                	sd	s0,32(sp)
    80003fe2:	ec26                	sd	s1,24(sp)
    80003fe4:	e84a                	sd	s2,16(sp)
    80003fe6:	e44e                	sd	s3,8(sp)
    80003fe8:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003fea:	00005597          	auipc	a1,0x5
    80003fee:	87658593          	addi	a1,a1,-1930 # 80008860 <syscall_names+0x188>
    80003ff2:	0004a517          	auipc	a0,0x4a
    80003ff6:	b3650513          	addi	a0,a0,-1226 # 8004db28 <itable>
    80003ffa:	ffffd097          	auipc	ra,0xffffd
    80003ffe:	ce2080e7          	jalr	-798(ra) # 80000cdc <initlock>
  for(i = 0; i < NINODE; i++) {
    80004002:	0004a497          	auipc	s1,0x4a
    80004006:	b4e48493          	addi	s1,s1,-1202 # 8004db50 <itable+0x28>
    8000400a:	0004b997          	auipc	s3,0x4b
    8000400e:	5d698993          	addi	s3,s3,1494 # 8004f5e0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80004012:	00005917          	auipc	s2,0x5
    80004016:	85690913          	addi	s2,s2,-1962 # 80008868 <syscall_names+0x190>
    8000401a:	85ca                	mv	a1,s2
    8000401c:	8526                	mv	a0,s1
    8000401e:	00001097          	auipc	ra,0x1
    80004022:	e12080e7          	jalr	-494(ra) # 80004e30 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80004026:	08848493          	addi	s1,s1,136
    8000402a:	ff3498e3          	bne	s1,s3,8000401a <iinit+0x3e>
}
    8000402e:	70a2                	ld	ra,40(sp)
    80004030:	7402                	ld	s0,32(sp)
    80004032:	64e2                	ld	s1,24(sp)
    80004034:	6942                	ld	s2,16(sp)
    80004036:	69a2                	ld	s3,8(sp)
    80004038:	6145                	addi	sp,sp,48
    8000403a:	8082                	ret

000000008000403c <ialloc>:
{
    8000403c:	7139                	addi	sp,sp,-64
    8000403e:	fc06                	sd	ra,56(sp)
    80004040:	f822                	sd	s0,48(sp)
    80004042:	f426                	sd	s1,40(sp)
    80004044:	f04a                	sd	s2,32(sp)
    80004046:	ec4e                	sd	s3,24(sp)
    80004048:	e852                	sd	s4,16(sp)
    8000404a:	e456                	sd	s5,8(sp)
    8000404c:	e05a                	sd	s6,0(sp)
    8000404e:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80004050:	0004a717          	auipc	a4,0x4a
    80004054:	ac472703          	lw	a4,-1340(a4) # 8004db14 <sb+0xc>
    80004058:	4785                	li	a5,1
    8000405a:	04e7f863          	bgeu	a5,a4,800040aa <ialloc+0x6e>
    8000405e:	8aaa                	mv	s5,a0
    80004060:	8b2e                	mv	s6,a1
    80004062:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80004064:	0004aa17          	auipc	s4,0x4a
    80004068:	aa4a0a13          	addi	s4,s4,-1372 # 8004db08 <sb>
    8000406c:	00495593          	srli	a1,s2,0x4
    80004070:	018a2783          	lw	a5,24(s4)
    80004074:	9dbd                	addw	a1,a1,a5
    80004076:	8556                	mv	a0,s5
    80004078:	00000097          	auipc	ra,0x0
    8000407c:	94c080e7          	jalr	-1716(ra) # 800039c4 <bread>
    80004080:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80004082:	05850993          	addi	s3,a0,88
    80004086:	00f97793          	andi	a5,s2,15
    8000408a:	079a                	slli	a5,a5,0x6
    8000408c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000408e:	00099783          	lh	a5,0(s3)
    80004092:	cf9d                	beqz	a5,800040d0 <ialloc+0x94>
    brelse(bp);
    80004094:	00000097          	auipc	ra,0x0
    80004098:	a60080e7          	jalr	-1440(ra) # 80003af4 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000409c:	0905                	addi	s2,s2,1
    8000409e:	00ca2703          	lw	a4,12(s4)
    800040a2:	0009079b          	sext.w	a5,s2
    800040a6:	fce7e3e3          	bltu	a5,a4,8000406c <ialloc+0x30>
  printf("ialloc: no inodes\n");
    800040aa:	00004517          	auipc	a0,0x4
    800040ae:	7c650513          	addi	a0,a0,1990 # 80008870 <syscall_names+0x198>
    800040b2:	ffffc097          	auipc	ra,0xffffc
    800040b6:	4d4080e7          	jalr	1236(ra) # 80000586 <printf>
  return 0;
    800040ba:	4501                	li	a0,0
}
    800040bc:	70e2                	ld	ra,56(sp)
    800040be:	7442                	ld	s0,48(sp)
    800040c0:	74a2                	ld	s1,40(sp)
    800040c2:	7902                	ld	s2,32(sp)
    800040c4:	69e2                	ld	s3,24(sp)
    800040c6:	6a42                	ld	s4,16(sp)
    800040c8:	6aa2                	ld	s5,8(sp)
    800040ca:	6b02                	ld	s6,0(sp)
    800040cc:	6121                	addi	sp,sp,64
    800040ce:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800040d0:	04000613          	li	a2,64
    800040d4:	4581                	li	a1,0
    800040d6:	854e                	mv	a0,s3
    800040d8:	ffffd097          	auipc	ra,0xffffd
    800040dc:	d90080e7          	jalr	-624(ra) # 80000e68 <memset>
      dip->type = type;
    800040e0:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800040e4:	8526                	mv	a0,s1
    800040e6:	00001097          	auipc	ra,0x1
    800040ea:	c66080e7          	jalr	-922(ra) # 80004d4c <log_write>
      brelse(bp);
    800040ee:	8526                	mv	a0,s1
    800040f0:	00000097          	auipc	ra,0x0
    800040f4:	a04080e7          	jalr	-1532(ra) # 80003af4 <brelse>
      return iget(dev, inum);
    800040f8:	0009059b          	sext.w	a1,s2
    800040fc:	8556                	mv	a0,s5
    800040fe:	00000097          	auipc	ra,0x0
    80004102:	da2080e7          	jalr	-606(ra) # 80003ea0 <iget>
    80004106:	bf5d                	j	800040bc <ialloc+0x80>

0000000080004108 <iupdate>:
{
    80004108:	1101                	addi	sp,sp,-32
    8000410a:	ec06                	sd	ra,24(sp)
    8000410c:	e822                	sd	s0,16(sp)
    8000410e:	e426                	sd	s1,8(sp)
    80004110:	e04a                	sd	s2,0(sp)
    80004112:	1000                	addi	s0,sp,32
    80004114:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004116:	415c                	lw	a5,4(a0)
    80004118:	0047d79b          	srliw	a5,a5,0x4
    8000411c:	0004a597          	auipc	a1,0x4a
    80004120:	a045a583          	lw	a1,-1532(a1) # 8004db20 <sb+0x18>
    80004124:	9dbd                	addw	a1,a1,a5
    80004126:	4108                	lw	a0,0(a0)
    80004128:	00000097          	auipc	ra,0x0
    8000412c:	89c080e7          	jalr	-1892(ra) # 800039c4 <bread>
    80004130:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004132:	05850793          	addi	a5,a0,88
    80004136:	40d8                	lw	a4,4(s1)
    80004138:	8b3d                	andi	a4,a4,15
    8000413a:	071a                	slli	a4,a4,0x6
    8000413c:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000413e:	04449703          	lh	a4,68(s1)
    80004142:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80004146:	04649703          	lh	a4,70(s1)
    8000414a:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000414e:	04849703          	lh	a4,72(s1)
    80004152:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80004156:	04a49703          	lh	a4,74(s1)
    8000415a:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000415e:	44f8                	lw	a4,76(s1)
    80004160:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80004162:	03400613          	li	a2,52
    80004166:	05048593          	addi	a1,s1,80
    8000416a:	00c78513          	addi	a0,a5,12
    8000416e:	ffffd097          	auipc	ra,0xffffd
    80004172:	d56080e7          	jalr	-682(ra) # 80000ec4 <memmove>
  log_write(bp);
    80004176:	854a                	mv	a0,s2
    80004178:	00001097          	auipc	ra,0x1
    8000417c:	bd4080e7          	jalr	-1068(ra) # 80004d4c <log_write>
  brelse(bp);
    80004180:	854a                	mv	a0,s2
    80004182:	00000097          	auipc	ra,0x0
    80004186:	972080e7          	jalr	-1678(ra) # 80003af4 <brelse>
}
    8000418a:	60e2                	ld	ra,24(sp)
    8000418c:	6442                	ld	s0,16(sp)
    8000418e:	64a2                	ld	s1,8(sp)
    80004190:	6902                	ld	s2,0(sp)
    80004192:	6105                	addi	sp,sp,32
    80004194:	8082                	ret

0000000080004196 <idup>:
{
    80004196:	1101                	addi	sp,sp,-32
    80004198:	ec06                	sd	ra,24(sp)
    8000419a:	e822                	sd	s0,16(sp)
    8000419c:	e426                	sd	s1,8(sp)
    8000419e:	1000                	addi	s0,sp,32
    800041a0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800041a2:	0004a517          	auipc	a0,0x4a
    800041a6:	98650513          	addi	a0,a0,-1658 # 8004db28 <itable>
    800041aa:	ffffd097          	auipc	ra,0xffffd
    800041ae:	bc2080e7          	jalr	-1086(ra) # 80000d6c <acquire>
  ip->ref++;
    800041b2:	449c                	lw	a5,8(s1)
    800041b4:	2785                	addiw	a5,a5,1
    800041b6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800041b8:	0004a517          	auipc	a0,0x4a
    800041bc:	97050513          	addi	a0,a0,-1680 # 8004db28 <itable>
    800041c0:	ffffd097          	auipc	ra,0xffffd
    800041c4:	c60080e7          	jalr	-928(ra) # 80000e20 <release>
}
    800041c8:	8526                	mv	a0,s1
    800041ca:	60e2                	ld	ra,24(sp)
    800041cc:	6442                	ld	s0,16(sp)
    800041ce:	64a2                	ld	s1,8(sp)
    800041d0:	6105                	addi	sp,sp,32
    800041d2:	8082                	ret

00000000800041d4 <ilock>:
{
    800041d4:	1101                	addi	sp,sp,-32
    800041d6:	ec06                	sd	ra,24(sp)
    800041d8:	e822                	sd	s0,16(sp)
    800041da:	e426                	sd	s1,8(sp)
    800041dc:	e04a                	sd	s2,0(sp)
    800041de:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800041e0:	c115                	beqz	a0,80004204 <ilock+0x30>
    800041e2:	84aa                	mv	s1,a0
    800041e4:	451c                	lw	a5,8(a0)
    800041e6:	00f05f63          	blez	a5,80004204 <ilock+0x30>
  acquiresleep(&ip->lock);
    800041ea:	0541                	addi	a0,a0,16
    800041ec:	00001097          	auipc	ra,0x1
    800041f0:	c7e080e7          	jalr	-898(ra) # 80004e6a <acquiresleep>
  if(ip->valid == 0){
    800041f4:	40bc                	lw	a5,64(s1)
    800041f6:	cf99                	beqz	a5,80004214 <ilock+0x40>
}
    800041f8:	60e2                	ld	ra,24(sp)
    800041fa:	6442                	ld	s0,16(sp)
    800041fc:	64a2                	ld	s1,8(sp)
    800041fe:	6902                	ld	s2,0(sp)
    80004200:	6105                	addi	sp,sp,32
    80004202:	8082                	ret
    panic("ilock");
    80004204:	00004517          	auipc	a0,0x4
    80004208:	68450513          	addi	a0,a0,1668 # 80008888 <syscall_names+0x1b0>
    8000420c:	ffffc097          	auipc	ra,0xffffc
    80004210:	330080e7          	jalr	816(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004214:	40dc                	lw	a5,4(s1)
    80004216:	0047d79b          	srliw	a5,a5,0x4
    8000421a:	0004a597          	auipc	a1,0x4a
    8000421e:	9065a583          	lw	a1,-1786(a1) # 8004db20 <sb+0x18>
    80004222:	9dbd                	addw	a1,a1,a5
    80004224:	4088                	lw	a0,0(s1)
    80004226:	fffff097          	auipc	ra,0xfffff
    8000422a:	79e080e7          	jalr	1950(ra) # 800039c4 <bread>
    8000422e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004230:	05850593          	addi	a1,a0,88
    80004234:	40dc                	lw	a5,4(s1)
    80004236:	8bbd                	andi	a5,a5,15
    80004238:	079a                	slli	a5,a5,0x6
    8000423a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000423c:	00059783          	lh	a5,0(a1)
    80004240:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004244:	00259783          	lh	a5,2(a1)
    80004248:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000424c:	00459783          	lh	a5,4(a1)
    80004250:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80004254:	00659783          	lh	a5,6(a1)
    80004258:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000425c:	459c                	lw	a5,8(a1)
    8000425e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80004260:	03400613          	li	a2,52
    80004264:	05b1                	addi	a1,a1,12
    80004266:	05048513          	addi	a0,s1,80
    8000426a:	ffffd097          	auipc	ra,0xffffd
    8000426e:	c5a080e7          	jalr	-934(ra) # 80000ec4 <memmove>
    brelse(bp);
    80004272:	854a                	mv	a0,s2
    80004274:	00000097          	auipc	ra,0x0
    80004278:	880080e7          	jalr	-1920(ra) # 80003af4 <brelse>
    ip->valid = 1;
    8000427c:	4785                	li	a5,1
    8000427e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80004280:	04449783          	lh	a5,68(s1)
    80004284:	fbb5                	bnez	a5,800041f8 <ilock+0x24>
      panic("ilock: no type");
    80004286:	00004517          	auipc	a0,0x4
    8000428a:	60a50513          	addi	a0,a0,1546 # 80008890 <syscall_names+0x1b8>
    8000428e:	ffffc097          	auipc	ra,0xffffc
    80004292:	2ae080e7          	jalr	686(ra) # 8000053c <panic>

0000000080004296 <iunlock>:
{
    80004296:	1101                	addi	sp,sp,-32
    80004298:	ec06                	sd	ra,24(sp)
    8000429a:	e822                	sd	s0,16(sp)
    8000429c:	e426                	sd	s1,8(sp)
    8000429e:	e04a                	sd	s2,0(sp)
    800042a0:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800042a2:	c905                	beqz	a0,800042d2 <iunlock+0x3c>
    800042a4:	84aa                	mv	s1,a0
    800042a6:	01050913          	addi	s2,a0,16
    800042aa:	854a                	mv	a0,s2
    800042ac:	00001097          	auipc	ra,0x1
    800042b0:	c58080e7          	jalr	-936(ra) # 80004f04 <holdingsleep>
    800042b4:	cd19                	beqz	a0,800042d2 <iunlock+0x3c>
    800042b6:	449c                	lw	a5,8(s1)
    800042b8:	00f05d63          	blez	a5,800042d2 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800042bc:	854a                	mv	a0,s2
    800042be:	00001097          	auipc	ra,0x1
    800042c2:	c02080e7          	jalr	-1022(ra) # 80004ec0 <releasesleep>
}
    800042c6:	60e2                	ld	ra,24(sp)
    800042c8:	6442                	ld	s0,16(sp)
    800042ca:	64a2                	ld	s1,8(sp)
    800042cc:	6902                	ld	s2,0(sp)
    800042ce:	6105                	addi	sp,sp,32
    800042d0:	8082                	ret
    panic("iunlock");
    800042d2:	00004517          	auipc	a0,0x4
    800042d6:	5ce50513          	addi	a0,a0,1486 # 800088a0 <syscall_names+0x1c8>
    800042da:	ffffc097          	auipc	ra,0xffffc
    800042de:	262080e7          	jalr	610(ra) # 8000053c <panic>

00000000800042e2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800042e2:	7179                	addi	sp,sp,-48
    800042e4:	f406                	sd	ra,40(sp)
    800042e6:	f022                	sd	s0,32(sp)
    800042e8:	ec26                	sd	s1,24(sp)
    800042ea:	e84a                	sd	s2,16(sp)
    800042ec:	e44e                	sd	s3,8(sp)
    800042ee:	e052                	sd	s4,0(sp)
    800042f0:	1800                	addi	s0,sp,48
    800042f2:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800042f4:	05050493          	addi	s1,a0,80
    800042f8:	08050913          	addi	s2,a0,128
    800042fc:	a021                	j	80004304 <itrunc+0x22>
    800042fe:	0491                	addi	s1,s1,4
    80004300:	01248d63          	beq	s1,s2,8000431a <itrunc+0x38>
    if(ip->addrs[i]){
    80004304:	408c                	lw	a1,0(s1)
    80004306:	dde5                	beqz	a1,800042fe <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80004308:	0009a503          	lw	a0,0(s3)
    8000430c:	00000097          	auipc	ra,0x0
    80004310:	8fc080e7          	jalr	-1796(ra) # 80003c08 <bfree>
      ip->addrs[i] = 0;
    80004314:	0004a023          	sw	zero,0(s1)
    80004318:	b7dd                	j	800042fe <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000431a:	0809a583          	lw	a1,128(s3)
    8000431e:	e185                	bnez	a1,8000433e <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004320:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004324:	854e                	mv	a0,s3
    80004326:	00000097          	auipc	ra,0x0
    8000432a:	de2080e7          	jalr	-542(ra) # 80004108 <iupdate>
}
    8000432e:	70a2                	ld	ra,40(sp)
    80004330:	7402                	ld	s0,32(sp)
    80004332:	64e2                	ld	s1,24(sp)
    80004334:	6942                	ld	s2,16(sp)
    80004336:	69a2                	ld	s3,8(sp)
    80004338:	6a02                	ld	s4,0(sp)
    8000433a:	6145                	addi	sp,sp,48
    8000433c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000433e:	0009a503          	lw	a0,0(s3)
    80004342:	fffff097          	auipc	ra,0xfffff
    80004346:	682080e7          	jalr	1666(ra) # 800039c4 <bread>
    8000434a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000434c:	05850493          	addi	s1,a0,88
    80004350:	45850913          	addi	s2,a0,1112
    80004354:	a021                	j	8000435c <itrunc+0x7a>
    80004356:	0491                	addi	s1,s1,4
    80004358:	01248b63          	beq	s1,s2,8000436e <itrunc+0x8c>
      if(a[j])
    8000435c:	408c                	lw	a1,0(s1)
    8000435e:	dde5                	beqz	a1,80004356 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80004360:	0009a503          	lw	a0,0(s3)
    80004364:	00000097          	auipc	ra,0x0
    80004368:	8a4080e7          	jalr	-1884(ra) # 80003c08 <bfree>
    8000436c:	b7ed                	j	80004356 <itrunc+0x74>
    brelse(bp);
    8000436e:	8552                	mv	a0,s4
    80004370:	fffff097          	auipc	ra,0xfffff
    80004374:	784080e7          	jalr	1924(ra) # 80003af4 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004378:	0809a583          	lw	a1,128(s3)
    8000437c:	0009a503          	lw	a0,0(s3)
    80004380:	00000097          	auipc	ra,0x0
    80004384:	888080e7          	jalr	-1912(ra) # 80003c08 <bfree>
    ip->addrs[NDIRECT] = 0;
    80004388:	0809a023          	sw	zero,128(s3)
    8000438c:	bf51                	j	80004320 <itrunc+0x3e>

000000008000438e <iput>:
{
    8000438e:	1101                	addi	sp,sp,-32
    80004390:	ec06                	sd	ra,24(sp)
    80004392:	e822                	sd	s0,16(sp)
    80004394:	e426                	sd	s1,8(sp)
    80004396:	e04a                	sd	s2,0(sp)
    80004398:	1000                	addi	s0,sp,32
    8000439a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000439c:	00049517          	auipc	a0,0x49
    800043a0:	78c50513          	addi	a0,a0,1932 # 8004db28 <itable>
    800043a4:	ffffd097          	auipc	ra,0xffffd
    800043a8:	9c8080e7          	jalr	-1592(ra) # 80000d6c <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800043ac:	4498                	lw	a4,8(s1)
    800043ae:	4785                	li	a5,1
    800043b0:	02f70363          	beq	a4,a5,800043d6 <iput+0x48>
  ip->ref--;
    800043b4:	449c                	lw	a5,8(s1)
    800043b6:	37fd                	addiw	a5,a5,-1
    800043b8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800043ba:	00049517          	auipc	a0,0x49
    800043be:	76e50513          	addi	a0,a0,1902 # 8004db28 <itable>
    800043c2:	ffffd097          	auipc	ra,0xffffd
    800043c6:	a5e080e7          	jalr	-1442(ra) # 80000e20 <release>
}
    800043ca:	60e2                	ld	ra,24(sp)
    800043cc:	6442                	ld	s0,16(sp)
    800043ce:	64a2                	ld	s1,8(sp)
    800043d0:	6902                	ld	s2,0(sp)
    800043d2:	6105                	addi	sp,sp,32
    800043d4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800043d6:	40bc                	lw	a5,64(s1)
    800043d8:	dff1                	beqz	a5,800043b4 <iput+0x26>
    800043da:	04a49783          	lh	a5,74(s1)
    800043de:	fbf9                	bnez	a5,800043b4 <iput+0x26>
    acquiresleep(&ip->lock);
    800043e0:	01048913          	addi	s2,s1,16
    800043e4:	854a                	mv	a0,s2
    800043e6:	00001097          	auipc	ra,0x1
    800043ea:	a84080e7          	jalr	-1404(ra) # 80004e6a <acquiresleep>
    release(&itable.lock);
    800043ee:	00049517          	auipc	a0,0x49
    800043f2:	73a50513          	addi	a0,a0,1850 # 8004db28 <itable>
    800043f6:	ffffd097          	auipc	ra,0xffffd
    800043fa:	a2a080e7          	jalr	-1494(ra) # 80000e20 <release>
    itrunc(ip);
    800043fe:	8526                	mv	a0,s1
    80004400:	00000097          	auipc	ra,0x0
    80004404:	ee2080e7          	jalr	-286(ra) # 800042e2 <itrunc>
    ip->type = 0;
    80004408:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000440c:	8526                	mv	a0,s1
    8000440e:	00000097          	auipc	ra,0x0
    80004412:	cfa080e7          	jalr	-774(ra) # 80004108 <iupdate>
    ip->valid = 0;
    80004416:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000441a:	854a                	mv	a0,s2
    8000441c:	00001097          	auipc	ra,0x1
    80004420:	aa4080e7          	jalr	-1372(ra) # 80004ec0 <releasesleep>
    acquire(&itable.lock);
    80004424:	00049517          	auipc	a0,0x49
    80004428:	70450513          	addi	a0,a0,1796 # 8004db28 <itable>
    8000442c:	ffffd097          	auipc	ra,0xffffd
    80004430:	940080e7          	jalr	-1728(ra) # 80000d6c <acquire>
    80004434:	b741                	j	800043b4 <iput+0x26>

0000000080004436 <iunlockput>:
{
    80004436:	1101                	addi	sp,sp,-32
    80004438:	ec06                	sd	ra,24(sp)
    8000443a:	e822                	sd	s0,16(sp)
    8000443c:	e426                	sd	s1,8(sp)
    8000443e:	1000                	addi	s0,sp,32
    80004440:	84aa                	mv	s1,a0
  iunlock(ip);
    80004442:	00000097          	auipc	ra,0x0
    80004446:	e54080e7          	jalr	-428(ra) # 80004296 <iunlock>
  iput(ip);
    8000444a:	8526                	mv	a0,s1
    8000444c:	00000097          	auipc	ra,0x0
    80004450:	f42080e7          	jalr	-190(ra) # 8000438e <iput>
}
    80004454:	60e2                	ld	ra,24(sp)
    80004456:	6442                	ld	s0,16(sp)
    80004458:	64a2                	ld	s1,8(sp)
    8000445a:	6105                	addi	sp,sp,32
    8000445c:	8082                	ret

000000008000445e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000445e:	1141                	addi	sp,sp,-16
    80004460:	e422                	sd	s0,8(sp)
    80004462:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004464:	411c                	lw	a5,0(a0)
    80004466:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004468:	415c                	lw	a5,4(a0)
    8000446a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000446c:	04451783          	lh	a5,68(a0)
    80004470:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004474:	04a51783          	lh	a5,74(a0)
    80004478:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000447c:	04c56783          	lwu	a5,76(a0)
    80004480:	e99c                	sd	a5,16(a1)
}
    80004482:	6422                	ld	s0,8(sp)
    80004484:	0141                	addi	sp,sp,16
    80004486:	8082                	ret

0000000080004488 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004488:	457c                	lw	a5,76(a0)
    8000448a:	0ed7e963          	bltu	a5,a3,8000457c <readi+0xf4>
{
    8000448e:	7159                	addi	sp,sp,-112
    80004490:	f486                	sd	ra,104(sp)
    80004492:	f0a2                	sd	s0,96(sp)
    80004494:	eca6                	sd	s1,88(sp)
    80004496:	e8ca                	sd	s2,80(sp)
    80004498:	e4ce                	sd	s3,72(sp)
    8000449a:	e0d2                	sd	s4,64(sp)
    8000449c:	fc56                	sd	s5,56(sp)
    8000449e:	f85a                	sd	s6,48(sp)
    800044a0:	f45e                	sd	s7,40(sp)
    800044a2:	f062                	sd	s8,32(sp)
    800044a4:	ec66                	sd	s9,24(sp)
    800044a6:	e86a                	sd	s10,16(sp)
    800044a8:	e46e                	sd	s11,8(sp)
    800044aa:	1880                	addi	s0,sp,112
    800044ac:	8b2a                	mv	s6,a0
    800044ae:	8bae                	mv	s7,a1
    800044b0:	8a32                	mv	s4,a2
    800044b2:	84b6                	mv	s1,a3
    800044b4:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800044b6:	9f35                	addw	a4,a4,a3
    return 0;
    800044b8:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800044ba:	0ad76063          	bltu	a4,a3,8000455a <readi+0xd2>
  if(off + n > ip->size)
    800044be:	00e7f463          	bgeu	a5,a4,800044c6 <readi+0x3e>
    n = ip->size - off;
    800044c2:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800044c6:	0a0a8963          	beqz	s5,80004578 <readi+0xf0>
    800044ca:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800044cc:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800044d0:	5c7d                	li	s8,-1
    800044d2:	a82d                	j	8000450c <readi+0x84>
    800044d4:	020d1d93          	slli	s11,s10,0x20
    800044d8:	020ddd93          	srli	s11,s11,0x20
    800044dc:	05890613          	addi	a2,s2,88
    800044e0:	86ee                	mv	a3,s11
    800044e2:	963a                	add	a2,a2,a4
    800044e4:	85d2                	mv	a1,s4
    800044e6:	855e                	mv	a0,s7
    800044e8:	ffffe097          	auipc	ra,0xffffe
    800044ec:	596080e7          	jalr	1430(ra) # 80002a7e <either_copyout>
    800044f0:	05850d63          	beq	a0,s8,8000454a <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800044f4:	854a                	mv	a0,s2
    800044f6:	fffff097          	auipc	ra,0xfffff
    800044fa:	5fe080e7          	jalr	1534(ra) # 80003af4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800044fe:	013d09bb          	addw	s3,s10,s3
    80004502:	009d04bb          	addw	s1,s10,s1
    80004506:	9a6e                	add	s4,s4,s11
    80004508:	0559f763          	bgeu	s3,s5,80004556 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    8000450c:	00a4d59b          	srliw	a1,s1,0xa
    80004510:	855a                	mv	a0,s6
    80004512:	00000097          	auipc	ra,0x0
    80004516:	8a4080e7          	jalr	-1884(ra) # 80003db6 <bmap>
    8000451a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000451e:	cd85                	beqz	a1,80004556 <readi+0xce>
    bp = bread(ip->dev, addr);
    80004520:	000b2503          	lw	a0,0(s6)
    80004524:	fffff097          	auipc	ra,0xfffff
    80004528:	4a0080e7          	jalr	1184(ra) # 800039c4 <bread>
    8000452c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000452e:	3ff4f713          	andi	a4,s1,1023
    80004532:	40ec87bb          	subw	a5,s9,a4
    80004536:	413a86bb          	subw	a3,s5,s3
    8000453a:	8d3e                	mv	s10,a5
    8000453c:	2781                	sext.w	a5,a5
    8000453e:	0006861b          	sext.w	a2,a3
    80004542:	f8f679e3          	bgeu	a2,a5,800044d4 <readi+0x4c>
    80004546:	8d36                	mv	s10,a3
    80004548:	b771                	j	800044d4 <readi+0x4c>
      brelse(bp);
    8000454a:	854a                	mv	a0,s2
    8000454c:	fffff097          	auipc	ra,0xfffff
    80004550:	5a8080e7          	jalr	1448(ra) # 80003af4 <brelse>
      tot = -1;
    80004554:	59fd                	li	s3,-1
  }
  return tot;
    80004556:	0009851b          	sext.w	a0,s3
}
    8000455a:	70a6                	ld	ra,104(sp)
    8000455c:	7406                	ld	s0,96(sp)
    8000455e:	64e6                	ld	s1,88(sp)
    80004560:	6946                	ld	s2,80(sp)
    80004562:	69a6                	ld	s3,72(sp)
    80004564:	6a06                	ld	s4,64(sp)
    80004566:	7ae2                	ld	s5,56(sp)
    80004568:	7b42                	ld	s6,48(sp)
    8000456a:	7ba2                	ld	s7,40(sp)
    8000456c:	7c02                	ld	s8,32(sp)
    8000456e:	6ce2                	ld	s9,24(sp)
    80004570:	6d42                	ld	s10,16(sp)
    80004572:	6da2                	ld	s11,8(sp)
    80004574:	6165                	addi	sp,sp,112
    80004576:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004578:	89d6                	mv	s3,s5
    8000457a:	bff1                	j	80004556 <readi+0xce>
    return 0;
    8000457c:	4501                	li	a0,0
}
    8000457e:	8082                	ret

0000000080004580 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004580:	457c                	lw	a5,76(a0)
    80004582:	10d7e863          	bltu	a5,a3,80004692 <writei+0x112>
{
    80004586:	7159                	addi	sp,sp,-112
    80004588:	f486                	sd	ra,104(sp)
    8000458a:	f0a2                	sd	s0,96(sp)
    8000458c:	eca6                	sd	s1,88(sp)
    8000458e:	e8ca                	sd	s2,80(sp)
    80004590:	e4ce                	sd	s3,72(sp)
    80004592:	e0d2                	sd	s4,64(sp)
    80004594:	fc56                	sd	s5,56(sp)
    80004596:	f85a                	sd	s6,48(sp)
    80004598:	f45e                	sd	s7,40(sp)
    8000459a:	f062                	sd	s8,32(sp)
    8000459c:	ec66                	sd	s9,24(sp)
    8000459e:	e86a                	sd	s10,16(sp)
    800045a0:	e46e                	sd	s11,8(sp)
    800045a2:	1880                	addi	s0,sp,112
    800045a4:	8aaa                	mv	s5,a0
    800045a6:	8bae                	mv	s7,a1
    800045a8:	8a32                	mv	s4,a2
    800045aa:	8936                	mv	s2,a3
    800045ac:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800045ae:	00e687bb          	addw	a5,a3,a4
    800045b2:	0ed7e263          	bltu	a5,a3,80004696 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800045b6:	00043737          	lui	a4,0x43
    800045ba:	0ef76063          	bltu	a4,a5,8000469a <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800045be:	0c0b0863          	beqz	s6,8000468e <writei+0x10e>
    800045c2:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800045c4:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800045c8:	5c7d                	li	s8,-1
    800045ca:	a091                	j	8000460e <writei+0x8e>
    800045cc:	020d1d93          	slli	s11,s10,0x20
    800045d0:	020ddd93          	srli	s11,s11,0x20
    800045d4:	05848513          	addi	a0,s1,88
    800045d8:	86ee                	mv	a3,s11
    800045da:	8652                	mv	a2,s4
    800045dc:	85de                	mv	a1,s7
    800045de:	953a                	add	a0,a0,a4
    800045e0:	ffffe097          	auipc	ra,0xffffe
    800045e4:	4f4080e7          	jalr	1268(ra) # 80002ad4 <either_copyin>
    800045e8:	07850263          	beq	a0,s8,8000464c <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800045ec:	8526                	mv	a0,s1
    800045ee:	00000097          	auipc	ra,0x0
    800045f2:	75e080e7          	jalr	1886(ra) # 80004d4c <log_write>
    brelse(bp);
    800045f6:	8526                	mv	a0,s1
    800045f8:	fffff097          	auipc	ra,0xfffff
    800045fc:	4fc080e7          	jalr	1276(ra) # 80003af4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004600:	013d09bb          	addw	s3,s10,s3
    80004604:	012d093b          	addw	s2,s10,s2
    80004608:	9a6e                	add	s4,s4,s11
    8000460a:	0569f663          	bgeu	s3,s6,80004656 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    8000460e:	00a9559b          	srliw	a1,s2,0xa
    80004612:	8556                	mv	a0,s5
    80004614:	fffff097          	auipc	ra,0xfffff
    80004618:	7a2080e7          	jalr	1954(ra) # 80003db6 <bmap>
    8000461c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004620:	c99d                	beqz	a1,80004656 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004622:	000aa503          	lw	a0,0(s5)
    80004626:	fffff097          	auipc	ra,0xfffff
    8000462a:	39e080e7          	jalr	926(ra) # 800039c4 <bread>
    8000462e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004630:	3ff97713          	andi	a4,s2,1023
    80004634:	40ec87bb          	subw	a5,s9,a4
    80004638:	413b06bb          	subw	a3,s6,s3
    8000463c:	8d3e                	mv	s10,a5
    8000463e:	2781                	sext.w	a5,a5
    80004640:	0006861b          	sext.w	a2,a3
    80004644:	f8f674e3          	bgeu	a2,a5,800045cc <writei+0x4c>
    80004648:	8d36                	mv	s10,a3
    8000464a:	b749                	j	800045cc <writei+0x4c>
      brelse(bp);
    8000464c:	8526                	mv	a0,s1
    8000464e:	fffff097          	auipc	ra,0xfffff
    80004652:	4a6080e7          	jalr	1190(ra) # 80003af4 <brelse>
  }

  if(off > ip->size)
    80004656:	04caa783          	lw	a5,76(s5)
    8000465a:	0127f463          	bgeu	a5,s2,80004662 <writei+0xe2>
    ip->size = off;
    8000465e:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004662:	8556                	mv	a0,s5
    80004664:	00000097          	auipc	ra,0x0
    80004668:	aa4080e7          	jalr	-1372(ra) # 80004108 <iupdate>

  return tot;
    8000466c:	0009851b          	sext.w	a0,s3
}
    80004670:	70a6                	ld	ra,104(sp)
    80004672:	7406                	ld	s0,96(sp)
    80004674:	64e6                	ld	s1,88(sp)
    80004676:	6946                	ld	s2,80(sp)
    80004678:	69a6                	ld	s3,72(sp)
    8000467a:	6a06                	ld	s4,64(sp)
    8000467c:	7ae2                	ld	s5,56(sp)
    8000467e:	7b42                	ld	s6,48(sp)
    80004680:	7ba2                	ld	s7,40(sp)
    80004682:	7c02                	ld	s8,32(sp)
    80004684:	6ce2                	ld	s9,24(sp)
    80004686:	6d42                	ld	s10,16(sp)
    80004688:	6da2                	ld	s11,8(sp)
    8000468a:	6165                	addi	sp,sp,112
    8000468c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000468e:	89da                	mv	s3,s6
    80004690:	bfc9                	j	80004662 <writei+0xe2>
    return -1;
    80004692:	557d                	li	a0,-1
}
    80004694:	8082                	ret
    return -1;
    80004696:	557d                	li	a0,-1
    80004698:	bfe1                	j	80004670 <writei+0xf0>
    return -1;
    8000469a:	557d                	li	a0,-1
    8000469c:	bfd1                	j	80004670 <writei+0xf0>

000000008000469e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000469e:	1141                	addi	sp,sp,-16
    800046a0:	e406                	sd	ra,8(sp)
    800046a2:	e022                	sd	s0,0(sp)
    800046a4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800046a6:	4639                	li	a2,14
    800046a8:	ffffd097          	auipc	ra,0xffffd
    800046ac:	890080e7          	jalr	-1904(ra) # 80000f38 <strncmp>
}
    800046b0:	60a2                	ld	ra,8(sp)
    800046b2:	6402                	ld	s0,0(sp)
    800046b4:	0141                	addi	sp,sp,16
    800046b6:	8082                	ret

00000000800046b8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800046b8:	7139                	addi	sp,sp,-64
    800046ba:	fc06                	sd	ra,56(sp)
    800046bc:	f822                	sd	s0,48(sp)
    800046be:	f426                	sd	s1,40(sp)
    800046c0:	f04a                	sd	s2,32(sp)
    800046c2:	ec4e                	sd	s3,24(sp)
    800046c4:	e852                	sd	s4,16(sp)
    800046c6:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800046c8:	04451703          	lh	a4,68(a0)
    800046cc:	4785                	li	a5,1
    800046ce:	00f71a63          	bne	a4,a5,800046e2 <dirlookup+0x2a>
    800046d2:	892a                	mv	s2,a0
    800046d4:	89ae                	mv	s3,a1
    800046d6:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800046d8:	457c                	lw	a5,76(a0)
    800046da:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800046dc:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800046de:	e79d                	bnez	a5,8000470c <dirlookup+0x54>
    800046e0:	a8a5                	j	80004758 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800046e2:	00004517          	auipc	a0,0x4
    800046e6:	1c650513          	addi	a0,a0,454 # 800088a8 <syscall_names+0x1d0>
    800046ea:	ffffc097          	auipc	ra,0xffffc
    800046ee:	e52080e7          	jalr	-430(ra) # 8000053c <panic>
      panic("dirlookup read");
    800046f2:	00004517          	auipc	a0,0x4
    800046f6:	1ce50513          	addi	a0,a0,462 # 800088c0 <syscall_names+0x1e8>
    800046fa:	ffffc097          	auipc	ra,0xffffc
    800046fe:	e42080e7          	jalr	-446(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004702:	24c1                	addiw	s1,s1,16
    80004704:	04c92783          	lw	a5,76(s2)
    80004708:	04f4f763          	bgeu	s1,a5,80004756 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000470c:	4741                	li	a4,16
    8000470e:	86a6                	mv	a3,s1
    80004710:	fc040613          	addi	a2,s0,-64
    80004714:	4581                	li	a1,0
    80004716:	854a                	mv	a0,s2
    80004718:	00000097          	auipc	ra,0x0
    8000471c:	d70080e7          	jalr	-656(ra) # 80004488 <readi>
    80004720:	47c1                	li	a5,16
    80004722:	fcf518e3          	bne	a0,a5,800046f2 <dirlookup+0x3a>
    if(de.inum == 0)
    80004726:	fc045783          	lhu	a5,-64(s0)
    8000472a:	dfe1                	beqz	a5,80004702 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000472c:	fc240593          	addi	a1,s0,-62
    80004730:	854e                	mv	a0,s3
    80004732:	00000097          	auipc	ra,0x0
    80004736:	f6c080e7          	jalr	-148(ra) # 8000469e <namecmp>
    8000473a:	f561                	bnez	a0,80004702 <dirlookup+0x4a>
      if(poff)
    8000473c:	000a0463          	beqz	s4,80004744 <dirlookup+0x8c>
        *poff = off;
    80004740:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004744:	fc045583          	lhu	a1,-64(s0)
    80004748:	00092503          	lw	a0,0(s2)
    8000474c:	fffff097          	auipc	ra,0xfffff
    80004750:	754080e7          	jalr	1876(ra) # 80003ea0 <iget>
    80004754:	a011                	j	80004758 <dirlookup+0xa0>
  return 0;
    80004756:	4501                	li	a0,0
}
    80004758:	70e2                	ld	ra,56(sp)
    8000475a:	7442                	ld	s0,48(sp)
    8000475c:	74a2                	ld	s1,40(sp)
    8000475e:	7902                	ld	s2,32(sp)
    80004760:	69e2                	ld	s3,24(sp)
    80004762:	6a42                	ld	s4,16(sp)
    80004764:	6121                	addi	sp,sp,64
    80004766:	8082                	ret

0000000080004768 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004768:	711d                	addi	sp,sp,-96
    8000476a:	ec86                	sd	ra,88(sp)
    8000476c:	e8a2                	sd	s0,80(sp)
    8000476e:	e4a6                	sd	s1,72(sp)
    80004770:	e0ca                	sd	s2,64(sp)
    80004772:	fc4e                	sd	s3,56(sp)
    80004774:	f852                	sd	s4,48(sp)
    80004776:	f456                	sd	s5,40(sp)
    80004778:	f05a                	sd	s6,32(sp)
    8000477a:	ec5e                	sd	s7,24(sp)
    8000477c:	e862                	sd	s8,16(sp)
    8000477e:	e466                	sd	s9,8(sp)
    80004780:	1080                	addi	s0,sp,96
    80004782:	84aa                	mv	s1,a0
    80004784:	8b2e                	mv	s6,a1
    80004786:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004788:	00054703          	lbu	a4,0(a0)
    8000478c:	02f00793          	li	a5,47
    80004790:	02f70263          	beq	a4,a5,800047b4 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004794:	ffffd097          	auipc	ra,0xffffd
    80004798:	436080e7          	jalr	1078(ra) # 80001bca <myproc>
    8000479c:	15053503          	ld	a0,336(a0)
    800047a0:	00000097          	auipc	ra,0x0
    800047a4:	9f6080e7          	jalr	-1546(ra) # 80004196 <idup>
    800047a8:	8a2a                	mv	s4,a0
  while(*path == '/')
    800047aa:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800047ae:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800047b0:	4b85                	li	s7,1
    800047b2:	a875                	j	8000486e <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    800047b4:	4585                	li	a1,1
    800047b6:	4505                	li	a0,1
    800047b8:	fffff097          	auipc	ra,0xfffff
    800047bc:	6e8080e7          	jalr	1768(ra) # 80003ea0 <iget>
    800047c0:	8a2a                	mv	s4,a0
    800047c2:	b7e5                	j	800047aa <namex+0x42>
      iunlockput(ip);
    800047c4:	8552                	mv	a0,s4
    800047c6:	00000097          	auipc	ra,0x0
    800047ca:	c70080e7          	jalr	-912(ra) # 80004436 <iunlockput>
      return 0;
    800047ce:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800047d0:	8552                	mv	a0,s4
    800047d2:	60e6                	ld	ra,88(sp)
    800047d4:	6446                	ld	s0,80(sp)
    800047d6:	64a6                	ld	s1,72(sp)
    800047d8:	6906                	ld	s2,64(sp)
    800047da:	79e2                	ld	s3,56(sp)
    800047dc:	7a42                	ld	s4,48(sp)
    800047de:	7aa2                	ld	s5,40(sp)
    800047e0:	7b02                	ld	s6,32(sp)
    800047e2:	6be2                	ld	s7,24(sp)
    800047e4:	6c42                	ld	s8,16(sp)
    800047e6:	6ca2                	ld	s9,8(sp)
    800047e8:	6125                	addi	sp,sp,96
    800047ea:	8082                	ret
      iunlock(ip);
    800047ec:	8552                	mv	a0,s4
    800047ee:	00000097          	auipc	ra,0x0
    800047f2:	aa8080e7          	jalr	-1368(ra) # 80004296 <iunlock>
      return ip;
    800047f6:	bfe9                	j	800047d0 <namex+0x68>
      iunlockput(ip);
    800047f8:	8552                	mv	a0,s4
    800047fa:	00000097          	auipc	ra,0x0
    800047fe:	c3c080e7          	jalr	-964(ra) # 80004436 <iunlockput>
      return 0;
    80004802:	8a4e                	mv	s4,s3
    80004804:	b7f1                	j	800047d0 <namex+0x68>
  len = path - s;
    80004806:	40998633          	sub	a2,s3,s1
    8000480a:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    8000480e:	099c5863          	bge	s8,s9,8000489e <namex+0x136>
    memmove(name, s, DIRSIZ);
    80004812:	4639                	li	a2,14
    80004814:	85a6                	mv	a1,s1
    80004816:	8556                	mv	a0,s5
    80004818:	ffffc097          	auipc	ra,0xffffc
    8000481c:	6ac080e7          	jalr	1708(ra) # 80000ec4 <memmove>
    80004820:	84ce                	mv	s1,s3
  while(*path == '/')
    80004822:	0004c783          	lbu	a5,0(s1)
    80004826:	01279763          	bne	a5,s2,80004834 <namex+0xcc>
    path++;
    8000482a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000482c:	0004c783          	lbu	a5,0(s1)
    80004830:	ff278de3          	beq	a5,s2,8000482a <namex+0xc2>
    ilock(ip);
    80004834:	8552                	mv	a0,s4
    80004836:	00000097          	auipc	ra,0x0
    8000483a:	99e080e7          	jalr	-1634(ra) # 800041d4 <ilock>
    if(ip->type != T_DIR){
    8000483e:	044a1783          	lh	a5,68(s4)
    80004842:	f97791e3          	bne	a5,s7,800047c4 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80004846:	000b0563          	beqz	s6,80004850 <namex+0xe8>
    8000484a:	0004c783          	lbu	a5,0(s1)
    8000484e:	dfd9                	beqz	a5,800047ec <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004850:	4601                	li	a2,0
    80004852:	85d6                	mv	a1,s5
    80004854:	8552                	mv	a0,s4
    80004856:	00000097          	auipc	ra,0x0
    8000485a:	e62080e7          	jalr	-414(ra) # 800046b8 <dirlookup>
    8000485e:	89aa                	mv	s3,a0
    80004860:	dd41                	beqz	a0,800047f8 <namex+0x90>
    iunlockput(ip);
    80004862:	8552                	mv	a0,s4
    80004864:	00000097          	auipc	ra,0x0
    80004868:	bd2080e7          	jalr	-1070(ra) # 80004436 <iunlockput>
    ip = next;
    8000486c:	8a4e                	mv	s4,s3
  while(*path == '/')
    8000486e:	0004c783          	lbu	a5,0(s1)
    80004872:	01279763          	bne	a5,s2,80004880 <namex+0x118>
    path++;
    80004876:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004878:	0004c783          	lbu	a5,0(s1)
    8000487c:	ff278de3          	beq	a5,s2,80004876 <namex+0x10e>
  if(*path == 0)
    80004880:	cb9d                	beqz	a5,800048b6 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80004882:	0004c783          	lbu	a5,0(s1)
    80004886:	89a6                	mv	s3,s1
  len = path - s;
    80004888:	4c81                	li	s9,0
    8000488a:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    8000488c:	01278963          	beq	a5,s2,8000489e <namex+0x136>
    80004890:	dbbd                	beqz	a5,80004806 <namex+0x9e>
    path++;
    80004892:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80004894:	0009c783          	lbu	a5,0(s3)
    80004898:	ff279ce3          	bne	a5,s2,80004890 <namex+0x128>
    8000489c:	b7ad                	j	80004806 <namex+0x9e>
    memmove(name, s, len);
    8000489e:	2601                	sext.w	a2,a2
    800048a0:	85a6                	mv	a1,s1
    800048a2:	8556                	mv	a0,s5
    800048a4:	ffffc097          	auipc	ra,0xffffc
    800048a8:	620080e7          	jalr	1568(ra) # 80000ec4 <memmove>
    name[len] = 0;
    800048ac:	9cd6                	add	s9,s9,s5
    800048ae:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800048b2:	84ce                	mv	s1,s3
    800048b4:	b7bd                	j	80004822 <namex+0xba>
  if(nameiparent){
    800048b6:	f00b0de3          	beqz	s6,800047d0 <namex+0x68>
    iput(ip);
    800048ba:	8552                	mv	a0,s4
    800048bc:	00000097          	auipc	ra,0x0
    800048c0:	ad2080e7          	jalr	-1326(ra) # 8000438e <iput>
    return 0;
    800048c4:	4a01                	li	s4,0
    800048c6:	b729                	j	800047d0 <namex+0x68>

00000000800048c8 <dirlink>:
{
    800048c8:	7139                	addi	sp,sp,-64
    800048ca:	fc06                	sd	ra,56(sp)
    800048cc:	f822                	sd	s0,48(sp)
    800048ce:	f426                	sd	s1,40(sp)
    800048d0:	f04a                	sd	s2,32(sp)
    800048d2:	ec4e                	sd	s3,24(sp)
    800048d4:	e852                	sd	s4,16(sp)
    800048d6:	0080                	addi	s0,sp,64
    800048d8:	892a                	mv	s2,a0
    800048da:	8a2e                	mv	s4,a1
    800048dc:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800048de:	4601                	li	a2,0
    800048e0:	00000097          	auipc	ra,0x0
    800048e4:	dd8080e7          	jalr	-552(ra) # 800046b8 <dirlookup>
    800048e8:	e93d                	bnez	a0,8000495e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800048ea:	04c92483          	lw	s1,76(s2)
    800048ee:	c49d                	beqz	s1,8000491c <dirlink+0x54>
    800048f0:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800048f2:	4741                	li	a4,16
    800048f4:	86a6                	mv	a3,s1
    800048f6:	fc040613          	addi	a2,s0,-64
    800048fa:	4581                	li	a1,0
    800048fc:	854a                	mv	a0,s2
    800048fe:	00000097          	auipc	ra,0x0
    80004902:	b8a080e7          	jalr	-1142(ra) # 80004488 <readi>
    80004906:	47c1                	li	a5,16
    80004908:	06f51163          	bne	a0,a5,8000496a <dirlink+0xa2>
    if(de.inum == 0)
    8000490c:	fc045783          	lhu	a5,-64(s0)
    80004910:	c791                	beqz	a5,8000491c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004912:	24c1                	addiw	s1,s1,16
    80004914:	04c92783          	lw	a5,76(s2)
    80004918:	fcf4ede3          	bltu	s1,a5,800048f2 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000491c:	4639                	li	a2,14
    8000491e:	85d2                	mv	a1,s4
    80004920:	fc240513          	addi	a0,s0,-62
    80004924:	ffffc097          	auipc	ra,0xffffc
    80004928:	650080e7          	jalr	1616(ra) # 80000f74 <strncpy>
  de.inum = inum;
    8000492c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004930:	4741                	li	a4,16
    80004932:	86a6                	mv	a3,s1
    80004934:	fc040613          	addi	a2,s0,-64
    80004938:	4581                	li	a1,0
    8000493a:	854a                	mv	a0,s2
    8000493c:	00000097          	auipc	ra,0x0
    80004940:	c44080e7          	jalr	-956(ra) # 80004580 <writei>
    80004944:	1541                	addi	a0,a0,-16
    80004946:	00a03533          	snez	a0,a0
    8000494a:	40a00533          	neg	a0,a0
}
    8000494e:	70e2                	ld	ra,56(sp)
    80004950:	7442                	ld	s0,48(sp)
    80004952:	74a2                	ld	s1,40(sp)
    80004954:	7902                	ld	s2,32(sp)
    80004956:	69e2                	ld	s3,24(sp)
    80004958:	6a42                	ld	s4,16(sp)
    8000495a:	6121                	addi	sp,sp,64
    8000495c:	8082                	ret
    iput(ip);
    8000495e:	00000097          	auipc	ra,0x0
    80004962:	a30080e7          	jalr	-1488(ra) # 8000438e <iput>
    return -1;
    80004966:	557d                	li	a0,-1
    80004968:	b7dd                	j	8000494e <dirlink+0x86>
      panic("dirlink read");
    8000496a:	00004517          	auipc	a0,0x4
    8000496e:	f6650513          	addi	a0,a0,-154 # 800088d0 <syscall_names+0x1f8>
    80004972:	ffffc097          	auipc	ra,0xffffc
    80004976:	bca080e7          	jalr	-1078(ra) # 8000053c <panic>

000000008000497a <namei>:

struct inode*
namei(char *path)
{
    8000497a:	1101                	addi	sp,sp,-32
    8000497c:	ec06                	sd	ra,24(sp)
    8000497e:	e822                	sd	s0,16(sp)
    80004980:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004982:	fe040613          	addi	a2,s0,-32
    80004986:	4581                	li	a1,0
    80004988:	00000097          	auipc	ra,0x0
    8000498c:	de0080e7          	jalr	-544(ra) # 80004768 <namex>
}
    80004990:	60e2                	ld	ra,24(sp)
    80004992:	6442                	ld	s0,16(sp)
    80004994:	6105                	addi	sp,sp,32
    80004996:	8082                	ret

0000000080004998 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004998:	1141                	addi	sp,sp,-16
    8000499a:	e406                	sd	ra,8(sp)
    8000499c:	e022                	sd	s0,0(sp)
    8000499e:	0800                	addi	s0,sp,16
    800049a0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800049a2:	4585                	li	a1,1
    800049a4:	00000097          	auipc	ra,0x0
    800049a8:	dc4080e7          	jalr	-572(ra) # 80004768 <namex>
}
    800049ac:	60a2                	ld	ra,8(sp)
    800049ae:	6402                	ld	s0,0(sp)
    800049b0:	0141                	addi	sp,sp,16
    800049b2:	8082                	ret

00000000800049b4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800049b4:	1101                	addi	sp,sp,-32
    800049b6:	ec06                	sd	ra,24(sp)
    800049b8:	e822                	sd	s0,16(sp)
    800049ba:	e426                	sd	s1,8(sp)
    800049bc:	e04a                	sd	s2,0(sp)
    800049be:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800049c0:	0004b917          	auipc	s2,0x4b
    800049c4:	c1090913          	addi	s2,s2,-1008 # 8004f5d0 <log>
    800049c8:	01892583          	lw	a1,24(s2)
    800049cc:	02892503          	lw	a0,40(s2)
    800049d0:	fffff097          	auipc	ra,0xfffff
    800049d4:	ff4080e7          	jalr	-12(ra) # 800039c4 <bread>
    800049d8:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800049da:	02c92603          	lw	a2,44(s2)
    800049de:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800049e0:	00c05f63          	blez	a2,800049fe <write_head+0x4a>
    800049e4:	0004b717          	auipc	a4,0x4b
    800049e8:	c1c70713          	addi	a4,a4,-996 # 8004f600 <log+0x30>
    800049ec:	87aa                	mv	a5,a0
    800049ee:	060a                	slli	a2,a2,0x2
    800049f0:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800049f2:	4314                	lw	a3,0(a4)
    800049f4:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800049f6:	0711                	addi	a4,a4,4
    800049f8:	0791                	addi	a5,a5,4
    800049fa:	fec79ce3          	bne	a5,a2,800049f2 <write_head+0x3e>
  }
  bwrite(buf);
    800049fe:	8526                	mv	a0,s1
    80004a00:	fffff097          	auipc	ra,0xfffff
    80004a04:	0b6080e7          	jalr	182(ra) # 80003ab6 <bwrite>
  brelse(buf);
    80004a08:	8526                	mv	a0,s1
    80004a0a:	fffff097          	auipc	ra,0xfffff
    80004a0e:	0ea080e7          	jalr	234(ra) # 80003af4 <brelse>
}
    80004a12:	60e2                	ld	ra,24(sp)
    80004a14:	6442                	ld	s0,16(sp)
    80004a16:	64a2                	ld	s1,8(sp)
    80004a18:	6902                	ld	s2,0(sp)
    80004a1a:	6105                	addi	sp,sp,32
    80004a1c:	8082                	ret

0000000080004a1e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a1e:	0004b797          	auipc	a5,0x4b
    80004a22:	bde7a783          	lw	a5,-1058(a5) # 8004f5fc <log+0x2c>
    80004a26:	0af05d63          	blez	a5,80004ae0 <install_trans+0xc2>
{
    80004a2a:	7139                	addi	sp,sp,-64
    80004a2c:	fc06                	sd	ra,56(sp)
    80004a2e:	f822                	sd	s0,48(sp)
    80004a30:	f426                	sd	s1,40(sp)
    80004a32:	f04a                	sd	s2,32(sp)
    80004a34:	ec4e                	sd	s3,24(sp)
    80004a36:	e852                	sd	s4,16(sp)
    80004a38:	e456                	sd	s5,8(sp)
    80004a3a:	e05a                	sd	s6,0(sp)
    80004a3c:	0080                	addi	s0,sp,64
    80004a3e:	8b2a                	mv	s6,a0
    80004a40:	0004ba97          	auipc	s5,0x4b
    80004a44:	bc0a8a93          	addi	s5,s5,-1088 # 8004f600 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a48:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004a4a:	0004b997          	auipc	s3,0x4b
    80004a4e:	b8698993          	addi	s3,s3,-1146 # 8004f5d0 <log>
    80004a52:	a00d                	j	80004a74 <install_trans+0x56>
    brelse(lbuf);
    80004a54:	854a                	mv	a0,s2
    80004a56:	fffff097          	auipc	ra,0xfffff
    80004a5a:	09e080e7          	jalr	158(ra) # 80003af4 <brelse>
    brelse(dbuf);
    80004a5e:	8526                	mv	a0,s1
    80004a60:	fffff097          	auipc	ra,0xfffff
    80004a64:	094080e7          	jalr	148(ra) # 80003af4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a68:	2a05                	addiw	s4,s4,1
    80004a6a:	0a91                	addi	s5,s5,4
    80004a6c:	02c9a783          	lw	a5,44(s3)
    80004a70:	04fa5e63          	bge	s4,a5,80004acc <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004a74:	0189a583          	lw	a1,24(s3)
    80004a78:	014585bb          	addw	a1,a1,s4
    80004a7c:	2585                	addiw	a1,a1,1
    80004a7e:	0289a503          	lw	a0,40(s3)
    80004a82:	fffff097          	auipc	ra,0xfffff
    80004a86:	f42080e7          	jalr	-190(ra) # 800039c4 <bread>
    80004a8a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004a8c:	000aa583          	lw	a1,0(s5)
    80004a90:	0289a503          	lw	a0,40(s3)
    80004a94:	fffff097          	auipc	ra,0xfffff
    80004a98:	f30080e7          	jalr	-208(ra) # 800039c4 <bread>
    80004a9c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004a9e:	40000613          	li	a2,1024
    80004aa2:	05890593          	addi	a1,s2,88
    80004aa6:	05850513          	addi	a0,a0,88
    80004aaa:	ffffc097          	auipc	ra,0xffffc
    80004aae:	41a080e7          	jalr	1050(ra) # 80000ec4 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004ab2:	8526                	mv	a0,s1
    80004ab4:	fffff097          	auipc	ra,0xfffff
    80004ab8:	002080e7          	jalr	2(ra) # 80003ab6 <bwrite>
    if(recovering == 0)
    80004abc:	f80b1ce3          	bnez	s6,80004a54 <install_trans+0x36>
      bunpin(dbuf);
    80004ac0:	8526                	mv	a0,s1
    80004ac2:	fffff097          	auipc	ra,0xfffff
    80004ac6:	10a080e7          	jalr	266(ra) # 80003bcc <bunpin>
    80004aca:	b769                	j	80004a54 <install_trans+0x36>
}
    80004acc:	70e2                	ld	ra,56(sp)
    80004ace:	7442                	ld	s0,48(sp)
    80004ad0:	74a2                	ld	s1,40(sp)
    80004ad2:	7902                	ld	s2,32(sp)
    80004ad4:	69e2                	ld	s3,24(sp)
    80004ad6:	6a42                	ld	s4,16(sp)
    80004ad8:	6aa2                	ld	s5,8(sp)
    80004ada:	6b02                	ld	s6,0(sp)
    80004adc:	6121                	addi	sp,sp,64
    80004ade:	8082                	ret
    80004ae0:	8082                	ret

0000000080004ae2 <initlog>:
{
    80004ae2:	7179                	addi	sp,sp,-48
    80004ae4:	f406                	sd	ra,40(sp)
    80004ae6:	f022                	sd	s0,32(sp)
    80004ae8:	ec26                	sd	s1,24(sp)
    80004aea:	e84a                	sd	s2,16(sp)
    80004aec:	e44e                	sd	s3,8(sp)
    80004aee:	1800                	addi	s0,sp,48
    80004af0:	892a                	mv	s2,a0
    80004af2:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004af4:	0004b497          	auipc	s1,0x4b
    80004af8:	adc48493          	addi	s1,s1,-1316 # 8004f5d0 <log>
    80004afc:	00004597          	auipc	a1,0x4
    80004b00:	de458593          	addi	a1,a1,-540 # 800088e0 <syscall_names+0x208>
    80004b04:	8526                	mv	a0,s1
    80004b06:	ffffc097          	auipc	ra,0xffffc
    80004b0a:	1d6080e7          	jalr	470(ra) # 80000cdc <initlock>
  log.start = sb->logstart;
    80004b0e:	0149a583          	lw	a1,20(s3)
    80004b12:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004b14:	0109a783          	lw	a5,16(s3)
    80004b18:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004b1a:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004b1e:	854a                	mv	a0,s2
    80004b20:	fffff097          	auipc	ra,0xfffff
    80004b24:	ea4080e7          	jalr	-348(ra) # 800039c4 <bread>
  log.lh.n = lh->n;
    80004b28:	4d30                	lw	a2,88(a0)
    80004b2a:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004b2c:	00c05f63          	blez	a2,80004b4a <initlog+0x68>
    80004b30:	87aa                	mv	a5,a0
    80004b32:	0004b717          	auipc	a4,0x4b
    80004b36:	ace70713          	addi	a4,a4,-1330 # 8004f600 <log+0x30>
    80004b3a:	060a                	slli	a2,a2,0x2
    80004b3c:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004b3e:	4ff4                	lw	a3,92(a5)
    80004b40:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004b42:	0791                	addi	a5,a5,4
    80004b44:	0711                	addi	a4,a4,4
    80004b46:	fec79ce3          	bne	a5,a2,80004b3e <initlog+0x5c>
  brelse(buf);
    80004b4a:	fffff097          	auipc	ra,0xfffff
    80004b4e:	faa080e7          	jalr	-86(ra) # 80003af4 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004b52:	4505                	li	a0,1
    80004b54:	00000097          	auipc	ra,0x0
    80004b58:	eca080e7          	jalr	-310(ra) # 80004a1e <install_trans>
  log.lh.n = 0;
    80004b5c:	0004b797          	auipc	a5,0x4b
    80004b60:	aa07a023          	sw	zero,-1376(a5) # 8004f5fc <log+0x2c>
  write_head(); // clear the log
    80004b64:	00000097          	auipc	ra,0x0
    80004b68:	e50080e7          	jalr	-432(ra) # 800049b4 <write_head>
}
    80004b6c:	70a2                	ld	ra,40(sp)
    80004b6e:	7402                	ld	s0,32(sp)
    80004b70:	64e2                	ld	s1,24(sp)
    80004b72:	6942                	ld	s2,16(sp)
    80004b74:	69a2                	ld	s3,8(sp)
    80004b76:	6145                	addi	sp,sp,48
    80004b78:	8082                	ret

0000000080004b7a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004b7a:	1101                	addi	sp,sp,-32
    80004b7c:	ec06                	sd	ra,24(sp)
    80004b7e:	e822                	sd	s0,16(sp)
    80004b80:	e426                	sd	s1,8(sp)
    80004b82:	e04a                	sd	s2,0(sp)
    80004b84:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004b86:	0004b517          	auipc	a0,0x4b
    80004b8a:	a4a50513          	addi	a0,a0,-1462 # 8004f5d0 <log>
    80004b8e:	ffffc097          	auipc	ra,0xffffc
    80004b92:	1de080e7          	jalr	478(ra) # 80000d6c <acquire>
  while(1){
    if(log.committing){
    80004b96:	0004b497          	auipc	s1,0x4b
    80004b9a:	a3a48493          	addi	s1,s1,-1478 # 8004f5d0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004b9e:	4979                	li	s2,30
    80004ba0:	a039                	j	80004bae <begin_op+0x34>
      sleep(&log, &log.lock);
    80004ba2:	85a6                	mv	a1,s1
    80004ba4:	8526                	mv	a0,s1
    80004ba6:	ffffe097          	auipc	ra,0xffffe
    80004baa:	964080e7          	jalr	-1692(ra) # 8000250a <sleep>
    if(log.committing){
    80004bae:	50dc                	lw	a5,36(s1)
    80004bb0:	fbed                	bnez	a5,80004ba2 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004bb2:	5098                	lw	a4,32(s1)
    80004bb4:	2705                	addiw	a4,a4,1
    80004bb6:	0027179b          	slliw	a5,a4,0x2
    80004bba:	9fb9                	addw	a5,a5,a4
    80004bbc:	0017979b          	slliw	a5,a5,0x1
    80004bc0:	54d4                	lw	a3,44(s1)
    80004bc2:	9fb5                	addw	a5,a5,a3
    80004bc4:	00f95963          	bge	s2,a5,80004bd6 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004bc8:	85a6                	mv	a1,s1
    80004bca:	8526                	mv	a0,s1
    80004bcc:	ffffe097          	auipc	ra,0xffffe
    80004bd0:	93e080e7          	jalr	-1730(ra) # 8000250a <sleep>
    80004bd4:	bfe9                	j	80004bae <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004bd6:	0004b517          	auipc	a0,0x4b
    80004bda:	9fa50513          	addi	a0,a0,-1542 # 8004f5d0 <log>
    80004bde:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004be0:	ffffc097          	auipc	ra,0xffffc
    80004be4:	240080e7          	jalr	576(ra) # 80000e20 <release>
      break;
    }
  }
}
    80004be8:	60e2                	ld	ra,24(sp)
    80004bea:	6442                	ld	s0,16(sp)
    80004bec:	64a2                	ld	s1,8(sp)
    80004bee:	6902                	ld	s2,0(sp)
    80004bf0:	6105                	addi	sp,sp,32
    80004bf2:	8082                	ret

0000000080004bf4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004bf4:	7139                	addi	sp,sp,-64
    80004bf6:	fc06                	sd	ra,56(sp)
    80004bf8:	f822                	sd	s0,48(sp)
    80004bfa:	f426                	sd	s1,40(sp)
    80004bfc:	f04a                	sd	s2,32(sp)
    80004bfe:	ec4e                	sd	s3,24(sp)
    80004c00:	e852                	sd	s4,16(sp)
    80004c02:	e456                	sd	s5,8(sp)
    80004c04:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004c06:	0004b497          	auipc	s1,0x4b
    80004c0a:	9ca48493          	addi	s1,s1,-1590 # 8004f5d0 <log>
    80004c0e:	8526                	mv	a0,s1
    80004c10:	ffffc097          	auipc	ra,0xffffc
    80004c14:	15c080e7          	jalr	348(ra) # 80000d6c <acquire>
  log.outstanding -= 1;
    80004c18:	509c                	lw	a5,32(s1)
    80004c1a:	37fd                	addiw	a5,a5,-1
    80004c1c:	0007891b          	sext.w	s2,a5
    80004c20:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004c22:	50dc                	lw	a5,36(s1)
    80004c24:	e7b9                	bnez	a5,80004c72 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004c26:	04091e63          	bnez	s2,80004c82 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004c2a:	0004b497          	auipc	s1,0x4b
    80004c2e:	9a648493          	addi	s1,s1,-1626 # 8004f5d0 <log>
    80004c32:	4785                	li	a5,1
    80004c34:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004c36:	8526                	mv	a0,s1
    80004c38:	ffffc097          	auipc	ra,0xffffc
    80004c3c:	1e8080e7          	jalr	488(ra) # 80000e20 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004c40:	54dc                	lw	a5,44(s1)
    80004c42:	06f04763          	bgtz	a5,80004cb0 <end_op+0xbc>
    acquire(&log.lock);
    80004c46:	0004b497          	auipc	s1,0x4b
    80004c4a:	98a48493          	addi	s1,s1,-1654 # 8004f5d0 <log>
    80004c4e:	8526                	mv	a0,s1
    80004c50:	ffffc097          	auipc	ra,0xffffc
    80004c54:	11c080e7          	jalr	284(ra) # 80000d6c <acquire>
    log.committing = 0;
    80004c58:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004c5c:	8526                	mv	a0,s1
    80004c5e:	ffffe097          	auipc	ra,0xffffe
    80004c62:	a5c080e7          	jalr	-1444(ra) # 800026ba <wakeup>
    release(&log.lock);
    80004c66:	8526                	mv	a0,s1
    80004c68:	ffffc097          	auipc	ra,0xffffc
    80004c6c:	1b8080e7          	jalr	440(ra) # 80000e20 <release>
}
    80004c70:	a03d                	j	80004c9e <end_op+0xaa>
    panic("log.committing");
    80004c72:	00004517          	auipc	a0,0x4
    80004c76:	c7650513          	addi	a0,a0,-906 # 800088e8 <syscall_names+0x210>
    80004c7a:	ffffc097          	auipc	ra,0xffffc
    80004c7e:	8c2080e7          	jalr	-1854(ra) # 8000053c <panic>
    wakeup(&log);
    80004c82:	0004b497          	auipc	s1,0x4b
    80004c86:	94e48493          	addi	s1,s1,-1714 # 8004f5d0 <log>
    80004c8a:	8526                	mv	a0,s1
    80004c8c:	ffffe097          	auipc	ra,0xffffe
    80004c90:	a2e080e7          	jalr	-1490(ra) # 800026ba <wakeup>
  release(&log.lock);
    80004c94:	8526                	mv	a0,s1
    80004c96:	ffffc097          	auipc	ra,0xffffc
    80004c9a:	18a080e7          	jalr	394(ra) # 80000e20 <release>
}
    80004c9e:	70e2                	ld	ra,56(sp)
    80004ca0:	7442                	ld	s0,48(sp)
    80004ca2:	74a2                	ld	s1,40(sp)
    80004ca4:	7902                	ld	s2,32(sp)
    80004ca6:	69e2                	ld	s3,24(sp)
    80004ca8:	6a42                	ld	s4,16(sp)
    80004caa:	6aa2                	ld	s5,8(sp)
    80004cac:	6121                	addi	sp,sp,64
    80004cae:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004cb0:	0004ba97          	auipc	s5,0x4b
    80004cb4:	950a8a93          	addi	s5,s5,-1712 # 8004f600 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004cb8:	0004ba17          	auipc	s4,0x4b
    80004cbc:	918a0a13          	addi	s4,s4,-1768 # 8004f5d0 <log>
    80004cc0:	018a2583          	lw	a1,24(s4)
    80004cc4:	012585bb          	addw	a1,a1,s2
    80004cc8:	2585                	addiw	a1,a1,1
    80004cca:	028a2503          	lw	a0,40(s4)
    80004cce:	fffff097          	auipc	ra,0xfffff
    80004cd2:	cf6080e7          	jalr	-778(ra) # 800039c4 <bread>
    80004cd6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004cd8:	000aa583          	lw	a1,0(s5)
    80004cdc:	028a2503          	lw	a0,40(s4)
    80004ce0:	fffff097          	auipc	ra,0xfffff
    80004ce4:	ce4080e7          	jalr	-796(ra) # 800039c4 <bread>
    80004ce8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004cea:	40000613          	li	a2,1024
    80004cee:	05850593          	addi	a1,a0,88
    80004cf2:	05848513          	addi	a0,s1,88
    80004cf6:	ffffc097          	auipc	ra,0xffffc
    80004cfa:	1ce080e7          	jalr	462(ra) # 80000ec4 <memmove>
    bwrite(to);  // write the log
    80004cfe:	8526                	mv	a0,s1
    80004d00:	fffff097          	auipc	ra,0xfffff
    80004d04:	db6080e7          	jalr	-586(ra) # 80003ab6 <bwrite>
    brelse(from);
    80004d08:	854e                	mv	a0,s3
    80004d0a:	fffff097          	auipc	ra,0xfffff
    80004d0e:	dea080e7          	jalr	-534(ra) # 80003af4 <brelse>
    brelse(to);
    80004d12:	8526                	mv	a0,s1
    80004d14:	fffff097          	auipc	ra,0xfffff
    80004d18:	de0080e7          	jalr	-544(ra) # 80003af4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004d1c:	2905                	addiw	s2,s2,1
    80004d1e:	0a91                	addi	s5,s5,4
    80004d20:	02ca2783          	lw	a5,44(s4)
    80004d24:	f8f94ee3          	blt	s2,a5,80004cc0 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004d28:	00000097          	auipc	ra,0x0
    80004d2c:	c8c080e7          	jalr	-884(ra) # 800049b4 <write_head>
    install_trans(0); // Now install writes to home locations
    80004d30:	4501                	li	a0,0
    80004d32:	00000097          	auipc	ra,0x0
    80004d36:	cec080e7          	jalr	-788(ra) # 80004a1e <install_trans>
    log.lh.n = 0;
    80004d3a:	0004b797          	auipc	a5,0x4b
    80004d3e:	8c07a123          	sw	zero,-1854(a5) # 8004f5fc <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004d42:	00000097          	auipc	ra,0x0
    80004d46:	c72080e7          	jalr	-910(ra) # 800049b4 <write_head>
    80004d4a:	bdf5                	j	80004c46 <end_op+0x52>

0000000080004d4c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004d4c:	1101                	addi	sp,sp,-32
    80004d4e:	ec06                	sd	ra,24(sp)
    80004d50:	e822                	sd	s0,16(sp)
    80004d52:	e426                	sd	s1,8(sp)
    80004d54:	e04a                	sd	s2,0(sp)
    80004d56:	1000                	addi	s0,sp,32
    80004d58:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004d5a:	0004b917          	auipc	s2,0x4b
    80004d5e:	87690913          	addi	s2,s2,-1930 # 8004f5d0 <log>
    80004d62:	854a                	mv	a0,s2
    80004d64:	ffffc097          	auipc	ra,0xffffc
    80004d68:	008080e7          	jalr	8(ra) # 80000d6c <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004d6c:	02c92603          	lw	a2,44(s2)
    80004d70:	47f5                	li	a5,29
    80004d72:	06c7c563          	blt	a5,a2,80004ddc <log_write+0x90>
    80004d76:	0004b797          	auipc	a5,0x4b
    80004d7a:	8767a783          	lw	a5,-1930(a5) # 8004f5ec <log+0x1c>
    80004d7e:	37fd                	addiw	a5,a5,-1
    80004d80:	04f65e63          	bge	a2,a5,80004ddc <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004d84:	0004b797          	auipc	a5,0x4b
    80004d88:	86c7a783          	lw	a5,-1940(a5) # 8004f5f0 <log+0x20>
    80004d8c:	06f05063          	blez	a5,80004dec <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004d90:	4781                	li	a5,0
    80004d92:	06c05563          	blez	a2,80004dfc <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004d96:	44cc                	lw	a1,12(s1)
    80004d98:	0004b717          	auipc	a4,0x4b
    80004d9c:	86870713          	addi	a4,a4,-1944 # 8004f600 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004da0:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004da2:	4314                	lw	a3,0(a4)
    80004da4:	04b68c63          	beq	a3,a1,80004dfc <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004da8:	2785                	addiw	a5,a5,1
    80004daa:	0711                	addi	a4,a4,4
    80004dac:	fef61be3          	bne	a2,a5,80004da2 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004db0:	0621                	addi	a2,a2,8
    80004db2:	060a                	slli	a2,a2,0x2
    80004db4:	0004b797          	auipc	a5,0x4b
    80004db8:	81c78793          	addi	a5,a5,-2020 # 8004f5d0 <log>
    80004dbc:	97b2                	add	a5,a5,a2
    80004dbe:	44d8                	lw	a4,12(s1)
    80004dc0:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004dc2:	8526                	mv	a0,s1
    80004dc4:	fffff097          	auipc	ra,0xfffff
    80004dc8:	dcc080e7          	jalr	-564(ra) # 80003b90 <bpin>
    log.lh.n++;
    80004dcc:	0004b717          	auipc	a4,0x4b
    80004dd0:	80470713          	addi	a4,a4,-2044 # 8004f5d0 <log>
    80004dd4:	575c                	lw	a5,44(a4)
    80004dd6:	2785                	addiw	a5,a5,1
    80004dd8:	d75c                	sw	a5,44(a4)
    80004dda:	a82d                	j	80004e14 <log_write+0xc8>
    panic("too big a transaction");
    80004ddc:	00004517          	auipc	a0,0x4
    80004de0:	b1c50513          	addi	a0,a0,-1252 # 800088f8 <syscall_names+0x220>
    80004de4:	ffffb097          	auipc	ra,0xffffb
    80004de8:	758080e7          	jalr	1880(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    80004dec:	00004517          	auipc	a0,0x4
    80004df0:	b2450513          	addi	a0,a0,-1244 # 80008910 <syscall_names+0x238>
    80004df4:	ffffb097          	auipc	ra,0xffffb
    80004df8:	748080e7          	jalr	1864(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    80004dfc:	00878693          	addi	a3,a5,8
    80004e00:	068a                	slli	a3,a3,0x2
    80004e02:	0004a717          	auipc	a4,0x4a
    80004e06:	7ce70713          	addi	a4,a4,1998 # 8004f5d0 <log>
    80004e0a:	9736                	add	a4,a4,a3
    80004e0c:	44d4                	lw	a3,12(s1)
    80004e0e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004e10:	faf609e3          	beq	a2,a5,80004dc2 <log_write+0x76>
  }
  release(&log.lock);
    80004e14:	0004a517          	auipc	a0,0x4a
    80004e18:	7bc50513          	addi	a0,a0,1980 # 8004f5d0 <log>
    80004e1c:	ffffc097          	auipc	ra,0xffffc
    80004e20:	004080e7          	jalr	4(ra) # 80000e20 <release>
}
    80004e24:	60e2                	ld	ra,24(sp)
    80004e26:	6442                	ld	s0,16(sp)
    80004e28:	64a2                	ld	s1,8(sp)
    80004e2a:	6902                	ld	s2,0(sp)
    80004e2c:	6105                	addi	sp,sp,32
    80004e2e:	8082                	ret

0000000080004e30 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004e30:	1101                	addi	sp,sp,-32
    80004e32:	ec06                	sd	ra,24(sp)
    80004e34:	e822                	sd	s0,16(sp)
    80004e36:	e426                	sd	s1,8(sp)
    80004e38:	e04a                	sd	s2,0(sp)
    80004e3a:	1000                	addi	s0,sp,32
    80004e3c:	84aa                	mv	s1,a0
    80004e3e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004e40:	00004597          	auipc	a1,0x4
    80004e44:	af058593          	addi	a1,a1,-1296 # 80008930 <syscall_names+0x258>
    80004e48:	0521                	addi	a0,a0,8
    80004e4a:	ffffc097          	auipc	ra,0xffffc
    80004e4e:	e92080e7          	jalr	-366(ra) # 80000cdc <initlock>
  lk->name = name;
    80004e52:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004e56:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004e5a:	0204a423          	sw	zero,40(s1)
}
    80004e5e:	60e2                	ld	ra,24(sp)
    80004e60:	6442                	ld	s0,16(sp)
    80004e62:	64a2                	ld	s1,8(sp)
    80004e64:	6902                	ld	s2,0(sp)
    80004e66:	6105                	addi	sp,sp,32
    80004e68:	8082                	ret

0000000080004e6a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004e6a:	1101                	addi	sp,sp,-32
    80004e6c:	ec06                	sd	ra,24(sp)
    80004e6e:	e822                	sd	s0,16(sp)
    80004e70:	e426                	sd	s1,8(sp)
    80004e72:	e04a                	sd	s2,0(sp)
    80004e74:	1000                	addi	s0,sp,32
    80004e76:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004e78:	00850913          	addi	s2,a0,8
    80004e7c:	854a                	mv	a0,s2
    80004e7e:	ffffc097          	auipc	ra,0xffffc
    80004e82:	eee080e7          	jalr	-274(ra) # 80000d6c <acquire>
  while (lk->locked) {
    80004e86:	409c                	lw	a5,0(s1)
    80004e88:	cb89                	beqz	a5,80004e9a <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004e8a:	85ca                	mv	a1,s2
    80004e8c:	8526                	mv	a0,s1
    80004e8e:	ffffd097          	auipc	ra,0xffffd
    80004e92:	67c080e7          	jalr	1660(ra) # 8000250a <sleep>
  while (lk->locked) {
    80004e96:	409c                	lw	a5,0(s1)
    80004e98:	fbed                	bnez	a5,80004e8a <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004e9a:	4785                	li	a5,1
    80004e9c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004e9e:	ffffd097          	auipc	ra,0xffffd
    80004ea2:	d2c080e7          	jalr	-724(ra) # 80001bca <myproc>
    80004ea6:	591c                	lw	a5,48(a0)
    80004ea8:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004eaa:	854a                	mv	a0,s2
    80004eac:	ffffc097          	auipc	ra,0xffffc
    80004eb0:	f74080e7          	jalr	-140(ra) # 80000e20 <release>
}
    80004eb4:	60e2                	ld	ra,24(sp)
    80004eb6:	6442                	ld	s0,16(sp)
    80004eb8:	64a2                	ld	s1,8(sp)
    80004eba:	6902                	ld	s2,0(sp)
    80004ebc:	6105                	addi	sp,sp,32
    80004ebe:	8082                	ret

0000000080004ec0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004ec0:	1101                	addi	sp,sp,-32
    80004ec2:	ec06                	sd	ra,24(sp)
    80004ec4:	e822                	sd	s0,16(sp)
    80004ec6:	e426                	sd	s1,8(sp)
    80004ec8:	e04a                	sd	s2,0(sp)
    80004eca:	1000                	addi	s0,sp,32
    80004ecc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004ece:	00850913          	addi	s2,a0,8
    80004ed2:	854a                	mv	a0,s2
    80004ed4:	ffffc097          	auipc	ra,0xffffc
    80004ed8:	e98080e7          	jalr	-360(ra) # 80000d6c <acquire>
  lk->locked = 0;
    80004edc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004ee0:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004ee4:	8526                	mv	a0,s1
    80004ee6:	ffffd097          	auipc	ra,0xffffd
    80004eea:	7d4080e7          	jalr	2004(ra) # 800026ba <wakeup>
  release(&lk->lk);
    80004eee:	854a                	mv	a0,s2
    80004ef0:	ffffc097          	auipc	ra,0xffffc
    80004ef4:	f30080e7          	jalr	-208(ra) # 80000e20 <release>
}
    80004ef8:	60e2                	ld	ra,24(sp)
    80004efa:	6442                	ld	s0,16(sp)
    80004efc:	64a2                	ld	s1,8(sp)
    80004efe:	6902                	ld	s2,0(sp)
    80004f00:	6105                	addi	sp,sp,32
    80004f02:	8082                	ret

0000000080004f04 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004f04:	7179                	addi	sp,sp,-48
    80004f06:	f406                	sd	ra,40(sp)
    80004f08:	f022                	sd	s0,32(sp)
    80004f0a:	ec26                	sd	s1,24(sp)
    80004f0c:	e84a                	sd	s2,16(sp)
    80004f0e:	e44e                	sd	s3,8(sp)
    80004f10:	1800                	addi	s0,sp,48
    80004f12:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004f14:	00850913          	addi	s2,a0,8
    80004f18:	854a                	mv	a0,s2
    80004f1a:	ffffc097          	auipc	ra,0xffffc
    80004f1e:	e52080e7          	jalr	-430(ra) # 80000d6c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004f22:	409c                	lw	a5,0(s1)
    80004f24:	ef99                	bnez	a5,80004f42 <holdingsleep+0x3e>
    80004f26:	4481                	li	s1,0
  release(&lk->lk);
    80004f28:	854a                	mv	a0,s2
    80004f2a:	ffffc097          	auipc	ra,0xffffc
    80004f2e:	ef6080e7          	jalr	-266(ra) # 80000e20 <release>
  return r;
}
    80004f32:	8526                	mv	a0,s1
    80004f34:	70a2                	ld	ra,40(sp)
    80004f36:	7402                	ld	s0,32(sp)
    80004f38:	64e2                	ld	s1,24(sp)
    80004f3a:	6942                	ld	s2,16(sp)
    80004f3c:	69a2                	ld	s3,8(sp)
    80004f3e:	6145                	addi	sp,sp,48
    80004f40:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004f42:	0284a983          	lw	s3,40(s1)
    80004f46:	ffffd097          	auipc	ra,0xffffd
    80004f4a:	c84080e7          	jalr	-892(ra) # 80001bca <myproc>
    80004f4e:	5904                	lw	s1,48(a0)
    80004f50:	413484b3          	sub	s1,s1,s3
    80004f54:	0014b493          	seqz	s1,s1
    80004f58:	bfc1                	j	80004f28 <holdingsleep+0x24>

0000000080004f5a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004f5a:	1141                	addi	sp,sp,-16
    80004f5c:	e406                	sd	ra,8(sp)
    80004f5e:	e022                	sd	s0,0(sp)
    80004f60:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004f62:	00004597          	auipc	a1,0x4
    80004f66:	9de58593          	addi	a1,a1,-1570 # 80008940 <syscall_names+0x268>
    80004f6a:	0004a517          	auipc	a0,0x4a
    80004f6e:	7ae50513          	addi	a0,a0,1966 # 8004f718 <ftable>
    80004f72:	ffffc097          	auipc	ra,0xffffc
    80004f76:	d6a080e7          	jalr	-662(ra) # 80000cdc <initlock>
}
    80004f7a:	60a2                	ld	ra,8(sp)
    80004f7c:	6402                	ld	s0,0(sp)
    80004f7e:	0141                	addi	sp,sp,16
    80004f80:	8082                	ret

0000000080004f82 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004f82:	1101                	addi	sp,sp,-32
    80004f84:	ec06                	sd	ra,24(sp)
    80004f86:	e822                	sd	s0,16(sp)
    80004f88:	e426                	sd	s1,8(sp)
    80004f8a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004f8c:	0004a517          	auipc	a0,0x4a
    80004f90:	78c50513          	addi	a0,a0,1932 # 8004f718 <ftable>
    80004f94:	ffffc097          	auipc	ra,0xffffc
    80004f98:	dd8080e7          	jalr	-552(ra) # 80000d6c <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004f9c:	0004a497          	auipc	s1,0x4a
    80004fa0:	79448493          	addi	s1,s1,1940 # 8004f730 <ftable+0x18>
    80004fa4:	0004b717          	auipc	a4,0x4b
    80004fa8:	72c70713          	addi	a4,a4,1836 # 800506d0 <disk>
    if(f->ref == 0){
    80004fac:	40dc                	lw	a5,4(s1)
    80004fae:	cf99                	beqz	a5,80004fcc <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004fb0:	02848493          	addi	s1,s1,40
    80004fb4:	fee49ce3          	bne	s1,a4,80004fac <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004fb8:	0004a517          	auipc	a0,0x4a
    80004fbc:	76050513          	addi	a0,a0,1888 # 8004f718 <ftable>
    80004fc0:	ffffc097          	auipc	ra,0xffffc
    80004fc4:	e60080e7          	jalr	-416(ra) # 80000e20 <release>
  return 0;
    80004fc8:	4481                	li	s1,0
    80004fca:	a819                	j	80004fe0 <filealloc+0x5e>
      f->ref = 1;
    80004fcc:	4785                	li	a5,1
    80004fce:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004fd0:	0004a517          	auipc	a0,0x4a
    80004fd4:	74850513          	addi	a0,a0,1864 # 8004f718 <ftable>
    80004fd8:	ffffc097          	auipc	ra,0xffffc
    80004fdc:	e48080e7          	jalr	-440(ra) # 80000e20 <release>
}
    80004fe0:	8526                	mv	a0,s1
    80004fe2:	60e2                	ld	ra,24(sp)
    80004fe4:	6442                	ld	s0,16(sp)
    80004fe6:	64a2                	ld	s1,8(sp)
    80004fe8:	6105                	addi	sp,sp,32
    80004fea:	8082                	ret

0000000080004fec <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004fec:	1101                	addi	sp,sp,-32
    80004fee:	ec06                	sd	ra,24(sp)
    80004ff0:	e822                	sd	s0,16(sp)
    80004ff2:	e426                	sd	s1,8(sp)
    80004ff4:	1000                	addi	s0,sp,32
    80004ff6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004ff8:	0004a517          	auipc	a0,0x4a
    80004ffc:	72050513          	addi	a0,a0,1824 # 8004f718 <ftable>
    80005000:	ffffc097          	auipc	ra,0xffffc
    80005004:	d6c080e7          	jalr	-660(ra) # 80000d6c <acquire>
  if(f->ref < 1)
    80005008:	40dc                	lw	a5,4(s1)
    8000500a:	02f05263          	blez	a5,8000502e <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000500e:	2785                	addiw	a5,a5,1
    80005010:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80005012:	0004a517          	auipc	a0,0x4a
    80005016:	70650513          	addi	a0,a0,1798 # 8004f718 <ftable>
    8000501a:	ffffc097          	auipc	ra,0xffffc
    8000501e:	e06080e7          	jalr	-506(ra) # 80000e20 <release>
  return f;
}
    80005022:	8526                	mv	a0,s1
    80005024:	60e2                	ld	ra,24(sp)
    80005026:	6442                	ld	s0,16(sp)
    80005028:	64a2                	ld	s1,8(sp)
    8000502a:	6105                	addi	sp,sp,32
    8000502c:	8082                	ret
    panic("filedup");
    8000502e:	00004517          	auipc	a0,0x4
    80005032:	91a50513          	addi	a0,a0,-1766 # 80008948 <syscall_names+0x270>
    80005036:	ffffb097          	auipc	ra,0xffffb
    8000503a:	506080e7          	jalr	1286(ra) # 8000053c <panic>

000000008000503e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000503e:	7139                	addi	sp,sp,-64
    80005040:	fc06                	sd	ra,56(sp)
    80005042:	f822                	sd	s0,48(sp)
    80005044:	f426                	sd	s1,40(sp)
    80005046:	f04a                	sd	s2,32(sp)
    80005048:	ec4e                	sd	s3,24(sp)
    8000504a:	e852                	sd	s4,16(sp)
    8000504c:	e456                	sd	s5,8(sp)
    8000504e:	0080                	addi	s0,sp,64
    80005050:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80005052:	0004a517          	auipc	a0,0x4a
    80005056:	6c650513          	addi	a0,a0,1734 # 8004f718 <ftable>
    8000505a:	ffffc097          	auipc	ra,0xffffc
    8000505e:	d12080e7          	jalr	-750(ra) # 80000d6c <acquire>
  if(f->ref < 1)
    80005062:	40dc                	lw	a5,4(s1)
    80005064:	06f05163          	blez	a5,800050c6 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80005068:	37fd                	addiw	a5,a5,-1
    8000506a:	0007871b          	sext.w	a4,a5
    8000506e:	c0dc                	sw	a5,4(s1)
    80005070:	06e04363          	bgtz	a4,800050d6 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80005074:	0004a903          	lw	s2,0(s1)
    80005078:	0094ca83          	lbu	s5,9(s1)
    8000507c:	0104ba03          	ld	s4,16(s1)
    80005080:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80005084:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80005088:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000508c:	0004a517          	auipc	a0,0x4a
    80005090:	68c50513          	addi	a0,a0,1676 # 8004f718 <ftable>
    80005094:	ffffc097          	auipc	ra,0xffffc
    80005098:	d8c080e7          	jalr	-628(ra) # 80000e20 <release>

  if(ff.type == FD_PIPE){
    8000509c:	4785                	li	a5,1
    8000509e:	04f90d63          	beq	s2,a5,800050f8 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800050a2:	3979                	addiw	s2,s2,-2
    800050a4:	4785                	li	a5,1
    800050a6:	0527e063          	bltu	a5,s2,800050e6 <fileclose+0xa8>
    begin_op();
    800050aa:	00000097          	auipc	ra,0x0
    800050ae:	ad0080e7          	jalr	-1328(ra) # 80004b7a <begin_op>
    iput(ff.ip);
    800050b2:	854e                	mv	a0,s3
    800050b4:	fffff097          	auipc	ra,0xfffff
    800050b8:	2da080e7          	jalr	730(ra) # 8000438e <iput>
    end_op();
    800050bc:	00000097          	auipc	ra,0x0
    800050c0:	b38080e7          	jalr	-1224(ra) # 80004bf4 <end_op>
    800050c4:	a00d                	j	800050e6 <fileclose+0xa8>
    panic("fileclose");
    800050c6:	00004517          	auipc	a0,0x4
    800050ca:	88a50513          	addi	a0,a0,-1910 # 80008950 <syscall_names+0x278>
    800050ce:	ffffb097          	auipc	ra,0xffffb
    800050d2:	46e080e7          	jalr	1134(ra) # 8000053c <panic>
    release(&ftable.lock);
    800050d6:	0004a517          	auipc	a0,0x4a
    800050da:	64250513          	addi	a0,a0,1602 # 8004f718 <ftable>
    800050de:	ffffc097          	auipc	ra,0xffffc
    800050e2:	d42080e7          	jalr	-702(ra) # 80000e20 <release>
  }
}
    800050e6:	70e2                	ld	ra,56(sp)
    800050e8:	7442                	ld	s0,48(sp)
    800050ea:	74a2                	ld	s1,40(sp)
    800050ec:	7902                	ld	s2,32(sp)
    800050ee:	69e2                	ld	s3,24(sp)
    800050f0:	6a42                	ld	s4,16(sp)
    800050f2:	6aa2                	ld	s5,8(sp)
    800050f4:	6121                	addi	sp,sp,64
    800050f6:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800050f8:	85d6                	mv	a1,s5
    800050fa:	8552                	mv	a0,s4
    800050fc:	00000097          	auipc	ra,0x0
    80005100:	348080e7          	jalr	840(ra) # 80005444 <pipeclose>
    80005104:	b7cd                	j	800050e6 <fileclose+0xa8>

0000000080005106 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80005106:	715d                	addi	sp,sp,-80
    80005108:	e486                	sd	ra,72(sp)
    8000510a:	e0a2                	sd	s0,64(sp)
    8000510c:	fc26                	sd	s1,56(sp)
    8000510e:	f84a                	sd	s2,48(sp)
    80005110:	f44e                	sd	s3,40(sp)
    80005112:	0880                	addi	s0,sp,80
    80005114:	84aa                	mv	s1,a0
    80005116:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80005118:	ffffd097          	auipc	ra,0xffffd
    8000511c:	ab2080e7          	jalr	-1358(ra) # 80001bca <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80005120:	409c                	lw	a5,0(s1)
    80005122:	37f9                	addiw	a5,a5,-2
    80005124:	4705                	li	a4,1
    80005126:	04f76763          	bltu	a4,a5,80005174 <filestat+0x6e>
    8000512a:	892a                	mv	s2,a0
    ilock(f->ip);
    8000512c:	6c88                	ld	a0,24(s1)
    8000512e:	fffff097          	auipc	ra,0xfffff
    80005132:	0a6080e7          	jalr	166(ra) # 800041d4 <ilock>
    stati(f->ip, &st);
    80005136:	fb840593          	addi	a1,s0,-72
    8000513a:	6c88                	ld	a0,24(s1)
    8000513c:	fffff097          	auipc	ra,0xfffff
    80005140:	322080e7          	jalr	802(ra) # 8000445e <stati>
    iunlock(f->ip);
    80005144:	6c88                	ld	a0,24(s1)
    80005146:	fffff097          	auipc	ra,0xfffff
    8000514a:	150080e7          	jalr	336(ra) # 80004296 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000514e:	46e1                	li	a3,24
    80005150:	fb840613          	addi	a2,s0,-72
    80005154:	85ce                	mv	a1,s3
    80005156:	05093503          	ld	a0,80(s2)
    8000515a:	ffffc097          	auipc	ra,0xffffc
    8000515e:	6b6080e7          	jalr	1718(ra) # 80001810 <copyout>
    80005162:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80005166:	60a6                	ld	ra,72(sp)
    80005168:	6406                	ld	s0,64(sp)
    8000516a:	74e2                	ld	s1,56(sp)
    8000516c:	7942                	ld	s2,48(sp)
    8000516e:	79a2                	ld	s3,40(sp)
    80005170:	6161                	addi	sp,sp,80
    80005172:	8082                	ret
  return -1;
    80005174:	557d                	li	a0,-1
    80005176:	bfc5                	j	80005166 <filestat+0x60>

0000000080005178 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80005178:	7179                	addi	sp,sp,-48
    8000517a:	f406                	sd	ra,40(sp)
    8000517c:	f022                	sd	s0,32(sp)
    8000517e:	ec26                	sd	s1,24(sp)
    80005180:	e84a                	sd	s2,16(sp)
    80005182:	e44e                	sd	s3,8(sp)
    80005184:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005186:	00854783          	lbu	a5,8(a0)
    8000518a:	c3d5                	beqz	a5,8000522e <fileread+0xb6>
    8000518c:	84aa                	mv	s1,a0
    8000518e:	89ae                	mv	s3,a1
    80005190:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005192:	411c                	lw	a5,0(a0)
    80005194:	4705                	li	a4,1
    80005196:	04e78963          	beq	a5,a4,800051e8 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000519a:	470d                	li	a4,3
    8000519c:	04e78d63          	beq	a5,a4,800051f6 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800051a0:	4709                	li	a4,2
    800051a2:	06e79e63          	bne	a5,a4,8000521e <fileread+0xa6>
    ilock(f->ip);
    800051a6:	6d08                	ld	a0,24(a0)
    800051a8:	fffff097          	auipc	ra,0xfffff
    800051ac:	02c080e7          	jalr	44(ra) # 800041d4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800051b0:	874a                	mv	a4,s2
    800051b2:	5094                	lw	a3,32(s1)
    800051b4:	864e                	mv	a2,s3
    800051b6:	4585                	li	a1,1
    800051b8:	6c88                	ld	a0,24(s1)
    800051ba:	fffff097          	auipc	ra,0xfffff
    800051be:	2ce080e7          	jalr	718(ra) # 80004488 <readi>
    800051c2:	892a                	mv	s2,a0
    800051c4:	00a05563          	blez	a0,800051ce <fileread+0x56>
      f->off += r;
    800051c8:	509c                	lw	a5,32(s1)
    800051ca:	9fa9                	addw	a5,a5,a0
    800051cc:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800051ce:	6c88                	ld	a0,24(s1)
    800051d0:	fffff097          	auipc	ra,0xfffff
    800051d4:	0c6080e7          	jalr	198(ra) # 80004296 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800051d8:	854a                	mv	a0,s2
    800051da:	70a2                	ld	ra,40(sp)
    800051dc:	7402                	ld	s0,32(sp)
    800051de:	64e2                	ld	s1,24(sp)
    800051e0:	6942                	ld	s2,16(sp)
    800051e2:	69a2                	ld	s3,8(sp)
    800051e4:	6145                	addi	sp,sp,48
    800051e6:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800051e8:	6908                	ld	a0,16(a0)
    800051ea:	00000097          	auipc	ra,0x0
    800051ee:	3c2080e7          	jalr	962(ra) # 800055ac <piperead>
    800051f2:	892a                	mv	s2,a0
    800051f4:	b7d5                	j	800051d8 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800051f6:	02451783          	lh	a5,36(a0)
    800051fa:	03079693          	slli	a3,a5,0x30
    800051fe:	92c1                	srli	a3,a3,0x30
    80005200:	4725                	li	a4,9
    80005202:	02d76863          	bltu	a4,a3,80005232 <fileread+0xba>
    80005206:	0792                	slli	a5,a5,0x4
    80005208:	0004a717          	auipc	a4,0x4a
    8000520c:	47070713          	addi	a4,a4,1136 # 8004f678 <devsw>
    80005210:	97ba                	add	a5,a5,a4
    80005212:	639c                	ld	a5,0(a5)
    80005214:	c38d                	beqz	a5,80005236 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80005216:	4505                	li	a0,1
    80005218:	9782                	jalr	a5
    8000521a:	892a                	mv	s2,a0
    8000521c:	bf75                	j	800051d8 <fileread+0x60>
    panic("fileread");
    8000521e:	00003517          	auipc	a0,0x3
    80005222:	74250513          	addi	a0,a0,1858 # 80008960 <syscall_names+0x288>
    80005226:	ffffb097          	auipc	ra,0xffffb
    8000522a:	316080e7          	jalr	790(ra) # 8000053c <panic>
    return -1;
    8000522e:	597d                	li	s2,-1
    80005230:	b765                	j	800051d8 <fileread+0x60>
      return -1;
    80005232:	597d                	li	s2,-1
    80005234:	b755                	j	800051d8 <fileread+0x60>
    80005236:	597d                	li	s2,-1
    80005238:	b745                	j	800051d8 <fileread+0x60>

000000008000523a <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000523a:	00954783          	lbu	a5,9(a0)
    8000523e:	10078e63          	beqz	a5,8000535a <filewrite+0x120>
{
    80005242:	715d                	addi	sp,sp,-80
    80005244:	e486                	sd	ra,72(sp)
    80005246:	e0a2                	sd	s0,64(sp)
    80005248:	fc26                	sd	s1,56(sp)
    8000524a:	f84a                	sd	s2,48(sp)
    8000524c:	f44e                	sd	s3,40(sp)
    8000524e:	f052                	sd	s4,32(sp)
    80005250:	ec56                	sd	s5,24(sp)
    80005252:	e85a                	sd	s6,16(sp)
    80005254:	e45e                	sd	s7,8(sp)
    80005256:	e062                	sd	s8,0(sp)
    80005258:	0880                	addi	s0,sp,80
    8000525a:	892a                	mv	s2,a0
    8000525c:	8b2e                	mv	s6,a1
    8000525e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80005260:	411c                	lw	a5,0(a0)
    80005262:	4705                	li	a4,1
    80005264:	02e78263          	beq	a5,a4,80005288 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005268:	470d                	li	a4,3
    8000526a:	02e78563          	beq	a5,a4,80005294 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000526e:	4709                	li	a4,2
    80005270:	0ce79d63          	bne	a5,a4,8000534a <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005274:	0ac05b63          	blez	a2,8000532a <filewrite+0xf0>
    int i = 0;
    80005278:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000527a:	6b85                	lui	s7,0x1
    8000527c:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80005280:	6c05                	lui	s8,0x1
    80005282:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80005286:	a851                	j	8000531a <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80005288:	6908                	ld	a0,16(a0)
    8000528a:	00000097          	auipc	ra,0x0
    8000528e:	22a080e7          	jalr	554(ra) # 800054b4 <pipewrite>
    80005292:	a045                	j	80005332 <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005294:	02451783          	lh	a5,36(a0)
    80005298:	03079693          	slli	a3,a5,0x30
    8000529c:	92c1                	srli	a3,a3,0x30
    8000529e:	4725                	li	a4,9
    800052a0:	0ad76f63          	bltu	a4,a3,8000535e <filewrite+0x124>
    800052a4:	0792                	slli	a5,a5,0x4
    800052a6:	0004a717          	auipc	a4,0x4a
    800052aa:	3d270713          	addi	a4,a4,978 # 8004f678 <devsw>
    800052ae:	97ba                	add	a5,a5,a4
    800052b0:	679c                	ld	a5,8(a5)
    800052b2:	cbc5                	beqz	a5,80005362 <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    800052b4:	4505                	li	a0,1
    800052b6:	9782                	jalr	a5
    800052b8:	a8ad                	j	80005332 <filewrite+0xf8>
      if(n1 > max)
    800052ba:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800052be:	00000097          	auipc	ra,0x0
    800052c2:	8bc080e7          	jalr	-1860(ra) # 80004b7a <begin_op>
      ilock(f->ip);
    800052c6:	01893503          	ld	a0,24(s2)
    800052ca:	fffff097          	auipc	ra,0xfffff
    800052ce:	f0a080e7          	jalr	-246(ra) # 800041d4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800052d2:	8756                	mv	a4,s5
    800052d4:	02092683          	lw	a3,32(s2)
    800052d8:	01698633          	add	a2,s3,s6
    800052dc:	4585                	li	a1,1
    800052de:	01893503          	ld	a0,24(s2)
    800052e2:	fffff097          	auipc	ra,0xfffff
    800052e6:	29e080e7          	jalr	670(ra) # 80004580 <writei>
    800052ea:	84aa                	mv	s1,a0
    800052ec:	00a05763          	blez	a0,800052fa <filewrite+0xc0>
        f->off += r;
    800052f0:	02092783          	lw	a5,32(s2)
    800052f4:	9fa9                	addw	a5,a5,a0
    800052f6:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800052fa:	01893503          	ld	a0,24(s2)
    800052fe:	fffff097          	auipc	ra,0xfffff
    80005302:	f98080e7          	jalr	-104(ra) # 80004296 <iunlock>
      end_op();
    80005306:	00000097          	auipc	ra,0x0
    8000530a:	8ee080e7          	jalr	-1810(ra) # 80004bf4 <end_op>

      if(r != n1){
    8000530e:	009a9f63          	bne	s5,s1,8000532c <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    80005312:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80005316:	0149db63          	bge	s3,s4,8000532c <filewrite+0xf2>
      int n1 = n - i;
    8000531a:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    8000531e:	0004879b          	sext.w	a5,s1
    80005322:	f8fbdce3          	bge	s7,a5,800052ba <filewrite+0x80>
    80005326:	84e2                	mv	s1,s8
    80005328:	bf49                	j	800052ba <filewrite+0x80>
    int i = 0;
    8000532a:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000532c:	033a1d63          	bne	s4,s3,80005366 <filewrite+0x12c>
    80005330:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005332:	60a6                	ld	ra,72(sp)
    80005334:	6406                	ld	s0,64(sp)
    80005336:	74e2                	ld	s1,56(sp)
    80005338:	7942                	ld	s2,48(sp)
    8000533a:	79a2                	ld	s3,40(sp)
    8000533c:	7a02                	ld	s4,32(sp)
    8000533e:	6ae2                	ld	s5,24(sp)
    80005340:	6b42                	ld	s6,16(sp)
    80005342:	6ba2                	ld	s7,8(sp)
    80005344:	6c02                	ld	s8,0(sp)
    80005346:	6161                	addi	sp,sp,80
    80005348:	8082                	ret
    panic("filewrite");
    8000534a:	00003517          	auipc	a0,0x3
    8000534e:	62650513          	addi	a0,a0,1574 # 80008970 <syscall_names+0x298>
    80005352:	ffffb097          	auipc	ra,0xffffb
    80005356:	1ea080e7          	jalr	490(ra) # 8000053c <panic>
    return -1;
    8000535a:	557d                	li	a0,-1
}
    8000535c:	8082                	ret
      return -1;
    8000535e:	557d                	li	a0,-1
    80005360:	bfc9                	j	80005332 <filewrite+0xf8>
    80005362:	557d                	li	a0,-1
    80005364:	b7f9                	j	80005332 <filewrite+0xf8>
    ret = (i == n ? n : -1);
    80005366:	557d                	li	a0,-1
    80005368:	b7e9                	j	80005332 <filewrite+0xf8>

000000008000536a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000536a:	7179                	addi	sp,sp,-48
    8000536c:	f406                	sd	ra,40(sp)
    8000536e:	f022                	sd	s0,32(sp)
    80005370:	ec26                	sd	s1,24(sp)
    80005372:	e84a                	sd	s2,16(sp)
    80005374:	e44e                	sd	s3,8(sp)
    80005376:	e052                	sd	s4,0(sp)
    80005378:	1800                	addi	s0,sp,48
    8000537a:	84aa                	mv	s1,a0
    8000537c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000537e:	0005b023          	sd	zero,0(a1)
    80005382:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80005386:	00000097          	auipc	ra,0x0
    8000538a:	bfc080e7          	jalr	-1028(ra) # 80004f82 <filealloc>
    8000538e:	e088                	sd	a0,0(s1)
    80005390:	c551                	beqz	a0,8000541c <pipealloc+0xb2>
    80005392:	00000097          	auipc	ra,0x0
    80005396:	bf0080e7          	jalr	-1040(ra) # 80004f82 <filealloc>
    8000539a:	00aa3023          	sd	a0,0(s4)
    8000539e:	c92d                	beqz	a0,80005410 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800053a0:	ffffc097          	auipc	ra,0xffffc
    800053a4:	88c080e7          	jalr	-1908(ra) # 80000c2c <kalloc>
    800053a8:	892a                	mv	s2,a0
    800053aa:	c125                	beqz	a0,8000540a <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800053ac:	4985                	li	s3,1
    800053ae:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800053b2:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800053b6:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800053ba:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800053be:	00003597          	auipc	a1,0x3
    800053c2:	0da58593          	addi	a1,a1,218 # 80008498 <states.0+0x1c0>
    800053c6:	ffffc097          	auipc	ra,0xffffc
    800053ca:	916080e7          	jalr	-1770(ra) # 80000cdc <initlock>
  (*f0)->type = FD_PIPE;
    800053ce:	609c                	ld	a5,0(s1)
    800053d0:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800053d4:	609c                	ld	a5,0(s1)
    800053d6:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800053da:	609c                	ld	a5,0(s1)
    800053dc:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800053e0:	609c                	ld	a5,0(s1)
    800053e2:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800053e6:	000a3783          	ld	a5,0(s4)
    800053ea:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800053ee:	000a3783          	ld	a5,0(s4)
    800053f2:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800053f6:	000a3783          	ld	a5,0(s4)
    800053fa:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800053fe:	000a3783          	ld	a5,0(s4)
    80005402:	0127b823          	sd	s2,16(a5)
  return 0;
    80005406:	4501                	li	a0,0
    80005408:	a025                	j	80005430 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000540a:	6088                	ld	a0,0(s1)
    8000540c:	e501                	bnez	a0,80005414 <pipealloc+0xaa>
    8000540e:	a039                	j	8000541c <pipealloc+0xb2>
    80005410:	6088                	ld	a0,0(s1)
    80005412:	c51d                	beqz	a0,80005440 <pipealloc+0xd6>
    fileclose(*f0);
    80005414:	00000097          	auipc	ra,0x0
    80005418:	c2a080e7          	jalr	-982(ra) # 8000503e <fileclose>
  if(*f1)
    8000541c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005420:	557d                	li	a0,-1
  if(*f1)
    80005422:	c799                	beqz	a5,80005430 <pipealloc+0xc6>
    fileclose(*f1);
    80005424:	853e                	mv	a0,a5
    80005426:	00000097          	auipc	ra,0x0
    8000542a:	c18080e7          	jalr	-1000(ra) # 8000503e <fileclose>
  return -1;
    8000542e:	557d                	li	a0,-1
}
    80005430:	70a2                	ld	ra,40(sp)
    80005432:	7402                	ld	s0,32(sp)
    80005434:	64e2                	ld	s1,24(sp)
    80005436:	6942                	ld	s2,16(sp)
    80005438:	69a2                	ld	s3,8(sp)
    8000543a:	6a02                	ld	s4,0(sp)
    8000543c:	6145                	addi	sp,sp,48
    8000543e:	8082                	ret
  return -1;
    80005440:	557d                	li	a0,-1
    80005442:	b7fd                	j	80005430 <pipealloc+0xc6>

0000000080005444 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005444:	1101                	addi	sp,sp,-32
    80005446:	ec06                	sd	ra,24(sp)
    80005448:	e822                	sd	s0,16(sp)
    8000544a:	e426                	sd	s1,8(sp)
    8000544c:	e04a                	sd	s2,0(sp)
    8000544e:	1000                	addi	s0,sp,32
    80005450:	84aa                	mv	s1,a0
    80005452:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005454:	ffffc097          	auipc	ra,0xffffc
    80005458:	918080e7          	jalr	-1768(ra) # 80000d6c <acquire>
  if(writable){
    8000545c:	02090d63          	beqz	s2,80005496 <pipeclose+0x52>
    pi->writeopen = 0;
    80005460:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005464:	21848513          	addi	a0,s1,536
    80005468:	ffffd097          	auipc	ra,0xffffd
    8000546c:	252080e7          	jalr	594(ra) # 800026ba <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005470:	2204b783          	ld	a5,544(s1)
    80005474:	eb95                	bnez	a5,800054a8 <pipeclose+0x64>
    release(&pi->lock);
    80005476:	8526                	mv	a0,s1
    80005478:	ffffc097          	auipc	ra,0xffffc
    8000547c:	9a8080e7          	jalr	-1624(ra) # 80000e20 <release>
    kfree((char*)pi);
    80005480:	8526                	mv	a0,s1
    80005482:	ffffb097          	auipc	ra,0xffffb
    80005486:	614080e7          	jalr	1556(ra) # 80000a96 <kfree>
  } else
    release(&pi->lock);
}
    8000548a:	60e2                	ld	ra,24(sp)
    8000548c:	6442                	ld	s0,16(sp)
    8000548e:	64a2                	ld	s1,8(sp)
    80005490:	6902                	ld	s2,0(sp)
    80005492:	6105                	addi	sp,sp,32
    80005494:	8082                	ret
    pi->readopen = 0;
    80005496:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000549a:	21c48513          	addi	a0,s1,540
    8000549e:	ffffd097          	auipc	ra,0xffffd
    800054a2:	21c080e7          	jalr	540(ra) # 800026ba <wakeup>
    800054a6:	b7e9                	j	80005470 <pipeclose+0x2c>
    release(&pi->lock);
    800054a8:	8526                	mv	a0,s1
    800054aa:	ffffc097          	auipc	ra,0xffffc
    800054ae:	976080e7          	jalr	-1674(ra) # 80000e20 <release>
}
    800054b2:	bfe1                	j	8000548a <pipeclose+0x46>

00000000800054b4 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800054b4:	711d                	addi	sp,sp,-96
    800054b6:	ec86                	sd	ra,88(sp)
    800054b8:	e8a2                	sd	s0,80(sp)
    800054ba:	e4a6                	sd	s1,72(sp)
    800054bc:	e0ca                	sd	s2,64(sp)
    800054be:	fc4e                	sd	s3,56(sp)
    800054c0:	f852                	sd	s4,48(sp)
    800054c2:	f456                	sd	s5,40(sp)
    800054c4:	f05a                	sd	s6,32(sp)
    800054c6:	ec5e                	sd	s7,24(sp)
    800054c8:	e862                	sd	s8,16(sp)
    800054ca:	1080                	addi	s0,sp,96
    800054cc:	84aa                	mv	s1,a0
    800054ce:	8aae                	mv	s5,a1
    800054d0:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800054d2:	ffffc097          	auipc	ra,0xffffc
    800054d6:	6f8080e7          	jalr	1784(ra) # 80001bca <myproc>
    800054da:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800054dc:	8526                	mv	a0,s1
    800054de:	ffffc097          	auipc	ra,0xffffc
    800054e2:	88e080e7          	jalr	-1906(ra) # 80000d6c <acquire>
  while(i < n){
    800054e6:	0b405663          	blez	s4,80005592 <pipewrite+0xde>
  int i = 0;
    800054ea:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800054ec:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800054ee:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800054f2:	21c48b93          	addi	s7,s1,540
    800054f6:	a089                	j	80005538 <pipewrite+0x84>
      release(&pi->lock);
    800054f8:	8526                	mv	a0,s1
    800054fa:	ffffc097          	auipc	ra,0xffffc
    800054fe:	926080e7          	jalr	-1754(ra) # 80000e20 <release>
      return -1;
    80005502:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005504:	854a                	mv	a0,s2
    80005506:	60e6                	ld	ra,88(sp)
    80005508:	6446                	ld	s0,80(sp)
    8000550a:	64a6                	ld	s1,72(sp)
    8000550c:	6906                	ld	s2,64(sp)
    8000550e:	79e2                	ld	s3,56(sp)
    80005510:	7a42                	ld	s4,48(sp)
    80005512:	7aa2                	ld	s5,40(sp)
    80005514:	7b02                	ld	s6,32(sp)
    80005516:	6be2                	ld	s7,24(sp)
    80005518:	6c42                	ld	s8,16(sp)
    8000551a:	6125                	addi	sp,sp,96
    8000551c:	8082                	ret
      wakeup(&pi->nread);
    8000551e:	8562                	mv	a0,s8
    80005520:	ffffd097          	auipc	ra,0xffffd
    80005524:	19a080e7          	jalr	410(ra) # 800026ba <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005528:	85a6                	mv	a1,s1
    8000552a:	855e                	mv	a0,s7
    8000552c:	ffffd097          	auipc	ra,0xffffd
    80005530:	fde080e7          	jalr	-34(ra) # 8000250a <sleep>
  while(i < n){
    80005534:	07495063          	bge	s2,s4,80005594 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80005538:	2204a783          	lw	a5,544(s1)
    8000553c:	dfd5                	beqz	a5,800054f8 <pipewrite+0x44>
    8000553e:	854e                	mv	a0,s3
    80005540:	ffffd097          	auipc	ra,0xffffd
    80005544:	3de080e7          	jalr	990(ra) # 8000291e <killed>
    80005548:	f945                	bnez	a0,800054f8 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000554a:	2184a783          	lw	a5,536(s1)
    8000554e:	21c4a703          	lw	a4,540(s1)
    80005552:	2007879b          	addiw	a5,a5,512
    80005556:	fcf704e3          	beq	a4,a5,8000551e <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000555a:	4685                	li	a3,1
    8000555c:	01590633          	add	a2,s2,s5
    80005560:	faf40593          	addi	a1,s0,-81
    80005564:	0509b503          	ld	a0,80(s3)
    80005568:	ffffc097          	auipc	ra,0xffffc
    8000556c:	334080e7          	jalr	820(ra) # 8000189c <copyin>
    80005570:	03650263          	beq	a0,s6,80005594 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005574:	21c4a783          	lw	a5,540(s1)
    80005578:	0017871b          	addiw	a4,a5,1
    8000557c:	20e4ae23          	sw	a4,540(s1)
    80005580:	1ff7f793          	andi	a5,a5,511
    80005584:	97a6                	add	a5,a5,s1
    80005586:	faf44703          	lbu	a4,-81(s0)
    8000558a:	00e78c23          	sb	a4,24(a5)
      i++;
    8000558e:	2905                	addiw	s2,s2,1
    80005590:	b755                	j	80005534 <pipewrite+0x80>
  int i = 0;
    80005592:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005594:	21848513          	addi	a0,s1,536
    80005598:	ffffd097          	auipc	ra,0xffffd
    8000559c:	122080e7          	jalr	290(ra) # 800026ba <wakeup>
  release(&pi->lock);
    800055a0:	8526                	mv	a0,s1
    800055a2:	ffffc097          	auipc	ra,0xffffc
    800055a6:	87e080e7          	jalr	-1922(ra) # 80000e20 <release>
  return i;
    800055aa:	bfa9                	j	80005504 <pipewrite+0x50>

00000000800055ac <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800055ac:	715d                	addi	sp,sp,-80
    800055ae:	e486                	sd	ra,72(sp)
    800055b0:	e0a2                	sd	s0,64(sp)
    800055b2:	fc26                	sd	s1,56(sp)
    800055b4:	f84a                	sd	s2,48(sp)
    800055b6:	f44e                	sd	s3,40(sp)
    800055b8:	f052                	sd	s4,32(sp)
    800055ba:	ec56                	sd	s5,24(sp)
    800055bc:	e85a                	sd	s6,16(sp)
    800055be:	0880                	addi	s0,sp,80
    800055c0:	84aa                	mv	s1,a0
    800055c2:	892e                	mv	s2,a1
    800055c4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800055c6:	ffffc097          	auipc	ra,0xffffc
    800055ca:	604080e7          	jalr	1540(ra) # 80001bca <myproc>
    800055ce:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800055d0:	8526                	mv	a0,s1
    800055d2:	ffffb097          	auipc	ra,0xffffb
    800055d6:	79a080e7          	jalr	1946(ra) # 80000d6c <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800055da:	2184a703          	lw	a4,536(s1)
    800055de:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800055e2:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800055e6:	02f71763          	bne	a4,a5,80005614 <piperead+0x68>
    800055ea:	2244a783          	lw	a5,548(s1)
    800055ee:	c39d                	beqz	a5,80005614 <piperead+0x68>
    if(killed(pr)){
    800055f0:	8552                	mv	a0,s4
    800055f2:	ffffd097          	auipc	ra,0xffffd
    800055f6:	32c080e7          	jalr	812(ra) # 8000291e <killed>
    800055fa:	e949                	bnez	a0,8000568c <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800055fc:	85a6                	mv	a1,s1
    800055fe:	854e                	mv	a0,s3
    80005600:	ffffd097          	auipc	ra,0xffffd
    80005604:	f0a080e7          	jalr	-246(ra) # 8000250a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005608:	2184a703          	lw	a4,536(s1)
    8000560c:	21c4a783          	lw	a5,540(s1)
    80005610:	fcf70de3          	beq	a4,a5,800055ea <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005614:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005616:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005618:	05505463          	blez	s5,80005660 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    8000561c:	2184a783          	lw	a5,536(s1)
    80005620:	21c4a703          	lw	a4,540(s1)
    80005624:	02f70e63          	beq	a4,a5,80005660 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005628:	0017871b          	addiw	a4,a5,1
    8000562c:	20e4ac23          	sw	a4,536(s1)
    80005630:	1ff7f793          	andi	a5,a5,511
    80005634:	97a6                	add	a5,a5,s1
    80005636:	0187c783          	lbu	a5,24(a5)
    8000563a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000563e:	4685                	li	a3,1
    80005640:	fbf40613          	addi	a2,s0,-65
    80005644:	85ca                	mv	a1,s2
    80005646:	050a3503          	ld	a0,80(s4)
    8000564a:	ffffc097          	auipc	ra,0xffffc
    8000564e:	1c6080e7          	jalr	454(ra) # 80001810 <copyout>
    80005652:	01650763          	beq	a0,s6,80005660 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005656:	2985                	addiw	s3,s3,1
    80005658:	0905                	addi	s2,s2,1
    8000565a:	fd3a91e3          	bne	s5,s3,8000561c <piperead+0x70>
    8000565e:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005660:	21c48513          	addi	a0,s1,540
    80005664:	ffffd097          	auipc	ra,0xffffd
    80005668:	056080e7          	jalr	86(ra) # 800026ba <wakeup>
  release(&pi->lock);
    8000566c:	8526                	mv	a0,s1
    8000566e:	ffffb097          	auipc	ra,0xffffb
    80005672:	7b2080e7          	jalr	1970(ra) # 80000e20 <release>
  return i;
}
    80005676:	854e                	mv	a0,s3
    80005678:	60a6                	ld	ra,72(sp)
    8000567a:	6406                	ld	s0,64(sp)
    8000567c:	74e2                	ld	s1,56(sp)
    8000567e:	7942                	ld	s2,48(sp)
    80005680:	79a2                	ld	s3,40(sp)
    80005682:	7a02                	ld	s4,32(sp)
    80005684:	6ae2                	ld	s5,24(sp)
    80005686:	6b42                	ld	s6,16(sp)
    80005688:	6161                	addi	sp,sp,80
    8000568a:	8082                	ret
      release(&pi->lock);
    8000568c:	8526                	mv	a0,s1
    8000568e:	ffffb097          	auipc	ra,0xffffb
    80005692:	792080e7          	jalr	1938(ra) # 80000e20 <release>
      return -1;
    80005696:	59fd                	li	s3,-1
    80005698:	bff9                	j	80005676 <piperead+0xca>

000000008000569a <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000569a:	1141                	addi	sp,sp,-16
    8000569c:	e422                	sd	s0,8(sp)
    8000569e:	0800                	addi	s0,sp,16
    800056a0:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800056a2:	8905                	andi	a0,a0,1
    800056a4:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800056a6:	8b89                	andi	a5,a5,2
    800056a8:	c399                	beqz	a5,800056ae <flags2perm+0x14>
      perm |= PTE_W;
    800056aa:	00456513          	ori	a0,a0,4
    return perm;
}
    800056ae:	6422                	ld	s0,8(sp)
    800056b0:	0141                	addi	sp,sp,16
    800056b2:	8082                	ret

00000000800056b4 <exec>:

int
exec(char *path, char **argv)
{
    800056b4:	df010113          	addi	sp,sp,-528
    800056b8:	20113423          	sd	ra,520(sp)
    800056bc:	20813023          	sd	s0,512(sp)
    800056c0:	ffa6                	sd	s1,504(sp)
    800056c2:	fbca                	sd	s2,496(sp)
    800056c4:	f7ce                	sd	s3,488(sp)
    800056c6:	f3d2                	sd	s4,480(sp)
    800056c8:	efd6                	sd	s5,472(sp)
    800056ca:	ebda                	sd	s6,464(sp)
    800056cc:	e7de                	sd	s7,456(sp)
    800056ce:	e3e2                	sd	s8,448(sp)
    800056d0:	ff66                	sd	s9,440(sp)
    800056d2:	fb6a                	sd	s10,432(sp)
    800056d4:	f76e                	sd	s11,424(sp)
    800056d6:	0c00                	addi	s0,sp,528
    800056d8:	892a                	mv	s2,a0
    800056da:	dea43c23          	sd	a0,-520(s0)
    800056de:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800056e2:	ffffc097          	auipc	ra,0xffffc
    800056e6:	4e8080e7          	jalr	1256(ra) # 80001bca <myproc>
    800056ea:	84aa                	mv	s1,a0

  begin_op();
    800056ec:	fffff097          	auipc	ra,0xfffff
    800056f0:	48e080e7          	jalr	1166(ra) # 80004b7a <begin_op>

  if((ip = namei(path)) == 0){
    800056f4:	854a                	mv	a0,s2
    800056f6:	fffff097          	auipc	ra,0xfffff
    800056fa:	284080e7          	jalr	644(ra) # 8000497a <namei>
    800056fe:	c92d                	beqz	a0,80005770 <exec+0xbc>
    80005700:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005702:	fffff097          	auipc	ra,0xfffff
    80005706:	ad2080e7          	jalr	-1326(ra) # 800041d4 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000570a:	04000713          	li	a4,64
    8000570e:	4681                	li	a3,0
    80005710:	e5040613          	addi	a2,s0,-432
    80005714:	4581                	li	a1,0
    80005716:	8552                	mv	a0,s4
    80005718:	fffff097          	auipc	ra,0xfffff
    8000571c:	d70080e7          	jalr	-656(ra) # 80004488 <readi>
    80005720:	04000793          	li	a5,64
    80005724:	00f51a63          	bne	a0,a5,80005738 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005728:	e5042703          	lw	a4,-432(s0)
    8000572c:	464c47b7          	lui	a5,0x464c4
    80005730:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005734:	04f70463          	beq	a4,a5,8000577c <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005738:	8552                	mv	a0,s4
    8000573a:	fffff097          	auipc	ra,0xfffff
    8000573e:	cfc080e7          	jalr	-772(ra) # 80004436 <iunlockput>
    end_op();
    80005742:	fffff097          	auipc	ra,0xfffff
    80005746:	4b2080e7          	jalr	1202(ra) # 80004bf4 <end_op>
  }
  return -1;
    8000574a:	557d                	li	a0,-1
}
    8000574c:	20813083          	ld	ra,520(sp)
    80005750:	20013403          	ld	s0,512(sp)
    80005754:	74fe                	ld	s1,504(sp)
    80005756:	795e                	ld	s2,496(sp)
    80005758:	79be                	ld	s3,488(sp)
    8000575a:	7a1e                	ld	s4,480(sp)
    8000575c:	6afe                	ld	s5,472(sp)
    8000575e:	6b5e                	ld	s6,464(sp)
    80005760:	6bbe                	ld	s7,456(sp)
    80005762:	6c1e                	ld	s8,448(sp)
    80005764:	7cfa                	ld	s9,440(sp)
    80005766:	7d5a                	ld	s10,432(sp)
    80005768:	7dba                	ld	s11,424(sp)
    8000576a:	21010113          	addi	sp,sp,528
    8000576e:	8082                	ret
    end_op();
    80005770:	fffff097          	auipc	ra,0xfffff
    80005774:	484080e7          	jalr	1156(ra) # 80004bf4 <end_op>
    return -1;
    80005778:	557d                	li	a0,-1
    8000577a:	bfc9                	j	8000574c <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    8000577c:	8526                	mv	a0,s1
    8000577e:	ffffc097          	auipc	ra,0xffffc
    80005782:	510080e7          	jalr	1296(ra) # 80001c8e <proc_pagetable>
    80005786:	8b2a                	mv	s6,a0
    80005788:	d945                	beqz	a0,80005738 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000578a:	e7042d03          	lw	s10,-400(s0)
    8000578e:	e8845783          	lhu	a5,-376(s0)
    80005792:	10078463          	beqz	a5,8000589a <exec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005796:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005798:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    8000579a:	6c85                	lui	s9,0x1
    8000579c:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800057a0:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800057a4:	6a85                	lui	s5,0x1
    800057a6:	a0b5                	j	80005812 <exec+0x15e>
      panic("loadseg: address should exist");
    800057a8:	00003517          	auipc	a0,0x3
    800057ac:	1d850513          	addi	a0,a0,472 # 80008980 <syscall_names+0x2a8>
    800057b0:	ffffb097          	auipc	ra,0xffffb
    800057b4:	d8c080e7          	jalr	-628(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    800057b8:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800057ba:	8726                	mv	a4,s1
    800057bc:	012c06bb          	addw	a3,s8,s2
    800057c0:	4581                	li	a1,0
    800057c2:	8552                	mv	a0,s4
    800057c4:	fffff097          	auipc	ra,0xfffff
    800057c8:	cc4080e7          	jalr	-828(ra) # 80004488 <readi>
    800057cc:	2501                	sext.w	a0,a0
    800057ce:	24a49863          	bne	s1,a0,80005a1e <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    800057d2:	012a893b          	addw	s2,s5,s2
    800057d6:	03397563          	bgeu	s2,s3,80005800 <exec+0x14c>
    pa = walkaddr(pagetable, va + i);
    800057da:	02091593          	slli	a1,s2,0x20
    800057de:	9181                	srli	a1,a1,0x20
    800057e0:	95de                	add	a1,a1,s7
    800057e2:	855a                	mv	a0,s6
    800057e4:	ffffc097          	auipc	ra,0xffffc
    800057e8:	a0c080e7          	jalr	-1524(ra) # 800011f0 <walkaddr>
    800057ec:	862a                	mv	a2,a0
    if(pa == 0)
    800057ee:	dd4d                	beqz	a0,800057a8 <exec+0xf4>
    if(sz - i < PGSIZE)
    800057f0:	412984bb          	subw	s1,s3,s2
    800057f4:	0004879b          	sext.w	a5,s1
    800057f8:	fcfcf0e3          	bgeu	s9,a5,800057b8 <exec+0x104>
    800057fc:	84d6                	mv	s1,s5
    800057fe:	bf6d                	j	800057b8 <exec+0x104>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005800:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005804:	2d85                	addiw	s11,s11,1
    80005806:	038d0d1b          	addiw	s10,s10,56
    8000580a:	e8845783          	lhu	a5,-376(s0)
    8000580e:	08fdd763          	bge	s11,a5,8000589c <exec+0x1e8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005812:	2d01                	sext.w	s10,s10
    80005814:	03800713          	li	a4,56
    80005818:	86ea                	mv	a3,s10
    8000581a:	e1840613          	addi	a2,s0,-488
    8000581e:	4581                	li	a1,0
    80005820:	8552                	mv	a0,s4
    80005822:	fffff097          	auipc	ra,0xfffff
    80005826:	c66080e7          	jalr	-922(ra) # 80004488 <readi>
    8000582a:	03800793          	li	a5,56
    8000582e:	1ef51663          	bne	a0,a5,80005a1a <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    80005832:	e1842783          	lw	a5,-488(s0)
    80005836:	4705                	li	a4,1
    80005838:	fce796e3          	bne	a5,a4,80005804 <exec+0x150>
    if(ph.memsz < ph.filesz)
    8000583c:	e4043483          	ld	s1,-448(s0)
    80005840:	e3843783          	ld	a5,-456(s0)
    80005844:	1ef4e863          	bltu	s1,a5,80005a34 <exec+0x380>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005848:	e2843783          	ld	a5,-472(s0)
    8000584c:	94be                	add	s1,s1,a5
    8000584e:	1ef4e663          	bltu	s1,a5,80005a3a <exec+0x386>
    if(ph.vaddr % PGSIZE != 0)
    80005852:	df043703          	ld	a4,-528(s0)
    80005856:	8ff9                	and	a5,a5,a4
    80005858:	1e079463          	bnez	a5,80005a40 <exec+0x38c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000585c:	e1c42503          	lw	a0,-484(s0)
    80005860:	00000097          	auipc	ra,0x0
    80005864:	e3a080e7          	jalr	-454(ra) # 8000569a <flags2perm>
    80005868:	86aa                	mv	a3,a0
    8000586a:	8626                	mv	a2,s1
    8000586c:	85ca                	mv	a1,s2
    8000586e:	855a                	mv	a0,s6
    80005870:	ffffc097          	auipc	ra,0xffffc
    80005874:	d34080e7          	jalr	-716(ra) # 800015a4 <uvmalloc>
    80005878:	e0a43423          	sd	a0,-504(s0)
    8000587c:	1c050563          	beqz	a0,80005a46 <exec+0x392>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005880:	e2843b83          	ld	s7,-472(s0)
    80005884:	e2042c03          	lw	s8,-480(s0)
    80005888:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000588c:	00098463          	beqz	s3,80005894 <exec+0x1e0>
    80005890:	4901                	li	s2,0
    80005892:	b7a1                	j	800057da <exec+0x126>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005894:	e0843903          	ld	s2,-504(s0)
    80005898:	b7b5                	j	80005804 <exec+0x150>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000589a:	4901                	li	s2,0
  iunlockput(ip);
    8000589c:	8552                	mv	a0,s4
    8000589e:	fffff097          	auipc	ra,0xfffff
    800058a2:	b98080e7          	jalr	-1128(ra) # 80004436 <iunlockput>
  end_op();
    800058a6:	fffff097          	auipc	ra,0xfffff
    800058aa:	34e080e7          	jalr	846(ra) # 80004bf4 <end_op>
  p = myproc();
    800058ae:	ffffc097          	auipc	ra,0xffffc
    800058b2:	31c080e7          	jalr	796(ra) # 80001bca <myproc>
    800058b6:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800058b8:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    800058bc:	6985                	lui	s3,0x1
    800058be:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800058c0:	99ca                	add	s3,s3,s2
    800058c2:	77fd                	lui	a5,0xfffff
    800058c4:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800058c8:	4691                	li	a3,4
    800058ca:	6609                	lui	a2,0x2
    800058cc:	964e                	add	a2,a2,s3
    800058ce:	85ce                	mv	a1,s3
    800058d0:	855a                	mv	a0,s6
    800058d2:	ffffc097          	auipc	ra,0xffffc
    800058d6:	cd2080e7          	jalr	-814(ra) # 800015a4 <uvmalloc>
    800058da:	892a                	mv	s2,a0
    800058dc:	e0a43423          	sd	a0,-504(s0)
    800058e0:	e509                	bnez	a0,800058ea <exec+0x236>
  if(pagetable)
    800058e2:	e1343423          	sd	s3,-504(s0)
    800058e6:	4a01                	li	s4,0
    800058e8:	aa1d                	j	80005a1e <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    800058ea:	75f9                	lui	a1,0xffffe
    800058ec:	95aa                	add	a1,a1,a0
    800058ee:	855a                	mv	a0,s6
    800058f0:	ffffc097          	auipc	ra,0xffffc
    800058f4:	eee080e7          	jalr	-274(ra) # 800017de <uvmclear>
  stackbase = sp - PGSIZE;
    800058f8:	7bfd                	lui	s7,0xfffff
    800058fa:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800058fc:	e0043783          	ld	a5,-512(s0)
    80005900:	6388                	ld	a0,0(a5)
    80005902:	c52d                	beqz	a0,8000596c <exec+0x2b8>
    80005904:	e9040993          	addi	s3,s0,-368
    80005908:	f9040c13          	addi	s8,s0,-112
    8000590c:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000590e:	ffffb097          	auipc	ra,0xffffb
    80005912:	6d4080e7          	jalr	1748(ra) # 80000fe2 <strlen>
    80005916:	0015079b          	addiw	a5,a0,1
    8000591a:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000591e:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80005922:	13796563          	bltu	s2,s7,80005a4c <exec+0x398>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005926:	e0043d03          	ld	s10,-512(s0)
    8000592a:	000d3a03          	ld	s4,0(s10)
    8000592e:	8552                	mv	a0,s4
    80005930:	ffffb097          	auipc	ra,0xffffb
    80005934:	6b2080e7          	jalr	1714(ra) # 80000fe2 <strlen>
    80005938:	0015069b          	addiw	a3,a0,1
    8000593c:	8652                	mv	a2,s4
    8000593e:	85ca                	mv	a1,s2
    80005940:	855a                	mv	a0,s6
    80005942:	ffffc097          	auipc	ra,0xffffc
    80005946:	ece080e7          	jalr	-306(ra) # 80001810 <copyout>
    8000594a:	10054363          	bltz	a0,80005a50 <exec+0x39c>
    ustack[argc] = sp;
    8000594e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005952:	0485                	addi	s1,s1,1
    80005954:	008d0793          	addi	a5,s10,8
    80005958:	e0f43023          	sd	a5,-512(s0)
    8000595c:	008d3503          	ld	a0,8(s10)
    80005960:	c909                	beqz	a0,80005972 <exec+0x2be>
    if(argc >= MAXARG)
    80005962:	09a1                	addi	s3,s3,8
    80005964:	fb8995e3          	bne	s3,s8,8000590e <exec+0x25a>
  ip = 0;
    80005968:	4a01                	li	s4,0
    8000596a:	a855                	j	80005a1e <exec+0x36a>
  sp = sz;
    8000596c:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005970:	4481                	li	s1,0
  ustack[argc] = 0;
    80005972:	00349793          	slli	a5,s1,0x3
    80005976:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffae780>
    8000597a:	97a2                	add	a5,a5,s0
    8000597c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005980:	00148693          	addi	a3,s1,1
    80005984:	068e                	slli	a3,a3,0x3
    80005986:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000598a:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    8000598e:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80005992:	f57968e3          	bltu	s2,s7,800058e2 <exec+0x22e>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005996:	e9040613          	addi	a2,s0,-368
    8000599a:	85ca                	mv	a1,s2
    8000599c:	855a                	mv	a0,s6
    8000599e:	ffffc097          	auipc	ra,0xffffc
    800059a2:	e72080e7          	jalr	-398(ra) # 80001810 <copyout>
    800059a6:	0a054763          	bltz	a0,80005a54 <exec+0x3a0>
  p->trapframe->a1 = sp;
    800059aa:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    800059ae:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800059b2:	df843783          	ld	a5,-520(s0)
    800059b6:	0007c703          	lbu	a4,0(a5)
    800059ba:	cf11                	beqz	a4,800059d6 <exec+0x322>
    800059bc:	0785                	addi	a5,a5,1
    if(*s == '/')
    800059be:	02f00693          	li	a3,47
    800059c2:	a039                	j	800059d0 <exec+0x31c>
      last = s+1;
    800059c4:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800059c8:	0785                	addi	a5,a5,1
    800059ca:	fff7c703          	lbu	a4,-1(a5)
    800059ce:	c701                	beqz	a4,800059d6 <exec+0x322>
    if(*s == '/')
    800059d0:	fed71ce3          	bne	a4,a3,800059c8 <exec+0x314>
    800059d4:	bfc5                	j	800059c4 <exec+0x310>
  safestrcpy(p->name, last, sizeof(p->name));
    800059d6:	4641                	li	a2,16
    800059d8:	df843583          	ld	a1,-520(s0)
    800059dc:	158a8513          	addi	a0,s5,344
    800059e0:	ffffb097          	auipc	ra,0xffffb
    800059e4:	5d0080e7          	jalr	1488(ra) # 80000fb0 <safestrcpy>
  oldpagetable = p->pagetable;
    800059e8:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800059ec:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800059f0:	e0843783          	ld	a5,-504(s0)
    800059f4:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800059f8:	058ab783          	ld	a5,88(s5)
    800059fc:	e6843703          	ld	a4,-408(s0)
    80005a00:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005a02:	058ab783          	ld	a5,88(s5)
    80005a06:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005a0a:	85e6                	mv	a1,s9
    80005a0c:	ffffc097          	auipc	ra,0xffffc
    80005a10:	31e080e7          	jalr	798(ra) # 80001d2a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005a14:	0004851b          	sext.w	a0,s1
    80005a18:	bb15                	j	8000574c <exec+0x98>
    80005a1a:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80005a1e:	e0843583          	ld	a1,-504(s0)
    80005a22:	855a                	mv	a0,s6
    80005a24:	ffffc097          	auipc	ra,0xffffc
    80005a28:	306080e7          	jalr	774(ra) # 80001d2a <proc_freepagetable>
  return -1;
    80005a2c:	557d                	li	a0,-1
  if(ip){
    80005a2e:	d00a0fe3          	beqz	s4,8000574c <exec+0x98>
    80005a32:	b319                	j	80005738 <exec+0x84>
    80005a34:	e1243423          	sd	s2,-504(s0)
    80005a38:	b7dd                	j	80005a1e <exec+0x36a>
    80005a3a:	e1243423          	sd	s2,-504(s0)
    80005a3e:	b7c5                	j	80005a1e <exec+0x36a>
    80005a40:	e1243423          	sd	s2,-504(s0)
    80005a44:	bfe9                	j	80005a1e <exec+0x36a>
    80005a46:	e1243423          	sd	s2,-504(s0)
    80005a4a:	bfd1                	j	80005a1e <exec+0x36a>
  ip = 0;
    80005a4c:	4a01                	li	s4,0
    80005a4e:	bfc1                	j	80005a1e <exec+0x36a>
    80005a50:	4a01                	li	s4,0
  if(pagetable)
    80005a52:	b7f1                	j	80005a1e <exec+0x36a>
  sz = sz1;
    80005a54:	e0843983          	ld	s3,-504(s0)
    80005a58:	b569                	j	800058e2 <exec+0x22e>

0000000080005a5a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005a5a:	7179                	addi	sp,sp,-48
    80005a5c:	f406                	sd	ra,40(sp)
    80005a5e:	f022                	sd	s0,32(sp)
    80005a60:	ec26                	sd	s1,24(sp)
    80005a62:	e84a                	sd	s2,16(sp)
    80005a64:	1800                	addi	s0,sp,48
    80005a66:	892e                	mv	s2,a1
    80005a68:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005a6a:	fdc40593          	addi	a1,s0,-36
    80005a6e:	ffffe097          	auipc	ra,0xffffe
    80005a72:	89e080e7          	jalr	-1890(ra) # 8000330c <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005a76:	fdc42703          	lw	a4,-36(s0)
    80005a7a:	47bd                	li	a5,15
    80005a7c:	02e7eb63          	bltu	a5,a4,80005ab2 <argfd+0x58>
    80005a80:	ffffc097          	auipc	ra,0xffffc
    80005a84:	14a080e7          	jalr	330(ra) # 80001bca <myproc>
    80005a88:	fdc42703          	lw	a4,-36(s0)
    80005a8c:	01a70793          	addi	a5,a4,26
    80005a90:	078e                	slli	a5,a5,0x3
    80005a92:	953e                	add	a0,a0,a5
    80005a94:	611c                	ld	a5,0(a0)
    80005a96:	c385                	beqz	a5,80005ab6 <argfd+0x5c>
    return -1;
  if(pfd)
    80005a98:	00090463          	beqz	s2,80005aa0 <argfd+0x46>
    *pfd = fd;
    80005a9c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005aa0:	4501                	li	a0,0
  if(pf)
    80005aa2:	c091                	beqz	s1,80005aa6 <argfd+0x4c>
    *pf = f;
    80005aa4:	e09c                	sd	a5,0(s1)
}
    80005aa6:	70a2                	ld	ra,40(sp)
    80005aa8:	7402                	ld	s0,32(sp)
    80005aaa:	64e2                	ld	s1,24(sp)
    80005aac:	6942                	ld	s2,16(sp)
    80005aae:	6145                	addi	sp,sp,48
    80005ab0:	8082                	ret
    return -1;
    80005ab2:	557d                	li	a0,-1
    80005ab4:	bfcd                	j	80005aa6 <argfd+0x4c>
    80005ab6:	557d                	li	a0,-1
    80005ab8:	b7fd                	j	80005aa6 <argfd+0x4c>

0000000080005aba <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005aba:	1101                	addi	sp,sp,-32
    80005abc:	ec06                	sd	ra,24(sp)
    80005abe:	e822                	sd	s0,16(sp)
    80005ac0:	e426                	sd	s1,8(sp)
    80005ac2:	1000                	addi	s0,sp,32
    80005ac4:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005ac6:	ffffc097          	auipc	ra,0xffffc
    80005aca:	104080e7          	jalr	260(ra) # 80001bca <myproc>
    80005ace:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005ad0:	0d050793          	addi	a5,a0,208
    80005ad4:	4501                	li	a0,0
    80005ad6:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005ad8:	6398                	ld	a4,0(a5)
    80005ada:	cb19                	beqz	a4,80005af0 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005adc:	2505                	addiw	a0,a0,1
    80005ade:	07a1                	addi	a5,a5,8
    80005ae0:	fed51ce3          	bne	a0,a3,80005ad8 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005ae4:	557d                	li	a0,-1
}
    80005ae6:	60e2                	ld	ra,24(sp)
    80005ae8:	6442                	ld	s0,16(sp)
    80005aea:	64a2                	ld	s1,8(sp)
    80005aec:	6105                	addi	sp,sp,32
    80005aee:	8082                	ret
      p->ofile[fd] = f;
    80005af0:	01a50793          	addi	a5,a0,26
    80005af4:	078e                	slli	a5,a5,0x3
    80005af6:	963e                	add	a2,a2,a5
    80005af8:	e204                	sd	s1,0(a2)
      return fd;
    80005afa:	b7f5                	j	80005ae6 <fdalloc+0x2c>

0000000080005afc <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005afc:	715d                	addi	sp,sp,-80
    80005afe:	e486                	sd	ra,72(sp)
    80005b00:	e0a2                	sd	s0,64(sp)
    80005b02:	fc26                	sd	s1,56(sp)
    80005b04:	f84a                	sd	s2,48(sp)
    80005b06:	f44e                	sd	s3,40(sp)
    80005b08:	f052                	sd	s4,32(sp)
    80005b0a:	ec56                	sd	s5,24(sp)
    80005b0c:	e85a                	sd	s6,16(sp)
    80005b0e:	0880                	addi	s0,sp,80
    80005b10:	8b2e                	mv	s6,a1
    80005b12:	89b2                	mv	s3,a2
    80005b14:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005b16:	fb040593          	addi	a1,s0,-80
    80005b1a:	fffff097          	auipc	ra,0xfffff
    80005b1e:	e7e080e7          	jalr	-386(ra) # 80004998 <nameiparent>
    80005b22:	84aa                	mv	s1,a0
    80005b24:	14050b63          	beqz	a0,80005c7a <create+0x17e>
    return 0;

  ilock(dp);
    80005b28:	ffffe097          	auipc	ra,0xffffe
    80005b2c:	6ac080e7          	jalr	1708(ra) # 800041d4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005b30:	4601                	li	a2,0
    80005b32:	fb040593          	addi	a1,s0,-80
    80005b36:	8526                	mv	a0,s1
    80005b38:	fffff097          	auipc	ra,0xfffff
    80005b3c:	b80080e7          	jalr	-1152(ra) # 800046b8 <dirlookup>
    80005b40:	8aaa                	mv	s5,a0
    80005b42:	c921                	beqz	a0,80005b92 <create+0x96>
    iunlockput(dp);
    80005b44:	8526                	mv	a0,s1
    80005b46:	fffff097          	auipc	ra,0xfffff
    80005b4a:	8f0080e7          	jalr	-1808(ra) # 80004436 <iunlockput>
    ilock(ip);
    80005b4e:	8556                	mv	a0,s5
    80005b50:	ffffe097          	auipc	ra,0xffffe
    80005b54:	684080e7          	jalr	1668(ra) # 800041d4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005b58:	4789                	li	a5,2
    80005b5a:	02fb1563          	bne	s6,a5,80005b84 <create+0x88>
    80005b5e:	044ad783          	lhu	a5,68(s5)
    80005b62:	37f9                	addiw	a5,a5,-2
    80005b64:	17c2                	slli	a5,a5,0x30
    80005b66:	93c1                	srli	a5,a5,0x30
    80005b68:	4705                	li	a4,1
    80005b6a:	00f76d63          	bltu	a4,a5,80005b84 <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005b6e:	8556                	mv	a0,s5
    80005b70:	60a6                	ld	ra,72(sp)
    80005b72:	6406                	ld	s0,64(sp)
    80005b74:	74e2                	ld	s1,56(sp)
    80005b76:	7942                	ld	s2,48(sp)
    80005b78:	79a2                	ld	s3,40(sp)
    80005b7a:	7a02                	ld	s4,32(sp)
    80005b7c:	6ae2                	ld	s5,24(sp)
    80005b7e:	6b42                	ld	s6,16(sp)
    80005b80:	6161                	addi	sp,sp,80
    80005b82:	8082                	ret
    iunlockput(ip);
    80005b84:	8556                	mv	a0,s5
    80005b86:	fffff097          	auipc	ra,0xfffff
    80005b8a:	8b0080e7          	jalr	-1872(ra) # 80004436 <iunlockput>
    return 0;
    80005b8e:	4a81                	li	s5,0
    80005b90:	bff9                	j	80005b6e <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005b92:	85da                	mv	a1,s6
    80005b94:	4088                	lw	a0,0(s1)
    80005b96:	ffffe097          	auipc	ra,0xffffe
    80005b9a:	4a6080e7          	jalr	1190(ra) # 8000403c <ialloc>
    80005b9e:	8a2a                	mv	s4,a0
    80005ba0:	c529                	beqz	a0,80005bea <create+0xee>
  ilock(ip);
    80005ba2:	ffffe097          	auipc	ra,0xffffe
    80005ba6:	632080e7          	jalr	1586(ra) # 800041d4 <ilock>
  ip->major = major;
    80005baa:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005bae:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005bb2:	4905                	li	s2,1
    80005bb4:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005bb8:	8552                	mv	a0,s4
    80005bba:	ffffe097          	auipc	ra,0xffffe
    80005bbe:	54e080e7          	jalr	1358(ra) # 80004108 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005bc2:	032b0b63          	beq	s6,s2,80005bf8 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005bc6:	004a2603          	lw	a2,4(s4)
    80005bca:	fb040593          	addi	a1,s0,-80
    80005bce:	8526                	mv	a0,s1
    80005bd0:	fffff097          	auipc	ra,0xfffff
    80005bd4:	cf8080e7          	jalr	-776(ra) # 800048c8 <dirlink>
    80005bd8:	06054f63          	bltz	a0,80005c56 <create+0x15a>
  iunlockput(dp);
    80005bdc:	8526                	mv	a0,s1
    80005bde:	fffff097          	auipc	ra,0xfffff
    80005be2:	858080e7          	jalr	-1960(ra) # 80004436 <iunlockput>
  return ip;
    80005be6:	8ad2                	mv	s5,s4
    80005be8:	b759                	j	80005b6e <create+0x72>
    iunlockput(dp);
    80005bea:	8526                	mv	a0,s1
    80005bec:	fffff097          	auipc	ra,0xfffff
    80005bf0:	84a080e7          	jalr	-1974(ra) # 80004436 <iunlockput>
    return 0;
    80005bf4:	8ad2                	mv	s5,s4
    80005bf6:	bfa5                	j	80005b6e <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005bf8:	004a2603          	lw	a2,4(s4)
    80005bfc:	00003597          	auipc	a1,0x3
    80005c00:	da458593          	addi	a1,a1,-604 # 800089a0 <syscall_names+0x2c8>
    80005c04:	8552                	mv	a0,s4
    80005c06:	fffff097          	auipc	ra,0xfffff
    80005c0a:	cc2080e7          	jalr	-830(ra) # 800048c8 <dirlink>
    80005c0e:	04054463          	bltz	a0,80005c56 <create+0x15a>
    80005c12:	40d0                	lw	a2,4(s1)
    80005c14:	00003597          	auipc	a1,0x3
    80005c18:	d9458593          	addi	a1,a1,-620 # 800089a8 <syscall_names+0x2d0>
    80005c1c:	8552                	mv	a0,s4
    80005c1e:	fffff097          	auipc	ra,0xfffff
    80005c22:	caa080e7          	jalr	-854(ra) # 800048c8 <dirlink>
    80005c26:	02054863          	bltz	a0,80005c56 <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    80005c2a:	004a2603          	lw	a2,4(s4)
    80005c2e:	fb040593          	addi	a1,s0,-80
    80005c32:	8526                	mv	a0,s1
    80005c34:	fffff097          	auipc	ra,0xfffff
    80005c38:	c94080e7          	jalr	-876(ra) # 800048c8 <dirlink>
    80005c3c:	00054d63          	bltz	a0,80005c56 <create+0x15a>
    dp->nlink++;  // for ".."
    80005c40:	04a4d783          	lhu	a5,74(s1)
    80005c44:	2785                	addiw	a5,a5,1
    80005c46:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005c4a:	8526                	mv	a0,s1
    80005c4c:	ffffe097          	auipc	ra,0xffffe
    80005c50:	4bc080e7          	jalr	1212(ra) # 80004108 <iupdate>
    80005c54:	b761                	j	80005bdc <create+0xe0>
  ip->nlink = 0;
    80005c56:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005c5a:	8552                	mv	a0,s4
    80005c5c:	ffffe097          	auipc	ra,0xffffe
    80005c60:	4ac080e7          	jalr	1196(ra) # 80004108 <iupdate>
  iunlockput(ip);
    80005c64:	8552                	mv	a0,s4
    80005c66:	ffffe097          	auipc	ra,0xffffe
    80005c6a:	7d0080e7          	jalr	2000(ra) # 80004436 <iunlockput>
  iunlockput(dp);
    80005c6e:	8526                	mv	a0,s1
    80005c70:	ffffe097          	auipc	ra,0xffffe
    80005c74:	7c6080e7          	jalr	1990(ra) # 80004436 <iunlockput>
  return 0;
    80005c78:	bddd                	j	80005b6e <create+0x72>
    return 0;
    80005c7a:	8aaa                	mv	s5,a0
    80005c7c:	bdcd                	j	80005b6e <create+0x72>

0000000080005c7e <sys_dup>:
{
    80005c7e:	7179                	addi	sp,sp,-48
    80005c80:	f406                	sd	ra,40(sp)
    80005c82:	f022                	sd	s0,32(sp)
    80005c84:	ec26                	sd	s1,24(sp)
    80005c86:	e84a                	sd	s2,16(sp)
    80005c88:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005c8a:	fd840613          	addi	a2,s0,-40
    80005c8e:	4581                	li	a1,0
    80005c90:	4501                	li	a0,0
    80005c92:	00000097          	auipc	ra,0x0
    80005c96:	dc8080e7          	jalr	-568(ra) # 80005a5a <argfd>
    return -1;
    80005c9a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005c9c:	02054363          	bltz	a0,80005cc2 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005ca0:	fd843903          	ld	s2,-40(s0)
    80005ca4:	854a                	mv	a0,s2
    80005ca6:	00000097          	auipc	ra,0x0
    80005caa:	e14080e7          	jalr	-492(ra) # 80005aba <fdalloc>
    80005cae:	84aa                	mv	s1,a0
    return -1;
    80005cb0:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005cb2:	00054863          	bltz	a0,80005cc2 <sys_dup+0x44>
  filedup(f);
    80005cb6:	854a                	mv	a0,s2
    80005cb8:	fffff097          	auipc	ra,0xfffff
    80005cbc:	334080e7          	jalr	820(ra) # 80004fec <filedup>
  return fd;
    80005cc0:	87a6                	mv	a5,s1
}
    80005cc2:	853e                	mv	a0,a5
    80005cc4:	70a2                	ld	ra,40(sp)
    80005cc6:	7402                	ld	s0,32(sp)
    80005cc8:	64e2                	ld	s1,24(sp)
    80005cca:	6942                	ld	s2,16(sp)
    80005ccc:	6145                	addi	sp,sp,48
    80005cce:	8082                	ret

0000000080005cd0 <sys_read>:
{
    80005cd0:	7179                	addi	sp,sp,-48
    80005cd2:	f406                	sd	ra,40(sp)
    80005cd4:	f022                	sd	s0,32(sp)
    80005cd6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005cd8:	fd840593          	addi	a1,s0,-40
    80005cdc:	4505                	li	a0,1
    80005cde:	ffffd097          	auipc	ra,0xffffd
    80005ce2:	64e080e7          	jalr	1614(ra) # 8000332c <argaddr>
  argint(2, &n);
    80005ce6:	fe440593          	addi	a1,s0,-28
    80005cea:	4509                	li	a0,2
    80005cec:	ffffd097          	auipc	ra,0xffffd
    80005cf0:	620080e7          	jalr	1568(ra) # 8000330c <argint>
  if(argfd(0, 0, &f) < 0)
    80005cf4:	fe840613          	addi	a2,s0,-24
    80005cf8:	4581                	li	a1,0
    80005cfa:	4501                	li	a0,0
    80005cfc:	00000097          	auipc	ra,0x0
    80005d00:	d5e080e7          	jalr	-674(ra) # 80005a5a <argfd>
    80005d04:	87aa                	mv	a5,a0
    return -1;
    80005d06:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005d08:	0007cc63          	bltz	a5,80005d20 <sys_read+0x50>
  return fileread(f, p, n);
    80005d0c:	fe442603          	lw	a2,-28(s0)
    80005d10:	fd843583          	ld	a1,-40(s0)
    80005d14:	fe843503          	ld	a0,-24(s0)
    80005d18:	fffff097          	auipc	ra,0xfffff
    80005d1c:	460080e7          	jalr	1120(ra) # 80005178 <fileread>
}
    80005d20:	70a2                	ld	ra,40(sp)
    80005d22:	7402                	ld	s0,32(sp)
    80005d24:	6145                	addi	sp,sp,48
    80005d26:	8082                	ret

0000000080005d28 <sys_write>:
{
    80005d28:	7179                	addi	sp,sp,-48
    80005d2a:	f406                	sd	ra,40(sp)
    80005d2c:	f022                	sd	s0,32(sp)
    80005d2e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005d30:	fd840593          	addi	a1,s0,-40
    80005d34:	4505                	li	a0,1
    80005d36:	ffffd097          	auipc	ra,0xffffd
    80005d3a:	5f6080e7          	jalr	1526(ra) # 8000332c <argaddr>
  argint(2, &n);
    80005d3e:	fe440593          	addi	a1,s0,-28
    80005d42:	4509                	li	a0,2
    80005d44:	ffffd097          	auipc	ra,0xffffd
    80005d48:	5c8080e7          	jalr	1480(ra) # 8000330c <argint>
  if(argfd(0, 0, &f) < 0)
    80005d4c:	fe840613          	addi	a2,s0,-24
    80005d50:	4581                	li	a1,0
    80005d52:	4501                	li	a0,0
    80005d54:	00000097          	auipc	ra,0x0
    80005d58:	d06080e7          	jalr	-762(ra) # 80005a5a <argfd>
    80005d5c:	87aa                	mv	a5,a0
    return -1;
    80005d5e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005d60:	0007cc63          	bltz	a5,80005d78 <sys_write+0x50>
  return filewrite(f, p, n);
    80005d64:	fe442603          	lw	a2,-28(s0)
    80005d68:	fd843583          	ld	a1,-40(s0)
    80005d6c:	fe843503          	ld	a0,-24(s0)
    80005d70:	fffff097          	auipc	ra,0xfffff
    80005d74:	4ca080e7          	jalr	1226(ra) # 8000523a <filewrite>
}
    80005d78:	70a2                	ld	ra,40(sp)
    80005d7a:	7402                	ld	s0,32(sp)
    80005d7c:	6145                	addi	sp,sp,48
    80005d7e:	8082                	ret

0000000080005d80 <sys_close>:
{
    80005d80:	1101                	addi	sp,sp,-32
    80005d82:	ec06                	sd	ra,24(sp)
    80005d84:	e822                	sd	s0,16(sp)
    80005d86:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005d88:	fe040613          	addi	a2,s0,-32
    80005d8c:	fec40593          	addi	a1,s0,-20
    80005d90:	4501                	li	a0,0
    80005d92:	00000097          	auipc	ra,0x0
    80005d96:	cc8080e7          	jalr	-824(ra) # 80005a5a <argfd>
    return -1;
    80005d9a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005d9c:	02054463          	bltz	a0,80005dc4 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005da0:	ffffc097          	auipc	ra,0xffffc
    80005da4:	e2a080e7          	jalr	-470(ra) # 80001bca <myproc>
    80005da8:	fec42783          	lw	a5,-20(s0)
    80005dac:	07e9                	addi	a5,a5,26
    80005dae:	078e                	slli	a5,a5,0x3
    80005db0:	953e                	add	a0,a0,a5
    80005db2:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005db6:	fe043503          	ld	a0,-32(s0)
    80005dba:	fffff097          	auipc	ra,0xfffff
    80005dbe:	284080e7          	jalr	644(ra) # 8000503e <fileclose>
  return 0;
    80005dc2:	4781                	li	a5,0
}
    80005dc4:	853e                	mv	a0,a5
    80005dc6:	60e2                	ld	ra,24(sp)
    80005dc8:	6442                	ld	s0,16(sp)
    80005dca:	6105                	addi	sp,sp,32
    80005dcc:	8082                	ret

0000000080005dce <sys_fstat>:
{
    80005dce:	1101                	addi	sp,sp,-32
    80005dd0:	ec06                	sd	ra,24(sp)
    80005dd2:	e822                	sd	s0,16(sp)
    80005dd4:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005dd6:	fe040593          	addi	a1,s0,-32
    80005dda:	4505                	li	a0,1
    80005ddc:	ffffd097          	auipc	ra,0xffffd
    80005de0:	550080e7          	jalr	1360(ra) # 8000332c <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005de4:	fe840613          	addi	a2,s0,-24
    80005de8:	4581                	li	a1,0
    80005dea:	4501                	li	a0,0
    80005dec:	00000097          	auipc	ra,0x0
    80005df0:	c6e080e7          	jalr	-914(ra) # 80005a5a <argfd>
    80005df4:	87aa                	mv	a5,a0
    return -1;
    80005df6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005df8:	0007ca63          	bltz	a5,80005e0c <sys_fstat+0x3e>
  return filestat(f, st);
    80005dfc:	fe043583          	ld	a1,-32(s0)
    80005e00:	fe843503          	ld	a0,-24(s0)
    80005e04:	fffff097          	auipc	ra,0xfffff
    80005e08:	302080e7          	jalr	770(ra) # 80005106 <filestat>
}
    80005e0c:	60e2                	ld	ra,24(sp)
    80005e0e:	6442                	ld	s0,16(sp)
    80005e10:	6105                	addi	sp,sp,32
    80005e12:	8082                	ret

0000000080005e14 <sys_link>:
{
    80005e14:	7169                	addi	sp,sp,-304
    80005e16:	f606                	sd	ra,296(sp)
    80005e18:	f222                	sd	s0,288(sp)
    80005e1a:	ee26                	sd	s1,280(sp)
    80005e1c:	ea4a                	sd	s2,272(sp)
    80005e1e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005e20:	08000613          	li	a2,128
    80005e24:	ed040593          	addi	a1,s0,-304
    80005e28:	4501                	li	a0,0
    80005e2a:	ffffd097          	auipc	ra,0xffffd
    80005e2e:	522080e7          	jalr	1314(ra) # 8000334c <argstr>
    return -1;
    80005e32:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005e34:	10054e63          	bltz	a0,80005f50 <sys_link+0x13c>
    80005e38:	08000613          	li	a2,128
    80005e3c:	f5040593          	addi	a1,s0,-176
    80005e40:	4505                	li	a0,1
    80005e42:	ffffd097          	auipc	ra,0xffffd
    80005e46:	50a080e7          	jalr	1290(ra) # 8000334c <argstr>
    return -1;
    80005e4a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005e4c:	10054263          	bltz	a0,80005f50 <sys_link+0x13c>
  begin_op();
    80005e50:	fffff097          	auipc	ra,0xfffff
    80005e54:	d2a080e7          	jalr	-726(ra) # 80004b7a <begin_op>
  if((ip = namei(old)) == 0){
    80005e58:	ed040513          	addi	a0,s0,-304
    80005e5c:	fffff097          	auipc	ra,0xfffff
    80005e60:	b1e080e7          	jalr	-1250(ra) # 8000497a <namei>
    80005e64:	84aa                	mv	s1,a0
    80005e66:	c551                	beqz	a0,80005ef2 <sys_link+0xde>
  ilock(ip);
    80005e68:	ffffe097          	auipc	ra,0xffffe
    80005e6c:	36c080e7          	jalr	876(ra) # 800041d4 <ilock>
  if(ip->type == T_DIR){
    80005e70:	04449703          	lh	a4,68(s1)
    80005e74:	4785                	li	a5,1
    80005e76:	08f70463          	beq	a4,a5,80005efe <sys_link+0xea>
  ip->nlink++;
    80005e7a:	04a4d783          	lhu	a5,74(s1)
    80005e7e:	2785                	addiw	a5,a5,1
    80005e80:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005e84:	8526                	mv	a0,s1
    80005e86:	ffffe097          	auipc	ra,0xffffe
    80005e8a:	282080e7          	jalr	642(ra) # 80004108 <iupdate>
  iunlock(ip);
    80005e8e:	8526                	mv	a0,s1
    80005e90:	ffffe097          	auipc	ra,0xffffe
    80005e94:	406080e7          	jalr	1030(ra) # 80004296 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005e98:	fd040593          	addi	a1,s0,-48
    80005e9c:	f5040513          	addi	a0,s0,-176
    80005ea0:	fffff097          	auipc	ra,0xfffff
    80005ea4:	af8080e7          	jalr	-1288(ra) # 80004998 <nameiparent>
    80005ea8:	892a                	mv	s2,a0
    80005eaa:	c935                	beqz	a0,80005f1e <sys_link+0x10a>
  ilock(dp);
    80005eac:	ffffe097          	auipc	ra,0xffffe
    80005eb0:	328080e7          	jalr	808(ra) # 800041d4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005eb4:	00092703          	lw	a4,0(s2)
    80005eb8:	409c                	lw	a5,0(s1)
    80005eba:	04f71d63          	bne	a4,a5,80005f14 <sys_link+0x100>
    80005ebe:	40d0                	lw	a2,4(s1)
    80005ec0:	fd040593          	addi	a1,s0,-48
    80005ec4:	854a                	mv	a0,s2
    80005ec6:	fffff097          	auipc	ra,0xfffff
    80005eca:	a02080e7          	jalr	-1534(ra) # 800048c8 <dirlink>
    80005ece:	04054363          	bltz	a0,80005f14 <sys_link+0x100>
  iunlockput(dp);
    80005ed2:	854a                	mv	a0,s2
    80005ed4:	ffffe097          	auipc	ra,0xffffe
    80005ed8:	562080e7          	jalr	1378(ra) # 80004436 <iunlockput>
  iput(ip);
    80005edc:	8526                	mv	a0,s1
    80005ede:	ffffe097          	auipc	ra,0xffffe
    80005ee2:	4b0080e7          	jalr	1200(ra) # 8000438e <iput>
  end_op();
    80005ee6:	fffff097          	auipc	ra,0xfffff
    80005eea:	d0e080e7          	jalr	-754(ra) # 80004bf4 <end_op>
  return 0;
    80005eee:	4781                	li	a5,0
    80005ef0:	a085                	j	80005f50 <sys_link+0x13c>
    end_op();
    80005ef2:	fffff097          	auipc	ra,0xfffff
    80005ef6:	d02080e7          	jalr	-766(ra) # 80004bf4 <end_op>
    return -1;
    80005efa:	57fd                	li	a5,-1
    80005efc:	a891                	j	80005f50 <sys_link+0x13c>
    iunlockput(ip);
    80005efe:	8526                	mv	a0,s1
    80005f00:	ffffe097          	auipc	ra,0xffffe
    80005f04:	536080e7          	jalr	1334(ra) # 80004436 <iunlockput>
    end_op();
    80005f08:	fffff097          	auipc	ra,0xfffff
    80005f0c:	cec080e7          	jalr	-788(ra) # 80004bf4 <end_op>
    return -1;
    80005f10:	57fd                	li	a5,-1
    80005f12:	a83d                	j	80005f50 <sys_link+0x13c>
    iunlockput(dp);
    80005f14:	854a                	mv	a0,s2
    80005f16:	ffffe097          	auipc	ra,0xffffe
    80005f1a:	520080e7          	jalr	1312(ra) # 80004436 <iunlockput>
  ilock(ip);
    80005f1e:	8526                	mv	a0,s1
    80005f20:	ffffe097          	auipc	ra,0xffffe
    80005f24:	2b4080e7          	jalr	692(ra) # 800041d4 <ilock>
  ip->nlink--;
    80005f28:	04a4d783          	lhu	a5,74(s1)
    80005f2c:	37fd                	addiw	a5,a5,-1
    80005f2e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005f32:	8526                	mv	a0,s1
    80005f34:	ffffe097          	auipc	ra,0xffffe
    80005f38:	1d4080e7          	jalr	468(ra) # 80004108 <iupdate>
  iunlockput(ip);
    80005f3c:	8526                	mv	a0,s1
    80005f3e:	ffffe097          	auipc	ra,0xffffe
    80005f42:	4f8080e7          	jalr	1272(ra) # 80004436 <iunlockput>
  end_op();
    80005f46:	fffff097          	auipc	ra,0xfffff
    80005f4a:	cae080e7          	jalr	-850(ra) # 80004bf4 <end_op>
  return -1;
    80005f4e:	57fd                	li	a5,-1
}
    80005f50:	853e                	mv	a0,a5
    80005f52:	70b2                	ld	ra,296(sp)
    80005f54:	7412                	ld	s0,288(sp)
    80005f56:	64f2                	ld	s1,280(sp)
    80005f58:	6952                	ld	s2,272(sp)
    80005f5a:	6155                	addi	sp,sp,304
    80005f5c:	8082                	ret

0000000080005f5e <sys_unlink>:
{
    80005f5e:	7151                	addi	sp,sp,-240
    80005f60:	f586                	sd	ra,232(sp)
    80005f62:	f1a2                	sd	s0,224(sp)
    80005f64:	eda6                	sd	s1,216(sp)
    80005f66:	e9ca                	sd	s2,208(sp)
    80005f68:	e5ce                	sd	s3,200(sp)
    80005f6a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005f6c:	08000613          	li	a2,128
    80005f70:	f3040593          	addi	a1,s0,-208
    80005f74:	4501                	li	a0,0
    80005f76:	ffffd097          	auipc	ra,0xffffd
    80005f7a:	3d6080e7          	jalr	982(ra) # 8000334c <argstr>
    80005f7e:	18054163          	bltz	a0,80006100 <sys_unlink+0x1a2>
  begin_op();
    80005f82:	fffff097          	auipc	ra,0xfffff
    80005f86:	bf8080e7          	jalr	-1032(ra) # 80004b7a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005f8a:	fb040593          	addi	a1,s0,-80
    80005f8e:	f3040513          	addi	a0,s0,-208
    80005f92:	fffff097          	auipc	ra,0xfffff
    80005f96:	a06080e7          	jalr	-1530(ra) # 80004998 <nameiparent>
    80005f9a:	84aa                	mv	s1,a0
    80005f9c:	c979                	beqz	a0,80006072 <sys_unlink+0x114>
  ilock(dp);
    80005f9e:	ffffe097          	auipc	ra,0xffffe
    80005fa2:	236080e7          	jalr	566(ra) # 800041d4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005fa6:	00003597          	auipc	a1,0x3
    80005faa:	9fa58593          	addi	a1,a1,-1542 # 800089a0 <syscall_names+0x2c8>
    80005fae:	fb040513          	addi	a0,s0,-80
    80005fb2:	ffffe097          	auipc	ra,0xffffe
    80005fb6:	6ec080e7          	jalr	1772(ra) # 8000469e <namecmp>
    80005fba:	14050a63          	beqz	a0,8000610e <sys_unlink+0x1b0>
    80005fbe:	00003597          	auipc	a1,0x3
    80005fc2:	9ea58593          	addi	a1,a1,-1558 # 800089a8 <syscall_names+0x2d0>
    80005fc6:	fb040513          	addi	a0,s0,-80
    80005fca:	ffffe097          	auipc	ra,0xffffe
    80005fce:	6d4080e7          	jalr	1748(ra) # 8000469e <namecmp>
    80005fd2:	12050e63          	beqz	a0,8000610e <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005fd6:	f2c40613          	addi	a2,s0,-212
    80005fda:	fb040593          	addi	a1,s0,-80
    80005fde:	8526                	mv	a0,s1
    80005fe0:	ffffe097          	auipc	ra,0xffffe
    80005fe4:	6d8080e7          	jalr	1752(ra) # 800046b8 <dirlookup>
    80005fe8:	892a                	mv	s2,a0
    80005fea:	12050263          	beqz	a0,8000610e <sys_unlink+0x1b0>
  ilock(ip);
    80005fee:	ffffe097          	auipc	ra,0xffffe
    80005ff2:	1e6080e7          	jalr	486(ra) # 800041d4 <ilock>
  if(ip->nlink < 1)
    80005ff6:	04a91783          	lh	a5,74(s2)
    80005ffa:	08f05263          	blez	a5,8000607e <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005ffe:	04491703          	lh	a4,68(s2)
    80006002:	4785                	li	a5,1
    80006004:	08f70563          	beq	a4,a5,8000608e <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80006008:	4641                	li	a2,16
    8000600a:	4581                	li	a1,0
    8000600c:	fc040513          	addi	a0,s0,-64
    80006010:	ffffb097          	auipc	ra,0xffffb
    80006014:	e58080e7          	jalr	-424(ra) # 80000e68 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006018:	4741                	li	a4,16
    8000601a:	f2c42683          	lw	a3,-212(s0)
    8000601e:	fc040613          	addi	a2,s0,-64
    80006022:	4581                	li	a1,0
    80006024:	8526                	mv	a0,s1
    80006026:	ffffe097          	auipc	ra,0xffffe
    8000602a:	55a080e7          	jalr	1370(ra) # 80004580 <writei>
    8000602e:	47c1                	li	a5,16
    80006030:	0af51563          	bne	a0,a5,800060da <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80006034:	04491703          	lh	a4,68(s2)
    80006038:	4785                	li	a5,1
    8000603a:	0af70863          	beq	a4,a5,800060ea <sys_unlink+0x18c>
  iunlockput(dp);
    8000603e:	8526                	mv	a0,s1
    80006040:	ffffe097          	auipc	ra,0xffffe
    80006044:	3f6080e7          	jalr	1014(ra) # 80004436 <iunlockput>
  ip->nlink--;
    80006048:	04a95783          	lhu	a5,74(s2)
    8000604c:	37fd                	addiw	a5,a5,-1
    8000604e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80006052:	854a                	mv	a0,s2
    80006054:	ffffe097          	auipc	ra,0xffffe
    80006058:	0b4080e7          	jalr	180(ra) # 80004108 <iupdate>
  iunlockput(ip);
    8000605c:	854a                	mv	a0,s2
    8000605e:	ffffe097          	auipc	ra,0xffffe
    80006062:	3d8080e7          	jalr	984(ra) # 80004436 <iunlockput>
  end_op();
    80006066:	fffff097          	auipc	ra,0xfffff
    8000606a:	b8e080e7          	jalr	-1138(ra) # 80004bf4 <end_op>
  return 0;
    8000606e:	4501                	li	a0,0
    80006070:	a84d                	j	80006122 <sys_unlink+0x1c4>
    end_op();
    80006072:	fffff097          	auipc	ra,0xfffff
    80006076:	b82080e7          	jalr	-1150(ra) # 80004bf4 <end_op>
    return -1;
    8000607a:	557d                	li	a0,-1
    8000607c:	a05d                	j	80006122 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000607e:	00003517          	auipc	a0,0x3
    80006082:	93250513          	addi	a0,a0,-1742 # 800089b0 <syscall_names+0x2d8>
    80006086:	ffffa097          	auipc	ra,0xffffa
    8000608a:	4b6080e7          	jalr	1206(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000608e:	04c92703          	lw	a4,76(s2)
    80006092:	02000793          	li	a5,32
    80006096:	f6e7f9e3          	bgeu	a5,a4,80006008 <sys_unlink+0xaa>
    8000609a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000609e:	4741                	li	a4,16
    800060a0:	86ce                	mv	a3,s3
    800060a2:	f1840613          	addi	a2,s0,-232
    800060a6:	4581                	li	a1,0
    800060a8:	854a                	mv	a0,s2
    800060aa:	ffffe097          	auipc	ra,0xffffe
    800060ae:	3de080e7          	jalr	990(ra) # 80004488 <readi>
    800060b2:	47c1                	li	a5,16
    800060b4:	00f51b63          	bne	a0,a5,800060ca <sys_unlink+0x16c>
    if(de.inum != 0)
    800060b8:	f1845783          	lhu	a5,-232(s0)
    800060bc:	e7a1                	bnez	a5,80006104 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800060be:	29c1                	addiw	s3,s3,16
    800060c0:	04c92783          	lw	a5,76(s2)
    800060c4:	fcf9ede3          	bltu	s3,a5,8000609e <sys_unlink+0x140>
    800060c8:	b781                	j	80006008 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800060ca:	00003517          	auipc	a0,0x3
    800060ce:	8fe50513          	addi	a0,a0,-1794 # 800089c8 <syscall_names+0x2f0>
    800060d2:	ffffa097          	auipc	ra,0xffffa
    800060d6:	46a080e7          	jalr	1130(ra) # 8000053c <panic>
    panic("unlink: writei");
    800060da:	00003517          	auipc	a0,0x3
    800060de:	90650513          	addi	a0,a0,-1786 # 800089e0 <syscall_names+0x308>
    800060e2:	ffffa097          	auipc	ra,0xffffa
    800060e6:	45a080e7          	jalr	1114(ra) # 8000053c <panic>
    dp->nlink--;
    800060ea:	04a4d783          	lhu	a5,74(s1)
    800060ee:	37fd                	addiw	a5,a5,-1
    800060f0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800060f4:	8526                	mv	a0,s1
    800060f6:	ffffe097          	auipc	ra,0xffffe
    800060fa:	012080e7          	jalr	18(ra) # 80004108 <iupdate>
    800060fe:	b781                	j	8000603e <sys_unlink+0xe0>
    return -1;
    80006100:	557d                	li	a0,-1
    80006102:	a005                	j	80006122 <sys_unlink+0x1c4>
    iunlockput(ip);
    80006104:	854a                	mv	a0,s2
    80006106:	ffffe097          	auipc	ra,0xffffe
    8000610a:	330080e7          	jalr	816(ra) # 80004436 <iunlockput>
  iunlockput(dp);
    8000610e:	8526                	mv	a0,s1
    80006110:	ffffe097          	auipc	ra,0xffffe
    80006114:	326080e7          	jalr	806(ra) # 80004436 <iunlockput>
  end_op();
    80006118:	fffff097          	auipc	ra,0xfffff
    8000611c:	adc080e7          	jalr	-1316(ra) # 80004bf4 <end_op>
  return -1;
    80006120:	557d                	li	a0,-1
}
    80006122:	70ae                	ld	ra,232(sp)
    80006124:	740e                	ld	s0,224(sp)
    80006126:	64ee                	ld	s1,216(sp)
    80006128:	694e                	ld	s2,208(sp)
    8000612a:	69ae                	ld	s3,200(sp)
    8000612c:	616d                	addi	sp,sp,240
    8000612e:	8082                	ret

0000000080006130 <sys_open>:

uint64
sys_open(void)
{
    80006130:	7131                	addi	sp,sp,-192
    80006132:	fd06                	sd	ra,184(sp)
    80006134:	f922                	sd	s0,176(sp)
    80006136:	f526                	sd	s1,168(sp)
    80006138:	f14a                	sd	s2,160(sp)
    8000613a:	ed4e                	sd	s3,152(sp)
    8000613c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000613e:	f4c40593          	addi	a1,s0,-180
    80006142:	4505                	li	a0,1
    80006144:	ffffd097          	auipc	ra,0xffffd
    80006148:	1c8080e7          	jalr	456(ra) # 8000330c <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000614c:	08000613          	li	a2,128
    80006150:	f5040593          	addi	a1,s0,-176
    80006154:	4501                	li	a0,0
    80006156:	ffffd097          	auipc	ra,0xffffd
    8000615a:	1f6080e7          	jalr	502(ra) # 8000334c <argstr>
    8000615e:	87aa                	mv	a5,a0
    return -1;
    80006160:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80006162:	0a07c863          	bltz	a5,80006212 <sys_open+0xe2>

  begin_op();
    80006166:	fffff097          	auipc	ra,0xfffff
    8000616a:	a14080e7          	jalr	-1516(ra) # 80004b7a <begin_op>

  if(omode & O_CREATE){
    8000616e:	f4c42783          	lw	a5,-180(s0)
    80006172:	2007f793          	andi	a5,a5,512
    80006176:	cbdd                	beqz	a5,8000622c <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    80006178:	4681                	li	a3,0
    8000617a:	4601                	li	a2,0
    8000617c:	4589                	li	a1,2
    8000617e:	f5040513          	addi	a0,s0,-176
    80006182:	00000097          	auipc	ra,0x0
    80006186:	97a080e7          	jalr	-1670(ra) # 80005afc <create>
    8000618a:	84aa                	mv	s1,a0
    if(ip == 0){
    8000618c:	c951                	beqz	a0,80006220 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000618e:	04449703          	lh	a4,68(s1)
    80006192:	478d                	li	a5,3
    80006194:	00f71763          	bne	a4,a5,800061a2 <sys_open+0x72>
    80006198:	0464d703          	lhu	a4,70(s1)
    8000619c:	47a5                	li	a5,9
    8000619e:	0ce7ec63          	bltu	a5,a4,80006276 <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800061a2:	fffff097          	auipc	ra,0xfffff
    800061a6:	de0080e7          	jalr	-544(ra) # 80004f82 <filealloc>
    800061aa:	892a                	mv	s2,a0
    800061ac:	c56d                	beqz	a0,80006296 <sys_open+0x166>
    800061ae:	00000097          	auipc	ra,0x0
    800061b2:	90c080e7          	jalr	-1780(ra) # 80005aba <fdalloc>
    800061b6:	89aa                	mv	s3,a0
    800061b8:	0c054a63          	bltz	a0,8000628c <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800061bc:	04449703          	lh	a4,68(s1)
    800061c0:	478d                	li	a5,3
    800061c2:	0ef70563          	beq	a4,a5,800062ac <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800061c6:	4789                	li	a5,2
    800061c8:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800061cc:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800061d0:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800061d4:	f4c42783          	lw	a5,-180(s0)
    800061d8:	0017c713          	xori	a4,a5,1
    800061dc:	8b05                	andi	a4,a4,1
    800061de:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800061e2:	0037f713          	andi	a4,a5,3
    800061e6:	00e03733          	snez	a4,a4
    800061ea:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800061ee:	4007f793          	andi	a5,a5,1024
    800061f2:	c791                	beqz	a5,800061fe <sys_open+0xce>
    800061f4:	04449703          	lh	a4,68(s1)
    800061f8:	4789                	li	a5,2
    800061fa:	0cf70063          	beq	a4,a5,800062ba <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    800061fe:	8526                	mv	a0,s1
    80006200:	ffffe097          	auipc	ra,0xffffe
    80006204:	096080e7          	jalr	150(ra) # 80004296 <iunlock>
  end_op();
    80006208:	fffff097          	auipc	ra,0xfffff
    8000620c:	9ec080e7          	jalr	-1556(ra) # 80004bf4 <end_op>

  return fd;
    80006210:	854e                	mv	a0,s3
}
    80006212:	70ea                	ld	ra,184(sp)
    80006214:	744a                	ld	s0,176(sp)
    80006216:	74aa                	ld	s1,168(sp)
    80006218:	790a                	ld	s2,160(sp)
    8000621a:	69ea                	ld	s3,152(sp)
    8000621c:	6129                	addi	sp,sp,192
    8000621e:	8082                	ret
      end_op();
    80006220:	fffff097          	auipc	ra,0xfffff
    80006224:	9d4080e7          	jalr	-1580(ra) # 80004bf4 <end_op>
      return -1;
    80006228:	557d                	li	a0,-1
    8000622a:	b7e5                	j	80006212 <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    8000622c:	f5040513          	addi	a0,s0,-176
    80006230:	ffffe097          	auipc	ra,0xffffe
    80006234:	74a080e7          	jalr	1866(ra) # 8000497a <namei>
    80006238:	84aa                	mv	s1,a0
    8000623a:	c905                	beqz	a0,8000626a <sys_open+0x13a>
    ilock(ip);
    8000623c:	ffffe097          	auipc	ra,0xffffe
    80006240:	f98080e7          	jalr	-104(ra) # 800041d4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80006244:	04449703          	lh	a4,68(s1)
    80006248:	4785                	li	a5,1
    8000624a:	f4f712e3          	bne	a4,a5,8000618e <sys_open+0x5e>
    8000624e:	f4c42783          	lw	a5,-180(s0)
    80006252:	dba1                	beqz	a5,800061a2 <sys_open+0x72>
      iunlockput(ip);
    80006254:	8526                	mv	a0,s1
    80006256:	ffffe097          	auipc	ra,0xffffe
    8000625a:	1e0080e7          	jalr	480(ra) # 80004436 <iunlockput>
      end_op();
    8000625e:	fffff097          	auipc	ra,0xfffff
    80006262:	996080e7          	jalr	-1642(ra) # 80004bf4 <end_op>
      return -1;
    80006266:	557d                	li	a0,-1
    80006268:	b76d                	j	80006212 <sys_open+0xe2>
      end_op();
    8000626a:	fffff097          	auipc	ra,0xfffff
    8000626e:	98a080e7          	jalr	-1654(ra) # 80004bf4 <end_op>
      return -1;
    80006272:	557d                	li	a0,-1
    80006274:	bf79                	j	80006212 <sys_open+0xe2>
    iunlockput(ip);
    80006276:	8526                	mv	a0,s1
    80006278:	ffffe097          	auipc	ra,0xffffe
    8000627c:	1be080e7          	jalr	446(ra) # 80004436 <iunlockput>
    end_op();
    80006280:	fffff097          	auipc	ra,0xfffff
    80006284:	974080e7          	jalr	-1676(ra) # 80004bf4 <end_op>
    return -1;
    80006288:	557d                	li	a0,-1
    8000628a:	b761                	j	80006212 <sys_open+0xe2>
      fileclose(f);
    8000628c:	854a                	mv	a0,s2
    8000628e:	fffff097          	auipc	ra,0xfffff
    80006292:	db0080e7          	jalr	-592(ra) # 8000503e <fileclose>
    iunlockput(ip);
    80006296:	8526                	mv	a0,s1
    80006298:	ffffe097          	auipc	ra,0xffffe
    8000629c:	19e080e7          	jalr	414(ra) # 80004436 <iunlockput>
    end_op();
    800062a0:	fffff097          	auipc	ra,0xfffff
    800062a4:	954080e7          	jalr	-1708(ra) # 80004bf4 <end_op>
    return -1;
    800062a8:	557d                	li	a0,-1
    800062aa:	b7a5                	j	80006212 <sys_open+0xe2>
    f->type = FD_DEVICE;
    800062ac:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800062b0:	04649783          	lh	a5,70(s1)
    800062b4:	02f91223          	sh	a5,36(s2)
    800062b8:	bf21                	j	800061d0 <sys_open+0xa0>
    itrunc(ip);
    800062ba:	8526                	mv	a0,s1
    800062bc:	ffffe097          	auipc	ra,0xffffe
    800062c0:	026080e7          	jalr	38(ra) # 800042e2 <itrunc>
    800062c4:	bf2d                	j	800061fe <sys_open+0xce>

00000000800062c6 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800062c6:	7175                	addi	sp,sp,-144
    800062c8:	e506                	sd	ra,136(sp)
    800062ca:	e122                	sd	s0,128(sp)
    800062cc:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800062ce:	fffff097          	auipc	ra,0xfffff
    800062d2:	8ac080e7          	jalr	-1876(ra) # 80004b7a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800062d6:	08000613          	li	a2,128
    800062da:	f7040593          	addi	a1,s0,-144
    800062de:	4501                	li	a0,0
    800062e0:	ffffd097          	auipc	ra,0xffffd
    800062e4:	06c080e7          	jalr	108(ra) # 8000334c <argstr>
    800062e8:	02054963          	bltz	a0,8000631a <sys_mkdir+0x54>
    800062ec:	4681                	li	a3,0
    800062ee:	4601                	li	a2,0
    800062f0:	4585                	li	a1,1
    800062f2:	f7040513          	addi	a0,s0,-144
    800062f6:	00000097          	auipc	ra,0x0
    800062fa:	806080e7          	jalr	-2042(ra) # 80005afc <create>
    800062fe:	cd11                	beqz	a0,8000631a <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006300:	ffffe097          	auipc	ra,0xffffe
    80006304:	136080e7          	jalr	310(ra) # 80004436 <iunlockput>
  end_op();
    80006308:	fffff097          	auipc	ra,0xfffff
    8000630c:	8ec080e7          	jalr	-1812(ra) # 80004bf4 <end_op>
  return 0;
    80006310:	4501                	li	a0,0
}
    80006312:	60aa                	ld	ra,136(sp)
    80006314:	640a                	ld	s0,128(sp)
    80006316:	6149                	addi	sp,sp,144
    80006318:	8082                	ret
    end_op();
    8000631a:	fffff097          	auipc	ra,0xfffff
    8000631e:	8da080e7          	jalr	-1830(ra) # 80004bf4 <end_op>
    return -1;
    80006322:	557d                	li	a0,-1
    80006324:	b7fd                	j	80006312 <sys_mkdir+0x4c>

0000000080006326 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006326:	7135                	addi	sp,sp,-160
    80006328:	ed06                	sd	ra,152(sp)
    8000632a:	e922                	sd	s0,144(sp)
    8000632c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000632e:	fffff097          	auipc	ra,0xfffff
    80006332:	84c080e7          	jalr	-1972(ra) # 80004b7a <begin_op>
  argint(1, &major);
    80006336:	f6c40593          	addi	a1,s0,-148
    8000633a:	4505                	li	a0,1
    8000633c:	ffffd097          	auipc	ra,0xffffd
    80006340:	fd0080e7          	jalr	-48(ra) # 8000330c <argint>
  argint(2, &minor);
    80006344:	f6840593          	addi	a1,s0,-152
    80006348:	4509                	li	a0,2
    8000634a:	ffffd097          	auipc	ra,0xffffd
    8000634e:	fc2080e7          	jalr	-62(ra) # 8000330c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006352:	08000613          	li	a2,128
    80006356:	f7040593          	addi	a1,s0,-144
    8000635a:	4501                	li	a0,0
    8000635c:	ffffd097          	auipc	ra,0xffffd
    80006360:	ff0080e7          	jalr	-16(ra) # 8000334c <argstr>
    80006364:	02054b63          	bltz	a0,8000639a <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006368:	f6841683          	lh	a3,-152(s0)
    8000636c:	f6c41603          	lh	a2,-148(s0)
    80006370:	458d                	li	a1,3
    80006372:	f7040513          	addi	a0,s0,-144
    80006376:	fffff097          	auipc	ra,0xfffff
    8000637a:	786080e7          	jalr	1926(ra) # 80005afc <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000637e:	cd11                	beqz	a0,8000639a <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006380:	ffffe097          	auipc	ra,0xffffe
    80006384:	0b6080e7          	jalr	182(ra) # 80004436 <iunlockput>
  end_op();
    80006388:	fffff097          	auipc	ra,0xfffff
    8000638c:	86c080e7          	jalr	-1940(ra) # 80004bf4 <end_op>
  return 0;
    80006390:	4501                	li	a0,0
}
    80006392:	60ea                	ld	ra,152(sp)
    80006394:	644a                	ld	s0,144(sp)
    80006396:	610d                	addi	sp,sp,160
    80006398:	8082                	ret
    end_op();
    8000639a:	fffff097          	auipc	ra,0xfffff
    8000639e:	85a080e7          	jalr	-1958(ra) # 80004bf4 <end_op>
    return -1;
    800063a2:	557d                	li	a0,-1
    800063a4:	b7fd                	j	80006392 <sys_mknod+0x6c>

00000000800063a6 <sys_chdir>:

uint64
sys_chdir(void)
{
    800063a6:	7135                	addi	sp,sp,-160
    800063a8:	ed06                	sd	ra,152(sp)
    800063aa:	e922                	sd	s0,144(sp)
    800063ac:	e526                	sd	s1,136(sp)
    800063ae:	e14a                	sd	s2,128(sp)
    800063b0:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800063b2:	ffffc097          	auipc	ra,0xffffc
    800063b6:	818080e7          	jalr	-2024(ra) # 80001bca <myproc>
    800063ba:	892a                	mv	s2,a0
  
  begin_op();
    800063bc:	ffffe097          	auipc	ra,0xffffe
    800063c0:	7be080e7          	jalr	1982(ra) # 80004b7a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800063c4:	08000613          	li	a2,128
    800063c8:	f6040593          	addi	a1,s0,-160
    800063cc:	4501                	li	a0,0
    800063ce:	ffffd097          	auipc	ra,0xffffd
    800063d2:	f7e080e7          	jalr	-130(ra) # 8000334c <argstr>
    800063d6:	04054b63          	bltz	a0,8000642c <sys_chdir+0x86>
    800063da:	f6040513          	addi	a0,s0,-160
    800063de:	ffffe097          	auipc	ra,0xffffe
    800063e2:	59c080e7          	jalr	1436(ra) # 8000497a <namei>
    800063e6:	84aa                	mv	s1,a0
    800063e8:	c131                	beqz	a0,8000642c <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800063ea:	ffffe097          	auipc	ra,0xffffe
    800063ee:	dea080e7          	jalr	-534(ra) # 800041d4 <ilock>
  if(ip->type != T_DIR){
    800063f2:	04449703          	lh	a4,68(s1)
    800063f6:	4785                	li	a5,1
    800063f8:	04f71063          	bne	a4,a5,80006438 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800063fc:	8526                	mv	a0,s1
    800063fe:	ffffe097          	auipc	ra,0xffffe
    80006402:	e98080e7          	jalr	-360(ra) # 80004296 <iunlock>
  iput(p->cwd);
    80006406:	15093503          	ld	a0,336(s2)
    8000640a:	ffffe097          	auipc	ra,0xffffe
    8000640e:	f84080e7          	jalr	-124(ra) # 8000438e <iput>
  end_op();
    80006412:	ffffe097          	auipc	ra,0xffffe
    80006416:	7e2080e7          	jalr	2018(ra) # 80004bf4 <end_op>
  p->cwd = ip;
    8000641a:	14993823          	sd	s1,336(s2)
  return 0;
    8000641e:	4501                	li	a0,0
}
    80006420:	60ea                	ld	ra,152(sp)
    80006422:	644a                	ld	s0,144(sp)
    80006424:	64aa                	ld	s1,136(sp)
    80006426:	690a                	ld	s2,128(sp)
    80006428:	610d                	addi	sp,sp,160
    8000642a:	8082                	ret
    end_op();
    8000642c:	ffffe097          	auipc	ra,0xffffe
    80006430:	7c8080e7          	jalr	1992(ra) # 80004bf4 <end_op>
    return -1;
    80006434:	557d                	li	a0,-1
    80006436:	b7ed                	j	80006420 <sys_chdir+0x7a>
    iunlockput(ip);
    80006438:	8526                	mv	a0,s1
    8000643a:	ffffe097          	auipc	ra,0xffffe
    8000643e:	ffc080e7          	jalr	-4(ra) # 80004436 <iunlockput>
    end_op();
    80006442:	ffffe097          	auipc	ra,0xffffe
    80006446:	7b2080e7          	jalr	1970(ra) # 80004bf4 <end_op>
    return -1;
    8000644a:	557d                	li	a0,-1
    8000644c:	bfd1                	j	80006420 <sys_chdir+0x7a>

000000008000644e <sys_exec>:

uint64
sys_exec(void)
{
    8000644e:	7121                	addi	sp,sp,-448
    80006450:	ff06                	sd	ra,440(sp)
    80006452:	fb22                	sd	s0,432(sp)
    80006454:	f726                	sd	s1,424(sp)
    80006456:	f34a                	sd	s2,416(sp)
    80006458:	ef4e                	sd	s3,408(sp)
    8000645a:	eb52                	sd	s4,400(sp)
    8000645c:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000645e:	e4840593          	addi	a1,s0,-440
    80006462:	4505                	li	a0,1
    80006464:	ffffd097          	auipc	ra,0xffffd
    80006468:	ec8080e7          	jalr	-312(ra) # 8000332c <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000646c:	08000613          	li	a2,128
    80006470:	f5040593          	addi	a1,s0,-176
    80006474:	4501                	li	a0,0
    80006476:	ffffd097          	auipc	ra,0xffffd
    8000647a:	ed6080e7          	jalr	-298(ra) # 8000334c <argstr>
    8000647e:	87aa                	mv	a5,a0
    return -1;
    80006480:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80006482:	0c07c263          	bltz	a5,80006546 <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    80006486:	10000613          	li	a2,256
    8000648a:	4581                	li	a1,0
    8000648c:	e5040513          	addi	a0,s0,-432
    80006490:	ffffb097          	auipc	ra,0xffffb
    80006494:	9d8080e7          	jalr	-1576(ra) # 80000e68 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006498:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    8000649c:	89a6                	mv	s3,s1
    8000649e:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800064a0:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800064a4:	00391513          	slli	a0,s2,0x3
    800064a8:	e4040593          	addi	a1,s0,-448
    800064ac:	e4843783          	ld	a5,-440(s0)
    800064b0:	953e                	add	a0,a0,a5
    800064b2:	ffffd097          	auipc	ra,0xffffd
    800064b6:	dbc080e7          	jalr	-580(ra) # 8000326e <fetchaddr>
    800064ba:	02054a63          	bltz	a0,800064ee <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    800064be:	e4043783          	ld	a5,-448(s0)
    800064c2:	c3b9                	beqz	a5,80006508 <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800064c4:	ffffa097          	auipc	ra,0xffffa
    800064c8:	768080e7          	jalr	1896(ra) # 80000c2c <kalloc>
    800064cc:	85aa                	mv	a1,a0
    800064ce:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800064d2:	cd11                	beqz	a0,800064ee <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800064d4:	6605                	lui	a2,0x1
    800064d6:	e4043503          	ld	a0,-448(s0)
    800064da:	ffffd097          	auipc	ra,0xffffd
    800064de:	de6080e7          	jalr	-538(ra) # 800032c0 <fetchstr>
    800064e2:	00054663          	bltz	a0,800064ee <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    800064e6:	0905                	addi	s2,s2,1
    800064e8:	09a1                	addi	s3,s3,8
    800064ea:	fb491de3          	bne	s2,s4,800064a4 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800064ee:	f5040913          	addi	s2,s0,-176
    800064f2:	6088                	ld	a0,0(s1)
    800064f4:	c921                	beqz	a0,80006544 <sys_exec+0xf6>
    kfree(argv[i]);
    800064f6:	ffffa097          	auipc	ra,0xffffa
    800064fa:	5a0080e7          	jalr	1440(ra) # 80000a96 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800064fe:	04a1                	addi	s1,s1,8
    80006500:	ff2499e3          	bne	s1,s2,800064f2 <sys_exec+0xa4>
  return -1;
    80006504:	557d                	li	a0,-1
    80006506:	a081                	j	80006546 <sys_exec+0xf8>
      argv[i] = 0;
    80006508:	0009079b          	sext.w	a5,s2
    8000650c:	078e                	slli	a5,a5,0x3
    8000650e:	fd078793          	addi	a5,a5,-48
    80006512:	97a2                	add	a5,a5,s0
    80006514:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80006518:	e5040593          	addi	a1,s0,-432
    8000651c:	f5040513          	addi	a0,s0,-176
    80006520:	fffff097          	auipc	ra,0xfffff
    80006524:	194080e7          	jalr	404(ra) # 800056b4 <exec>
    80006528:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000652a:	f5040993          	addi	s3,s0,-176
    8000652e:	6088                	ld	a0,0(s1)
    80006530:	c901                	beqz	a0,80006540 <sys_exec+0xf2>
    kfree(argv[i]);
    80006532:	ffffa097          	auipc	ra,0xffffa
    80006536:	564080e7          	jalr	1380(ra) # 80000a96 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000653a:	04a1                	addi	s1,s1,8
    8000653c:	ff3499e3          	bne	s1,s3,8000652e <sys_exec+0xe0>
  return ret;
    80006540:	854a                	mv	a0,s2
    80006542:	a011                	j	80006546 <sys_exec+0xf8>
  return -1;
    80006544:	557d                	li	a0,-1
}
    80006546:	70fa                	ld	ra,440(sp)
    80006548:	745a                	ld	s0,432(sp)
    8000654a:	74ba                	ld	s1,424(sp)
    8000654c:	791a                	ld	s2,416(sp)
    8000654e:	69fa                	ld	s3,408(sp)
    80006550:	6a5a                	ld	s4,400(sp)
    80006552:	6139                	addi	sp,sp,448
    80006554:	8082                	ret

0000000080006556 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006556:	7139                	addi	sp,sp,-64
    80006558:	fc06                	sd	ra,56(sp)
    8000655a:	f822                	sd	s0,48(sp)
    8000655c:	f426                	sd	s1,40(sp)
    8000655e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006560:	ffffb097          	auipc	ra,0xffffb
    80006564:	66a080e7          	jalr	1642(ra) # 80001bca <myproc>
    80006568:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000656a:	fd840593          	addi	a1,s0,-40
    8000656e:	4501                	li	a0,0
    80006570:	ffffd097          	auipc	ra,0xffffd
    80006574:	dbc080e7          	jalr	-580(ra) # 8000332c <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80006578:	fc840593          	addi	a1,s0,-56
    8000657c:	fd040513          	addi	a0,s0,-48
    80006580:	fffff097          	auipc	ra,0xfffff
    80006584:	dea080e7          	jalr	-534(ra) # 8000536a <pipealloc>
    return -1;
    80006588:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000658a:	0c054463          	bltz	a0,80006652 <sys_pipe+0xfc>
  fd0 = -1;
    8000658e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006592:	fd043503          	ld	a0,-48(s0)
    80006596:	fffff097          	auipc	ra,0xfffff
    8000659a:	524080e7          	jalr	1316(ra) # 80005aba <fdalloc>
    8000659e:	fca42223          	sw	a0,-60(s0)
    800065a2:	08054b63          	bltz	a0,80006638 <sys_pipe+0xe2>
    800065a6:	fc843503          	ld	a0,-56(s0)
    800065aa:	fffff097          	auipc	ra,0xfffff
    800065ae:	510080e7          	jalr	1296(ra) # 80005aba <fdalloc>
    800065b2:	fca42023          	sw	a0,-64(s0)
    800065b6:	06054863          	bltz	a0,80006626 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800065ba:	4691                	li	a3,4
    800065bc:	fc440613          	addi	a2,s0,-60
    800065c0:	fd843583          	ld	a1,-40(s0)
    800065c4:	68a8                	ld	a0,80(s1)
    800065c6:	ffffb097          	auipc	ra,0xffffb
    800065ca:	24a080e7          	jalr	586(ra) # 80001810 <copyout>
    800065ce:	02054063          	bltz	a0,800065ee <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800065d2:	4691                	li	a3,4
    800065d4:	fc040613          	addi	a2,s0,-64
    800065d8:	fd843583          	ld	a1,-40(s0)
    800065dc:	0591                	addi	a1,a1,4
    800065de:	68a8                	ld	a0,80(s1)
    800065e0:	ffffb097          	auipc	ra,0xffffb
    800065e4:	230080e7          	jalr	560(ra) # 80001810 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800065e8:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800065ea:	06055463          	bgez	a0,80006652 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    800065ee:	fc442783          	lw	a5,-60(s0)
    800065f2:	07e9                	addi	a5,a5,26
    800065f4:	078e                	slli	a5,a5,0x3
    800065f6:	97a6                	add	a5,a5,s1
    800065f8:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800065fc:	fc042783          	lw	a5,-64(s0)
    80006600:	07e9                	addi	a5,a5,26
    80006602:	078e                	slli	a5,a5,0x3
    80006604:	94be                	add	s1,s1,a5
    80006606:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000660a:	fd043503          	ld	a0,-48(s0)
    8000660e:	fffff097          	auipc	ra,0xfffff
    80006612:	a30080e7          	jalr	-1488(ra) # 8000503e <fileclose>
    fileclose(wf);
    80006616:	fc843503          	ld	a0,-56(s0)
    8000661a:	fffff097          	auipc	ra,0xfffff
    8000661e:	a24080e7          	jalr	-1500(ra) # 8000503e <fileclose>
    return -1;
    80006622:	57fd                	li	a5,-1
    80006624:	a03d                	j	80006652 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80006626:	fc442783          	lw	a5,-60(s0)
    8000662a:	0007c763          	bltz	a5,80006638 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    8000662e:	07e9                	addi	a5,a5,26
    80006630:	078e                	slli	a5,a5,0x3
    80006632:	97a6                	add	a5,a5,s1
    80006634:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80006638:	fd043503          	ld	a0,-48(s0)
    8000663c:	fffff097          	auipc	ra,0xfffff
    80006640:	a02080e7          	jalr	-1534(ra) # 8000503e <fileclose>
    fileclose(wf);
    80006644:	fc843503          	ld	a0,-56(s0)
    80006648:	fffff097          	auipc	ra,0xfffff
    8000664c:	9f6080e7          	jalr	-1546(ra) # 8000503e <fileclose>
    return -1;
    80006650:	57fd                	li	a5,-1
}
    80006652:	853e                	mv	a0,a5
    80006654:	70e2                	ld	ra,56(sp)
    80006656:	7442                	ld	s0,48(sp)
    80006658:	74a2                	ld	s1,40(sp)
    8000665a:	6121                	addi	sp,sp,64
    8000665c:	8082                	ret
	...

0000000080006660 <kernelvec>:
    80006660:	7111                	addi	sp,sp,-256
    80006662:	e006                	sd	ra,0(sp)
    80006664:	e40a                	sd	sp,8(sp)
    80006666:	e80e                	sd	gp,16(sp)
    80006668:	ec12                	sd	tp,24(sp)
    8000666a:	f016                	sd	t0,32(sp)
    8000666c:	f41a                	sd	t1,40(sp)
    8000666e:	f81e                	sd	t2,48(sp)
    80006670:	fc22                	sd	s0,56(sp)
    80006672:	e0a6                	sd	s1,64(sp)
    80006674:	e4aa                	sd	a0,72(sp)
    80006676:	e8ae                	sd	a1,80(sp)
    80006678:	ecb2                	sd	a2,88(sp)
    8000667a:	f0b6                	sd	a3,96(sp)
    8000667c:	f4ba                	sd	a4,104(sp)
    8000667e:	f8be                	sd	a5,112(sp)
    80006680:	fcc2                	sd	a6,120(sp)
    80006682:	e146                	sd	a7,128(sp)
    80006684:	e54a                	sd	s2,136(sp)
    80006686:	e94e                	sd	s3,144(sp)
    80006688:	ed52                	sd	s4,152(sp)
    8000668a:	f156                	sd	s5,160(sp)
    8000668c:	f55a                	sd	s6,168(sp)
    8000668e:	f95e                	sd	s7,176(sp)
    80006690:	fd62                	sd	s8,184(sp)
    80006692:	e1e6                	sd	s9,192(sp)
    80006694:	e5ea                	sd	s10,200(sp)
    80006696:	e9ee                	sd	s11,208(sp)
    80006698:	edf2                	sd	t3,216(sp)
    8000669a:	f1f6                	sd	t4,224(sp)
    8000669c:	f5fa                	sd	t5,232(sp)
    8000669e:	f9fe                	sd	t6,240(sp)
    800066a0:	ac5fc0ef          	jal	ra,80003164 <kerneltrap>
    800066a4:	6082                	ld	ra,0(sp)
    800066a6:	6122                	ld	sp,8(sp)
    800066a8:	61c2                	ld	gp,16(sp)
    800066aa:	7282                	ld	t0,32(sp)
    800066ac:	7322                	ld	t1,40(sp)
    800066ae:	73c2                	ld	t2,48(sp)
    800066b0:	7462                	ld	s0,56(sp)
    800066b2:	6486                	ld	s1,64(sp)
    800066b4:	6526                	ld	a0,72(sp)
    800066b6:	65c6                	ld	a1,80(sp)
    800066b8:	6666                	ld	a2,88(sp)
    800066ba:	7686                	ld	a3,96(sp)
    800066bc:	7726                	ld	a4,104(sp)
    800066be:	77c6                	ld	a5,112(sp)
    800066c0:	7866                	ld	a6,120(sp)
    800066c2:	688a                	ld	a7,128(sp)
    800066c4:	692a                	ld	s2,136(sp)
    800066c6:	69ca                	ld	s3,144(sp)
    800066c8:	6a6a                	ld	s4,152(sp)
    800066ca:	7a8a                	ld	s5,160(sp)
    800066cc:	7b2a                	ld	s6,168(sp)
    800066ce:	7bca                	ld	s7,176(sp)
    800066d0:	7c6a                	ld	s8,184(sp)
    800066d2:	6c8e                	ld	s9,192(sp)
    800066d4:	6d2e                	ld	s10,200(sp)
    800066d6:	6dce                	ld	s11,208(sp)
    800066d8:	6e6e                	ld	t3,216(sp)
    800066da:	7e8e                	ld	t4,224(sp)
    800066dc:	7f2e                	ld	t5,232(sp)
    800066de:	7fce                	ld	t6,240(sp)
    800066e0:	6111                	addi	sp,sp,256
    800066e2:	10200073          	sret
    800066e6:	00000013          	nop
    800066ea:	00000013          	nop
    800066ee:	0001                	nop

00000000800066f0 <timervec>:
    800066f0:	34051573          	csrrw	a0,mscratch,a0
    800066f4:	e10c                	sd	a1,0(a0)
    800066f6:	e510                	sd	a2,8(a0)
    800066f8:	e914                	sd	a3,16(a0)
    800066fa:	6d0c                	ld	a1,24(a0)
    800066fc:	7110                	ld	a2,32(a0)
    800066fe:	6194                	ld	a3,0(a1)
    80006700:	96b2                	add	a3,a3,a2
    80006702:	e194                	sd	a3,0(a1)
    80006704:	4589                	li	a1,2
    80006706:	14459073          	csrw	sip,a1
    8000670a:	6914                	ld	a3,16(a0)
    8000670c:	6510                	ld	a2,8(a0)
    8000670e:	610c                	ld	a1,0(a0)
    80006710:	34051573          	csrrw	a0,mscratch,a0
    80006714:	30200073          	mret
	...

000000008000671a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000671a:	1141                	addi	sp,sp,-16
    8000671c:	e422                	sd	s0,8(sp)
    8000671e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006720:	0c0007b7          	lui	a5,0xc000
    80006724:	4705                	li	a4,1
    80006726:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006728:	c3d8                	sw	a4,4(a5)
}
    8000672a:	6422                	ld	s0,8(sp)
    8000672c:	0141                	addi	sp,sp,16
    8000672e:	8082                	ret

0000000080006730 <plicinithart>:

void
plicinithart(void)
{
    80006730:	1141                	addi	sp,sp,-16
    80006732:	e406                	sd	ra,8(sp)
    80006734:	e022                	sd	s0,0(sp)
    80006736:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006738:	ffffb097          	auipc	ra,0xffffb
    8000673c:	466080e7          	jalr	1126(ra) # 80001b9e <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006740:	0085171b          	slliw	a4,a0,0x8
    80006744:	0c0027b7          	lui	a5,0xc002
    80006748:	97ba                	add	a5,a5,a4
    8000674a:	40200713          	li	a4,1026
    8000674e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006752:	00d5151b          	slliw	a0,a0,0xd
    80006756:	0c2017b7          	lui	a5,0xc201
    8000675a:	97aa                	add	a5,a5,a0
    8000675c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006760:	60a2                	ld	ra,8(sp)
    80006762:	6402                	ld	s0,0(sp)
    80006764:	0141                	addi	sp,sp,16
    80006766:	8082                	ret

0000000080006768 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006768:	1141                	addi	sp,sp,-16
    8000676a:	e406                	sd	ra,8(sp)
    8000676c:	e022                	sd	s0,0(sp)
    8000676e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006770:	ffffb097          	auipc	ra,0xffffb
    80006774:	42e080e7          	jalr	1070(ra) # 80001b9e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006778:	00d5151b          	slliw	a0,a0,0xd
    8000677c:	0c2017b7          	lui	a5,0xc201
    80006780:	97aa                	add	a5,a5,a0
  return irq;
}
    80006782:	43c8                	lw	a0,4(a5)
    80006784:	60a2                	ld	ra,8(sp)
    80006786:	6402                	ld	s0,0(sp)
    80006788:	0141                	addi	sp,sp,16
    8000678a:	8082                	ret

000000008000678c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000678c:	1101                	addi	sp,sp,-32
    8000678e:	ec06                	sd	ra,24(sp)
    80006790:	e822                	sd	s0,16(sp)
    80006792:	e426                	sd	s1,8(sp)
    80006794:	1000                	addi	s0,sp,32
    80006796:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006798:	ffffb097          	auipc	ra,0xffffb
    8000679c:	406080e7          	jalr	1030(ra) # 80001b9e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800067a0:	00d5151b          	slliw	a0,a0,0xd
    800067a4:	0c2017b7          	lui	a5,0xc201
    800067a8:	97aa                	add	a5,a5,a0
    800067aa:	c3c4                	sw	s1,4(a5)
}
    800067ac:	60e2                	ld	ra,24(sp)
    800067ae:	6442                	ld	s0,16(sp)
    800067b0:	64a2                	ld	s1,8(sp)
    800067b2:	6105                	addi	sp,sp,32
    800067b4:	8082                	ret

00000000800067b6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800067b6:	1141                	addi	sp,sp,-16
    800067b8:	e406                	sd	ra,8(sp)
    800067ba:	e022                	sd	s0,0(sp)
    800067bc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800067be:	479d                	li	a5,7
    800067c0:	04a7cc63          	blt	a5,a0,80006818 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800067c4:	0004a797          	auipc	a5,0x4a
    800067c8:	f0c78793          	addi	a5,a5,-244 # 800506d0 <disk>
    800067cc:	97aa                	add	a5,a5,a0
    800067ce:	0187c783          	lbu	a5,24(a5)
    800067d2:	ebb9                	bnez	a5,80006828 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800067d4:	00451693          	slli	a3,a0,0x4
    800067d8:	0004a797          	auipc	a5,0x4a
    800067dc:	ef878793          	addi	a5,a5,-264 # 800506d0 <disk>
    800067e0:	6398                	ld	a4,0(a5)
    800067e2:	9736                	add	a4,a4,a3
    800067e4:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800067e8:	6398                	ld	a4,0(a5)
    800067ea:	9736                	add	a4,a4,a3
    800067ec:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800067f0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800067f4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800067f8:	97aa                	add	a5,a5,a0
    800067fa:	4705                	li	a4,1
    800067fc:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006800:	0004a517          	auipc	a0,0x4a
    80006804:	ee850513          	addi	a0,a0,-280 # 800506e8 <disk+0x18>
    80006808:	ffffc097          	auipc	ra,0xffffc
    8000680c:	eb2080e7          	jalr	-334(ra) # 800026ba <wakeup>
}
    80006810:	60a2                	ld	ra,8(sp)
    80006812:	6402                	ld	s0,0(sp)
    80006814:	0141                	addi	sp,sp,16
    80006816:	8082                	ret
    panic("free_desc 1");
    80006818:	00002517          	auipc	a0,0x2
    8000681c:	1d850513          	addi	a0,a0,472 # 800089f0 <syscall_names+0x318>
    80006820:	ffffa097          	auipc	ra,0xffffa
    80006824:	d1c080e7          	jalr	-740(ra) # 8000053c <panic>
    panic("free_desc 2");
    80006828:	00002517          	auipc	a0,0x2
    8000682c:	1d850513          	addi	a0,a0,472 # 80008a00 <syscall_names+0x328>
    80006830:	ffffa097          	auipc	ra,0xffffa
    80006834:	d0c080e7          	jalr	-756(ra) # 8000053c <panic>

0000000080006838 <virtio_disk_init>:
{
    80006838:	1101                	addi	sp,sp,-32
    8000683a:	ec06                	sd	ra,24(sp)
    8000683c:	e822                	sd	s0,16(sp)
    8000683e:	e426                	sd	s1,8(sp)
    80006840:	e04a                	sd	s2,0(sp)
    80006842:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006844:	00002597          	auipc	a1,0x2
    80006848:	1cc58593          	addi	a1,a1,460 # 80008a10 <syscall_names+0x338>
    8000684c:	0004a517          	auipc	a0,0x4a
    80006850:	fac50513          	addi	a0,a0,-84 # 800507f8 <disk+0x128>
    80006854:	ffffa097          	auipc	ra,0xffffa
    80006858:	488080e7          	jalr	1160(ra) # 80000cdc <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000685c:	100017b7          	lui	a5,0x10001
    80006860:	4398                	lw	a4,0(a5)
    80006862:	2701                	sext.w	a4,a4
    80006864:	747277b7          	lui	a5,0x74727
    80006868:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000686c:	14f71b63          	bne	a4,a5,800069c2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006870:	100017b7          	lui	a5,0x10001
    80006874:	43dc                	lw	a5,4(a5)
    80006876:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006878:	4709                	li	a4,2
    8000687a:	14e79463          	bne	a5,a4,800069c2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000687e:	100017b7          	lui	a5,0x10001
    80006882:	479c                	lw	a5,8(a5)
    80006884:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006886:	12e79e63          	bne	a5,a4,800069c2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000688a:	100017b7          	lui	a5,0x10001
    8000688e:	47d8                	lw	a4,12(a5)
    80006890:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006892:	554d47b7          	lui	a5,0x554d4
    80006896:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000689a:	12f71463          	bne	a4,a5,800069c2 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000689e:	100017b7          	lui	a5,0x10001
    800068a2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800068a6:	4705                	li	a4,1
    800068a8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800068aa:	470d                	li	a4,3
    800068ac:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800068ae:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800068b0:	c7ffe6b7          	lui	a3,0xc7ffe
    800068b4:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fadf4f>
    800068b8:	8f75                	and	a4,a4,a3
    800068ba:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800068bc:	472d                	li	a4,11
    800068be:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800068c0:	5bbc                	lw	a5,112(a5)
    800068c2:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800068c6:	8ba1                	andi	a5,a5,8
    800068c8:	10078563          	beqz	a5,800069d2 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800068cc:	100017b7          	lui	a5,0x10001
    800068d0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800068d4:	43fc                	lw	a5,68(a5)
    800068d6:	2781                	sext.w	a5,a5
    800068d8:	10079563          	bnez	a5,800069e2 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800068dc:	100017b7          	lui	a5,0x10001
    800068e0:	5bdc                	lw	a5,52(a5)
    800068e2:	2781                	sext.w	a5,a5
  if(max == 0)
    800068e4:	10078763          	beqz	a5,800069f2 <virtio_disk_init+0x1ba>
  if(max < NUM)
    800068e8:	471d                	li	a4,7
    800068ea:	10f77c63          	bgeu	a4,a5,80006a02 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    800068ee:	ffffa097          	auipc	ra,0xffffa
    800068f2:	33e080e7          	jalr	830(ra) # 80000c2c <kalloc>
    800068f6:	0004a497          	auipc	s1,0x4a
    800068fa:	dda48493          	addi	s1,s1,-550 # 800506d0 <disk>
    800068fe:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006900:	ffffa097          	auipc	ra,0xffffa
    80006904:	32c080e7          	jalr	812(ra) # 80000c2c <kalloc>
    80006908:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000690a:	ffffa097          	auipc	ra,0xffffa
    8000690e:	322080e7          	jalr	802(ra) # 80000c2c <kalloc>
    80006912:	87aa                	mv	a5,a0
    80006914:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006916:	6088                	ld	a0,0(s1)
    80006918:	cd6d                	beqz	a0,80006a12 <virtio_disk_init+0x1da>
    8000691a:	0004a717          	auipc	a4,0x4a
    8000691e:	dbe73703          	ld	a4,-578(a4) # 800506d8 <disk+0x8>
    80006922:	cb65                	beqz	a4,80006a12 <virtio_disk_init+0x1da>
    80006924:	c7fd                	beqz	a5,80006a12 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80006926:	6605                	lui	a2,0x1
    80006928:	4581                	li	a1,0
    8000692a:	ffffa097          	auipc	ra,0xffffa
    8000692e:	53e080e7          	jalr	1342(ra) # 80000e68 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006932:	0004a497          	auipc	s1,0x4a
    80006936:	d9e48493          	addi	s1,s1,-610 # 800506d0 <disk>
    8000693a:	6605                	lui	a2,0x1
    8000693c:	4581                	li	a1,0
    8000693e:	6488                	ld	a0,8(s1)
    80006940:	ffffa097          	auipc	ra,0xffffa
    80006944:	528080e7          	jalr	1320(ra) # 80000e68 <memset>
  memset(disk.used, 0, PGSIZE);
    80006948:	6605                	lui	a2,0x1
    8000694a:	4581                	li	a1,0
    8000694c:	6888                	ld	a0,16(s1)
    8000694e:	ffffa097          	auipc	ra,0xffffa
    80006952:	51a080e7          	jalr	1306(ra) # 80000e68 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006956:	100017b7          	lui	a5,0x10001
    8000695a:	4721                	li	a4,8
    8000695c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000695e:	4098                	lw	a4,0(s1)
    80006960:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006964:	40d8                	lw	a4,4(s1)
    80006966:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000696a:	6498                	ld	a4,8(s1)
    8000696c:	0007069b          	sext.w	a3,a4
    80006970:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006974:	9701                	srai	a4,a4,0x20
    80006976:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000697a:	6898                	ld	a4,16(s1)
    8000697c:	0007069b          	sext.w	a3,a4
    80006980:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006984:	9701                	srai	a4,a4,0x20
    80006986:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000698a:	4705                	li	a4,1
    8000698c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000698e:	00e48c23          	sb	a4,24(s1)
    80006992:	00e48ca3          	sb	a4,25(s1)
    80006996:	00e48d23          	sb	a4,26(s1)
    8000699a:	00e48da3          	sb	a4,27(s1)
    8000699e:	00e48e23          	sb	a4,28(s1)
    800069a2:	00e48ea3          	sb	a4,29(s1)
    800069a6:	00e48f23          	sb	a4,30(s1)
    800069aa:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800069ae:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800069b2:	0727a823          	sw	s2,112(a5)
}
    800069b6:	60e2                	ld	ra,24(sp)
    800069b8:	6442                	ld	s0,16(sp)
    800069ba:	64a2                	ld	s1,8(sp)
    800069bc:	6902                	ld	s2,0(sp)
    800069be:	6105                	addi	sp,sp,32
    800069c0:	8082                	ret
    panic("could not find virtio disk");
    800069c2:	00002517          	auipc	a0,0x2
    800069c6:	05e50513          	addi	a0,a0,94 # 80008a20 <syscall_names+0x348>
    800069ca:	ffffa097          	auipc	ra,0xffffa
    800069ce:	b72080e7          	jalr	-1166(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    800069d2:	00002517          	auipc	a0,0x2
    800069d6:	06e50513          	addi	a0,a0,110 # 80008a40 <syscall_names+0x368>
    800069da:	ffffa097          	auipc	ra,0xffffa
    800069de:	b62080e7          	jalr	-1182(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    800069e2:	00002517          	auipc	a0,0x2
    800069e6:	07e50513          	addi	a0,a0,126 # 80008a60 <syscall_names+0x388>
    800069ea:	ffffa097          	auipc	ra,0xffffa
    800069ee:	b52080e7          	jalr	-1198(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    800069f2:	00002517          	auipc	a0,0x2
    800069f6:	08e50513          	addi	a0,a0,142 # 80008a80 <syscall_names+0x3a8>
    800069fa:	ffffa097          	auipc	ra,0xffffa
    800069fe:	b42080e7          	jalr	-1214(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    80006a02:	00002517          	auipc	a0,0x2
    80006a06:	09e50513          	addi	a0,a0,158 # 80008aa0 <syscall_names+0x3c8>
    80006a0a:	ffffa097          	auipc	ra,0xffffa
    80006a0e:	b32080e7          	jalr	-1230(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    80006a12:	00002517          	auipc	a0,0x2
    80006a16:	0ae50513          	addi	a0,a0,174 # 80008ac0 <syscall_names+0x3e8>
    80006a1a:	ffffa097          	auipc	ra,0xffffa
    80006a1e:	b22080e7          	jalr	-1246(ra) # 8000053c <panic>

0000000080006a22 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006a22:	7159                	addi	sp,sp,-112
    80006a24:	f486                	sd	ra,104(sp)
    80006a26:	f0a2                	sd	s0,96(sp)
    80006a28:	eca6                	sd	s1,88(sp)
    80006a2a:	e8ca                	sd	s2,80(sp)
    80006a2c:	e4ce                	sd	s3,72(sp)
    80006a2e:	e0d2                	sd	s4,64(sp)
    80006a30:	fc56                	sd	s5,56(sp)
    80006a32:	f85a                	sd	s6,48(sp)
    80006a34:	f45e                	sd	s7,40(sp)
    80006a36:	f062                	sd	s8,32(sp)
    80006a38:	ec66                	sd	s9,24(sp)
    80006a3a:	e86a                	sd	s10,16(sp)
    80006a3c:	1880                	addi	s0,sp,112
    80006a3e:	8a2a                	mv	s4,a0
    80006a40:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006a42:	00c52c83          	lw	s9,12(a0)
    80006a46:	001c9c9b          	slliw	s9,s9,0x1
    80006a4a:	1c82                	slli	s9,s9,0x20
    80006a4c:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006a50:	0004a517          	auipc	a0,0x4a
    80006a54:	da850513          	addi	a0,a0,-600 # 800507f8 <disk+0x128>
    80006a58:	ffffa097          	auipc	ra,0xffffa
    80006a5c:	314080e7          	jalr	788(ra) # 80000d6c <acquire>
  for(int i = 0; i < 3; i++){
    80006a60:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80006a62:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006a64:	0004ab17          	auipc	s6,0x4a
    80006a68:	c6cb0b13          	addi	s6,s6,-916 # 800506d0 <disk>
  for(int i = 0; i < 3; i++){
    80006a6c:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006a6e:	0004ac17          	auipc	s8,0x4a
    80006a72:	d8ac0c13          	addi	s8,s8,-630 # 800507f8 <disk+0x128>
    80006a76:	a095                	j	80006ada <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80006a78:	00fb0733          	add	a4,s6,a5
    80006a7c:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006a80:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    80006a82:	0207c563          	bltz	a5,80006aac <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    80006a86:	2605                	addiw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    80006a88:	0591                	addi	a1,a1,4
    80006a8a:	05560d63          	beq	a2,s5,80006ae4 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006a8e:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    80006a90:	0004a717          	auipc	a4,0x4a
    80006a94:	c4070713          	addi	a4,a4,-960 # 800506d0 <disk>
    80006a98:	87ca                	mv	a5,s2
    if(disk.free[i]){
    80006a9a:	01874683          	lbu	a3,24(a4)
    80006a9e:	fee9                	bnez	a3,80006a78 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    80006aa0:	2785                	addiw	a5,a5,1
    80006aa2:	0705                	addi	a4,a4,1
    80006aa4:	fe979be3          	bne	a5,s1,80006a9a <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    80006aa8:	57fd                	li	a5,-1
    80006aaa:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    80006aac:	00c05e63          	blez	a2,80006ac8 <virtio_disk_rw+0xa6>
    80006ab0:	060a                	slli	a2,a2,0x2
    80006ab2:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    80006ab6:	0009a503          	lw	a0,0(s3)
    80006aba:	00000097          	auipc	ra,0x0
    80006abe:	cfc080e7          	jalr	-772(ra) # 800067b6 <free_desc>
      for(int j = 0; j < i; j++)
    80006ac2:	0991                	addi	s3,s3,4
    80006ac4:	ffa999e3          	bne	s3,s10,80006ab6 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006ac8:	85e2                	mv	a1,s8
    80006aca:	0004a517          	auipc	a0,0x4a
    80006ace:	c1e50513          	addi	a0,a0,-994 # 800506e8 <disk+0x18>
    80006ad2:	ffffc097          	auipc	ra,0xffffc
    80006ad6:	a38080e7          	jalr	-1480(ra) # 8000250a <sleep>
  for(int i = 0; i < 3; i++){
    80006ada:	f9040993          	addi	s3,s0,-112
{
    80006ade:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    80006ae0:	864a                	mv	a2,s2
    80006ae2:	b775                	j	80006a8e <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006ae4:	f9042503          	lw	a0,-112(s0)
    80006ae8:	00a50713          	addi	a4,a0,10
    80006aec:	0712                	slli	a4,a4,0x4

  if(write)
    80006aee:	0004a797          	auipc	a5,0x4a
    80006af2:	be278793          	addi	a5,a5,-1054 # 800506d0 <disk>
    80006af6:	00e786b3          	add	a3,a5,a4
    80006afa:	01703633          	snez	a2,s7
    80006afe:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006b00:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006b04:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006b08:	f6070613          	addi	a2,a4,-160
    80006b0c:	6394                	ld	a3,0(a5)
    80006b0e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006b10:	00870593          	addi	a1,a4,8
    80006b14:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006b16:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006b18:	0007b803          	ld	a6,0(a5)
    80006b1c:	9642                	add	a2,a2,a6
    80006b1e:	46c1                	li	a3,16
    80006b20:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006b22:	4585                	li	a1,1
    80006b24:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006b28:	f9442683          	lw	a3,-108(s0)
    80006b2c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006b30:	0692                	slli	a3,a3,0x4
    80006b32:	9836                	add	a6,a6,a3
    80006b34:	058a0613          	addi	a2,s4,88
    80006b38:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80006b3c:	0007b803          	ld	a6,0(a5)
    80006b40:	96c2                	add	a3,a3,a6
    80006b42:	40000613          	li	a2,1024
    80006b46:	c690                	sw	a2,8(a3)
  if(write)
    80006b48:	001bb613          	seqz	a2,s7
    80006b4c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006b50:	00166613          	ori	a2,a2,1
    80006b54:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006b58:	f9842603          	lw	a2,-104(s0)
    80006b5c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006b60:	00250693          	addi	a3,a0,2
    80006b64:	0692                	slli	a3,a3,0x4
    80006b66:	96be                	add	a3,a3,a5
    80006b68:	58fd                	li	a7,-1
    80006b6a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006b6e:	0612                	slli	a2,a2,0x4
    80006b70:	9832                	add	a6,a6,a2
    80006b72:	f9070713          	addi	a4,a4,-112
    80006b76:	973e                	add	a4,a4,a5
    80006b78:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80006b7c:	6398                	ld	a4,0(a5)
    80006b7e:	9732                	add	a4,a4,a2
    80006b80:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006b82:	4609                	li	a2,2
    80006b84:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006b88:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006b8c:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    80006b90:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006b94:	6794                	ld	a3,8(a5)
    80006b96:	0026d703          	lhu	a4,2(a3)
    80006b9a:	8b1d                	andi	a4,a4,7
    80006b9c:	0706                	slli	a4,a4,0x1
    80006b9e:	96ba                	add	a3,a3,a4
    80006ba0:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006ba4:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006ba8:	6798                	ld	a4,8(a5)
    80006baa:	00275783          	lhu	a5,2(a4)
    80006bae:	2785                	addiw	a5,a5,1
    80006bb0:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006bb4:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006bb8:	100017b7          	lui	a5,0x10001
    80006bbc:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006bc0:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006bc4:	0004a917          	auipc	s2,0x4a
    80006bc8:	c3490913          	addi	s2,s2,-972 # 800507f8 <disk+0x128>
  while(b->disk == 1) {
    80006bcc:	4485                	li	s1,1
    80006bce:	00b79c63          	bne	a5,a1,80006be6 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006bd2:	85ca                	mv	a1,s2
    80006bd4:	8552                	mv	a0,s4
    80006bd6:	ffffc097          	auipc	ra,0xffffc
    80006bda:	934080e7          	jalr	-1740(ra) # 8000250a <sleep>
  while(b->disk == 1) {
    80006bde:	004a2783          	lw	a5,4(s4)
    80006be2:	fe9788e3          	beq	a5,s1,80006bd2 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006be6:	f9042903          	lw	s2,-112(s0)
    80006bea:	00290713          	addi	a4,s2,2
    80006bee:	0712                	slli	a4,a4,0x4
    80006bf0:	0004a797          	auipc	a5,0x4a
    80006bf4:	ae078793          	addi	a5,a5,-1312 # 800506d0 <disk>
    80006bf8:	97ba                	add	a5,a5,a4
    80006bfa:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006bfe:	0004a997          	auipc	s3,0x4a
    80006c02:	ad298993          	addi	s3,s3,-1326 # 800506d0 <disk>
    80006c06:	00491713          	slli	a4,s2,0x4
    80006c0a:	0009b783          	ld	a5,0(s3)
    80006c0e:	97ba                	add	a5,a5,a4
    80006c10:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006c14:	854a                	mv	a0,s2
    80006c16:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006c1a:	00000097          	auipc	ra,0x0
    80006c1e:	b9c080e7          	jalr	-1124(ra) # 800067b6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006c22:	8885                	andi	s1,s1,1
    80006c24:	f0ed                	bnez	s1,80006c06 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006c26:	0004a517          	auipc	a0,0x4a
    80006c2a:	bd250513          	addi	a0,a0,-1070 # 800507f8 <disk+0x128>
    80006c2e:	ffffa097          	auipc	ra,0xffffa
    80006c32:	1f2080e7          	jalr	498(ra) # 80000e20 <release>
}
    80006c36:	70a6                	ld	ra,104(sp)
    80006c38:	7406                	ld	s0,96(sp)
    80006c3a:	64e6                	ld	s1,88(sp)
    80006c3c:	6946                	ld	s2,80(sp)
    80006c3e:	69a6                	ld	s3,72(sp)
    80006c40:	6a06                	ld	s4,64(sp)
    80006c42:	7ae2                	ld	s5,56(sp)
    80006c44:	7b42                	ld	s6,48(sp)
    80006c46:	7ba2                	ld	s7,40(sp)
    80006c48:	7c02                	ld	s8,32(sp)
    80006c4a:	6ce2                	ld	s9,24(sp)
    80006c4c:	6d42                	ld	s10,16(sp)
    80006c4e:	6165                	addi	sp,sp,112
    80006c50:	8082                	ret

0000000080006c52 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006c52:	1101                	addi	sp,sp,-32
    80006c54:	ec06                	sd	ra,24(sp)
    80006c56:	e822                	sd	s0,16(sp)
    80006c58:	e426                	sd	s1,8(sp)
    80006c5a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006c5c:	0004a497          	auipc	s1,0x4a
    80006c60:	a7448493          	addi	s1,s1,-1420 # 800506d0 <disk>
    80006c64:	0004a517          	auipc	a0,0x4a
    80006c68:	b9450513          	addi	a0,a0,-1132 # 800507f8 <disk+0x128>
    80006c6c:	ffffa097          	auipc	ra,0xffffa
    80006c70:	100080e7          	jalr	256(ra) # 80000d6c <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006c74:	10001737          	lui	a4,0x10001
    80006c78:	533c                	lw	a5,96(a4)
    80006c7a:	8b8d                	andi	a5,a5,3
    80006c7c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006c7e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006c82:	689c                	ld	a5,16(s1)
    80006c84:	0204d703          	lhu	a4,32(s1)
    80006c88:	0027d783          	lhu	a5,2(a5)
    80006c8c:	04f70863          	beq	a4,a5,80006cdc <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006c90:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006c94:	6898                	ld	a4,16(s1)
    80006c96:	0204d783          	lhu	a5,32(s1)
    80006c9a:	8b9d                	andi	a5,a5,7
    80006c9c:	078e                	slli	a5,a5,0x3
    80006c9e:	97ba                	add	a5,a5,a4
    80006ca0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006ca2:	00278713          	addi	a4,a5,2
    80006ca6:	0712                	slli	a4,a4,0x4
    80006ca8:	9726                	add	a4,a4,s1
    80006caa:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006cae:	e721                	bnez	a4,80006cf6 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006cb0:	0789                	addi	a5,a5,2
    80006cb2:	0792                	slli	a5,a5,0x4
    80006cb4:	97a6                	add	a5,a5,s1
    80006cb6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006cb8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006cbc:	ffffc097          	auipc	ra,0xffffc
    80006cc0:	9fe080e7          	jalr	-1538(ra) # 800026ba <wakeup>

    disk.used_idx += 1;
    80006cc4:	0204d783          	lhu	a5,32(s1)
    80006cc8:	2785                	addiw	a5,a5,1
    80006cca:	17c2                	slli	a5,a5,0x30
    80006ccc:	93c1                	srli	a5,a5,0x30
    80006cce:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006cd2:	6898                	ld	a4,16(s1)
    80006cd4:	00275703          	lhu	a4,2(a4)
    80006cd8:	faf71ce3          	bne	a4,a5,80006c90 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006cdc:	0004a517          	auipc	a0,0x4a
    80006ce0:	b1c50513          	addi	a0,a0,-1252 # 800507f8 <disk+0x128>
    80006ce4:	ffffa097          	auipc	ra,0xffffa
    80006ce8:	13c080e7          	jalr	316(ra) # 80000e20 <release>
}
    80006cec:	60e2                	ld	ra,24(sp)
    80006cee:	6442                	ld	s0,16(sp)
    80006cf0:	64a2                	ld	s1,8(sp)
    80006cf2:	6105                	addi	sp,sp,32
    80006cf4:	8082                	ret
      panic("virtio_disk_intr status");
    80006cf6:	00002517          	auipc	a0,0x2
    80006cfa:	de250513          	addi	a0,a0,-542 # 80008ad8 <syscall_names+0x400>
    80006cfe:	ffffa097          	auipc	ra,0xffffa
    80006d02:	83e080e7          	jalr	-1986(ra) # 8000053c <panic>
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
