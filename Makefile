# ==========================================
# OpenGL Engine Style Makefile
# ==========================================

# Compiladores
CXX := g++
CC  := gcc

# Projeto
APP := executavel_jogo

# Diretórios
SRC_DIR := src
OBJ_DIR := build
BIN_DIR := bin
INC_DIR := include
LIB_DIR := lib

# Sistema operacional
UNAME := $(shell uname)

# Arquivos fonte
CPP_SRC := $(wildcard $(SRC_DIR)/*.cpp)
C_SRC   := $(SRC_DIR)/glad.c

CPP_OBJ := $(patsubst $(SRC_DIR)/%.cpp,$(OBJ_DIR)/%.o,$(CPP_SRC))
C_OBJ   := $(OBJ_DIR)/glad.o

OBJS := $(CPP_OBJ) $(C_OBJ)

TARGET := $(BIN_DIR)/$(APP)

# ==========================================
# Build mode
# ==========================================

MODE ?= release

ifeq ($(MODE),debug)
CXXFLAGS := -std=c++17 -Wall -Wextra -g -O0
else
CXXFLAGS := -std=c++17 -Wall -Wextra -O2
endif

CXXFLAGS += -I$(INC_DIR)
CFLAGS   := -I$(INC_DIR)

# ==========================================
# GLFW detection
# ==========================================

GLFW_CFLAGS := $(shell pkg-config --cflags glfw3 2>/dev/null)
GLFW_LIBS   := $(shell pkg-config --libs glfw3 2>/dev/null)

ifeq ($(GLFW_LIBS),)
GLFW_LIBS := -L$(LIB_DIR) -lglfw3
endif

# ==========================================
# Platform specific libs
# ==========================================

ifeq ($(UNAME),Linux)
SYS_LIBS := -lGL -lX11 -lpthread -lXrandr -lXi -ldl
endif

ifeq ($(UNAME),Darwin)
SYS_LIBS := -framework OpenGL -framework Cocoa -framework IOKit
endif

LIBS := $(GLFW_LIBS) $(SYS_LIBS)

# ==========================================
# Parallel build
# ==========================================

JOBS := $(shell nproc 2>/dev/null || sysctl -n hw.ncpu)

# ==========================================
# Targets
# ==========================================

all: $(TARGET)

$(TARGET): $(OBJS)
	@mkdir -p $(BIN_DIR)
	@echo "[LINK] $(APP)"
	$(CXX) $(OBJS) $(LIBS) -o $(TARGET)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	@mkdir -p $(OBJ_DIR)
	@echo "[CXX] $<"
	$(CXX) $(CXXFLAGS) $(GLFW_CFLAGS) -c $< -o $@

$(OBJ_DIR)/glad.o: $(SRC_DIR)/glad.c
	@mkdir -p $(OBJ_DIR)
	@echo "[CC] $<"
	$(CC) $(CFLAGS) -c $< -o $@

run: all
	./$(TARGET)

clean:
	rm -rf $(OBJ_DIR) $(BIN_DIR)
	@echo "[CLEAN] Done"

rebuild: clean all

# build paralelo
fast:
	$(MAKE) -j$(JOBS)

.PHONY: all run clean rebuild fast
