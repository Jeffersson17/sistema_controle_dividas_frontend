class HistoricalModel {
  final double value;
  final String clientName;
  final String observation;
  final String date;

  HistoricalModel({
    required this.value,
    required this.clientName,
    required this.observation,
    required this.date,
  });

  factory HistoricalModel.fromMap(Map<String, dynamic> map) {
    return HistoricalModel(
      value: double.parse(map['value'].toString()),
      clientName: map['client_name'],
      observation: map['observation'],
      date: map['date'],
    );
  }
}