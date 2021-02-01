# Flutter-POS

A mobile POS written in Flutter, suitable for small cafe/restaurant, fully offline

Support:
- Android (tested on **Sunmi v1s** device)
- Web (unable to print yet)
- English & Vietnamese (auto detect Locale)

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
