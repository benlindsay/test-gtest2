# A sample Makefile for building Google Test and using it in user
# tests.  Please tweak it to suit your environment and project.  You
# may want to move it to your project's root directory.
#
# SYNOPSIS:
#
#   make [all]  - makes everything.
#   make TARGET - makes the given target.
#   make clean  - removes all files generated by make.

# Please tweak the following variable definitions as needed by your
# project, except GTEST_HEADERS, which you can use in your own targets
# but shouldn't modify.

# Points to the root of Google Test, relative to where this file is.
# Remember to tweak this if you move this file.
GTEST_DIR = /tmp/googletest/googletest

# Where to find user code.
USER_DIR = src

LIB_DIR_1 = manual-lib
LIB_DIR_2 = lib64

# Flags passed to the preprocessor.
# Set Google Test's header directory as a system directory, such that
# the compiler doesn't generate warnings in Google Test headers.
CPPFLAGS += -isystem include

# Flags passed to the C++ compiler.
CXXFLAGS += -g -Wall -Wextra -pthread

# All tests produced by this Makefile.  Remember to add new tests you
# created to the list.
TESTS = test1 test2

# All Google Test headers.  Usually you shouldn't change this
# definition.
GTEST_HEADERS = include/gtest/*.h \
                include/gtest/internal/*.h

# House-keeping build targets.

all : $(TESTS)

clean :
	rm -rf $(TESTS) **/*.a **/*.o $(LIB_DIR_1) include $(LIB_DIR_2)

# Builds gtest.a and gtest_main.a.

# Usually you shouldn't tweak such internal variables, indicated by a
# trailing _.
GTEST_SRCS_ = $(GTEST_DIR)/src/*.cc $(GTEST_DIR)/src/*.h $(GTEST_HEADERS)

$(GTEST_HEADERS):
	cp -r $(GTEST_DIR)/include .

# For simplicity and to avoid depending on Google Test's
# implementation details, the dependencies specified below are
# conservative and not optimized.  This is fine as Google Test
# compiles fast and for ordinary users its source rarely changes.
$(LIB_DIR_1)/gtest-all.o : $(GTEST_SRCS_)
	mkdir -p $(LIB_DIR_1)
	$(CXX) $(CPPFLAGS) -I$(GTEST_DIR) $(CXXFLAGS) -c \
            $(GTEST_DIR)/src/gtest-all.cc -o $@

$(LIB_DIR_1)/gtest_main.o : $(GTEST_SRCS_)
	mkdir -p $(LIB_DIR_1)
	$(CXX) $(CPPFLAGS) -I$(GTEST_DIR) $(CXXFLAGS) -c \
            $(GTEST_DIR)/src/gtest_main.cc -o $@

$(LIB_DIR_1)/gtest.a : $(LIB_DIR_1)/gtest-all.o
	mkdir -p $(LIB_DIR_1)
	$(AR) $(ARFLAGS) $@ $^

$(LIB_DIR_1)/libgtest_main.a : $(LIB_DIR_1)/gtest-all.o $(LIB_DIR_1)/gtest_main.o
	mkdir -p $(LIB_DIR_1)
	$(AR) $(ARFLAGS) $@ $^

$(LIB_DIR_2)/libgtest_main.a : install-googletest.sh
	./install-googletest.sh

# Builds a sample test.  A test should link with either gtest.a or
# gtest_main.a, depending on whether it defines its own main()
# function.

$(USER_DIR)/test1.o : $(USER_DIR)/test.cpp $(GTEST_HEADERS)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

test1 : $(USER_DIR)/test1.o $(LIB_DIR_1)/libgtest_main.a
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -lpthread $^ -o $@

$(USER_DIR)/test2.o : $(USER_DIR)/test.cpp $(GTEST_HEADERS)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

test2 : $(USER_DIR)/test2.o $(LIB_DIR_2)/libgtest_main.a
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -lpthread $^ -o $@
