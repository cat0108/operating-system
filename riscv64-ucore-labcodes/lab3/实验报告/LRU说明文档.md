# 扩展练习 Challenge：实现不考虑实现开销和效率的 LRU 页替换算法（需要编程）
- 要求：选择**最长时间没有被引用**的页面进行置换。
- 方法：以 visited 的值作为上次访问时间长短的量值，visited 越大表示越长时间没被访问。缺页时，遍历内存中每个逻辑页面的上一次访问时间，并选择**上一个使用到当前时间最长**的页面。

实现思路：
- 增加检查函数_lru_check，调用函数时遍历所有的可交换页，若该页近期被访问过则将其 visited 归零，否则 visited++
- 在_lru_map_swappable ()、_lru_swap_out_victim () 执行时调用_lru_check 函数，对当前可交换页链表的各页访问情况进行更新。
- _lru_swap_out_victim () 函数维护一个 largest_visited 变量储存最久未访问的页，遍历所有可交换页，找到其中 visited 最大者，将其换出
```c
static int _lru_check(struct mm_struct *mm)
{
    list_entry_t *head = (list_entry_t *)mm->sm_priv;   //头指针
    assert(head != NULL);
    list_entry_t *entry = head;
    while ((entry = list_prev(entry)) != head)
    {
        struct Page *entry_page = le2page(entry, pra_page_link);
        pte_t *tmp_pte = get_pte(mm->pgdir, entry_page->pra_vaddr, 0);
        cprintf("the ppn value of the pte of the vaddress is: 0x%x  \n", (*tmp_pte) >> 10);
        if (*tmp_pte & PTE_A)  //如果近期被访问过，visited清零
        {
            entry_page->visited = 0;
            *tmp_pte = *tmp_pte ^ PTE_A;//清除访问位
        }
        else
        {
            //未被访问就加一
            entry_page->visited++;
        }
        cprintf("the visited goes to %d\n", entry_page->visited);
    }
}
```
_lru_map_swappable 函数基本上与 FIFO 算法的内容一致，增加了对 check 函数的调用和对 page 的 visited 初始化为 0
```c
static int _lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    _lru_check(mm);
    list_entry_t *entry = &(page->pra_page_link);
    assert(entry != NULL);
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
    list_add(head, entry); // 将页面page插入到页面链表pra_list_head的末尾
    page->visited = 0;     //标记为未访问
    return 0;
}
```
_lru_swap_out_victim 函数需要遍历所有可交换页，找到其中 visited 最大者和对应的 page，将其换出
```c
static int _lru_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page, int in_tick)
{
    _lru_check(mm);
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
    assert(head != NULL);
    assert(in_tick == 0);
    
    list_entry_t *entry = list_prev(head);
    list_entry_t *pTobeDel = entry;
    uint_t largest_visted = le2page(entry, pra_page_link)->visited;     //最长时间未被访问的page，比较的是visited
    while (1)
    {
        //entry转一圈，遍历结束
        // 遍历找到最大的visited，表示最早被访问的
        if (entry == head)
        {
            break;
        }
        if (le2page(entry, pra_page_link)->visited > largest_visted)
        {
            largest_visted = le2page(entry, pra_page_link)->visited;
            pTobeDel = entry;
        }
        entry = list_prev(entry);
    }
    list_del(pTobeDel);
    *ptr_page = le2page(pTobeDel, pra_page_link);
    cprintf("curr_ptr %p\n", pTobeDel);
    return 0;
}
```