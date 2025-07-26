import '../services/api_service.dart';
import '../models/api_models.dart';

class MesaRepository {
  final ApiService _api = ApiService();

  // Listar todas as mesas
  Future<List<Mesa>> getMesas({int offset = 0, int limit = 100}) async {
    try {
      final response = await _api.get('table/dbo.Mesa', 
        params: {
          'offset': offset,
          'limit': limit,
        }
      );
      
      final mesas = (response as List).map((e) => Mesa.fromJson(e)).toList();
      
      // Buscar vendas abertas para associar às mesas
      final vendasResponse = await _api.get('view/dbo.vw_vendas_abertas');
      final vendas = (vendasResponse as List)
          .map((e) => Venda.fromJson(e))
          .where((v) => v.aberta && !v.cancelada)
          .toList();
      
      // Associar vendas às mesas
      for (var mesa in mesas) {
        final venda = vendas.firstWhere(
          (v) => v.mesaId == mesa.id,
          orElse: () => Venda(mesaId: 0, mesaNumero: 0, aberta: false),
        );
        
        if (venda.mesaId != 0) {
          mesa.vendaAtualId = venda.id;
        }
      }
      
      return mesas;
    } catch (e) {
      print('Erro ao buscar mesas: $e');
      return [];
    }
  }

  // Obter mesa por ID
  Future<Mesa?> getMesaById(int id) async {
    try {
      final response = await _api.get('table/dbo.Mesa', 
        params: {
          'filter': "(id_mesa=$id)",
          'limit': 1,
        }
      );
      
      if (response is List && response.isNotEmpty) {
        final mesa = Mesa.fromJson(response.first);
        
        // Buscar venda aberta nesta mesa
        final vendasResponse = await _api.get('view/dbo.vw_vendas_abertas', 
          params: {
            'filter': "(id_mesa=$id) AND (status_aberta='True') AND (cancelada='False')",
          }
        );
        
        if (vendasResponse is List && vendasResponse.isNotEmpty) {
          final venda = Venda.fromJson(vendasResponse.first);
          mesa.vendaAtualId = venda.id;
        }
        
        return mesa;
      }
      return null;
    } catch (e) {
      print('Erro ao buscar mesa: $e');
      return null;
    }
  }

  // Criar nova mesa
  Future<bool> criarMesa(Mesa mesa) async {
    try {
      await _api.post('sp/dbo.sp_cadastrar_mesa', mesa.toJson());
      return true;
    } catch (e) {
      print('Erro ao criar mesa: $e');
      return false;
    }
  }

  // Atualizar mesa existente
  Future<bool> atualizarMesa(Mesa mesa) async {
    try {
      if (mesa.id == null) return false;
      
      await _api.post('sp/dbo.sp_atualizar_mesa', mesa.toJson());
      return true;
    } catch (e) {
      print('Erro ao atualizar mesa: $e');
      return false;
    }
  }

  // Obter mesas ocupadas
  Future<int> getQuantidadeMesasOcupadas() async {
    try {
      final mesas = await getMesas();
      return mesas.where((m) => m.status == MesaStatus.ocupada).length;
    } catch (e) {
      print('Erro ao contar mesas ocupadas: $e');
      return 0;
    }
  }
}