#include <list.h>
#include <string.h>
#include<stdio.h>
#include <buddy_pmm.h>

free_buddy_t buddy_s;

#define buddy_array (buddy_s.free_array)
#define max_order (buddy_s.max_order)
#define nr_free (buddy_s.nr_free)

static int IS_POWER_OF_2(size_t n) {
    if (n & (n - 1)) {
        return 0;
    }
    else {
        return 1;
    }
}

static unsigned int getOrderOf2(size_t n) {
    unsigned int order = 0;
    while (n >> 1) {
        n >>= 1;
        order ++;
    }
    return order;
}

static size_t ROUNDDOWN2(size_t n) {
    size_t res = 1;
    if (!IS_POWER_OF_2(n)) {
        while (n) {
            n = n >> 1;
            res = res << 1;
        }
        return res>>1; 
    }
    else {
        return n;
    }
}

static size_t ROUNDUP2(size_t n) {
    size_t res = 1;
    if (!IS_POWER_OF_2(n)) {
        while (n) {
            n = n >> 1;
            res = res << 1;
        }
        return res; 
    }
    else {
        return n;
    }
}


/*
 *  初始化buddy结构体
 */
static void
buddy_init(void) {
    // 初始化链表数组中的每个free_list头
    for (int i = 0;i < MAX_BUDDY_ORDER;i ++){
        list_init(buddy_array + i); 
    }
    max_order = 0;
    nr_free = 0;
    return;
}

/*
 *  获取以page页为头页的块的buddy块
 */
static struct Page*
buddy_get_buddy(struct Page *page) {
    unsigned int order = page->property;
    extern ppn_t first_ppn;
    //此处操作的逻辑：一个page的buddy和它只在最高位不同，其余位相同，例如order=2时，page为100-111，则buddy为000-011，因此采用异或
    unsigned int buddy_ppn =first_ppn + ((1 << order) ^ (page2ppn(page) - first_ppn));
    if (buddy_ppn > page2ppn(page)) {
        return page + (buddy_ppn - page2ppn(page));
    }
    else {
        return page - (page2ppn(page) - buddy_ppn);
    }
 
}

static void
buddy_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    size_t pnum;
    unsigned int order;
    pnum = ROUNDDOWN2(n);       // 将页数向下取整为2的幂
    order = getOrderOf2(pnum);   // 求出页数对应的2的幂
    struct Page *p = base;
    // 初始化pages数组中范围内的每个Page
    for (; p != base + pnum; p ++) {
        assert(PageReserved(p));
        p->flags = 0;
        p->property = -1;   // 全部初始化为非头页
        set_page_ref(p, 0);
    }
    max_order = order;
    nr_free = pnum;
    list_add(&(buddy_array[max_order]), &(base->page_link)); // 将第一页base插入数组的最后一个链表，作为初始化的最大块——16384,的头页
    base->property = max_order;                       // 将第一页base的property设为最大块的2幂

    return;
}    


// 默认分裂数组中第n条链表的第一块
static void buddy_split(size_t n) {
    assert(n > 0 && n <= max_order);
    assert(!list_empty(&(buddy_array[n])));
    struct Page *page_a;
    struct Page *page_b;

    page_a = le2page(list_next(&(buddy_array[n])), page_link);
    page_b = page_a + (1 << (n - 1));
    page_a->property = n - 1;
    page_b->property = n - 1;

    list_del(list_next(&(buddy_array[n])));
    list_add(&(buddy_array[n-1]), &(page_a->page_link));
    list_add(&(page_a->page_link), &(page_b->page_link));

    return;
}

static struct Page *
buddy_alloc_pages(size_t n) {
    // require n > 0, or panic
    assert(n > 0);

    // if the number of required pages beyond what we have currently, return NULL
    if (n > nr_free) {
        return NULL;
    }

    struct Page *page = NULL;
    size_t pnum = ROUNDUP2(n);  // 处理所要分配的页数，向上取整至2的幂
    size_t order = 0;

    order = getOrderOf2(pnum);  // 求出所需页数对应的幂pow
find:
    // 若pow对应的链表中含有空闲块，则直接分配
    if (!list_empty(&(buddy_array[order]))) {
        page = le2page(list_next(&(buddy_array[order])), page_link);
        list_del(list_next(&(buddy_array[order])));
        SetPageProperty(page); // 将分配块的头页设置为已被占用
        goto done; 
    }
    else {
        for (int i = order;i < max_order + 1;i ++) {
            // 找到pow后第一个非空链表，分裂空闲块
            if (!list_empty(&(buddy_array[i]))) {
                buddy_split(i);
                goto find;      // 重新检查现在是否可以分配
            }
        }
    }

done:
    nr_free -= pnum;
    return page;
}

static void
buddy_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    unsigned int pnum = 1 << (base->property);
    assert(ROUNDUP2(n) == pnum);
    struct Page* left_block = base;
    struct Page *buddy = NULL;
    struct Page* tmp = NULL;

    buddy = buddy_get_buddy(left_block);
    list_add(&(buddy_array[left_block->property]), &(left_block->page_link));
    // 当buddy块空闲，且当前块不为最大块时
    while (!PageProperty(buddy) && left_block->property < max_order) {
        if (left_block > buddy) { // 若当前左块为更大块的右块
            left_block->property = -1;
            ClearPageProperty(left_block);
            tmp = left_block;
            left_block = buddy;
            buddy = tmp;
        }
        list_del(&(left_block->page_link));    
        list_del(&(buddy->page_link));
        left_block->property += 1;
        list_add(&(buddy_array[left_block->property]), &(left_block->page_link)); // 头插入相应链表
        buddy = buddy_get_buddy(left_block);
    }
    ClearPageProperty(left_block); // 将回收块的头页设置为空闲
    nr_free += pnum;
    
    return;
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}


static void
basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);
    free_page(p0);
    free_page(p1);
    free_page(p2);

    assert((p0 = alloc_pages(4)) != NULL);
    assert((p1 = alloc_pages(2)) != NULL);
    assert((p2 = alloc_pages(1)) != NULL);
    free_pages(p0, 4);
    free_pages(p1, 2);
    free_pages(p2, 1);

    assert((p0 = alloc_pages(3)) != NULL);
    assert((p1 = alloc_pages(3)) != NULL);
    free_pages(p0, 3);
    free_pages(p1, 3);

}

static void
show_buddy_array(void) {
    cprintf("test: Printing buddy array:\n");
    for (int i = 0;i < max_order + 1;i ++) {
        cprintf("%d layer: ", i);
        list_entry_t *le = &(buddy_array[i]);
        while ((le = list_next(le)) != &(buddy_array[i])) {
            struct Page *p = le2page(le, page_link);
            cprintf("%d ", 1 << (p->property));
        }
        cprintf("\n");
    }
    cprintf("---------------------------\n");
    return;
}

static void
buddy_check(void) {
    basic_check();
    show_buddy_array();

    struct Page *p0, *p1, *p2 ,*p3, *p4,*p5;
    p0=p1=p2=NULL;
    assert((p0 = buddy_alloc_pages(12)) != NULL);
    show_buddy_array();
    assert((p1 = buddy_alloc_pages(2)) != NULL);
    show_buddy_array();
    assert((p2 = buddy_alloc_pages(1)) != NULL);
    show_buddy_array();
    assert((p3 = buddy_alloc_pages(1)) != NULL);
    show_buddy_array();
    assert((p4 = buddy_alloc_pages(1)) != NULL);

    show_buddy_array();

    buddy_free_pages(p2, 1);
    buddy_free_pages(p3, 1);
    show_buddy_array();
    buddy_free_pages(p1, 2);
    buddy_free_pages(p4, 1);
    buddy_free_pages(p0, 12);

}   

const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};