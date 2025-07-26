import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/boteco_service.dart';
import '../widgets/shared_widgets.dart';
import '../models/api_models.dart';
import '../utils/formatters.dart';
import '../utils/error_handler.dart';

class TablesPageAPI extends StatefulWidget {
  const TablesPageAPI({Key? key}) : super(key: key);

  @override
  State<TablesPageAPI> createState() => _TablesPageAPIState();
}

class _TablesPageAPIState extends State<TablesPageAPI> {
  final BotecoService _botecoService = BotecoService();
  List<Mesa> _mesas = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _carregarMesas();
  }

  Future<void> _carregarMesas() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final mesas = await _botecoService.getMesas();
      mesas.sort((a, b) => a.numero.compareTo(b.numero));

      if (mounted) {
        setState(() {
          _mesas = mesas;
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
      appBar: const CustomAppBar(title: 'Gerenciar Mesas'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildErrorView()
              : RefreshIndicator(
                  onRefresh: _carregarMesas,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusHeader(),
                      const SizedBox(height: 8),
                      _buildTableGrid(),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTableDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Nova Mesa'),
      ).animate().scale(delay: const Duration(milliseconds: 300)),
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
            'Erro ao carregar mesas',
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
            onPressed: _carregarMesas,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    final mesasOcupadas = _mesas.where((mesa) => mesa.status == MesaStatus.ocupada).length;
    final mesasLivres = _mesas.length - mesasOcupadas;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status das Mesas',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatusBox(
                  Icons.check_circle_outline,
                  'Disponíveis',
                  '$mesasLivres',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatusBox(
                  Icons.people,
                  'Ocupadas',
                  '$mesasOcupadas',
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatusBox(
                  Icons.table_restaurant,
                  'Total',
                  '${_mesas.length}',
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300))
        .moveY(begin: 20, duration: const Duration(milliseconds: 300));
  }

  Widget _buildStatusBox(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: color,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTableGrid() {
    return Expanded(
      child: _mesas.isEmpty
          ? Center(
              child: EmptyStateCard(
                message: 'Nenhuma mesa cadastrada',
                icon: Icons.table_bar,
                actionText: 'Adicionar Mesa',
                onAction: _showAddTableDialog,
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _mesas.length,
              itemBuilder: (context, index) {
                final delay = Duration(milliseconds: 30 * index);
                final mesa = _mesas[index];
                return _buildTableCard(mesa).animate().fadeIn(delay: delay).moveY(begin: 20, delay: delay, duration: const Duration(milliseconds: 300));
              },
            ),
    );
  }

  Widget _buildTableCard(Mesa mesa) {
    final bool isOccupied = mesa.status == MesaStatus.ocupada;
    final Color statusColor = isOccupied ? Colors.orange : Colors.green;
    final String statusText = isOccupied ? 'Ocupada' : 'Disponível';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _handleTableTap(mesa),
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        radius: 20,
                        child: Text(
                          '${mesa.numero}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: statusColor, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isOccupied ? Icons.people : Icons.check_circle_outline,
                              size: 14,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mesa ${mesa.numero}',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Capacidade: ${mesa.capacidade} pessoas',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (mesa.nomeCliente != null && mesa.nomeCliente!.isNotEmpty) ...[  
                    const SizedBox(height: 4),
                    Text(
                      'Cliente: ${mesa.nomeCliente}',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const Spacer(),
                  Text(
                    isOccupied ? 'Ver detalhes' : 'Iniciar atendimento',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (isOccupied)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                  .scaleXY(begin: 0.8, end: 1.2, duration: const Duration(seconds: 1)),
              ),
          ],
        ),
      ),
    );
  }

  void _handleTableTap(Mesa mesa) async {
    if (mesa.status == MesaStatus.ocupada) {
      // A mesa está ocupada, vamos para os detalhes da venda/pedido
      final venda = await _botecoService.getVendaAbertaMesa(mesa.id!);
      if (venda != null && mounted) {
        // TODO: Navegar para página de detalhes da venda/pedido
        ErrorHandler.mostrarSucessoSnackBar(
          context, 
          'Venda #${venda.id} aberta na mesa ${mesa.numero}'
        );
      } else {
        ErrorHandler.mostrarErroSnackBar(
          context, 
          'Não foi possível encontrar a venda aberta para esta mesa'
        );
      }
    } else {
      // A mesa está livre, vamos criar uma nova venda
      _showNewOrderDialog(mesa);
    }
  }

  void _showNewOrderDialog(Mesa mesa) {
    final TextEditingController clienteController = TextEditingController();
    final TextEditingController funcionarioController = TextEditingController(text: 'Garçom');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Abrir Mesa ${mesa.numero}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: clienteController,
              decoration: const InputDecoration(
                labelText: 'Nome do Cliente (opcional)',
                hintText: 'Ex: João Silva',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: funcionarioController,
              decoration: const InputDecoration(
                labelText: 'Atendente',
                hintText: 'Nome do atendente',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _abrirVendaEPedido(mesa, clienteController.text, funcionarioController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              'Abrir Mesa',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirVendaEPedido(Mesa mesa, String nomeCliente, String funcionario) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final result = await _botecoService.abrirMesaECriarPedido(
        mesa.id!, 
        nomeCliente, 
        funcionario
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (result != null && mounted) {
        final vendaId = result['vendaId'];
        final pedidoId = result['pedidoId'];
        
        ErrorHandler.mostrarSucessoSnackBar(
          context, 
          'Mesa aberta com sucesso! Venda #$vendaId - Pedido #$pedidoId'
        );
        
        // Recarregar as mesas
        _carregarMesas();
        
        // TODO: Navegar para a página de detalhes do pedido
      } else if (mounted) {
        ErrorHandler.mostrarErroSnackBar(
          context, 
          'Não foi possível abrir a mesa. Tente novamente.'
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ErrorHandler.mostrarErroSnackBar(
          context, 
          ErrorHandler.tratarErroApi(e)
        );
      }
    }
  }

  void _showAddTableDialog() {
    final TextEditingController numberController = TextEditingController();
    final TextEditingController capacityController = TextEditingController(text: '4');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Nova Mesa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: numberController,
              decoration: const InputDecoration(
                labelText: 'Número da Mesa',
                hintText: 'Ex: 1, 2, 3...',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: capacityController,
              decoration: const InputDecoration(
                labelText: 'Capacidade (pessoas)',
                hintText: 'Ex: 4',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final numberText = numberController.text.trim();
              final capacityText = capacityController.text.trim();

              if (numberText.isEmpty) {
                ErrorHandler.mostrarErroSnackBar(
                  context,
                  'Informe o número da mesa',
                );
                return;
              }

              final number = int.tryParse(numberText);
              final capacity = int.tryParse(capacityText) ?? 4;

              if (number == null || number <= 0) {
                ErrorHandler.mostrarErroSnackBar(
                  context,
                  'Número de mesa inválido',
                );
                return;
              }

              // Verificar se já existe uma mesa com este número
              final existingTable = _mesas.any((t) => t.numero == number);
              if (existingTable) {
                if (mounted) {
                  ErrorHandler.mostrarErroSnackBar(
                    context,
                    'Já existe uma mesa com este número',
                  );
                }
                return;
              }

              Navigator.pop(context);
              
              try {
                setState(() {
                  _isLoading = true;
                });
                
                final newTable = Mesa(
                  numero: number,
                  capacidade: capacity,
                );
                
                final success = await _botecoService.criarMesa(newTable);
                
                if (success && mounted) {
                  ErrorHandler.mostrarSucessoSnackBar(
                    context,
                    'Mesa $number adicionada com sucesso!',
                  );
                  _carregarMesas();
                } else if (mounted) {
                  ErrorHandler.mostrarErroSnackBar(
                    context,
                    'Erro ao adicionar mesa. Tente novamente.',
                  );
                  setState(() {
                    _isLoading = false;
                  });
                }
              } catch (e) {
                if (mounted) {
                  ErrorHandler.mostrarErroSnackBar(
                    context,
                    ErrorHandler.tratarErroApi(e),
                  );
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              'Adicionar',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}