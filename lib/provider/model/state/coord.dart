import '../../../storage_engines/connection_interface.dart';

/// encapsulates the global X, Y position of a node
class Coordinate {
  late double x = 0, y = 0;

  Coordinate(this.x, this.y);

  Coordinate.fromDB(int tableID, CoordinateIO database) {
    x = database.getX(tableID);
    y = database.getY(tableID);
  }
}
