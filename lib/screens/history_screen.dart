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

  // Дата боюнча фильтр (Календарь)
  Future<void> _filterByDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF4A89DC)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        // Формат: YYYY-MM-DD
        _selectedDate =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
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

  // Ордерди түзөтүү диалогу (Сүрөттөгү калем баскычы үчүн)
  Future<void> _editOrder(OrderModel order) async {
    // Бул жерде түзөтүү логикасы болот
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Түзөтүү функциясы алдыда кошулат')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9), // Ачык боз фон
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A89DC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.userName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: _clearDateFilter,
            ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Издөө тилкесине фокус беребиз же логика
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            onPressed: _filterByDate,
          ),
        ],
      ),
      body: Column(
        children: [
          // Издөө тилкеси (Search bar)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Модельди издөө...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: const Icon(
                    Icons.tune,
                    color: Colors.grey,
                  ), // Filter icon
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (value) {
                  _searchQuery = value;
                  _applyFilters();
                },
              ),
            ),
          ),

          if (_selectedDate != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Көрсөтүлгөн дата: $_selectedDate',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A89DC),
                ),
              ),
            ),

          // Маалыматтардын тизмеси
          Expanded(
            child: _filteredOrders.isEmpty
                ? const Center(child: Text('Маалымат табылган жок'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // 1-катар: Колдонуучу & Түзөтүү (Edit)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      size: 20,
                                      color: Color(0xFF4A89DC),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Колдонуучу: ${order.userName}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () => _editOrder(order),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Color(0xFF4A89DC),
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // 2-катар: Модель
                            Row(
                              children: [
                                const Icon(
                                  Icons.work,
                                  size: 20,
                                  color: Color(0xFF4A89DC),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Модель: ${order.modelName}',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // 3-катар: Крой
                            Row(
                              children: [
                                const Icon(
                                  Icons.content_cut,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Крой: ${order.cutQuantity}',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // 4-катар: Түс
                            Row(
                              children: [
                                const Icon(
                                  Icons.palette,
                                  size: 20,
                                  color: Colors.blueGrey,
                                ),
                                const SizedBox(width: 8),
                                // Түстү таануу үчүн
                                Builder(
                                  builder: (context) {
                                    String colorName = "Белгисиз";
                                    if (order.color.toLowerCase() ==
                                        '#ff000000') {
                                      colorName = 'Кара';
                                    } else if (order.color.toLowerCase() ==
                                        '#ffffffff')
                                      // ignore: curly_braces_in_flow_control_structures
                                      colorName = 'Ак';
                                    else if (order.color.toLowerCase() ==
                                        '#ff9e9e9e')
                                      // ignore: curly_braces_in_flow_control_structures
                                      colorName = 'Боз';
                                    else if (order.color.toLowerCase() ==
                                        '#fff44336')
                                      // ignore: curly_braces_in_flow_control_structures
                                      colorName = 'Кызыл';
                                    else if (order.color.toLowerCase() ==
                                        '#ff2196f3')
                                      // ignore: curly_braces_in_flow_control_structures
                                      colorName = 'Көк';

                                    return Text(
                                      'Түс: $colorName', // "Кара" ж.б
                                      style: const TextStyle(fontSize: 15),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // 5-катар: Штук, Фурнитура, Шилтеме & Өчүрүү
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.inventory_2,
                                      size: 20,
                                      color: Colors.blueAccent,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Штук: ${order.pieceQuantity} ${order.hardwareType}',
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4A89DC),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.link,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () => _deleteOrder(order.id!),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade400,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.delete_outline,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // 6-катар: Отправка датасы
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Отправка: ${order.cutDate}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
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
