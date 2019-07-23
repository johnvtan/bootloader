BL_TARGET := boot

BL_DIR := src
OBJ_DIR := objs
BIN_DIR := bin

BL_SRC := $(wildcard $(BL_DIR)/*.s) 
BL_OBJS := $(patsubst $(BL_DIR)/%.s, $(OBJ_DIR)/%.o, $(BL_SRC))

NASM := nasm
NASM_FLAGS := -f elf -g -F dwarf

LD := ld
LD_FLAGS := -M -m elf_i386 -T link.ld

OBJCOPY := objcopy

QEMU := qemu-system-x86_64
QEMU_FLAGS := -monitor stdio

all: dirs build

dirs:
	mkdir -p $(OBJ_DIR) $(BIN_DIR)

clean:
	rm -rf $(OBJ_DIR) $(BIN_DIR)

build: $(BL_OBJS)
	$(LD) $(LD_FLAGS) $(BL_OBJS) -o $(BIN_DIR)/$(KERN_TARGET).elf > $(OBJ_DIR)/$(KERN_TARGET).map
	$(OBJCOPY) -O binary $(BIN_DIR)/$(KERN_TARGET).elf $(BIN_DIR)/$(KERN_TARGET).bin

$(OBJ_DIR)/%.o: $(BL_DIR)/%.s
	$(NASM) $(NASM_FLAGS) $< -o $@  

run: all 
	$(QEMU) $(QEMU_FLAGS) -fda $(BIN_DIR)/$(KERN_TARGET).bin

debug: all
	$(QEMU) $(QEMU_FLAGS) -s -S -fda $(BIN_DIR)/$(KERN_TARGET).bin
