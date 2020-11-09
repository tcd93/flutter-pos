import 'package:flutter_test/flutter_test.dart';

import 'package:hembo/models/tracker.dart';
import 'package:hembo/models/table.dart';

final mockTracker = OrderTracker(
  modelBuilder: (tracker) => [
    TableModel(tracker, 0)
      ..lineItem(1).quantity = 7
      ..lineItem(1).quantity = 5
      ..lineItem(5).quantity = 10
      ..lineItem(3).quantity = 15,
  ],
);
final TableModel mockTable = mockTracker.getTable(0);

void main() {
  test('Tracker should be tracking only one table (index 0)', () {
    expect(() => mockTracker.getTable(1), throwsRangeError);
  });

  test('mockTable total quantity should be 30', () {
    expect(mockTable.totalMenuItemQuantity(), 30);
  });

  test('Table should go back to blank state after checkout', () {
    mockTable.checkout();
    expect(mockTable.totalMenuItemQuantity(), 0);
    expect(mockTable.getTableStatus(), TableStatus.empty);
  });
}
