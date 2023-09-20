# lab1 中断处理
在RISCV中，interrupt和exception统称为trap。
处理方法：
1. 编写中断处理代码
2. 设置控制状态寄存器
3. CPU捕获异常
4. 移交中断处理程序处理
5. 返回程序

## 中断处理的两种Mode：
1. M Mode：机器模式，发生的所有异常在默认情况控制权都会被移交到M模式的异常处理程序。
2. S Mode： supervisor Mode:操作系统权限模式，在M mode中的异常处理程序可以将异常重新导向S Mode；或者通过**异常委托机制**选择性地交给S Mode处理，完全绕过M Mode。
3. U Mode:User Mode用户态。

## 中断处理的寄存器
控制状态寄存器**CSRS**和中断有关。

1. sstatus(Supervisor Status Register):可禁止CPU产生中断。其中有关键位SIE（supervisor interrupt enable）和UIE(user)，置为0时可让在S/U态运行的程序禁止产生中断。二进制位SPIE(previous)保存SIE之前的值，以便在异常处理过程中能够正确地恢复中断状态。
2. stvec(supervisor Trap Vector Base addr ):中断向量表基址寄存器。在中断产生后由中断处理程序来处理中断**注意该寄存器存的是其基地址！**
   
   `中断向量表：将不同种类的中断映射到相应处理程序。`

   若只有一个中断处理程序，则stvec直接指向那个程序的地址。如何实现？

   `stvec最低两位二进制位用来判断，是00说明是中断程序地址，是01则说明是中断向量表地址，在末尾补0形成完整地址(RISCV架构要求)`
3. sepc：supervisor状态下的异常pc，记录触发中断的指令、scause:记录中断发生原因、stval(Trap value)：记录辅助信息，把发生的问题记录下来，如非法指令、缺页错误等。
4. sscratch:切换context时保存栈的临时状态：约定，若中断前是S态，则置为0，若位U态，则储存内核栈地址。sbadvaddr：用于在异常处理期间存储导致异常的虚拟地址或访问异常的地址。
   
## 中断相关的特权指令
1. ecall:只能在M态执行，在S和U态执行会触发exception，进入M/S态的中断处理流程。
2. sret:从S态中断返回U态,pc<--sepc。返回中断前的地址。
3. ebreak:触发断点中断，进入中断处理流程。
4. mret:从M态返回S、U态，pc<--mepc。

## 中断入口(开始实验编程部分)
发生中断后stvec跳转到中断程序入口点，在执行中断程序之前需要进行上下文切换。

`中断处理需要把原先寄存器保存，在处理完毕后把寄存器恢复并继续执行。`

1. 保存上下文的这些寄存器到内存(栈)上
   1. 定义结构体trapFrame(中断帧)，里面包含0-31号寄存器（在嵌套结构体gpr中，和4个CSR）
        ```c
        struct trapframe {
            struct pushregs gpr;//x0-x31
            uintptr_t status; //sstatus
            uintptr_t epc; //sepc
            uintptr_t badvaddr; //sbadvaddr
            uintptr_t cause; //scause
            };
        void trap(struct trapframe *tf);//进行中断处理
        ```
   2. 将这些寄存器保存到栈上，先保存通用寄存器，再保存CSR，其中sp保存原先的栈。因此x2(sp)不和其它通用寄存器一起保存，在最开始保存到sscratch中，后续写入栈中。注意CSR不能直接写到内存，应使用通用寄存器过渡。
        ```c
        csrw sscratch, sp
        ......
        csrrw s0, sscratch, x0//sscratch写入s0，再把0写入sscratch
        STORE s0, 2*REGBYTES(sp)//将原来的sp(x2)保存
        ```
2. 从栈上恢复寄存器(LOAD)
   和保存的顺序相反，注意只需要恢复sstatus和sepc，同理CSR不能直接从内存中读，最后恢复sp。**不需要全部恢复的原因：**为了提高中断响应和上下文切换的效率。取出和恢复所有 CSR 可能会引入额外的开销，因此通常只需要处理一些关键的 CSR。
3. 中断入口的确定：中断入口点可分为三个部分：**保存上下文、调用中断处理函数、恢复上下文**。保存和恢复已经实现，在调用trap时，需要传递参数，通过寄存器a0完成，传递的参数为结构体trapframe的指针，即为当前sp的位置。除此之外，中断入口点必须四字节对齐，采用align函数。

## 中断处理程序
需要初始化中断处理函数
1. 在intr.c
    ```c
    void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
    ```
    中通过设置SIE位为1/0来决定是否启用中断。

2. 在trap.c中
    ```c
    void idt_init(void)
    ```
    将之前的中断入口点(已经对齐)赋值给stvec寄存器，满足先前的规定。同时将trap()函数的处理中断功能拆分，根据scause的正负(最高位的值)来判断是interrupt(1)还是exception(0)。
    ```c
        if ((intptr_t)tf->cause < 0) {
            // interrupts
            interrupt_handler(tf);
        } else {
            // exceptions
            exception_handler(tf);
            }
        }
    ```
    在此之中即有时钟中断:IRQ_S_TIMER，其本质上是每隔若干个时钟周期就执行一次的程序。

3. 实现时钟中断：
   1. 在OpenSBI中提供了接口:sbi_set_timer()。传入一个时刻并在该时刻触发时钟中断。
   2. rdtime伪指令：读取time的CSR数值，表示CPU启动之后经过真实时间，基本单位是CPU的时钟频率(使用需要**内联汇编**)。例如本实验时钟频率10MHz，则每过1s结果增加10000000
      1. 在32位架构下，需要rdtimeh和rdtime进行拼接后才能返回。
      2. 64位架构下，读取直接返回即可。
   3. 启用中断(set SIE)、设置第一个时钟中断事件和后续中断事件。
4. **中断处理流程**：全过程的执行流可分为**内核初始化**和**时钟中断执行流**两部分
   1. 在内核kern_init()中：输出一些信息表示加载内核，初始化控制台(暂未实现)，在打印一些信息后按照先后顺序进行如下操作：
      1. 调用trap.c中的idt_init()函数，设置stvec的跳转地址，即中断处理程序入口为trapentry.S中的特定代码部分。
      2. 调用clock.c中的clock_init()函数，设置CSR里的SIE为1，使得能够在S态允许时钟中断(默认关闭)。该函数声明了计时器ticks，又调用了 clock_set_next_event()函数，调用sbi的接口set_sbi_timer()触发中断。
      3. 调用intr.c中的intr_enable()函数，使得全局能允许中断。
   2. 中断执行流：触发的中断由于先前stvec跳转地址的设定，跳转到trapentry.S中保存上下文信息，并将其封装为结构体当作参数传入trap.c的trap()函数中，通过scause最高位的值判断其属于interrupt还是exception从而跳转不同的处理函数()本实验是interrupt。再细分判断是哪一种类型的中断(时钟中断)。执行其对应的处理语句：触发下一次中断，累加计数器，在屏幕上打印，完成处理后回到原先恢复的上下文。以此反复直到打印十条消息后终止程序。

## 练习1解答
指令 la sp, bootstacktop将栈指针sp的值设置为 bootstacktop 的地址。初始化内核的栈，以确保内核代码在执行时有一个有效的栈。在程序的后续中也定义了启动栈bootstack，并初始化了一些空间，然后定义了栈顶，此命令作用即为将栈指针置于该栈顶部，之后栈的分配在bootstack之上进行。不会对已经定义的数据区产生冲突

tail_kern为不返回调用，即跳转到tail_kern的位置继续执行而不再返回，目的是让启动操作系统内核

## challenge1
1. 描述 ucore 中处理中断异常的流程:
   
   触发中断时，首先由sepc保存异常的pc，然后pc设置为stvec，跳转到stvec寄存器所指向的地址中，即trapentry.S里，在该过程保存了上下文信息，并封装成结构体，将其作为参数调用trap()函数，进行中断处理，在该函数内调用trap_dispatch()函数，根据保存上下文的信息，进一步分为interrupt和exception两个处理函数。再根据不同的中断源进行不同处理，最后跳转回到trapentry.S中恢复上下文，并返回到中断发生的位置继续执行。
2. 其中 mov a0，sp 的目的是什么：
   
   我们注意到trap(struct trapframe *tf)的参数是中断帧这个结构体，而在这之前，已经把该结构体里的所有寄存器存到了栈上，因此此时sp的位置即为这个结构体的指针，a0用于传递函数的参数，因此这一句就是向trap中传递结构体参数。
3. SAVE_ALL中寄存器保存在栈中的位置是什么确定的：
   
   是根据寄存器的编号x0-x31依次保存，然后再保存CSR，由于sp(x2)寄存器需要保存最初始的栈指针，于是需要先存到sscratch中去，再保存到特定位置上。
4. 对于任何中断，__alltraps 中都需要保存所有寄存器吗？

   对于不同的中断来说，判断其正在使用哪些寄存器需要一定的硬件软件支持，加大工作量，不妨采用最简单的办法，将通用的寄存器全部保存。

## challenge 2
1. 在 trapentry.S 中汇编代码 csrw sscratch, sp；csrrw s0, sscratch, x0 实现了什么操作，目的是什么？
   
   第一句汇编代码就像我们提到的这样，需要保存最初的栈状态，先放到sssratch寄存器中暂存。后一条指令是由于CSR寄存器不能直接和内存进行读写操作，于是先把刚才保存的sp保存到s0寄存器中,然后再将x0寄存器里的0保存到sscratch中，这么做是由于一个约定:中断前处于S态sscratch的值为0，若处于U态则其值赋值为内存栈地址。后续再将s0的值存到栈上的特定位置。
2. save all里面保存了 stval scause 这些 csr，而在 restore all 里面却不还原它们？那这样 store 的意义何在呢？

   这些寄存器是在中断处理过程中判断中断类型，进行相应中断处理程序的选择等操作中发挥作用，后续没有作用，因此没有必要重新恢复。而若想将这些寄存器传递，封装了一个数据结构trapframe。要想将此数据结构作为trap()函数参数调用就需要将这些寄存器依次入栈，所以需要store。

