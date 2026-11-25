CXXFLAGS ?= -O3 -Wall

sources := bvh.cc geometry.cc image.cc main.cc material.cc render.cc scene.cc
objects := $(sources:%.cc=build/%.o)

.PHONY: all clean
all: pt

pt: $(objects) Makefile
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $(objects) $(LDLIBS)

build/%.o: src/%.cc Makefile | build
	$(CXX) -Isrc/include $(CPPFLAGS) -std=c++17 $(CXXFLAGS) -MMD -MP -c $< -o $@

build:
	mkdir -p $@

clean:
	$(RM) -r build pt

-include $(objects:.o=.d)
