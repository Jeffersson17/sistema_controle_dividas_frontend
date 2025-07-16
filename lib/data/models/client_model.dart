class ClientModel {
  final String id;
  final double debt;
  final String name;

  ClientModel({
    required this.id,
    required this.debt,
    required this.name,
  });

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'],
      debt: double.parse(map['debt'].toString()),
      name: map['name'],
    );
  }
}