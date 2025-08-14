// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../data/http/exceptions.dart';
import '../data/http/http_client.dart';
import '../data/models/client_model.dart';
import '../data/repositories/client_repository.dart';
import '../pages/stores/store_client.dart';
import '../utils/logout.dart';
import 'create_client.dart';
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
  List<ClientModel> _filteredClients = [];

  @override
  void initState() {
    super.initState();
    final client = HttpClient();
    final repository = ClientRepository(client: client);
    store = ClientStore(repository: repository);

    store.isLoading.addListener(() => setState(() {}));
    store.state.addListener(() => setState(() {}));
    store.erro.addListener(() => setState(() {}));

    _loadClients();
  }

  Widget _buildAppBarTitle() {
    return _isSearching
        ? TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Procurar por...',
              hintStyle: TextStyle(color: Colors.white),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              final allClients = store.state.value;
              final query = value.toLowerCase();

              setState(() {
                currentPage = 0;
                _filteredClients = allClients
                    .where(
                      (client) => client.name.toLowerCase().contains(query),
                    )
                    .toList();
              });
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
              _filteredClients = [];
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

  Future<void> _loadClients() async {
    try {
      await store.getClients();
    } on UnauthorizedException catch (_) {
      if (!mounted) return;
      await handleLogout(context);
    } on SocketException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Erro: sem conexão com a internet. Verifique sua conexão e tente novamente.',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          content: Text('Erro: não foi possível carregar os clientes.'),
        ),
      );
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
                const SizedBox(height: 24),
                TextFormField(
                  controller: _valueController,
                  keyboardType: TextInputType.numberWithOptions(
                    signed: true,
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: "Valor do pagamento",
                    labelStyle: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green.shade900),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe o valor do pagamento';
                    }

                    final val = double.tryParse(value.replaceAll(',', '.'));
                    if (val == null) return 'Informe um valor válido';
                    if (val.abs() > currentDebt) {
                      return 'Pagamento maior que a dívida';
                    }
                    return null;
                  },
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _obsController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: "Deixe uma observação (opcional)",
                    labelStyle: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(Icons.comment_sharp),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green.shade900),
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

                  // Caixa de confirmação
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirmar operação'),
                      content: Text(
                        'Tem certeza que deseja registrar este pagamento no valor de R\$${value.toStringAsFixed(2)}?',
                      ),
                      contentTextStyle: const TextStyle(fontSize: 16),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.green[800],
                          ),
                          child: const Text(
                            'Confirmar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm != true) return;

                  try {
                    await store.updateClientDebt(
                      clientId: clientId,
                      value: value,
                      observation: observation,
                    );
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  } on UnauthorizedException catch (_) {
                    if (!mounted) return;
                    await handleLogout(context);
                  } on SocketException {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            'Erro: sem conexão com a internet. Verifique sua conexão e tente novamente.',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
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
                const SizedBox(height: 24),
                TextFormField(
                  controller: _valueController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: "Valor da compra",
                    labelStyle: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green.shade900),
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
                const SizedBox(height: 24),
                TextFormField(
                  controller: _obsController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: "Deixe uma observação (opcional)",
                    labelStyle: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(Icons.comment),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green.shade900),
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

                  // Caixa de confirmação
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirmar operação'),
                      content: Text(
                        'Tem certeza que deseja registrar esta compra no valor de R\$${value.toStringAsFixed(2)}?',
                      ),
                      contentTextStyle: const TextStyle(fontSize: 16),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.green[800],
                          ),
                          child: const Text(
                            'Confirmar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm != true) return;

                  try {
                    await store.updateClientDebt(
                      clientId: clientId,
                      value: value,
                      observation: observation,
                    );
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  } on UnauthorizedException catch (_) {
                    if (!mounted) return;
                    await handleLogout(context);
                  } on SocketException {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            'Erro: sem conexão com a internet. Verifique sua conexão e tente novamente.',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
              child: const Text(
                'Enviar',
                style: TextStyle(color: Colors.black),
              ),
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

        final dataToShow =
            _filteredClients.isNotEmpty || _searchController.text.isNotEmpty
            ? _filteredClients
            : clients;
        final totalPages = (dataToShow.length / itemsPerPage).ceil();
        final int start = currentPage * itemsPerPage;
        final int end = (start + itemsPerPage).clamp(0, dataToShow.length);
        final List<ClientModel> pageItems = dataToShow.sublist(start, end);

        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'LISTA DE CLIENTES',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.remove,
                          color: Colors.transparent,
                          size: 20,
                        ), // espaço do botão -
                        const SizedBox(width: 8),
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Dívida',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.add,
                          color: Colors.transparent,
                          size: 20,
                        ), // espaço do botão +
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _loadClients();
                },
                child: ListView.builder(
                  itemCount: pageItems.length,
                  itemBuilder: (context, index) {
                    final client = pageItems[index];
                    final formattedDebt = client.debt
                        .toStringAsFixed(2)
                        .replaceAll('.', ',');

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              client.name,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          SizedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => showRemoveDebtDialog(
                                    client.id,
                                    client.debt,
                                  ),
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
                                  icon: const Icon(
                                    Icons.add,
                                    size: 20,
                                    color: Colors.green,
                                  ),
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: currentPage > 0
                        ? () => setState(() => currentPage--)
                        : null,
                  ),
                  Text(
                    'Página ${currentPage + 1} de $totalPages',
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 20),
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
              // ...existing code...
              ListTile(
                leading: Icon(
                  Icons.people,
                  color: _selectedOption == 'Clients'
                      ? Colors.green[800]
                      : Colors.black54,
                ),
                title: Text(
                  'Clientes',
                  style: TextStyle(
                    color: _selectedOption == 'Clients'
                        ? Colors.green[800]
                        : Colors.black87,
                    fontWeight: _selectedOption == 'Clients'
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                selected: _selectedOption == 'Clients',
                onTap: () => _onSelectMenuOption('Clients'),
              ),
              ListTile(
                leading: Icon(
                  Icons.history,
                  color: _selectedOption == 'History'
                      ? Colors.green[800]
                      : Colors.black54,
                ),
                title: Text(
                  'Histórico',
                  style: TextStyle(
                    color: _selectedOption == 'History'
                        ? Colors.green[800]
                        : Colors.black87,
                    fontWeight: _selectedOption == 'History'
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                selected: _selectedOption == 'History',
                onTap: () => _onSelectMenuOption('History'),
              ),
              // ...existing code...
            ],
          ),
        ),
      ),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.green[800],
        title: _buildAppBarTitle(),
        actions: _buildAppBarActions(),
      ),
      body: _selectedOption == 'Clients'
          ? _buildClientList()
          : HistoricalPage(searchTerm: _searchController.text),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateClient()),
          );
          if (created == true) {
            store.getClients();
          }
        },
        tooltip: 'Cadastrar Cliente',
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        shape: CircleBorder(),
        child: Icon(Icons.person_add),
      ),
    );
  }
}
