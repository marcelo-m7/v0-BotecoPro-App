import '../models/api_models.dart';
import '../repositories/fornecedor_repository.dart';
import '../repositories/produto_repository.dart';
import '../repositories/mesa_repository.dart';
import '../repositories/venda_pedido_repository.dart';

// Serviço centralizado para acessar todas as funcionalidades
class BotecoService {
  static final BotecoService _instance = BotecoService._internal();
  factory BotecoService() => _instance;
  BotecoService._internal();

  // Repositórios
  final FornecedorRepository _fornecedorRepo = FornecedorRepository();
  final ProdutoRepository _produtoRepo = ProdutoRepository();
  final MesaRepository _mesaRepo = MesaRepository();
  final VendaPedidoRepository _vendaPedidoRepo = VendaPedidoRepository();

  // --- Métodos para Fornecedores ---
  Future<List<Fornecedor>> getFornecedores() => _fornecedorRepo.getFornecedores();
  Future<Fornecedor?> getFornecedorById(int id) => _fornecedorRepo.getFornecedorById(id);
  Future<bool> criarFornecedor(Fornecedor fornecedor) => _fornecedorRepo.criarFornecedor(fornecedor);
  Future<bool> atualizarFornecedor(Fornecedor fornecedor) => _fornecedorRepo.atualizarFornecedor(fornecedor);
  Future<bool> excluirFornecedor(int id) => _fornecedorRepo.excluirFornecedor(id);

  // --- Métodos para Produtos ---
  Future<List<Produto>> getProdutos() => _produtoRepo.getProdutos();
  Future<Produto?> getProdutoById(int id) => _produtoRepo.getProdutoById(id);
  Future<bool> criarProduto(Produto produto) => _produtoRepo.criarProduto(produto);
  Future<bool> atualizarProduto(Produto produto) => _produtoRepo.atualizarProduto(produto);
  Future<bool> ajustarEstoque(int produtoId, double novaQuantidade, String motivo) => 
      _produtoRepo.ajustarEstoque(produtoId, novaQuantidade, motivo);
  Future<double> getEstoqueProduto(int produtoId) => _produtoRepo.getEstoqueProduto(produtoId);
  Future<List<Produto>> getProdutosEstoqueBaixo(double limiteMinimo) => 
      _produtoRepo.getProdutosEstoqueBaixo(limiteMinimo);

  // --- Métodos para Mesas ---
  Future<List<Mesa>> getMesas() => _mesaRepo.getMesas();
  Future<Mesa?> getMesaById(int id) => _mesaRepo.getMesaById(id);
  Future<bool> criarMesa(Mesa mesa) => _mesaRepo.criarMesa(mesa);
  Future<bool> atualizarMesa(Mesa mesa) => _mesaRepo.atualizarMesa(mesa);
  Future<int> getQuantidadeMesasOcupadas() => _mesaRepo.getQuantidadeMesasOcupadas();

  // --- Métodos para Vendas ---
  Future<int?> abrirVenda(int mesaId, {String? nomeCliente}) => 
      _vendaPedidoRepo.abrirVenda(mesaId, nomeCliente: nomeCliente);
  Future<List<Venda>> getVendasAbertas() => _vendaPedidoRepo.getVendasAbertas();
  Future<Venda?> getVendaById(int id) => _vendaPedidoRepo.getVendaById(id);
  Future<Venda?> getVendaAbertaMesa(int mesaId) => _vendaPedidoRepo.getVendaAbertaMesa(mesaId);
  Future<bool> fecharVenda(int vendaId, String metodoPagamento) => 
      _vendaPedidoRepo.fecharVenda(vendaId, metodoPagamento);
  Future<bool> cancelarVenda(int vendaId, String motivo) => 
      _vendaPedidoRepo.cancelarVenda(vendaId, motivo);
  Future<double> getTotalVendasDia() => _vendaPedidoRepo.getTotalVendasDia();

  // --- Métodos para Pedidos ---
  Future<int?> criarPedido(int vendaId, String funcionario) => 
      _vendaPedidoRepo.criarPedido(vendaId, funcionario);
  Future<List<Pedido>> getPedidosAtivos() => _vendaPedidoRepo.getPedidosAtivos();
  Future<Pedido?> getPedidoCompletoById(int id) => _vendaPedidoRepo.getPedidoCompletoById(id);
  Future<bool> atualizarStatusPedido(int pedidoId, PedidoStatus status) => 
      _vendaPedidoRepo.atualizarStatusPedido(pedidoId, status);

  // --- Métodos para Itens de Pedido ---
  Future<bool> adicionarItemPedido(ItemPedido item) => _vendaPedidoRepo.adicionarItemPedido(item);
  Future<bool> removerItemPedido(int itemId) => _vendaPedidoRepo.removerItemPedido(itemId);
  Future<bool> atualizarQuantidadeItem(int itemId, int novaQuantidade) => 
      _vendaPedidoRepo.atualizarQuantidadeItem(itemId, novaQuantidade);

  // --- Métodos de centralização de dados ---
  
  // Inicializa os dados básicos (mesas, produtos, fornecedores)
  Future<void> inicializarDados() async {
    await Future.wait([
      getMesas(),
      getProdutos(),
      getFornecedores(),
    ]);
  }

  // Dados para Dashboard
  Future<Map<String, dynamic>> getDadosDashboard() async {
    final totalVendasHoje = await getTotalVendasDia();
    final mesasOcupadas = await getQuantidadeMesasOcupadas();
    final totalMesas = (await getMesas()).length;
    final pedidosAtivos = (await getPedidosAtivos()).length;
    final produtosEstoqueBaixo = (await getProdutosEstoqueBaixo(10)).length;
    
    return {
      'totalVendasHoje': totalVendasHoje,
      'mesasOcupadas': mesasOcupadas,
      'totalMesas': totalMesas,
      'pedidosAtivos': pedidosAtivos,
      'produtosEstoqueBaixo': produtosEstoqueBaixo,
    };
  }
  
  // Fluxo completo: Abrir Mesa -> Criar Pedido -> Adicionar Item
  Future<Map<String, dynamic>?> abrirMesaECriarPedido(int mesaId, String nomeCliente, String funcionario) async {
    try {
      // 1. Abrir venda na mesa
      final vendaId = await abrirVenda(mesaId, nomeCliente: nomeCliente);
      if (vendaId == null) return null;
      
      // 2. Criar pedido na venda
      final pedidoId = await criarPedido(vendaId, funcionario);
      if (pedidoId == null) return null;
      
      return {
        'vendaId': vendaId,
        'pedidoId': pedidoId,
      };
    } catch (e) {
      print('Erro no fluxo de abrir mesa: $e');
      return null;
    }
  }
}