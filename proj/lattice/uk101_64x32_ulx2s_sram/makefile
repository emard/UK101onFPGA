BINARY=diamond/project/project_project.jed

all: $(BINARY)

$(BINARY):
	./clean-lattice.sh
	cd diamond; ./build.sh

upload: program

program: $(BINARY)
	ujprog $<

flash: $(BINARY)
	ujprog -j flash $<
	
copy: $(BINARY)
	cp $(BINARY) blinkled_LFXP2-8E-5TN144C.jed

clean:
	rm -rf diamond *~
