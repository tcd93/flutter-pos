import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:posapp/common/money_format/money.dart';
import 'package:posapp/generated/l10n.dart';

void main() {
  setUp(() async {
    await S.load(Locale('vi'));
  });
  test('test currency formatter', () {
    var s = Money.format(10500);
    expect(s, '10.500');
  });
  test('test currency un-formatter', () {
    var s = Money.format(10000);
    var n = Money.unformat(s);
    expect(n, 10000);
  });
}
