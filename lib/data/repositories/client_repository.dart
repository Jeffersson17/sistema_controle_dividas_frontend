import 'dart:convert';

import 'package:sistema_controle_dividas_frontend/data/http/http_client.dart';
import 'package:sistema_controle_dividas_frontend/data/models/client_model.dart';

import '../http/exceptions.dart';
import '../models/historical_model.dart';

abstract class IClientRepository {
  Future<List<ClientModel>> getClients();
  Future<HistoricalModel> updateClientDebt({
    required String clientId,
    required double value,
    required String observation,
  });
}

class ClientRepository implements IClientRepository {
  final IHttpClient client;

  ClientRepository({required this.client});

  @override
  Future<List<ClientModel>> getClients() async {
    final response = await client.get(
      url: 'http://10.0.0.175:8000/client/',
    );

    if(response.statusCode == 200) {
      final body = jsonDecode(response.body);

      final clients = (body as List)
        .map((item) => ClientModel.fromMap(item))
        .toList();

      return clients;
    } else if(response.statusCode == 404) {
      throw NotFoundException(message: 'A url informada não é válida');
    } else {
      throw Exception('Não foi possível carregar os clientes');
    }
  }

  @override
  Future<HistoricalModel> updateClientDebt({
    required String clientId,
    required double value,
    required String observation,
  }) async {
    final response = await client.post(
      url: 'http://10.0.0.175:8000/historical/',
      body: {
        'client': clientId,
        'value': value,
        'observation': observation,
      },
    );

    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);
      return HistoricalModel.fromMap(body);
    } else if (response.statusCode == 400) {
      throw Exception('Dados inválidos para atualizar dívida.');
    } else {
      throw Exception('Erro ao atualizar a dívida do cliente.');
    }
  }
}