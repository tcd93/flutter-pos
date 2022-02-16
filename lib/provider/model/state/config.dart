class Config {
  final String key;
  final Object value;

  Config({required this.key, required this.value});

  Config.fromJson(Map<String, dynamic> json)
      : key = json['key'],
        value = json['value'];

  Map<String, dynamic> toJson() => {'key': key, 'value': value};
}
