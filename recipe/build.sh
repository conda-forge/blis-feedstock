CFLAGS=$(echo "${CFLAGS}" | sed "s/-march=[a-zA-Z0-9]*//g")
CFLAGS=$(echo "${CFLAGS}" | sed "s/-mtune=[a-zA-Z0-9]*//g")

# Avoid sorting LDFLAGS
sed -i.bak 's/LDFLAGS := $(sort $(LDFLAGS))//g' common.mk

mkdir build && cd build
../configure --prefix=$PREFIX --disable-static --enable-shared --enable-cblas --enable-threading=$threading $CPU_FAMILY
make -j${CPU_COUNT}
make install
make check -j${CPU_COUNT}
