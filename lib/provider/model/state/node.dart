class Node {
  final int id;
  double x, y;

  /// The tab index on Lobby screen
  final int page;

  Node({this.x = 0, this.y = 0, required this.page}) : id = -1;

  Node.fromJson(Map<String, dynamic> json)
      : id = json['ID'] ?? json['tableID'] ?? json['id'],
        x = json['x'],
        y = json['y'],
        page = json['page'] ?? 0;

  Map<String, dynamic> toJson() => {'ID': id, 'x': x, 'y': y, 'page': page};
}
