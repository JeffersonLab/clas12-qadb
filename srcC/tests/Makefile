CXX = g++ -std=c++17
FLAGS = -g -Wno-deprecated -fPIC -m64 -fno-inline -Wno-write-strings

ifndef QADB
$(error "ERROR: you need environment variable 'QADB'; run 'source environ.sh'")
endif

# QADB and rapidjson
DEPS += -I$(QADB)/srcC/rapidjson/include -I$(QADB)/srcC/include

#--------------------------------------------

SOURCES := $(basename $(wildcard *.cpp))
EXES := $(addsuffix .exe, $(SOURCES))

#--------------------------------------------

all: 
	make exe

exe: $(EXES)

%.exe: %.o
	@echo "--- make executable $@"
	$(CXX) -o $@ $< $(LIBS)

%.o: %.cpp
	@echo "----- build $@ -----"
	$(CXX) -c $^ -o $@ $(FLAGS) $(DEPS)

clean:
	@echo "----- clean -----"
	$(RM) $(EXES)
