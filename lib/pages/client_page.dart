import 'package:flutter/material.dart';
import '../data/http/http_client.dart';
import '../data/models/client_model.dart';
import '../data/repositories/client_repository.dart';
import '../pages/stores/store_client.dart';
import 'historical_page.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  String _selectedOption = 'Clients';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  final int itemsPerPage = 11;
  int currentPage = 0;

  late final ClientStore store;

  @override
  void initState() {
    super.initState();
    final client = HttpClient();
    final repository = ClientRepository(client: client);
    store = ClientStore(repository: repository);

    store.isLoading.addListener(() => setState(() {}));
    store.state.addListener(() => setState(() {}));
    store.erro.addListener(() => setState(() {}));

    store.getClients();
  }

  Widget _buildAppBarTitle() {
    return _isSearching
        ? TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(color: Colors.white),
              border: InputBorder.none,
            ),
            onSubmitted: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Searching for: $value')),
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

  Future<void> showRemoveDebtDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('How much did the client pay?'),
          content: const TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: ''),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      );

  Future<void> showAddDebtDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('How much did the client buy?'),
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
    Navigator.pop(context); // Close drawer
    setState(() {
      _selectedOption = option;
    });
  }

  Widget _buildClientList() {
    return ValueListenableBuilder<List<ClientModel>>(
      valueListenable: store.state,
      builder: (context, clients, _) {
        if (store.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (store.erro.value.isNotEmpty) {
          return Center(child: Text('Error: ${store.erro.value}'));
        }

        if (clients.isEmpty) {
          return const Center(child: Text('Nenhum cliente encontrado!'));
        }

        final totalPages = (clients.length / itemsPerPage).ceil();
        final int start = currentPage * itemsPerPage;
        final int end = (start + itemsPerPage).clamp(0, clients.length);
        final List<ClientModel> pageItems = clients.sublist(start, end);

        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'LISTA DE CLIENTE',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: pageItems.length,
                itemBuilder: (context, index) {
                  final client = pageItems[index];
                  final formattedDebt = client.debt.toStringAsFixed(2).replaceAll('.', ',');

                  return ListTile(
                    title: Text(
                      client.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 20, color: Colors.red),
                          onPressed: () => showRemoveDebtDialog(),
                        ),
                        Text(
                          formattedDebt,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 20, color: Colors.green),
                          onPressed: () => showAddDebtDialog(),
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
                    onPressed: currentPage > 0
                        ? () => setState(() => currentPage--)
                        : null,
                  ),
                  for (int i = 0; i < totalPages; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontWeight: currentPage == i
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 18),
                    onPressed: currentPage < totalPages - 1
                        ? () => setState(() => currentPage++)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
                title: const Text('Clients'),
                selected: _selectedOption == 'Clients',
                onTap: () => _onSelectMenuOption('Clients'),
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('History'),
                selected: _selectedOption == 'History',
                onTap: () => _onSelectMenuOption('History'),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: _buildAppBarTitle(),
        actions: _buildAppBarActions(),
      ),
      body: _selectedOption == 'Clients'
          ? _buildClientList()
          : const HistoricalPage(),
    );
  }
}
