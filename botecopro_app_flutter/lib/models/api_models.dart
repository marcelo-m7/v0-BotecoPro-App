// Models adaptados para a API real
import 'package:intl/intl.dart';
import '../utils/api_converter.dart';

// Enum para status de mesa
enum MesaStatus { livre, ocupada }

// Enum para status de pedido
enum PedidoStatus { pendente, preparando, pronto, entregue, cancelado }

// Enum para método de pagamento
enum MetodoPagamento { dinheiro, credito, debito, pix }

// Enum para categoria de produto
enum CategoriaProduto { bebida, comida, outro }

// Modelo de Fornecedor
class Fornecedor {
  final int? id;
  String nome;
  String contato;
  String telefone;
  String email;
  String detalhes;

  Fornecedor({
    this.id,
    required this.nome,
    required this.contato,
    this.telefone = '',
    this.email = '',
    this.detalhes = '',
  });

  Fornecedor copyWith({
    String? nome,
    String? contato,
    String? telefone,
    String? email,
    String? detalhes,
  }) {
    return Fornecedor(
      id: id,
      nome: nome ?? this.nome,
      contato: contato ?? this.contato,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
      detalhes: detalhes ?? this.detalhes,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (id != null) data['@id_fornecedor'] = id;
    data['@nome'] = nome;
    data['@contato'] = contato;
    data['@telefone'] = telefone;
    data['@email'] = email;
    data['@detalhes'] = detalhes;
    return data;
  }

  factory Fornecedor.fromJson(Map<String, dynamic> json) {
    return Fornecedor(
      id: ApiConverter.toInt(json['id_fornecedor']),
      nome: ApiConverter.toStr(json['nome']) ?? '',
      contato: ApiConverter.toStr(json['contato']) ?? '',
      telefone: ApiConverter.toStr(json['telefone']) ?? '',
      email: ApiConverter.toStr(json['email']) ?? '',
      detalhes: ApiConverter.toStr(json['detalhes']) ?? '',
    );
  }
}

// Modelo de Produto
class Produto {
  final int? id;
  String nome;
  CategoriaProduto categoria;
  double preco;
  double estoque;
  int? fornecedorId;
  String descricao;
  String unidade;
  bool controlaEstoque;

  Produto({
    this.id,
    required this.nome,
    required this.categoria,
    required this.preco,
    this.estoque = 0,
    this.fornecedorId,
    this.descricao = '',
    this.unidade = 'unidade',
    this.controlaEstoque = true,
  });

  Produto copyWith({
    String? nome,
    CategoriaProduto? categoria,
    double? preco,
    double? estoque,
    int? fornecedorId,
    String? descricao,
    String? unidade,
    bool? controlaEstoque,
  }) {
    return Produto(
      id: id,
      nome: nome ?? this.nome,
      categoria: categoria ?? this.categoria,
      preco: preco ?? this.preco,
      estoque: estoque ?? this.estoque,
      fornecedorId: fornecedorId ?? this.fornecedorId,
      descricao: descricao ?? this.descricao,
      unidade: unidade ?? this.unidade,
      controlaEstoque: controlaEstoque ?? this.controlaEstoque,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (id != null) data['@id_produto'] = id;
    data['@nome'] = nome;
    data['@tipo_produto'] = getCategoriaNome(categoria);
    data['@preco_venda'] = preco;
    data['@id_fornecedor'] = fornecedorId;
    data['@descricao'] = descricao;
    data['@unidade_base'] = unidade;
    data['@controla_estoque'] = controlaEstoque ? 'True' : 'False';
    return data;
  }

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: ApiConverter.toInt(json['id_produto']),
      nome: ApiConverter.toStr(json['nome']) ?? '',
      categoria: getCategoriaFromNome(ApiConverter.toStr(json['tipo_produto']) ?? 'outro'),
      preco: ApiConverter.toDouble(json['preco_venda']) ?? 0.0,
      estoque: 0, // Será preenchido pelo estoque
      fornecedorId: ApiConverter.toInt(json['id_fornecedor']),
      descricao: ApiConverter.toStr(json['descricao']) ?? '',
      unidade: ApiConverter.toStr(json['unidade_base']) ?? 'unidade',
      controlaEstoque: ApiConverter.toBool(json['controla_estoque']),
    );
  }

  static String getCategoriaNome(CategoriaProduto categoria) {
    switch (categoria) {
      case CategoriaProduto.bebida:
        return 'bebida';
      case CategoriaProduto.comida:
        return 'comida';
      case CategoriaProduto.outro:
        return 'outro';
    }
  }

  static CategoriaProduto getCategoriaFromNome(String nome) {
    switch (nome.toLowerCase()) {
      case 'bebida':
        return CategoriaProduto.bebida;
      case 'comida':
        return CategoriaProduto.comida;
      default:
        return CategoriaProduto.outro;
    }
  }
}

// Modelo de estoque
class EstoqueItem {
  final int id;
  final int produtoId;
  final String nomeProduto;
  final double quantidade;
  final DateTime dataAtualizacao;

  EstoqueItem({
    required this.id,
    required this.produtoId,
    required this.nomeProduto,
    required this.quantidade,
    required this.dataAtualizacao,
  });

  factory EstoqueItem.fromJson(Map<String, dynamic> json) {
    return EstoqueItem(
      id: ApiConverter.toInt(json['id_estoque']) ?? 0,
      produtoId: ApiConverter.toInt(json['id_produto']) ?? 0,
      nomeProduto: ApiConverter.toStr(json['nome_produto']) ?? '',
      quantidade: ApiConverter.toDouble(json['quantidade_disponivel']) ?? 0.0,
      dataAtualizacao: json['data_atualizacao'] != null 
          ? DateTime.parse(json['data_atualizacao'].toString())
          : DateTime.now(),
    );
  }
}

// Modelo de Mesa
class Mesa {
  final int? id;
  int numero;
  MesaStatus status;
  int capacidade;
  String? nomeCliente;
  int? vendaAtualId;

  Mesa({
    this.id,
    required this.numero,
    this.status = MesaStatus.livre,
    this.capacidade = 4,
    this.nomeCliente,
    this.vendaAtualId,
  });

  Mesa copyWith({
    int? numero,
    MesaStatus? status,
    int? capacidade,
    String? nomeCliente,
    int? vendaAtualId,
  }) {
    return Mesa(
      id: id,
      numero: numero ?? this.numero,
      status: status ?? this.status,
      capacidade: capacidade ?? this.capacidade,
      nomeCliente: nomeCliente ?? this.nomeCliente,
      vendaAtualId: vendaAtualId ?? this.vendaAtualId,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (id != null) data['@id_mesa'] = id;
    data['@numero_mesa'] = numero;
    data['@status_ocupada'] = (status == MesaStatus.ocupada) ? 'True' : 'False';
    data['@quantidade_lugares'] = capacidade;
    data['@nome_cliente'] = nomeCliente ?? '';
    return data;
  }

  factory Mesa.fromJson(Map<String, dynamic> json) {
    return Mesa(
      id: ApiConverter.toInt(json['id_mesa']),
      numero: ApiConverter.toInt(json['numero_mesa']) ?? 0,
      status: ApiConverter.toBool(json['status_ocupada']) ? MesaStatus.ocupada : MesaStatus.livre,
      capacidade: ApiConverter.toInt(json['quantidade_lugares']) ?? 4,
      nomeCliente: ApiConverter.toStr(json['nome_cliente']),
      // vendaAtualId será preenchido a partir do vw_vendas_abertas
    );
  }
}

// Modelo de Pedido
class Pedido {
  final int? id;
  final int? vendaId;
  final int? mesaId;
  final int? mesaNumero;
  final DateTime dataPedido;
  final String funcionario;
  PedidoStatus status;
  List<ItemPedido> itens;

  Pedido({
    this.id,
    this.vendaId,
    this.mesaId,
    this.mesaNumero,
    DateTime? dataPedido,
    this.funcionario = '',
    this.status = PedidoStatus.pendente,
    List<ItemPedido>? itens,
  }) : 
    dataPedido = dataPedido ?? DateTime.now(),
    itens = itens ?? [];

  double get total => itens.fold(0, (sum, item) => sum + item.total);

  Pedido copyWith({
    int? vendaId,
    int? mesaId,
    int? mesaNumero,
    DateTime? dataPedido,
    String? funcionario,
    PedidoStatus? status,
    List<ItemPedido>? itens,
  }) {
    return Pedido(
      id: id,
      vendaId: vendaId ?? this.vendaId,
      mesaId: mesaId ?? this.mesaId,
      mesaNumero: mesaNumero ?? this.mesaNumero,
      dataPedido: dataPedido ?? this.dataPedido,
      funcionario: funcionario ?? this.funcionario,
      status: status ?? this.status,
      itens: itens ?? this.itens,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (id != null) data['@id_pedido'] = id;
    data['@id_venda'] = vendaId;
    data['@funcionario'] = funcionario;
    data['@status_pedido'] = getStatusNome(status);
    return data;
  }

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: ApiConverter.toInt(json['id_pedido']),
      vendaId: ApiConverter.toInt(json['id_venda']),
      mesaId: ApiConverter.toInt(json['id_mesa']),
      mesaNumero: ApiConverter.toInt(json['numero_mesa']),
      dataPedido: json['data_pedido'] != null 
          ? DateTime.parse(json['data_pedido'].toString()) 
          : DateTime.now(),
      funcionario: ApiConverter.toStr(json['nome_funcionario']) ?? '',
      status: getStatusFromNome(ApiConverter.toStr(json['status_pedido']) ?? 'pendente'),
    );
  }

  static String getStatusNome(PedidoStatus status) {
    switch (status) {
      case PedidoStatus.pendente:
        return 'pendente';
      case PedidoStatus.preparando:
        return 'preparando';
      case PedidoStatus.pronto:
        return 'pronto';
      case PedidoStatus.entregue:
        return 'entregue';
      case PedidoStatus.cancelado:
        return 'cancelado';
    }
  }

  static PedidoStatus getStatusFromNome(String nome) {
    switch (nome.toLowerCase()) {
      case 'pendente':
        return PedidoStatus.pendente;
      case 'preparando':
        return PedidoStatus.preparando;
      case 'pronto':
        return PedidoStatus.pronto;
      case 'entregue':
        return PedidoStatus.entregue;
      case 'cancelado':
        return PedidoStatus.cancelado;
      default:
        return PedidoStatus.pendente;
    }
  }
}

// Modelo de Item de Pedido
class ItemPedido {
  final int? id;
  final int? pedidoId;
  final String tipoItem; // 'produto' ou 'receita'
  final int itemId;
  final String nomeItem;
  final int quantidade;
  final double precoUnitario;
  final String observacao;
  final PedidoStatus status; // Status não está na API, mantido para compatibilidade

  ItemPedido({
    this.id,
    this.pedidoId,
    required this.tipoItem,
    required this.itemId,
    required this.nomeItem,
    required this.quantidade,
    required this.precoUnitario,
    this.observacao = '',
    this.status = PedidoStatus.pendente,
  });

  double get total => precoUnitario * quantidade;

  ItemPedido copyWith({
    int? pedidoId,
    String? tipoItem,
    int? itemId,
    String? nomeItem,
    int? quantidade,
    double? precoUnitario,
    String? observacao,
    PedidoStatus? status,
  }) {
    return ItemPedido(
      id: id,
      pedidoId: pedidoId ?? this.pedidoId,
      tipoItem: tipoItem ?? this.tipoItem,
      itemId: itemId ?? this.itemId,
      nomeItem: nomeItem ?? this.nomeItem,
      quantidade: quantidade ?? this.quantidade,
      precoUnitario: precoUnitario ?? this.precoUnitario,
      observacao: observacao ?? this.observacao,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (id != null) data['@id_pedido_item'] = id;
    data['@id_pedido'] = pedidoId;
    data['@tipo_item'] = tipoItem;
    data['@id_item'] = itemId;
    data['@quantidade'] = quantidade;
    data['@preco_unitario'] = precoUnitario;
    data['@observacao'] = observacao;
    return data;
  }

  factory ItemPedido.fromJson(Map<String, dynamic> json) {
    return ItemPedido(
      id: ApiConverter.toInt(json['id_pedido_item']),
      pedidoId: ApiConverter.toInt(json['id_pedido']),
      tipoItem: ApiConverter.toStr(json['tipo_item']) ?? 'produto',
      itemId: ApiConverter.toInt(json['id_item']) ?? 0,
      nomeItem: ApiConverter.toStr(json['nome_item']) ?? '',
      quantidade: ApiConverter.toInt(json['quantidade']) ?? 1,
      precoUnitario: ApiConverter.toDouble(json['preco_unitario']) ?? 0.0,
      observacao: ApiConverter.toStr(json['observacao']) ?? '',
      // Status não disponível na API, usamos pendente como padrão
    );
  }
}

// Modelo de Venda
class Venda {
  final int? id;
  final int mesaId;
  final int mesaNumero;
  final String? nomeCliente;
  final DateTime dataVenda;
  final bool aberta;
  final bool cancelada;
  final double? valorTotal; // Pode não estar disponível em todas as visualizações
  final String? metodoPagamento;

  Venda({
    this.id,
    required this.mesaId,
    required this.mesaNumero,
    this.nomeCliente,
    DateTime? dataVenda,
    this.aberta = true,
    this.cancelada = false,
    this.valorTotal,
    this.metodoPagamento,
  }) : dataVenda = dataVenda ?? DateTime.now();

  Venda copyWith({
    int? mesaId,
    int? mesaNumero,
    String? nomeCliente,
    DateTime? dataVenda,
    bool? aberta,
    bool? cancelada,
    double? valorTotal,
    String? metodoPagamento,
  }) {
    return Venda(
      id: id,
      mesaId: mesaId ?? this.mesaId,
      mesaNumero: mesaNumero ?? this.mesaNumero,
      nomeCliente: nomeCliente ?? this.nomeCliente,
      dataVenda: dataVenda ?? this.dataVenda,
      aberta: aberta ?? this.aberta,
      cancelada: cancelada ?? this.cancelada,
      valorTotal: valorTotal ?? this.valorTotal,
      metodoPagamento: metodoPagamento ?? this.metodoPagamento,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (id != null) data['@id_venda'] = id;
    data['@id_mesa'] = mesaId;
    data['@nome_cliente'] = nomeCliente ?? '';
    return data;
  }

  factory Venda.fromJson(Map<String, dynamic> json) {
    return Venda(
      id: ApiConverter.toInt(json['id_venda']),
      mesaId: ApiConverter.toInt(json['id_mesa']) ?? 0,
      mesaNumero: ApiConverter.toInt(json['numero_mesa']) ?? 0,
      nomeCliente: ApiConverter.toStr(json['nome_cliente']),
      dataVenda: json['data_venda'] != null 
          ? DateTime.parse(json['data_venda'].toString()) 
          : DateTime.now(),
      aberta: ApiConverter.toBool(json['status_aberta']),
      cancelada: ApiConverter.toBool(json['cancelada']),
      valorTotal: ApiConverter.toDouble(json['valor_total']),
      metodoPagamento: ApiConverter.toStr(json['metodo_pagamento']),
    );
  }
}

// Utilidades para conversão de data
String formatApiDateTime(DateTime date) {
  return DateFormat("yyyy-MM-ddTHH:mm:ss").format(date);
}

DateTime parseApiDateTime(String dateString) {
  return DateFormat("yyyy-MM-ddTHH:mm:ss").parse(dateString);
}