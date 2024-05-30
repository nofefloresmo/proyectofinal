import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
import 'signup_page.dart';
import '../widgets/login_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller; // Controlador de animación
  Timer? _flickerTimer; // Temporizador para el parpadeo de neon
  double _opacity = 1.0; // Inicia con opacidad al 100%
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // Instancia de la clase LoginWidget que contiene aspectos de diseño del login
  final login = LoginWidget();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration:
          const Duration(milliseconds: 500), // Corta duración para los cambios
      vsync: this,
    );
    startFlickeringEffect();
  }

  // efecto de parpadeo de Neon
  void startFlickeringEffect() {
    _flickerTimer?.cancel(); // Cancelar cualquier parpadeo de neon
    _flickerTimer = Timer.periodic(const Duration(milliseconds: 180), (timer) {
      setState(() {
        final random = math.Random();
        _opacity = random.nextBool() ? 1.0 : random.nextDouble();
      });
    });
  }

  Future<void> loginUser() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'User document does not exist.',
        );
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(user: userCredential.user!)),
      );
    } catch (e) {
      print('Error: $e');
      // Mostrar mensaje de error
      // Si ocurre un error durante el inicio de sesión, se captura y se muestra un mensaje de error.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Error al Iniciar Sesión, Usuario o Contraseña incorrectas."),
        ),
      );
    }
  }

  @override
  void dispose() {
    disposeControlers();
    _flickerTimer?.cancel();
    super.dispose();
  }

  void disposeControlers() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _formKey.currentState?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 170),
              Container(
                width: 300,
                height: 80,
                alignment: AlignmentGeometry.lerp(
                    Alignment.centerLeft, Alignment.centerRight, 0.5),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: login.getNeonColor().withOpacity(_opacity * 0.9),
                    width: 5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromARGB(255, 11, 7, 21),
                  boxShadow: [
                    BoxShadow(
                      color: login.getNeonColor().withOpacity(_opacity * 0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: login.getNeonColor().withOpacity(_opacity * 0.3),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: login.getLogo(30),
              ),
              SizedBox(height: 80),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 360,
                height: 35,
                alignment: AlignmentGeometry.lerp(
                    Alignment.centerLeft, Alignment.centerRight, 0.5),
                child: AutoSizeText(
                  login.getMensaje(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                  minFontSize: 10,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 50),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        fillColor: Colors.white.withOpacity(0.05),
                        filled: true,
                        prefixIcon: Icon(Icons.person, color: Colors.pink),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor introduce tu email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        fillColor: Colors.white.withOpacity(0.05),
                        filled: true,
                        prefixIcon: Icon(Icons.lock, color: Colors.pink),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor introduce tu contraseña';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          loginUser();
                        }
                      },
                      child: const Text('Login'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                        );
                      },
                      child:
                          const Text('No tienes una cuenta? registrate aquí'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
