#!/bin/sh
CFLAGS=$(echo "${CFLAGS}" | sed "s/-march=[a-zA-Z0-9]*//g")
CFLAGS=$(echo "${CFLAGS}" | sed "s/-mtune=[a-zA-Z0-9]*//g")

# Avoid sorting LDFLAGS
sed -i.bak 's/LDFLAGS := $(sort $(LDFLAGS))//g' common.mk

if [[ "$CC" == *"-gnu-"* ]]
then
  CC_VENDOR=gcc
else
  CC_VENDOR=clang
  # Use response file to avoid reaching argument size limits under windows
  echo $LDFLAGS > LDFLAGS
  LDFLAGS="@LDFLAGS"
fi



./configure --prefix=$PREFIX --disable-static --enable-shared --enable-cblas --enable-threading=$threading $CPU_FAMILY
make CC_VENDOR=$CC_VENDOR -j${CPU_COUNT}
make CC_VENDOR=$CC_VENDOR install
make CC_VENDOR=$CC_VENDOR check -j${CPU_COUNT}
