CFLAGS=$(echo "${CFLAGS}" | sed "s/-march=[a-zA-Z0-9]*//g")
CFLAGS=$(echo "${CFLAGS}" | sed "s/-mtune=[a-zA-Z0-9]*//g")

# Avoid sorting LDFLAGS
sed -i.bak 's/LDFLAGS := $(sort $(LDFLAGS))//g' common.mk

case $target_platform in
    osx-*)
        export CC=$BUILD_PREFIX/bin/clang
        ./configure --prefix=$PREFIX --enable-cblas --enable-threading=pthreads intel64
        make CC_VENDOR=clang -j${CPU_COUNT}
        make install
        make check -j${CPU_COUNT}
        ;;
    linux-*)
        ln -s `which $CC` $BUILD_PREFIX/bin/gcc
        export CC=$BUILD_PREFIX/bin/gcc
        ./configure --prefix=$PREFIX --enable-cblas --enable-threading=pthreads x86_64
        make CC_VENDOR=gcc -j${CPU_COUNT}
        make install
        make check -j${CPU_COUNT}
        ;;
    win-*)
        export LIBPTHREAD=
        ./configure --disable-shared --enable-static --prefix=$PREFIX --enable-cblas --enable-threading=pthreads --enable-arg-max-hack x86_64
        make V=1 -j${CPU_COUNT}
        echo "Contents of frame/3/gemm/bli_gemm_ker_var2.c:"
        cat frame/3/gemm/bli_gemm_ker_var2.c
        echo "Contents of kernels/skx/3/bli_dgemm_skx_asm_16x14.c:"
        cat kernels/skx/3/bli_dgemm_skx_asm_16x14.c
        echo "Compiling assembly of frame/3/gemm/bli_gemm_ker_var2.c..."
        echo "clang.exe -O2 -I$PREFIX/include -O2 -D_CRT_SECURE_NO_WARNINGS -D_MT -D_DLL -nostdlib -Xclang --dependent-lib=msvcrt -fuse-ld=lld -Wall -Wno-unused-function -Wfatal-errors -Wno-tautological-compare -std=c99 -D_POSIX_C_SOURCE=200112L -pthread -Iinclude/x86_64 -I./frame/3/ -I./frame/ind/ukernels/ -I./frame/3/ -I./frame/1m/ -I./frame/1f/ -I./frame/1/ -I./frame/include -DBLIS_VERSION_STRING=\"0.8.1\" -DBLIS_IS_BUILDING_LIBRARY -S frame/3/gemm/bli_gemm_ker_var2.c -o ./bli_gemm_ker_var2.s"
        clang.exe -O2 -I$PREFIX/include -O2 -D_CRT_SECURE_NO_WARNINGS -D_MT -D_DLL -nostdlib -Xclang --dependent-lib=msvcrt -fuse-ld=lld -Wall -Wno-unused-function -Wfatal-errors -Wno-tautological-compare -std=c99 -D_POSIX_C_SOURCE=200112L -pthread -Iinclude/x86_64 -I./frame/3/ -I./frame/ind/ukernels/ -I./frame/3/ -I./frame/1m/ -I./frame/1f/ -I./frame/1/ -I./frame/include -DBLIS_VERSION_STRING=\"0.8.1\" -DBLIS_IS_BUILDING_LIBRARY -S frame/3/gemm/bli_gemm_ker_var2.c -o ./bli_gemm_ker_var2.s
        echo "Compiling assembly of kernels/skx/3/bli_dgemm_skx_asm_16x14.c..."
        echo "clang.exe -O2 -O3 -fomit-frame-pointer -mavx512f -mavx512dq -mavx512bw -mavx512vl -mfpmath=sse -march=skylake-avx512 -I$PREFIX/include -O2 -D_CRT_SECURE_NO_WARNINGS -D_MT -D_DLL -nostdlib -Xclang --dependent-lib=msvcrt -fuse-ld=lld -Wall -Wno-unused-function -Wfatal-errors -Wno-tautological-compare -std=c99 -D_POSIX_C_SOURCE=200112L -pthread -Iinclude/x86_64 -I./frame/3/ -I./frame/ind/ukernels/ -I./frame/3/ -I./frame/1m/ -I./frame/1f/ -I./frame/1/ -I./frame/include -DBLIS_VERSION_STRING=\"0.8.1\" -DBLIS_IS_BUILDING_LIBRARY -S kernels/skx/3/bli_dgemm_skx_asm_16x14.c -o ./bli_dgemm_skx_asm_16x14.s"
        clang.exe -O2 -O3 -fomit-frame-pointer -mavx512f -mavx512dq -mavx512bw -mavx512vl -mfpmath=sse -march=skylake-avx512 -I$PREFIX/include -O2 -D_CRT_SECURE_NO_WARNINGS -D_MT -D_DLL -nostdlib -Xclang --dependent-lib=msvcrt -fuse-ld=lld -Wall -Wno-unused-function -Wfatal-errors -Wno-tautological-compare -std=c99 -D_POSIX_C_SOURCE=200112L -pthread -Iinclude/x86_64 -I./frame/3/ -I./frame/ind/ukernels/ -I./frame/3/ -I./frame/1m/ -I./frame/1f/ -I./frame/1/ -I./frame/include -DBLIS_VERSION_STRING=\"0.8.1\" -DBLIS_IS_BUILDING_LIBRARY -S kernels/skx/3/bli_dgemm_skx_asm_16x14.c -o ./bli_dgemm_skx_asm_16x14.s
        echo "Contents of bli_gemm_ker_var2.s:"
        cat ./bli_gemm_ker_var2.s
        echo "Contents of bli_dgemm_skx_asm_16x14.s:"
        cat ./bli_dgemm_skx_asm_16x14.s
        make install
        make check -j${CPU_COUNT}
 
        ./configure --enable-shared --disable-static --prefix=$PREFIX --enable-cblas --enable-threading=pthreads --enable-arg-max-hack x86_64
        make -j${CPU_COUNT}
        make install
        mv $PREFIX/lib/libblis.lib $PREFIX/lib/blis.lib
        mv $PREFIX/lib/libblis.a $PREFIX/lib/libblis.lib
        mv $PREFIX/lib/libblis.*.dll $PREFIX/bin/
        ;;
esac
