class Node {
  final int id;
  double x, y;

  Node({this.x = 0, this.y = 0}) : id = -1;

  Node.fromJson(Map<String, dynamic> json)
      : id = json['ID'] ?? json['tableID'] ?? json['id'],
        x = json['x'],
        y = json['y'];

  Map<String, dynamic> toJson() => {'ID': id, 'x': x, 'y': y};
}
