import 'package:flutter_test/flutter_test.dart';
import 'package:posapp/storage_engines/sqlite/sqlite.dart';

void main() {
  test('Should merge rawResults into a list of one object', () {
    final rawResults = [
      {
        'ID': 1,
        'date': '20170907',
        'time': '17:30',
        'tableID': 0,
        'status': 0,
        'discountRate': 1.0,
        'isDeleted': false,
        //
        'orderID': 1,
        'dishID': 0,
        'dishName': 'Test Dish 0',
        'price': 5000.0,
        'quantity': 1,
      },
      {
        'ID': 1,
        'date': '20170907',
        'time': '17:30',
        'tableID': 0,
        'status': 0,
        'discountRate': 1.0,
        'isDeleted': false,
        //
        'orderID': 1,
        'dishID': 1,
        'dishName': 'Test Dish 1',
        'price': 6000.0,
        'quantity': 1,
      },
      {
        'ID': 2,
        'date': '20170907',
        'time': '19:30',
        'tableID': 1,
        'status': 0,
        'discountRate': 1.0,
        'isDeleted': false,
        //
        'orderID': 2,
        'dishID': 1,
        'dishName': 'Test Dish 3',
        'price': 9900.0,
        'quantity': 1,
      }
    ];
    final r = mergeRaws(rawResults);
    expect(r, [
      {
        'ID': 1,
        'checkoutTime': '20170907 17:30',
        'tableID': 0,
        'status': 0,
        'discountRate': 1.0,
        'isDeleted': false,
        'lineItems': [
          {'orderID': 1, 'dishID': 0, 'dishName': 'Test Dish 0', 'price': 5000.0, 'quantity': 1},
          {'orderID': 1, 'dishID': 1, 'dishName': 'Test Dish 1', 'price': 6000.0, 'quantity': 1},
        ],
      },
      {
        'ID': 2,
        'checkoutTime': '20170907 19:30',
        'tableID': 1,
        'status': 0,
        'discountRate': 1.0,
        'isDeleted': false,
        'lineItems': [
          {'orderID': 2, 'dishID': 1, 'dishName': 'Test Dish 3', 'price': 9900.0, 'quantity': 1},
        ],
      }
    ]);
  });
}
