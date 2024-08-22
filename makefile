CXX = g++
CXXFLAGS = -std=c++17 -Wall -pedantic-errors -g -I./include -I/usr/include/lua5.1

SRCS =  main.cpp 
OBJS = ${SRCS:.cpp=.o}
HEADERS = 

MAIN = myprog

all: ${MAIN}
	@echo done

${MAIN}: ${OBJS}
	${CXX} ${CXXFLAGS} ${OBJS} -o ${MAIN} -llua5.1 -lm

.cpp.o:
	${CXX} ${CXXFLAGS} -c $< -o   $@

clean:
	${RM} ${PROGS} ${OBJS} *.o *~.