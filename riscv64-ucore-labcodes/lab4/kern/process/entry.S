.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1				# push arg
	jalr s0					# jump and link to kernel_thread

	jal do_exit
