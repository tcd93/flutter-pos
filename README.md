# Simple-POS
### ❤️❤️ [Online Demo](https://tcd93.github.io/flutter-pos) ❤️❤️

A mobile POS written in _Flutter_, suitable for small cafe/restaurant, fully offline. 

**Tested & printable on **Sunmi V1S** device.**
![sunmi_v1s](.github/resource/print.jpg)

**Support:**
- Android
- Web (unable to print, _local-storage_ unable to persist uploaded images)
- English & Vietnamese (auto detect Locale)

---

## Install & Run

1. Get [flutter](https://flutter.dev/)
2. `flutter channel beta` (please use beta channel for now)
3. `flutter upgrade`
4. `flutter config --enable-web`
2. `flutter run -d chrome --web-renderer canvaskit`

## Testing

`flutter test`

## TODO
- [ ] Inventory journal
- [ ] Remote printing? (via Bluetooth)
