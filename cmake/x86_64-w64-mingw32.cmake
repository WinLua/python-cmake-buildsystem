SET(CMAKE_SYSTEM_NAME Windows)
SET(CMAKE_C_COMPILER ${COMPILERPATH}x86_64-w64-mingw32-gcc)
SET(CMAKE_CXX_COMPILER ${COMPILERPATH}x86_64-w64-mingw32-g++)
SET(CMAKE_RC_COMPILER ${COMPILERPATH}x86_64-w64-mingw32-windres)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

