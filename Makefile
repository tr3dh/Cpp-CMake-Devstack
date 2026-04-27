ifeq ($(OS),Windows_NT)
    ifeq ($(MSYSTEM),)
        include Makefiles/platform/win.mk
        include Makefiles/utils.win.mk
    else
        include Makefiles/platform/mingw64.mk
        include Makefiles/utils.mingw64.mk
    endif
else
    include Makefiles/platform/unix.mk
    include Makefiles/utils.unix.mk
endif