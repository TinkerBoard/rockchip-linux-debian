FIND_PACKAGE (JNI REQUIRED)

if (PERIPHERALMAN)
  # Override the JNI include directory for Android Things since these
  # will require an Android-friendly jni.h
  set(JAVA_INCLUDE_PATH "${ANDROID_SYSROOT}/usr/include")
endif()

if (ANDROID_BUILD)
	set(JAVA_INCLUDE_PATH "$ENV{NDK_HOME}/sysroot/usr/include/")
endif()

include_directories (
  ${JAVA_INCLUDE_PATH}
  ${JAVA_INCLUDE_PATH2}
  ${CMAKE_CURRENT_SOURCE_DIR}/..
)

# SWIG treats SWIG_FLAGS as a list and not a string so semicolon seperation is required
set_source_files_properties (mraajava.i PROPERTIES SWIG_FLAGS ";-package;mraa;-I${CMAKE_BINARY_DIR}/src")
set_source_files_properties (mraajava.i PROPERTIES CPLUSPLUS ON)

if (BUILDCPP)
  set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fpermissive -DJAVACALLBACK")
endif()
set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DJAVACALLBACK")

if (NOT DEFINED ENV{JAVA_HOME_NATIVE})
  if (NOT DEFINED ENV{JAVA_HOME})
    message (FATAL_ERROR "Neither JAVA_HOME nor JAVA_HOME_NATIVE are set")
  endif()
  set (JAVA_HOME_NATIVE $ENV{JAVA_HOME})
  set (JAVAC $ENV{JAVA_HOME}/bin/javac)
  set (JAR $ENV{JAVA_HOME}/bin/jar)
else ()
  set (JAVAC $ENV{JAVA_HOME_NATIVE}/bin/javac)
  set (JAR $ENV{JAVA_HOME_NATIVE}/bin/jar)
endif ()

message (STATUS "INFO - JAVA_INCLUDE_PATH is ${JAVA_INCLUDE_PATH}")
message (STATUS "INFO - JAVA_INCLUDE_PATH2 is ${JAVA_INCLUDE_PATH2}")

if (CMAKE_VERSION VERSION_LESS "3.8")
  swig_add_module (mraajava java mraajava.i mraajni.c)
else ()
  swig_add_library (mraajava LANGUAGE java SOURCES mraajava.i mraajni.c)
endif ()
swig_link_libraries (mraajava ${JAVA_LIBRARIES} mraa)

add_custom_command (TARGET mraajava
  POST_BUILD
  COMMAND cmake -E echo "Compiling java.."
  COMMAND cmake -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/mraa
  COMMAND ${JAVAC} *.java -d ${CMAKE_CURRENT_BINARY_DIR}
  COMMAND cmake -E echo "Creating jar"
  COMMAND ${JAR} cvmf manifest.txt mraa.jar mraa
)

if (DOXYGEN_FOUND)
  foreach (_file ${DOCFILES})
    add_dependencies (${SWIG_MODULE_mraajava_REAL_NAME} ${_file}doc_i)
  endforeach ()
endif ()

mraa_create_install_pkgconfig (mraajava.pc ${LIB_INSTALL_DIR}/pkgconfig)

install (TARGETS mraajava LIBRARY DESTINATION ${LIB_INSTALL_DIR})
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/mraa.jar DESTINATION ${LIB_INSTALL_DIR}/../lib/java)
