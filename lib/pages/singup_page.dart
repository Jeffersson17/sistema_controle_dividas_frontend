import 'package:flutter/material.dart';
import 'package:sistema_controle_dividas_frontend/pages/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  void _cadastrar() {
    if (_formKey.currentState!.validate()) {
      final user = _userController.text;
      final email = _emailController.text;

      // Aqui você pode enviar os dados para a API ou salvar localmente
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cadastro realizado para $user $email')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Cadastro'),
        backgroundColor: Colors.green[800],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                const SizedBox(height: 24),
                TextFormField(
                  controller: _userController,
                  decoration: InputDecoration(
                    labelText: "Usuário",
                    labelStyle: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Informe o usuário' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "E-mail",
                    labelStyle: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  style: TextStyle(fontSize: 16),
                  validator: (value) =>
                    value == null || !value.contains('@') ? 'E-mail inválido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _senhaController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Senha",
                    labelStyle: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  validator: (value) =>
                      value != null && value.length < 4 ? 'Senha muito curta' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmarSenhaController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Confirmar senha",
                    labelStyle: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  validator: (value) => value != _senhaController.text
                      ? 'Senhas não coincidem'
                      : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _cadastrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Cadastrar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
