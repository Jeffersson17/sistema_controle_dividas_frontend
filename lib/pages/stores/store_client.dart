import 'package:flutter/cupertino.dart';
import 'package:sistema_controle_dividas_frontend/data/http/exceptions.dart';
import 'package:sistema_controle_dividas_frontend/data/models/client_model.dart';
import 'package:sistema_controle_dividas_frontend/data/repositories/client_repository.dart';

class ClientStore {
  final IClientRepository repository;

  //Variável reativa para loading
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  //Variável reativa para state
  final ValueNotifier<List<ClientModel>> state = ValueNotifier<List<ClientModel>>([]);

  //Variável reativa para erro
  final ValueNotifier<String> erro = ValueNotifier<String>('');

  ClientStore({required this.repository});

  Future getClients() async {
    isLoading.value = true;

    try {
      final result = await repository.getClients();
      state.value = result;
    } on NotFoundException catch(e) {
      erro.value = e.message;
    } catch(e) {
      erro.value = e.toString();
    }

    isLoading.value = false;
  }
}