# Cervantes Tecnologia - Sistema de Cadastro

Este é um aplicativo Flutter desenvolvido para gerenciar cadastros com funcionalidades básicas de inserção, edição e exclusão de registros. O aplicativo utiliza um banco de dados SQLite local para armazenar os dados e inclui um sistema de log para rastrear operações.

## Funcionalidades
- **Cadastrar**: Adicionar novos registros com nome e número (único e maior que zero).
- **Listar**: Visualizar a lista de cadastros com opções para editar ou excluir.
- **Editar**: Alterar o nome de um registro existente.
- **Excluir**: Remover um registro da lista.
- **Log de Operações**: Registra automaticamente inserções, atualizações e exclusões em uma tabela separada.

## Tecnologias Utilizadas
- **Flutter**: Framework para construção da interface e lógica do aplicativo.
- **SQLite**: Banco de dados local para persistência de dados.
- **sqflite**: Pacote Dart para integração com SQLite no Flutter.
- **sqflite_common_ffi**: Suporte para execução em desktop (Windows, Linux, macOS).

## Pré-requisitos
- [Flutter SDK](https://flutter.dev/docs/get-started/install) instalado.
- [Dart](https://dart.dev/get-dart) instalado.
- Editor de código (recomendado: [Visual Studio Code](https://code.visualstudio.com/) com extensões Flutter e Dart).
- Configuração do ambiente para desktop (opcional, para Windows, Linux ou macOS).

### Configuração para Desktop (Windows)
1. Habilite o suporte a desktop no Flutter:
   ```bash
   flutter config --enable-windows-desktop