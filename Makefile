#----------------------------------------------------------------------------------------
# Quite universal Makefile for AVR MCUs
# Works under Linux and Windows Power Shell
#
# created by Michal Kaptur (2014)
# @ kaptur.michal at gmail
#----------------------------------------------------------------------------------------



#----------------------------------------------------------------------------------------
#Project specific settings

TARGET_GCC=atmega32
TARGET_DUDE=m32
FCPU=8000000UL
INCLUDES_DIR=..\libs\mklib_1wire

#----------------------------------------------------------------------------------------
#Programmer settings
UPLOADER=avrdude
PORT=avrdoper
PROGRAMMER=stk500v2

#----------------------------------------------------------------------------------------
#Universal settings

CXX=avr-gcc

OUTPUT=$(shell basename $(CURDIR))
#define, macros
DFLAGS=-DF_CPU=$(FCPU)
#includes
INCLUDES=-I$(INCLUDES_DIR)
#other parameters for compilation
CXX_PARAMS=-std=c99



#----------------------------------------------------------------------------------------
#Actual makefile
#----------------------------------------------------------------------------------------


build:
	@`mkdir -p bin`
	@echo -e "\e[32mCompiling...\e[39m"
#	FIXME: move source names to variable
	$(CXX) .\ds18b20.c .\main.c ..\libs\mklib_1wire\mklib_1wire.c .\usart.c -O2 -mmcu=$(TARGET_GCC) $(CXX_PARAMS) $(INCLUDES) $(DFLAGS) -o .\bin\$(OUTPUT).elf
	@echo -e "\t\e[32m done.\e[39m"
	@echo -e "\n\e[32m Creating hex file...\e[39m"
	avr-objcopy.exe -j .text -j .data -O ihex .\bin\$(OUTPUT).elf .\bin\$(OUTPUT).hex
	@echo -e "\t\e[32m done.\e[39m"

run: build
	@echo -e "\n\e[32m Uploading hex file...\e[39m"
	$(UPLOADER) -P $(PORT) -c $(PROGRAMMER) -p$(TARGET_DUDE) -U flash:w:.\bin\$(OUTPUT).hex
	
clean:
	rm -rf *.elf
	rm -rf *.hex
	rm -rf .\bin
	@echo -e "\t\n \e[32m cleaned up.\e[39m"
	
	
print_mcu_names:
	@echo -e "\e[32m Names for TARGET_GCC\e[39m"
	-avr-as -mx
	@echo -e "\n\e[32m Names for TARGET_DUDE\e[39m"
	-$(UPLOADER) -P $(PORT) -c $(PROGRAMMER)
	@echo -e "\n\e[32m Don't care about these 'error' above, it's a simple way to get target names listed.\e[39m"