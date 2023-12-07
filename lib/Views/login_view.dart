import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyecto_psicologia/Components/boton_psicologia.dart';
import 'package:proyecto_psicologia/Services/firebase_services.dart';

class LoginView extends StatefulWidget {
  const LoginView({ Key? key }) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {

  final servicios = Get.put(FirebaseServicesS());

  @override
  Widget build(BuildContext context) {
    return Obx(
      ()=> Scaffold(
        body: Center(
          child: !servicios.verificar.value ? BotonPsicologia(
            iconData: Icons.login,
            text: 'Iniciar sesión',
            onTap: ()async{
              // await servicios.autenticarUsuario(numeroC: 'psicologo', password: '123456', context: context);
              // await servicios.autenticarUsuario(numeroC: '19091435', password: '123456', context: context);
              await servicios.autenticarUsuario(numeroC: 'c18090562', password: '123456', context: context);
            },
          ) : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}