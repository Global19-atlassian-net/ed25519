SGX_SDK ?= /opt/intel/sgxsdk

C_Flags := -O2 -fpic -I.

SGX_C_Flags := -Wno-implicit-function-declaration -std=c11 -m64 -O2 -nostdinc -DSGX_COMPAT -fpie -fstack-protector \
	-IInclude -I. -I$(SGX_SDK)/include -I$(SGX_SDK)/include/tlibc -I$(SGX_SDK)/include/libcxx -fno-builtin-printf -I.

C_Files := $(wildcard src/*.c)

OUT := out

SGX_OBJ := sgxobj
SGX_C_Objects := $(C_Files:src/%.c=$(SGX_OBJ)/%.o)

NONSGX_OBJ := nonsgxobj
NONSGX_C_Objects := $(C_Files:src/%.c=$(NONSGX_OBJ)/%.o)

.PHONY: all run
all: $(OUT)/libed25519.sgx.static.a $(OUT)/libed25519.static.a
run: all

$(SGX_OBJ)/%.o: src/%.c
	@echo "CC  <=  $<"
	@mkdir -p $(SGX_OBJ)
	$(CC) $(SGX_C_Flags) -c $< -o $@

$(NONSGX_OBJ)/%.o: src/%.c
	@echo "CC  <=  $<"
	@mkdir -p $(NONSGX_OBJ)
	$(CC) $(C_Flags) -c $< -o $@

$(OUT)/libed25519.sgx.static.a: $(SGX_C_Objects)
	@mkdir -p $(OUT)
	ar rcs $@ $(SGX_C_Objects)

$(OUT)/libed25519.static.a: $(NONSGX_C_Objects)
	@mkdir -p $(OUT)
	ar rcs $@ $(SGX_C_Objects)

clean:
	@rm -rf $(SGX_OBJ) $(NONSGX_OBJ) $(OUT)
