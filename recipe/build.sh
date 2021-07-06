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
        make -j${CPU_COUNT}
        echo "Contents of frame/3/gemm/bli_gemm_ker_var2.c:"
        cat frame/3/gemm/bli_gemm_ker_var2.c
        echo "Contents of kernels/skx/3/bli_dgemm_skx_asm_16x14.c:"
        cat kernels/skx/3/bli_dgemm_skx_asm_16x14.c
        echo "Compiling assimbly of frame/3/gemm/bli_gemm_ker_var2.c..."
        echo "clang-cl -I$LIBRARY_INC/blis /FAcs -o bli_gemm_ker_var2.s frame/3/gemm/bli_gemm_ker_var2.c"
        clang-cl -I$LIBRARY_INC/blis /FAcs -o bli_gemm_ker_var2.s frame/3/gemm/bli_gemm_ker_var2.c
        echo "Compiling assimbly of kernels/skx/3/bli_dgemm_skx_asm_16x14.c..."
        echo "clang-cl -I$LIBRARY_INC/blis /FAcs -o bli_dgemm_skx_asm_16x14.s kernels/skx/3/bli_dgemm_skx_asm_16x14.c"
        clang-cl -I$LIBRARY_INC/blis /FAcs -o bli_dgemm_skx_asm_16x14.s kernels/skx/3/bli_dgemm_skx_asm_16x14.c
        cat "Contents of bli_gemm_ker_var2.s:"
        cat bli_gemm_ker_var2.s
        echo "Contents of bli_dgemm_skx_asm_16x14.s:"
        cat bli_dgemm_skx_asm_16x14.s
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
