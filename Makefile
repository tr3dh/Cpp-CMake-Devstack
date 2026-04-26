ifeq ($(OS),Windows_NT)
    ifeq ($(MSYSTEM),)
        include Makefiles/win.mk
    else
        include Makefiles/mingw64.mk
    endif
else
    include Makefiles/Makefile.unix
endif