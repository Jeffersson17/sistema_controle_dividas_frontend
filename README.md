# Sistema de Controle de Dívidas - Frontend

Este projeto é o frontend de um sistema para controle de dívidas de clientes, desenvolvido em Flutter. Ele permite o gerenciamento de clientes, registro de dívidas, pagamento e compras, histórico de operações e autenticação de usuários.

## Funcionalidades

- **Autenticação:** Login seguro com armazenamento de token JWT.
- **Cadastro de Clientes:** Adicione clientes.
- **Controle de Dívidas:** Registre novas dívidas e pagamentos.
- **Histórico:** Visualize o histórico de operações de cada cliente.

## Tecnologias Utilizadas

- **Flutter**: Framework principal para desenvolvimento mobile.
- **Dart**: Linguagem de programação.
- **HTTP**: Comunicação com API backend.
- **Shared Preferences**: Armazenamento local de token de autenticação.
- **Provider/ValueNotifier**: Gerenciamento de estado.

## Estrutura do Projeto

```
lib/
├── data/
│   ├── http/
│   │   ├── http_client.dart
│   │   └── exceptions.dart
│   ├── models/
│   └── repositories/
├── pages/
│   ├── client_page.dart
│   ├── login_page.dart
│   ├── stores/
│   └── utils/
└── main.dart
```

## Como Executar

1. **Instale o Flutter:**
   Siga as instruções em [flutter.dev](https://flutter.dev/docs/get-started/install).

2. **Clone o repositório:**
   ```bash
   git clone https://github.com/Jeffersson17/sistema_controle_dividas_frontend.git
   cd sistema_controle_dividas_frontend
   ```

3. **Instale as dependências:**
   ```bash
   flutter pub get
   ```

4. **Execute o projeto:**
   ```bash
   flutter run
   ```