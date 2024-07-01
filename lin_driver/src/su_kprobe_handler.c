#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/kprobes.h>

#include "su_kprobe_handler.h"

static struct kprobe kp;

static int my_kprobe_handler(struct kprobe* p, struct pt_regs* pregs) {
   printk(KERN_INFO "kprobe handler : handler p called \n");
   return 0;
}


int __init my_kprobe_init(void) {
   kp.pre_handler = my_kprobe_handler;
   //kp.symbol_name = "do_fork";
   kp.addr = (kprobe_opcode_t *)0xffffffff8100a1b0;
   int ret = 0;
   ret = register_kprobe(&kp);
   if (ret < 0) {
      printk(KERN_INFO "register_kprobe failed, returned %d\n", ret);
      return ret;
   }
   printk(KERN_INFO "kprobe registered for do_fork\n");
   return ret;
}

void __exit my_kprobe_exit(void)
{
    unregister_kprobe(&kp);
    printk(KERN_INFO "kprobe unregistered for do_fork\n");
}
