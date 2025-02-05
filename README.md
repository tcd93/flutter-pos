# Simple-POS

## ⚠ Check this out! version 2 is at https://tcd93.github.io/flutter_2 ⚠ 
## ❤️❤️ [Online Demo for v2](https://github.com/tcd93/flutter_pos2)❤️❤️

### ❤️❤️ [Online Demo for v1](https://tcd93.github.io/flutter-pos)❤️❤️

A mobile POS written in _Flutter_, suitable for small cafe/restaurant, fully offline.

**Tested & printable on **Sunmi V1S** device.**

![sunmi_v1s](.github/resource/print.jpg)

**Support:**

- Android
- Web (unable to print)
- English & Vietnamese (auto detect Locale)

---

## Install & Run

Get [flutter](https://flutter.dev/)
**IMPORTANT: this project works only with Flutter >= 3.10**

```
flutter pub get
flutter run
```

### Running inside WSL2
##### Use **Docker for Destop**'s _Dev Environment_ (note that usbip over Docker Desktop, as of now, hasn't work; you can try debugging over ADB tcpip)
Or
##### Run Docker containers inside of WSL2
1. Build image and run container: `docker-compose -f .\compose-dev.yaml up -d --build`
2. SSH inside: `docker exec -it flutter_dev bash`
3. Accept licences: `flutter doctor --android-licenses`
4. Clean: `flutter clean`
5. Run:
    - Web: `flutter run -d web-server` (Visual studio code should forward the port automatically if you use _Remote window_)
    - USB-connected Android device: follow the instruction [here](https://learn.microsoft.com/en-us/windows/wsl/connect-usb) to connect your phone into WSL2, remember to kill the running ADB server on your Windows host machine first

## Testing
`flutter test`

## TODO
- [ ] Remote printing? (via Bluetooth)
