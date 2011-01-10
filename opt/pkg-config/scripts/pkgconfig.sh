#!/usr/bin/env bash
if [ ! "$PKG_CONFIG_PATH32" = "" ]; then
	PKG_CONFIG_PATH32=${PKG_CONFIG_PATH32}:/usr/local/lib/pkgconfig
else
	PKG_CONFIG_PATH32=/usr/local/lib/pkgconfig:/usr/lib/pkgconfig
fi

if [ ! "$PKG_CONFIG_PATH64" = "" ]; then
	PKG_CONFIG_PATH64=${PKG_CONFIG_PATH64}:/usr/local/lib64/pkgconfig
else
	PKG_CONFIG_PATH64=/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig
fi

export PKG_CONFIG_PATH32
export PKG_CONFIG_PATH64
