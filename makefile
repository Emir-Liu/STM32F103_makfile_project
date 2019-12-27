
TARGET = test_project

PREFIX	= arm-none-eabi-
CC			= $(PREFIX)gcc
AS			= $(PREFIX)as
LD			= $(PREFIX)ld
OBJCOPY	= $(PREFIX)objcopy

#读取当前工作目录
TOP=$(shell pwd)

#include头文件
INC_FLAGS= -I $(TOP)/CORE                  	\
           -I $(TOP)/HARDWARE    						\
           -I $(TOP)/STM32F10x_FWLib/inc  	\
           -I $(TOP)/SYSTEM        					\
           -I $(TOP)/USER

#GCC选项
# -W -Wall				:开启警报
# -g							:产生调试信息，用于产生.elf调试文件
# mcpu=cortex-m3	:用于设定芯片内核参数
# -mthumb					:表明使用的指令集
# -D STM32F10X_MD -D USE_STDPERIPH_DRIVER	:宏定义
# -O0							:优化等级有O0,O1,O2等
# -std=gnu11			:设定语言标准GNU11,当然可以换为C98等
CFLAGS =  -W -Wall -g -mcpu=cortex-m3 -mthumb -D STM32F10X_MD -D USE_STDPERIPH_DRIVER $(INC_FLAGS) -O0 -std=gnu11
ASFLAGS = -W -Wall -g -mcpu=cortex-m3 -mthumb 

#搜索并返回当前路径下的所有.c文件的集合
#将C_SRC包含的文件的.c后缀代替为.o文件
C_SRC=$(shell find ./ -name '*.c')  
C_OBJ=$(C_SRC:%.c=%.o)

ASM_SRC=$(shell find ./ -name '*.s')
ASM_OBJ=$(ASM_SRC:%.s=%.o)

#.PHONY关键字，代表后面的执行对象，不是文件
.PHONY: all clean update 

#all的依赖对象是$(C_OBJ)和$(ASM_OBJ),一个变量是以.c或.s为后缀文件替换为.o为后缀的文件的集合，如果.o文件修改则更新all。
all:$(C_OBJ) $(ASM_OBJ)
	$(CC) $(C_OBJ) $(ASM_OBJ) -T stm32_flash.ld -o $(TARGET).elf   -mthumb -mcpu=cortex-m3 -Wl,--start-group -lc -lm -Wl,--end-group -specs=nano.specs -specs=nosys.specs -static -Wl,-cref,-u,Reset_Handler -Wl,-Map=Project.map -Wl,--gc-sections -Wl,--defsym=malloc_getpagesize_P=0x80 
#通过.elf文件，生成.bin和.hex文件
	$(OBJCOPY) $(TARGET).elf  $(TARGET).bin -Obinary 
	$(OBJCOPY) $(TARGET).elf  $(TARGET).hex -Oihex

#.o文件依赖于.o文件
#其中 $@:目标文件 $^:所有依赖文件 $<:第一个依赖文件
$(C_OBJ):%.o:%.c
	$(CC) -c $(CFLAGS) -o $@ $<

#$(ASM_OBJ):%.o:%.c
#	$(AS) -c $(ASFLAGS) -o $@ $<
$(ASM_OBJ): $(ASM_SRC)
	$(AS) -c $(ASFLAGS) -o $@ $<

clean:
	rm -f $(shell find ./ -name '*.o')
	rm -f $(shell find ./ -name '*.d')
	rm -f $(shell find ./ -name '*.map')
	rm -f $(shell find ./ -name '*.elf')
	rm -f $(shell find ./ -name '*.bin')
	rm -f $(shell find ./ -name '*.hex')

update:
	openocd -f /usr/share/openocd/scripts/interface/stlink-v2.cfg  -f /usr/share/openocd/scripts/target/stm32f1x_stlink.cfg -c init -c halt -c "flash write_image erase $(TOP)/LED_project.hex" -c reset -c shutdown
 


 










