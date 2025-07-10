class ClientModel {
  final double debt;
  final String name;

  ClientModel({
    required this.debt,
    required this.name,
  });

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      debt: double.parse(map['debt'].toString()),
      name: map['name'],
    );
  }
}