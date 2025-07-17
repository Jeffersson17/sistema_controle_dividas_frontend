class HistoricalModel {
  final int id;
  final String client; // id do cliente (UUID)
  final String clientName;
  final double value;
  final String observation;
  final String date;

  HistoricalModel({
    required this.id,
    required this.client,
    required this.clientName,
    required this.value,
    required this.observation,
    required this.date,
  });

  factory HistoricalModel.fromMap(Map<String, dynamic> map) {
    return HistoricalModel(
      id: map['id'] as int,
      client: map['client'] as String,
      clientName: map['client_name'] as String,
      value: double.parse(map['value'].toString()),
      observation: map['observation'] as String,
      date: map['date'] as String,
    );
  }
}
