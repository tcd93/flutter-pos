import '../../../storage_engines/connection_interface.dart';

/// encapsulates the global X, Y position of a node
class Coordinate {
  late double x = 0, y = 0;

  Coordinate(this.x, this.y);

  static Future<Coordinate> fromDB(int tableID, CoordinateIO database) async {
    final _x = await database.getX(tableID);
    final _y = await database.getY(tableID);
    return Coordinate(_x, _y);
  }
}
