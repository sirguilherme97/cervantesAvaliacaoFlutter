import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

List<String> titles = <String>['Cadastrar', 'Listar'];

void main() {
  // Inicializa o sqflite para desktop (Windows, Linux, MacOS)
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 12, 38, 240),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(218, 70, 32, 1),
        ),
      ),
      home: const MyAppBar(),
    );
  }
}

class MyAppBar extends StatefulWidget {
  const MyAppBar({super.key});

  @override
  State<MyAppBar> createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  final Color oddItemColor = const Color.fromARGB(255, 255, 255, 255).withOpacity(0.05);
  final Color evenItemColor = const Color.fromARGB(255, 255, 255, 255).withOpacity(0.15);

  // Controladores para os inputs
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();

  // Lista que vai armazenar os dados cadastrados
  List<Map<String, dynamic>> cadastro = [];

  static const int tabsCount = 2;

  void _showEditDialog(String currentNome, int numero) {
    final editController = TextEditingController(text: currentNome);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Nome'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(labelText: 'Novo nome'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final novoNome = editController.text.trim();
              if (novoNome.isNotEmpty) {
                await DatabaseHelper().updateCadastro(novoNome, numero);
                await _loadCadastros();
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCadastros();
  }

  Future<void> _loadCadastros() async {
    final data = await DatabaseHelper().getCadastros();
    setState(() {
      cadastro = data;
    });
  }

  @override
  void dispose() {
    nomeController.dispose();
    numeroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: tabsCount,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cervantes Tecnologia'),
          scrolledUnderElevation: 4.0,
          shadowColor: Theme.of(context).shadowColor,
          bottom: TabBar(
            tabs: <Widget>[
              Tab(icon: const Icon(Icons.add), text: titles[0]),
              Tab(
                icon: const Icon(Icons.format_list_bulleted),
                text: titles[1],
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            // Aba "Cadastrar"
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    width: 500,
                    child: TextField(
                      controller: nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 500,
                    child: TextField(
                      controller: numeroController,
                      decoration: const InputDecoration(
                        labelText: 'Número',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 250,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () async {
                        final nome = nomeController.text.trim();
                        final numeroStr = numeroController.text.trim();

                        if (nome.isEmpty || numeroStr.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Preencha todos os campos'),
                            ),
                          );
                          return;
                        }

                        final numero = int.tryParse(numeroStr);
                        if (numero == null || numero <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Número deve ser um valor inteiro positivo',
                              ),
                            ),
                          );
                          return;
                        }

                        try {
                          await DatabaseHelper().insertCadastro(nome, numero);
                          nomeController.clear();
                          numeroController.clear();

                          // Atualizar a lista após inserção
                          final data = await DatabaseHelper().getCadastros();
                          setState(() {
                            cadastro = data;
                          });
                        } catch (e) {
                          String mensagem = 'Erro ao inserir dados';
                          if (e.toString().contains(
                            'UNIQUE constraint failed',
                          )) {
                            mensagem = 'O número $numero já está cadastrado!';
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(mensagem),
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                            ),
                          );
                        }
                      },

                      child: const Text('Adicionar'),
                    ),
                  ),
                  // Removed the Expanded widget with ListView.builder
                ],
              ),
            ),

            // Aba "Listar"
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: cadastro.isEmpty
                  ? const Center(child: Text('Nenhum cadastro ainda'))
                  : SizedBox(
                      height: 400,
                      child: ListView.builder(
                        itemCount: cadastro.length,
                        itemBuilder: (context, index) {
                          final item = cadastro[index];
                          final color = index.isOdd
                              ? oddItemColor
                              : evenItemColor;

                          return ListTile(
                            tileColor: color,
                            title: Text('Nome: ${item['nome']}'),
                            subtitle: Text('Número: ${item['numero']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                  onPressed: () {
                                    _showEditDialog(
                                      item['nome'],
                                      item['numero'],
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                  onPressed: () async {
                                    await DatabaseHelper().deleteCadastro(
                                      item['numero'],
                                    );
                                    await _loadCadastros();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
