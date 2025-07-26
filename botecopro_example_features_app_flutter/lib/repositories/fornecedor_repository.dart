import '../services/api_service.dart';
import '../models/api_models.dart';

class FornecedorRepository {
  final ApiService _api = ApiService();

  // Listar todos os fornecedores
  Future<List<Fornecedor>> getFornecedores({int offset = 0, int limit = 1000}) async {
    try {
      final response = await _api.get('table/dbo.Fornecedor', 
        params: {
          'offset': offset,
          'limit': limit,
        }
      );
      return (response as List).map((e) => Fornecedor.fromJson(e)).toList();
    } catch (e) {
      print('Erro ao buscar fornecedores: $e');
      return [];
    }
  }

  // Obter fornecedor por ID
  Future<Fornecedor?> getFornecedorById(int id) async {
    try {
      final response = await _api.get('table/dbo.Fornecedor', 
        params: {
          'filter': "(id_fornecedor=$id)",
          'limit': 1,
        }
      );
      if (response is List && response.isNotEmpty) {
        return Fornecedor.fromJson(response.first);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar fornecedor: $e');
      return null;
    }
  }

  // Criar novo fornecedor
  Future<bool> criarFornecedor(Fornecedor fornecedor) async {
    try {
      await _api.post('sp/dbo.sp_cadastrar_fornecedor', fornecedor.toJson());
      return true;
    } catch (e) {
      print('Erro ao criar fornecedor: $e');
      return false;
    }
  }

  // Atualizar fornecedor existente
  Future<bool> atualizarFornecedor(Fornecedor fornecedor) async {
    try {
      if (fornecedor.id == null) return false;
      
      await _api.post('sp/dbo.sp_atualizar_fornecedor', fornecedor.toJson());
      return true;
    } catch (e) {
      print('Erro ao atualizar fornecedor: $e');
      return false;
    }
  }

  // Excluir fornecedor
  Future<bool> excluirFornecedor(int id) async {
    try {
      await _api.post('sp/dbo.sp_excluir_fornecedor', {'@id_fornecedor': id});
      return true;
    } catch (e) {
      print('Erro ao excluir fornecedor: $e');
      return false;
    }
  }
}