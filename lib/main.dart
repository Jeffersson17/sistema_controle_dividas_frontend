import 'package:flutter/material.dart';
import 'historical_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mercadinho LEONE',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[800],
          elevation: 4,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18),
          titleLarge: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedOption = 'Clientes';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> clientes = [
    {"nome": "Luana Santos", "divida": 558.85},
    {"nome": "Gustavo Silva", "divida": 250.00},
  ];

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
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            dropdownColor: Colors.green[700],
            value: _selectedOption,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            onChanged: (String? newValue) async {
              setState(() {
                _selectedOption = newValue!;
              });
              if (newValue == 'Histórico') {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoricalPage(),
                  ),
                );
                setState(() {
                  _selectedOption = 'Clientes';
                });
              }
            },
            items: ['Clientes', 'Histórico'].map((value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
          ),
        ),
        const SizedBox(width: 16),
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

  @override
  Widget build(BuildContext context) {
    // Aqui está o estilo que você mencionou
    final TextStyle titles = const TextStyle(
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.bold,
      fontSize: 19,
    );

    return Scaffold(
      appBar: AppBar(
        leading: Image.asset("assets/logo.png"),
        title: _buildAppBarTitle(),
        actions: _buildAppBarActions(),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: PaginatedDataTable(
                header: const Text(
                  'LISTA DE CLIENTES',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28, // aumenta o tamanho da fonte
                    fontWeight: FontWeight.bold, // deixa o texto em negrito
                  ),
                ),
                columns: [
                  DataColumn(label: Text('Nome', style: titles)),
                  DataColumn(label: Text(' Dívida', style: titles)),
                ],
                rowsPerPage: 11,
                source: ClienteDataSource(
                  clientes,
                  onAdd: (index) => addDebt(),
                  onRemove: (index) => removeDebt(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Fonte de dados paginada com os dois clientes
class ClienteDataSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final void Function(int index) onAdd;
  final void Function(int index) onRemove;

  ClienteDataSource(this.data, {required this.onAdd, required this.onRemove});

  @override
  DataRow getRow(int index) {
    final cliente = data[index];
    return DataRow(
      cells: [
        DataCell(Text(cliente["nome"])),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 20, color: Colors.red),
                constraints: const BoxConstraints(),
                onPressed: () => onRemove(index),
              ),
              const SizedBox(width: 8),
              Text(cliente["divida"].toStringAsFixed(2)),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add, size: 20, color: Colors.green),
                constraints: const BoxConstraints(),
                onPressed: () => onAdd(index),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => data.length;
  @override
  int get selectedRowCount => 0;
}
