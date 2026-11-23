# Lab 01 - "Eres el hardware"          Linux / macOS (y Windows con MSYS2/MinGW)
#
#   make plugin    compila plugin/lab01_plugin.cpp -> plugin/lab01_plugin.so (.dylib / .dll)
#   make check     compila el plugin y ejecuta todas las pruebas (./check.sh)
#   make clean     borra el plugin compilado
#
# Para elegir otro compilador:  make CXX=clang++ plugin

CXX      ?= g++
CXXFLAGS ?= -std=c++17 -O2 -Wall -Wextra

UNAME_S := $(shell uname -s 2>/dev/null)
ifeq ($(UNAME_S),Darwin)
  EXT    = dylib
  SHARED = -dynamiclib
else ifneq (,$(or $(findstring MINGW,$(UNAME_S)),$(findstring MSYS,$(UNAME_S))))
  EXT    = dll
  SHARED = -shared -static-libgcc -static-libstdc++
else
  EXT    = so
  SHARED = -shared -fPIC
endif

PLUGIN = plugin/lab01_plugin.$(EXT)

.PHONY: plugin check clean

plugin: $(PLUGIN)

$(PLUGIN): plugin/lab01_plugin.cpp include/easm.h
	$(CXX) $(CXXFLAGS) $(SHARED) -I include -o $@ $<

check: plugin
	./check.sh

clean:
	rm -f plugin/lab01_plugin.so plugin/lab01_plugin.dylib plugin/lab01_plugin.dll
