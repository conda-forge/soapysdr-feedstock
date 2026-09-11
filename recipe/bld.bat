setlocal EnableDelayedExpansion
@echo on

:: Make a build folder and change to it
mkdir build
cd build

FOR /F "delims=" %%i in ('$PYTHON -c "import sysconfig; print(sysconfig.get_config_var('LDLIBRARY'))"') DO set "PYTHON_LIBRARY=%%i"
FOR /F "delims=" %%i in ('$PYTHON -c "import sysconfig; print(sysconfig.get_paths()['include'])"') DO set "PYTHON_INCLUDE_DIR=%%i"

:: configure
:: enable components explicitly so we get build error when unsatisfied
cmake -G "Ninja" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DLIB_SUFFIX="" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DPYTHON_EXECUTABLE="%PYTHON%" ^
    -DPYTHON_LIBRARY="%PYTHON_LIBRARY%" ^
    -DPYTHON_INCLUDE_DIR="%PYTHON_INCLUDE_DIR%" ^
    -DPYTHON_INSTALL_DIR="%SP_DIR%" ^
    -DSOAPY_SDR_EXTVER=%PKG_BUILDNUM% ^
    -DENABLE_APPS=ON ^
    -DENABLE_DOCS=OFF ^
    -DENABLE_LIBRARY=ON ^
    -DENABLE_PYTHON=ON ^
    -DENABLE_TESTS=ON ^
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ^
    ..
if errorlevel 1 exit 1

:: build
cmake --build . --config Release -- -j%CPU_COUNT%
if errorlevel 1 exit 1

:: install
cmake --build . --config Release --target install
if errorlevel 1 exit 1
