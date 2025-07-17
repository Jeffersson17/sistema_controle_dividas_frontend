import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/http/http_client.dart';
import '../data/models/historical_model.dart';
import '../data/repositories/historical_repository.dart';
import '../pages/stores/store_historical.dart';

class HistoricalPage extends StatefulWidget {
  final String searchTerm;
  const HistoricalPage({super.key, required this.searchTerm});

  @override
  State<HistoricalPage> createState() => _HistoricalPageState();
}

class _HistoricalPageState extends State<HistoricalPage> {
  late final HistoricalStore store;

  @override
  void initState() {
    super.initState();
    final client = HttpClient();
    final repository = HistoricalRepository(historical: client);
    store = HistoricalStore(repository: repository);

    store.isLoading.addListener(() => setState(() {}));
    store.state.addListener(() => setState(() {}));
    store.erro.addListener(() => setState(() {}));

    store.getHistorical();
  }

  List _getFilteredData() {
    final historico = store.state.value;
    if (widget.searchTerm.isEmpty) return historico;

    return historico
        .where((item) =>
            item.clientName.toLowerCase().contains(widget.searchTerm.toLowerCase()))
        .toList();
  }

  void _showHistoricalDetails(HistoricalModel item) {
    showDialog(
      context: context,
      builder: (context) {
        final date = DateTime.parse(item.date).toLocal();
        final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);

        return AlertDialog(
          title: Text('Detalhes do Histórico'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Text('🧍 Cliente: ${item.clientName}'),
              const SizedBox(height: 12),
              Text('💰 Valor: ${(item.value >= 0 ? '+' : '-') + item.value.abs().toStringAsFixed(2)}'),
              const SizedBox(height: 12),
              Text('💬 Observação: ${item.observation.isEmpty ? 'Sem observação!' : item.observation}'),
              const SizedBox(height: 12),
              Text('🗓 Data: $formattedDate'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (store.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (store.erro.value.isNotEmpty) {
      return Center(child: Text('Erro: ${store.erro.value}'));
    }

    final dataToShow = _getFilteredData();

    if (dataToShow.isEmpty) {
      return const Center(child: Text('Nenhum histórico encontrado.'));
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'HISTÓRICO',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await store.getHistorical();
            },
            child: ListView.builder(
              itemCount: dataToShow.length,
              itemBuilder: (context, index) {
                final item = dataToShow[index];
                final isPositive = item.value >= 0;
                final valorFormatado =
                  '${isPositive ? '+' : '-'}${item.value.abs().toStringAsFixed(2).replaceAll('.', ',')}';

                return ListTile(
                  title: Text(
                    item.clientName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    valorFormatado,
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  onTap: () => _showHistoricalDetails(item),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
