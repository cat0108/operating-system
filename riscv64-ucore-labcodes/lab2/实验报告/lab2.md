# 操作系统的物理内存管理
## 基础知识
1. 使用页表机制：RISCV:sv39 页大小：4k
2. 物理地址 (Physical Address) 有 56 位，虚拟地址 (Virtual Address) 有 39 位，虚拟地址`高位补齐`
3. 不论是物理地址还是虚拟地址，最后 12 位表示的是页内偏移。


### 页表项
1. 描述一个虚拟页号如何映射到物理页号
2. 有上述知，56-12=44，页表项需要44位来保存物理页号。
3. 页表项的结构：63-54位为保留位，53-10位为物理页号，9-0位为映射的状态信息位。

5. 状态位的介绍：
   1. RSW(2bit) 域留给操作系统使用，它会被硬件忽略。两位留给 S Mode 的应用程序，我们可以用来进行拓展。
   2. D：dirty，该页是否被写过
   3. A：accessed，该页是否被访问过
   4. G：global，该页是否是全局页
   5. U：user，该页是否属于用户态，若属于用户态，则为安全考虑，S Mode 的应用程序不能访问该页
   6. V：valid，该页是否有效，若无效，则说明该页还没有被分配物理内存，其它位无意义
   7. 剩下根据状态位三位(read、write、execute)RWX的取值不同，分别代表不同含义：

    ![Alt text](image.png)

### 多级页表
sv39采用三级页表
1. 大小分别为：有 4KiB=4096 字节的页，大小为 2MiB=2^21 字节的大页，和大小为 1 GiB 的大大页。
2. 由于虚拟地址为39位，去除12位页内偏移，剩下27位，每一级页表的偏移9位，因此共计512G的虚拟内存地址空间
3. 每一级页表的大小：512bit/8*64=4kiB
   
### 页表基址
satp（Supervisor Address Translation and Protection，监管者地址转换和保护）的 S 模式控制状态寄存器(CSR)控制了分页系统。

![Alt text](image-1.png)
1. MODE 域可以开启分页并选择分页模式，我们此处选择 Sv39 模式(1000)。
2. ASID 域是地址空间 ID，用于多进程的地址空间隔离，我们此处不使用多进程，因此 ASID 域为 0 即可，还可以用来降低上下文切换的开销。
3. PPN 域是页表基址，它指向了最高级地址的物理页号。`tag:，PPN 字段保存了根页表的物理地址，它以 4 KiB 的页面大小为单位。通常 M 模式的程序在第一次进入 S模式之前会把零写入 satp 以禁用分页，然后 S 模式的程序在初始化页表以后再次进行satp 寄存器的写操作。`
   
### TLB  (Translation Lookaside Buffer)
注意点：若PPN字段被修改，说明切换了映射方式，需要刷新TLB：`sfence.vma`指令，同样手动修改页表项后，也需要刷新TLB。

## 实验内容

### exercise 1

1. 为什么使用do while(0)
    ```c++
    #define local_intr_save(x) \
    do {                   \
        x = __intr_save(); \
    } while (0)
    //宏定义采用直接替换的方式，内联函数也是直接替换的方式，若出现if语句，没有do while，则会：
    if(expr)
        if (read_csr(sstatus) & SSTATUS_SIE) {
            intr_disable();
            return 1;
        }
    return 0;
    //出现逻辑错误
    ```
2. 改进：对于struct Page
   ```c
   struct Page {
    int ref;                        // page frame's reference counter
    uint64_t flags;                 // array of flags that describe the status of the page frame
    unsigned int property;          // the num of free block, used in first fit pm manager
    list_entry_t page_link;         // free list link
    };
   ```
   文中采用一种减去偏移量的方式来已知page link获取Page，但是若声明page_link在最先，page_link的的地址就是Page这个结构体的地址，无需复杂操作。

   ```