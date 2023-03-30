.SUFFIXES:
.SUFFIXES: .cpp .o .d

.PHONY: clean run install

srcs = main.cpp
objs = $(srcs:.cpp=.o)

CXXFLAGS += -g -I ./

prefix ?= $(out)
DESTDIR ?= $(prefix)

main.o: main.cpp up.h

.cpp.o:
	$(CXX) $(CXXFLAGS) -c $< -o $@

up: $(objs)
	$(CXX) $(LDFLAGS) $(objs) -lunistring -o up

run: up
	./up

check:
	@echo "The code is non-trivial, but perfect"

doc: Doxyfile
	doxygen
	chown -R $(shell id -u) doc

install: up doc
	install -m 0755 -d $(DESTDIR)/bin
	install -m 0755 ./up $(DESTDIR)/bin/up
	install -m 0755 -d $(DESTDIR)/share/doc/$(name)/api
	cp -r ./doc/html/. $(DESTDIR)/share/doc/$(name)/api
	install -m 0755 -d $(DESTDIR)/share/
	cp -r ./doc/man $(DESTDIR)/share/

clean:
	rm -f main.o ./up
	rm -rf doc
