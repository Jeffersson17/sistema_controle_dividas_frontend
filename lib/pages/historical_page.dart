import 'package:flutter/material.dart';

class HistoricalPage extends StatefulWidget {
  const HistoricalPage({super.key});

  @override
  State<HistoricalPage> createState() => _HistoricalPageState();
}

class _HistoricalPageState extends State<HistoricalPage> {
  final List<Map<String, dynamic>> historico = [
    {'nome': 'João Silva', 'item': 'Camiseta', 'valor': 120.0},
    {'nome': 'Maria Oliveira', 'item': 'Pagamento', 'valor': -50.0},
    {'nome': 'Pedro Santos', 'item': 'Tenis', 'valor': 200.0},
    {'nome': 'Ana Souza', 'item': 'Sôaua', 'valor': -30.0},
    {'nome': 'Carlos Pereira', 'item': 'Jaqueta', 'valor': 150.0},
    {'nome': 'Mariana Rocha', 'item': 'Taia', 'valor': -75.0},
    {'nome': 'Fernando Almeida', 'item': 'Calça', 'valor': 90.0},
    {'nome': 'Fernando Almeida', 'item': 'Calça', 'valor': 90.0},
  ];

  int paginaAtual = 0;
  final int itensPorPagina = 9;

  @override
  Widget build(BuildContext context) {
    final int totalPaginas = (historico.length / itensPorPagina).ceil();
    final int inicio = paginaAtual * itensPorPagina;
    final int fim = (inicio + itensPorPagina).clamp(0, historico.length);
    final List<Map<String, dynamic>> pagina = historico.sublist(inicio, fim);

    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'HISTÓRICO',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: pagina.length,
              itemBuilder: (context, index) {
                final item = pagina[index];
                final isPositive = item['valor'] >= 0;
                final valorFormatado =
                    '${isPositive ? '+' : '-'}${item['valor'].abs().toStringAsFixed(2).replaceAll('.', ',')}';

                return ListTile(
                  title: Text(
                    item['nome'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(item['item']),
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
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                  onPressed: paginaAtual > 0
                      ? () => setState(() => paginaAtual--)
                      : null,
                ),
                for (int i = 0; i < totalPaginas; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontWeight: paginaAtual == i
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 18),
                  onPressed: paginaAtual < totalPaginas - 1
                      ? () => setState(() => paginaAtual++)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
