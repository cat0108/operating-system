
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	0040006f          	j	8020000c <kern_init>

000000008020000c <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000c:	00004517          	auipc	a0,0x4
    80200010:	00450513          	addi	a0,a0,4 # 80204010 <edata>
    80200014:	00004617          	auipc	a2,0x4
    80200018:	00c60613          	addi	a2,a2,12 # 80204020 <end>
int kern_init(void) {
    8020001c:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001e:	8e09                	sub	a2,a2,a0
    80200020:	4581                	li	a1,0
int kern_init(void) {
    80200022:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200024:	251000ef          	jal	ra,80200a74 <memset>

    cons_init();  // init the console
    80200028:	16e000ef          	jal	ra,80200196 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002c:	00001597          	auipc	a1,0x1
    80200030:	a5c58593          	addi	a1,a1,-1444 # 80200a88 <etext+0x2>
    80200034:	00001517          	auipc	a0,0x1
    80200038:	a7450513          	addi	a0,a0,-1420 # 80200aa8 <etext+0x22>
    8020003c:	030000ef          	jal	ra,8020006c <cprintf>

    print_kerninfo();
    80200040:	060000ef          	jal	ra,802000a0 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200044:	162000ef          	jal	ra,802001a6 <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200048:	0e8000ef          	jal	ra,80200130 <clock_init>

    intr_enable();  // enable irq interrupt
    8020004c:	154000ef          	jal	ra,802001a0 <intr_enable>
    
    while (1)
        ;
    80200050:	a001                	j	80200050 <kern_init+0x44>

0000000080200052 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200052:	1141                	addi	sp,sp,-16
    80200054:	e022                	sd	s0,0(sp)
    80200056:	e406                	sd	ra,8(sp)
    80200058:	842e                	mv	s0,a1
    cons_putc(c);
    8020005a:	13e000ef          	jal	ra,80200198 <cons_putc>
    (*cnt)++;
    8020005e:	401c                	lw	a5,0(s0)
}
    80200060:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200062:	2785                	addiw	a5,a5,1
    80200064:	c01c                	sw	a5,0(s0)
}
    80200066:	6402                	ld	s0,0(sp)
    80200068:	0141                	addi	sp,sp,16
    8020006a:	8082                	ret

000000008020006c <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    8020006c:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    8020006e:	02810313          	addi	t1,sp,40 # 80204028 <end+0x8>
int cprintf(const char *fmt, ...) {
    80200072:	f42e                	sd	a1,40(sp)
    80200074:	f832                	sd	a2,48(sp)
    80200076:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200078:	862a                	mv	a2,a0
    8020007a:	004c                	addi	a1,sp,4
    8020007c:	00000517          	auipc	a0,0x0
    80200080:	fd650513          	addi	a0,a0,-42 # 80200052 <cputch>
    80200084:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    80200086:	ec06                	sd	ra,24(sp)
    80200088:	e0ba                	sd	a4,64(sp)
    8020008a:	e4be                	sd	a5,72(sp)
    8020008c:	e8c2                	sd	a6,80(sp)
    8020008e:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200090:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200092:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200094:	5da000ef          	jal	ra,8020066e <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80200098:	60e2                	ld	ra,24(sp)
    8020009a:	4512                	lw	a0,4(sp)
    8020009c:	6125                	addi	sp,sp,96
    8020009e:	8082                	ret

00000000802000a0 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a0:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a2:	00001517          	auipc	a0,0x1
    802000a6:	a0e50513          	addi	a0,a0,-1522 # 80200ab0 <etext+0x2a>
void print_kerninfo(void) {
    802000aa:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000ac:	fc1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b0:	00000597          	auipc	a1,0x0
    802000b4:	f5c58593          	addi	a1,a1,-164 # 8020000c <kern_init>
    802000b8:	00001517          	auipc	a0,0x1
    802000bc:	a1850513          	addi	a0,a0,-1512 # 80200ad0 <etext+0x4a>
    802000c0:	fadff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c4:	00001597          	auipc	a1,0x1
    802000c8:	9c258593          	addi	a1,a1,-1598 # 80200a86 <etext>
    802000cc:	00001517          	auipc	a0,0x1
    802000d0:	a2450513          	addi	a0,a0,-1500 # 80200af0 <etext+0x6a>
    802000d4:	f99ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d8:	00004597          	auipc	a1,0x4
    802000dc:	f3858593          	addi	a1,a1,-200 # 80204010 <edata>
    802000e0:	00001517          	auipc	a0,0x1
    802000e4:	a3050513          	addi	a0,a0,-1488 # 80200b10 <etext+0x8a>
    802000e8:	f85ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ec:	00004597          	auipc	a1,0x4
    802000f0:	f3458593          	addi	a1,a1,-204 # 80204020 <end>
    802000f4:	00001517          	auipc	a0,0x1
    802000f8:	a3c50513          	addi	a0,a0,-1476 # 80200b30 <etext+0xaa>
    802000fc:	f71ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200100:	00004597          	auipc	a1,0x4
    80200104:	31f58593          	addi	a1,a1,799 # 8020441f <end+0x3ff>
    80200108:	00000797          	auipc	a5,0x0
    8020010c:	f0478793          	addi	a5,a5,-252 # 8020000c <kern_init>
    80200110:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200114:	43f7d593          	srai	a1,a5,0x3f
}
    80200118:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011a:	3ff5f593          	andi	a1,a1,1023
    8020011e:	95be                	add	a1,a1,a5
    80200120:	85a9                	srai	a1,a1,0xa
    80200122:	00001517          	auipc	a0,0x1
    80200126:	a2e50513          	addi	a0,a0,-1490 # 80200b50 <etext+0xca>
}
    8020012a:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020012c:	f41ff06f          	j	8020006c <cprintf>

0000000080200130 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    80200130:	1141                	addi	sp,sp,-16
    80200132:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200134:	02000793          	li	a5,32
    80200138:	1047a7f3          	csrrs	a5,sie,a5
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    // timebase = sbi_timebase() / 500;
    cprintf("++ setup illegal instruction\n");
    8020013c:	00001517          	auipc	a0,0x1
    80200140:	a4450513          	addi	a0,a0,-1468 # 80200b80 <etext+0xfa>
    80200144:	f29ff0ef          	jal	ra,8020006c <cprintf>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200148:	c0102573          	rdtime	a0
}

void clock_set_next_event(void) { 


    sbi_set_timer(get_cycles() + timebase); 
    8020014c:	67e1                	lui	a5,0x18
    8020014e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200152:	953e                	add	a0,a0,a5
    80200154:	0c3000ef          	jal	ra,80200a16 <sbi_set_timer>
    __asm__ __volatile__(
    80200158:	30200073          	mret
    __asm__ __volatile__(
    8020015c:	0001                	nop
    cprintf("++ setup breakpoint \n");
    8020015e:	00001517          	auipc	a0,0x1
    80200162:	a4250513          	addi	a0,a0,-1470 # 80200ba0 <etext+0x11a>
    80200166:	f07ff0ef          	jal	ra,8020006c <cprintf>
    __asm__ __volatile__(
    8020016a:	9002                	ebreak
    __asm__ __volatile__(
    8020016c:	0001                	nop
}
    8020016e:	60a2                	ld	ra,8(sp)
    ticks = 0;
    80200170:	00004797          	auipc	a5,0x4
    80200174:	ea07b423          	sd	zero,-344(a5) # 80204018 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200178:	00001517          	auipc	a0,0x1
    8020017c:	a4050513          	addi	a0,a0,-1472 # 80200bb8 <etext+0x132>
}
    80200180:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    80200182:	eebff06f          	j	8020006c <cprintf>

0000000080200186 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200186:	c0102573          	rdtime	a0
    sbi_set_timer(get_cycles() + timebase); 
    8020018a:	67e1                	lui	a5,0x18
    8020018c:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200190:	953e                	add	a0,a0,a5
    80200192:	0850006f          	j	80200a16 <sbi_set_timer>

0000000080200196 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    80200196:	8082                	ret

0000000080200198 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    80200198:	0ff57513          	andi	a0,a0,255
    8020019c:	05f0006f          	j	802009fa <sbi_console_putchar>

00000000802001a0 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    802001a0:	100167f3          	csrrsi	a5,sstatus,2
    802001a4:	8082                	ret

00000000802001a6 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    802001a6:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    802001aa:	00000797          	auipc	a5,0x0
    802001ae:	3a278793          	addi	a5,a5,930 # 8020054c <__alltraps>
    802001b2:	10579073          	csrw	stvec,a5
}
    802001b6:	8082                	ret

00000000802001b8 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001b8:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    802001ba:	1141                	addi	sp,sp,-16
    802001bc:	e022                	sd	s0,0(sp)
    802001be:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001c0:	00001517          	auipc	a0,0x1
    802001c4:	b8050513          	addi	a0,a0,-1152 # 80200d40 <etext+0x2ba>
void print_regs(struct pushregs *gpr) {
    802001c8:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001ca:	ea3ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001ce:	640c                	ld	a1,8(s0)
    802001d0:	00001517          	auipc	a0,0x1
    802001d4:	b8850513          	addi	a0,a0,-1144 # 80200d58 <etext+0x2d2>
    802001d8:	e95ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001dc:	680c                	ld	a1,16(s0)
    802001de:	00001517          	auipc	a0,0x1
    802001e2:	b9250513          	addi	a0,a0,-1134 # 80200d70 <etext+0x2ea>
    802001e6:	e87ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001ea:	6c0c                	ld	a1,24(s0)
    802001ec:	00001517          	auipc	a0,0x1
    802001f0:	b9c50513          	addi	a0,a0,-1124 # 80200d88 <etext+0x302>
    802001f4:	e79ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001f8:	700c                	ld	a1,32(s0)
    802001fa:	00001517          	auipc	a0,0x1
    802001fe:	ba650513          	addi	a0,a0,-1114 # 80200da0 <etext+0x31a>
    80200202:	e6bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    80200206:	740c                	ld	a1,40(s0)
    80200208:	00001517          	auipc	a0,0x1
    8020020c:	bb050513          	addi	a0,a0,-1104 # 80200db8 <etext+0x332>
    80200210:	e5dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    80200214:	780c                	ld	a1,48(s0)
    80200216:	00001517          	auipc	a0,0x1
    8020021a:	bba50513          	addi	a0,a0,-1094 # 80200dd0 <etext+0x34a>
    8020021e:	e4fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200222:	7c0c                	ld	a1,56(s0)
    80200224:	00001517          	auipc	a0,0x1
    80200228:	bc450513          	addi	a0,a0,-1084 # 80200de8 <etext+0x362>
    8020022c:	e41ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200230:	602c                	ld	a1,64(s0)
    80200232:	00001517          	auipc	a0,0x1
    80200236:	bce50513          	addi	a0,a0,-1074 # 80200e00 <etext+0x37a>
    8020023a:	e33ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    8020023e:	642c                	ld	a1,72(s0)
    80200240:	00001517          	auipc	a0,0x1
    80200244:	bd850513          	addi	a0,a0,-1064 # 80200e18 <etext+0x392>
    80200248:	e25ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    8020024c:	682c                	ld	a1,80(s0)
    8020024e:	00001517          	auipc	a0,0x1
    80200252:	be250513          	addi	a0,a0,-1054 # 80200e30 <etext+0x3aa>
    80200256:	e17ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    8020025a:	6c2c                	ld	a1,88(s0)
    8020025c:	00001517          	auipc	a0,0x1
    80200260:	bec50513          	addi	a0,a0,-1044 # 80200e48 <etext+0x3c2>
    80200264:	e09ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200268:	702c                	ld	a1,96(s0)
    8020026a:	00001517          	auipc	a0,0x1
    8020026e:	bf650513          	addi	a0,a0,-1034 # 80200e60 <etext+0x3da>
    80200272:	dfbff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200276:	742c                	ld	a1,104(s0)
    80200278:	00001517          	auipc	a0,0x1
    8020027c:	c0050513          	addi	a0,a0,-1024 # 80200e78 <etext+0x3f2>
    80200280:	dedff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200284:	782c                	ld	a1,112(s0)
    80200286:	00001517          	auipc	a0,0x1
    8020028a:	c0a50513          	addi	a0,a0,-1014 # 80200e90 <etext+0x40a>
    8020028e:	ddfff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200292:	7c2c                	ld	a1,120(s0)
    80200294:	00001517          	auipc	a0,0x1
    80200298:	c1450513          	addi	a0,a0,-1004 # 80200ea8 <etext+0x422>
    8020029c:	dd1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    802002a0:	604c                	ld	a1,128(s0)
    802002a2:	00001517          	auipc	a0,0x1
    802002a6:	c1e50513          	addi	a0,a0,-994 # 80200ec0 <etext+0x43a>
    802002aa:	dc3ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    802002ae:	644c                	ld	a1,136(s0)
    802002b0:	00001517          	auipc	a0,0x1
    802002b4:	c2850513          	addi	a0,a0,-984 # 80200ed8 <etext+0x452>
    802002b8:	db5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    802002bc:	684c                	ld	a1,144(s0)
    802002be:	00001517          	auipc	a0,0x1
    802002c2:	c3250513          	addi	a0,a0,-974 # 80200ef0 <etext+0x46a>
    802002c6:	da7ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002ca:	6c4c                	ld	a1,152(s0)
    802002cc:	00001517          	auipc	a0,0x1
    802002d0:	c3c50513          	addi	a0,a0,-964 # 80200f08 <etext+0x482>
    802002d4:	d99ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002d8:	704c                	ld	a1,160(s0)
    802002da:	00001517          	auipc	a0,0x1
    802002de:	c4650513          	addi	a0,a0,-954 # 80200f20 <etext+0x49a>
    802002e2:	d8bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002e6:	744c                	ld	a1,168(s0)
    802002e8:	00001517          	auipc	a0,0x1
    802002ec:	c5050513          	addi	a0,a0,-944 # 80200f38 <etext+0x4b2>
    802002f0:	d7dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002f4:	784c                	ld	a1,176(s0)
    802002f6:	00001517          	auipc	a0,0x1
    802002fa:	c5a50513          	addi	a0,a0,-934 # 80200f50 <etext+0x4ca>
    802002fe:	d6fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    80200302:	7c4c                	ld	a1,184(s0)
    80200304:	00001517          	auipc	a0,0x1
    80200308:	c6450513          	addi	a0,a0,-924 # 80200f68 <etext+0x4e2>
    8020030c:	d61ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    80200310:	606c                	ld	a1,192(s0)
    80200312:	00001517          	auipc	a0,0x1
    80200316:	c6e50513          	addi	a0,a0,-914 # 80200f80 <etext+0x4fa>
    8020031a:	d53ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    8020031e:	646c                	ld	a1,200(s0)
    80200320:	00001517          	auipc	a0,0x1
    80200324:	c7850513          	addi	a0,a0,-904 # 80200f98 <etext+0x512>
    80200328:	d45ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    8020032c:	686c                	ld	a1,208(s0)
    8020032e:	00001517          	auipc	a0,0x1
    80200332:	c8250513          	addi	a0,a0,-894 # 80200fb0 <etext+0x52a>
    80200336:	d37ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    8020033a:	6c6c                	ld	a1,216(s0)
    8020033c:	00001517          	auipc	a0,0x1
    80200340:	c8c50513          	addi	a0,a0,-884 # 80200fc8 <etext+0x542>
    80200344:	d29ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200348:	706c                	ld	a1,224(s0)
    8020034a:	00001517          	auipc	a0,0x1
    8020034e:	c9650513          	addi	a0,a0,-874 # 80200fe0 <etext+0x55a>
    80200352:	d1bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200356:	746c                	ld	a1,232(s0)
    80200358:	00001517          	auipc	a0,0x1
    8020035c:	ca050513          	addi	a0,a0,-864 # 80200ff8 <etext+0x572>
    80200360:	d0dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200364:	786c                	ld	a1,240(s0)
    80200366:	00001517          	auipc	a0,0x1
    8020036a:	caa50513          	addi	a0,a0,-854 # 80201010 <etext+0x58a>
    8020036e:	cffff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200372:	7c6c                	ld	a1,248(s0)
}
    80200374:	6402                	ld	s0,0(sp)
    80200376:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200378:	00001517          	auipc	a0,0x1
    8020037c:	cb050513          	addi	a0,a0,-848 # 80201028 <etext+0x5a2>
}
    80200380:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200382:	cebff06f          	j	8020006c <cprintf>

0000000080200386 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    80200386:	1141                	addi	sp,sp,-16
    80200388:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    8020038a:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    8020038c:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    8020038e:	00001517          	auipc	a0,0x1
    80200392:	cb250513          	addi	a0,a0,-846 # 80201040 <etext+0x5ba>
void print_trapframe(struct trapframe *tf) {
    80200396:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200398:	cd5ff0ef          	jal	ra,8020006c <cprintf>
    print_regs(&tf->gpr);
    8020039c:	8522                	mv	a0,s0
    8020039e:	e1bff0ef          	jal	ra,802001b8 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    802003a2:	10043583          	ld	a1,256(s0)
    802003a6:	00001517          	auipc	a0,0x1
    802003aa:	cb250513          	addi	a0,a0,-846 # 80201058 <etext+0x5d2>
    802003ae:	cbfff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    802003b2:	10843583          	ld	a1,264(s0)
    802003b6:	00001517          	auipc	a0,0x1
    802003ba:	cba50513          	addi	a0,a0,-838 # 80201070 <etext+0x5ea>
    802003be:	cafff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    802003c2:	11043583          	ld	a1,272(s0)
    802003c6:	00001517          	auipc	a0,0x1
    802003ca:	cc250513          	addi	a0,a0,-830 # 80201088 <etext+0x602>
    802003ce:	c9fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003d2:	11843583          	ld	a1,280(s0)
}
    802003d6:	6402                	ld	s0,0(sp)
    802003d8:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003da:	00001517          	auipc	a0,0x1
    802003de:	cc650513          	addi	a0,a0,-826 # 802010a0 <etext+0x61a>
}
    802003e2:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003e4:	c89ff06f          	j	8020006c <cprintf>

00000000802003e8 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003e8:	11853783          	ld	a5,280(a0)
    802003ec:	577d                	li	a4,-1
    802003ee:	8305                	srli	a4,a4,0x1
    802003f0:	8ff9                	and	a5,a5,a4
    switch (cause) {
    802003f2:	472d                	li	a4,11
    802003f4:	08f76963          	bltu	a4,a5,80200486 <interrupt_handler+0x9e>
    802003f8:	00000717          	auipc	a4,0x0
    802003fc:	7dc70713          	addi	a4,a4,2012 # 80200bd4 <etext+0x14e>
    80200400:	078a                	slli	a5,a5,0x2
    80200402:	97ba                	add	a5,a5,a4
    80200404:	439c                	lw	a5,0(a5)
    80200406:	97ba                	add	a5,a5,a4
    80200408:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    8020040a:	00001517          	auipc	a0,0x1
    8020040e:	8e650513          	addi	a0,a0,-1818 # 80200cf0 <etext+0x26a>
    80200412:	c5bff06f          	j	8020006c <cprintf>
            cprintf("Hypervisor software interrupt\n");
    80200416:	00001517          	auipc	a0,0x1
    8020041a:	8ba50513          	addi	a0,a0,-1862 # 80200cd0 <etext+0x24a>
    8020041e:	c4fff06f          	j	8020006c <cprintf>
            cprintf("User software interrupt\n");
    80200422:	00001517          	auipc	a0,0x1
    80200426:	86e50513          	addi	a0,a0,-1938 # 80200c90 <etext+0x20a>
    8020042a:	c43ff06f          	j	8020006c <cprintf>
            cprintf("Supervisor software interrupt\n");
    8020042e:	00001517          	auipc	a0,0x1
    80200432:	88250513          	addi	a0,a0,-1918 # 80200cb0 <etext+0x22a>
    80200436:	c37ff06f          	j	8020006c <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    8020043a:	00001517          	auipc	a0,0x1
    8020043e:	8e650513          	addi	a0,a0,-1818 # 80200d20 <etext+0x29a>
    80200442:	c2bff06f          	j	8020006c <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200446:	1141                	addi	sp,sp,-16
    80200448:	e022                	sd	s0,0(sp)
    8020044a:	e406                	sd	ra,8(sp)
            ticks++;
    8020044c:	00004417          	auipc	s0,0x4
    80200450:	bcc40413          	addi	s0,s0,-1076 # 80204018 <ticks>
            clock_set_next_event();
    80200454:	d33ff0ef          	jal	ra,80200186 <clock_set_next_event>
            ticks++;
    80200458:	601c                	ld	a5,0(s0)
    8020045a:	0785                	addi	a5,a5,1
    8020045c:	00004717          	auipc	a4,0x4
    80200460:	baf73e23          	sd	a5,-1092(a4) # 80204018 <ticks>
            if(ticks % TICK_NUM==0)
    80200464:	601c                	ld	a5,0(s0)
    80200466:	06400713          	li	a4,100
    8020046a:	02e7f7b3          	remu	a5,a5,a4
    8020046e:	cf91                	beqz	a5,8020048a <interrupt_handler+0xa2>
            if(ticks / TICK_NUM == 10)
    80200470:	601c                	ld	a5,0(s0)
    80200472:	06300713          	li	a4,99
    80200476:	c1878793          	addi	a5,a5,-1000
    8020047a:	02f77163          	bleu	a5,a4,8020049c <interrupt_handler+0xb4>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    8020047e:	60a2                	ld	ra,8(sp)
    80200480:	6402                	ld	s0,0(sp)
    80200482:	0141                	addi	sp,sp,16
    80200484:	8082                	ret
            print_trapframe(tf);
    80200486:	f01ff06f          	j	80200386 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    8020048a:	06400593          	li	a1,100
    8020048e:	00001517          	auipc	a0,0x1
    80200492:	88250513          	addi	a0,a0,-1918 # 80200d10 <etext+0x28a>
    80200496:	bd7ff0ef          	jal	ra,8020006c <cprintf>
    8020049a:	bfd9                	j	80200470 <interrupt_handler+0x88>
}
    8020049c:	6402                	ld	s0,0(sp)
    8020049e:	60a2                	ld	ra,8(sp)
    802004a0:	0141                	addi	sp,sp,16
                sbi_shutdown();
    802004a2:	5900006f          	j	80200a32 <sbi_shutdown>

00000000802004a6 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    802004a6:	11853783          	ld	a5,280(a0)
    802004aa:	472d                	li	a4,11
    802004ac:	02f76863          	bltu	a4,a5,802004dc <exception_handler+0x36>
    802004b0:	4705                	li	a4,1
    802004b2:	00f71733          	sll	a4,a4,a5
    802004b6:	6785                	lui	a5,0x1
    802004b8:	17cd                	addi	a5,a5,-13
    802004ba:	8ff9                	and	a5,a5,a4
    802004bc:	ef99                	bnez	a5,802004da <exception_handler+0x34>
void exception_handler(struct trapframe *tf) {
    802004be:	1141                	addi	sp,sp,-16
    802004c0:	e022                	sd	s0,0(sp)
    802004c2:	e406                	sd	ra,8(sp)
    802004c4:	00877793          	andi	a5,a4,8
    802004c8:	842a                	mv	s0,a0
    802004ca:	e3b1                	bnez	a5,8020050e <exception_handler+0x68>
    802004cc:	8b11                	andi	a4,a4,4
    802004ce:	eb09                	bnez	a4,802004e0 <exception_handler+0x3a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004d0:	6402                	ld	s0,0(sp)
    802004d2:	60a2                	ld	ra,8(sp)
    802004d4:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004d6:	eb1ff06f          	j	80200386 <print_trapframe>
    802004da:	8082                	ret
    802004dc:	eabff06f          	j	80200386 <print_trapframe>
            cprintf("Illegal instruction caught at 0x%x\n",tf->epc);
    802004e0:	10853583          	ld	a1,264(a0)
    802004e4:	00000517          	auipc	a0,0x0
    802004e8:	72450513          	addi	a0,a0,1828 # 80200c08 <etext+0x182>
    802004ec:	b81ff0ef          	jal	ra,8020006c <cprintf>
            cprintf("Exception type:Illegal instruction\n");
    802004f0:	00000517          	auipc	a0,0x0
    802004f4:	74050513          	addi	a0,a0,1856 # 80200c30 <etext+0x1aa>
    802004f8:	b75ff0ef          	jal	ra,8020006c <cprintf>
            tf->epc=tf->epc+4;
    802004fc:	10843783          	ld	a5,264(s0)
}
    80200500:	60a2                	ld	ra,8(sp)
            tf->epc=tf->epc+4;
    80200502:	0791                	addi	a5,a5,4
    80200504:	10f43423          	sd	a5,264(s0)
}
    80200508:	6402                	ld	s0,0(sp)
    8020050a:	0141                	addi	sp,sp,16
    8020050c:	8082                	ret
            cprintf("ebreak caught at 0x%x\n",tf->epc);
    8020050e:	10853583          	ld	a1,264(a0)
    80200512:	00000517          	auipc	a0,0x0
    80200516:	74650513          	addi	a0,a0,1862 # 80200c58 <etext+0x1d2>
    8020051a:	b53ff0ef          	jal	ra,8020006c <cprintf>
            cprintf("Exception type:breakpoint\n");
    8020051e:	00000517          	auipc	a0,0x0
    80200522:	75250513          	addi	a0,a0,1874 # 80200c70 <etext+0x1ea>
    80200526:	b47ff0ef          	jal	ra,8020006c <cprintf>
            tf->epc=tf->epc+4;
    8020052a:	10843783          	ld	a5,264(s0)
}
    8020052e:	60a2                	ld	ra,8(sp)
            tf->epc=tf->epc+4;
    80200530:	0791                	addi	a5,a5,4
    80200532:	10f43423          	sd	a5,264(s0)
}
    80200536:	6402                	ld	s0,0(sp)
    80200538:	0141                	addi	sp,sp,16
    8020053a:	8082                	ret

000000008020053c <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    8020053c:	11853783          	ld	a5,280(a0)
    80200540:	0007c463          	bltz	a5,80200548 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    80200544:	f63ff06f          	j	802004a6 <exception_handler>
        interrupt_handler(tf);
    80200548:	ea1ff06f          	j	802003e8 <interrupt_handler>

000000008020054c <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    8020054c:	14011073          	csrw	sscratch,sp
    80200550:	712d                	addi	sp,sp,-288
    80200552:	e002                	sd	zero,0(sp)
    80200554:	e406                	sd	ra,8(sp)
    80200556:	ec0e                	sd	gp,24(sp)
    80200558:	f012                	sd	tp,32(sp)
    8020055a:	f416                	sd	t0,40(sp)
    8020055c:	f81a                	sd	t1,48(sp)
    8020055e:	fc1e                	sd	t2,56(sp)
    80200560:	e0a2                	sd	s0,64(sp)
    80200562:	e4a6                	sd	s1,72(sp)
    80200564:	e8aa                	sd	a0,80(sp)
    80200566:	ecae                	sd	a1,88(sp)
    80200568:	f0b2                	sd	a2,96(sp)
    8020056a:	f4b6                	sd	a3,104(sp)
    8020056c:	f8ba                	sd	a4,112(sp)
    8020056e:	fcbe                	sd	a5,120(sp)
    80200570:	e142                	sd	a6,128(sp)
    80200572:	e546                	sd	a7,136(sp)
    80200574:	e94a                	sd	s2,144(sp)
    80200576:	ed4e                	sd	s3,152(sp)
    80200578:	f152                	sd	s4,160(sp)
    8020057a:	f556                	sd	s5,168(sp)
    8020057c:	f95a                	sd	s6,176(sp)
    8020057e:	fd5e                	sd	s7,184(sp)
    80200580:	e1e2                	sd	s8,192(sp)
    80200582:	e5e6                	sd	s9,200(sp)
    80200584:	e9ea                	sd	s10,208(sp)
    80200586:	edee                	sd	s11,216(sp)
    80200588:	f1f2                	sd	t3,224(sp)
    8020058a:	f5f6                	sd	t4,232(sp)
    8020058c:	f9fa                	sd	t5,240(sp)
    8020058e:	fdfe                	sd	t6,248(sp)
    80200590:	14001473          	csrrw	s0,sscratch,zero
    80200594:	100024f3          	csrr	s1,sstatus
    80200598:	14102973          	csrr	s2,sepc
    8020059c:	143029f3          	csrr	s3,stval
    802005a0:	14202a73          	csrr	s4,scause
    802005a4:	e822                	sd	s0,16(sp)
    802005a6:	e226                	sd	s1,256(sp)
    802005a8:	e64a                	sd	s2,264(sp)
    802005aa:	ea4e                	sd	s3,272(sp)
    802005ac:	ee52                	sd	s4,280(sp)

    move  a0, sp
    802005ae:	850a                	mv	a0,sp
    jal trap
    802005b0:	f8dff0ef          	jal	ra,8020053c <trap>

00000000802005b4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    802005b4:	6492                	ld	s1,256(sp)
    802005b6:	6932                	ld	s2,264(sp)
    802005b8:	10049073          	csrw	sstatus,s1
    802005bc:	14191073          	csrw	sepc,s2
    802005c0:	60a2                	ld	ra,8(sp)
    802005c2:	61e2                	ld	gp,24(sp)
    802005c4:	7202                	ld	tp,32(sp)
    802005c6:	72a2                	ld	t0,40(sp)
    802005c8:	7342                	ld	t1,48(sp)
    802005ca:	73e2                	ld	t2,56(sp)
    802005cc:	6406                	ld	s0,64(sp)
    802005ce:	64a6                	ld	s1,72(sp)
    802005d0:	6546                	ld	a0,80(sp)
    802005d2:	65e6                	ld	a1,88(sp)
    802005d4:	7606                	ld	a2,96(sp)
    802005d6:	76a6                	ld	a3,104(sp)
    802005d8:	7746                	ld	a4,112(sp)
    802005da:	77e6                	ld	a5,120(sp)
    802005dc:	680a                	ld	a6,128(sp)
    802005de:	68aa                	ld	a7,136(sp)
    802005e0:	694a                	ld	s2,144(sp)
    802005e2:	69ea                	ld	s3,152(sp)
    802005e4:	7a0a                	ld	s4,160(sp)
    802005e6:	7aaa                	ld	s5,168(sp)
    802005e8:	7b4a                	ld	s6,176(sp)
    802005ea:	7bea                	ld	s7,184(sp)
    802005ec:	6c0e                	ld	s8,192(sp)
    802005ee:	6cae                	ld	s9,200(sp)
    802005f0:	6d4e                	ld	s10,208(sp)
    802005f2:	6dee                	ld	s11,216(sp)
    802005f4:	7e0e                	ld	t3,224(sp)
    802005f6:	7eae                	ld	t4,232(sp)
    802005f8:	7f4e                	ld	t5,240(sp)
    802005fa:	7fee                	ld	t6,248(sp)
    802005fc:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802005fe:	10200073          	sret

0000000080200602 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    80200602:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200606:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    80200608:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    8020060c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    8020060e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    80200612:	f022                	sd	s0,32(sp)
    80200614:	ec26                	sd	s1,24(sp)
    80200616:	e84a                	sd	s2,16(sp)
    80200618:	f406                	sd	ra,40(sp)
    8020061a:	e44e                	sd	s3,8(sp)
    8020061c:	84aa                	mv	s1,a0
    8020061e:	892e                	mv	s2,a1
    80200620:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    80200624:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    80200626:	03067e63          	bleu	a6,a2,80200662 <printnum+0x60>
    8020062a:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    8020062c:	00805763          	blez	s0,8020063a <printnum+0x38>
    80200630:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    80200632:	85ca                	mv	a1,s2
    80200634:	854e                	mv	a0,s3
    80200636:	9482                	jalr	s1
        while (-- width > 0)
    80200638:	fc65                	bnez	s0,80200630 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    8020063a:	1a02                	slli	s4,s4,0x20
    8020063c:	020a5a13          	srli	s4,s4,0x20
    80200640:	00001797          	auipc	a5,0x1
    80200644:	c0878793          	addi	a5,a5,-1016 # 80201248 <error_string+0x38>
    80200648:	9a3e                	add	s4,s4,a5
}
    8020064a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    8020064c:	000a4503          	lbu	a0,0(s4)
}
    80200650:	70a2                	ld	ra,40(sp)
    80200652:	69a2                	ld	s3,8(sp)
    80200654:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200656:	85ca                	mv	a1,s2
    80200658:	8326                	mv	t1,s1
}
    8020065a:	6942                	ld	s2,16(sp)
    8020065c:	64e2                	ld	s1,24(sp)
    8020065e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    80200660:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    80200662:	03065633          	divu	a2,a2,a6
    80200666:	8722                	mv	a4,s0
    80200668:	f9bff0ef          	jal	ra,80200602 <printnum>
    8020066c:	b7f9                	j	8020063a <printnum+0x38>

000000008020066e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    8020066e:	7119                	addi	sp,sp,-128
    80200670:	f4a6                	sd	s1,104(sp)
    80200672:	f0ca                	sd	s2,96(sp)
    80200674:	e8d2                	sd	s4,80(sp)
    80200676:	e4d6                	sd	s5,72(sp)
    80200678:	e0da                	sd	s6,64(sp)
    8020067a:	fc5e                	sd	s7,56(sp)
    8020067c:	f862                	sd	s8,48(sp)
    8020067e:	f06a                	sd	s10,32(sp)
    80200680:	fc86                	sd	ra,120(sp)
    80200682:	f8a2                	sd	s0,112(sp)
    80200684:	ecce                	sd	s3,88(sp)
    80200686:	f466                	sd	s9,40(sp)
    80200688:	ec6e                	sd	s11,24(sp)
    8020068a:	892a                	mv	s2,a0
    8020068c:	84ae                	mv	s1,a1
    8020068e:	8d32                	mv	s10,a2
    80200690:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    80200692:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    80200694:	00001a17          	auipc	s4,0x1
    80200698:	a20a0a13          	addi	s4,s4,-1504 # 802010b4 <etext+0x62e>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
    8020069c:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802006a0:	00001c17          	auipc	s8,0x1
    802006a4:	b70c0c13          	addi	s8,s8,-1168 # 80201210 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006a8:	000d4503          	lbu	a0,0(s10)
    802006ac:	02500793          	li	a5,37
    802006b0:	001d0413          	addi	s0,s10,1
    802006b4:	00f50e63          	beq	a0,a5,802006d0 <vprintfmt+0x62>
            if (ch == '\0') {
    802006b8:	c521                	beqz	a0,80200700 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006ba:	02500993          	li	s3,37
    802006be:	a011                	j	802006c2 <vprintfmt+0x54>
            if (ch == '\0') {
    802006c0:	c121                	beqz	a0,80200700 <vprintfmt+0x92>
            putch(ch, putdat);
    802006c2:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006c4:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    802006c6:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006c8:	fff44503          	lbu	a0,-1(s0)
    802006cc:	ff351ae3          	bne	a0,s3,802006c0 <vprintfmt+0x52>
    802006d0:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    802006d4:	02000793          	li	a5,32
        lflag = altflag = 0;
    802006d8:	4981                	li	s3,0
    802006da:	4801                	li	a6,0
        width = precision = -1;
    802006dc:	5cfd                	li	s9,-1
    802006de:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
    802006e0:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
    802006e4:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
    802006e6:	fdd6069b          	addiw	a3,a2,-35
    802006ea:	0ff6f693          	andi	a3,a3,255
    802006ee:	00140d13          	addi	s10,s0,1
    802006f2:	20d5e563          	bltu	a1,a3,802008fc <vprintfmt+0x28e>
    802006f6:	068a                	slli	a3,a3,0x2
    802006f8:	96d2                	add	a3,a3,s4
    802006fa:	4294                	lw	a3,0(a3)
    802006fc:	96d2                	add	a3,a3,s4
    802006fe:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    80200700:	70e6                	ld	ra,120(sp)
    80200702:	7446                	ld	s0,112(sp)
    80200704:	74a6                	ld	s1,104(sp)
    80200706:	7906                	ld	s2,96(sp)
    80200708:	69e6                	ld	s3,88(sp)
    8020070a:	6a46                	ld	s4,80(sp)
    8020070c:	6aa6                	ld	s5,72(sp)
    8020070e:	6b06                	ld	s6,64(sp)
    80200710:	7be2                	ld	s7,56(sp)
    80200712:	7c42                	ld	s8,48(sp)
    80200714:	7ca2                	ld	s9,40(sp)
    80200716:	7d02                	ld	s10,32(sp)
    80200718:	6de2                	ld	s11,24(sp)
    8020071a:	6109                	addi	sp,sp,128
    8020071c:	8082                	ret
    if (lflag >= 2) {
    8020071e:	4705                	li	a4,1
    80200720:	008a8593          	addi	a1,s5,8
    80200724:	01074463          	blt	a4,a6,8020072c <vprintfmt+0xbe>
    else if (lflag) {
    80200728:	26080363          	beqz	a6,8020098e <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
    8020072c:	000ab603          	ld	a2,0(s5)
    80200730:	46c1                	li	a3,16
    80200732:	8aae                	mv	s5,a1
    80200734:	a06d                	j	802007de <vprintfmt+0x170>
            goto reswitch;
    80200736:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    8020073a:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
    8020073c:	846a                	mv	s0,s10
            goto reswitch;
    8020073e:	b765                	j	802006e6 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
    80200740:	000aa503          	lw	a0,0(s5)
    80200744:	85a6                	mv	a1,s1
    80200746:	0aa1                	addi	s5,s5,8
    80200748:	9902                	jalr	s2
            break;
    8020074a:	bfb9                	j	802006a8 <vprintfmt+0x3a>
    if (lflag >= 2) {
    8020074c:	4705                	li	a4,1
    8020074e:	008a8993          	addi	s3,s5,8
    80200752:	01074463          	blt	a4,a6,8020075a <vprintfmt+0xec>
    else if (lflag) {
    80200756:	22080463          	beqz	a6,8020097e <vprintfmt+0x310>
        return va_arg(*ap, long);
    8020075a:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
    8020075e:	24044463          	bltz	s0,802009a6 <vprintfmt+0x338>
            num = getint(&ap, lflag);
    80200762:	8622                	mv	a2,s0
    80200764:	8ace                	mv	s5,s3
    80200766:	46a9                	li	a3,10
    80200768:	a89d                	j	802007de <vprintfmt+0x170>
            err = va_arg(ap, int);
    8020076a:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020076e:	4719                	li	a4,6
            err = va_arg(ap, int);
    80200770:	0aa1                	addi	s5,s5,8
            if (err < 0) {
    80200772:	41f7d69b          	sraiw	a3,a5,0x1f
    80200776:	8fb5                	xor	a5,a5,a3
    80200778:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020077c:	1ad74363          	blt	a4,a3,80200922 <vprintfmt+0x2b4>
    80200780:	00369793          	slli	a5,a3,0x3
    80200784:	97e2                	add	a5,a5,s8
    80200786:	639c                	ld	a5,0(a5)
    80200788:	18078d63          	beqz	a5,80200922 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
    8020078c:	86be                	mv	a3,a5
    8020078e:	00001617          	auipc	a2,0x1
    80200792:	b6a60613          	addi	a2,a2,-1174 # 802012f8 <error_string+0xe8>
    80200796:	85a6                	mv	a1,s1
    80200798:	854a                	mv	a0,s2
    8020079a:	240000ef          	jal	ra,802009da <printfmt>
    8020079e:	b729                	j	802006a8 <vprintfmt+0x3a>
            lflag ++;
    802007a0:	00144603          	lbu	a2,1(s0)
    802007a4:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
    802007a6:	846a                	mv	s0,s10
            goto reswitch;
    802007a8:	bf3d                	j	802006e6 <vprintfmt+0x78>
    if (lflag >= 2) {
    802007aa:	4705                	li	a4,1
    802007ac:	008a8593          	addi	a1,s5,8
    802007b0:	01074463          	blt	a4,a6,802007b8 <vprintfmt+0x14a>
    else if (lflag) {
    802007b4:	1e080263          	beqz	a6,80200998 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
    802007b8:	000ab603          	ld	a2,0(s5)
    802007bc:	46a1                	li	a3,8
    802007be:	8aae                	mv	s5,a1
    802007c0:	a839                	j	802007de <vprintfmt+0x170>
            putch('0', putdat);
    802007c2:	03000513          	li	a0,48
    802007c6:	85a6                	mv	a1,s1
    802007c8:	e03e                	sd	a5,0(sp)
    802007ca:	9902                	jalr	s2
            putch('x', putdat);
    802007cc:	85a6                	mv	a1,s1
    802007ce:	07800513          	li	a0,120
    802007d2:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    802007d4:	0aa1                	addi	s5,s5,8
    802007d6:	ff8ab603          	ld	a2,-8(s5)
            goto number;
    802007da:	6782                	ld	a5,0(sp)
    802007dc:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
    802007de:	876e                	mv	a4,s11
    802007e0:	85a6                	mv	a1,s1
    802007e2:	854a                	mv	a0,s2
    802007e4:	e1fff0ef          	jal	ra,80200602 <printnum>
            break;
    802007e8:	b5c1                	j	802006a8 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
    802007ea:	000ab603          	ld	a2,0(s5)
    802007ee:	0aa1                	addi	s5,s5,8
    802007f0:	1c060663          	beqz	a2,802009bc <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
    802007f4:	00160413          	addi	s0,a2,1
    802007f8:	17b05c63          	blez	s11,80200970 <vprintfmt+0x302>
    802007fc:	02d00593          	li	a1,45
    80200800:	14b79263          	bne	a5,a1,80200944 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200804:	00064783          	lbu	a5,0(a2)
    80200808:	0007851b          	sext.w	a0,a5
    8020080c:	c905                	beqz	a0,8020083c <vprintfmt+0x1ce>
    8020080e:	000cc563          	bltz	s9,80200818 <vprintfmt+0x1aa>
    80200812:	3cfd                	addiw	s9,s9,-1
    80200814:	036c8263          	beq	s9,s6,80200838 <vprintfmt+0x1ca>
                    putch('?', putdat);
    80200818:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    8020081a:	18098463          	beqz	s3,802009a2 <vprintfmt+0x334>
    8020081e:	3781                	addiw	a5,a5,-32
    80200820:	18fbf163          	bleu	a5,s7,802009a2 <vprintfmt+0x334>
                    putch('?', putdat);
    80200824:	03f00513          	li	a0,63
    80200828:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020082a:	0405                	addi	s0,s0,1
    8020082c:	fff44783          	lbu	a5,-1(s0)
    80200830:	3dfd                	addiw	s11,s11,-1
    80200832:	0007851b          	sext.w	a0,a5
    80200836:	fd61                	bnez	a0,8020080e <vprintfmt+0x1a0>
            for (; width > 0; width --) {
    80200838:	e7b058e3          	blez	s11,802006a8 <vprintfmt+0x3a>
    8020083c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    8020083e:	85a6                	mv	a1,s1
    80200840:	02000513          	li	a0,32
    80200844:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200846:	e60d81e3          	beqz	s11,802006a8 <vprintfmt+0x3a>
    8020084a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    8020084c:	85a6                	mv	a1,s1
    8020084e:	02000513          	li	a0,32
    80200852:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200854:	fe0d94e3          	bnez	s11,8020083c <vprintfmt+0x1ce>
    80200858:	bd81                	j	802006a8 <vprintfmt+0x3a>
    if (lflag >= 2) {
    8020085a:	4705                	li	a4,1
    8020085c:	008a8593          	addi	a1,s5,8
    80200860:	01074463          	blt	a4,a6,80200868 <vprintfmt+0x1fa>
    else if (lflag) {
    80200864:	12080063          	beqz	a6,80200984 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
    80200868:	000ab603          	ld	a2,0(s5)
    8020086c:	46a9                	li	a3,10
    8020086e:	8aae                	mv	s5,a1
    80200870:	b7bd                	j	802007de <vprintfmt+0x170>
    80200872:	00144603          	lbu	a2,1(s0)
            padc = '-';
    80200876:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
    8020087a:	846a                	mv	s0,s10
    8020087c:	b5ad                	j	802006e6 <vprintfmt+0x78>
            putch(ch, putdat);
    8020087e:	85a6                	mv	a1,s1
    80200880:	02500513          	li	a0,37
    80200884:	9902                	jalr	s2
            break;
    80200886:	b50d                	j	802006a8 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
    80200888:	000aac83          	lw	s9,0(s5)
            goto process_precision;
    8020088c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    80200890:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
    80200892:	846a                	mv	s0,s10
            if (width < 0)
    80200894:	e40dd9e3          	bgez	s11,802006e6 <vprintfmt+0x78>
                width = precision, precision = -1;
    80200898:	8de6                	mv	s11,s9
    8020089a:	5cfd                	li	s9,-1
    8020089c:	b5a9                	j	802006e6 <vprintfmt+0x78>
            goto reswitch;
    8020089e:	00144603          	lbu	a2,1(s0)
            padc = '0';
    802008a2:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
    802008a6:	846a                	mv	s0,s10
            goto reswitch;
    802008a8:	bd3d                	j	802006e6 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
    802008aa:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
    802008ae:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802008b2:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    802008b4:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    802008b8:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802008bc:	fcd56ce3          	bltu	a0,a3,80200894 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
    802008c0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    802008c2:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
    802008c6:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
    802008ca:	0196873b          	addw	a4,a3,s9
    802008ce:	0017171b          	slliw	a4,a4,0x1
    802008d2:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
    802008d6:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
    802008da:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    802008de:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802008e2:	fcd57fe3          	bleu	a3,a0,802008c0 <vprintfmt+0x252>
    802008e6:	b77d                	j	80200894 <vprintfmt+0x226>
            if (width < 0)
    802008e8:	fffdc693          	not	a3,s11
    802008ec:	96fd                	srai	a3,a3,0x3f
    802008ee:	00ddfdb3          	and	s11,s11,a3
    802008f2:	00144603          	lbu	a2,1(s0)
    802008f6:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    802008f8:	846a                	mv	s0,s10
    802008fa:	b3f5                	j	802006e6 <vprintfmt+0x78>
            putch('%', putdat);
    802008fc:	85a6                	mv	a1,s1
    802008fe:	02500513          	li	a0,37
    80200902:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    80200904:	fff44703          	lbu	a4,-1(s0)
    80200908:	02500793          	li	a5,37
    8020090c:	8d22                	mv	s10,s0
    8020090e:	d8f70de3          	beq	a4,a5,802006a8 <vprintfmt+0x3a>
    80200912:	02500713          	li	a4,37
    80200916:	1d7d                	addi	s10,s10,-1
    80200918:	fffd4783          	lbu	a5,-1(s10)
    8020091c:	fee79de3          	bne	a5,a4,80200916 <vprintfmt+0x2a8>
    80200920:	b361                	j	802006a8 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    80200922:	00001617          	auipc	a2,0x1
    80200926:	9c660613          	addi	a2,a2,-1594 # 802012e8 <error_string+0xd8>
    8020092a:	85a6                	mv	a1,s1
    8020092c:	854a                	mv	a0,s2
    8020092e:	0ac000ef          	jal	ra,802009da <printfmt>
    80200932:	bb9d                	j	802006a8 <vprintfmt+0x3a>
                p = "(null)";
    80200934:	00001617          	auipc	a2,0x1
    80200938:	9ac60613          	addi	a2,a2,-1620 # 802012e0 <error_string+0xd0>
            if (width > 0 && padc != '-') {
    8020093c:	00001417          	auipc	s0,0x1
    80200940:	9a540413          	addi	s0,s0,-1627 # 802012e1 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200944:	8532                	mv	a0,a2
    80200946:	85e6                	mv	a1,s9
    80200948:	e032                	sd	a2,0(sp)
    8020094a:	e43e                	sd	a5,8(sp)
    8020094c:	102000ef          	jal	ra,80200a4e <strnlen>
    80200950:	40ad8dbb          	subw	s11,s11,a0
    80200954:	6602                	ld	a2,0(sp)
    80200956:	01b05d63          	blez	s11,80200970 <vprintfmt+0x302>
    8020095a:	67a2                	ld	a5,8(sp)
    8020095c:	2781                	sext.w	a5,a5
    8020095e:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
    80200960:	6522                	ld	a0,8(sp)
    80200962:	85a6                	mv	a1,s1
    80200964:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200966:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    80200968:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020096a:	6602                	ld	a2,0(sp)
    8020096c:	fe0d9ae3          	bnez	s11,80200960 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200970:	00064783          	lbu	a5,0(a2)
    80200974:	0007851b          	sext.w	a0,a5
    80200978:	e8051be3          	bnez	a0,8020080e <vprintfmt+0x1a0>
    8020097c:	b335                	j	802006a8 <vprintfmt+0x3a>
        return va_arg(*ap, int);
    8020097e:	000aa403          	lw	s0,0(s5)
    80200982:	bbf1                	j	8020075e <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
    80200984:	000ae603          	lwu	a2,0(s5)
    80200988:	46a9                	li	a3,10
    8020098a:	8aae                	mv	s5,a1
    8020098c:	bd89                	j	802007de <vprintfmt+0x170>
    8020098e:	000ae603          	lwu	a2,0(s5)
    80200992:	46c1                	li	a3,16
    80200994:	8aae                	mv	s5,a1
    80200996:	b5a1                	j	802007de <vprintfmt+0x170>
    80200998:	000ae603          	lwu	a2,0(s5)
    8020099c:	46a1                	li	a3,8
    8020099e:	8aae                	mv	s5,a1
    802009a0:	bd3d                	j	802007de <vprintfmt+0x170>
                    putch(ch, putdat);
    802009a2:	9902                	jalr	s2
    802009a4:	b559                	j	8020082a <vprintfmt+0x1bc>
                putch('-', putdat);
    802009a6:	85a6                	mv	a1,s1
    802009a8:	02d00513          	li	a0,45
    802009ac:	e03e                	sd	a5,0(sp)
    802009ae:	9902                	jalr	s2
                num = -(long long)num;
    802009b0:	8ace                	mv	s5,s3
    802009b2:	40800633          	neg	a2,s0
    802009b6:	46a9                	li	a3,10
    802009b8:	6782                	ld	a5,0(sp)
    802009ba:	b515                	j	802007de <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
    802009bc:	01b05663          	blez	s11,802009c8 <vprintfmt+0x35a>
    802009c0:	02d00693          	li	a3,45
    802009c4:	f6d798e3          	bne	a5,a3,80200934 <vprintfmt+0x2c6>
    802009c8:	00001417          	auipc	s0,0x1
    802009cc:	91940413          	addi	s0,s0,-1767 # 802012e1 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802009d0:	02800513          	li	a0,40
    802009d4:	02800793          	li	a5,40
    802009d8:	bd1d                	j	8020080e <vprintfmt+0x1a0>

00000000802009da <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009da:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    802009dc:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009e0:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009e2:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009e4:	ec06                	sd	ra,24(sp)
    802009e6:	f83a                	sd	a4,48(sp)
    802009e8:	fc3e                	sd	a5,56(sp)
    802009ea:	e0c2                	sd	a6,64(sp)
    802009ec:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    802009ee:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009f0:	c7fff0ef          	jal	ra,8020066e <vprintfmt>
}
    802009f4:	60e2                	ld	ra,24(sp)
    802009f6:	6161                	addi	sp,sp,80
    802009f8:	8082                	ret

00000000802009fa <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    802009fa:	00003797          	auipc	a5,0x3
    802009fe:	60678793          	addi	a5,a5,1542 # 80204000 <bootstacktop>
    __asm__ volatile (
    80200a02:	6398                	ld	a4,0(a5)
    80200a04:	4781                	li	a5,0
    80200a06:	88ba                	mv	a7,a4
    80200a08:	852a                	mv	a0,a0
    80200a0a:	85be                	mv	a1,a5
    80200a0c:	863e                	mv	a2,a5
    80200a0e:	00000073          	ecall
    80200a12:	87aa                	mv	a5,a0
}
    80200a14:	8082                	ret

0000000080200a16 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    80200a16:	00003797          	auipc	a5,0x3
    80200a1a:	5fa78793          	addi	a5,a5,1530 # 80204010 <edata>
    __asm__ volatile (
    80200a1e:	6398                	ld	a4,0(a5)
    80200a20:	4781                	li	a5,0
    80200a22:	88ba                	mv	a7,a4
    80200a24:	852a                	mv	a0,a0
    80200a26:	85be                	mv	a1,a5
    80200a28:	863e                	mv	a2,a5
    80200a2a:	00000073          	ecall
    80200a2e:	87aa                	mv	a5,a0
}
    80200a30:	8082                	ret

0000000080200a32 <sbi_shutdown>:


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    80200a32:	00003797          	auipc	a5,0x3
    80200a36:	5d678793          	addi	a5,a5,1494 # 80204008 <SBI_SHUTDOWN>
    __asm__ volatile (
    80200a3a:	6398                	ld	a4,0(a5)
    80200a3c:	4781                	li	a5,0
    80200a3e:	88ba                	mv	a7,a4
    80200a40:	853e                	mv	a0,a5
    80200a42:	85be                	mv	a1,a5
    80200a44:	863e                	mv	a2,a5
    80200a46:	00000073          	ecall
    80200a4a:	87aa                	mv	a5,a0
    80200a4c:	8082                	ret

0000000080200a4e <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
    80200a4e:	c185                	beqz	a1,80200a6e <strnlen+0x20>
    80200a50:	00054783          	lbu	a5,0(a0)
    80200a54:	cf89                	beqz	a5,80200a6e <strnlen+0x20>
    size_t cnt = 0;
    80200a56:	4781                	li	a5,0
    80200a58:	a021                	j	80200a60 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
    80200a5a:	00074703          	lbu	a4,0(a4)
    80200a5e:	c711                	beqz	a4,80200a6a <strnlen+0x1c>
        cnt ++;
    80200a60:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200a62:	00f50733          	add	a4,a0,a5
    80200a66:	fef59ae3          	bne	a1,a5,80200a5a <strnlen+0xc>
    }
    return cnt;
}
    80200a6a:	853e                	mv	a0,a5
    80200a6c:	8082                	ret
    size_t cnt = 0;
    80200a6e:	4781                	li	a5,0
}
    80200a70:	853e                	mv	a0,a5
    80200a72:	8082                	ret

0000000080200a74 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200a74:	ca01                	beqz	a2,80200a84 <memset+0x10>
    80200a76:	962a                	add	a2,a2,a0
    char *p = s;
    80200a78:	87aa                	mv	a5,a0
        *p ++ = c;
    80200a7a:	0785                	addi	a5,a5,1
    80200a7c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200a80:	fec79de3          	bne	a5,a2,80200a7a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200a84:	8082                	ret
