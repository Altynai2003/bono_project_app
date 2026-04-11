import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // shared_preferences пакетин кошуу
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _savedName = ''; // Сакталган атты сактоо үчүн өзгөрмө

  @override
  void initState() {
    super.initState();
    _loadSavedName(); // Экран ачылганда сакталган атты окуйбуз
  }

  // Сакталган атты SharedPreferences аркылуу окуу
  Future<void> _loadSavedName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_name') ?? '';
    if (savedName.isNotEmpty) {
      if (mounted) {
        setState(() {
          _savedName = savedName; // UI'ны жаңыртуу үчүн сактайбыз
          _nameController.text = savedName; // Окулган атты Input'ка коюу
        });
      }
    }
  }

  // Баштоо баскычы басылганда
  Future<void> _continue() async {
    if (_formKey.currentState!.validate()) {
      // Экрандан өтүүдөн мурун жазылган атты сактап калабыз
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _nameController.text.trim());

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
            HomeScreen(userName: _nameController.text.trim()),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Ачык боз/ак фон
      body: Stack(
        children: [
          // Фондогу суу белгилери (Тигүүчү машинаны окшоштуруу)
          Positioned(
            bottom: -20,
            left: -20,
            right: -20,
            child: Opacity(
              opacity: 0.10, // Бүдөмүк кылуу (Opacity)
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                   Icon(Icons.precision_manufacturing, size: 250, color: Theme.of(context).colorScheme.primary),
                   const SizedBox(width: 20),
                   Icon(Icons.cut, size: 120, color: Theme.of(context).colorScheme.primary),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),
                      // "Кош келиңиз" тексти
                      const Text(
                        'Кош келиңиз!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Түшүндүрмө текст
                      Text(
                        _savedName.isNotEmpty 
                            ? '$_savedName акыркы колдонуучу' 
                            : 'Сиз жаңы колдонуучусуз',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Аты-жөнүн киргизүүчү инпут (TextField)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(10), // 0.04 * 255
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _nameController,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF334155),
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none, // Негизги бордерди жашыруу
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                            prefixIcon: Container(
                              margin: const EdgeInsets.only(left: 12, right: 16, top: 8, bottom: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withAlpha(25), // Ачык көк фон
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.person,
                                color: Theme.of(context).colorScheme.primary,
                                size: 24,
                              ),
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _continue(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Сураныч, атыңызды жазыңыз';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Баштоо баскычы
                      SizedBox(
                        width: double.infinity,
                        height: 56, // Баскычтын бийиктигин чоңойтуу
                        child: ElevatedButton(
                          onPressed: _continue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16), // Бурчтарын көбүрөөк тегеректөө
                            ),
                            elevation: 0, // Дизайндагыдай көлөкөсүз
                          ),
                          child: const Text(
                            'Баштоо',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48), // Айрым боштуктар үчүн
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
