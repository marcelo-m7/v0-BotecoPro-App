import '../services/api_service.dart';
import '../models/api_models.dart';
import '../utils/api_converter.dart';

class VendaPedidoRepository {
  final ApiService _api = ApiService();

  // --- VENDAS ---
  
  // Abrir uma nova venda (abrir mesa)
  Future<int?> abrirVenda(int mesaId, {String? nomeCliente}) async {
    try {
      final Map<String, dynamic> data = {
        '@id_mesa': mesaId,
      };
      if (nomeCliente != null && nomeCliente.isNotEmpty) {
        data['@nome_cliente'] = nomeCliente;
      }
      
      final response = await _api.post('sp/dbo.sp_abrir_venda_mesa', data);
      if (response != null && response is Map && response.containsKey('id_venda')) {
        return ApiConverter.toInt(response['id_venda']);
      }
      return null;
    } catch (e) {
      print('Erro ao abrir venda: $e');
      return null;
    }
  }

  // Listar vendas abertas
  Future<List<Venda>> getVendasAbertas() async {
    try {
      final response = await _api.get('view/dbo.vw_vendas_abertas', 
        params: {
          'filter': "(status_aberta='True') AND (cancelada='False')",
        }
      );
      return (response as List).map((e) => Venda.fromJson(e)).toList();
    } catch (e) {
      print('Erro ao buscar vendas abertas: $e');
      return [];
    }
  }

  // Obter venda por ID
  Future<Venda?> getVendaById(int id) async {
    try {
      final response = await _api.get('view/dbo.vw_vendas_abertas', 
        params: {
          'filter': "(id_venda=$id)",
          'limit': 1,
        }
      );
      
      if (response is List && response.isNotEmpty) {
        return Venda.fromJson(response.first);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar venda: $e');
      return null;
    }
  }

  // Obter venda aberta de uma mesa
  Future<Venda?> getVendaAbertaMesa(int mesaId) async {
    try {
      final response = await _api.get('view/dbo.vw_vendas_abertas', 
        params: {
          'filter': "(id_mesa=$mesaId) AND (status_aberta='True') AND (cancelada='False')",
          'limit': 1,
        }
      );
      
      if (response is List && response.isNotEmpty) {
        return Venda.fromJson(response.first);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar venda da mesa: $e');
      return null;
    }
  }

  // Fechar venda (fechar mesa)
  Future<bool> fecharVenda(int vendaId, String metodoPagamento) async {
    try {
      await _api.post('sp/dbo.sp_fechar_venda', {
        '@id_venda': vendaId,
        '@metodo_pagamento': metodoPagamento,
      });
      return true;
    } catch (e) {
      print('Erro ao fechar venda: $e');
      return false;
    }
  }

  // Cancelar venda
  Future<bool> cancelarVenda(int vendaId, String motivo) async {
    try {
      await _api.post('sp/dbo.sp_cancelar_venda', {
        '@id_venda': vendaId,
        '@motivo': motivo,
      });
      return true;
    } catch (e) {
      print('Erro ao cancelar venda: $e');
      return false;
    }
  }

  // Total de vendas do dia
  Future<double> getTotalVendasDia() async {
    try {
      final hoje = DateTime.now();
      final dataHoje = "${hoje.year}-${hoje.month.toString().padLeft(2, '0')}-${hoje.day.toString().padLeft(2, '0')}";
      
      final response = await _api.get('view/dbo.vw_vendas_fechadas_dia', 
        params: {
          'filter': "(data_venda >= '$dataHoje')",
        }
      );
      
      double total = 0;
      if (response is List) {
        for (var venda in response) {
          if (venda['valor_total'] != null) {
            total += (venda['valor_total'] is String) 
                ? double.tryParse(venda['valor_total']) ?? 0 
                : (venda['valor_total'] as num?)?.toDouble() ?? 0;
          }
        }
      }
      return total;
    } catch (e) {
      print('Erro ao calcular total de vendas: $e');
      return 0;
    }
  }

  // --- PEDIDOS ---
  
  // Criar novo pedido
  Future<int?> criarPedido(int vendaId, String funcionario) async {
    try {
      final response = await _api.post('sp/dbo.sp_criar_pedido', {
        '@id_venda': vendaId,
        '@funcionario': funcionario,
      });
      
      if (response != null && response is Map && response.containsKey('id_pedido')) {
        return ApiConverter.toInt(response['id_pedido']);
      }
      return null;
    } catch (e) {
      print('Erro ao criar pedido: $e');
      return null;
    }
  }

  // Listar pedidos ativos
  Future<List<Pedido>> getPedidosAtivos() async {
    try {
      final response = await _api.get('view/dbo.vw_pedidos_abertos');
      return (response as List).map((e) => Pedido.fromJson(e)).toList();
    } catch (e) {
      print('Erro ao buscar pedidos ativos: $e');
      return [];
    }
  }

  // Obter pedido por ID com itens
  Future<Pedido?> getPedidoCompletoById(int id) async {
    try {
      final response = await _api.get('view/dbo.vw_pedidos_abertos', 
        params: {
          'filter': "(id_pedido=$id)",
          'limit': 1,
        }
      );
      
      if (response is List && response.isNotEmpty) {
        final pedido = Pedido.fromJson(response.first);
        
        // Buscar itens do pedido
        final itensResponse = await _api.get('view/dbo.vw_pedido_itens', 
          params: {
            'filter': "(id_pedido=$id)",
          }
        );
        
        if (itensResponse is List) {
          pedido.itens = itensResponse.map((e) => ItemPedido.fromJson(e)).toList();
        }
        
        return pedido;
      }
      return null;
    } catch (e) {
      print('Erro ao buscar pedido completo: $e');
      return null;
    }
  }

  // Atualizar status do pedido
  Future<bool> atualizarStatusPedido(int pedidoId, PedidoStatus status) async {
    try {
      await _api.post('sp/dbo.sp_atualizar_status_pedido', {
        '@id_pedido': pedidoId,
        '@status_pedido': Pedido.getStatusNome(status),
      });
      return true;
    } catch (e) {
      print('Erro ao atualizar status do pedido: $e');
      return false;
    }
  }

  // --- ITENS DE PEDIDO ---
  
  // Adicionar item ao pedido
  Future<bool> adicionarItemPedido(ItemPedido item) async {
    try {
      if (item.pedidoId == null) return false;
      
      await _api.post('sp/dbo.sp_adicionar_item_pedido', item.toJson());
      return true;
    } catch (e) {
      print('Erro ao adicionar item ao pedido: $e');
      return false;
    }
  }

  // Remover item do pedido
  Future<bool> removerItemPedido(int itemId) async {
    try {
      await _api.post('sp/dbo.sp_remover_item_pedido', {
        '@id_pedido_item': itemId,
      });
      return true;
    } catch (e) {
      print('Erro ao remover item do pedido: $e');
      return false;
    }
  }

  // Atualizar quantidade de um item
  Future<bool> atualizarQuantidadeItem(int itemId, int novaQuantidade) async {
    try {
      await _api.post('sp/dbo.sp_atualizar_quantidade_item', {
        '@id_pedido_item': itemId,
        '@quantidade': novaQuantidade,
      });
      return true;
    } catch (e) {
      print('Erro ao atualizar quantidade do item: $e');
      return false;
    }
  }
}