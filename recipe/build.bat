setlocal EnableExtensions EnableDelayedExpansion
@echo on

:: Make a build folder and change to it
mkdir build
cd build

:: configure
:: enable components explicitly so we get build error when unsatisfied
set ^"CMAKE_OPTIONS=^
 -DCMAKE_BUILD_TYPE=Release ^
 -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
 -DLIB_SUFFIX="" ^
 -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
 -DPython3_EXECUTABLE="%PYTHON%" ^
 -DPython3_INSTALL_DIR="%SP_DIR%" ^
 -DSOAPY_SDR_EXTVER=%PKG_BUILDNUM% ^
 -DENABLE_APPS=ON ^
 -DENABLE_DOCS=OFF ^
 -DENABLE_LIBRARY=ON ^
 -DENABLE_PYTHON2=OFF ^
 -DENABLE_PYTHON3=ON ^
 -DENABLE_TESTS=ON ^
 -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ^
 ^"

if exist "%PREFIX%\include\python\Python.h" (
  set ^"CMAKE_OPTIONS=!CMAKE_OPTIONS! ^
    -DPython3_INCLUDE_DIR=%PREFIX%\include\python ^
    ^"
)

cmake -G "Ninja" !CMAKE_OPTIONS! ..
if errorlevel 1 exit 1

:: build
cmake --build . --config Release -- -j%CPU_COUNT%
if errorlevel 1 exit 1

:: install
cmake --build . --config Release --target install
if errorlevel 1 exit 1
