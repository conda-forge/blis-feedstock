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
  # Response files don't seem to work with windows so we have to activate the arg max hack
  ARG_MAX_HACK="--enable-arg-max-hack"
fi



./configure --prefix=$PREFIX --disable-static --enable-shared --enable-cblas --enable-threading=$threading $ARG_MAX_HACK $CPU_FAMILY
make CC_VENDOR=$CC_VENDOR -j${CPU_COUNT}
make CC_VENDOR=$CC_VENDOR install
make CC_VENDOR=$CC_VENDOR check -j${CPU_COUNT}

for out in out.*
do
  echo '*******************************************************************'
  echo $out
  echo '*******************************************************************'
  cat $out
  echo '*******************************************************************'
done
