import 'package:flutter/material.dart';

class ErrorHandler {
  // Exibe um diálogo de erro
  static void mostrarErro(BuildContext context, String mensagem) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Erro'),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Exibe um SnackBar de erro
  static void mostrarErroSnackBar(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Exibe um SnackBar de sucesso
  static void mostrarSucessoSnackBar(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Trata erros de API
  static String tratarErroApi(dynamic erro) {
    if (erro.toString().contains('Connection refused') ||
        erro.toString().contains('connection timeout') ||
        erro.toString().contains('Network is unreachable')) {
      return 'Não foi possível conectar ao servidor. Verifique sua conexão com a internet.';
    }
    
    if (erro.toString().contains('404')) {
      return 'Recurso não encontrado no servidor.';
    }
    
    if (erro.toString().contains('401') || erro.toString().contains('403')) {
      return 'Acesso não autorizado. Por favor, faça login novamente.';
    }
    
    if (erro.toString().contains('500')) {
      return 'Erro interno do servidor. Por favor, tente novamente mais tarde.';
    }
    
    return 'Ocorreu um erro: ${erro.toString()}';
  }
}