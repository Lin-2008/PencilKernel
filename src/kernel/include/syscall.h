#ifndef __SYSCALL_H__
#define __SYSCALL_H__

#include <thread.h>

#define SYSCALL_INTR 0x40
// typedef void* syscall_t;
typedef signed long long int syscall_return_t;

#define SEND         1 /* 发送消息 */
#define RECEIVE      2 /* 接收消息 */
#define BOTH         3 /* 发送消息,等待对方回复 */
#define MSG_RECEIVED 4 /* 查看是否有进程向自己发送过消息 */

enum
{
    ANY = 0x0fff0000,
    NO_TASK,
    TASKPID_END,
};

extern pid_t pid_table[TASKPID_END - ANY];
void init_syscall();
syscall_return_t send_recv(int function,pid_t src_dst,message_t* msg);

#endif