# Project template for development board STM32F0Discovery
# Uses libraries HAL, which are placed in dedicated
# directory (where is also Makefile for them)
# Andrej Bendzo  <andrej.sl@azet.sk>
# 2016.08.11
######################################################

# This Makefile contains rule "flash", which is intended for writing of program into MCU,
# rule "erase" for erasing Flash memory of MCU
# and rule "reset" for system resetting of MCU.




#  *****  Basic settings of project  *****
# ==============================================================================

# all the files will be generated with this name (main.elf, main.bin, main.hex, etc)
PROJECT_NAME = l4template
TARGET = $(PROJECT_NAME).elf

# list of source files
#SRCS = main.c stm32f0xx_it.c system_stm32f0xx.c stm32f0xx_hal_msp.c
SRCS = main.c stm32l4xx_it.c system_stm32l4xx.c stm32l4xx_hal_msp.c

# ==============================================================================


# Directory with source files
#SRCDIR = src/f0
SRCDIR = src/l4

# Directory with header files
#INCDIR = inc/f0
INCDIR = inc/l4

# Directory with binary files
BINDIR = bin

# Directory with object files
OBJDIR = obj

# Directory with dependency files
DEPDIR = dep

# Location of the Libraries directory from the STM32F0xx HAL Peripheral Library
PERIPH_LIB = Libraries


# used programs:
CC = arm-none-eabi-gcc
GDB = arm-none-eabi-gdb
OBJCOPY = arm-none-eabi-objcopy
OBJDUMP = arm-none-eabi-objdump
SIZE = arm-none-eabi-size


# Compilation settings:
CFLAGS  = -std=gnu11 -Os
CFLAGS += -mlittle-endian -mcpu=cortex-m4 -mthumb
CFLAGS += -Wall -Wstrict-prototypes -fsingle-precision-constant
CFLAGS += -ffunction-sections -fdata-sections

# defining used MCU (instead of in file stm32f00x.h): -DSTM32F051x8
CFLAGS += -I$(INCDIR)
CFLAGS += -I$(PERIPH_LIB)
CFLAGS += -I$(PERIPH_LIB)/CMSIS/Include
#CFLAGS += -I$(PERIPH_LIB)/CMSIS/ST/STM32F0xx/Include
CFLAGS += -I$(PERIPH_LIB)/CMSIS/ST/STM32L4xx/Include
#CFLAGS += -I$(PERIPH_LIB)/STM32F0xx_HAL_Driver/Inc
CFLAGS += -I$(PERIPH_LIB)/STM32L4xx_HAL_Driver/Inc
#CFLAGS += -I$(PERIPH_LIB)/STM32F0xx_HAL_Driver/Inc/Legacy
CFLAGS += -I$(PERIPH_LIB)/STM32L4xx_HAL_Driver/Inc/Legacy
CFLAGS += -DUSE_HAL_DRIVER # to include file stm32l4xx_hal.h


# Settings of linker
LDFLAGS =  -mcpu=cortex-m4 -mthumb
LDFLAGS += -Wl,--gc-sections -Wl,-Map=$(BINDIR)/$(PROJECT_NAME).map,--cref,--no-warn-mismatch


vpath %.a $(PERIPH_LIB)


# startup file for MCU
#STARTUP = $(SRCDIR)/startup_stm32f051x8.s
STARTUP = $(SRCDIR)/startup_stm32l476xx.s

# generating of object files and dependencies
OBJS = $(addprefix $(OBJDIR)/,$(SRCS:.c=.o))
DEPS = $(addprefix $(DEPDIR)/,$(SRCS:.c=.d))


.PHONY: all library flash erase reset clean entireclean display

all: dirs library $(BINDIR)/$(TARGET) $(BINDIR)/$(PROJECT_NAME).hex $(BINDIR)/$(PROJECT_NAME).lst size

library:
	make -C $(PERIPH_LIB)

dirs:
	mkdir -p $(DEPDIR) $(OBJDIR) $(BINDIR)

display:
	@echo 'SRCS = $(SRCS)'
	@echo 'OBJS = $(OBJS)'


## Compile:
# independent rule for every source file
$(OBJDIR)/main.o : $(SRCDIR)/main.c
	$(CC) $(CFLAGS) -MMD -MF $(DEPDIR)/$(*F).d -c $(SRCDIR)/main.c -o $@

#$(OBJDIR)/stm32f0xx_it.o : $(SRCDIR)/stm32f0xx_it.c $(INCDIR)/stm32f0xx_it.h
#	$(CC) $(CFLAGS) -MMD -MF $(DEPDIR)/$(*F).d -c $(SRCDIR)/stm32f0xx_it.c -o $@
$(OBJDIR)/stm32l4xx_it.o : $(SRCDIR)/stm32l4xx_it.c $(INCDIR)/stm32l4xx_it.h
	$(CC) $(CFLAGS) -MMD -MF $(DEPDIR)/$(*F).d -c $(SRCDIR)/stm32l4xx_it.c -o $@

#$(OBJDIR)/system_stm32f0xx.o : $(SRCDIR)/system_stm32f0xx.c
#	$(CC) $(CFLAGS) -MMD -MF $(DEPDIR)/$(*F).d -c $(SRCDIR)/system_stm32f0xx.c -o $@
$(OBJDIR)/system_stm32l4xx.o : $(SRCDIR)/system_stm32l4xx.c
	$(CC) $(CFLAGS) -MMD -MF $(DEPDIR)/$(*F).d -c $(SRCDIR)/system_stm32l4xx.c -o $@

#$(OBJDIR)/stm32f0xx_hal_msp.o : $(SRCDIR)/stm32f0xx_hal_msp.c
#	$(CC) $(CFLAGS) -MMD -MF $(DEPDIR)/$(*F).d -c $(SRCDIR)/stm32f0xx_hal_msp.c -o $@
$(OBJDIR)/stm32l4xx_hal_msp.o : $(SRCDIR)/stm32l4xx_hal_msp.c
	$(CC) $(CFLAGS) -MMD -MF $(DEPDIR)/$(*F).d -c $(SRCDIR)/stm32l4xx_hal_msp.c -o $@


## Link:
#$(BINDIR)/$(TARGET): $(OBJS)
#	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@ $(STARTUP) -L$(PERIPH_LIB) -lstm32f0 -TSTM32F051R8_FLASH.ld
$(BINDIR)/$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@ $(STARTUP) -L$(PERIPH_LIB) -lstm32l4 -TSTM32L476RG.ld

## Post-build steps:
$(BINDIR)/$(PROJECT_NAME).hex: $(BINDIR)/$(TARGET)
	$(OBJCOPY) -O ihex $(BINDIR)/$(TARGET) $@

#$(BINDIR)/$(PROJECT_NAME).bin: $(BINDIR)/$(TARGET)
#	$(OBJCOPY) -O binary $(BINDIR)/$(TARGET) $@

$(BINDIR)/$(PROJECT_NAME).lst: $(BINDIR)/$(TARGET)
	$(OBJDUMP) -St $(BINDIR)/$(TARGET) > $@

size: $(BINDIR)/$(TARGET)
	@echo 'size $<'
	@$(SIZE) -B $(BINDIR)/$(TARGET)
	@echo


flash:
	openocd -f board/stm32f0discovery.cfg -c "program $(BINDIR)/$(PROJECT_NAME).hex verify reset exit"
#second approach:	openocd -f board/stm32f0discovery.cfg -c "init" -c "reset halt" -c "flash write_image erase $(BINDIR)/$(PROJECT_NAME).hex" -c "verify_image $(BINDIR)/$(PROJECT_NAME).hex" -c "reset run" -c "exit"
#third approach:	openocd -f interface/stlink-v2.cfg -f target/stm32f0x_stlink.cfg -c "init" -c "reset halt" -c "flash write_image erase $(BINDIR)/$(PROJECT_NAME).hex" -c "verify_image $(BINDIR)/$(PROJECT_NAME).hex" -c "reset run" -c "exit"

#erase:
#	openocd -f board/stm32f0discovery.cfg -c "init" -c "reset halt" -c "stm32f0x mass_erase 0" -c "reset" -c "shutdown"
erase:
	openocd -f board/stm32f0discovery.cfg -c "init" -c "reset halt" -c "stm32l4x mass_erase 0" -c "reset" -c "shutdown"

reset:
	openocd -f board/stm32f0discovery.cfg -c "init" -c "reset" -c "shutdown"

clean:
	rm -f $(OBJDIR)/*.o $(DEPDIR)/*.d
	rm -f $(BINDIR)/$(PROJECT_NAME).elf $(BINDIR)/$(PROJECT_NAME).hex $(BINDIR)/$(PROJECT_NAME).bin $(BINDIR)/$(PROJECT_NAME).map $(BINDIR)/$(PROJECT_NAME).lst

entireclean: clean
	make -C $(PERIPH_LIB) clean
