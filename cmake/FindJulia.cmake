find_program(Julia_EXECUTABLE julia)

if(NOT Julia_EXECUTABLE)

    set(Julia_ROOT "C:/Users/timal/.julia/juliaup/julia-1.10.2+0.x64.w64.mingw32"
        CACHE PATH "Julia installation root")
    set(Julia_EXECUTABLE "${Julia_ROOT}/bin/julia.exe")
    set(Julia_INCLUDE_DIR "${Julia_ROOT}/include/julia")
    set(Julia_LIBRARY_DIR "${Julia_ROOT}/lib")
    set(Julia_BINARY_DIR  "${Julia_ROOT}/bin")

else()
    execute_process(
        COMMAND ${Julia_EXECUTABLE} --startup-file=no
                -e "print(joinpath(Sys.BINDIR, \"..\", \"include\", \"julia\"))"
        OUTPUT_VARIABLE Julia_INCLUDE_DIR
    )
    execute_process(
        COMMAND ${Julia_EXECUTABLE} --startup-file=no
                -e "print(joinpath(Sys.BINDIR, \"..\", \"lib\"))"
        OUTPUT_VARIABLE Julia_LIBRARY_DIR
    )
    execute_process(
        COMMAND ${Julia_EXECUTABLE} --startup-file=no
                -e "print(Sys.BINDIR)"
        OUTPUT_VARIABLE Julia_BINARY_DIR
    )
endif()

if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set(Julia_LIBRARY "${Julia_LIBRARY_DIR}/libjulia.lib")
else()
    set(Julia_LIBRARY "${Julia_LIBRARY_DIR}/libjulia.dll.a")
endif()