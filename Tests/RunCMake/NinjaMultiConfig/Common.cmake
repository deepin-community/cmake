function(generate_output_files)
  set(content)
  foreach(tgt IN LISTS ARGN)
    get_property(type TARGET ${tgt} PROPERTY TYPE)

    if(NOT type STREQUAL "OBJECT_LIBRARY")
      set(file " [==[$<TARGET_FILE:${tgt}>]==]")
      set(filename " [==[$<TARGET_FILE_NAME:${tgt}>]==]")
    else()
      set(file)
      set(filename)
    endif()
    string(APPEND content "set(TARGET_FILE_${tgt}_$<CONFIG>${file})\n")
    string(APPEND content "set(TARGET_FILE_NAME_${tgt}_$<CONFIG>${filename})\n")

    if(type MATCHES "^(STATIC|MODULE|SHARED)_LIBRARY$")
      set(linker_file " [==[$<TARGET_LINKER_FILE:${tgt}>]==]")
      set(linker_filename " [==[$<TARGET_LINKER_FILE_NAME:${tgt}>]==]")
    else()
      set(linker_file)
      set(linker_filename)
    endif()
    string(APPEND content "set(TARGET_LINKER_FILE_${tgt}_$<CONFIG>${linker_file})\n")
    string(APPEND content "set(TARGET_LINKER_FILE_NAME_${tgt}_$<CONFIG>${linker_filename})\n")

    if(NOT WIN32 AND NOT CYGWIN AND type MATCHES "^(SHARED_LIBRARY)$")
      set(soname_file " [==[$<TARGET_SONAME_FILE:${tgt}>]==]")
      set(soname_filename " [==[$<TARGET_SONAME_FILE_NAME:${tgt}>]==]")
    else()
      set(soname_file)
      set(soname_filename)
    endif()
    string(APPEND content "set(TARGET_SONAME_FILE_${tgt}_$<CONFIG>${soname_file})\n")
    string(APPEND content "set(TARGET_SONAME_FILE_NAME_${tgt}_$<CONFIG>${soname_filename})\n")

    if(type MATCHES "^(EXECUTABLE)$")
      set(exe_file " [==[$<TARGET_FILE_DIR:${tgt}>/$<TARGET_FILE_PREFIX:${tgt}>$<TARGET_FILE_BASE_NAME:${tgt}>$<TARGET_FILE_SUFFIX:${tgt}>]==]")
      set(exe_filename " [==[$<TARGET_FILE_PREFIX:${tgt}>$<TARGET_FILE_BASE_NAME:${tgt}>$<TARGET_FILE_SUFFIX:${tgt}>]==]")

      if(WIN32 AND NOT generate_output_files_NO_EXE_LIB)
        set(exe_lib_file " [==[$<TARGET_FILE_DIR:${tgt}>/$<TARGET_FILE_PREFIX:${tgt}>$<TARGET_FILE_BASE_NAME:${tgt}>.lib]==]")
        string(APPEND content "set(TARGET_EXE_LIB_FILE_${tgt}_$<CONFIG>${exe_lib_file})\n")
      endif()
    else()
      set(exe_file)
      set(exe_filename)
    endif()
    string(APPEND content "set(TARGET_EXE_FILE_${tgt}_$<CONFIG>${exe_file})\n")
    string(APPEND content "set(TARGET_EXE_FILE_NAME_${tgt}_$<CONFIG>${exe_filename})\n")

    string(APPEND content "set(TARGET_OBJECT_FILES_${tgt}_$<CONFIG> [==[$<TARGET_OBJECTS:${tgt}>]==])\n")
  endforeach()

  file(GENERATE OUTPUT "${CMAKE_BINARY_DIR}/target_files_$<CONFIG>.cmake" CONTENT "${content}")

  set(content)
  foreach(config IN LISTS CMAKE_CONFIGURATION_TYPES)
    string(APPEND content "include(\${CMAKE_CURRENT_LIST_DIR}/target_files_${config}.cmake)\n")
  endforeach()

  file(WRITE "${CMAKE_BINARY_DIR}/target_files.cmake" "${content}")
endfunction()
