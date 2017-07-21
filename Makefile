#
# Basic Makefile for AVR template project
# (C) 2014 Sergey Shcherbakov <shchers@gmail.com>
#

ifeq ($(shell which avr-gcc),)
$(error Please install avr-gcc package)
endif

ifeq ($(shell which avrdude),)
$(error Please install avrdude package)
endif

# Change MCU type accordingly to installed in your board
MCU := atmega328p

# Frequency of MCU in Hz
F_CPU := 16000000

# Fuses
EFUSE := 0xfd
HFUSE := 0xd3
LFUSE := 0xff

# List of sources that used in project
C_SRC := \
	main.c

# Firmware name
BIN := avr_tmp

# Path of current project
TOP := $(shell pwd)

# Output folder for all binaries
BUILD_OUTPUT ?= $(TOP)/bin

# Objects output dir
OBJDIR := $(BUILD_OUTPUT)/objs

# List of objects
OBJS := $(addprefix $(OBJDIR)/,$(C_SRC:.c=.o))

CFLAGS := -DF_CPU=$(F_CPU)UL
# Compiler options
CFLAGS += -mmcu=$(MCU) -gdwarf-2 -std=gnu99
# Compiler optimization
CFLAGS += -Os
# C Dialect options
CFLAGS += -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums
# Warning options
CFLAGS += -Wall -Wstrict-prototypes
# Includes
CFLAGS += -I ./

# Libs
LDFLAGS := -lm

# --- Programmer options ---

# ISP bitclock
BITCLOCK := 4MHz

# --- Targets ---

.PHONY: all firmware flash fuses clean

all: firmware

clean:
	@rm -vrf $(BUILD_OUTPUT)

fuses:
	@dialog --yesno "Do you really want to flash FUSES?" 0 0
	@avrdude -p $(MCU) -c avrispmkII -P usb -B $(BITCLOCK) -U efuse:w:$(EFUSE):m -U hfuse:w:$(HFUSE):m -U lfuse:w:$(LFUSE):m

mkdirs:
	@mkdir -p $(BUILD_OUTPUT)
	@mkdir -p $(OBJDIR)

$(OBJDIR)/%.o : %.c
	@echo "\\033[33m--- Building $< ---\\033[0m"
	@avr-gcc $(CFLAGS) -c $< -o $@

$(BUILD_OUTPUT)/$(BIN).elf: mkdirs $(OBJS)
	@echo "\\033[1;37;42m--- Linking $(@) ---\\033[0m"
	@avr-gcc $(CFLAGS) $(OBJS) --output $(@) -Wl,-Map=$(BUILD_OUTPUT)/$(BIN).map,--cref $(LDFLAGS)
# Creating load file for Flash
	@avr-objcopy -O ihex -R .eeprom -R .fuse -R .lock -R .signature $(@) $(BUILD_OUTPUT)/$(BIN).hex
# Creating load file for EEPROM
	@avr-objcopy -j .eeprom --set-section-flags=.eeprom="alloc,load" --change-section-lma .eeprom=0 --no-change-warnings -O ihex $(@) $(BUILD_OUTPUT)/$(BIN).eep
# Just print size
	@avr-size --format=avr --mcu=$(MCU) -C $(@)

firmware: $(BUILD_OUTPUT)/$(BIN).elf

flash: firmware
	@avrdude -p $(MCU) -c avrispmkII -P usb -B $(BITCLOCK) -U flash:w:$(BUILD_OUTPUT)/$(BIN).hex
