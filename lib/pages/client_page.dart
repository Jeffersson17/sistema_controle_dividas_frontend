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
  final _formKey = GlobalKey<FormState>();
  final _removeFormKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _obsController = TextEditingController();

  final int itemsPerPage = 8;
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

  Future<void> showRemoveDebtDialog(String clientId, double currentDebt) {
    _valueController.clear();
    _obsController.clear();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Quanto o cliente pagou?'),
          content: Form(
            key: _removeFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _valueController,
                  keyboardType: TextInputType.numberWithOptions(
                    signed: true,
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: "Valor",
                    labelStyle: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe o valor do pagamento';
                    }

                    final val = double.tryParse(value.replaceAll(',', '.'));
                    if (val == null) return 'Informe um valor válido';
                    if (val.abs() > currentDebt) return 'Pagamento maior que a dívida';

                    return null;
                  },
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _obsController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: "Deixe uma observação",
                    labelStyle: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_removeFormKey.currentState!.validate()) {
                  final valueText = _valueController.text.replaceAll(',', '.');
                  double value = double.tryParse(valueText) ?? 0.0;
                  final observation = _obsController.text;

                  if (value > 0) {
                    value = -value;
                  }

                  await store.updateClientDebt(
                    clientId: clientId,
                    value: value,
                    observation: observation,
                  );

                  Navigator.pop(context);
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showAddDebtDialog(String clientId) {
    _valueController.clear();
    _obsController.clear();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Quanto o cliente comprou?'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _valueController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: "Valor",
                    labelStyle: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe o valor da compra';
                    }

                    final val = double.tryParse(value.replaceAll(',', '.'));

                    if (val == null || val <= 0) {
                      return 'Informe um valor válido';
                    }

                    return null;
                  },
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _obsController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: "Deixe uma observação",
                    labelStyle: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final valueText = _valueController.text.replaceAll(',', '.');
                  final value = double.parse(valueText);
                  final observation = _obsController.text;

                  await store.updateClientDebt(
                    clientId: clientId,
                    value: value,
                    observation: observation,
                  );

                  Navigator.pop(context);
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }



  void _onSelectMenuOption(String option) {
    Navigator.pop(context); // Close drawer
    setState(() {
      _selectedOption = option;
    });
  }

  Widget _buildClientList() {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05;
    final verticalPadding = 8.0;

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
            Text(
              'LISTA DE CLIENTE',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,  
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Nome',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.remove, color: Colors.transparent, size: 20), // espaço do botão -
                        const SizedBox(width: 8),
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Dívida',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.add, color: Colors.transparent, size: 20), // espaço do botão +
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => store.getClients(),
                child: ListView.builder(
                  itemCount: pageItems.length,
                  itemBuilder: (context, index) {
                    final client = pageItems[index];
                    final formattedDebt = client.debt.toStringAsFixed(2).replaceAll('.', ',');

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              client.name,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          SizedBox(
                            width: 160,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 20, color: Colors.red),
                                  onPressed: () => showRemoveDebtDialog(client.id, client.debt),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  formattedDebt,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 20, color: Colors.green),
                                  onPressed: () => showAddDebtDialog(client.id),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            ),
            const Divider(height: 2),
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
