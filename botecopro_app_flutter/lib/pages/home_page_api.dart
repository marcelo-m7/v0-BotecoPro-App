import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/boteco_service.dart';
import '../widgets/shared_widgets.dart';
import '../models/api_models.dart';
import '../utils/formatters.dart';
import '../utils/error_handler.dart';
import 'tables_page.dart';
import 'products_page.dart';
import 'suppliers_page.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BotecoService _botecoService = BotecoService();
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  
  // Dados para o dashboard
  double _totalVendasHoje = 0;
  int _mesasOcupadas = 0;
  int _totalMesas = 0;
  int _pedidosAtivos = 0;
  int _produtosEstoqueBaixo = 0;
  List<Pedido> _ultimosPedidos = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Carrega dados do dashboard
      final dashboardData = await _botecoService.getDadosDashboard();
      final pedidosAtivos = await _botecoService.getPedidosAtivos();
      
      if (mounted) {
        setState(() {
          _totalVendasHoje = dashboardData['totalVendasHoje'];
          _mesasOcupadas = dashboardData['mesasOcupadas'];
          _totalMesas = dashboardData['totalMesas'];
          _pedidosAtivos = dashboardData['pedidosAtivos'];
          _produtosEstoqueBaixo = dashboardData['produtosEstoqueBaixo'];
          
          // Ordenar pedidos do mais recente para o mais antigo e pegar no máximo 3
          _ultimosPedidos = pedidosAtivos;
          _ultimosPedidos.sort((a, b) => b.dataPedido.compareTo(a.dataPedido));
          if (_ultimosPedidos.length > 3) {
            _ultimosPedidos = _ultimosPedidos.sublist(0, 3);
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = ErrorHandler.tratarErroApi(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sports_bar,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              'Boteco PRO',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildErrorView()
              : RefreshIndicator(
                  onRefresh: _carregarDados,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeHeader(),
                        _buildStatusCards(),
                        _buildMenuGrid(),
                        if (_ultimosPedidos.isNotEmpty) _buildRecentOrdersSection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar dados',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _carregarDados,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final now = DateTime.now();
    String greeting;
    if (now.hour < 12) {
      greeting = 'Bom dia';
    } else if (now.hour < 18) {
      greeting = 'Boa tarde';
    } else {
      greeting = 'Boa noite';
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('EEEE, d "de" MMMM', 'pt_BR').format(now),
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 0,
                  color: Colors.white.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.money,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Vendas hoje',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          Formatters.formatarMoeda(_totalVendasHoje),
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCards() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              'Status Atual',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          StatusCard(
            title: 'Mesas ocupadas',
            value: '$_mesasOcupadas de $_totalMesas',
            icon: Icons.table_bar,
            color: const Color(0xFFFF9800),
          ),
          StatusCard(
            title: 'Pedidos ativos',
            value: '$_pedidosAtivos',
            icon: Icons.receipt_long,
            color: const Color(0xFF4CAF50),
          ),
          StatusCard(
            title: 'Produtos com estoque baixo',
            value: '$_produtosEstoqueBaixo',
            icon: Icons.warning_amber,
            color: _produtosEstoqueBaixo > 0 
                ? const Color(0xFFF44336) 
                : const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              'Menu Principal',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              MenuCard(
                title: 'Mesas',
                icon: Icons.table_restaurant,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TablesPage(),
                    ),
                  ).then((_) => _carregarDados());
                },
                backgroundColor: const Color(0xFF6F61EF),
              ),
              MenuCard(
                title: 'Produtos',
                icon: Icons.inventory_2,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProductsPage(),
                    ),
                  ).then((_) => _carregarDados());
                },
                backgroundColor: const Color(0xFF39D2C0),
              ),
              MenuCard(
                title: 'Fornecedores',
                icon: Icons.local_shipping,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SuppliersPage(),
                    ),
                  ).then((_) => _carregarDados());
                },
                backgroundColor: const Color(0xFFEE8B60),
              ),
              MenuCard(
                title: 'Relatórios',
                icon: Icons.bar_chart,
                onTap: () {
                  ErrorHandler.mostrarErroSnackBar(
                    context, 
                    'Função disponível em breve!'
                  );
                },
                backgroundColor: const Color(0xFF888888),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              'Pedidos Ativos',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _ultimosPedidos.length,
            itemBuilder: (context, index) {
              final pedido = _ultimosPedidos[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      '${pedido.mesaNumero}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    'Mesa ${pedido.mesaNumero}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pedido #${pedido.id} - ${Formatters.formatarDataHora(pedido.dataPedido)}',
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(pedido.status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _getStatusColor(pedido.status)),
                        ),
                        child: Text(
                          Pedido.getStatusNome(pedido.status),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(pedido.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TablesPage(),
                      ),
                    ).then((_) => _carregarDados());
                  },
                ),
              )
              .animate()
              .fadeIn()
              .slideX(begin: 30, duration: Duration(milliseconds: 200 + (index * 100)));
            },
          ),
          if (_pedidosAtivos > 3)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TablesPage(),
                      ),
                    ).then((_) => _carregarDados());
                  },
                  icon: Icon(
                    Icons.visibility,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: Text(
                    'Ver todos os pedidos',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(PedidoStatus status) {
    switch (status) {
      case PedidoStatus.pendente:
        return const Color(0xFFFFA000); // Amber
      case PedidoStatus.preparando:
        return const Color(0xFF2196F3); // Blue
      case PedidoStatus.pronto:
        return const Color(0xFF4CAF50); // Green
      case PedidoStatus.entregue:
        return const Color(0xFF9E9E9E); // Grey
      case PedidoStatus.cancelado:
        return const Color(0xFFF44336); // Red
    }
  }
}