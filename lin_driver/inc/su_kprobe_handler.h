#ifndef __SU_KPROBE_HANDLERS_H__
#define __SU_KPROBE_HANDLERS_H__

#define OP_BUFFER_SIZE                                                  \
	256 /* Number of output messages in each per-cpu buffer */

/* Function Declartations*/
int my_kprobe_init(void);
void my_kprobe_exit(void);



#endif
