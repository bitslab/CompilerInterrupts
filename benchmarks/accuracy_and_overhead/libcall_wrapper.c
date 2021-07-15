#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "ci_lib.h"
#include <sys/mman.h>
#include <sys/types.h>
#include <dirent.h>
#include <time.h>


static int (*real_munmap)(void *addr, size_t length) = NULL;

int munmap(void *addr, size_t length) {

  if(!real_munmap) {
    real_munmap = dlsym(RTLD_NEXT, "munmap");
    if (!real_munmap) {
      printf("Symbol for munmap() is not found.\n");
      exit(1);
    }
  }

  ci_disable();
  int ret = real_munmap(addr, length);
  ci_enable();
  return ret;
}


static int (*real_mprotect)(void *addr, size_t len, int prot) = NULL;

int mprotect(void *addr, size_t len, int prot) {

  if(!real_mprotect) {
    real_mprotect = dlsym(RTLD_NEXT, "mprotect");
    if (!real_mprotect) {
      printf("Symbol for mprotect() is not found.\n");
      exit(1);
    }
  }

  ci_disable();
  int ret = real_mprotect(addr, len, prot);
  ci_enable();
  return ret;
}


static int (*real_pthread_join)(pthread_t thread, void **retval) = NULL;

int pthread_join(pthread_t thread, void **retval) {

  if(!real_pthread_join) {
    real_pthread_join = dlsym(RTLD_NEXT, "pthread_join");
    if (!real_pthread_join) {
      printf("Symbol for pthread_join() is not found.\n");
      exit(1);
    }
  }

  ci_disable();
  int ret = real_pthread_join(thread, retval);
  ci_enable();
  return ret;
}


static int (*real_pthread_timedjoin_np) (pthread_t __th, void **__thread_return, const struct timespec *__abstime) = NULL;

int pthread_timedjoin_np (pthread_t __th, void **__thread_return, const struct timespec *__abstime) {

  if(!real_pthread_timedjoin_np) {
    real_pthread_timedjoin_np = dlsym(RTLD_NEXT, "pthread_timedjoin_np");
    if (!real_pthread_timedjoin_np) {
      printf("Symbol for pthread_timedjoin_np() is not found.\n");
      exit(1);
    }
  }

  ci_disable();
  int ret = real_pthread_timedjoin_np(__th, __thread_return, __abstime);
  ci_enable();
  return ret;
}


static int (*real_pthread_clockjoin_np) (pthread_t __th, void **__thread_return, clockid_t __clockid, const struct timespec *__abstime) = NULL;

int pthread_clockjoin_np (pthread_t __th, void **__thread_return, clockid_t __clockid, const struct timespec *__abstime) {

  if(!real_pthread_clockjoin_np) {
    real_pthread_clockjoin_np = dlsym(RTLD_NEXT, "pthread_clockjoin_np");
    if (!real_pthread_clockjoin_np) {
      printf("Symbol for pthread_clockjoin_np() is not found.\n");
      exit(1);
    }
  }

  ci_disable();
  int ret = real_pthread_clockjoin_np(__th, __thread_return, __clockid, __abstime);
  ci_enable();
  return ret;
}


static int (*real_pthread_mutex_lock)(pthread_mutex_t *mutex) = NULL;

int pthread_mutex_lock(pthread_mutex_t *mutex) {

  if(!real_pthread_mutex_lock) {
    real_pthread_mutex_lock = dlsym(RTLD_NEXT, "pthread_mutex_lock");
    if (!real_pthread_mutex_lock) {
      printf("Symbol for pthread_mutex_lock() is not found.\n");
      exit(1);
    }
  }

  ci_disable();
  int ret = real_pthread_mutex_lock(mutex);
  ci_enable();
  return ret;
}


#if 0
static int (*real_pthread_mutex_unlock)(pthread_mutex_t *mutex) = NULL;

int pthread_mutex_unlock(pthread_mutex_t *mutex) {

  if(!real_pthread_mutex_unlock) {
    real_pthread_mutex_lock = dlsym(RTLD_NEXT, "pthread_mutex_unlock");
    if (!real_pthread_mutex_unlock) {
      printf("Symbol for pthread_mutex_unlock() is not found.\n");
      exit(1);
    }
  }

  ci_disable();
  int ret = real_pthread_mutex_unlock(mutex);
  ci_enable();
  return ret;
}
#endif

static int (*real_pthread_mutex_timedlock)(pthread_mutex_t *restrict mutex, const struct timespec *restrict abs_timeout) = NULL;

int pthread_mutex_timedlock(pthread_mutex_t *restrict mutex, const struct timespec *restrict abs_timeout) {

  if(!real_pthread_mutex_timedlock) {
    real_pthread_mutex_timedlock = dlsym(RTLD_NEXT, "pthread_mutex_timedlock");
    if (!real_pthread_mutex_timedlock) {
      printf("Symbol for pthread_mutex_timedlock() is not found.\n");
      exit(1);
    }
  }

  ci_disable();
  int ret = real_pthread_mutex_timedlock(mutex, abs_timeout);
  ci_enable();
  return ret;
}


#if 0
static int (*real_pthread_cond_wait)(pthread_cond_t *cond, pthread_mutex_t *mutex) = NULL;

int pthread_cond_wait(pthread_cond_t *cond, pthread_mutex_t *mutex) {

  if(!real_pthread_cond_wait) {
    real_pthread_cond_wait = dlsym(RTLD_NEXT, "pthread_cond_wait");
    if (!real_pthread_cond_wait) {
      printf("Symbol for pthread_cond_wait() is not found.\n");
      exit(1);
    }
  }

  ci_disable();
  int ret = real_pthread_cond_wait(cond, mutex);
  ci_enable();
  return ret;
}
#endif


static int (*real_pthread_cond_timedwait)(pthread_cond_t *cond, pthread_mutex_t *mutex, const struct timespec *abstime) = NULL;

int pthread_cond_timedwait(pthread_cond_t *cond, pthread_mutex_t *mutex, const struct timespec *abstime) {

  if(!real_pthread_cond_timedwait) {
    real_pthread_cond_timedwait = dlsym(RTLD_NEXT, "pthread_cond_timedwait");
    if (!real_pthread_cond_timedwait) {
      printf("Symbol for pthread_cond_timedwait() is not found.\n");
      exit(1);
    }
  }

  ci_disable();
  int ret = real_pthread_cond_timedwait(cond, mutex, abstime);
  ci_enable();
  return ret;
}


static int (*real_pthread_barrier_wait)(pthread_barrier_t *barrier) = NULL;

int pthread_barrier_wait(pthread_barrier_t *barrier) {

  if(!real_pthread_barrier_wait) {
    real_pthread_barrier_wait = dlsym(RTLD_NEXT, "pthread_barrier_wait");
    if (!real_pthread_barrier_wait) {
      printf("Symbol for pthread_barrier_wait() is not found.\n");
      exit(1);
    }
  }

  ci_disable();
  int ret = real_pthread_barrier_wait(barrier);
  ci_enable();
  return ret;
}


static int (*real_pthread_spin_lock)(pthread_spinlock_t *lock) = NULL;

int pthread_spin_lock(pthread_spinlock_t *lock) {

  if(!real_pthread_spin_lock) {
    real_pthread_spin_lock = dlsym(RTLD_NEXT, "pthread_spin_lock");
    if (!real_pthread_spin_lock) {
      printf("Symbol for pthread_spin_lock() is not found.\n");
      exit(1);
    }
  }

  ci_disable();
  int ret = real_pthread_spin_lock(lock);
  ci_enable();
  return ret;
}


static int (*real_pthread_rwlock_rdlock)(pthread_rwlock_t *rwlock) = NULL;

int pthread_rwlock_rdlock(pthread_rwlock_t *rwlock) {

  if(!real_pthread_rwlock_rdlock) {
    real_pthread_rwlock_rdlock = dlsym(RTLD_NEXT, "pthread_rwlock_rdlock");
    if (!real_pthread_rwlock_rdlock) {
      printf("Symbol for pthread_rwlock_rdlock() is not found.\n");
      exit(1);
    }
  }

  ci_disable();
  int ret = real_pthread_rwlock_rdlock(rwlock);
  ci_enable();
  return ret;
}


static int (*real_pthread_rwlock_timedrdlock)(pthread_rwlock_t *restrict rwlock, const struct timespec *restrict abs_timeout) = NULL;

int pthread_rwlock_timedrdlock(pthread_rwlock_t *restrict rwlock, const struct timespec *restrict abs_timeout) {

  if(!real_pthread_rwlock_timedrdlock) {
    real_pthread_rwlock_timedrdlock = dlsym(RTLD_NEXT, "pthread_rwlock_timedrdlock");
    if (!real_pthread_rwlock_timedrdlock) {
      printf("Symbol for pthread_rwlock_timedrdlock() is not found.\n");
      exit(1);
    }
  }

  ci_disable();
  int ret = real_pthread_rwlock_timedrdlock(rwlock, abs_timeout);
  ci_enable();
  return ret;
}


static int (*real_pthread_rwlock_wrlock)(pthread_rwlock_t *rwlock) = NULL;

int pthread_rwlock_wrlock(pthread_rwlock_t *rwlock) {

  if(!real_pthread_rwlock_wrlock) {
    real_pthread_rwlock_wrlock = dlsym(RTLD_NEXT, "pthread_rwlock_wrlock");
    if (!real_pthread_rwlock_wrlock) {
      printf("Symbol for pthread_rwlock_wrlock() is not found.\n");
      exit(1);
    }
  }

  ci_disable();
  int ret = real_pthread_rwlock_wrlock(rwlock);
  ci_enable();
  return ret;
}


static int (*real_pthread_rwlock_timedwrlock)(pthread_rwlock_t *restrict rwlock, const struct timespec *restrict abs_timeout) = NULL; 

int pthread_rwlock_timedwrlock(pthread_rwlock_t *restrict rwlock, const struct timespec *restrict abs_timeout) {

  if(!real_pthread_rwlock_timedwrlock) {
    real_pthread_rwlock_timedwrlock = dlsym(RTLD_NEXT, "pthread_rwlock_timedwrlock");
    if (!real_pthread_rwlock_timedwrlock) {
      printf("Symbol for pthread_rwlock_timedwrlock() is not found.\n");
      exit(1);
    }
  }

  ci_disable();
  int ret = real_pthread_rwlock_timedwrlock(rwlock, abs_timeout);
  ci_enable();
  return ret;
}


static unsigned int (*real_sleep)(unsigned int seconds) = NULL;

unsigned int sleep(unsigned int seconds) {

  if(!real_sleep) {
    real_sleep = dlsym(RTLD_NEXT, "sleep");
    if (!real_sleep) {
      printf("Symbol for sleep() is not found.\n");
      exit(1);
    }
  }

  ci_disable();
  unsigned int ret = real_sleep(seconds);
  ci_enable();
  return ret;
}


#if 0
static ssize_t (*real_write)(int fd, const void *buf, size_t count) = NULL;

ssize_t write(int fd, const void *buf, size_t count) {
  //printf("write:chars#:%lu\n", count);

  real_write = dlsym(RTLD_NEXT, "write");
  if (!real_write) {
    printf("Symbol for write() is not found.\n");
    exit(1);
  }

  ci_disable();
  ssize_t ret = real_write(fd, buf, count);
  ci_enable();
  return ret;
}


static int (*real_puts)(const char* str) = NULL;

int puts(const char* str)
{
  //printf("puts:chars#:%lu\n", strlen(str));

  real_puts = dlsym(RTLD_NEXT, "puts");
  if (!real_puts) {
    printf("Symbol for puts() is not found.\n");
    exit(1);
  }

  ci_disable();
  int ret = real_puts(str);
  ci_enable();
  return ret;
}


//int open(const char *pathname, int flags);
//int openat(int dirfd, const char *pathname, int flags);
//int openat(int dirfd, const char *pathname, int flags, mode_t mode);
static int (*real_open)(const char *pathname, int flags, mode_t mode) = NULL;

int open(const char *pathname, int flags, mode_t mode) {

  real_open = dlsym(RTLD_NEXT, "open");
  if (!real_open) {
    printf("Symbol for open() is not found.\n");
    exit(1);
  }

  ci_disable();
  int ret = real_open(pathname, flags, mode);
  ci_enable();
  return ret;
}


//DIR *fdopendir(int fd);
static DIR* (*real_opendir)(const char *name) = NULL;

DIR *opendir(const char *name) {

  real_opendir = dlsym(RTLD_NEXT, "opendir");
  if (!real_opendir) {
    printf("Symbol for opendir() is not found.\n");
    exit(1);
  }

  ci_disable();
  DIR *ret = real_opendir(name);
  ci_enable();
  return ret;
}


static int (*real_strcmp)(const char *s1, const char *s2) = NULL;

int strcmp(const char *s1, const char *s2) {

  real_strcmp = dlsym(RTLD_NEXT, "strcmp");
  if (!real_strcmp) {
    printf("Symbol for strcmp() is not found.\n");
    exit(1);
  }

  ci_disable();
  int ret = real_strcmp(s1, s2);
  ci_enable();
  return ret;
}


static char* (*real_strcpy)(char *dest, const char *src) = NULL;

char *strcpy(char *dest, const char *src) {

  real_strcpy = dlsym(RTLD_NEXT, "strcpy");
  if (!real_strcpy) {
    printf("Symbol for strcpy() is not found.\n");
    exit(1);
  }

  ci_disable();
  char *ret = real_strcpy(dest, src);
  ci_enable();
  return ret;
}


static size_t (*real_strlen)(const char *s) = NULL;

size_t strlen(const char *s) {

  real_strlen = dlsym(RTLD_NEXT, "strlen");
  if (!real_strlen) {
    printf("Symbol for strlen() is not found.\n");
    exit(1);
  }

  ci_disable();
  size_t ret = real_strlen(s);
  ci_enable();
  return ret;
}


static int (*real_close)(int fd) = NULL;

int close(int fd) {

  real_close = dlsym(RTLD_NEXT, "close");
  if (!real_close) {
    printf("Symbol for close() is not found.\n");
    exit(1);
  }

  ci_disable();
  int ret = real_close(fd);
  ci_enable();
  return ret;
}


static int (*real_closedir)(DIR *dirp) = NULL;

int closedir(DIR *dirp) {

  real_closedir = dlsym(RTLD_NEXT, "closedir");
  if (!real_closedir) {
    printf("Symbol for closedir() is not found.\n");
    exit(1);
  }

  ci_disable();
  int ret = real_closedir(dirp);
  ci_enable();
  return ret;
}


static struct dirent* (*real_readdir)(DIR *dirp) = NULL;

struct dirent *readdir(DIR *dirp) {

  real_readdir = dlsym(RTLD_NEXT, "readdir");
  if (!real_readdir) {
    printf("Symbol for readdir() is not found.\n");
    exit(1);
  }

  ci_disable();
  struct dirent *ret = real_readdir(dirp);
  ci_enable();
  return ret;
}


static int (*real_pthread_spin_init)(pthread_spinlock_t *lock, int pshared) = NULL;

int pthread_spin_init(pthread_spinlock_t *lock, int pshared) {

  real_pthread_spin_init = dlsym(RTLD_NEXT, "pthread_spin_init");
  if (!real_pthread_spin_init) {
    printf("Symbol for pthread_spin_init() is not found.\n");
    exit(1);
  }

  ci_disable();
  int ret = real_pthread_spin_init(lock, pshared);
  ci_enable();
  return ret;
}


static int (*real_pthread_mutex_init)(pthread_mutex_t *mutex,
    const pthread_mutexattr_t *attr) = NULL;

int pthread_mutex_init(pthread_mutex_t *mutex,
    const pthread_mutexattr_t *attr) {

  real_pthread_mutex_init = dlsym(RTLD_NEXT, "pthread_mutex_init");
  if (!real_pthread_mutex_init) {
    printf("Symbol for pthread_mutex_init() is not found.\n");
    exit(1);
  }

  ci_disable();
  int ret = real_pthread_mutex_init(mutex, attr);
  ci_enable();
  return ret;
}


static void* (*real_memcpy)(void *dest, const void *src, size_t n) = NULL;

void *memcpy(void *dest, const void *src, size_t n) {

  real_memcpy = dlsym(RTLD_NEXT, "memcpy");
  if (!real_memcpy) {
    printf("Symbol for memcpy() is not found.\n");
    exit(1);
  }

  ci_disable();
  void *ret = real_memcpy(dest, src, n);
  ci_enable();
  return ret;
}


static int (*real_sprintf)(char *str, const char *format, ...) = NULL;

int sprintf(char *str, const char *format, ...) {

  real_sprintf = dlsym(RTLD_NEXT, "sprintf");
  if (!real_sprintf) {
    printf("Symbol for sprintf() is not found.\n");
    exit(1);
  }

  ci_disable();
  int ret = real_sprintf(str, format, varargs);
  ci_enable();
  return ret;
}


static void* (*real_malloc)( size_t size ) = NULL;

void* malloc( size_t size ) {

  if (!real_malloc) {
    real_malloc = dlsym(RTLD_NEXT, "malloc");

    if (!real_malloc) {
      printf("Symbol for malloc() is not found.\n");
      exit(1);
    }
  }

  ci_disable();
  void *ret = real_malloc(size);
  ci_enable();
  return ret;
}


static void* (*real_mmap)(void *addr, size_t length, int prot, int flags,
                  int fd, off_t offset) = NULL;

void *mmap(void *addr, size_t length, int prot, int flags,
                  int fd, off_t offset) {

  real_mmap = dlsym(RTLD_NEXT, "mmap");
  if (!real_mmap) {
    printf("Symbol for mmap() is not found.\n");
    exit(1);
  }

  ci_disable();
  //void *ret = real_mmap(addr, length, prot, flags | MAP_POPULATE, fd, offset);
  void *ret = real_mmap(addr, length, prot, flags, fd, offset);
  ci_enable();
  return ret;
}
#endif

