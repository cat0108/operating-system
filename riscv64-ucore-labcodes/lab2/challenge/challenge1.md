# challenge 1 buddy system的实现
我们将buddy sysytem的结构的每一层使用一个list来表示，即每一层表示2的不同次幂的块的链表，每个块的结构如下：
```c
typedef struct {
    unsigned int max_order;                           // buddy二叉树的层数
    list_entry_t free_array[MAX_BUDDY_ORDER + 1];     // 链表数组(现在默认有14层，即2^14 = 16384个可分配物理页)，每个数组元素都一个free_list头
    unsigned int nr_free;                             // 系统中剩余的空闲块
} free_buddy_t;
```
由于分配的总内存不是2的整数次幂，所以我们分配时向下取整。
我们还定义了如下函数
```c
    static int IS_POWER_OF_2(size_t n)//判断n是否是2的整数次幂
    static unsigned int getOrderOf2(size_t n)//n是2的整数次幂，返回n的次幂
    static size_t ROUNDDOWN2(size_t n)//向下取整为2的整数次幂
    static size_t ROUNDUP2(size_t n)//向上取整为2的整数次幂
    static void show_buddy_array(void) //打印buddy system的每一层的空闲块数
```
# 初始化buddy system
初始化时，由于buddy system的树状结构，要求初始化的页数必须为2的整数倍，于是我们采用向下取整，并得到2的幂：max_order,对应的buddy_array[max_order]即为初始化的页所连接的链表。

# 分配内存
分配内存时，同理我们需要向上取整至2的整数次幂order，然后找到对应的buddy_array[order]的链表，若链表为空，则向上一层即[order+1]寻找，直到找到一个非空的链表，然后分裂该链表的第一个块直到分裂到order层，并将该节点和分配出去的order层的page从链表中删除，返回该page。

# 释放内存
释放内存时，首先将要释放的块连接到buddy_array[order]中去，然后判断其兄弟节点buddy且未被分配，若未被分配，则将其合并，合并后继续向上合并，直到合并到最大层，或者其兄弟节点已经被分配。

# 测试
在测试样例中，我们采用打印每一层的空闲块数并进行比对来分析正确性

# 一些函数接口
```c
    static void 
    buddy_split(size_t n)//分裂第n层的第一个块
    static struct Page*
    buddy_get_buddy(struct Page *page)//返回一个block的的buddy
```