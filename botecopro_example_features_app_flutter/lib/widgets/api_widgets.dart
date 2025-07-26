import 'package:flutter/material.dart';
import '../models/api_models.dart';

// Badge de status para pedidos
class StatusBadge extends StatelessWidget {
  final PedidoStatus status;

  const StatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case PedidoStatus.pendente:
        badgeColor = const Color(0xFFFFA000); // Amber
        statusText = 'Pendente';
        statusIcon = Icons.schedule;
        break;
      case PedidoStatus.preparando:
        badgeColor = const Color(0xFF2196F3); // Blue
        statusText = 'Preparando';
        statusIcon = Icons.restaurant;
        break;
      case PedidoStatus.pronto:
        badgeColor = const Color(0xFF4CAF50); // Green
        statusText = 'Pronto';
        statusIcon = Icons.check_circle;
        break;
      case PedidoStatus.entregue:
        badgeColor = const Color(0xFF9E9E9E); // Grey
        statusText = 'Entregue';
        statusIcon = Icons.delivery_dining;
        break;
      case PedidoStatus.cancelado:
        badgeColor = const Color(0xFFF44336); // Red
        statusText = 'Cancelado';
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 16,
            color: badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Diálogo de confirmação
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.content,
    this.confirmText = 'Confirmar',
    this.cancelText = 'Cancelar',
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            cancelText,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: Text(
            confirmText,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
      ],
    );
  }
}

// Loading Dialog
class LoadingDialog extends StatelessWidget {
  final String message;

  const LoadingDialog({Key? key, this.message = 'Carregando...'}) : super(key: key);

  static Future<void> show(BuildContext context, {String message = 'Carregando...'}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingDialog(message: message);
      },
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}