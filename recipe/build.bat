call %BUILD_PREFIX%\Library\bin\run_autotools_clang_conda_build.bat
if errorlevel 1 exit 1

dumpbin /exports %LIBRARY_BIN%\libblis.4.dll > exports.txt
type exports.txt
:: fail if we cannot find the expected symbols in DLL exports
grep -q cdotc_ exports.txt
if errorlevel 1 exit 1
