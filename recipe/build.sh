CFLAGS=$(echo "${CFLAGS}" | sed "s/-march=[a-zA-Z0-9]*//g")
CFLAGS=$(echo "${CFLAGS}" | sed "s/-mtune=[a-zA-Z0-9]*//g")

# Avoid sorting LDFLAGS
sed -i.bak 's/LDFLAGS := $(sort $(LDFLAGS))//g' common.mk


case $target_platform in
    osx-64)
        config=intel64
        ;;
    osx-arm64)
        config=cortexa53/armv8a
        ;;
    linux-64)
        config=x86_64
        ;;
    win-64)
        config=x86_64
        ;;
esac

case $target_platform in
    osx-*)
        export CC=$BUILD_PREFIX/bin/clang
        ./configure --prefix=$PREFIX --enable-cblas --enable-threading=pthreads $config
        make CC_VENDOR=clang -j${CPU_COUNT}
        make install
        make check -j${CPU_COUNT}
        ;;
    linux-*)
        ln -s `which $CC` $BUILD_PREFIX/bin/gcc
        export CC=$BUILD_PREFIX/bin/gcc
        ./configure --prefix=$PREFIX --enable-cblas --enable-threading=pthreads $config
        make CC_VENDOR=gcc -j${CPU_COUNT}
        make install
        make check -j${CPU_COUNT}
        ;;
    win-*)
        export LIBPTHREAD=
        ./configure --disable-shared --enable-static --prefix=$PREFIX --enable-cblas --enable-threading=pthreads --enable-arg-max-hack x86_64
        make -j${CPU_COUNT}
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
