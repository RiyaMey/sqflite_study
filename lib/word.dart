class Word {
  final int id;
  final String name;
  final String value;

  const Word({
    required this.id,
    required this.name,
    required this.value,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'value': value,
    };
  }

  factory Word.fromMap(Map<String, dynamic> json) => Word(
      id: json['id'],
      name: json['name'],
      value: json['value'],
    );

  @override
  String toString() {
    return 'Word{id: $id, name: $name, value: $value}';
  }
  
}