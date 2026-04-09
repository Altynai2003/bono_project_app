import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _modelController = TextEditingController();
  final _cutController = TextEditingController();
  final _colorController = TextEditingController();
  final _quantityController = TextEditingController();
  final _shipmentController = TextEditingController();
  final _dateController = TextEditingController(); // Дата үчүн контроллер
  
  String _furnituraType = 'Кнопка'; // Фурнитура түрү: Кнопка, Замок, Экөө тең

  // Датаны тандоо (Date Picker)
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}";
      });
    }
  }

  // Форманы тазалоо
  void _clearForm() {
    _formKey.currentState?.reset();
    _modelController.clear();
    _cutController.clear();
    _colorController.clear();
    _quantityController.clear();
    _shipmentController.clear();
    _dateController.clear();
    setState(() {
      _furnituraType = 'Кнопка';
    });
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Маалымат ийгиликтүү сакталды!')),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      
      // Optionally clear the form or navigate back
      // _formKey.currentState!.reset();
    }
  }

  @override
  void dispose() {
    _modelController.dispose();
    _cutController.dispose();
    _colorController.dispose();
    _quantityController.dispose();
    _shipmentController.dispose();
    _dateController.dispose(); // Контроллерди эстутумдан өчүрүү
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Жаңы буйрутма'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        actions: [
          // Тарыхчага өтүү баскычы
          IconButton(
            icon: const Icon(Icons.history_edu),
            tooltip: 'Тарыхчага өтүү',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Тарыхча барагы азырынча даяр эмес')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 16.0),
                child: Text(
                  'Салам, ${widget.userName} 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Модель маалыматы',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _modelController,
                          decoration: const InputDecoration(
                            labelText: 'Кандай модель?',
                            prefixIcon: Icon(Icons.checkroom),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Милдеттүү толтурулат' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _colorController,
                                decoration: const InputDecoration(
                                  labelText: 'Түсү',
                                  prefixIcon: Icon(Icons.palette_outlined),
                                ),
                                validator: (value) => value == null || value.isEmpty ? 'Жазыңыз' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _cutController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Крой саны',
                                  prefixIcon: Icon(Icons.content_cut),
                                ),
                                validator: (value) => value == null || value.isEmpty ? 'Жазыңыз' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Өндүрүш жана детальдар',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Канча штук чыгат?',
                            prefixIcon: Icon(Icons.format_list_numbered),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Милдеттүү толтурулат' : null,
                        ),
                        const SizedBox(height: 16),
                        // Фурнитура түрү
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade50,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Фурнитура түрү:',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  ChoiceChip(
                                    label: const Text('Кнопка'),
                                    selected: _furnituraType == 'Кнопка',
                                    onSelected: (val) => setState(() => _furnituraType = 'Кнопка'),
                                  ),
                                  ChoiceChip(
                                    label: const Text('Замок'),
                                    selected: _furnituraType == 'Замок',
                                    onSelected: (val) => setState(() => _furnituraType = 'Замок'),
                                  ),
                                  ChoiceChip(
                                    label: const Text('Экөө тең'),
                                    selected: _furnituraType == 'Экөө тең',
                                    onSelected: (val) => setState(() => _furnituraType = 'Экөө тең'),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _shipmentController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Канча отправка болот?',
                            prefixIcon: Icon(Icons.local_shipping_outlined),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Милдеттүү толтурулат' : null,
                        ),
                        const SizedBox(height: 16),
                        // Крой кесилген дата
                        TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          onTap: _selectDate,
                          decoration: const InputDecoration(
                            labelText: 'Крой кесилген дата',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Милдеттүү толтурулат' : null,
                        ),
                        const SizedBox(height: 32),
                        // Сактоо баскычы
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                            child: const Text(
                              'Сактоо',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Тазалоо баскычы
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _clearForm,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              side: BorderSide(color: Colors.red.shade400),
                              foregroundColor: Colors.red.shade600,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.delete_outline),
                                SizedBox(width: 8),
                                Text(
                                  'Тазалоо',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

