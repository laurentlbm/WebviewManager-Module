# Webview Manager Lite
Fork of [Androidacy](https://www.androidacy.com)'s Webview Manager, with a few changes:
- Stop opening browser to Androidacy's Website
- Stop using their API, therefore:
- - No speed throttling
- - Download APKs directly from Github
- Only install webview, no browser



## What is this?

With this module, you can install a different default webview.

Different webviews have additional advantages to the default ones: they are often more up to date, secure, privacy friendly, and better performing!

The module will always download the latest version of the webview, to update it just reflash the module!

The latest update should now work on all ROMs Android v7.0+. ROMs versions 5.x to 6.x are not explicitly supported. Overly customized OEM ROMs such as MIUI have limited support.

## What is a WebView?

Webview is a shared component between apps to display web content instead of directing to a browser. It's like a minimal browser, but for non-browsers that display web content in any other way than sending you to a browser or custom tab, apps that use it include email, wewbview wrapper apps, or even some banking apps. Even the Google app uses a webview.

**PLEASE NOTE SOME APPS WON'T WORK WITHOUT GOOGLE'S OWN WEBVIEW**. We can't fix that and any issues on it will be closed and ignored. Complain to the app developer, not us. We're not even sure why this happens or if/how they check.

## Credits

Bromite itself is created by and copyright of the developers of the [Bromite project](https://github.com/bromite/bromite). The upstream official repository can be found [here](https://github.com/bromite/bromitewebview). The source code is [here](https://github.com/bromite/bromite)

Ungoogled-chromium Android is created by and copyright [The Ungoogled Chromium Authors](https://ungoogled-software.github.io/). Source code for Android builds can be found [here](https://git.droidware.info/wchen342/ungoogled-chromium-android)

Chromium is created by and copyright [The Chromium Project](http://www.chromium.org/). Source code used in the Chromium implemrntation is [here](https://github.com/bromite/chromium)

All binaries utilized and the original MMT-Extended template are developed by and copyright Zackptg5 excluding BusyBox and the original installer template which is built by and copyright John Wu. The upstream binaries are copyright and developed by the original authors.

Origimal module created by Androidacy with help early on from Skittles9823 and Zackptg5.

The logging code used was orginally developed by and copyright John Fawkes, and modified later by Androidacy

## ETAs/ Versions

This module downloads the latest webview APK every time it is flashed. We will otherwise update as we see fit.
At any time the latest alpha if available can be downloaded by zipping the master branch of the upstream repository, although you should wait for us to do a release first.

In addition, there may be third party ways to update any apps that can be installed with the module. We do not endorse nor did we create these ways!

## Compatibility

- Android 7.x to 11.0.
- Some heavily customized stock ROMs may have issues. This is especially true on android 11!
- MIUI is not officially supported for the aforementioned reason. Some people have had success with debloating the stock bloatware.
- OneUI users: make sure Secure Folder is disabled before installing.
- Magisk v20.1+ required
- **Required: flash through magisk manager**
- TWRP installs are not supported!
- SELinux enforcing/permissive