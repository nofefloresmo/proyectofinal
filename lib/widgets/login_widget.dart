import 'package:flutter/material.dart';
import 'dart:math';

const List<String> mensajesBienvenida = [
  '¿De nuevo en TecBoxD?',
  '¡Bienvenido de nuevo!',
  '¡Bienvenido a TecBoxD!',
  '¡Otra vez en TecBoxD!',
  '¡De vuelta en TecBoxD!',
  '¡Regresaste a TecBoxD!',
  'Que la fuerza te acompañe',
  '¡Hasta la vista, baby!',
  'Say "hello" to my little friend!',
  '¡Que comience el espectáculo!',
  '¡Houston, tenemos un problema!',
  '¡Life always finds a way!',
  '¡Yo soy tu padre!',
  '¡Al infinito y más allá!',
  '¡Eres un mago, Harry!',
  '¡Volveremos a ver el sol nacer!',
  '¡Que ruede el trueno!',
  '¡Hazte con ellos, tigre!',
  '¡Si construyes, vendrán!',
  '¡He venido a buscar a Frodo!',
  '¡Aaahhhhhh! ¡Me he desvanecido!',
  '¡The force is strong with this one!',
];

const List<Color> startingColors = [
  Color.fromARGB(255, 106, 11, 106),
  Color.fromARGB(255, 126, 27, 58),
  Color.fromARGB(255, 88, 85, 18),
  Color.fromARGB(255, 88, 15, 127)
];

const List<Color> neonColors = [
  Color.fromARGB(255, 255, 165, 0), // Neon Orange
  Color.fromARGB(255, 0, 255, 0), // Neon Green
  Color.fromARGB(255, 3, 169, 244), // Neon Blue
  Color.fromARGB(255, 232, 57, 115) // Neon Pink
];

// Colores random
final randomStarting = Random().nextInt(neonColors.length);
final randomNeon = Random().nextInt(startingColors.length);
final randomMensaje = Random().nextInt(mensajesBienvenida.length);

class LoginWidget {
  Widget getLogo(double sizeLogo) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          startingColors[randomStarting],
          neonColors[randomNeon],
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Text(
        'TecBoxD',
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'OutrunFuture',
          fontWeight: FontWeight.bold,
          fontSize: sizeLogo,
        ),
      ),
    );
  }

  Color getStartingColor() {
    return startingColors[randomStarting];
  }

  Color getNeonColor() {
    return neonColors[randomNeon];
  }

  String getMensaje() {
    return mensajesBienvenida[randomMensaje];
  }
}
