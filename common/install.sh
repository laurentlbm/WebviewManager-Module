# shellcheck shell=dash
# shellcheck disable=SC1091,SC1090,SC2139,SC3010

A=$(resetprop ro.system.build.version.release || resetprop ro.build.version.release)
ui_print "ⓘ Your device is a $(echo "$DEVICE" | sed 's#%20#\ #g') with android $A, sdk$API, with an $ARCH cpu"

vol_sel() {
  log 'INFO' "Entering config"
  ui_print "ⓘ Starting config mode...."
  ui_print "ⓘ Volume up to accept the current choice, and down to move to next option"
  sleep 2
  ui_print "-> Do you want to install only webview?"
  unset INSTALL
  if chooseport; then
    INSTALL=0
  fi
  if [[ -z $INSTALL ]]; then
    ui_print "-> How about only browser?"
    if chooseport; then
      INSTALL=1
    fi
  fi
  if [[ -z $INSTALL ]]; then
    ui_print "-> How about both browser and webview?"
    if chooseport; then
      INSTALL=2
    fi
  fi
  if [[ -z $INSTALL ]]; then
    ui_print "-> No valid choice, Using just webview"
    INSTALL=0
  fi
  sel_web() {
    unset WEBVIEW
    ui_print "-> Please choose your webview."
    ui_print "  1. Bromite"
    if chooseport; then
      WEBVIEW=0
    fi
    if [[ -z $WEBVIEW ]]; then
      ui_print "  2. Chromium"
      if chooseport; then
        WEBVIEW=1
      fi
    fi
    if [[ -z $WEBVIEW ]]; then
      ui_print "  3. Ungoogled Chromium"
      if chooseport; then
        WEBVIEW=2
      fi
    fi
    if [[ -z $WEBVIEW ]]; then
      ui_print "-> No valid choice, using bromite"
      WEBVIEW=0
    fi
  }
  sel_browser() {
    unset BROWSER
    ui_print "-> Please choose your browser."
    ui_print "  1. Bromite"
    if chooseport; then
      WEBVIEW=0
    fi
    if [[ -z $BROWSER ]]; then
      ui_print "  2. Chromium"
      if chooseport; then
        BROWSER=1
      fi
    fi
    if [[ -z $BROWSER ]]; then
      ui_print "  3. Ungoogled Chromium"
      if chooseport; then
        BROWSER=2
      fi
    fi
    if [[ -z $BROWSER ]]; then
      ui_print "  4. Ungoogled Chromium (extensions support version)?"
      if chooseport; then
        BROWSER=3
      fi
    fi
    if [[ -z $BROWSER ]]; then
      ui_print "-> No valid choice, using bromite"
      BROWSER=0
    fi
  }
  if [[ "$INSTALL" -eq 0 ]]; then
    sel_web
  fi
  if [[ "$INSTALL" -eq 2 ]]; then
    sel_web
    sel_browser
  fi
  if [[ "$INSTALL" -eq 1 ]]; then
    sel_browser
  fi
  log 'INFO' "User chose browser option $BROWSER, webview $WEBVIEW"
  ui_print "ⓘ Config complete! Proceeding."
}

download_webview() {
  log 'INFO' 'Downloading webview'
  cd "$TMPDIR" || return
  if [[ $WEBVIEW -eq 0 ]]; then
    NAME="Bromite"
    url="https://github.com/bromite/bromite/releases/latest/download/${ARCH}_SystemWebView.apk"
  elif [[ $WEBVIEW -eq 1 ]]; then
    NAME="Chromium"
    url="https://github.com/bromite/chromium/releases/latest/download/chr_${ARCH}_SystemWebView.apk"
  else
    NAME="Ungoogled-Chromium"
    url="https://uc.droidware.info/release/SystemWebView/SystemWebView/SystemWebView_${ARCH}.apk"
  fi

  ui_print "ⓘ Downloading ${NAME} webview, please be patient..."
  curl -vSL "$url" -o "${NAME}Webview.apk"
  if test $? -ne 0; then
      log 'ERROR' "Couldn't download webview. Is it offline?"
      ui_print "⚠ Download failed"
      it_failed
  fi

  extract_webview
}

download_browser() {
  og 'INFO' 'Downloading browser'
  cd "$TMPDIR" || return
  if [[ $BROWSER -eq 0 ]]; then
    NAME="Bromite"
    url="https://github.com/bromite/bromite/releases/latest/download/${ARCH}_ChromePublic.apk"
  elif [[ $BROWSER -eq 1 ]]; then
    NAME="Chromium"
    url="https://github.com/bromite/chromium/releases/latest/download/chr_${ARCH}_ChromePublic.apk"
  elif [[ $BROWSER -eq 2 ]]; then
    NAME="Ungoogled-Chromium"
    url="https://uc.droidware.info/release/Ungoogled-Chromium/ChromeModernPublic/ChromeModernPublic_${ARCH}.apk"
  else
    NAME="Ungoogled-Chromium"
    url="https://uc.droidware.info/release/Extension/ChromeModernPublic/Extensions_ChromeModernPublic_${ARCH}.apk"
  fi

  ui_print "ⓘ Downloading ${NAME} browser, please be patient..."
  curl -vSL "$url" -o "${NAME}Browser.apk"
  if test $? -ne 0; then
      log 'ERROR' "Couldn't download browser. Is it offline?"
      ui_print "⚠ Download failed"
      it_failed
  fi

  extract_browser
}

create_overlay() {
  log 'INFO' 'Creating overlays'
  cd "$TMPDIR" || return
  ui_print "ⓘ Fixing system webview whitelist"
  if [[ "${API}" -ge "29" ]]; then
    aapt p -f -v -M "$MODPATH"/common/overlay10/AndroidManifest.xml -I /system/framework/framework-res.apk -S "$MODPATH"/common/overlay10/res -F "$MODPATH"/unsigned.apk >"$MODPATH"/logs/aapt.log
  else
    aapt p -f -v -M "$MODPATH"/common/overlay9/AndroidManifest.xml -I /system/framework/framework-res.apk -S "$MODPATH"/common/overlay9/res -F "$MODPATH"/unsigned.apk >"$MODPATH"/logs/aapt.log
  fi
  if [[ -f "$MODPATH"/unsigned.apk ]]; then
    sign "$MODPATH"/unsigned.apk "$MODPATH"/signed.apk
    cp -rf "$MODPATH"/signed.apk "$MODPATH"/common/WebviewOverlay.apk
    rm -rf "$MODPATH"/signed.apk "$MODPATH"/unsigned.apk
  else
    log 'ERROR' 'Could not create overlay'
    ui_print "⚠ Overlay creation has failed! Poorly designed ROMs have this issue"
    ui_print "⚠ Compatibility is unlikely, please report this to your ROM developer."
    ui_print "⚠ Some ROMs need a patch to fix this."
    ui_print "⚠ Do NOT report this issue to us."
    sleep 1
  fi

  if [ -d /system_ext/overlay ]; then
    OLP=/system/system_ext/overlay
  elif [ -d /product/overlay ]; then
    OLP=/system/product/overlay
  elif [ -d /vendor/overlay ]; then
    OLP=/system/vendor/overlay
  elif [ -d /system/overlay ]; then
    OLP=/system/overlay
  fi
  mkdir -p "$MODPATH""$OLP"
  cp_ch "$MODPATH"/common/WebviewOverlay.apk "$MODPATH""$OLP"
  echo "$OLP" >"$MODPATH"/overlay.txt
}

set_path() {
  log 'INFO' 'Running debloater'
  ui_print "ⓘ Detecting and systemlessly debloating conflicting packages"
  paths=$(cmd package dump com.android.webview | grep codePath)
  A=${paths##*=}
  unset paths
  K=$(find /system /vendor /product /system_ext -type d 2>/dev/null | grep -i webview | grep -iv lib | grep -iv stub | grep -iv google)
  L=$(find /system /vendor /product /system_ext -type d 2>/dev/null | grep -i webview | grep -iv lib | grep -i stub | grep -iv google)
  paths=$(cmd package dump com.google.android.webview | grep codePath)
  B=${paths##*=}
  unset paths
  I=$(find /system /vendor /product /system_ext -type d 2>/dev/null | grep -i google | grep -i webview | grep -iv lib | grep -iv stub | grep -iv overlay)
  H=$(find /system /vendor /product /system_ext -type d 2>/dev/null | grep -i google | grep -i webview | grep -iv lib | grep -i stub | grep -iv overlay)
  G=$(find /system /vendor /product /system_ext -type d 2>/dev/null | grep -i google | grep -i webview | grep -iv lib | grep -iv stub | grep -i overlay)
  paths=$(cmd package dump com.android.chrome | grep codePath)
  C=${paths##*=}
  J=$(find /system /vendor /product /system_ext -type d 2>/dev/null | grep -i chrome | grep -iv lib | grep -iv stub)
  F=$(find /system /vendor /product /system_ext -type d 2>/dev/null | grep -i chrome | grep -iv lib | grep -i stub)
  unset paths
  paths=$(cmd package dump com.android.browser | grep codePath)
  D=${paths##*=}
  unset paths
  paths=$(cmd package dump org.lineageos.jelly | grep codePath)
  E=${paths##*=}
}

extract_webview() {
  log 'INFO' 'Extracting webview package'
  WPATH="/system/app/${NAME}Webview"
  ui_print "ⓘ Installing ${NAME} Webview"
  for i in "$A" "$H" "$I" "$B" "$G" "$K" "$L"; do
    if [[ -n "$i" ]]; then
      mktouch "$MODPATH""$i"/.replace
    fi
  done
  if [[ "${API}" -lt "29" ]]; then
    for i in "$J" "$F" "$C"; do
      if [[ -n "$i" ]]; then
        mktouch "$MODPATH""$i"/.replace
      fi
    done
  fi
  mktouch "$MODPATH"$WPATH/.replace
  cp_ch "$TMPDIR"/"$NAME"Webview.apk "$MODPATH"$WPATH/webview.apk
  cp "$MODPATH"$WPATH/webview.apk "$TMPDIR"/webview.zip
  mkdir -p "$TMPDIR"/webview "$MODPATH"$WPATH/lib/arm64 "$MODPATH"$WPATH/lib/arm
  unzip -d "$TMPDIR"/webview "$TMPDIR"/webview.zip >/dev/null
  cp -rf "$TMPDIR"/webview/lib/arm64-v8a/* "$MODPATH"$WPATH/lib/arm64
  cp -rf "$TMPDIR"/webview/lib/armeabi-v7a/* "$MODPATH"$WPATH/lib/arm
  rm -rf "$TMPDIR"/webview "$TMPDIR"/webview.zip
  create_overlay
}

extract_browser() {
  log 'INFO' 'Extracting browser package'
  BPATH="/system/app/${NAME}Browser"
  ui_print "ⓘ Installing ${NAME} Browser"
  for i in "$J" "$F" "$C" "$E" "$D"; do
    if [[ -n "$i" ]]; then
      mktouch "$MODPATH""$i"/.replace
    fi
  done
  mktouch "$MODPATH""$BPATH"/.replace
  cp_ch "$TMPDIR"/"$NAME"Browser.apk "$MODPATH"$BPATH/browser.apk
  cp_ch "$MODPATH"$BPATH/browser.apk "$TMPDIR"/browser.zip
  mkdir -p "$TMPDIR"/browser "$MODPATH"$BPATH/lib/arm64 "$MODPATH"$BPATH/lib/arm
  unzip -d "$TMPDIR"/browser "$TMPDIR"/browser.zip >/dev/null
  cp -rf "$TMPDIR"/browser/lib/arm64-v8a/* "$MODPATH"$BPATH/lib/arm64
  cp -rf "$TMPDIR"/browser/lib/armeabi-v7a/* "$MODPATH"$BPATH/lib/arm
  rm -rf "$TMPDIR"/browser "$TMPDIR"/browser.zip
}

online_install() {
  ui_print "☑ Awesome, you have internet"
  set_path
  if [[ $INSTALL -eq 0 ]]; then
    download_webview
  elif [[ $INSTALL -eq 1 ]]; then
    download_browser
  elif [[ $INSTALL -eq 2 ]]; then
    download_webview
    download_browser
  fi
}

do_install() {
  log 'INFO' 'Starting install'
  vol_sel
  if ! "$BOOTMODE"; then
    ui_print "ⓘ Detected recovery install! Aborting!"
    it_failed 1
  else
    online_install
  fi
  do_cleanup
}

clean_dalvik() {
  ui_print "⚠ Dalvik cache will be cleared next boot"
  ui_print "⚠ Expect longer boot time"
}

do_cleanup() {
  log 'INFO' 'Running cleanup'
  ui_print "ⓘ Cleaning up..."
  rm -f "$MODPATH"/system/app/placeholder
  rm -f "$MODPATH"/*.md
  
  ui_print "ⓘ Backing up important stuffs to module directory"
  mkdir -p "$MODPATH"/backup/
  cp /data/system/overlays.xml "$MODPATH"/backup/
  
  if [[ -d "$MODPATH"/product ]]; then
    if [[ -d "$MODPATH"/system/product ]]; then
      cp -rf "$MODPATH"/product/* "$MODPATH"/system/product/
      rm -fr "$MODPATH"/product/
    else
      mv "$MODPATH"/product/ "$MODPATH"/system/
    fi
  fi
  if [[ -d "$MODPATH"/system_ext ]]; then
    if [[ -d "$MODPATH"/system/systen_ext ]]; then
      cp -rf "$MODPATH"/system_ext/ "$MODPATH"/system/
      rm -fr "$MODPATH"/system_ext/
    else
      mv "$MODPATH"/system_ext/ "$MODPATH"/system/
    fi
  fi
  
  clean_dalvik
}


do_install

ui_print ' '
ui_print "ⓘ Some stock apps have been systemlessly debloated"
ui_print "ⓘ Anything debloated is known to cause conflicts"
ui_print "ⓘ Such as Chrome, Google WebView, etc"
ui_print "ⓘ It is recommended not to reinstall them"
ui_print " "
ui_print ">>> Webview Manager Lite | By LL & Androidacy <<<"
ui_print " "
ui_print "☑ Install apparently succeeded, please reboot ASAP"
ui_print " "
