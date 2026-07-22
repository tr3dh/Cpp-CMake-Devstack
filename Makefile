PLATFORM_PREFIX = \

ifeq ($(OS),Windows_NT)
    ifeq ($(MSYSTEM),)
        PLATFORM_PREFIX = win
    else
        PLATFORM_PREFIX = mingw64
    endif
else
    PLATFORM_PREFIX = unix
endif

include Makefiles/$(PLATFORM_PREFIX).mk