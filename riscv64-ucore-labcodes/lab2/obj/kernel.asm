
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址,lui：将32位立即数的32-12位加载到寄存器32-12位，并进行符号扩展。%hi:提取64位中的32-12位
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中，中间16位不管
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fe250513          	addi	a0,a0,-30 # ffffffffc0206018 <edata>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	58a60613          	addi	a2,a2,1418 # ffffffffc02065c8 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	0b5010ef          	jal	ra,ffffffffc0201902 <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	8c250513          	addi	a0,a0,-1854 # ffffffffc0201918 <etext+0x4>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	0a6010ef          	jal	ra,ffffffffc0201110 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3fc000ef          	jal	ra,ffffffffc020046a <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	39a000ef          	jal	ra,ffffffffc020040c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e8000ef          	jal	ra,ffffffffc020045e <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200084:	3ce000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200088:	401c                	lw	a5,0(s0)
}
ffffffffc020008a:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
}
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200096:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000aa:	32e010ef          	jal	ra,ffffffffc02013d8 <vprintfmt>
    return cnt;
}
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000da:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000dc:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000de:	2fa010ef          	jal	ra,ffffffffc02013d8 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ea:	3680006f          	j	ffffffffc0200452 <cons_putc>

ffffffffc02000ee <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ee:	1101                	addi	sp,sp,-32
ffffffffc02000f0:	e822                	sd	s0,16(sp)
ffffffffc02000f2:	ec06                	sd	ra,24(sp)
ffffffffc02000f4:	e426                	sd	s1,8(sp)
ffffffffc02000f6:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f8:	00054503          	lbu	a0,0(a0)
ffffffffc02000fc:	c51d                	beqz	a0,ffffffffc020012a <cputs+0x3c>
ffffffffc02000fe:	0405                	addi	s0,s0,1
ffffffffc0200100:	4485                	li	s1,1
ffffffffc0200102:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200104:	34e000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200112:	f96d                	bnez	a0,ffffffffc0200104 <cputs+0x16>
ffffffffc0200114:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200118:	4529                	li	a0,10
ffffffffc020011a:	338000ef          	jal	ra,ffffffffc0200452 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011e:	8522                	mv	a0,s0
ffffffffc0200120:	60e2                	ld	ra,24(sp)
ffffffffc0200122:	6442                	ld	s0,16(sp)
ffffffffc0200124:	64a2                	ld	s1,8(sp)
ffffffffc0200126:	6105                	addi	sp,sp,32
ffffffffc0200128:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020012a:	4405                	li	s0,1
ffffffffc020012c:	b7f5                	j	ffffffffc0200118 <cputs+0x2a>

ffffffffc020012e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012e:	1141                	addi	sp,sp,-16
ffffffffc0200130:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200132:	328000ef          	jal	ra,ffffffffc020045a <cons_getc>
ffffffffc0200136:	dd75                	beqz	a0,ffffffffc0200132 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200138:	60a2                	ld	ra,8(sp)
ffffffffc020013a:	0141                	addi	sp,sp,16
ffffffffc020013c:	8082                	ret

ffffffffc020013e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200140:	00002517          	auipc	a0,0x2
ffffffffc0200144:	82850513          	addi	a0,a0,-2008 # ffffffffc0201968 <etext+0x54>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00002517          	auipc	a0,0x2
ffffffffc020015a:	83250513          	addi	a0,a0,-1998 # ffffffffc0201988 <etext+0x74>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00001597          	auipc	a1,0x1
ffffffffc0200166:	7b258593          	addi	a1,a1,1970 # ffffffffc0201914 <etext>
ffffffffc020016a:	00002517          	auipc	a0,0x2
ffffffffc020016e:	83e50513          	addi	a0,a0,-1986 # ffffffffc02019a8 <etext+0x94>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00006597          	auipc	a1,0x6
ffffffffc020017a:	ea258593          	addi	a1,a1,-350 # ffffffffc0206018 <edata>
ffffffffc020017e:	00002517          	auipc	a0,0x2
ffffffffc0200182:	84a50513          	addi	a0,a0,-1974 # ffffffffc02019c8 <etext+0xb4>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00006597          	auipc	a1,0x6
ffffffffc020018e:	43e58593          	addi	a1,a1,1086 # ffffffffc02065c8 <end>
ffffffffc0200192:	00002517          	auipc	a0,0x2
ffffffffc0200196:	85650513          	addi	a0,a0,-1962 # ffffffffc02019e8 <etext+0xd4>
ffffffffc020019a:	f1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019e:	00007597          	auipc	a1,0x7
ffffffffc02001a2:	82958593          	addi	a1,a1,-2007 # ffffffffc02069c7 <end+0x3ff>
ffffffffc02001a6:	00000797          	auipc	a5,0x0
ffffffffc02001aa:	e9078793          	addi	a5,a5,-368 # ffffffffc0200036 <kern_init>
ffffffffc02001ae:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b2:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b6:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b8:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001bc:	95be                	add	a1,a1,a5
ffffffffc02001be:	85a9                	srai	a1,a1,0xa
ffffffffc02001c0:	00002517          	auipc	a0,0x2
ffffffffc02001c4:	84850513          	addi	a0,a0,-1976 # ffffffffc0201a08 <etext+0xf4>
}
ffffffffc02001c8:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ca:	eedff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02001ce <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001ce:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001d0:	00001617          	auipc	a2,0x1
ffffffffc02001d4:	76860613          	addi	a2,a2,1896 # ffffffffc0201938 <etext+0x24>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00001517          	auipc	a0,0x1
ffffffffc02001e0:	77450513          	addi	a0,a0,1908 # ffffffffc0201950 <etext+0x3c>
void print_stackframe(void) {
ffffffffc02001e4:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e6:	1c6000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001ea <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ea:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ec:	00002617          	auipc	a2,0x2
ffffffffc02001f0:	92c60613          	addi	a2,a2,-1748 # ffffffffc0201b18 <commands+0xe0>
ffffffffc02001f4:	00002597          	auipc	a1,0x2
ffffffffc02001f8:	94458593          	addi	a1,a1,-1724 # ffffffffc0201b38 <commands+0x100>
ffffffffc02001fc:	00002517          	auipc	a0,0x2
ffffffffc0200200:	94450513          	addi	a0,a0,-1724 # ffffffffc0201b40 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00002617          	auipc	a2,0x2
ffffffffc020020e:	94660613          	addi	a2,a2,-1722 # ffffffffc0201b50 <commands+0x118>
ffffffffc0200212:	00002597          	auipc	a1,0x2
ffffffffc0200216:	96658593          	addi	a1,a1,-1690 # ffffffffc0201b78 <commands+0x140>
ffffffffc020021a:	00002517          	auipc	a0,0x2
ffffffffc020021e:	92650513          	addi	a0,a0,-1754 # ffffffffc0201b40 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00002617          	auipc	a2,0x2
ffffffffc020022a:	96260613          	addi	a2,a2,-1694 # ffffffffc0201b88 <commands+0x150>
ffffffffc020022e:	00002597          	auipc	a1,0x2
ffffffffc0200232:	97a58593          	addi	a1,a1,-1670 # ffffffffc0201ba8 <commands+0x170>
ffffffffc0200236:	00002517          	auipc	a0,0x2
ffffffffc020023a:	90a50513          	addi	a0,a0,-1782 # ffffffffc0201b40 <commands+0x108>
ffffffffc020023e:	e79ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    }
    return 0;
}
ffffffffc0200242:	60a2                	ld	ra,8(sp)
ffffffffc0200244:	4501                	li	a0,0
ffffffffc0200246:	0141                	addi	sp,sp,16
ffffffffc0200248:	8082                	ret

ffffffffc020024a <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024a:	1141                	addi	sp,sp,-16
ffffffffc020024c:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020024e:	ef1ff0ef          	jal	ra,ffffffffc020013e <print_kerninfo>
    return 0;
}
ffffffffc0200252:	60a2                	ld	ra,8(sp)
ffffffffc0200254:	4501                	li	a0,0
ffffffffc0200256:	0141                	addi	sp,sp,16
ffffffffc0200258:	8082                	ret

ffffffffc020025a <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	1141                	addi	sp,sp,-16
ffffffffc020025c:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020025e:	f71ff0ef          	jal	ra,ffffffffc02001ce <print_stackframe>
    return 0;
}
ffffffffc0200262:	60a2                	ld	ra,8(sp)
ffffffffc0200264:	4501                	li	a0,0
ffffffffc0200266:	0141                	addi	sp,sp,16
ffffffffc0200268:	8082                	ret

ffffffffc020026a <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020026a:	7115                	addi	sp,sp,-224
ffffffffc020026c:	e962                	sd	s8,144(sp)
ffffffffc020026e:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200270:	00002517          	auipc	a0,0x2
ffffffffc0200274:	81050513          	addi	a0,a0,-2032 # ffffffffc0201a80 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200278:	ed86                	sd	ra,216(sp)
ffffffffc020027a:	e9a2                	sd	s0,208(sp)
ffffffffc020027c:	e5a6                	sd	s1,200(sp)
ffffffffc020027e:	e1ca                	sd	s2,192(sp)
ffffffffc0200280:	fd4e                	sd	s3,184(sp)
ffffffffc0200282:	f952                	sd	s4,176(sp)
ffffffffc0200284:	f556                	sd	s5,168(sp)
ffffffffc0200286:	f15a                	sd	s6,160(sp)
ffffffffc0200288:	ed5e                	sd	s7,152(sp)
ffffffffc020028a:	e566                	sd	s9,136(sp)
ffffffffc020028c:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020028e:	e29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200292:	00002517          	auipc	a0,0x2
ffffffffc0200296:	81650513          	addi	a0,a0,-2026 # ffffffffc0201aa8 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00001c97          	auipc	s9,0x1
ffffffffc02002ac:	790c8c93          	addi	s9,s9,1936 # ffffffffc0201a38 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00002997          	auipc	s3,0x2
ffffffffc02002b4:	82098993          	addi	s3,s3,-2016 # ffffffffc0201ad0 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00002917          	auipc	s2,0x2
ffffffffc02002bc:	82090913          	addi	s2,s2,-2016 # ffffffffc0201ad8 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00002b17          	auipc	s6,0x2
ffffffffc02002c6:	81eb0b13          	addi	s6,s6,-2018 # ffffffffc0201ae0 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00002a97          	auipc	s5,0x2
ffffffffc02002ce:	86ea8a93          	addi	s5,s5,-1938 # ffffffffc0201b38 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	48e010ef          	jal	ra,ffffffffc0201764 <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	5fc010ef          	jal	ra,ffffffffc02018e4 <strchr>
ffffffffc02002ec:	c925                	beqz	a0,ffffffffc020035c <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002ee:	00144583          	lbu	a1,1(s0)
ffffffffc02002f2:	00040023          	sb	zero,0(s0)
ffffffffc02002f6:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002f8:	f5fd                	bnez	a1,ffffffffc02002e6 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002fa:	dce9                	beqz	s1,ffffffffc02002d4 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002fc:	6582                	ld	a1,0(sp)
ffffffffc02002fe:	00001d17          	auipc	s10,0x1
ffffffffc0200302:	73ad0d13          	addi	s10,s10,1850 # ffffffffc0201a38 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	5ae010ef          	jal	ra,ffffffffc02018ba <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	59a010ef          	jal	ra,ffffffffc02018ba <strcmp>
ffffffffc0200324:	f57d                	bnez	a0,ffffffffc0200312 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200326:	00141793          	slli	a5,s0,0x1
ffffffffc020032a:	97a2                	add	a5,a5,s0
ffffffffc020032c:	078e                	slli	a5,a5,0x3
ffffffffc020032e:	97e6                	add	a5,a5,s9
ffffffffc0200330:	6b9c                	ld	a5,16(a5)
ffffffffc0200332:	8662                	mv	a2,s8
ffffffffc0200334:	002c                	addi	a1,sp,8
ffffffffc0200336:	fff4851b          	addiw	a0,s1,-1
ffffffffc020033a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020033c:	f8055ce3          	bgez	a0,ffffffffc02002d4 <kmonitor+0x6a>
}
ffffffffc0200340:	60ee                	ld	ra,216(sp)
ffffffffc0200342:	644e                	ld	s0,208(sp)
ffffffffc0200344:	64ae                	ld	s1,200(sp)
ffffffffc0200346:	690e                	ld	s2,192(sp)
ffffffffc0200348:	79ea                	ld	s3,184(sp)
ffffffffc020034a:	7a4a                	ld	s4,176(sp)
ffffffffc020034c:	7aaa                	ld	s5,168(sp)
ffffffffc020034e:	7b0a                	ld	s6,160(sp)
ffffffffc0200350:	6bea                	ld	s7,152(sp)
ffffffffc0200352:	6c4a                	ld	s8,144(sp)
ffffffffc0200354:	6caa                	ld	s9,136(sp)
ffffffffc0200356:	6d0a                	ld	s10,128(sp)
ffffffffc0200358:	612d                	addi	sp,sp,224
ffffffffc020035a:	8082                	ret
        if (*buf == '\0') {
ffffffffc020035c:	00044783          	lbu	a5,0(s0)
ffffffffc0200360:	dfc9                	beqz	a5,ffffffffc02002fa <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc0200362:	03448863          	beq	s1,s4,ffffffffc0200392 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc0200366:	00349793          	slli	a5,s1,0x3
ffffffffc020036a:	0118                	addi	a4,sp,128
ffffffffc020036c:	97ba                	add	a5,a5,a4
ffffffffc020036e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200372:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200376:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200378:	e591                	bnez	a1,ffffffffc0200384 <kmonitor+0x11a>
ffffffffc020037a:	b749                	j	ffffffffc02002fc <kmonitor+0x92>
            buf ++;
ffffffffc020037c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020037e:	00044583          	lbu	a1,0(s0)
ffffffffc0200382:	ddad                	beqz	a1,ffffffffc02002fc <kmonitor+0x92>
ffffffffc0200384:	854a                	mv	a0,s2
ffffffffc0200386:	55e010ef          	jal	ra,ffffffffc02018e4 <strchr>
ffffffffc020038a:	d96d                	beqz	a0,ffffffffc020037c <kmonitor+0x112>
ffffffffc020038c:	00044583          	lbu	a1,0(s0)
ffffffffc0200390:	bf91                	j	ffffffffc02002e4 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020039a:	b7f1                	j	ffffffffc0200366 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	76250513          	addi	a0,a0,1890 # ffffffffc0201b00 <commands+0xc8>
ffffffffc02003a6:	d11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return 0;
ffffffffc02003aa:	b72d                	j	ffffffffc02002d4 <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	06c30313          	addi	t1,t1,108 # ffffffffc0206418 <is_panic>
ffffffffc02003b4:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	02031c63          	bnez	t1,ffffffffc0200400 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	8432                	mv	s0,a2
ffffffffc02003d0:	00006717          	auipc	a4,0x6
ffffffffc02003d4:	04f72423          	sw	a5,72(a4) # ffffffffc0206418 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d8:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003da:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003dc:	85aa                	mv	a1,a0
ffffffffc02003de:	00001517          	auipc	a0,0x1
ffffffffc02003e2:	7da50513          	addi	a0,a0,2010 # ffffffffc0201bb8 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02003e6:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e8:	ccfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003ec:	65a2                	ld	a1,8(sp)
ffffffffc02003ee:	8522                	mv	a0,s0
ffffffffc02003f0:	ca7ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc02003f4:	00001517          	auipc	a0,0x1
ffffffffc02003f8:	63c50513          	addi	a0,a0,1596 # ffffffffc0201a30 <etext+0x11c>
ffffffffc02003fc:	cbbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200400:	064000ef          	jal	ra,ffffffffc0200464 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200404:	4501                	li	a0,0
ffffffffc0200406:	e65ff0ef          	jal	ra,ffffffffc020026a <kmonitor>
ffffffffc020040a:	bfed                	j	ffffffffc0200404 <__panic+0x58>

ffffffffc020040c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020040c:	1141                	addi	sp,sp,-16
ffffffffc020040e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200410:	02000793          	li	a5,32
ffffffffc0200414:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200418:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020041c:	67e1                	lui	a5,0x18
ffffffffc020041e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200422:	953e                	add	a0,a0,a5
ffffffffc0200424:	41a010ef          	jal	ra,ffffffffc020183e <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007bb23          	sd	zero,22(a5) # ffffffffc0206440 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00001517          	auipc	a0,0x1
ffffffffc0200436:	7a650513          	addi	a0,a0,1958 # ffffffffc0201bd8 <commands+0x1a0>
}
ffffffffc020043a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020043c:	c7bff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc0200440 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200440:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200444:	67e1                	lui	a5,0x18
ffffffffc0200446:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020044a:	953e                	add	a0,a0,a5
ffffffffc020044c:	3f20106f          	j	ffffffffc020183e <sbi_set_timer>

ffffffffc0200450 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200450:	8082                	ret

ffffffffc0200452 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200452:	0ff57513          	andi	a0,a0,255
ffffffffc0200456:	3cc0106f          	j	ffffffffc0201822 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	4000106f          	j	ffffffffc020185a <sbi_console_getchar>

ffffffffc020045e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200464:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200468:	8082                	ret

ffffffffc020046a <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020046a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020046e:	00000797          	auipc	a5,0x0
ffffffffc0200472:	32278793          	addi	a5,a5,802 # ffffffffc0200790 <__alltraps>
ffffffffc0200476:	10579073          	csrw	stvec,a5
}
ffffffffc020047a:	8082                	ret

ffffffffc020047c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020047e:	1141                	addi	sp,sp,-16
ffffffffc0200480:	e022                	sd	s0,0(sp)
ffffffffc0200482:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200484:	00002517          	auipc	a0,0x2
ffffffffc0200488:	86c50513          	addi	a0,a0,-1940 # ffffffffc0201cf0 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00002517          	auipc	a0,0x2
ffffffffc0200498:	87450513          	addi	a0,a0,-1932 # ffffffffc0201d08 <commands+0x2d0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00002517          	auipc	a0,0x2
ffffffffc02004a6:	87e50513          	addi	a0,a0,-1922 # ffffffffc0201d20 <commands+0x2e8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00002517          	auipc	a0,0x2
ffffffffc02004b4:	88850513          	addi	a0,a0,-1912 # ffffffffc0201d38 <commands+0x300>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00002517          	auipc	a0,0x2
ffffffffc02004c2:	89250513          	addi	a0,a0,-1902 # ffffffffc0201d50 <commands+0x318>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00002517          	auipc	a0,0x2
ffffffffc02004d0:	89c50513          	addi	a0,a0,-1892 # ffffffffc0201d68 <commands+0x330>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00002517          	auipc	a0,0x2
ffffffffc02004de:	8a650513          	addi	a0,a0,-1882 # ffffffffc0201d80 <commands+0x348>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00002517          	auipc	a0,0x2
ffffffffc02004ec:	8b050513          	addi	a0,a0,-1872 # ffffffffc0201d98 <commands+0x360>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00002517          	auipc	a0,0x2
ffffffffc02004fa:	8ba50513          	addi	a0,a0,-1862 # ffffffffc0201db0 <commands+0x378>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00002517          	auipc	a0,0x2
ffffffffc0200508:	8c450513          	addi	a0,a0,-1852 # ffffffffc0201dc8 <commands+0x390>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0201de0 <commands+0x3a8>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	8d850513          	addi	a0,a0,-1832 # ffffffffc0201df8 <commands+0x3c0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	8e250513          	addi	a0,a0,-1822 # ffffffffc0201e10 <commands+0x3d8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0201e28 <commands+0x3f0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	8f650513          	addi	a0,a0,-1802 # ffffffffc0201e40 <commands+0x408>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	90050513          	addi	a0,a0,-1792 # ffffffffc0201e58 <commands+0x420>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	90a50513          	addi	a0,a0,-1782 # ffffffffc0201e70 <commands+0x438>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	91450513          	addi	a0,a0,-1772 # ffffffffc0201e88 <commands+0x450>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	91e50513          	addi	a0,a0,-1762 # ffffffffc0201ea0 <commands+0x468>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	92850513          	addi	a0,a0,-1752 # ffffffffc0201eb8 <commands+0x480>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	93250513          	addi	a0,a0,-1742 # ffffffffc0201ed0 <commands+0x498>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	93c50513          	addi	a0,a0,-1732 # ffffffffc0201ee8 <commands+0x4b0>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	94650513          	addi	a0,a0,-1722 # ffffffffc0201f00 <commands+0x4c8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	95050513          	addi	a0,a0,-1712 # ffffffffc0201f18 <commands+0x4e0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	95a50513          	addi	a0,a0,-1702 # ffffffffc0201f30 <commands+0x4f8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	96450513          	addi	a0,a0,-1692 # ffffffffc0201f48 <commands+0x510>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	96e50513          	addi	a0,a0,-1682 # ffffffffc0201f60 <commands+0x528>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	97850513          	addi	a0,a0,-1672 # ffffffffc0201f78 <commands+0x540>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	98250513          	addi	a0,a0,-1662 # ffffffffc0201f90 <commands+0x558>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	98c50513          	addi	a0,a0,-1652 # ffffffffc0201fa8 <commands+0x570>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	99650513          	addi	a0,a0,-1642 # ffffffffc0201fc0 <commands+0x588>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	99c50513          	addi	a0,a0,-1636 # ffffffffc0201fd8 <commands+0x5a0>
}
ffffffffc0200644:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200646:	a71ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020064a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020064e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200650:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200652:	00002517          	auipc	a0,0x2
ffffffffc0200656:	99e50513          	addi	a0,a0,-1634 # ffffffffc0201ff0 <commands+0x5b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	a5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1bff0ef          	jal	ra,ffffffffc020047c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00002517          	auipc	a0,0x2
ffffffffc020066e:	99e50513          	addi	a0,a0,-1634 # ffffffffc0202008 <commands+0x5d0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	9a650513          	addi	a0,a0,-1626 # ffffffffc0202020 <commands+0x5e8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0202038 <commands+0x600>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	9b250513          	addi	a0,a0,-1614 # ffffffffc0202050 <commands+0x618>
}
ffffffffc02006a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a8:	a0fff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02006ac <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006ac:	11853783          	ld	a5,280(a0)
ffffffffc02006b0:	577d                	li	a4,-1
ffffffffc02006b2:	8305                	srli	a4,a4,0x1
ffffffffc02006b4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02006b6:	472d                	li	a4,11
ffffffffc02006b8:	08f76f63          	bltu	a4,a5,ffffffffc0200756 <interrupt_handler+0xaa>
ffffffffc02006bc:	00001717          	auipc	a4,0x1
ffffffffc02006c0:	53870713          	addi	a4,a4,1336 # ffffffffc0201bf4 <commands+0x1bc>
ffffffffc02006c4:	078a                	slli	a5,a5,0x2
ffffffffc02006c6:	97ba                	add	a5,a5,a4
ffffffffc02006c8:	439c                	lw	a5,0(a5)
ffffffffc02006ca:	97ba                	add	a5,a5,a4
ffffffffc02006cc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006ce:	00001517          	auipc	a0,0x1
ffffffffc02006d2:	5ba50513          	addi	a0,a0,1466 # ffffffffc0201c88 <commands+0x250>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	58e50513          	addi	a0,a0,1422 # ffffffffc0201c68 <commands+0x230>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	54250513          	addi	a0,a0,1346 # ffffffffc0201c28 <commands+0x1f0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	5b650513          	addi	a0,a0,1462 # ffffffffc0201ca8 <commands+0x270>
ffffffffc02006fa:	9bdff06f          	j	ffffffffc02000b6 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006fe:	1141                	addi	sp,sp,-16
ffffffffc0200700:	e022                	sd	s0,0(sp)
ffffffffc0200702:	e406                	sd	ra,8(sp)
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
            clock_set_next_event();
            ticks++;
ffffffffc0200704:	00006417          	auipc	s0,0x6
ffffffffc0200708:	d3c40413          	addi	s0,s0,-708 # ffffffffc0206440 <ticks>
            clock_set_next_event();
ffffffffc020070c:	d35ff0ef          	jal	ra,ffffffffc0200440 <clock_set_next_event>
            ticks++;
ffffffffc0200710:	601c                	ld	a5,0(s0)
ffffffffc0200712:	0785                	addi	a5,a5,1
ffffffffc0200714:	00006717          	auipc	a4,0x6
ffffffffc0200718:	d2f73623          	sd	a5,-724(a4) # ffffffffc0206440 <ticks>
            if(ticks % TICK_NUM==0)
ffffffffc020071c:	601c                	ld	a5,0(s0)
ffffffffc020071e:	06400713          	li	a4,100
ffffffffc0200722:	02e7f7b3          	remu	a5,a5,a4
ffffffffc0200726:	cb95                	beqz	a5,ffffffffc020075a <interrupt_handler+0xae>
                print_ticks();
            if(ticks / TICK_NUM == 10)
ffffffffc0200728:	601c                	ld	a5,0(s0)
ffffffffc020072a:	06300713          	li	a4,99
ffffffffc020072e:	c1878793          	addi	a5,a5,-1000
ffffffffc0200732:	02f77d63          	bleu	a5,a4,ffffffffc020076c <interrupt_handler+0xc0>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200736:	60a2                	ld	ra,8(sp)
ffffffffc0200738:	6402                	ld	s0,0(sp)
ffffffffc020073a:	0141                	addi	sp,sp,16
ffffffffc020073c:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020073e:	00001517          	auipc	a0,0x1
ffffffffc0200742:	59250513          	addi	a0,a0,1426 # ffffffffc0201cd0 <commands+0x298>
ffffffffc0200746:	971ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020074a:	00001517          	auipc	a0,0x1
ffffffffc020074e:	4fe50513          	addi	a0,a0,1278 # ffffffffc0201c48 <commands+0x210>
ffffffffc0200752:	965ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200756:	ef5ff06f          	j	ffffffffc020064a <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020075a:	06400593          	li	a1,100
ffffffffc020075e:	00001517          	auipc	a0,0x1
ffffffffc0200762:	56250513          	addi	a0,a0,1378 # ffffffffc0201cc0 <commands+0x288>
ffffffffc0200766:	951ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020076a:	bf7d                	j	ffffffffc0200728 <interrupt_handler+0x7c>
}
ffffffffc020076c:	6402                	ld	s0,0(sp)
ffffffffc020076e:	60a2                	ld	ra,8(sp)
ffffffffc0200770:	0141                	addi	sp,sp,16
                sbi_shutdown();
ffffffffc0200772:	1060106f          	j	ffffffffc0201878 <sbi_shutdown>

ffffffffc0200776 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200776:	11853783          	ld	a5,280(a0)
ffffffffc020077a:	0007c863          	bltz	a5,ffffffffc020078a <trap+0x14>
    switch (tf->cause) {
ffffffffc020077e:	472d                	li	a4,11
ffffffffc0200780:	00f76363          	bltu	a4,a5,ffffffffc0200786 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200784:	8082                	ret
            print_trapframe(tf);
ffffffffc0200786:	ec5ff06f          	j	ffffffffc020064a <print_trapframe>
        interrupt_handler(tf);
ffffffffc020078a:	f23ff06f          	j	ffffffffc02006ac <interrupt_handler>
	...

ffffffffc0200790 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200790:	14011073          	csrw	sscratch,sp
ffffffffc0200794:	712d                	addi	sp,sp,-288
ffffffffc0200796:	e002                	sd	zero,0(sp)
ffffffffc0200798:	e406                	sd	ra,8(sp)
ffffffffc020079a:	ec0e                	sd	gp,24(sp)
ffffffffc020079c:	f012                	sd	tp,32(sp)
ffffffffc020079e:	f416                	sd	t0,40(sp)
ffffffffc02007a0:	f81a                	sd	t1,48(sp)
ffffffffc02007a2:	fc1e                	sd	t2,56(sp)
ffffffffc02007a4:	e0a2                	sd	s0,64(sp)
ffffffffc02007a6:	e4a6                	sd	s1,72(sp)
ffffffffc02007a8:	e8aa                	sd	a0,80(sp)
ffffffffc02007aa:	ecae                	sd	a1,88(sp)
ffffffffc02007ac:	f0b2                	sd	a2,96(sp)
ffffffffc02007ae:	f4b6                	sd	a3,104(sp)
ffffffffc02007b0:	f8ba                	sd	a4,112(sp)
ffffffffc02007b2:	fcbe                	sd	a5,120(sp)
ffffffffc02007b4:	e142                	sd	a6,128(sp)
ffffffffc02007b6:	e546                	sd	a7,136(sp)
ffffffffc02007b8:	e94a                	sd	s2,144(sp)
ffffffffc02007ba:	ed4e                	sd	s3,152(sp)
ffffffffc02007bc:	f152                	sd	s4,160(sp)
ffffffffc02007be:	f556                	sd	s5,168(sp)
ffffffffc02007c0:	f95a                	sd	s6,176(sp)
ffffffffc02007c2:	fd5e                	sd	s7,184(sp)
ffffffffc02007c4:	e1e2                	sd	s8,192(sp)
ffffffffc02007c6:	e5e6                	sd	s9,200(sp)
ffffffffc02007c8:	e9ea                	sd	s10,208(sp)
ffffffffc02007ca:	edee                	sd	s11,216(sp)
ffffffffc02007cc:	f1f2                	sd	t3,224(sp)
ffffffffc02007ce:	f5f6                	sd	t4,232(sp)
ffffffffc02007d0:	f9fa                	sd	t5,240(sp)
ffffffffc02007d2:	fdfe                	sd	t6,248(sp)
ffffffffc02007d4:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007d8:	100024f3          	csrr	s1,sstatus
ffffffffc02007dc:	14102973          	csrr	s2,sepc
ffffffffc02007e0:	143029f3          	csrr	s3,stval
ffffffffc02007e4:	14202a73          	csrr	s4,scause
ffffffffc02007e8:	e822                	sd	s0,16(sp)
ffffffffc02007ea:	e226                	sd	s1,256(sp)
ffffffffc02007ec:	e64a                	sd	s2,264(sp)
ffffffffc02007ee:	ea4e                	sd	s3,272(sp)
ffffffffc02007f0:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007f2:	850a                	mv	a0,sp
    jal trap
ffffffffc02007f4:	f83ff0ef          	jal	ra,ffffffffc0200776 <trap>

ffffffffc02007f8 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007f8:	6492                	ld	s1,256(sp)
ffffffffc02007fa:	6932                	ld	s2,264(sp)
ffffffffc02007fc:	10049073          	csrw	sstatus,s1
ffffffffc0200800:	14191073          	csrw	sepc,s2
ffffffffc0200804:	60a2                	ld	ra,8(sp)
ffffffffc0200806:	61e2                	ld	gp,24(sp)
ffffffffc0200808:	7202                	ld	tp,32(sp)
ffffffffc020080a:	72a2                	ld	t0,40(sp)
ffffffffc020080c:	7342                	ld	t1,48(sp)
ffffffffc020080e:	73e2                	ld	t2,56(sp)
ffffffffc0200810:	6406                	ld	s0,64(sp)
ffffffffc0200812:	64a6                	ld	s1,72(sp)
ffffffffc0200814:	6546                	ld	a0,80(sp)
ffffffffc0200816:	65e6                	ld	a1,88(sp)
ffffffffc0200818:	7606                	ld	a2,96(sp)
ffffffffc020081a:	76a6                	ld	a3,104(sp)
ffffffffc020081c:	7746                	ld	a4,112(sp)
ffffffffc020081e:	77e6                	ld	a5,120(sp)
ffffffffc0200820:	680a                	ld	a6,128(sp)
ffffffffc0200822:	68aa                	ld	a7,136(sp)
ffffffffc0200824:	694a                	ld	s2,144(sp)
ffffffffc0200826:	69ea                	ld	s3,152(sp)
ffffffffc0200828:	7a0a                	ld	s4,160(sp)
ffffffffc020082a:	7aaa                	ld	s5,168(sp)
ffffffffc020082c:	7b4a                	ld	s6,176(sp)
ffffffffc020082e:	7bea                	ld	s7,184(sp)
ffffffffc0200830:	6c0e                	ld	s8,192(sp)
ffffffffc0200832:	6cae                	ld	s9,200(sp)
ffffffffc0200834:	6d4e                	ld	s10,208(sp)
ffffffffc0200836:	6dee                	ld	s11,216(sp)
ffffffffc0200838:	7e0e                	ld	t3,224(sp)
ffffffffc020083a:	7eae                	ld	t4,232(sp)
ffffffffc020083c:	7f4e                	ld	t5,240(sp)
ffffffffc020083e:	7fee                	ld	t6,248(sp)
ffffffffc0200840:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200842:	10200073          	sret

ffffffffc0200846 <buddy_init>:
 *  初始化buddy结构体
 */
static void
buddy_init(void) {
    // 初始化链表数组中的每个free_list头
    for (int i = 0;i < MAX_BUDDY_ORDER;i ++){
ffffffffc0200846:	00006797          	auipc	a5,0x6
ffffffffc020084a:	c0a78793          	addi	a5,a5,-1014 # ffffffffc0206450 <buddy_s+0x8>
ffffffffc020084e:	00006717          	auipc	a4,0x6
ffffffffc0200852:	d4270713          	addi	a4,a4,-702 # ffffffffc0206590 <buddy_s+0x148>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200856:	e79c                	sd	a5,8(a5)
ffffffffc0200858:	e39c                	sd	a5,0(a5)
ffffffffc020085a:	07c1                	addi	a5,a5,16
ffffffffc020085c:	fee79de3          	bne	a5,a4,ffffffffc0200856 <buddy_init+0x10>
        list_init(buddy_array + i); 
    }
    max_order = 0;
ffffffffc0200860:	00006797          	auipc	a5,0x6
ffffffffc0200864:	be07a423          	sw	zero,-1048(a5) # ffffffffc0206448 <buddy_s>
    nr_free = 0;
ffffffffc0200868:	00006797          	auipc	a5,0x6
ffffffffc020086c:	d207ac23          	sw	zero,-712(a5) # ffffffffc02065a0 <buddy_s+0x158>
    return;
}
ffffffffc0200870:	8082                	ret

ffffffffc0200872 <buddy_get_buddy>:
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200872:	00006797          	auipc	a5,0x6
ffffffffc0200876:	d4e78793          	addi	a5,a5,-690 # ffffffffc02065c0 <pages>
ffffffffc020087a:	639c                	ld	a5,0(a5)
ffffffffc020087c:	00002717          	auipc	a4,0x2
ffffffffc0200880:	a0470713          	addi	a4,a4,-1532 # ffffffffc0202280 <commands+0x848>
ffffffffc0200884:	6318                	ld	a4,0(a4)
ffffffffc0200886:	40f507b3          	sub	a5,a0,a5
ffffffffc020088a:	878d                	srai	a5,a5,0x3
ffffffffc020088c:	02e787b3          	mul	a5,a5,a4
ffffffffc0200890:	00002617          	auipc	a2,0x2
ffffffffc0200894:	eb860613          	addi	a2,a2,-328 # ffffffffc0202748 <nbase>
static struct Page*
buddy_get_buddy(struct Page *page) {
    unsigned int order = page->property;
    extern ppn_t first_ppn;
    //此处操作的逻辑：一个page的buddy和它只在最高位不同，其余位相同，例如order=2时，page为100-111，则buddy为000-011，因此采用异或
    unsigned int buddy_ppn =first_ppn + ((1 << order) ^ (page2ppn(page) - first_ppn));
ffffffffc0200898:	00006717          	auipc	a4,0x6
ffffffffc020089c:	b8870713          	addi	a4,a4,-1144 # ffffffffc0206420 <first_ppn>
ffffffffc02008a0:	6210                	ld	a2,0(a2)
ffffffffc02008a2:	4314                	lw	a3,0(a4)
ffffffffc02008a4:	490c                	lw	a1,16(a0)
ffffffffc02008a6:	4705                	li	a4,1
ffffffffc02008a8:	00b7173b          	sllw	a4,a4,a1
ffffffffc02008ac:	97b2                	add	a5,a5,a2
ffffffffc02008ae:	40d7863b          	subw	a2,a5,a3
ffffffffc02008b2:	8f31                	xor	a4,a4,a2
ffffffffc02008b4:	9f35                	addw	a4,a4,a3
    if (buddy_ppn > page2ppn(page)) {
ffffffffc02008b6:	1702                	slli	a4,a4,0x20
ffffffffc02008b8:	9301                	srli	a4,a4,0x20
ffffffffc02008ba:	00e7fa63          	bleu	a4,a5,ffffffffc02008ce <buddy_get_buddy+0x5c>
        return page + (buddy_ppn - page2ppn(page));
ffffffffc02008be:	40f707b3          	sub	a5,a4,a5
ffffffffc02008c2:	00279713          	slli	a4,a5,0x2
ffffffffc02008c6:	97ba                	add	a5,a5,a4
ffffffffc02008c8:	078e                	slli	a5,a5,0x3
ffffffffc02008ca:	953e                	add	a0,a0,a5
ffffffffc02008cc:	8082                	ret
    }
    else {
        return page - (page2ppn(page) - buddy_ppn);
ffffffffc02008ce:	8f99                	sub	a5,a5,a4
ffffffffc02008d0:	00279713          	slli	a4,a5,0x2
ffffffffc02008d4:	97ba                	add	a5,a5,a4
ffffffffc02008d6:	078e                	slli	a5,a5,0x3
ffffffffc02008d8:	8d1d                	sub	a0,a0,a5
    }
 
}
ffffffffc02008da:	8082                	ret

ffffffffc02008dc <buddy_nr_free_pages>:
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}
ffffffffc02008dc:	00006517          	auipc	a0,0x6
ffffffffc02008e0:	cc456503          	lwu	a0,-828(a0) # ffffffffc02065a0 <buddy_s+0x158>
ffffffffc02008e4:	8082                	ret

ffffffffc02008e6 <buddy_init_memmap>:
buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc02008e6:	1141                	addi	sp,sp,-16
ffffffffc02008e8:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02008ea:	c1e9                	beqz	a1,ffffffffc02009ac <buddy_init_memmap+0xc6>
    if (n & (n - 1)) {
ffffffffc02008ec:	fff58793          	addi	a5,a1,-1
ffffffffc02008f0:	8fed                	and	a5,a5,a1
ffffffffc02008f2:	cb99                	beqz	a5,ffffffffc0200908 <buddy_init_memmap+0x22>
    size_t res = 1;
ffffffffc02008f4:	4785                	li	a5,1
ffffffffc02008f6:	a011                	j	ffffffffc02008fa <buddy_init_memmap+0x14>
            res = res << 1;
ffffffffc02008f8:	87ba                	mv	a5,a4
            n = n >> 1;
ffffffffc02008fa:	8185                	srli	a1,a1,0x1
            res = res << 1;
ffffffffc02008fc:	00179713          	slli	a4,a5,0x1
        while (n) {
ffffffffc0200900:	fde5                	bnez	a1,ffffffffc02008f8 <buddy_init_memmap+0x12>
        return res>>1; 
ffffffffc0200902:	55fd                	li	a1,-1
ffffffffc0200904:	8185                	srli	a1,a1,0x1
ffffffffc0200906:	8dfd                	and	a1,a1,a5
    while (n >> 1) {
ffffffffc0200908:	0015d793          	srli	a5,a1,0x1
    unsigned int order = 0;
ffffffffc020090c:	4601                	li	a2,0
    while (n >> 1) {
ffffffffc020090e:	c781                	beqz	a5,ffffffffc0200916 <buddy_init_memmap+0x30>
ffffffffc0200910:	8385                	srli	a5,a5,0x1
        order ++;
ffffffffc0200912:	2605                	addiw	a2,a2,1
    while (n >> 1) {
ffffffffc0200914:	fff5                	bnez	a5,ffffffffc0200910 <buddy_init_memmap+0x2a>
    for (; p != base + pnum; p ++) {
ffffffffc0200916:	00259693          	slli	a3,a1,0x2
ffffffffc020091a:	96ae                	add	a3,a3,a1
ffffffffc020091c:	068e                	slli	a3,a3,0x3
ffffffffc020091e:	96aa                	add	a3,a3,a0
ffffffffc0200920:	02d50563          	beq	a0,a3,ffffffffc020094a <buddy_init_memmap+0x64>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200924:	651c                	ld	a5,8(a0)
        assert(PageReserved(p));
ffffffffc0200926:	8b85                	andi	a5,a5,1
ffffffffc0200928:	c3b5                	beqz	a5,ffffffffc020098c <buddy_init_memmap+0xa6>
ffffffffc020092a:	87aa                	mv	a5,a0
        p->property = -1;   // 全部初始化为非头页
ffffffffc020092c:	587d                	li	a6,-1
ffffffffc020092e:	a021                	j	ffffffffc0200936 <buddy_init_memmap+0x50>
ffffffffc0200930:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0200932:	8b05                	andi	a4,a4,1
ffffffffc0200934:	cf21                	beqz	a4,ffffffffc020098c <buddy_init_memmap+0xa6>
        p->flags = 0;
ffffffffc0200936:	0007b423          	sd	zero,8(a5)
        p->property = -1;   // 全部初始化为非头页
ffffffffc020093a:	0107a823          	sw	a6,16(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020093e:	0007a023          	sw	zero,0(a5)
    for (; p != base + pnum; p ++) {
ffffffffc0200942:	02878793          	addi	a5,a5,40
ffffffffc0200946:	fed795e3          	bne	a5,a3,ffffffffc0200930 <buddy_init_memmap+0x4a>
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
ffffffffc020094a:	02061793          	slli	a5,a2,0x20
ffffffffc020094e:	9381                	srli	a5,a5,0x20
    max_order = order;
ffffffffc0200950:	00006697          	auipc	a3,0x6
ffffffffc0200954:	af868693          	addi	a3,a3,-1288 # ffffffffc0206448 <buddy_s>
ffffffffc0200958:	0792                	slli	a5,a5,0x4
ffffffffc020095a:	00f68833          	add	a6,a3,a5
ffffffffc020095e:	01083703          	ld	a4,16(a6)
    nr_free = pnum;
ffffffffc0200962:	00006897          	auipc	a7,0x6
ffffffffc0200966:	c2b8af23          	sw	a1,-962(a7) # ffffffffc02065a0 <buddy_s+0x158>
    max_order = order;
ffffffffc020096a:	00006897          	auipc	a7,0x6
ffffffffc020096e:	acc8af23          	sw	a2,-1314(a7) # ffffffffc0206448 <buddy_s>
    list_add(&(buddy_array[max_order]), &(base->page_link)); // 将第一页base插入数组的最后一个链表，作为初始化的最大块——16384,的头页
ffffffffc0200972:	01850593          	addi	a1,a0,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200976:	e30c                	sd	a1,0(a4)
}    
ffffffffc0200978:	60a2                	ld	ra,8(sp)
    list_add(&(buddy_array[max_order]), &(base->page_link)); // 将第一页base插入数组的最后一个链表，作为初始化的最大块——16384,的头页
ffffffffc020097a:	07a1                	addi	a5,a5,8
ffffffffc020097c:	00b83823          	sd	a1,16(a6)
ffffffffc0200980:	97b6                	add	a5,a5,a3
    elm->next = next;
ffffffffc0200982:	f118                	sd	a4,32(a0)
    elm->prev = prev;
ffffffffc0200984:	ed1c                	sd	a5,24(a0)
    base->property = max_order;                       // 将第一页base的property设为最大块的2幂
ffffffffc0200986:	c910                	sw	a2,16(a0)
}    
ffffffffc0200988:	0141                	addi	sp,sp,16
ffffffffc020098a:	8082                	ret
        assert(PageReserved(p));
ffffffffc020098c:	00002697          	auipc	a3,0x2
ffffffffc0200990:	93468693          	addi	a3,a3,-1740 # ffffffffc02022c0 <commands+0x888>
ffffffffc0200994:	00002617          	auipc	a2,0x2
ffffffffc0200998:	8fc60613          	addi	a2,a2,-1796 # ffffffffc0202290 <commands+0x858>
ffffffffc020099c:	06500593          	li	a1,101
ffffffffc02009a0:	00002517          	auipc	a0,0x2
ffffffffc02009a4:	90850513          	addi	a0,a0,-1784 # ffffffffc02022a8 <commands+0x870>
ffffffffc02009a8:	a05ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc02009ac:	00002697          	auipc	a3,0x2
ffffffffc02009b0:	8dc68693          	addi	a3,a3,-1828 # ffffffffc0202288 <commands+0x850>
ffffffffc02009b4:	00002617          	auipc	a2,0x2
ffffffffc02009b8:	8dc60613          	addi	a2,a2,-1828 # ffffffffc0202290 <commands+0x858>
ffffffffc02009bc:	05d00593          	li	a1,93
ffffffffc02009c0:	00002517          	auipc	a0,0x2
ffffffffc02009c4:	8e850513          	addi	a0,a0,-1816 # ffffffffc02022a8 <commands+0x870>
ffffffffc02009c8:	9e5ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02009cc <show_buddy_array>:
    free_pages(p1, 3);

}

static void
show_buddy_array(void) {
ffffffffc02009cc:	715d                	addi	sp,sp,-80
    cprintf("test: Printing buddy array:\n");
ffffffffc02009ce:	00002517          	auipc	a0,0x2
ffffffffc02009d2:	93a50513          	addi	a0,a0,-1734 # ffffffffc0202308 <buddy_pmm_manager+0x38>
show_buddy_array(void) {
ffffffffc02009d6:	ec56                	sd	s5,24(sp)
ffffffffc02009d8:	e486                	sd	ra,72(sp)
ffffffffc02009da:	e0a2                	sd	s0,64(sp)
ffffffffc02009dc:	fc26                	sd	s1,56(sp)
ffffffffc02009de:	f84a                	sd	s2,48(sp)
ffffffffc02009e0:	f44e                	sd	s3,40(sp)
ffffffffc02009e2:	f052                	sd	s4,32(sp)
ffffffffc02009e4:	e85a                	sd	s6,16(sp)
ffffffffc02009e6:	e45e                	sd	s7,8(sp)
    for (int i = 0;i < max_order + 1;i ++) {
ffffffffc02009e8:	00006a97          	auipc	s5,0x6
ffffffffc02009ec:	a60a8a93          	addi	s5,s5,-1440 # ffffffffc0206448 <buddy_s>
    cprintf("test: Printing buddy array:\n");
ffffffffc02009f0:	ec6ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    for (int i = 0;i < max_order + 1;i ++) {
ffffffffc02009f4:	000aa703          	lw	a4,0(s5)
ffffffffc02009f8:	57fd                	li	a5,-1
ffffffffc02009fa:	04f70f63          	beq	a4,a5,ffffffffc0200a58 <show_buddy_array+0x8c>
ffffffffc02009fe:	00006497          	auipc	s1,0x6
ffffffffc0200a02:	a5248493          	addi	s1,s1,-1454 # ffffffffc0206450 <buddy_s+0x8>
ffffffffc0200a06:	4a01                	li	s4,0
        cprintf("%d layer: ", i);
ffffffffc0200a08:	00002b97          	auipc	s7,0x2
ffffffffc0200a0c:	920b8b93          	addi	s7,s7,-1760 # ffffffffc0202328 <buddy_pmm_manager+0x58>
        list_entry_t *le = &(buddy_array[i]);
        while ((le = list_next(le)) != &(buddy_array[i])) {
            struct Page *p = le2page(le, page_link);
            cprintf("%d ", 1 << (p->property));
ffffffffc0200a10:	4985                	li	s3,1
ffffffffc0200a12:	00002917          	auipc	s2,0x2
ffffffffc0200a16:	92690913          	addi	s2,s2,-1754 # ffffffffc0202338 <buddy_pmm_manager+0x68>
        }
        cprintf("\n");
ffffffffc0200a1a:	00001b17          	auipc	s6,0x1
ffffffffc0200a1e:	016b0b13          	addi	s6,s6,22 # ffffffffc0201a30 <etext+0x11c>
        cprintf("%d layer: ", i);
ffffffffc0200a22:	85d2                	mv	a1,s4
ffffffffc0200a24:	855e                	mv	a0,s7
ffffffffc0200a26:	e90ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return listelm->next;
ffffffffc0200a2a:	6480                	ld	s0,8(s1)
        while ((le = list_next(le)) != &(buddy_array[i])) {
ffffffffc0200a2c:	00848c63          	beq	s1,s0,ffffffffc0200a44 <show_buddy_array+0x78>
            cprintf("%d ", 1 << (p->property));
ffffffffc0200a30:	ff842583          	lw	a1,-8(s0)
ffffffffc0200a34:	854a                	mv	a0,s2
ffffffffc0200a36:	00b995bb          	sllw	a1,s3,a1
ffffffffc0200a3a:	e7cff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200a3e:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != &(buddy_array[i])) {
ffffffffc0200a40:	fe9418e3          	bne	s0,s1,ffffffffc0200a30 <show_buddy_array+0x64>
        cprintf("\n");
ffffffffc0200a44:	855a                	mv	a0,s6
ffffffffc0200a46:	e70ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    for (int i = 0;i < max_order + 1;i ++) {
ffffffffc0200a4a:	000aa783          	lw	a5,0(s5)
ffffffffc0200a4e:	2a05                	addiw	s4,s4,1
ffffffffc0200a50:	04c1                	addi	s1,s1,16
ffffffffc0200a52:	2785                	addiw	a5,a5,1
ffffffffc0200a54:	fcfa67e3          	bltu	s4,a5,ffffffffc0200a22 <show_buddy_array+0x56>
    }
    cprintf("---------------------------\n");
    return;
}
ffffffffc0200a58:	6406                	ld	s0,64(sp)
ffffffffc0200a5a:	60a6                	ld	ra,72(sp)
ffffffffc0200a5c:	74e2                	ld	s1,56(sp)
ffffffffc0200a5e:	7942                	ld	s2,48(sp)
ffffffffc0200a60:	79a2                	ld	s3,40(sp)
ffffffffc0200a62:	7a02                	ld	s4,32(sp)
ffffffffc0200a64:	6ae2                	ld	s5,24(sp)
ffffffffc0200a66:	6b42                	ld	s6,16(sp)
ffffffffc0200a68:	6ba2                	ld	s7,8(sp)
    cprintf("---------------------------\n");
ffffffffc0200a6a:	00002517          	auipc	a0,0x2
ffffffffc0200a6e:	8d650513          	addi	a0,a0,-1834 # ffffffffc0202340 <buddy_pmm_manager+0x70>
}
ffffffffc0200a72:	6161                	addi	sp,sp,80
    cprintf("---------------------------\n");
ffffffffc0200a74:	e42ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc0200a78 <buddy_free_pages>:
buddy_free_pages(struct Page *base, size_t n) {
ffffffffc0200a78:	715d                	addi	sp,sp,-80
ffffffffc0200a7a:	e486                	sd	ra,72(sp)
ffffffffc0200a7c:	e0a2                	sd	s0,64(sp)
ffffffffc0200a7e:	fc26                	sd	s1,56(sp)
ffffffffc0200a80:	f84a                	sd	s2,48(sp)
ffffffffc0200a82:	f44e                	sd	s3,40(sp)
ffffffffc0200a84:	f052                	sd	s4,32(sp)
ffffffffc0200a86:	ec56                	sd	s5,24(sp)
ffffffffc0200a88:	e85a                	sd	s6,16(sp)
ffffffffc0200a8a:	e45e                	sd	s7,8(sp)
    assert(n > 0);
ffffffffc0200a8c:	10058863          	beqz	a1,ffffffffc0200b9c <buddy_free_pages+0x124>
    unsigned int pnum = 1 << (base->property);
ffffffffc0200a90:	4904                	lw	s1,16(a0)
    if (n & (n - 1)) {
ffffffffc0200a92:	fff58793          	addi	a5,a1,-1
    unsigned int pnum = 1 << (base->property);
ffffffffc0200a96:	4a85                	li	s5,1
    if (n & (n - 1)) {
ffffffffc0200a98:	8fed                	and	a5,a5,a1
ffffffffc0200a9a:	842a                	mv	s0,a0
    unsigned int pnum = 1 << (base->property);
ffffffffc0200a9c:	009a9abb          	sllw	s5,s5,s1
    if (n & (n - 1)) {
ffffffffc0200aa0:	ebe5                	bnez	a5,ffffffffc0200b90 <buddy_free_pages+0x118>
    assert(ROUNDUP2(n) == pnum);
ffffffffc0200aa2:	020a9793          	slli	a5,s5,0x20
ffffffffc0200aa6:	9381                	srli	a5,a5,0x20
ffffffffc0200aa8:	10b79a63          	bne	a5,a1,ffffffffc0200bbc <buddy_free_pages+0x144>
    buddy = buddy_get_buddy(left_block);
ffffffffc0200aac:	8522                	mv	a0,s0
ffffffffc0200aae:	dc5ff0ef          	jal	ra,ffffffffc0200872 <buddy_get_buddy>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200ab2:	02049713          	slli	a4,s1,0x20
ffffffffc0200ab6:	9301                	srli	a4,a4,0x20
ffffffffc0200ab8:	00006b17          	auipc	s6,0x6
ffffffffc0200abc:	990b0b13          	addi	s6,s6,-1648 # ffffffffc0206448 <buddy_s>
ffffffffc0200ac0:	0712                	slli	a4,a4,0x4
ffffffffc0200ac2:	00eb05b3          	add	a1,s6,a4
ffffffffc0200ac6:	6990                	ld	a2,16(a1)
ffffffffc0200ac8:	6514                	ld	a3,8(a0)
    list_add(&(buddy_array[left_block->property]), &(left_block->page_link));
ffffffffc0200aca:	01840b93          	addi	s7,s0,24
    prev->next = next->prev = elm;
ffffffffc0200ace:	01763023          	sd	s7,0(a2)
ffffffffc0200ad2:	0721                	addi	a4,a4,8
ffffffffc0200ad4:	0175b823          	sd	s7,16(a1)
ffffffffc0200ad8:	975a                	add	a4,a4,s6
ffffffffc0200ada:	8285                	srli	a3,a3,0x1
    elm->prev = prev;
ffffffffc0200adc:	ec18                	sd	a4,24(s0)
    elm->next = next;
ffffffffc0200ade:	f010                	sd	a2,32(s0)
    while (!PageProperty(buddy) && left_block->property < max_order) {
ffffffffc0200ae0:	0016f713          	andi	a4,a3,1
    buddy = buddy_get_buddy(left_block);
ffffffffc0200ae4:	87aa                	mv	a5,a0
ffffffffc0200ae6:	00840913          	addi	s2,s0,8
    while (!PageProperty(buddy) && left_block->property < max_order) {
ffffffffc0200aea:	ef2d                	bnez	a4,ffffffffc0200b64 <buddy_free_pages+0xec>
ffffffffc0200aec:	000b2703          	lw	a4,0(s6)
ffffffffc0200af0:	06e4fa63          	bleu	a4,s1,ffffffffc0200b64 <buddy_free_pages+0xec>
            left_block->property = -1;
ffffffffc0200af4:	5a7d                	li	s4,-1
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200af6:	59f5                	li	s3,-3
        if (left_block > buddy) { // 若当前左块为更大块的右块
ffffffffc0200af8:	0087fd63          	bleu	s0,a5,ffffffffc0200b12 <buddy_free_pages+0x9a>
            left_block->property = -1;
ffffffffc0200afc:	01442823          	sw	s4,16(s0)
ffffffffc0200b00:	6139302f          	amoand.d	zero,s3,(s2)
ffffffffc0200b04:	8722                	mv	a4,s0
ffffffffc0200b06:	00878913          	addi	s2,a5,8
ffffffffc0200b0a:	843e                	mv	s0,a5
ffffffffc0200b0c:	01878b93          	addi	s7,a5,24
ffffffffc0200b10:	87ba                	mv	a5,a4
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b12:	6c10                	ld	a2,24(s0)
ffffffffc0200b14:	7014                	ld	a3,32(s0)
        left_block->property += 1;
ffffffffc0200b16:	4818                	lw	a4,16(s0)
        buddy = buddy_get_buddy(left_block);
ffffffffc0200b18:	8522                	mv	a0,s0
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200b1a:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0200b1c:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b1e:	0187b803          	ld	a6,24(a5)
ffffffffc0200b22:	738c                	ld	a1,32(a5)
        left_block->property += 1;
ffffffffc0200b24:	2705                	addiw	a4,a4,1
    __list_add(elm, listelm, listelm->next);
ffffffffc0200b26:	02071793          	slli	a5,a4,0x20
ffffffffc0200b2a:	83f1                	srli	a5,a5,0x1c
    prev->next = next;
ffffffffc0200b2c:	00b83423          	sd	a1,8(a6)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200b30:	00fb0633          	add	a2,s6,a5
ffffffffc0200b34:	6a14                	ld	a3,16(a2)
    next->prev = prev;
ffffffffc0200b36:	0105b023          	sd	a6,0(a1)
ffffffffc0200b3a:	c818                	sw	a4,16(s0)
    prev->next = next->prev = elm;
ffffffffc0200b3c:	0176b023          	sd	s7,0(a3)
        list_add(&(buddy_array[left_block->property]), &(left_block->page_link)); // 头插入相应链表
ffffffffc0200b40:	07a1                	addi	a5,a5,8
ffffffffc0200b42:	01763823          	sd	s7,16(a2)
ffffffffc0200b46:	97da                	add	a5,a5,s6
    elm->prev = prev;
ffffffffc0200b48:	ec1c                	sd	a5,24(s0)
    elm->next = next;
ffffffffc0200b4a:	f014                	sd	a3,32(s0)
        left_block->property += 1;
ffffffffc0200b4c:	0007049b          	sext.w	s1,a4
        buddy = buddy_get_buddy(left_block);
ffffffffc0200b50:	d23ff0ef          	jal	ra,ffffffffc0200872 <buddy_get_buddy>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b54:	6518                	ld	a4,8(a0)
ffffffffc0200b56:	87aa                	mv	a5,a0
    while (!PageProperty(buddy) && left_block->property < max_order) {
ffffffffc0200b58:	8b09                	andi	a4,a4,2
ffffffffc0200b5a:	e709                	bnez	a4,ffffffffc0200b64 <buddy_free_pages+0xec>
ffffffffc0200b5c:	000b2703          	lw	a4,0(s6)
ffffffffc0200b60:	f8e4ece3          	bltu	s1,a4,ffffffffc0200af8 <buddy_free_pages+0x80>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200b64:	57f5                	li	a5,-3
ffffffffc0200b66:	60f9302f          	amoand.d	zero,a5,(s2)
    nr_free += pnum;
ffffffffc0200b6a:	158b2783          	lw	a5,344(s6)
}
ffffffffc0200b6e:	60a6                	ld	ra,72(sp)
ffffffffc0200b70:	6406                	ld	s0,64(sp)
    nr_free += pnum;
ffffffffc0200b72:	01578abb          	addw	s5,a5,s5
ffffffffc0200b76:	00006797          	auipc	a5,0x6
ffffffffc0200b7a:	a357a523          	sw	s5,-1494(a5) # ffffffffc02065a0 <buddy_s+0x158>
}
ffffffffc0200b7e:	74e2                	ld	s1,56(sp)
ffffffffc0200b80:	7942                	ld	s2,48(sp)
ffffffffc0200b82:	79a2                	ld	s3,40(sp)
ffffffffc0200b84:	7a02                	ld	s4,32(sp)
ffffffffc0200b86:	6ae2                	ld	s5,24(sp)
ffffffffc0200b88:	6b42                	ld	s6,16(sp)
ffffffffc0200b8a:	6ba2                	ld	s7,8(sp)
ffffffffc0200b8c:	6161                	addi	sp,sp,80
ffffffffc0200b8e:	8082                	ret
    size_t res = 1;
ffffffffc0200b90:	4785                	li	a5,1
            n = n >> 1;
ffffffffc0200b92:	8185                	srli	a1,a1,0x1
            res = res << 1;
ffffffffc0200b94:	0786                	slli	a5,a5,0x1
        while (n) {
ffffffffc0200b96:	fdf5                	bnez	a1,ffffffffc0200b92 <buddy_free_pages+0x11a>
            res = res << 1;
ffffffffc0200b98:	85be                	mv	a1,a5
ffffffffc0200b9a:	b721                	j	ffffffffc0200aa2 <buddy_free_pages+0x2a>
    assert(n > 0);
ffffffffc0200b9c:	00001697          	auipc	a3,0x1
ffffffffc0200ba0:	6ec68693          	addi	a3,a3,1772 # ffffffffc0202288 <commands+0x850>
ffffffffc0200ba4:	00001617          	auipc	a2,0x1
ffffffffc0200ba8:	6ec60613          	addi	a2,a2,1772 # ffffffffc0202290 <commands+0x858>
ffffffffc0200bac:	0ae00593          	li	a1,174
ffffffffc0200bb0:	00001517          	auipc	a0,0x1
ffffffffc0200bb4:	6f850513          	addi	a0,a0,1784 # ffffffffc02022a8 <commands+0x870>
ffffffffc0200bb8:	ff4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(ROUNDUP2(n) == pnum);
ffffffffc0200bbc:	00001697          	auipc	a3,0x1
ffffffffc0200bc0:	6ac68693          	addi	a3,a3,1708 # ffffffffc0202268 <commands+0x830>
ffffffffc0200bc4:	00001617          	auipc	a2,0x1
ffffffffc0200bc8:	6cc60613          	addi	a2,a2,1740 # ffffffffc0202290 <commands+0x858>
ffffffffc0200bcc:	0b000593          	li	a1,176
ffffffffc0200bd0:	00001517          	auipc	a0,0x1
ffffffffc0200bd4:	6d850513          	addi	a0,a0,1752 # ffffffffc02022a8 <commands+0x870>
ffffffffc0200bd8:	fd4ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200bdc <buddy_alloc_pages>:
buddy_alloc_pages(size_t n) {
ffffffffc0200bdc:	7139                	addi	sp,sp,-64
ffffffffc0200bde:	fc06                	sd	ra,56(sp)
ffffffffc0200be0:	f822                	sd	s0,48(sp)
ffffffffc0200be2:	f426                	sd	s1,40(sp)
ffffffffc0200be4:	f04a                	sd	s2,32(sp)
ffffffffc0200be6:	ec4e                	sd	s3,24(sp)
ffffffffc0200be8:	e852                	sd	s4,16(sp)
ffffffffc0200bea:	e456                	sd	s5,8(sp)
    assert(n > 0);
ffffffffc0200bec:	1a050263          	beqz	a0,ffffffffc0200d90 <buddy_alloc_pages+0x1b4>
    if (n > nr_free) {
ffffffffc0200bf0:	00006e17          	auipc	t3,0x6
ffffffffc0200bf4:	858e0e13          	addi	t3,t3,-1960 # ffffffffc0206448 <buddy_s>
ffffffffc0200bf8:	158e2f03          	lw	t5,344(t3)
ffffffffc0200bfc:	020f1793          	slli	a5,t5,0x20
ffffffffc0200c00:	9381                	srli	a5,a5,0x20
ffffffffc0200c02:	14a7e163          	bltu	a5,a0,ffffffffc0200d44 <buddy_alloc_pages+0x168>
    if (n & (n - 1)) {
ffffffffc0200c06:	fff50793          	addi	a5,a0,-1
ffffffffc0200c0a:	8fe9                	and	a5,a5,a0
ffffffffc0200c0c:	12079663          	bnez	a5,ffffffffc0200d38 <buddy_alloc_pages+0x15c>
    while (n >> 1) {
ffffffffc0200c10:	00155793          	srli	a5,a0,0x1
ffffffffc0200c14:	12078a63          	beqz	a5,ffffffffc0200d48 <buddy_alloc_pages+0x16c>
    unsigned int order = 0;
ffffffffc0200c18:	4881                	li	a7,0
    while (n >> 1) {
ffffffffc0200c1a:	8385                	srli	a5,a5,0x1
        order ++;
ffffffffc0200c1c:	2885                	addiw	a7,a7,1
    while (n >> 1) {
ffffffffc0200c1e:	fff5                	bnez	a5,ffffffffc0200c1a <buddy_alloc_pages+0x3e>
ffffffffc0200c20:	02089793          	slli	a5,a7,0x20
ffffffffc0200c24:	83f1                	srli	a5,a5,0x1c
ffffffffc0200c26:	00878713          	addi	a4,a5,8
    return list->next == list;
ffffffffc0200c2a:	97f2                	add	a5,a5,t3
ffffffffc0200c2c:	6b84                	ld	s1,16(a5)
    if (!list_empty(&(buddy_array[order]))) {
ffffffffc0200c2e:	9772                	add	a4,a4,t3
ffffffffc0200c30:	0ee49663          	bne	s1,a4,ffffffffc0200d1c <buddy_alloc_pages+0x140>
        for (int i = order;i < max_order + 1;i ++) {
ffffffffc0200c34:	000e2283          	lw	t0,0(t3)
ffffffffc0200c38:	0008841b          	sext.w	s0,a7
            if (!list_empty(&(buddy_array[i]))) {
ffffffffc0200c3c:	00441f93          	slli	t6,s0,0x4
ffffffffc0200c40:	00240e93          	addi	t4,s0,2
ffffffffc0200c44:	008f8393          	addi	t2,t6,8
ffffffffc0200c48:	0e92                	slli	t4,t4,0x4
        for (int i = order;i < max_order + 1;i ++) {
ffffffffc0200c4a:	0012831b          	addiw	t1,t0,1
    assert(n > 0 && n <= max_order);
ffffffffc0200c4e:	1282                	slli	t0,t0,0x20
            if (!list_empty(&(buddy_array[i]))) {
ffffffffc0200c50:	93f2                	add	t2,t2,t3
    assert(n > 0 && n <= max_order);
ffffffffc0200c52:	0202d293          	srli	t0,t0,0x20
ffffffffc0200c56:	9ef2                	add	t4,t4,t3
ffffffffc0200c58:	9ff2                	add	t6,t6,t3
ffffffffc0200c5a:	0014091b          	addiw	s2,s0,1
    page_b = page_a + (1 << (n - 1));
ffffffffc0200c5e:	4985                	li	s3,1
ffffffffc0200c60:	883e                	mv	a6,a5
        for (int i = order;i < max_order + 1;i ++) {
ffffffffc0200c62:	0268f663          	bleu	t1,a7,ffffffffc0200c8e <buddy_alloc_pages+0xb2>
            if (!list_empty(&(buddy_array[i]))) {
ffffffffc0200c66:	010fb783          	ld	a5,16(t6)
ffffffffc0200c6a:	04779363          	bne	a5,t2,ffffffffc0200cb0 <buddy_alloc_pages+0xd4>
ffffffffc0200c6e:	874a                	mv	a4,s2
ffffffffc0200c70:	87f6                	mv	a5,t4
ffffffffc0200c72:	a811                	j	ffffffffc0200c86 <buddy_alloc_pages+0xaa>
ffffffffc0200c74:	6390                	ld	a2,0(a5)
ffffffffc0200c76:	ff878693          	addi	a3,a5,-8
ffffffffc0200c7a:	00170593          	addi	a1,a4,1
ffffffffc0200c7e:	07c1                	addi	a5,a5,16
ffffffffc0200c80:	02d61963          	bne	a2,a3,ffffffffc0200cb2 <buddy_alloc_pages+0xd6>
ffffffffc0200c84:	872e                	mv	a4,a1
        for (int i = order;i < max_order + 1;i ++) {
ffffffffc0200c86:	0007069b          	sext.w	a3,a4
ffffffffc0200c8a:	fe66e5e3          	bltu	a3,t1,ffffffffc0200c74 <buddy_alloc_pages+0x98>
    struct Page *page = NULL;
ffffffffc0200c8e:	4781                	li	a5,0
    nr_free -= pnum;
ffffffffc0200c90:	40af0f3b          	subw	t5,t5,a0
ffffffffc0200c94:	00006717          	auipc	a4,0x6
ffffffffc0200c98:	91e72623          	sw	t5,-1780(a4) # ffffffffc02065a0 <buddy_s+0x158>
}
ffffffffc0200c9c:	70e2                	ld	ra,56(sp)
ffffffffc0200c9e:	7442                	ld	s0,48(sp)
ffffffffc0200ca0:	74a2                	ld	s1,40(sp)
ffffffffc0200ca2:	7902                	ld	s2,32(sp)
ffffffffc0200ca4:	69e2                	ld	s3,24(sp)
ffffffffc0200ca6:	6a42                	ld	s4,16(sp)
ffffffffc0200ca8:	6aa2                	ld	s5,8(sp)
ffffffffc0200caa:	853e                	mv	a0,a5
ffffffffc0200cac:	6121                	addi	sp,sp,64
ffffffffc0200cae:	8082                	ret
            if (!list_empty(&(buddy_array[i]))) {
ffffffffc0200cb0:	8722                	mv	a4,s0
    assert(n > 0 && n <= max_order);
ffffffffc0200cb2:	cf59                	beqz	a4,ffffffffc0200d50 <buddy_alloc_pages+0x174>
ffffffffc0200cb4:	08e2ee63          	bltu	t0,a4,ffffffffc0200d50 <buddy_alloc_pages+0x174>
ffffffffc0200cb8:	00471693          	slli	a3,a4,0x4
ffffffffc0200cbc:	00de07b3          	add	a5,t3,a3
ffffffffc0200cc0:	6b9c                	ld	a5,16(a5)
    assert(!list_empty(&(buddy_array[n])));
ffffffffc0200cc2:	06a1                	addi	a3,a3,8
ffffffffc0200cc4:	96f2                	add	a3,a3,t3
ffffffffc0200cc6:	0ad78563          	beq	a5,a3,ffffffffc0200d70 <buddy_alloc_pages+0x194>
    page_b = page_a + (1 << (n - 1));
ffffffffc0200cca:	fff7061b          	addiw	a2,a4,-1
ffffffffc0200cce:	00c995bb          	sllw	a1,s3,a2
ffffffffc0200cd2:	00259693          	slli	a3,a1,0x2
ffffffffc0200cd6:	96ae                	add	a3,a3,a1
ffffffffc0200cd8:	068e                	slli	a3,a3,0x3
    __list_del(listelm->prev, listelm->next);
ffffffffc0200cda:	0007ba83          	ld	s5,0(a5)
ffffffffc0200cde:	0087ba03          	ld	s4,8(a5)
ffffffffc0200ce2:	16a1                	addi	a3,a3,-24
    page_a->property = n - 1;
ffffffffc0200ce4:	fec7ac23          	sw	a2,-8(a5)
    page_b = page_a + (1 << (n - 1));
ffffffffc0200ce8:	96be                	add	a3,a3,a5
    list_add(&(buddy_array[n-1]), &(page_a->page_link));
ffffffffc0200cea:	177d                	addi	a4,a4,-1
    page_b->property = n - 1;
ffffffffc0200cec:	ca90                	sw	a2,16(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200cee:	0712                	slli	a4,a4,0x4
    prev->next = next;
ffffffffc0200cf0:	014ab423          	sd	s4,8(s5)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200cf4:	00ee05b3          	add	a1,t3,a4
    next->prev = prev;
ffffffffc0200cf8:	015a3023          	sd	s5,0(s4)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200cfc:	6990                	ld	a2,16(a1)
    list_add(&(buddy_array[n-1]), &(page_a->page_link));
ffffffffc0200cfe:	0721                	addi	a4,a4,8
    prev->next = next->prev = elm;
ffffffffc0200d00:	e99c                	sd	a5,16(a1)
ffffffffc0200d02:	9772                	add	a4,a4,t3
    elm->prev = prev;
ffffffffc0200d04:	e398                	sd	a4,0(a5)
    list_add(&(page_a->page_link), &(page_b->page_link));
ffffffffc0200d06:	01868713          	addi	a4,a3,24
    prev->next = next->prev = elm;
ffffffffc0200d0a:	e218                	sd	a4,0(a2)
ffffffffc0200d0c:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0200d0e:	f290                	sd	a2,32(a3)
    return list->next == list;
ffffffffc0200d10:	01083703          	ld	a4,16(a6)
    elm->prev = prev;
ffffffffc0200d14:	ee9c                	sd	a5,24(a3)
    if (!list_empty(&(buddy_array[order]))) {
ffffffffc0200d16:	f49706e3          	beq	a4,s1,ffffffffc0200c62 <buddy_alloc_pages+0x86>
ffffffffc0200d1a:	84ba                	mv	s1,a4
    __list_del(listelm->prev, listelm->next);
ffffffffc0200d1c:	6094                	ld	a3,0(s1)
ffffffffc0200d1e:	6498                	ld	a4,8(s1)
        page = le2page(list_next(&(buddy_array[order])), page_link);
ffffffffc0200d20:	fe848793          	addi	a5,s1,-24
    prev->next = next;
ffffffffc0200d24:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0200d26:	e314                	sd	a3,0(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200d28:	4709                	li	a4,2
ffffffffc0200d2a:	ff048693          	addi	a3,s1,-16
ffffffffc0200d2e:	40e6b02f          	amoor.d	zero,a4,(a3)
        goto done; 
ffffffffc0200d32:	158e2f03          	lw	t5,344(t3)
ffffffffc0200d36:	bfa9                	j	ffffffffc0200c90 <buddy_alloc_pages+0xb4>
    size_t res = 1;
ffffffffc0200d38:	4785                	li	a5,1
            n = n >> 1;
ffffffffc0200d3a:	8105                	srli	a0,a0,0x1
            res = res << 1;
ffffffffc0200d3c:	0786                	slli	a5,a5,0x1
        while (n) {
ffffffffc0200d3e:	fd75                	bnez	a0,ffffffffc0200d3a <buddy_alloc_pages+0x15e>
            res = res << 1;
ffffffffc0200d40:	853e                	mv	a0,a5
ffffffffc0200d42:	b5f9                	j	ffffffffc0200c10 <buddy_alloc_pages+0x34>
        return NULL;
ffffffffc0200d44:	4781                	li	a5,0
ffffffffc0200d46:	bf99                	j	ffffffffc0200c9c <buddy_alloc_pages+0xc0>
    while (n >> 1) {
ffffffffc0200d48:	4721                	li	a4,8
    unsigned int order = 0;
ffffffffc0200d4a:	4881                	li	a7,0
ffffffffc0200d4c:	4781                	li	a5,0
ffffffffc0200d4e:	bdf1                	j	ffffffffc0200c2a <buddy_alloc_pages+0x4e>
    assert(n > 0 && n <= max_order);
ffffffffc0200d50:	00001697          	auipc	a3,0x1
ffffffffc0200d54:	31868693          	addi	a3,a3,792 # ffffffffc0202068 <commands+0x630>
ffffffffc0200d58:	00001617          	auipc	a2,0x1
ffffffffc0200d5c:	53860613          	addi	a2,a2,1336 # ffffffffc0202290 <commands+0x858>
ffffffffc0200d60:	07500593          	li	a1,117
ffffffffc0200d64:	00001517          	auipc	a0,0x1
ffffffffc0200d68:	54450513          	addi	a0,a0,1348 # ffffffffc02022a8 <commands+0x870>
ffffffffc0200d6c:	e40ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&(buddy_array[n])));
ffffffffc0200d70:	00001697          	auipc	a3,0x1
ffffffffc0200d74:	31068693          	addi	a3,a3,784 # ffffffffc0202080 <commands+0x648>
ffffffffc0200d78:	00001617          	auipc	a2,0x1
ffffffffc0200d7c:	51860613          	addi	a2,a2,1304 # ffffffffc0202290 <commands+0x858>
ffffffffc0200d80:	07600593          	li	a1,118
ffffffffc0200d84:	00001517          	auipc	a0,0x1
ffffffffc0200d88:	52450513          	addi	a0,a0,1316 # ffffffffc02022a8 <commands+0x870>
ffffffffc0200d8c:	e20ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200d90:	00001697          	auipc	a3,0x1
ffffffffc0200d94:	4f868693          	addi	a3,a3,1272 # ffffffffc0202288 <commands+0x850>
ffffffffc0200d98:	00001617          	auipc	a2,0x1
ffffffffc0200d9c:	4f860613          	addi	a2,a2,1272 # ffffffffc0202290 <commands+0x858>
ffffffffc0200da0:	08900593          	li	a1,137
ffffffffc0200da4:	00001517          	auipc	a0,0x1
ffffffffc0200da8:	50450513          	addi	a0,a0,1284 # ffffffffc02022a8 <commands+0x870>
ffffffffc0200dac:	e00ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200db0 <buddy_check>:

static void
buddy_check(void) {
ffffffffc0200db0:	7179                	addi	sp,sp,-48
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200db2:	4505                	li	a0,1
buddy_check(void) {
ffffffffc0200db4:	f406                	sd	ra,40(sp)
ffffffffc0200db6:	f022                	sd	s0,32(sp)
ffffffffc0200db8:	ec26                	sd	s1,24(sp)
ffffffffc0200dba:	e84a                	sd	s2,16(sp)
ffffffffc0200dbc:	e44e                	sd	s3,8(sp)
ffffffffc0200dbe:	e052                	sd	s4,0(sp)
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200dc0:	2c6000ef          	jal	ra,ffffffffc0201086 <alloc_pages>
ffffffffc0200dc4:	12050163          	beqz	a0,ffffffffc0200ee6 <buddy_check+0x136>
ffffffffc0200dc8:	842a                	mv	s0,a0
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200dca:	4505                	li	a0,1
ffffffffc0200dcc:	2ba000ef          	jal	ra,ffffffffc0201086 <alloc_pages>
ffffffffc0200dd0:	892a                	mv	s2,a0
ffffffffc0200dd2:	28050a63          	beqz	a0,ffffffffc0201066 <buddy_check+0x2b6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200dd6:	4505                	li	a0,1
ffffffffc0200dd8:	2ae000ef          	jal	ra,ffffffffc0201086 <alloc_pages>
ffffffffc0200ddc:	84aa                	mv	s1,a0
ffffffffc0200dde:	26050463          	beqz	a0,ffffffffc0201046 <buddy_check+0x296>
    free_page(p0);
ffffffffc0200de2:	4585                	li	a1,1
ffffffffc0200de4:	8522                	mv	a0,s0
ffffffffc0200de6:	2e4000ef          	jal	ra,ffffffffc02010ca <free_pages>
    free_page(p1);
ffffffffc0200dea:	854a                	mv	a0,s2
ffffffffc0200dec:	4585                	li	a1,1
ffffffffc0200dee:	2dc000ef          	jal	ra,ffffffffc02010ca <free_pages>
    free_page(p2);
ffffffffc0200df2:	4585                	li	a1,1
ffffffffc0200df4:	8526                	mv	a0,s1
ffffffffc0200df6:	2d4000ef          	jal	ra,ffffffffc02010ca <free_pages>
    assert((p0 = alloc_pages(4)) != NULL);
ffffffffc0200dfa:	4511                	li	a0,4
ffffffffc0200dfc:	28a000ef          	jal	ra,ffffffffc0201086 <alloc_pages>
ffffffffc0200e00:	892a                	mv	s2,a0
ffffffffc0200e02:	22050263          	beqz	a0,ffffffffc0201026 <buddy_check+0x276>
    assert((p1 = alloc_pages(2)) != NULL);
ffffffffc0200e06:	4509                	li	a0,2
ffffffffc0200e08:	27e000ef          	jal	ra,ffffffffc0201086 <alloc_pages>
ffffffffc0200e0c:	84aa                	mv	s1,a0
ffffffffc0200e0e:	1e050c63          	beqz	a0,ffffffffc0201006 <buddy_check+0x256>
    assert((p2 = alloc_pages(1)) != NULL);
ffffffffc0200e12:	4505                	li	a0,1
ffffffffc0200e14:	272000ef          	jal	ra,ffffffffc0201086 <alloc_pages>
ffffffffc0200e18:	842a                	mv	s0,a0
ffffffffc0200e1a:	1c050663          	beqz	a0,ffffffffc0200fe6 <buddy_check+0x236>
    free_pages(p0, 4);
ffffffffc0200e1e:	4591                	li	a1,4
ffffffffc0200e20:	854a                	mv	a0,s2
ffffffffc0200e22:	2a8000ef          	jal	ra,ffffffffc02010ca <free_pages>
    free_pages(p1, 2);
ffffffffc0200e26:	8526                	mv	a0,s1
ffffffffc0200e28:	4589                	li	a1,2
ffffffffc0200e2a:	2a0000ef          	jal	ra,ffffffffc02010ca <free_pages>
    free_pages(p2, 1);
ffffffffc0200e2e:	4585                	li	a1,1
ffffffffc0200e30:	8522                	mv	a0,s0
ffffffffc0200e32:	298000ef          	jal	ra,ffffffffc02010ca <free_pages>
    assert((p0 = alloc_pages(3)) != NULL);
ffffffffc0200e36:	450d                	li	a0,3
ffffffffc0200e38:	24e000ef          	jal	ra,ffffffffc0201086 <alloc_pages>
ffffffffc0200e3c:	84aa                	mv	s1,a0
ffffffffc0200e3e:	18050463          	beqz	a0,ffffffffc0200fc6 <buddy_check+0x216>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200e42:	450d                	li	a0,3
ffffffffc0200e44:	242000ef          	jal	ra,ffffffffc0201086 <alloc_pages>
ffffffffc0200e48:	842a                	mv	s0,a0
ffffffffc0200e4a:	14050e63          	beqz	a0,ffffffffc0200fa6 <buddy_check+0x1f6>
    free_pages(p0, 3);
ffffffffc0200e4e:	458d                	li	a1,3
ffffffffc0200e50:	8526                	mv	a0,s1
ffffffffc0200e52:	278000ef          	jal	ra,ffffffffc02010ca <free_pages>
    free_pages(p1, 3);
ffffffffc0200e56:	8522                	mv	a0,s0
ffffffffc0200e58:	458d                	li	a1,3
ffffffffc0200e5a:	270000ef          	jal	ra,ffffffffc02010ca <free_pages>
    basic_check();
    show_buddy_array();
ffffffffc0200e5e:	b6fff0ef          	jal	ra,ffffffffc02009cc <show_buddy_array>

    struct Page *p0, *p1, *p2 ,*p3, *p4,*p5;
    p0=p1=p2=NULL;
    assert((p0 = buddy_alloc_pages(12)) != NULL);
ffffffffc0200e62:	4531                	li	a0,12
ffffffffc0200e64:	d79ff0ef          	jal	ra,ffffffffc0200bdc <buddy_alloc_pages>
ffffffffc0200e68:	842a                	mv	s0,a0
ffffffffc0200e6a:	10050e63          	beqz	a0,ffffffffc0200f86 <buddy_check+0x1d6>
    show_buddy_array();
ffffffffc0200e6e:	b5fff0ef          	jal	ra,ffffffffc02009cc <show_buddy_array>
    assert((p1 = buddy_alloc_pages(2)) != NULL);
ffffffffc0200e72:	4509                	li	a0,2
ffffffffc0200e74:	d69ff0ef          	jal	ra,ffffffffc0200bdc <buddy_alloc_pages>
ffffffffc0200e78:	84aa                	mv	s1,a0
ffffffffc0200e7a:	0e050663          	beqz	a0,ffffffffc0200f66 <buddy_check+0x1b6>
    show_buddy_array();
ffffffffc0200e7e:	b4fff0ef          	jal	ra,ffffffffc02009cc <show_buddy_array>
    assert((p2 = buddy_alloc_pages(1)) != NULL);
ffffffffc0200e82:	4505                	li	a0,1
ffffffffc0200e84:	d59ff0ef          	jal	ra,ffffffffc0200bdc <buddy_alloc_pages>
ffffffffc0200e88:	892a                	mv	s2,a0
ffffffffc0200e8a:	cd55                	beqz	a0,ffffffffc0200f46 <buddy_check+0x196>
    show_buddy_array();
ffffffffc0200e8c:	b41ff0ef          	jal	ra,ffffffffc02009cc <show_buddy_array>
    assert((p3 = buddy_alloc_pages(1)) != NULL);
ffffffffc0200e90:	4505                	li	a0,1
ffffffffc0200e92:	d4bff0ef          	jal	ra,ffffffffc0200bdc <buddy_alloc_pages>
ffffffffc0200e96:	8a2a                	mv	s4,a0
ffffffffc0200e98:	c559                	beqz	a0,ffffffffc0200f26 <buddy_check+0x176>
    show_buddy_array();
ffffffffc0200e9a:	b33ff0ef          	jal	ra,ffffffffc02009cc <show_buddy_array>
    assert((p4 = buddy_alloc_pages(1)) != NULL);
ffffffffc0200e9e:	4505                	li	a0,1
ffffffffc0200ea0:	d3dff0ef          	jal	ra,ffffffffc0200bdc <buddy_alloc_pages>
ffffffffc0200ea4:	89aa                	mv	s3,a0
ffffffffc0200ea6:	c125                	beqz	a0,ffffffffc0200f06 <buddy_check+0x156>

    show_buddy_array();
ffffffffc0200ea8:	b25ff0ef          	jal	ra,ffffffffc02009cc <show_buddy_array>

    buddy_free_pages(p2, 1);
ffffffffc0200eac:	854a                	mv	a0,s2
ffffffffc0200eae:	4585                	li	a1,1
ffffffffc0200eb0:	bc9ff0ef          	jal	ra,ffffffffc0200a78 <buddy_free_pages>
    buddy_free_pages(p3, 1);
ffffffffc0200eb4:	8552                	mv	a0,s4
ffffffffc0200eb6:	4585                	li	a1,1
ffffffffc0200eb8:	bc1ff0ef          	jal	ra,ffffffffc0200a78 <buddy_free_pages>
    show_buddy_array();
ffffffffc0200ebc:	b11ff0ef          	jal	ra,ffffffffc02009cc <show_buddy_array>
    buddy_free_pages(p1, 2);
ffffffffc0200ec0:	8526                	mv	a0,s1
ffffffffc0200ec2:	4589                	li	a1,2
ffffffffc0200ec4:	bb5ff0ef          	jal	ra,ffffffffc0200a78 <buddy_free_pages>
    buddy_free_pages(p4, 1);
ffffffffc0200ec8:	854e                	mv	a0,s3
ffffffffc0200eca:	4585                	li	a1,1
ffffffffc0200ecc:	badff0ef          	jal	ra,ffffffffc0200a78 <buddy_free_pages>
    buddy_free_pages(p0, 12);
ffffffffc0200ed0:	8522                	mv	a0,s0

}   
ffffffffc0200ed2:	7402                	ld	s0,32(sp)
ffffffffc0200ed4:	70a2                	ld	ra,40(sp)
ffffffffc0200ed6:	64e2                	ld	s1,24(sp)
ffffffffc0200ed8:	6942                	ld	s2,16(sp)
ffffffffc0200eda:	69a2                	ld	s3,8(sp)
ffffffffc0200edc:	6a02                	ld	s4,0(sp)
    buddy_free_pages(p0, 12);
ffffffffc0200ede:	45b1                	li	a1,12
}   
ffffffffc0200ee0:	6145                	addi	sp,sp,48
    buddy_free_pages(p0, 12);
ffffffffc0200ee2:	b97ff06f          	j	ffffffffc0200a78 <buddy_free_pages>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ee6:	00001697          	auipc	a3,0x1
ffffffffc0200eea:	1ba68693          	addi	a3,a3,442 # ffffffffc02020a0 <commands+0x668>
ffffffffc0200eee:	00001617          	auipc	a2,0x1
ffffffffc0200ef2:	3a260613          	addi	a2,a2,930 # ffffffffc0202290 <commands+0x858>
ffffffffc0200ef6:	0d600593          	li	a1,214
ffffffffc0200efa:	00001517          	auipc	a0,0x1
ffffffffc0200efe:	3ae50513          	addi	a0,a0,942 # ffffffffc02022a8 <commands+0x870>
ffffffffc0200f02:	caaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p4 = buddy_alloc_pages(1)) != NULL);
ffffffffc0200f06:	00001697          	auipc	a3,0x1
ffffffffc0200f0a:	33a68693          	addi	a3,a3,826 # ffffffffc0202240 <commands+0x808>
ffffffffc0200f0e:	00001617          	auipc	a2,0x1
ffffffffc0200f12:	38260613          	addi	a2,a2,898 # ffffffffc0202290 <commands+0x858>
ffffffffc0200f16:	10a00593          	li	a1,266
ffffffffc0200f1a:	00001517          	auipc	a0,0x1
ffffffffc0200f1e:	38e50513          	addi	a0,a0,910 # ffffffffc02022a8 <commands+0x870>
ffffffffc0200f22:	c8aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p3 = buddy_alloc_pages(1)) != NULL);
ffffffffc0200f26:	00001697          	auipc	a3,0x1
ffffffffc0200f2a:	2f268693          	addi	a3,a3,754 # ffffffffc0202218 <commands+0x7e0>
ffffffffc0200f2e:	00001617          	auipc	a2,0x1
ffffffffc0200f32:	36260613          	addi	a2,a2,866 # ffffffffc0202290 <commands+0x858>
ffffffffc0200f36:	10800593          	li	a1,264
ffffffffc0200f3a:	00001517          	auipc	a0,0x1
ffffffffc0200f3e:	36e50513          	addi	a0,a0,878 # ffffffffc02022a8 <commands+0x870>
ffffffffc0200f42:	c6aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = buddy_alloc_pages(1)) != NULL);
ffffffffc0200f46:	00001697          	auipc	a3,0x1
ffffffffc0200f4a:	2aa68693          	addi	a3,a3,682 # ffffffffc02021f0 <commands+0x7b8>
ffffffffc0200f4e:	00001617          	auipc	a2,0x1
ffffffffc0200f52:	34260613          	addi	a2,a2,834 # ffffffffc0202290 <commands+0x858>
ffffffffc0200f56:	10600593          	li	a1,262
ffffffffc0200f5a:	00001517          	auipc	a0,0x1
ffffffffc0200f5e:	34e50513          	addi	a0,a0,846 # ffffffffc02022a8 <commands+0x870>
ffffffffc0200f62:	c4aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = buddy_alloc_pages(2)) != NULL);
ffffffffc0200f66:	00001697          	auipc	a3,0x1
ffffffffc0200f6a:	26268693          	addi	a3,a3,610 # ffffffffc02021c8 <commands+0x790>
ffffffffc0200f6e:	00001617          	auipc	a2,0x1
ffffffffc0200f72:	32260613          	addi	a2,a2,802 # ffffffffc0202290 <commands+0x858>
ffffffffc0200f76:	10400593          	li	a1,260
ffffffffc0200f7a:	00001517          	auipc	a0,0x1
ffffffffc0200f7e:	32e50513          	addi	a0,a0,814 # ffffffffc02022a8 <commands+0x870>
ffffffffc0200f82:	c2aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = buddy_alloc_pages(12)) != NULL);
ffffffffc0200f86:	00001697          	auipc	a3,0x1
ffffffffc0200f8a:	21a68693          	addi	a3,a3,538 # ffffffffc02021a0 <commands+0x768>
ffffffffc0200f8e:	00001617          	auipc	a2,0x1
ffffffffc0200f92:	30260613          	addi	a2,a2,770 # ffffffffc0202290 <commands+0x858>
ffffffffc0200f96:	10200593          	li	a1,258
ffffffffc0200f9a:	00001517          	auipc	a0,0x1
ffffffffc0200f9e:	30e50513          	addi	a0,a0,782 # ffffffffc02022a8 <commands+0x870>
ffffffffc0200fa2:	c0aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200fa6:	00001697          	auipc	a3,0x1
ffffffffc0200faa:	1da68693          	addi	a3,a3,474 # ffffffffc0202180 <commands+0x748>
ffffffffc0200fae:	00001617          	auipc	a2,0x1
ffffffffc0200fb2:	2e260613          	addi	a2,a2,738 # ffffffffc0202290 <commands+0x858>
ffffffffc0200fb6:	0e500593          	li	a1,229
ffffffffc0200fba:	00001517          	auipc	a0,0x1
ffffffffc0200fbe:	2ee50513          	addi	a0,a0,750 # ffffffffc02022a8 <commands+0x870>
ffffffffc0200fc2:	beaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(3)) != NULL);
ffffffffc0200fc6:	00001697          	auipc	a3,0x1
ffffffffc0200fca:	19a68693          	addi	a3,a3,410 # ffffffffc0202160 <commands+0x728>
ffffffffc0200fce:	00001617          	auipc	a2,0x1
ffffffffc0200fd2:	2c260613          	addi	a2,a2,706 # ffffffffc0202290 <commands+0x858>
ffffffffc0200fd6:	0e400593          	li	a1,228
ffffffffc0200fda:	00001517          	auipc	a0,0x1
ffffffffc0200fde:	2ce50513          	addi	a0,a0,718 # ffffffffc02022a8 <commands+0x870>
ffffffffc0200fe2:	bcaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_pages(1)) != NULL);
ffffffffc0200fe6:	00001697          	auipc	a3,0x1
ffffffffc0200fea:	15a68693          	addi	a3,a3,346 # ffffffffc0202140 <commands+0x708>
ffffffffc0200fee:	00001617          	auipc	a2,0x1
ffffffffc0200ff2:	2a260613          	addi	a2,a2,674 # ffffffffc0202290 <commands+0x858>
ffffffffc0200ff6:	0df00593          	li	a1,223
ffffffffc0200ffa:	00001517          	auipc	a0,0x1
ffffffffc0200ffe:	2ae50513          	addi	a0,a0,686 # ffffffffc02022a8 <commands+0x870>
ffffffffc0201002:	baaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(2)) != NULL);
ffffffffc0201006:	00001697          	auipc	a3,0x1
ffffffffc020100a:	11a68693          	addi	a3,a3,282 # ffffffffc0202120 <commands+0x6e8>
ffffffffc020100e:	00001617          	auipc	a2,0x1
ffffffffc0201012:	28260613          	addi	a2,a2,642 # ffffffffc0202290 <commands+0x858>
ffffffffc0201016:	0de00593          	li	a1,222
ffffffffc020101a:	00001517          	auipc	a0,0x1
ffffffffc020101e:	28e50513          	addi	a0,a0,654 # ffffffffc02022a8 <commands+0x870>
ffffffffc0201022:	b8aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(4)) != NULL);
ffffffffc0201026:	00001697          	auipc	a3,0x1
ffffffffc020102a:	0da68693          	addi	a3,a3,218 # ffffffffc0202100 <commands+0x6c8>
ffffffffc020102e:	00001617          	auipc	a2,0x1
ffffffffc0201032:	26260613          	addi	a2,a2,610 # ffffffffc0202290 <commands+0x858>
ffffffffc0201036:	0dd00593          	li	a1,221
ffffffffc020103a:	00001517          	auipc	a0,0x1
ffffffffc020103e:	26e50513          	addi	a0,a0,622 # ffffffffc02022a8 <commands+0x870>
ffffffffc0201042:	b6aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201046:	00001697          	auipc	a3,0x1
ffffffffc020104a:	09a68693          	addi	a3,a3,154 # ffffffffc02020e0 <commands+0x6a8>
ffffffffc020104e:	00001617          	auipc	a2,0x1
ffffffffc0201052:	24260613          	addi	a2,a2,578 # ffffffffc0202290 <commands+0x858>
ffffffffc0201056:	0d800593          	li	a1,216
ffffffffc020105a:	00001517          	auipc	a0,0x1
ffffffffc020105e:	24e50513          	addi	a0,a0,590 # ffffffffc02022a8 <commands+0x870>
ffffffffc0201062:	b4aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201066:	00001697          	auipc	a3,0x1
ffffffffc020106a:	05a68693          	addi	a3,a3,90 # ffffffffc02020c0 <commands+0x688>
ffffffffc020106e:	00001617          	auipc	a2,0x1
ffffffffc0201072:	22260613          	addi	a2,a2,546 # ffffffffc0202290 <commands+0x858>
ffffffffc0201076:	0d700593          	li	a1,215
ffffffffc020107a:	00001517          	auipc	a0,0x1
ffffffffc020107e:	22e50513          	addi	a0,a0,558 # ffffffffc02022a8 <commands+0x870>
ffffffffc0201082:	b2aff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201086 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201086:	100027f3          	csrr	a5,sstatus
ffffffffc020108a:	8b89                	andi	a5,a5,2
ffffffffc020108c:	eb89                	bnez	a5,ffffffffc020109e <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc020108e:	00005797          	auipc	a5,0x5
ffffffffc0201092:	52278793          	addi	a5,a5,1314 # ffffffffc02065b0 <pmm_manager>
ffffffffc0201096:	639c                	ld	a5,0(a5)
ffffffffc0201098:	0187b303          	ld	t1,24(a5)
ffffffffc020109c:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc020109e:	1141                	addi	sp,sp,-16
ffffffffc02010a0:	e406                	sd	ra,8(sp)
ffffffffc02010a2:	e022                	sd	s0,0(sp)
ffffffffc02010a4:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02010a6:	bbeff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02010aa:	00005797          	auipc	a5,0x5
ffffffffc02010ae:	50678793          	addi	a5,a5,1286 # ffffffffc02065b0 <pmm_manager>
ffffffffc02010b2:	639c                	ld	a5,0(a5)
ffffffffc02010b4:	8522                	mv	a0,s0
ffffffffc02010b6:	6f9c                	ld	a5,24(a5)
ffffffffc02010b8:	9782                	jalr	a5
ffffffffc02010ba:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc02010bc:	ba2ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc02010c0:	8522                	mv	a0,s0
ffffffffc02010c2:	60a2                	ld	ra,8(sp)
ffffffffc02010c4:	6402                	ld	s0,0(sp)
ffffffffc02010c6:	0141                	addi	sp,sp,16
ffffffffc02010c8:	8082                	ret

ffffffffc02010ca <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02010ca:	100027f3          	csrr	a5,sstatus
ffffffffc02010ce:	8b89                	andi	a5,a5,2
ffffffffc02010d0:	eb89                	bnez	a5,ffffffffc02010e2 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02010d2:	00005797          	auipc	a5,0x5
ffffffffc02010d6:	4de78793          	addi	a5,a5,1246 # ffffffffc02065b0 <pmm_manager>
ffffffffc02010da:	639c                	ld	a5,0(a5)
ffffffffc02010dc:	0207b303          	ld	t1,32(a5)
ffffffffc02010e0:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc02010e2:	1101                	addi	sp,sp,-32
ffffffffc02010e4:	ec06                	sd	ra,24(sp)
ffffffffc02010e6:	e822                	sd	s0,16(sp)
ffffffffc02010e8:	e426                	sd	s1,8(sp)
ffffffffc02010ea:	842a                	mv	s0,a0
ffffffffc02010ec:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02010ee:	b76ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02010f2:	00005797          	auipc	a5,0x5
ffffffffc02010f6:	4be78793          	addi	a5,a5,1214 # ffffffffc02065b0 <pmm_manager>
ffffffffc02010fa:	639c                	ld	a5,0(a5)
ffffffffc02010fc:	85a6                	mv	a1,s1
ffffffffc02010fe:	8522                	mv	a0,s0
ffffffffc0201100:	739c                	ld	a5,32(a5)
ffffffffc0201102:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201104:	6442                	ld	s0,16(sp)
ffffffffc0201106:	60e2                	ld	ra,24(sp)
ffffffffc0201108:	64a2                	ld	s1,8(sp)
ffffffffc020110a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020110c:	b52ff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc0201110 <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc0201110:	00001797          	auipc	a5,0x1
ffffffffc0201114:	1c078793          	addi	a5,a5,448 # ffffffffc02022d0 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201118:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc020111a:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020111c:	00001517          	auipc	a0,0x1
ffffffffc0201120:	25c50513          	addi	a0,a0,604 # ffffffffc0202378 <buddy_pmm_manager+0xa8>
void pmm_init(void) {
ffffffffc0201124:	e486                	sd	ra,72(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0201126:	00005717          	auipc	a4,0x5
ffffffffc020112a:	48f73523          	sd	a5,1162(a4) # ffffffffc02065b0 <pmm_manager>
void pmm_init(void) {
ffffffffc020112e:	f84a                	sd	s2,48(sp)
ffffffffc0201130:	e45e                	sd	s7,8(sp)
ffffffffc0201132:	e0a2                	sd	s0,64(sp)
ffffffffc0201134:	fc26                	sd	s1,56(sp)
ffffffffc0201136:	f44e                	sd	s3,40(sp)
ffffffffc0201138:	f052                	sd	s4,32(sp)
ffffffffc020113a:	ec56                	sd	s5,24(sp)
ffffffffc020113c:	e85a                	sd	s6,16(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc020113e:	00005917          	auipc	s2,0x5
ffffffffc0201142:	47290913          	addi	s2,s2,1138 # ffffffffc02065b0 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201146:	f71fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc020114a:	00093783          	ld	a5,0(s2)
    npage = maxpa / PGSIZE;
ffffffffc020114e:	00005b97          	auipc	s7,0x5
ffffffffc0201152:	2dab8b93          	addi	s7,s7,730 # ffffffffc0206428 <npage>
    pmm_manager->init();
ffffffffc0201156:	679c                	ld	a5,8(a5)
ffffffffc0201158:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020115a:	57f5                	li	a5,-3
ffffffffc020115c:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020115e:	00001517          	auipc	a0,0x1
ffffffffc0201162:	23250513          	addi	a0,a0,562 # ffffffffc0202390 <buddy_pmm_manager+0xc0>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201166:	00005717          	auipc	a4,0x5
ffffffffc020116a:	44f73923          	sd	a5,1106(a4) # ffffffffc02065b8 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc020116e:	f49fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0201172:	46c5                	li	a3,17
ffffffffc0201174:	06ee                	slli	a3,a3,0x1b
ffffffffc0201176:	40100613          	li	a2,1025
ffffffffc020117a:	16fd                	addi	a3,a3,-1
ffffffffc020117c:	0656                	slli	a2,a2,0x15
ffffffffc020117e:	07e005b7          	lui	a1,0x7e00
ffffffffc0201182:	00001517          	auipc	a0,0x1
ffffffffc0201186:	22650513          	addi	a0,a0,550 # ffffffffc02023a8 <buddy_pmm_manager+0xd8>
ffffffffc020118a:	f2dfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("the end of kernel: %p\n", end);
ffffffffc020118e:	00005597          	auipc	a1,0x5
ffffffffc0201192:	43a58593          	addi	a1,a1,1082 # ffffffffc02065c8 <end>
ffffffffc0201196:	00001517          	auipc	a0,0x1
ffffffffc020119a:	24250513          	addi	a0,a0,578 # ffffffffc02023d8 <buddy_pmm_manager+0x108>
ffffffffc020119e:	f19fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02011a2:	777d                	lui	a4,0xfffff
ffffffffc02011a4:	00006797          	auipc	a5,0x6
ffffffffc02011a8:	42378793          	addi	a5,a5,1059 # ffffffffc02075c7 <end+0xfff>
ffffffffc02011ac:	8ff9                	and	a5,a5,a4
    cprintf("pages begin addr: %p\n", pages);
ffffffffc02011ae:	85be                	mv	a1,a5
    npage = maxpa / PGSIZE;
ffffffffc02011b0:	00088737          	lui	a4,0x88
    cprintf("pages begin addr: %p\n", pages);
ffffffffc02011b4:	00001517          	auipc	a0,0x1
ffffffffc02011b8:	23c50513          	addi	a0,a0,572 # ffffffffc02023f0 <buddy_pmm_manager+0x120>
    npage = maxpa / PGSIZE;
ffffffffc02011bc:	00005697          	auipc	a3,0x5
ffffffffc02011c0:	26e6b623          	sd	a4,620(a3) # ffffffffc0206428 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02011c4:	00005717          	auipc	a4,0x5
ffffffffc02011c8:	3ef73e23          	sd	a5,1020(a4) # ffffffffc02065c0 <pages>
    cprintf("pages begin addr: %p\n", pages);
ffffffffc02011cc:	eebfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02011d0:	000bb703          	ld	a4,0(s7)
ffffffffc02011d4:	000807b7          	lui	a5,0x80
ffffffffc02011d8:	12f70f63          	beq	a4,a5,ffffffffc0201316 <pmm_init+0x206>
ffffffffc02011dc:	4601                	li	a2,0
ffffffffc02011de:	4701                	li	a4,0
ffffffffc02011e0:	00005b17          	auipc	s6,0x5
ffffffffc02011e4:	3e0b0b13          	addi	s6,s6,992 # ffffffffc02065c0 <pages>
ffffffffc02011e8:	4505                	li	a0,1
ffffffffc02011ea:	fff805b7          	lui	a1,0xfff80
        SetPageReserved(pages + i);
ffffffffc02011ee:	000b3783          	ld	a5,0(s6)
ffffffffc02011f2:	97b2                	add	a5,a5,a2
ffffffffc02011f4:	07a1                	addi	a5,a5,8
ffffffffc02011f6:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02011fa:	000bb783          	ld	a5,0(s7)
ffffffffc02011fe:	0705                	addi	a4,a4,1
ffffffffc0201200:	02860613          	addi	a2,a2,40
ffffffffc0201204:	00b786b3          	add	a3,a5,a1
ffffffffc0201208:	fed763e3          	bltu	a4,a3,ffffffffc02011ee <pmm_init+0xde>
ffffffffc020120c:	00279693          	slli	a3,a5,0x2
ffffffffc0201210:	96be                	add	a3,a3,a5
ffffffffc0201212:	00369793          	slli	a5,a3,0x3
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201216:	000b3683          	ld	a3,0(s6)
ffffffffc020121a:	fec00637          	lui	a2,0xfec00
ffffffffc020121e:	c0200737          	lui	a4,0xc0200
ffffffffc0201222:	96b2                	add	a3,a3,a2
ffffffffc0201224:	96be                	add	a3,a3,a5
ffffffffc0201226:	0ee6ef63          	bltu	a3,a4,ffffffffc0201324 <pmm_init+0x214>
ffffffffc020122a:	00005997          	auipc	s3,0x5
ffffffffc020122e:	38e98993          	addi	s3,s3,910 # ffffffffc02065b8 <va_pa_offset>
ffffffffc0201232:	0009b483          	ld	s1,0(s3)
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201236:	6405                	lui	s0,0x1
ffffffffc0201238:	147d                	addi	s0,s0,-1
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020123a:	409684b3          	sub	s1,a3,s1
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020123e:	9426                	add	s0,s0,s1
ffffffffc0201240:	7a7d                	lui	s4,0xfffff
ffffffffc0201242:	01447ab3          	and	s5,s0,s4
    cprintf("mem begin addr: %p\n", mem_begin);
ffffffffc0201246:	85d6                	mv	a1,s5
ffffffffc0201248:	00001517          	auipc	a0,0x1
ffffffffc020124c:	1f850513          	addi	a0,a0,504 # ffffffffc0202440 <buddy_pmm_manager+0x170>
ffffffffc0201250:	e67fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("mem end addr: %p\n", mem_end);
ffffffffc0201254:	4a45                	li	s4,17
ffffffffc0201256:	01ba1593          	slli	a1,s4,0x1b
ffffffffc020125a:	00001517          	auipc	a0,0x1
ffffffffc020125e:	1fe50513          	addi	a0,a0,510 # ffffffffc0202458 <buddy_pmm_manager+0x188>
ffffffffc0201262:	e55fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0201266:	000bb783          	ld	a5,0(s7)
ffffffffc020126a:	8031                	srli	s0,s0,0xc
ffffffffc020126c:	0ef47463          	bleu	a5,s0,ffffffffc0201354 <pmm_init+0x244>
        panic("pa2page called with invalid pa");
    }
    //pages为开始存储Page结构体的数组的起始位置
    //返回在page结构体中的偏移量(第几个page)
    return &pages[PPN(pa) - nbase];
ffffffffc0201270:	fff80537          	lui	a0,0xfff80
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201274:	00001797          	auipc	a5,0x1
ffffffffc0201278:	00c78793          	addi	a5,a5,12 # ffffffffc0202280 <commands+0x848>
    return &pages[PPN(pa) - nbase];
ffffffffc020127c:	942a                	add	s0,s0,a0
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020127e:	639c                	ld	a5,0(a5)
    return &pages[PPN(pa) - nbase];
ffffffffc0201280:	00241513          	slli	a0,s0,0x2
ffffffffc0201284:	942a                	add	s0,s0,a0
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201286:	02f407b3          	mul	a5,s0,a5
ffffffffc020128a:	000806b7          	lui	a3,0x80
    if (freemem < mem_end) {
ffffffffc020128e:	0a6e                	slli	s4,s4,0x1b
    return &pages[PPN(pa) - nbase];
ffffffffc0201290:	000b3503          	ld	a0,0(s6)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201294:	040e                	slli	s0,s0,0x3
ffffffffc0201296:	00093703          	ld	a4,0(s2)
ffffffffc020129a:	97b6                	add	a5,a5,a3
    first_ppn = page2ppn(pa2page(mem_begin));
ffffffffc020129c:	00005697          	auipc	a3,0x5
ffffffffc02012a0:	18f6b223          	sd	a5,388(a3) # ffffffffc0206420 <first_ppn>
    if (freemem < mem_end) {
ffffffffc02012a4:	0544ef63          	bltu	s1,s4,ffffffffc0201302 <pmm_init+0x1f2>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02012a8:	7b1c                	ld	a5,48(a4)
ffffffffc02012aa:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02012ac:	00001517          	auipc	a0,0x1
ffffffffc02012b0:	1f450513          	addi	a0,a0,500 # ffffffffc02024a0 <buddy_pmm_manager+0x1d0>
ffffffffc02012b4:	e03fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02012b8:	00004697          	auipc	a3,0x4
ffffffffc02012bc:	d4868693          	addi	a3,a3,-696 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02012c0:	00005797          	auipc	a5,0x5
ffffffffc02012c4:	16d7b823          	sd	a3,368(a5) # ffffffffc0206430 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02012c8:	c02007b7          	lui	a5,0xc0200
ffffffffc02012cc:	06f6e863          	bltu	a3,a5,ffffffffc020133c <pmm_init+0x22c>
ffffffffc02012d0:	0009b783          	ld	a5,0(s3)
}
ffffffffc02012d4:	6406                	ld	s0,64(sp)
ffffffffc02012d6:	60a6                	ld	ra,72(sp)
ffffffffc02012d8:	74e2                	ld	s1,56(sp)
ffffffffc02012da:	7942                	ld	s2,48(sp)
ffffffffc02012dc:	79a2                	ld	s3,40(sp)
ffffffffc02012de:	7a02                	ld	s4,32(sp)
ffffffffc02012e0:	6ae2                	ld	s5,24(sp)
ffffffffc02012e2:	6b42                	ld	s6,16(sp)
ffffffffc02012e4:	6ba2                	ld	s7,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02012e6:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc02012e8:	8e9d                	sub	a3,a3,a5
ffffffffc02012ea:	00005797          	auipc	a5,0x5
ffffffffc02012ee:	2ad7bf23          	sd	a3,702(a5) # ffffffffc02065a8 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02012f2:	00001517          	auipc	a0,0x1
ffffffffc02012f6:	1ce50513          	addi	a0,a0,462 # ffffffffc02024c0 <buddy_pmm_manager+0x1f0>
ffffffffc02012fa:	8636                	mv	a2,a3
}
ffffffffc02012fc:	6161                	addi	sp,sp,80
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02012fe:	db9fe06f          	j	ffffffffc02000b6 <cprintf>
    pmm_manager->init_memmap(base, n);
ffffffffc0201302:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201304:	415a0a33          	sub	s4,s4,s5
    pmm_manager->init_memmap(base, n);
ffffffffc0201308:	00ca5593          	srli	a1,s4,0xc
ffffffffc020130c:	9522                	add	a0,a0,s0
ffffffffc020130e:	9782                	jalr	a5
ffffffffc0201310:	00093703          	ld	a4,0(s2)
ffffffffc0201314:	bf51                	j	ffffffffc02012a8 <pmm_init+0x198>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201316:	014007b7          	lui	a5,0x1400
ffffffffc020131a:	00005b17          	auipc	s6,0x5
ffffffffc020131e:	2a6b0b13          	addi	s6,s6,678 # ffffffffc02065c0 <pages>
ffffffffc0201322:	bdd5                	j	ffffffffc0201216 <pmm_init+0x106>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201324:	00001617          	auipc	a2,0x1
ffffffffc0201328:	0e460613          	addi	a2,a2,228 # ffffffffc0202408 <buddy_pmm_manager+0x138>
ffffffffc020132c:	07300593          	li	a1,115
ffffffffc0201330:	00001517          	auipc	a0,0x1
ffffffffc0201334:	10050513          	addi	a0,a0,256 # ffffffffc0202430 <buddy_pmm_manager+0x160>
ffffffffc0201338:	874ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020133c:	00001617          	auipc	a2,0x1
ffffffffc0201340:	0cc60613          	addi	a2,a2,204 # ffffffffc0202408 <buddy_pmm_manager+0x138>
ffffffffc0201344:	09100593          	li	a1,145
ffffffffc0201348:	00001517          	auipc	a0,0x1
ffffffffc020134c:	0e850513          	addi	a0,a0,232 # ffffffffc0202430 <buddy_pmm_manager+0x160>
ffffffffc0201350:	85cff0ef          	jal	ra,ffffffffc02003ac <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201354:	00001617          	auipc	a2,0x1
ffffffffc0201358:	11c60613          	addi	a2,a2,284 # ffffffffc0202470 <buddy_pmm_manager+0x1a0>
ffffffffc020135c:	06b00593          	li	a1,107
ffffffffc0201360:	00001517          	auipc	a0,0x1
ffffffffc0201364:	13050513          	addi	a0,a0,304 # ffffffffc0202490 <buddy_pmm_manager+0x1c0>
ffffffffc0201368:	844ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020136c <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020136c:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201370:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201372:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201376:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201378:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020137c:	f022                	sd	s0,32(sp)
ffffffffc020137e:	ec26                	sd	s1,24(sp)
ffffffffc0201380:	e84a                	sd	s2,16(sp)
ffffffffc0201382:	f406                	sd	ra,40(sp)
ffffffffc0201384:	e44e                	sd	s3,8(sp)
ffffffffc0201386:	84aa                	mv	s1,a0
ffffffffc0201388:	892e                	mv	s2,a1
ffffffffc020138a:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020138e:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0201390:	03067e63          	bleu	a6,a2,ffffffffc02013cc <printnum+0x60>
ffffffffc0201394:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201396:	00805763          	blez	s0,ffffffffc02013a4 <printnum+0x38>
ffffffffc020139a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020139c:	85ca                	mv	a1,s2
ffffffffc020139e:	854e                	mv	a0,s3
ffffffffc02013a0:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02013a2:	fc65                	bnez	s0,ffffffffc020139a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02013a4:	1a02                	slli	s4,s4,0x20
ffffffffc02013a6:	020a5a13          	srli	s4,s4,0x20
ffffffffc02013aa:	00001797          	auipc	a5,0x1
ffffffffc02013ae:	2e678793          	addi	a5,a5,742 # ffffffffc0202690 <error_string+0x38>
ffffffffc02013b2:	9a3e                	add	s4,s4,a5
}
ffffffffc02013b4:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02013b6:	000a4503          	lbu	a0,0(s4) # fffffffffffff000 <end+0x3fdf8a38>
}
ffffffffc02013ba:	70a2                	ld	ra,40(sp)
ffffffffc02013bc:	69a2                	ld	s3,8(sp)
ffffffffc02013be:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02013c0:	85ca                	mv	a1,s2
ffffffffc02013c2:	8326                	mv	t1,s1
}
ffffffffc02013c4:	6942                	ld	s2,16(sp)
ffffffffc02013c6:	64e2                	ld	s1,24(sp)
ffffffffc02013c8:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02013ca:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02013cc:	03065633          	divu	a2,a2,a6
ffffffffc02013d0:	8722                	mv	a4,s0
ffffffffc02013d2:	f9bff0ef          	jal	ra,ffffffffc020136c <printnum>
ffffffffc02013d6:	b7f9                	j	ffffffffc02013a4 <printnum+0x38>

ffffffffc02013d8 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02013d8:	7119                	addi	sp,sp,-128
ffffffffc02013da:	f4a6                	sd	s1,104(sp)
ffffffffc02013dc:	f0ca                	sd	s2,96(sp)
ffffffffc02013de:	e8d2                	sd	s4,80(sp)
ffffffffc02013e0:	e4d6                	sd	s5,72(sp)
ffffffffc02013e2:	e0da                	sd	s6,64(sp)
ffffffffc02013e4:	fc5e                	sd	s7,56(sp)
ffffffffc02013e6:	f862                	sd	s8,48(sp)
ffffffffc02013e8:	f06a                	sd	s10,32(sp)
ffffffffc02013ea:	fc86                	sd	ra,120(sp)
ffffffffc02013ec:	f8a2                	sd	s0,112(sp)
ffffffffc02013ee:	ecce                	sd	s3,88(sp)
ffffffffc02013f0:	f466                	sd	s9,40(sp)
ffffffffc02013f2:	ec6e                	sd	s11,24(sp)
ffffffffc02013f4:	892a                	mv	s2,a0
ffffffffc02013f6:	84ae                	mv	s1,a1
ffffffffc02013f8:	8d32                	mv	s10,a2
ffffffffc02013fa:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02013fc:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013fe:	00001a17          	auipc	s4,0x1
ffffffffc0201402:	102a0a13          	addi	s4,s4,258 # ffffffffc0202500 <buddy_pmm_manager+0x230>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201406:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020140a:	00001c17          	auipc	s8,0x1
ffffffffc020140e:	24ec0c13          	addi	s8,s8,590 # ffffffffc0202658 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201412:	000d4503          	lbu	a0,0(s10)
ffffffffc0201416:	02500793          	li	a5,37
ffffffffc020141a:	001d0413          	addi	s0,s10,1
ffffffffc020141e:	00f50e63          	beq	a0,a5,ffffffffc020143a <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0201422:	c521                	beqz	a0,ffffffffc020146a <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201424:	02500993          	li	s3,37
ffffffffc0201428:	a011                	j	ffffffffc020142c <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc020142a:	c121                	beqz	a0,ffffffffc020146a <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc020142c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020142e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201430:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201432:	fff44503          	lbu	a0,-1(s0) # fff <BASE_ADDRESS-0xffffffffc01ff001>
ffffffffc0201436:	ff351ae3          	bne	a0,s3,ffffffffc020142a <vprintfmt+0x52>
ffffffffc020143a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020143e:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201442:	4981                	li	s3,0
ffffffffc0201444:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0201446:	5cfd                	li	s9,-1
ffffffffc0201448:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020144a:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc020144e:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201450:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0201454:	0ff6f693          	andi	a3,a3,255
ffffffffc0201458:	00140d13          	addi	s10,s0,1
ffffffffc020145c:	20d5e563          	bltu	a1,a3,ffffffffc0201666 <vprintfmt+0x28e>
ffffffffc0201460:	068a                	slli	a3,a3,0x2
ffffffffc0201462:	96d2                	add	a3,a3,s4
ffffffffc0201464:	4294                	lw	a3,0(a3)
ffffffffc0201466:	96d2                	add	a3,a3,s4
ffffffffc0201468:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020146a:	70e6                	ld	ra,120(sp)
ffffffffc020146c:	7446                	ld	s0,112(sp)
ffffffffc020146e:	74a6                	ld	s1,104(sp)
ffffffffc0201470:	7906                	ld	s2,96(sp)
ffffffffc0201472:	69e6                	ld	s3,88(sp)
ffffffffc0201474:	6a46                	ld	s4,80(sp)
ffffffffc0201476:	6aa6                	ld	s5,72(sp)
ffffffffc0201478:	6b06                	ld	s6,64(sp)
ffffffffc020147a:	7be2                	ld	s7,56(sp)
ffffffffc020147c:	7c42                	ld	s8,48(sp)
ffffffffc020147e:	7ca2                	ld	s9,40(sp)
ffffffffc0201480:	7d02                	ld	s10,32(sp)
ffffffffc0201482:	6de2                	ld	s11,24(sp)
ffffffffc0201484:	6109                	addi	sp,sp,128
ffffffffc0201486:	8082                	ret
    if (lflag >= 2) {
ffffffffc0201488:	4705                	li	a4,1
ffffffffc020148a:	008a8593          	addi	a1,s5,8
ffffffffc020148e:	01074463          	blt	a4,a6,ffffffffc0201496 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0201492:	26080363          	beqz	a6,ffffffffc02016f8 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0201496:	000ab603          	ld	a2,0(s5)
ffffffffc020149a:	46c1                	li	a3,16
ffffffffc020149c:	8aae                	mv	s5,a1
ffffffffc020149e:	a06d                	j	ffffffffc0201548 <vprintfmt+0x170>
            goto reswitch;
ffffffffc02014a0:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02014a4:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014a6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02014a8:	b765                	j	ffffffffc0201450 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc02014aa:	000aa503          	lw	a0,0(s5)
ffffffffc02014ae:	85a6                	mv	a1,s1
ffffffffc02014b0:	0aa1                	addi	s5,s5,8
ffffffffc02014b2:	9902                	jalr	s2
            break;
ffffffffc02014b4:	bfb9                	j	ffffffffc0201412 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02014b6:	4705                	li	a4,1
ffffffffc02014b8:	008a8993          	addi	s3,s5,8
ffffffffc02014bc:	01074463          	blt	a4,a6,ffffffffc02014c4 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc02014c0:	22080463          	beqz	a6,ffffffffc02016e8 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc02014c4:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02014c8:	24044463          	bltz	s0,ffffffffc0201710 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02014cc:	8622                	mv	a2,s0
ffffffffc02014ce:	8ace                	mv	s5,s3
ffffffffc02014d0:	46a9                	li	a3,10
ffffffffc02014d2:	a89d                	j	ffffffffc0201548 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02014d4:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02014d8:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02014da:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02014dc:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02014e0:	8fb5                	xor	a5,a5,a3
ffffffffc02014e2:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02014e6:	1ad74363          	blt	a4,a3,ffffffffc020168c <vprintfmt+0x2b4>
ffffffffc02014ea:	00369793          	slli	a5,a3,0x3
ffffffffc02014ee:	97e2                	add	a5,a5,s8
ffffffffc02014f0:	639c                	ld	a5,0(a5)
ffffffffc02014f2:	18078d63          	beqz	a5,ffffffffc020168c <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc02014f6:	86be                	mv	a3,a5
ffffffffc02014f8:	00001617          	auipc	a2,0x1
ffffffffc02014fc:	24860613          	addi	a2,a2,584 # ffffffffc0202740 <error_string+0xe8>
ffffffffc0201500:	85a6                	mv	a1,s1
ffffffffc0201502:	854a                	mv	a0,s2
ffffffffc0201504:	240000ef          	jal	ra,ffffffffc0201744 <printfmt>
ffffffffc0201508:	b729                	j	ffffffffc0201412 <vprintfmt+0x3a>
            lflag ++;
ffffffffc020150a:	00144603          	lbu	a2,1(s0)
ffffffffc020150e:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201510:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201512:	bf3d                	j	ffffffffc0201450 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0201514:	4705                	li	a4,1
ffffffffc0201516:	008a8593          	addi	a1,s5,8
ffffffffc020151a:	01074463          	blt	a4,a6,ffffffffc0201522 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc020151e:	1e080263          	beqz	a6,ffffffffc0201702 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0201522:	000ab603          	ld	a2,0(s5)
ffffffffc0201526:	46a1                	li	a3,8
ffffffffc0201528:	8aae                	mv	s5,a1
ffffffffc020152a:	a839                	j	ffffffffc0201548 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc020152c:	03000513          	li	a0,48
ffffffffc0201530:	85a6                	mv	a1,s1
ffffffffc0201532:	e03e                	sd	a5,0(sp)
ffffffffc0201534:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201536:	85a6                	mv	a1,s1
ffffffffc0201538:	07800513          	li	a0,120
ffffffffc020153c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020153e:	0aa1                	addi	s5,s5,8
ffffffffc0201540:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0201544:	6782                	ld	a5,0(sp)
ffffffffc0201546:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201548:	876e                	mv	a4,s11
ffffffffc020154a:	85a6                	mv	a1,s1
ffffffffc020154c:	854a                	mv	a0,s2
ffffffffc020154e:	e1fff0ef          	jal	ra,ffffffffc020136c <printnum>
            break;
ffffffffc0201552:	b5c1                	j	ffffffffc0201412 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201554:	000ab603          	ld	a2,0(s5)
ffffffffc0201558:	0aa1                	addi	s5,s5,8
ffffffffc020155a:	1c060663          	beqz	a2,ffffffffc0201726 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc020155e:	00160413          	addi	s0,a2,1
ffffffffc0201562:	17b05c63          	blez	s11,ffffffffc02016da <vprintfmt+0x302>
ffffffffc0201566:	02d00593          	li	a1,45
ffffffffc020156a:	14b79263          	bne	a5,a1,ffffffffc02016ae <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020156e:	00064783          	lbu	a5,0(a2)
ffffffffc0201572:	0007851b          	sext.w	a0,a5
ffffffffc0201576:	c905                	beqz	a0,ffffffffc02015a6 <vprintfmt+0x1ce>
ffffffffc0201578:	000cc563          	bltz	s9,ffffffffc0201582 <vprintfmt+0x1aa>
ffffffffc020157c:	3cfd                	addiw	s9,s9,-1
ffffffffc020157e:	036c8263          	beq	s9,s6,ffffffffc02015a2 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0201582:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201584:	18098463          	beqz	s3,ffffffffc020170c <vprintfmt+0x334>
ffffffffc0201588:	3781                	addiw	a5,a5,-32
ffffffffc020158a:	18fbf163          	bleu	a5,s7,ffffffffc020170c <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc020158e:	03f00513          	li	a0,63
ffffffffc0201592:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201594:	0405                	addi	s0,s0,1
ffffffffc0201596:	fff44783          	lbu	a5,-1(s0)
ffffffffc020159a:	3dfd                	addiw	s11,s11,-1
ffffffffc020159c:	0007851b          	sext.w	a0,a5
ffffffffc02015a0:	fd61                	bnez	a0,ffffffffc0201578 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc02015a2:	e7b058e3          	blez	s11,ffffffffc0201412 <vprintfmt+0x3a>
ffffffffc02015a6:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02015a8:	85a6                	mv	a1,s1
ffffffffc02015aa:	02000513          	li	a0,32
ffffffffc02015ae:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02015b0:	e60d81e3          	beqz	s11,ffffffffc0201412 <vprintfmt+0x3a>
ffffffffc02015b4:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02015b6:	85a6                	mv	a1,s1
ffffffffc02015b8:	02000513          	li	a0,32
ffffffffc02015bc:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02015be:	fe0d94e3          	bnez	s11,ffffffffc02015a6 <vprintfmt+0x1ce>
ffffffffc02015c2:	bd81                	j	ffffffffc0201412 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02015c4:	4705                	li	a4,1
ffffffffc02015c6:	008a8593          	addi	a1,s5,8
ffffffffc02015ca:	01074463          	blt	a4,a6,ffffffffc02015d2 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02015ce:	12080063          	beqz	a6,ffffffffc02016ee <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02015d2:	000ab603          	ld	a2,0(s5)
ffffffffc02015d6:	46a9                	li	a3,10
ffffffffc02015d8:	8aae                	mv	s5,a1
ffffffffc02015da:	b7bd                	j	ffffffffc0201548 <vprintfmt+0x170>
ffffffffc02015dc:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02015e0:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015e4:	846a                	mv	s0,s10
ffffffffc02015e6:	b5ad                	j	ffffffffc0201450 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02015e8:	85a6                	mv	a1,s1
ffffffffc02015ea:	02500513          	li	a0,37
ffffffffc02015ee:	9902                	jalr	s2
            break;
ffffffffc02015f0:	b50d                	j	ffffffffc0201412 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02015f2:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02015f6:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02015fa:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015fc:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02015fe:	e40dd9e3          	bgez	s11,ffffffffc0201450 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0201602:	8de6                	mv	s11,s9
ffffffffc0201604:	5cfd                	li	s9,-1
ffffffffc0201606:	b5a9                	j	ffffffffc0201450 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0201608:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc020160c:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201610:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201612:	bd3d                	j	ffffffffc0201450 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0201614:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0201618:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020161c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020161e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201622:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201626:	fcd56ce3          	bltu	a0,a3,ffffffffc02015fe <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc020162a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020162c:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0201630:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201634:	0196873b          	addw	a4,a3,s9
ffffffffc0201638:	0017171b          	slliw	a4,a4,0x1
ffffffffc020163c:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0201640:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0201644:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201648:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020164c:	fcd57fe3          	bleu	a3,a0,ffffffffc020162a <vprintfmt+0x252>
ffffffffc0201650:	b77d                	j	ffffffffc02015fe <vprintfmt+0x226>
            if (width < 0)
ffffffffc0201652:	fffdc693          	not	a3,s11
ffffffffc0201656:	96fd                	srai	a3,a3,0x3f
ffffffffc0201658:	00ddfdb3          	and	s11,s11,a3
ffffffffc020165c:	00144603          	lbu	a2,1(s0)
ffffffffc0201660:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201662:	846a                	mv	s0,s10
ffffffffc0201664:	b3f5                	j	ffffffffc0201450 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0201666:	85a6                	mv	a1,s1
ffffffffc0201668:	02500513          	li	a0,37
ffffffffc020166c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020166e:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201672:	02500793          	li	a5,37
ffffffffc0201676:	8d22                	mv	s10,s0
ffffffffc0201678:	d8f70de3          	beq	a4,a5,ffffffffc0201412 <vprintfmt+0x3a>
ffffffffc020167c:	02500713          	li	a4,37
ffffffffc0201680:	1d7d                	addi	s10,s10,-1
ffffffffc0201682:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0201686:	fee79de3          	bne	a5,a4,ffffffffc0201680 <vprintfmt+0x2a8>
ffffffffc020168a:	b361                	j	ffffffffc0201412 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020168c:	00001617          	auipc	a2,0x1
ffffffffc0201690:	0a460613          	addi	a2,a2,164 # ffffffffc0202730 <error_string+0xd8>
ffffffffc0201694:	85a6                	mv	a1,s1
ffffffffc0201696:	854a                	mv	a0,s2
ffffffffc0201698:	0ac000ef          	jal	ra,ffffffffc0201744 <printfmt>
ffffffffc020169c:	bb9d                	j	ffffffffc0201412 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020169e:	00001617          	auipc	a2,0x1
ffffffffc02016a2:	08a60613          	addi	a2,a2,138 # ffffffffc0202728 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc02016a6:	00001417          	auipc	s0,0x1
ffffffffc02016aa:	08340413          	addi	s0,s0,131 # ffffffffc0202729 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02016ae:	8532                	mv	a0,a2
ffffffffc02016b0:	85e6                	mv	a1,s9
ffffffffc02016b2:	e032                	sd	a2,0(sp)
ffffffffc02016b4:	e43e                	sd	a5,8(sp)
ffffffffc02016b6:	1de000ef          	jal	ra,ffffffffc0201894 <strnlen>
ffffffffc02016ba:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02016be:	6602                	ld	a2,0(sp)
ffffffffc02016c0:	01b05d63          	blez	s11,ffffffffc02016da <vprintfmt+0x302>
ffffffffc02016c4:	67a2                	ld	a5,8(sp)
ffffffffc02016c6:	2781                	sext.w	a5,a5
ffffffffc02016c8:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02016ca:	6522                	ld	a0,8(sp)
ffffffffc02016cc:	85a6                	mv	a1,s1
ffffffffc02016ce:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02016d0:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02016d2:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02016d4:	6602                	ld	a2,0(sp)
ffffffffc02016d6:	fe0d9ae3          	bnez	s11,ffffffffc02016ca <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016da:	00064783          	lbu	a5,0(a2)
ffffffffc02016de:	0007851b          	sext.w	a0,a5
ffffffffc02016e2:	e8051be3          	bnez	a0,ffffffffc0201578 <vprintfmt+0x1a0>
ffffffffc02016e6:	b335                	j	ffffffffc0201412 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02016e8:	000aa403          	lw	s0,0(s5)
ffffffffc02016ec:	bbf1                	j	ffffffffc02014c8 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02016ee:	000ae603          	lwu	a2,0(s5)
ffffffffc02016f2:	46a9                	li	a3,10
ffffffffc02016f4:	8aae                	mv	s5,a1
ffffffffc02016f6:	bd89                	j	ffffffffc0201548 <vprintfmt+0x170>
ffffffffc02016f8:	000ae603          	lwu	a2,0(s5)
ffffffffc02016fc:	46c1                	li	a3,16
ffffffffc02016fe:	8aae                	mv	s5,a1
ffffffffc0201700:	b5a1                	j	ffffffffc0201548 <vprintfmt+0x170>
ffffffffc0201702:	000ae603          	lwu	a2,0(s5)
ffffffffc0201706:	46a1                	li	a3,8
ffffffffc0201708:	8aae                	mv	s5,a1
ffffffffc020170a:	bd3d                	j	ffffffffc0201548 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc020170c:	9902                	jalr	s2
ffffffffc020170e:	b559                	j	ffffffffc0201594 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0201710:	85a6                	mv	a1,s1
ffffffffc0201712:	02d00513          	li	a0,45
ffffffffc0201716:	e03e                	sd	a5,0(sp)
ffffffffc0201718:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020171a:	8ace                	mv	s5,s3
ffffffffc020171c:	40800633          	neg	a2,s0
ffffffffc0201720:	46a9                	li	a3,10
ffffffffc0201722:	6782                	ld	a5,0(sp)
ffffffffc0201724:	b515                	j	ffffffffc0201548 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0201726:	01b05663          	blez	s11,ffffffffc0201732 <vprintfmt+0x35a>
ffffffffc020172a:	02d00693          	li	a3,45
ffffffffc020172e:	f6d798e3          	bne	a5,a3,ffffffffc020169e <vprintfmt+0x2c6>
ffffffffc0201732:	00001417          	auipc	s0,0x1
ffffffffc0201736:	ff740413          	addi	s0,s0,-9 # ffffffffc0202729 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020173a:	02800513          	li	a0,40
ffffffffc020173e:	02800793          	li	a5,40
ffffffffc0201742:	bd1d                	j	ffffffffc0201578 <vprintfmt+0x1a0>

ffffffffc0201744 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201744:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201746:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020174a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020174c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020174e:	ec06                	sd	ra,24(sp)
ffffffffc0201750:	f83a                	sd	a4,48(sp)
ffffffffc0201752:	fc3e                	sd	a5,56(sp)
ffffffffc0201754:	e0c2                	sd	a6,64(sp)
ffffffffc0201756:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201758:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020175a:	c7fff0ef          	jal	ra,ffffffffc02013d8 <vprintfmt>
}
ffffffffc020175e:	60e2                	ld	ra,24(sp)
ffffffffc0201760:	6161                	addi	sp,sp,80
ffffffffc0201762:	8082                	ret

ffffffffc0201764 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201764:	715d                	addi	sp,sp,-80
ffffffffc0201766:	e486                	sd	ra,72(sp)
ffffffffc0201768:	e0a2                	sd	s0,64(sp)
ffffffffc020176a:	fc26                	sd	s1,56(sp)
ffffffffc020176c:	f84a                	sd	s2,48(sp)
ffffffffc020176e:	f44e                	sd	s3,40(sp)
ffffffffc0201770:	f052                	sd	s4,32(sp)
ffffffffc0201772:	ec56                	sd	s5,24(sp)
ffffffffc0201774:	e85a                	sd	s6,16(sp)
ffffffffc0201776:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201778:	c901                	beqz	a0,ffffffffc0201788 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc020177a:	85aa                	mv	a1,a0
ffffffffc020177c:	00001517          	auipc	a0,0x1
ffffffffc0201780:	fc450513          	addi	a0,a0,-60 # ffffffffc0202740 <error_string+0xe8>
ffffffffc0201784:	933fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc0201788:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020178a:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020178c:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020178e:	4aa9                	li	s5,10
ffffffffc0201790:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201792:	00005b97          	auipc	s7,0x5
ffffffffc0201796:	886b8b93          	addi	s7,s7,-1914 # ffffffffc0206018 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020179a:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020179e:	991fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02017a2:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02017a4:	00054b63          	bltz	a0,ffffffffc02017ba <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02017a8:	00a95b63          	ble	a0,s2,ffffffffc02017be <readline+0x5a>
ffffffffc02017ac:	029a5463          	ble	s1,s4,ffffffffc02017d4 <readline+0x70>
        c = getchar();
ffffffffc02017b0:	97ffe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02017b4:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02017b6:	fe0559e3          	bgez	a0,ffffffffc02017a8 <readline+0x44>
            return NULL;
ffffffffc02017ba:	4501                	li	a0,0
ffffffffc02017bc:	a099                	j	ffffffffc0201802 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02017be:	03341463          	bne	s0,s3,ffffffffc02017e6 <readline+0x82>
ffffffffc02017c2:	e8b9                	bnez	s1,ffffffffc0201818 <readline+0xb4>
        c = getchar();
ffffffffc02017c4:	96bfe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02017c8:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02017ca:	fe0548e3          	bltz	a0,ffffffffc02017ba <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02017ce:	fea958e3          	ble	a0,s2,ffffffffc02017be <readline+0x5a>
ffffffffc02017d2:	4481                	li	s1,0
            cputchar(c);
ffffffffc02017d4:	8522                	mv	a0,s0
ffffffffc02017d6:	915fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc02017da:	009b87b3          	add	a5,s7,s1
ffffffffc02017de:	00878023          	sb	s0,0(a5)
ffffffffc02017e2:	2485                	addiw	s1,s1,1
ffffffffc02017e4:	bf6d                	j	ffffffffc020179e <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02017e6:	01540463          	beq	s0,s5,ffffffffc02017ee <readline+0x8a>
ffffffffc02017ea:	fb641ae3          	bne	s0,s6,ffffffffc020179e <readline+0x3a>
            cputchar(c);
ffffffffc02017ee:	8522                	mv	a0,s0
ffffffffc02017f0:	8fbfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc02017f4:	00005517          	auipc	a0,0x5
ffffffffc02017f8:	82450513          	addi	a0,a0,-2012 # ffffffffc0206018 <edata>
ffffffffc02017fc:	94aa                	add	s1,s1,a0
ffffffffc02017fe:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201802:	60a6                	ld	ra,72(sp)
ffffffffc0201804:	6406                	ld	s0,64(sp)
ffffffffc0201806:	74e2                	ld	s1,56(sp)
ffffffffc0201808:	7942                	ld	s2,48(sp)
ffffffffc020180a:	79a2                	ld	s3,40(sp)
ffffffffc020180c:	7a02                	ld	s4,32(sp)
ffffffffc020180e:	6ae2                	ld	s5,24(sp)
ffffffffc0201810:	6b42                	ld	s6,16(sp)
ffffffffc0201812:	6ba2                	ld	s7,8(sp)
ffffffffc0201814:	6161                	addi	sp,sp,80
ffffffffc0201816:	8082                	ret
            cputchar(c);
ffffffffc0201818:	4521                	li	a0,8
ffffffffc020181a:	8d1fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc020181e:	34fd                	addiw	s1,s1,-1
ffffffffc0201820:	bfbd                	j	ffffffffc020179e <readline+0x3a>

ffffffffc0201822 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201822:	00004797          	auipc	a5,0x4
ffffffffc0201826:	7e678793          	addi	a5,a5,2022 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc020182a:	6398                	ld	a4,0(a5)
ffffffffc020182c:	4781                	li	a5,0
ffffffffc020182e:	88ba                	mv	a7,a4
ffffffffc0201830:	852a                	mv	a0,a0
ffffffffc0201832:	85be                	mv	a1,a5
ffffffffc0201834:	863e                	mv	a2,a5
ffffffffc0201836:	00000073          	ecall
ffffffffc020183a:	87aa                	mv	a5,a0
}
ffffffffc020183c:	8082                	ret

ffffffffc020183e <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc020183e:	00005797          	auipc	a5,0x5
ffffffffc0201842:	bfa78793          	addi	a5,a5,-1030 # ffffffffc0206438 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201846:	6398                	ld	a4,0(a5)
ffffffffc0201848:	4781                	li	a5,0
ffffffffc020184a:	88ba                	mv	a7,a4
ffffffffc020184c:	852a                	mv	a0,a0
ffffffffc020184e:	85be                	mv	a1,a5
ffffffffc0201850:	863e                	mv	a2,a5
ffffffffc0201852:	00000073          	ecall
ffffffffc0201856:	87aa                	mv	a5,a0
}
ffffffffc0201858:	8082                	ret

ffffffffc020185a <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc020185a:	00004797          	auipc	a5,0x4
ffffffffc020185e:	7a678793          	addi	a5,a5,1958 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201862:	639c                	ld	a5,0(a5)
ffffffffc0201864:	4501                	li	a0,0
ffffffffc0201866:	88be                	mv	a7,a5
ffffffffc0201868:	852a                	mv	a0,a0
ffffffffc020186a:	85aa                	mv	a1,a0
ffffffffc020186c:	862a                	mv	a2,a0
ffffffffc020186e:	00000073          	ecall
ffffffffc0201872:	852a                	mv	a0,a0
}
ffffffffc0201874:	2501                	sext.w	a0,a0
ffffffffc0201876:	8082                	ret

ffffffffc0201878 <sbi_shutdown>:

void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
ffffffffc0201878:	00004797          	auipc	a5,0x4
ffffffffc020187c:	79878793          	addi	a5,a5,1944 # ffffffffc0206010 <SBI_SHUTDOWN>
    __asm__ volatile (
ffffffffc0201880:	6398                	ld	a4,0(a5)
ffffffffc0201882:	4781                	li	a5,0
ffffffffc0201884:	88ba                	mv	a7,a4
ffffffffc0201886:	853e                	mv	a0,a5
ffffffffc0201888:	85be                	mv	a1,a5
ffffffffc020188a:	863e                	mv	a2,a5
ffffffffc020188c:	00000073          	ecall
ffffffffc0201890:	87aa                	mv	a5,a0
ffffffffc0201892:	8082                	ret

ffffffffc0201894 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201894:	c185                	beqz	a1,ffffffffc02018b4 <strnlen+0x20>
ffffffffc0201896:	00054783          	lbu	a5,0(a0)
ffffffffc020189a:	cf89                	beqz	a5,ffffffffc02018b4 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc020189c:	4781                	li	a5,0
ffffffffc020189e:	a021                	j	ffffffffc02018a6 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02018a0:	00074703          	lbu	a4,0(a4) # ffffffffc0200000 <kern_entry>
ffffffffc02018a4:	c711                	beqz	a4,ffffffffc02018b0 <strnlen+0x1c>
        cnt ++;
ffffffffc02018a6:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02018a8:	00f50733          	add	a4,a0,a5
ffffffffc02018ac:	fef59ae3          	bne	a1,a5,ffffffffc02018a0 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02018b0:	853e                	mv	a0,a5
ffffffffc02018b2:	8082                	ret
    size_t cnt = 0;
ffffffffc02018b4:	4781                	li	a5,0
}
ffffffffc02018b6:	853e                	mv	a0,a5
ffffffffc02018b8:	8082                	ret

ffffffffc02018ba <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02018ba:	00054783          	lbu	a5,0(a0)
ffffffffc02018be:	0005c703          	lbu	a4,0(a1) # fffffffffff80000 <end+0x3fd79a38>
ffffffffc02018c2:	cb91                	beqz	a5,ffffffffc02018d6 <strcmp+0x1c>
ffffffffc02018c4:	00e79c63          	bne	a5,a4,ffffffffc02018dc <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02018c8:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02018ca:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02018ce:	0585                	addi	a1,a1,1
ffffffffc02018d0:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02018d4:	fbe5                	bnez	a5,ffffffffc02018c4 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02018d6:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02018d8:	9d19                	subw	a0,a0,a4
ffffffffc02018da:	8082                	ret
ffffffffc02018dc:	0007851b          	sext.w	a0,a5
ffffffffc02018e0:	9d19                	subw	a0,a0,a4
ffffffffc02018e2:	8082                	ret

ffffffffc02018e4 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02018e4:	00054783          	lbu	a5,0(a0)
ffffffffc02018e8:	cb91                	beqz	a5,ffffffffc02018fc <strchr+0x18>
        if (*s == c) {
ffffffffc02018ea:	00b79563          	bne	a5,a1,ffffffffc02018f4 <strchr+0x10>
ffffffffc02018ee:	a809                	j	ffffffffc0201900 <strchr+0x1c>
ffffffffc02018f0:	00b78763          	beq	a5,a1,ffffffffc02018fe <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02018f4:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02018f6:	00054783          	lbu	a5,0(a0)
ffffffffc02018fa:	fbfd                	bnez	a5,ffffffffc02018f0 <strchr+0xc>
    }
    return NULL;
ffffffffc02018fc:	4501                	li	a0,0
}
ffffffffc02018fe:	8082                	ret
ffffffffc0201900:	8082                	ret

ffffffffc0201902 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201902:	ca01                	beqz	a2,ffffffffc0201912 <memset+0x10>
ffffffffc0201904:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201906:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201908:	0785                	addi	a5,a5,1
ffffffffc020190a:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020190e:	fec79de3          	bne	a5,a2,ffffffffc0201908 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201912:	8082                	ret
