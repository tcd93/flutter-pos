class Node {
  final int id;
  String? name;
  double x, y;

  /// The tab index on Lobby screen
  final int page;

  Node({this.x = 0, this.y = 0, this.name, required this.page}) : id = -1;

  Node.fromJson(Map<String, dynamic> json)
      : id = json['ID'] ?? json['tableID'] ?? json['id'],
        x = json['x'],
        y = json['y'],
        name = json['name'],
        page = json['page'] ?? 0;

  Map<String, dynamic> toJson() => {'ID': id, 'x': x, 'y': y, 'name': name, 'page': page};
}
