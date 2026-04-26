# Guard gegen mehrfach Includes
if(PROVIDE_LIBRARYS_INCLUDED)

    return()
endif()
set(PROVIDE_LIBRARYS_INCLUDED TRUE)

function(provideLib targetDir repoUrl includeDirs cppDirs linkLibs extraOptions gitTag)
    
    if(NOT EXISTS ${targetDir})

        # GitHub Projekt clonen und submodules rekursiv updaten
        find_package(Git REQUIRED)
        message(STATUS "Cloning ${repoUrl} into ${targetDir}")
        execute_process(
            COMMAND ${GIT_EXECUTABLE} clone --recursive --progress ${repoUrl} ${targetDir}
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            RESULT_VARIABLE git_result
        )
        if(NOT git_result EQUAL "0")
            message(FATAL_ERROR "Failed to clone ${repoUrl}")
        endif()

        execute_process(

            COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${targetDir}
            RESULT_VARIABLE git_result
        )

        #
        if(NOT gitTag STREQUAL "")

            execute_process(
                COMMAND ${GIT_EXECUTABLE} checkout ${gitTag}
                WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${targetDir}
                RESULT_VARIABLE git_result
            )
            if(NOT git_result EQUAL "0")
                message(FATAL_ERROR "Failed to checkout tag ${gitTag}")
            endif()
            
            message(STATUS "Checked out tag ${gitTag}")
        endif()
    else()

        message(STATUS "Repository ${targetDir} exists")
    endif()

    #
    foreach(dir ${includeDirs})
        list(APPEND INCLUDES ${dir})
    endforeach()
    set(INCLUDES ${INCLUDES} PARENT_SCOPE)
    
    #
    set(LOCAL_CPPOBJS ${CPPOBJS})
    foreach(pattern ${cppDirs})

        if(pattern MATCHES "\\.(c|cpp|cc)$")

            list(APPEND LOCAL_CPPOBJS "${pattern}")

        else()

            # Ordner checken
            file(GLOB_RECURSE found_cpp_files "${pattern}/*.cpp")
            file(GLOB_RECURSE found_c_files "${pattern}/*.c")
            set(found_files ${found_cpp_files} ${found_c_files})
            
            if(found_files)

                message(STATUS "Pattern '${pattern}' resolved to ${found_files}")
                list(APPEND LOCAL_CPPOBJS ${found_files})
            endif()
        endif()
    endforeach()
    set(CPPOBJS ${LOCAL_CPPOBJS} PARENT_SCOPE)
    
    # Links
    foreach(lib ${linkLibs})
        list(APPEND LINKLIBS ${lib})
    endforeach()
    set(LINKLIBS ${LINKLIBS} PARENT_SCOPE)

    #
    foreach(option ${extraOptions})
    
        string(REPLACE "=" ";" option_pair ${option})
        list(GET option_pair 0 option_name)
        list(GET option_pair 1 option_value)
        set(${option_name} ${option_value} CACHE BOOL "" FORCE)
    endforeach()
    
    add_subdirectory(${targetDir})

endfunction()

function(provideHeaderOnlyLib targetDir repoUrl includeDirs extraOptions gitTag)

    provideLib("${targetDir}" "${repoUrl}" "${includeDirs}" "" "" "${extraOptions}" "${gitTag}")

    set(INCLUDES ${INCLUDES} PARENT_SCOPE)
    set(CPPOBJS  ${CPPOBJS}  PARENT_SCOPE)
    set(LINKLIBS ${LINKLIBS} PARENT_SCOPE)

endfunction()

function(includePrebuildLib label includes location)

    #
    add_library(${label} STATIC IMPORTED)

    #
    set_target_properties(${label} PROPERTIES
        IMPORTED_LOCATION "${location}"
        INTERFACE_INCLUDE_DIRECTORIES "${includes}"
    )

    list(APPEND LINKLIBS ${label})
    set(LINKLIBS ${LINKLIBS} PARENT_SCOPE)

endfunction()

function(getLib targetDir repoUrl gitTag)
    
    if(NOT EXISTS ${targetDir})

        # GitHub Projekt clonen und submodules rekursiv updaten
        find_package(Git REQUIRED)
        message(STATUS "Cloning ${repoUrl} into ${targetDir}")
        execute_process(
            COMMAND ${GIT_EXECUTABLE} clone --recursive --progress ${repoUrl} ${targetDir}
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            RESULT_VARIABLE git_result
        )
        if(NOT git_result EQUAL "0")
            message(FATAL_ERROR "Failed to clone ${repoUrl}")
        endif()

        execute_process(

            COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${targetDir}
            RESULT_VARIABLE git_result
        )

        #
        if(NOT gitTag STREQUAL "")

            execute_process(
                COMMAND ${GIT_EXECUTABLE} checkout ${gitTag}
                WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${targetDir}
                RESULT_VARIABLE git_result
            )
            if(NOT git_result EQUAL "0")
                message(FATAL_ERROR "Failed to checkout tag ${gitTag}")
            endif()
            
            message(STATUS "Checked out tag ${gitTag}")
        endif()
    else()

        message(STATUS "Repository ${targetDir} exists")
    endif()

endfunction()

function(getModule targetDir repoUrl gitTag)
    
    if(NOT EXISTS ${targetDir})

        # GitHub Projekt clonen und submodules rekursiv updaten
        find_package(Git REQUIRED)
        message(STATUS "Cloning ${repoUrl} into ${targetDir}")
        execute_process(
            COMMAND ${GIT_EXECUTABLE} clone --progress ${repoUrl} ${targetDir}
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            RESULT_VARIABLE git_result
        )
        if(NOT git_result EQUAL "0")
            message(FATAL_ERROR "Failed to clone ${repoUrl}")
        endif()

        execute_process(

            COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${targetDir}
            RESULT_VARIABLE git_result
        )

        #
        if(NOT gitTag STREQUAL "")

            execute_process(
                COMMAND ${GIT_EXECUTABLE} checkout ${gitTag}
                WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${targetDir}
                RESULT_VARIABLE git_result
            )
            if(NOT git_result EQUAL "0")
                message(FATAL_ERROR "Failed to checkout tag ${gitTag}")
            endif()
            
            message(STATUS "Checked out tag ${gitTag}")
        endif()
    else()

        message(STATUS "Repository ${targetDir} exists")
    endif()

endfunction()

function(buildStaticLib targetName sourceDir includeDir sources linkLibs outputDir)

    # ── Quellen einsammeln ────────────────────────────────────────────────────
    set(collected "")
    foreach(pattern ${sources})
        if(pattern STREQUAL "*")
            # Alle .cpp und .c im sourceDir einsammeln
            file(GLOB_RECURSE found_cpp "${sourceDir}/*.cpp")
            file(GLOB_RECURSE found_c   "${sourceDir}/*.c")
            list(APPEND collected ${found_cpp} ${found_c})
        elseif(IS_ABSOLUTE "${pattern}")
            list(APPEND collected "${pattern}")
        elseif(pattern MATCHES "\\.(c|cpp|cc)$")
            list(APPEND collected "${sourceDir}/${pattern}")
        else()
            file(GLOB_RECURSE found_cpp "${sourceDir}/${pattern}/*.cpp")
            file(GLOB_RECURSE found_c   "${sourceDir}/${pattern}/*.c")
            list(APPEND collected ${found_cpp} ${found_c})
        endif()
    endforeach()

    # ── Target anlegen ────────────────────────────────────────────────────────
    if(NOT collected)
        # header-only
        add_library(${targetName} INTERFACE)
        target_include_directories(${targetName} INTERFACE "${includeDir}")
        foreach(lib ${linkLibs})
            target_link_libraries(${targetName} INTERFACE ${lib})
        endforeach()
    else()
        add_library(${targetName} STATIC ${collected})
        target_include_directories(${targetName} PUBLIC "${includeDir}")
        foreach(lib ${linkLibs})
            target_link_libraries(${targetName} PUBLIC ${lib})
        endforeach()

        # Output-Pfad für die .lib / .a
        set_target_properties(${targetName} PROPERTIES
            ARCHIVE_OUTPUT_DIRECTORY "${outputDir}"
        )
    endif()

endfunction()