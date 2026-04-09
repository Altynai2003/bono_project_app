import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../db/database_helper.dart';

class HistoryScreen extends StatefulWidget {
  final String userName;

  const HistoryScreen({super.key, required this.userName});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<OrderModel> _allOrders = [];
  List<OrderModel> _filteredOrders = [];

  String _searchQuery = '';
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orders = await DatabaseHelper.instance.getAllOrders();
    setState(() {
      _allOrders = orders;
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredOrders = _allOrders.where((order) {
        final matchesSearch = order.modelName.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
        final matchesDate =
            _selectedDate == null || order.cutDate == _selectedDate;
        return matchesSearch && matchesDate;
      }).toList();
    });
  }

  // Дата боюнча фильтр
  Future<void> _filterByDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate =
            "${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}";
      });
      _applyFilters();
    }
  }

  // Фильтрди тазалоо
  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
    });
    _applyFilters();
  }

  // Маалыматты өчүрүү
  Future<void> _deleteOrder(int id) async {
    await DatabaseHelper.instance.deleteOrder(id);
    _loadOrders();
  }

  // Статусту өзгөртүү (Редактирлөө)
  Future<void> _editStatus(OrderModel order) async {
    String currentStatus = order.status;
    final statuses = ['Кесилди', 'Тигилүүдө', 'Даяр', 'Жөнөтүлдү'];

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Статусту өзгөртүү'),
        content: DropdownButtonFormField<String>(
          initialValue: currentStatus,
          items: statuses.map((status) {
            return DropdownMenuItem(value: status, child: Text(status));
          }).toList(),
          onChanged: (val) {
            if (val != null) currentStatus = val;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Жокко чыгаруу'),
          ),
          ElevatedButton(
            onPressed: () async {
              order.status = currentStatus;
              await DatabaseHelper.instance.updateOrder(order);
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              _loadOrders();
            },
            child: const Text('Сактоо'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Тарыхча'),
        actions: [
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Дата фильтрин өчүрүү',
              onPressed: _clearDateFilter,
            ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Дата боюнча издөө',
            onPressed: _filterByDate,
          ),
        ],
      ),
      body: Column(
        children: [
          // Издөө тилкеси (🔍 Издөө)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Модель боюнча издөө',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _applyFilters();
              },
            ),
          ),
          if (_selectedDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: Text(
                'Дата: $_selectedDate',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),

          // Маалыматтардын тизмеси
          Expanded(
            child: _filteredOrders.isEmpty
                ? const Center(child: Text('Маалымат табылган жок'))
                : ListView.builder(
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index];

                      // Түстү таануу
                      Color colorTag = Colors.black;
                      try {
                        colorTag = Color(
                          int.parse(order.color.replaceFirst('#', '0xFF')),
                        );
                      } catch (_) {
                        // эски же ката формат болсо кара бойдон калат
                      }

                      // Статус белгиси (🟡, 🔵, 🟢, 🚚)
                      Widget statusIcon;
                      switch (order.status) {
                        case 'Кесилди':
                          statusIcon = const Text(
                            '🟡',
                            style: TextStyle(fontSize: 20),
                          );
                          break;
                        case 'Тигилүүдө':
                          statusIcon = const Text(
                            '🔵',
                            style: TextStyle(fontSize: 20),
                          );
                          break;
                        case 'Даяр':
                          statusIcon = const Text(
                            '🟢',
                            style: TextStyle(fontSize: 20),
                          );
                          break;
                        case 'Жөнөтүлдү':
                          statusIcon = const Text(
                            '🚚',
                            style: TextStyle(fontSize: 20),
                          );
                          break;
                        default:
                          statusIcon = const SizedBox();
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: colorTag,
                            radius: 16,
                          ),
                          title: Text(
                            'Модель: ${order.modelName}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Статус: ${order.status} | Дата: ${order.cutDate}',
                          ),
                          trailing: SizedBox(width: 30, child: statusIcon),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '👤 Колдонуучу: ${order.userName}',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('👕 Модель: ${order.modelName}'),
                                  const SizedBox(height: 4),
                                  Text('✂️ Крой: ${order.cutQuantity}'),
                                  const SizedBox(height: 4),
                                  Text('📦 Штук: ${order.pieceQuantity}'),
                                  const SizedBox(height: 4),
                                  Text('🔘 Фурнитура: ${order.hardwareType}'),
                                  const SizedBox(height: 4),
                                  Text(
                                    '🚚 Отправка: ${order.shipmentQuantity}',
                                  ),
                                  const SizedBox(height: 4),
                                  Text('📅 Кесилген күнү: ${order.cutDate}'),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      // Редактирлөө (✏️)
                                      OutlinedButton.icon(
                                        onPressed: () => _editStatus(order),
                                        icon: const Icon(Icons.edit, size: 18),
                                        label: const Text('Статус'),
                                      ),
                                      // Өчүрүү (🗑️)
                                      OutlinedButton.icon(
                                        onPressed: () =>
                                            _deleteOrder(order.id!),
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                        label: const Text(
                                          'Өчүрүү',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
