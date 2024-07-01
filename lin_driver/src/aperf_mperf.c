#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <asm/msr.h>

#define IA32_APERF_MPERF_FIXED_CTR_CTRL 0x38f
#define IA32_PERF_FIXED_CTR0 0x309
#define IA32_PERF_FIXED_CTR1 0x30a
#define IA32_PERF_FIXED_CTR_CTRL 0x38d

static int __init init_aperf_mperf(void)
{
    u64 aperf, mperf;
    u64 fixed_ctr_ctrl;

    rdmsrl(IA32_PERF_FIXED_CTR_CTRL, fixed_ctr_ctrl);
    fixed_ctr_ctrl |= (1ULL << 32); // Enable user-mode access to fixed counters
    wrmsrl(IA32_PERF_FIXED_CTR_CTRL, fixed_ctr_ctrl);

    rdmsrl(IA32_APERF_MPERF_FIXED_CTR_CTRL, fixed_ctr_ctrl);
    fixed_ctr_ctrl |= 0x3333; // Enable APERF and MPERF
    wrmsrl(IA32_APERF_MPERF_FIXED_CTR_CTRL, fixed_ctr_ctrl);

    rdmsrl(IA32_PERF_FIXED_CTR0, aperf);
    rdmsrl(IA32_PERF_FIXED_CTR1, mperf);

    printk(KERN_INFO "APERF: %llu, MPERF: %llu\n", aperf, mperf);

    return 0;
}

static void __exit exit_aperf_mperf(void)
{
    // Clean up any resources if needed
}

module_init(init_aperf_mperf);
module_exit(exit_aperf_mperf);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Your Name");
MODULE_DESCRIPTION("Linux module for reading APERF and MPERF counters");

