# Copy-On-Write (COW) 设计文档
Copy-On-Write (COW) 是一种优化策略，主要用于进程创建和内存管理。在创建新进程或者分配新内存时，不立即进行数据复制，而是让父进程和子进程共享相同的内存。只有当其中一个进程试图修改内存时，才会复制一份内存给这个进程，这样可以减少不必要的内存复制，提高系统性能。
## 设计思路
1. Fork操作时不直接复制内存：在fork操作时，不直接进行内存的复制，而是将子进程和父进程的虚拟页映射到同一个物理页面。然后在这两个进程的虚拟页对应的PTE部分将这个页置为不可写，并标记为共享页面。这样，如果应用程序试图写某一个共享页，就会产生页访问异常，从而可以将控制权交给操作系统进行处理。

2. 处理内存页访问异常：当出现内存页访问异常时，会将共享的内存页复制一份，然后在新的内存页进行修改。处理方式为额外申请分配一个物理页面，然后将当前的共享页的内容复制过去，建立出错的线性地址与新创建的物理页面的映射关系，将PTE设置为非共享的。然后查询原先共享的页面是否还有其他进程在共享使用，如果没有了，就修改PTE，把共享标记修改为写标记，就可以实现正常的写操作了。
## 实现步骤  
1. 修改share变量：首先，将vmm.c中的dup_mmap函数中队share变量的设置进行修改,因为dup_mmap函数中会调用copy_range函数，copy_range函数有一个参数为share，因此修改share为1标志着启动了共享机制。  
```C
int dup_mmap(struct mm_struct *to, struct mm_struct *from) {
		...
        bool share = 1;
		if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share)!= 0) 			{
            return -E_NO_MEM;
         }
        ...
```
2. 修改Fork操作：在fork操作时，不直接复制内存，而是将父子进程的虚拟页映射到同一个物理页面，并将这个页置为不可写，并标记为共享页面。  
```C  
// 在fork操作时，修改copy_range函数
void copy_range(pgd_t *to, pgd_t *from, uintptr_t start, uintptr_t end, bool share) {
    ...
    if (share) {
        // 如果是共享，将页表项设置为只读，并标记为共享
        pte_t *pte = get_pte(from, start, 0);
        *pte = *pte & ~PTE_W;
        *pte = *pte | PTE_SHARE;
    }
    ...
}
```
3. 处理页访问异常：在页访问异常处理函数中，检查是否是由于写共享页引起的，如果是，就重新为进程分配页面、拷贝页面内容，并修改映射关系。  
```C  
// 在do_pgfault函数中处理写共享页的异常
int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
    ...
    if ((error_code & 2) && (pte & PTE_SHARE)) {
        // 如果是写共享页引起的异常
        struct Page *page = alloc_page();
        memcpy(page2kva(page), page2kva(pa2page(pte)), PGSIZE);
        pte = pte & ~PTE_SHARE;
        pte = pte | PTE_W;
        page_insert(mm->pgdir, page, addr, pte);
    }
    ...
}
```
4. 修改页表项：在修改页表项时，如果发现没有其他进程共享这个页面了，就将页表项设置为可写。
```C
// 在page_remove_pte函数中，如果发现没有其他进程共享这个页面了，就将页表项设置为可写
void page_remove_pte(pgd_t *pgdir, uintptr_t la, pte_t *ptep) {
    ...
    if ((pte & PTE_SHARE) && page_ref(page) == 1) {
        // 如果没有其他进程共享这个页面了
        pte = pte & ~PTE_SHARE;
         pte = pte | PTE_W;
        *ptep = pte;
    }
    ...
}

```
以上就是COW的基本设计和实现思路。