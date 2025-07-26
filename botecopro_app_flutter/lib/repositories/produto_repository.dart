import '../services/api_service.dart';
import '../models/api_models.dart';

class ProdutoRepository {
  final ApiService _api = ApiService();

  // Listar todos os produtos
  Future<List<Produto>> getProdutos({int offset = 0, int limit = 1000}) async {
    try {
      final response = await _api.get('table/dbo.Produto', 
        params: {
          'offset': offset,
          'limit': limit,
        }
      );
      
      // Buscar estoque para cada produto
      final produtos = (response as List).map((e) => Produto.fromJson(e)).toList();
      final estoqueResponse = await _api.get('view/dbo.vw_estoque_atual');
      final estoqueList = (estoqueResponse as List)
          .map((e) => EstoqueItem.fromJson(e))
          .toList();
      
      // Adicionar estoque a cada produto
      for (var produto in produtos) {
        final estoqueItem = estoqueList.firstWhere(
          (e) => e.produtoId == produto.id,
          orElse: () => EstoqueItem(
            id: 0,
            produtoId: produto.id!,
            nomeProduto: produto.nome,
            quantidade: 0,
            dataAtualizacao: DateTime.now(),
          ),
        );
        produto.estoque = estoqueItem.quantidade;
      }
      
      return produtos;
    } catch (e) {
      print('Erro ao buscar produtos: $e');
      return [];
    }
  }

  // Obter produto por ID
  Future<Produto?> getProdutoById(int id) async {
    try {
      final response = await _api.get('table/dbo.Produto', 
        params: {
          'filter': "(id_produto=$id)",
          'limit': 1,
        }
      );
      
      if (response is List && response.isNotEmpty) {
        final produto = Produto.fromJson(response.first);
        
        // Buscar estoque deste produto
        final estoqueResponse = await _api.get('view/dbo.vw_estoque_atual', 
          params: {
            'filter': "(id_produto=$id)",
          }
        );
        
        if (estoqueResponse is List && estoqueResponse.isNotEmpty) {
          final estoqueItem = EstoqueItem.fromJson(estoqueResponse.first);
          produto.estoque = estoqueItem.quantidade;
        }
        
        return produto;
      }
      return null;
    } catch (e) {
      print('Erro ao buscar produto: $e');
      return null;
    }
  }

  // Criar novo produto
  Future<bool> criarProduto(Produto produto) async {
    try {
      await _api.post('sp/dbo.sp_cadastrar_produto', produto.toJson());
      return true;
    } catch (e) {
      print('Erro ao criar produto: $e');
      return false;
    }
  }

  // Atualizar produto existente
  Future<bool> atualizarProduto(Produto produto) async {
    try {
      if (produto.id == null) return false;
      
      await _api.post('sp/dbo.sp_atualizar_produto', produto.toJson());
      return true;
    } catch (e) {
      print('Erro ao atualizar produto: $e');
      return false;
    }
  }

  // Ajustar estoque
  Future<bool> ajustarEstoque(int produtoId, double novaQuantidade, String motivo) async {
    try {
      await _api.post('sp/dbo.sp_ajustar_estoque', {
        '@id_produto': produtoId,
        '@quantidade_nova': novaQuantidade,
        '@motivo': motivo,
      });
      return true;
    } catch (e) {
      print('Erro ao ajustar estoque: $e');
      return false;
    }
  }

  // Obter estoque de um produto específico
  Future<double> getEstoqueProduto(int produtoId) async {
    try {
      final response = await _api.get('view/dbo.vw_estoque_atual', 
        params: {
          'filter': "(id_produto=$produtoId)",
        }
      );
      
      if (response is List && response.isNotEmpty) {
        final estoqueItem = EstoqueItem.fromJson(response.first);
        return estoqueItem.quantidade;
      }
      return 0;
    } catch (e) {
      print('Erro ao buscar estoque: $e');
      return 0;
    }
  }

  // Obter lista de produtos com estoque baixo
  Future<List<Produto>> getProdutosEstoqueBaixo(double limiteMinimo) async {
    try {
      // Buscar todos os produtos e seus estoques
      final produtos = await getProdutos();
      return produtos.where((p) => p.estoque <= limiteMinimo).toList();
    } catch (e) {
      print('Erro ao buscar produtos com estoque baixo: $e');
      return [];
    }
  }
}