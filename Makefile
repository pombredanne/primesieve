##############################################################################
# Makefile for primesieve (console version)
#
# Author:          Kim Walisch
# Contact:         kim.walisch@gmail.com
# Created:         10 July 2010 
# Last modified:   26 May 2011
#
# Project home:    http://primesieve.googlecode.com
##############################################################################

TARGET = primesieve
SRCDIR = soe
MAINDIR = console
OUTDIR = out
CXX = g++

# Oracle Solaris Studio (former Sun Studio)
ifeq ($(CXX),sunCC)
  $(warning sunCC: you might need to set OMP_NUM_THREADS to use OpenMP)
  CXXFLAGS += +w -fast -xopenmp -xipo -xrestrict -xalias_level=compatible

# Intel C++ Compiler
else ifeq ($(CXX),icpc)
  CXXFLAGS += -Wall -openmp -fast

# GCC, the GNU Compiler Collection
else ifneq ($(shell $(CXX) --version 2>&1 | head -1 | grep -iE 'GCC|G\+\+'),)
  # Mac OS X
  ifneq ($(shell $(CXX) --version 2>&1 | head -1 | grep -i apple),)
    CXXFLAGS += -fopenmp -fast
  else
    CXXFLAGS += -fopenmp -O2 -Wall
  endif
  # Add POPCNT (SSE 4.2) support if using GCC >= 4.4
  GCC_MAJOR := $(shell $(CXX) -dumpversion 2>&1 | cut -d'.' -f1)
  GCC_MINOR := $(shell $(CXX) -dumpversion 2>&1 | cut -d'.' -f2)
  GCC_VERSION := $(shell echo $$(($(GCC_MAJOR)*10+$(GCC_MINOR))))
  CXXFLAGS += $(shell if [ $(GCC_VERSION) -ge 44 ]; then echo -mpopcnt; fi)

# Other compilers
else
  $(warning unkown compiler: add OpenMP and POPCNT flags if supported)
  CXXFLAGS += -O2
endif

# Generate list of object files
OBJS := $(patsubst $(SRCDIR)/%.cpp,$(OUTDIR)/%.o,$(wildcard $(SRCDIR)/*.cpp))
OBJS += $(patsubst $(MAINDIR)/%.cpp,$(OUTDIR)/%.o,$(wildcard $(MAINDIR)/*.cpp))

TARGET := $(OUTDIR)/$(TARGET)

# Create output directory if it does not exist
ifeq ($(wildcard $(OUTDIR)/),)
$(shell mkdir -p $(OUTDIR))
endif

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) $(OBJS) -o $(TARGET)

$(OUTDIR)/%.o: $(SRCDIR)/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OUTDIR)/%.o: $(MAINDIR)/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

.PHONY: clean
clean:
	rm $(OBJS)
	rm $(TARGET)
