import 'package:flutter/material.dart';
import 'package:sistema_controle_dividas_frontend/data/http/exceptions.dart';

import '../../data/models/historical_model.dart';
import '../../data/repositories/historical_repository.dart';

class HistoricalStore {
  final IHistoricalRepository repository;

  final ValueNotifier<List<HistoricalModel>> state = ValueNotifier([]);

  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  final ValueNotifier<String> erro = ValueNotifier('');

  HistoricalStore({required this.repository});

  Future<void> getHistorical() async {
    isLoading.value = true;

    try {
      final result = await repository.getHistorical();
      state.value = result;
    } on UnauthorizedException {
      isLoading.value = false;
      rethrow;
    } catch (e) {
      erro.value = e.toString();
    }

    isLoading.value = false;
  }
}
