import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_psicologia/Constants/colors.dart';
import 'package:proyecto_psicologia/Views/agenda_cita_view.dart';
import 'package:proyecto_psicologia/Views/inicio_view.dart';
import 'package:proyecto_psicologia/Views/login_view.dart';
import 'package:proyecto_psicologia/Views/pdf_cita_view.dart';
import 'package:proyecto_psicologia/Views/prioridad_alta_view.dart';
import 'package:proyecto_psicologia/Views/psicologo_view.dart';
import 'package:proyecto_psicologia/Views/test_filtro_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        useMaterial3: false
      ),
      // home: const InicioView(),
      // home: const PdfCitaView(),
      // home: const TestFiltroView(),
      // home: const PrioridadAltaView(),
      // home: const AgendaCitaView(prioridad: 3),
      // home: const PsicologoView(),
      home: const LoginView(),

    );
  }
}
