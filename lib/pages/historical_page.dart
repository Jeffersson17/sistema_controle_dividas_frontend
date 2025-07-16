import 'package:flutter/material.dart';
import '../data/http/http_client.dart';
import '../data/models/historical_model.dart';
import '../data/repositories/historical_repository.dart';
import '../pages/stores/store_historical.dart';

class HistoricalPage extends StatefulWidget {
  const HistoricalPage({super.key});

  @override
  State<HistoricalPage> createState() => _HistoricalPageState();
}

class _HistoricalPageState extends State<HistoricalPage> {
  late final HistoricalStore store;

  final int itemsPerPage = 8;
  int currentPage = 0;

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

  @override
  Widget build(BuildContext context) {
    final historico = store.state.value;

    if (store.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (store.erro.value.isNotEmpty) {
      return Center(child: Text('Erro: ${store.erro.value}'));
    }

    if (historico.isEmpty) {
      return const Center(child: Text('Nenhum histórico encontrado.'));
    }

    final int totalPages = (historico.length / itemsPerPage).ceil();
    final int start = currentPage * itemsPerPage;
    final int end = (start + itemsPerPage).clamp(0, historico.length);
    final List<HistoricalModel> pageItems = historico.sublist(start, end);

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'HISTÓRICO',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => store.getHistorical(),
            child: ListView.builder(
              itemCount: pageItems.length,
              itemBuilder: (context, index) {
                final item = pageItems[index];
                final isPositive = item.value >= 0;
                final valorFormatado =
                    '${isPositive ? '+' : '-'}${item.value.abs().toStringAsFixed(2).replaceAll('.', ',')}';

                return ListTile(
                  title: Text(
                    item.clientName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(item.observation),
                  trailing: Text(
                    valorFormatado,
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                );
              },
            ),
          )
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 18),
                onPressed: currentPage > 0
                    ? () => setState(() => currentPage--)
                    : null,
              ),
              Text(
                'Página ${currentPage + 1} de $totalPages',
                style: const TextStyle(fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 18),
                onPressed: currentPage < totalPages - 1
                    ? () => setState(() => currentPage++)
                    : null,
              ),
            ],
          ),
        )
      ],
    );
  }
}
