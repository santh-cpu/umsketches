CXX = /usr/bin/clang++
CXXFLAGS = -std=c++17 -Wall -fPIC
LDFLAGS = -dynamiclib -framework Metal -framework Foundation -lobjc

SRC_CORE = src/core/validator.cpp
SRC_INJECTOR = src/injector/hook.mm
SRC_UTILS = src/utils/logger.cpp
SRC_SHAD = src/core/shadowtable.cpp

TARGET = libums.dylib

all: clean $(TARGET)

$(TARGET):
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $(SRC_SHAD) $(SRC_CORE) $(SRC_INJECTOR) $(SRC_UTILS) -o $(TARGET)

clean:
	rm -f $(TARGET)
