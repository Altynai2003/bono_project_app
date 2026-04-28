import 'package:bono_project_app/screens/history_screen.dart';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../db/database_helper.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    var getAllOrders = getAllOrders;
    final orders = await DatabaseHelper.instance.getAllOrders();
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  // Күнүнө канча крой (Дата боюнча топтоо)
  Map<String, int> _cutsPerDay() {
    Map<String, int> map = {};
    for (var o in _orders) {
      map[o.cutDate] = (map[o.cutDate] ?? 0) + o.cutQuantity;
    }
    return map;
  }

  // Кайсы модель эң көп
  String _mostFrequentModel() {
    if (_orders.isEmpty) return 'Жок';
    Map<String, int> counts = {};
    for (var o in _orders) {
      counts[o.modelName] = (counts[o.modelName] ?? 0) + o.cutQuantity;
    }
    String topModel = '';
    int maxCount = 0;
    counts.forEach((key, value) {
      if (value > maxCount) {
        maxCount = value;
        topModel = key;
      }
    });
    return '$topModel ($maxCount крой)';
  }

  // Эффективдүүлүк (Бардык штук / Бардык крой * 100)
  String _overallEfficiency() {
    if (_orders.isEmpty) return '0%';
    int totalCut = 0;
    int totalPiece = 0;
    for (var o in _orders) {
      totalCut += o.cutQuantity;
      totalPiece += o.pieceQuantity;
    }
    if (totalCut == 0) return '0%'; // катаны болтурбоо
    double eff = (totalPiece / totalCut) * 100;
    return '${eff.toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final topInfoStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Отчёт Жана Статистика')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Жогорку статистикалык карта (Card)
            Card(
              elevation: 4,
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(Icons.analytics, size: 48, color: Colors.blue),
                    const SizedBox(height: 16),
                    Text(
                      'Жалпы эффективдүүлүк: ${_overallEfficiency()}',
                      style: topInfoStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Топ модель: ${_mostFrequentModel()}',
                      style: topInfoStyle,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Күнүмдүк Кройлор (Отчёт):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Даталардын тизмеси
            Expanded(
              child: _orders.isEmpty
                  ? const Center(child: Text('Маалымат жок'))
                  : ListView(
                      children: _cutsPerDay().entries.map((e) {
                        return ListTile(
                          leading: const Icon(
                            Icons.date_range,
                            color: Colors.blueGrey,
                          ),
                          title: Text(
                            'Дата: ${e.key}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Text(
                            '${e.value} крой',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
