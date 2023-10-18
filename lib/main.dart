import 'package:flutter/material.dart';
import 'package:proyecto_psicologia/Constants/colors.dart';
import 'package:proyecto_psicologia/Views/inicio_view.dart';
import 'package:proyecto_psicologia/Views/prioridad_alta_view.dart';
import 'package:proyecto_psicologia/Views/test_filtro_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asesoria psicologica',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Palette.colorBlue,
      ),
      home: const InicioView(),
      // home: const TestFiltroView(),
      // home: const PrioridadAltaView(),

    );
  }
}
