set(CMAKE_MODULE_PATH
  ${CMAKE_CURRENT_LIST_DIR}
  ${CMAKE_MODULE_PATH}
  )

if(NOT DEFINED PATCH_COMMAND)
  find_package(Git)
  if(Git_FOUND OR GIT_FOUND)
    set(PATCH_COMMAND ${GIT_EXECUTABLE} apply --whitespace=fix)
    # Initialize Git repo to ensure "git apply" works when source tree
    # is located within an already versioned tree.
    if(NOT EXISTS "${SRC_DIR}/.git")
      execute_process(
        COMMAND ${GIT_EXECUTABLE} init
        WORKING_DIRECTORY ${SRC_DIR}
        RESULT_VARIABLE result
        ERROR_VARIABLE error
        ERROR_STRIP_TRAILING_WHITESPACE
        OUTPUT_QUIET
        )
      if(NOT result EQUAL 0)
        message(FATAL_ERROR "${output}\n${error}")
      endif()
    endif()
  else()
    find_package(Patch)
    if(Patch_FOUND OR PATCH_FOUND)
      # Since support for git diffs which copy or rename files was
      # added in patch 2.7, we can not use older version.
      if("${Patch_VERSION}" VERSION_EQUAL "2.7.0" OR "${Patch_VERSION}" VERSION_GREATER "2.7.0")
        set(PATCH_COMMAND ${Patch_EXECUTABLE} --quiet -p1 -i)
      else()
        set(_reason "Found Patch executable [${Patch_EXECUTABLE}] version [${Patch_VERSION}] older than 2.7.0 missing support for copy or rename files.")
      endif()
    endif()
  endif()
endif()

if(NOT DEFINED PATCH_COMMAND)
  message(FATAL_ERROR "Could NOT find a suitable version of Git or Patch executable to apply patches. ${_reason}")
endif()

set(patches_dir "${Python_SOURCE_DIR}/patches")

function(_apply_patches _subdir)
  if(NOT EXISTS ${patches_dir}/${_subdir})
    message(STATUS "Skipping patches: Directory '${patches_dir}/${_subdir}' does not exist")
    return()
  endif()
  file(GLOB _patches RELATIVE ${patches_dir} "${patches_dir}/${_subdir}/*.patch")
  if(NOT _patches)
    return()
  endif()
  message(STATUS "")
  list(SORT _patches)
  foreach(patch IN LISTS _patches)
    set(msg "Applying '${patch}'")
    message(STATUS "${msg}")
    set(applied ${SRC_DIR}/.patches/${patch}.applied)
    # Handle case where source tree was patched using the legacy approach.
    set(legacy_applied ${PROJECT_BINARY_DIR}/CMakeFiles/patches/${patch}.applied)
    if(EXISTS ${legacy_applied})
      set(applied ${legacy_applied})
    endif()
    if(EXISTS ${applied})
      message(STATUS "${msg} - skipping (already applied)")
      continue()
    endif()
    execute_process(
      COMMAND ${PATCH_COMMAND} ${patches_dir}/${patch}
      WORKING_DIRECTORY ${SRC_DIR}
      RESULT_VARIABLE result
      ERROR_VARIABLE error
      ERROR_STRIP_TRAILING_WHITESPACE
      OUTPUT_VARIABLE output
      OUTPUT_STRIP_TRAILING_WHITESPACE
      )
    if(result EQUAL 0)
      message(STATUS "${msg} - done")
      #get_filename_component(_dir ${applied} DIRECTORY)
      get_filename_component(_dir ${applied} PATH)
      execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${_dir})
      execute_process(COMMAND ${CMAKE_COMMAND} -E touch ${applied})
    else()
      message(STATUS "${msg} - failed")
      message(FATAL_ERROR "${output}\n${error}")
    endif()
  endforeach()
  message(STATUS "")
endfunction()
