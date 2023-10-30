#include <assert.h>
#include <defs.h>
#include <fs.h>
#include <ide.h>
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}

//硬盘的最大数量
#define MAX_IDE 2
//硬盘的最大扇区数
#define MAX_DISK_NSECS 56
//一块硬盘的大小，sectsize=512
static char ide[MAX_DISK_NSECS * SECTSIZE];
//检查给定的 IDE 设备编号 ideno 是否在有效范围内
bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
//返回该 IDE 设备的扇区数
size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
//读取该 IDE 设备上的指定位置开始的扇区数据到 缓冲区dst中
int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
    return 0;
}
//将缓冲区src中的数据写入到该 IDE 设备上的指定位置开始的扇区中
int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
    return 0;
}
