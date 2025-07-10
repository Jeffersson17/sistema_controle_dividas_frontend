import 'dart:convert';

import 'package:sistema_controle_dividas_frontend/data/http/exceptions.dart';
import 'package:sistema_controle_dividas_frontend/data/http/http_client.dart';

import '../models/historical_model.dart';

abstract class IHistoricalRepository {
  Future<List<HistoricalModel>> getHistorical();
}

class HistoricalRepository implements IHistoricalRepository {
  final IHttpClient historical;

  HistoricalRepository({required this.historical});

  @override
  Future<List<HistoricalModel>> getHistorical() async {
    final response = await historical.get(
      url: 'http://10.0.0.175:8000/historical/',
    );

    if(response.statusCode == 200) {
      final body = jsonDecode(response.body);

      final historicals = (body as List)
        .map((item) => HistoricalModel.fromMap(item))
        .toList();

      return historicals;
    } else if(response.statusCode == 404) {
      throw NotFoundException(message: 'A url informada não é válida');
    } else {
      throw Exception('Não foi possível carregar o histórico');
    }
  }
}