import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _savedName = '';

  @override
  void initState() {
    super.initState();
    _loadSavedName();
  }

  Future<void> _loadSavedName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_name') ?? '';
    if (savedName.isNotEmpty) {
      if (mounted) {
        setState(() {
          _savedName = savedName;
          _nameController.text = savedName;
        });
      }
    }
  }

  Future<void> _continue() async {
    if (_formKey.currentState!.validate()) {
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

            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));

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
      backgroundColor: const Color(0xFFF4F6F9), // Дизайндагы фон
      appBar: AppBar(
        // Бош көк тилке (сүрөттөгүдөй)
        toolbarHeight: 20,
        backgroundColor: const Color(0xFF4A89DC),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Астыңкы иллюстрация (Тигүү машинасы жана кайчы)
          Positioned(
            bottom: -20,
            left: -20,
            right: -20,
            child: Opacity(
              opacity: 0.15,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    Icons.precision_manufacturing,
                    size: 250,
                    color: const Color(0xFF4A89DC),
                  ),
                  const SizedBox(width: 20),
                  Icon(Icons.cut, size: 120, color: const Color(0xFF4A89DC)),
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
                      // "Кош келиңиз" тексти
                      const Text(
                        'Кош келиңиз!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Түшүндүрмө текст
                      Text(
                        _savedName.isNotEmpty
                            ? '$_savedName акыркы колдонуучу'
                            : 'Сиздин атыңыз',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Аты-жөнүн киргизүүчү инпут (TextField)
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF334155),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Атыңызды жазыңыз',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.only(
                              left: 12,
                              right: 16,
                              top: 4,
                              bottom: 4,
                            ),
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: const Color(0xFF4A89DC).withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.person,
                              color: Color(0xFF4A89DC),
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
                      const SizedBox(height: 24),

                      // Баштоо баскычы
                      SizedBox(
                        width: double.infinity,
                        height: 56, // Бийик баскыч
                        child: ElevatedButton(
                          onPressed: _continue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF4A89DC,
                            ), // Көк баскыч
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ), // Бурчтары тегеректелген
                            ),
                            elevation: 0,
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
                      const SizedBox(height: 64),
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
