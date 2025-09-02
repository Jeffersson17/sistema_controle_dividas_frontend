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
    try {
      final response = await client.get(url: 'https://sistema-controle-dvidas.fly.dev/client/');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return (body as List).map((item) => ClientModel.fromMap(item)).toList();
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'A url informada não é válida');
      } else {
        throw AppException('Não foi possível carregar os clientes');
      }
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw AppException('Erro desconhecido: $e');
    }
  }

  @override
  Future<HistoricalModel> updateClientDebt({
    required String clientId,
    required double value,
    required String observation,
  }) async {
    try {
      final response = await client.post(
        url: 'https://sistema-controle-dvidas.fly.dev/historical/',
        body: {'client': clientId, 'value': value, 'observation': observation},
      );

      if (response.statusCode == 201) {
        final body = jsonDecode(response.body);
        return HistoricalModel.fromMap(body);
      } else if (response.statusCode == 400) {
        throw Exception('Dados inválidos para atualizar dívida.');
      } else {
        throw Exception('Erro ao atualizar a dívida do cliente.');
      }
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw Exception('Erro desconhecido ao atualizar dívida: $e');
    }
  }
}
