import 'package:flutter/material.dart';
import 'historical_page.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});
  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  String _selectedOption = 'Clientes';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> clientes = [
    {"nome": "Luana Santos", "divida": 558.85},
    {"nome": "Gustavo Silva", "divida": 250.00},
  ];

  final int itensPorPagina = 11;
  int paginaAtual = 0;

  Widget _buildAppBarTitle() {
    return _isSearching
        ? TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Pesquisar...',
              hintStyle: TextStyle(color: Colors.white),
              border: InputBorder.none,
            ),
            onSubmitted: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Pesquisando por: $value')),
              );
            },
          )
        : const Text('Mercadinho LEONE');
  }

  List<Widget> _buildAppBarActions() {
    if (_isSearching) {
      return [
        IconButton(
          icon: const Icon(Icons.close),
          color: Colors.white,
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchController.clear();
            });
          },
        ),
      ];
    } else {
      return [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
        ),
      ];
    }
  }

  Future<void> removeDebt() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Quanto o cliente pagou?'),
          content: const TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: ''),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Enviar'),
            ),
          ],
        ),
      );

  Future<void> addDebt() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Quanto o cliente comprou?'),
          content: const TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: ''),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Enviar'),
            ),
          ],
        ),
      );

  void _onSelectMenuOption(String option) {
    Navigator.pop(context); // fecha o drawer
    setState(() {
      _selectedOption = option;
    });
  }

  Widget _buildClientes() {
    final int totalPaginas = (clientes.length / itensPorPagina).ceil();
    final int inicio = paginaAtual * itensPorPagina;
    final int fim = (inicio + itensPorPagina).clamp(0, clientes.length);
    final List<Map<String, dynamic>> pagina = clientes.sublist(inicio, fim);

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'LISTA DE CLIENTES',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: pagina.length,
            itemBuilder: (context, index) {
              final cliente = pagina[index];
              final valorFormatado =
                  cliente["divida"].toStringAsFixed(2).replaceAll('.', ',');

              return ListTile(
                title: Text(
                  cliente["nome"],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 20, color: Colors.red),
                      onPressed: () => removeDebt(),
                    ),
                    Text(
                      valorFormatado,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20, color: Colors.green),
                      onPressed: () => addDebt(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const Divider(height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 18),
                onPressed:
                    paginaAtual > 0 ? () => setState(() => paginaAtual--) : null,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SizedBox(
        width: 220,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.green[800]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 135,
                      child: Center(
                        child: Image.asset(
                          "assets/logo-mercadinho-leone.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Clientes'),
                selected: _selectedOption == 'Clientes',
                onTap: () => _onSelectMenuOption('Clientes'),
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Histórico'),
                selected: _selectedOption == 'Histórico',
                onTap: () => _onSelectMenuOption('Histórico'),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: _buildAppBarTitle(),
        actions: _buildAppBarActions(),
      ),
      body: _selectedOption == 'Clientes'
          ? _buildClientes()
          : const HistoricalPage(),
    );
  }
}
