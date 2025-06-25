#!/bin/bash

# Caminho do Android SDK
ANDROID_SDK="$HOME/Android/Sdk"
EMULADOR="$ANDROID_SDK/emulator/emulator"

# Diretório dos AVDs
export ANDROID_AVD_HOME="$HOME/.config/.android/avd"

"$EMULADOR" -avd Medium_Phone_API_36.0 \
  -no-boot-anim \
  -gpu host \
  -no-audio \
  -netdelay none \
  -netspeed full \
  -accel on \
  -memory 8096 \
  -cores 8 \
  -scale auto \
  -verbose \
  -qemu -cpu host
