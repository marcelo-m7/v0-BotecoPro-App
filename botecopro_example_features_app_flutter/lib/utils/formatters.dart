import 'package:intl/intl.dart';

class Formatters {
  // Formata valor como moeda brasileira
  static String formatarMoeda(double valor) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatter.format(valor);
  }

  // Formata data e hora no padrão brasileiro
  static String formatarDataHora(DateTime dataHora) {
    return DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(dataHora);
  }

  // Formata apenas a data no padrão brasileiro
  static String formatarData(DateTime data) {
    return DateFormat('dd/MM/yyyy', 'pt_BR').format(data);
  }

  // Formata data para API
  static String formatarDataParaApi(DateTime data) {
    return DateFormat('yyyy-MM-dd').format(data);
  }

  // Formata data e hora para API
  static String formatarDataHoraParaApi(DateTime dataHora) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss').format(dataHora);
  }

  // Formata o nome do dia da semana
  static String formatarDiaSemana(DateTime data) {
    return DateFormat('EEEE', 'pt_BR').format(data);
  }

  // Formata data por extenso
  static String formatarDataExtenso(DateTime data) {
    return DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR').format(data);
  }

  // Formata status da mesa
  static String formatarStatusMesa(bool ocupada) {
    return ocupada ? 'Ocupada' : 'Livre';
  }

  // Formata status do pedido
  static String formatarStatusPedido(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return 'Pendente';
      case 'preparando':
        return 'Preparando';
      case 'pronto':
        return 'Pronto';
      case 'entregue':
        return 'Entregue';
      case 'cancelado':
        return 'Cancelado';
      default:
        return 'Desconhecido';
    }
  }

  // Formata método de pagamento
  static String formatarMetodoPagamento(String metodo) {
    switch (metodo.toLowerCase()) {
      case 'dinheiro':
        return 'Dinheiro';
      case 'credito':
        return 'Cartão de Crédito';
      case 'debito':
        return 'Cartão de Débito';
      case 'pix':
        return 'PIX';
      default:
        return 'Desconhecido';
    }
  }
}