#!/system/bin/sh

rm -rf /data/resource-cache/*
rm -rf /data/dalvik-cache/*
rm -rf /cache/dalvik-cache/*
rm -rf /data/*/com.android.webview*
rm -rf /data/system/package_cache/*

sed -i "/item packageName=\"org.androidacy.WebviewOverlay\"/d" /data/system/overlays.xml

reboot
