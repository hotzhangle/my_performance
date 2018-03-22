GXX=g++
CC=gcc
CXXFLAGS =  -O2 -g -Wall -fmessage-length=0 -std=c++11
#################################################################################
#--------------------------------------------------------------------------------
#################################################################################
# 义项目代码根目录及所有文件夹目录
SRC_DIR = src
VPATH = $(SRC_DIR)

OUTPUT_DIR = debug
_OBJ_DIR = obj
_EXE_DIR = bin
OBJ_DIR = $(OUTPUT_DIR)/$(_OBJ_DIR)
EXE_DIR = $(OUTPUT_DIR)/$(_EXE_DIR)

# 列出所有的.cpp文件和相应的.o文件（带目录)
SRC_FILES = $(foreach n,$(VPATH),$(wildcard $(n)/*.cpp))
$(info, $(SRC_FILES))
# 将所有的.o文件放到定义好的输出文件夹中统一管理 建立存放.o文件的目录结构
$(shell mkdir -p "$(OBJ_DIR)")
$(shell mkdir -p "$(EXE_DIR)")
# $(patsubst pattern ,replacement ,text)
OBJ_FILES = $(patsubst $(SRC_DIR)/%.cpp,$(OBJ_DIR)/%.o,$(SRC_FILES))
################################################################################
#-------------------------------------------------------------------------------
################################################################################

TARGET = $(EXE_DIR)/main

all: $(TARGET)

$(TARGET):$(OBJ_FILES)
	$(GXX) $(CXXFLAGS) -o $@ $^ #$(TARGET) $(OBJS) $(LIBS)

$(OBJ_FILES):$(SRC_FILES)
	$(GXX) -c $(CXXFLAGS) -o $@ $<

.PYONY:clean
clean:
	-rm -rf  $(TARGET) $(OBJ_FILES) $(OUTPUT_DIR) $(TARGET)
