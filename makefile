# Makefile for building the standard c-library math for userspace
#

# Include all the definitions for os
include ../../config/common.mk

MVCS_SRCS = 
SOURCES = $(wildcard lib/builtins/*.c)
INCLUDES = -I../include -I../libc/include

# Setup architecture specific flags and paths
ifeq ($(VALI_ARCH), i386)
	math_flags = -D_HAVE_LONG_DOUBLE -D_LDBL_EQ_DBL
	ASFLAGS = -f win32 -Xvc
	ASM_SRCS = $(wildcard lib/builtins/i386/*.S)
	MVCS_SRCS += $(wildcard lib/msvc/*.s)
else ifeq ($(VALI_ARCH), amd64)
	math_flags = -D_HAVE_LONG_DOUBLE -D__x86_64__
	ASFLAGS = -f win64 -Xvc
	ASM_SRCS = $(wildcard lib/builtins/x86_64/*.S)
	SOURCES += $(wildcard lib/builtins/x86_64/*.c)
else
$(error VALI_ARCH is not set to a valid value)
endif

OBJECTS = $(ASM_SRCS:.S=.o) $(MVCS_SRCS:.s=.o) $(SOURCES:.c=.o)

CFLAGS = $(GCFLAGS) $(math_flags) $(INCLUDES)
LFLAGS = /lib

.PHONY: all
all: ../build/compiler-rt.lib

../build/compiler-rt.lib: $(OBJECTS)
	@printf "%b" "\033[0;36mCreating static library " $@ "\033[m\n"
	@$(LD) $(LFLAGS) $(OBJECTS) /out:$@

%.o : %.c
	@printf "%b" "\033[0;32mCompiling C source object " $< "\033[m\n"
	@$(CC) -c $(CFLAGS) -o $@ $<

%.o : %.S
	@printf "%b" "\033[0;32mAssembling source object " $< "\033[m\n"
	@$(CC) -c $(CFLAGS) -o $@ $<

%.o : %.s
	@printf "%b" "\033[0;32mAssembling source object " $< "\033[m\n"
	@$(AS) $(ASFLAGS) $< -o $@

.PHONY: clean
clean:
	@rm -f ../build/compiler-rt.lib
	@rm -f $(OBJECTS)