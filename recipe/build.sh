set -ex

CFLAGS=$(echo "${CFLAGS}" | sed "s/-march=[a-zA-Z0-9]*//g")
CFLAGS=$(echo "${CFLAGS}" | sed "s/-mtune=[a-zA-Z0-9]*//g")


# Map platform to BLIS target architecture 
case $target_platform in
    osx-64)
        arch="intel64"
        ;;
    *-64)
        arch="x86_64"
        ;;
    *-aarch64)
        arch="arm64"
        ;;
    *-arm64)
        arch="arm64"
        ;;
    #*-ppc64le)
    #    arch="power9"
    #   ;;
    *)
        echo "Unsupported architecture: $target_platform"
        exit 1
esac


# Define target-specific options
case $target_platform in
    osx-*)
        export CC_VENDOR=clang
        export PYTHON=${BUILD_PREFIX}/bin/python
        ;;
    linux-*)
        ln -s `which $CC` $BUILD_PREFIX/bin/gcc
        export CC_VENDOR=gcc
        export PYTHON=${BUILD_PREFIX}/bin/python
        ;;
    win-*)
        export LIBPTHREAD=""
        export PYTHON=${BUILD_PREFIX}/python
        # upstream's build system messes up paths with D:/...
        export CFLAGS=${CFLAGS/D:\///d/}
        export CXXFLAGS=${CXXFLAGS/D:\///d/}
        export LDFLAGS=${LDFLAGS/D:\///d/}
        ;;
esac


COMMON_CONFIGURE_ARGS=(
    --prefix="${PREFIX}"
    --enable-verbose-make
    --enable-cblas
    --enable-threading="${threading}"
    # note: arch must always come last
    "${arch}"
)


case $target_platform in
    win-*)
        # Windows: build shared and static libraries separately
        mkdir shared
        cd shared
        ../configure --enable-shared --disable-static --enable-arg-max-hack "${COMMON_CONFIGURE_ARGS[@]}"
        make -j${CPU_COUNT}
        make install
        # due to upstream bug, library is not installed currently
        # https://github.com/flame/blis/issues/911
        mv lib/*/libblis.lib "${PREFIX}"/lib/blis.lib
        mv lib/*/libblis*.dll "${PREFIX}"/bin/
        cd ..

        ./configure --disable-shared --enable-static --enable-arg-max-hack "${COMMON_CONFIGURE_ARGS[@]}"
        make -j${CPU_COUNT}
        make install
        make check -j${CPU_COUNT}
        mv "${PREFIX}"/lib/libblis.a "${PREFIX}"/lib/libblis.lib
        ;;
    *)
        # General case: build both static and shared simultaneously
        ./configure "${COMMON_CONFIGURE_ARGS[@]}"
        make -j${CPU_COUNT}
        make install
        make check -j${CPU_COUNT}
        ;;
esac
