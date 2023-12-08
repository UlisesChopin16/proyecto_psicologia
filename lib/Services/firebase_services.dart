import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyecto_psicologia/Views/inicio_view.dart';
import 'package:proyecto_psicologia/Views/psicologo_view.dart';


class FirebaseServicesS extends GetxController{

  var verificar = false.obs;
  var verificarCitaExistente = false.obs; 
  var verificarTelefono = false.obs;
  var vistaPsicologo = false.obs;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  FirebaseStorage storage = FirebaseStorage.instance;

  FirebaseAuth auth = FirebaseAuth.instance;

  RxList<Map<String,dynamic>> datosCitas = <Map<String,dynamic>>[].obs;
  RxList<Map<String,dynamic>> puntosCitas = <Map<String,dynamic>>[].obs;

  var datosAlumno = <String,dynamic>{}.obs;
  var datosCarrera = <String,dynamic>{}.obs;

  var lastDay = DateTime.now().obs;

  var pdf = Uint8List(0).obs;

  var fechaNormal = ''.obs;
  var periodoIngreso = ''.obs;

  var fecha = ''.obs;
  var hora = ''.obs;
  var periodo = ''.obs;
  var nombre = ''.obs;
  var numeroControl = ''.obs;
  var carrera = ''.obs;
  var telefono = ''.obs;
  var mensajeError = ''.obs;
  var plan = ''.obs;

  User? usuario;
  UserCredential? usuarioCredencial;

  
  snackBarError({required String mensaje,required BuildContext context}){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style: const TextStyle(
            fontSize: 18
          ),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      )
    );
  }

  snackBarSuccess({required String mensaje,required BuildContext context}){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style: const TextStyle(
            fontSize: 18
          ),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      )
    );
  }


  // Metodo para autenticar un usuario
  Future<void> autenticarUsuario({required String numeroC, required String password,required BuildContext context}) async {
    try {
      verificar.value = true;
      String email = '$numeroC@tecnamex.com';
      usuarioCredencial = await auth.signInWithEmailAndPassword(email: email, password: password);
      if(usuarioCredencial != null){
        
        numeroControl.value = numeroC;
        usuario = usuarioCredencial!.user;

        if(!context.mounted) return;
        snackBarSuccess(mensaje: 'Bienvenido', context: context);

        if(numeroControl.value == 'psicologo'){
          if(!context.mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const PsicologoView()
            )
          );
        }else{
          // Esta sera la vista del alumno en caso de que el usuario sea un alumno
          if(!context.mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const InicioView()
            )
          );
        }
        verificar.value = false;
      }else{
        mensajeError.value = 'Usuario o contraseña incorrectos';
        if(!context.mounted) return;
        snackBarError(mensaje: mensajeError.value, context: context);
        verificar.value = false;
      }
    } catch (e) {
      mensajeError.value = 'Algo salio mal, porfavor intente de nuevo más tarde';
      if(!context.mounted) return;
      snackBarError(mensaje: mensajeError.value, context: context);
      verificar.value = false;
    }
  }


  // Metodo para verificar si existe la cita el nombre del documento es la fecha y hora de la cita
  Future<void> verificarCita({required String collection,required String id,required BuildContext context}) async {
    try {
      verificar.value = true;
      // print('checando');
      verificarCitaExistente.value = false;
      DocumentSnapshot? querySnapshot = await firestore
      .collection(collection)
      .doc(id)
      .get();

      if(querySnapshot.data() != null){
        verificarCitaExistente.value = true;
        verificar.value = false;
      }else{
        verificarCitaExistente.value = false;
        verificar.value = false;
      }
    } catch (e) {
      mensajeError.value = 'Algo salio mal, porfavor intente de nuevo más tarde';
      if(!context.mounted) return;
      snackBarError(mensaje: mensajeError.value, context: context);
      verificar.value = false;
    }
  }

  /// Metodo para obtener todas las citas de firestore en un rango de 30 dias
  Future<void> obtenerCitasAlumno({required String id,required BuildContext context}) async {
    try {
      // print('obtenerCitas');
      datosCitas.clear();

      verificar.value = true;
      DateTime fecha = DateTime.now();
      // variable de fecha con 30 dias mas
      DateTime treinaMas = fecha.add(const Duration(days: 7));
      
      // obtenemos los documentos de la coleccion Citas que tengan el campo fechaNormal igual a la fecha dada del alumno
      QuerySnapshot querySnapshot = await firestore.collection('Citas')
      .where(
        'fechaNormal',
        isGreaterThanOrEqualTo: fecha.toString().split(' ')[0],
        isLessThanOrEqualTo: treinaMas.toString().split(' ')[0],
      )
      .get();

      querySnapshot.docs.forEach((element) {
        Map<String, dynamic> datos = element.data() as Map<String, dynamic>;
        if(datos['numeroControlCita'] == id){
          datosCitas.add(datos);
        }
      });
      
      // ordenamos las citas por fecha y hora
      datosCitas.sort((a, b) {
        int comparacionFecha = a['fechaNormal'].compareTo(b['fechaNormal']);

        if (comparacionFecha == 0) {
          // Las fechas son iguales, compara las horas
          String horaA = a['horaCita'].split(' - ')[0];
          String horaB = b['horaCita'].split(' - ')[0];

          return compararHoras(horaA, horaB);
        } else {
          return comparacionFecha;
        }
      });
      verificar.value = false;
    } catch (e) {
      mensajeError.value = 'Algo salio mal, porfavor intente de nuevo más tarde';
      if(!context.mounted) return;
      snackBarError(mensaje: mensajeError.value, context: context);
      verificar.value = false;
    }
  }

  // Metodo para subir información de una cita a firestore con un identificador
  Future<void> agregarCita({required String collection,required String id, required Map<String, dynamic> data,required BuildContext context}) async {
    try {
      verificar.value = true;
      await firestore.collection(collection).doc(id).set(data);
    } catch (e) {
      mensajeError.value = 'Algo salio mal, porfavor intente de nuevo más tarde';
      if(!context.mounted) return;
      snackBarError(mensaje: mensajeError.value, context: context);
      verificar.value = false;
    }
  }

  // Metodo para subir un archivo pdf a firebase storage con Uint8List
  Future<void> subirArchivo({required Uint8List data,required String nombre,required BuildContext context}) async {
    try {
      verificar.value = true;
      final Reference ref = storage.ref().child('CitasPsicologia').child(nombre);
      final UploadTask uploadTask = ref.putData(data);

      await uploadTask.whenComplete(() => true);
      verificar.value = false;
    } catch (e) {
      mensajeError.value = 'Algo salio mal, porfavor intente de nuevo más tarde';
      if(!context.mounted) return;
      snackBarError(mensaje: mensajeError.value, context: context);
      verificar.value = false;
    }
  }

  /// Metodo para obtener todas las citas de firestore en un rango de 30 dias
  Future<void> obtenerCitas() async {
    try {
      // print('obtenerCitas');
      verificar.value = true;
      DateTime fecha = DateTime.now();
      // variable de fecha con 30 dias mas
      DateTime treinaMas = fecha.add(const Duration(days: 30));
      
      // obtenemos los documentos de la coleccion Citas que tengan el campo fechaNormal igual a la fecha dada del alumno
      QuerySnapshot querySnapshot = await firestore.collection('Citas').where(
        'fechaNormal', 
        isGreaterThanOrEqualTo: fecha.toString().split(' ')[0],
        isLessThanOrEqualTo: treinaMas.toString().split(' ')[0]
      ).get();
      querySnapshot.docs.forEach((element) {
        puntosCitas.add(element.data() as Map<String, dynamic>);
      });
      verificar.value = false;
    } catch (e) {
      mensajeError.value = 'Algo salio mal, porfavor intente de nuevo más tarde';
      verificar.value = false;
    }
  }

  // Metodo para obtener un documento a partir de su identificador
  Future<void> obtenerCita({required DateTime fecha,required BuildContext context}) async {
    try {
      verificar.value = true;

      datosCitas.clear();

      // obtenemos los documentos de la coleccion Citas que tengan el campo fechaNormal igual a la fecha dada del alumno
      QuerySnapshot querySnapshot = await firestore.collection('Citas').
      where('fechaNormal', isEqualTo: fecha.toString().split(' ')[0]).get();
      querySnapshot.docs.forEach((element) {
        datosCitas.add(element.data() as Map<String, dynamic>);
      });
      
      // ordenamos las citas por fecha y hora
      datosCitas.sort((a, b) {
        int comparacionFecha = a['fechaNormal'].compareTo(b['fechaNormal']);

        if (comparacionFecha == 0) {
          // Las fechas son iguales, compara las horas
          String horaA = a['horaCita'].split(' - ')[0];
          String horaB = b['horaCita'].split(' - ')[0];

          return compararHoras(horaA, horaB);
        } else {
          return comparacionFecha;
        }
      });

      verificar.value = false;
    } catch (e) {
      mensajeError.value = 'Algo salio mal, porfavor intente de nuevo más tarde';
      if(!context.mounted) return;
      snackBarError(mensaje: mensajeError.value, context: context);
      verificar.value = false;
    }
  }

  int compararHoras(String horaA, String horaB) {
    int horasA = int.parse(horaA.split(':')[0]);
    int horasB = int.parse(horaB.split(':')[0]);

    if (horaA.toLowerCase().contains('pm') && horasA < 12) {
      horasA += 12;
    }
    
    if (horaB.toLowerCase().contains('pm') && horasB < 12) {
      horasB += 12;
    }

    int minutosA = int.parse(horaA.split(':')[1].replaceAll(RegExp('[^0-9]'), ''));
    int minutosB = int.parse(horaB.split(':')[1].replaceAll(RegExp('[^0-9]'), ''));

    if (horasA != horasB) {
      return horasA.compareTo(horasB);
    } else {
      return minutosA.compareTo(minutosB);
    }
  }

  // Metodo para obtener un documento a partir de su identificador
  Future<void> obtenerAlumno({required String collection, required String id,required BuildContext context}) async {
    try {
      verificar.value = true;
      String coleccionCompleta = '/itz/tecnamex/$collection';
      DocumentSnapshot document = await firestore.collection(coleccionCompleta).doc(id).get();
      datosAlumno.value = document.data() as Map<String, dynamic>;
      numeroControl.value = id;
      obtenerPeriodoEscolar();
      obtenerNumero();
      if(!context.mounted) return;
      await obtenerCarrera(collection: 'planes', id: datosAlumno['clavePlanEstudios'].toString(),context: context);
      nombre.value = datosAlumno['apellidosNombre'];
      verificar.value = false;
    } catch (e) {
      mensajeError.value = 'Algo salio mal, porfavor intente de nuevo más tarde';
      if(!context.mounted) return;
      snackBarError(mensaje: mensajeError.value, context: context);
      verificar.value = false;
    }
  }

  // Metodo para obtener un documento a partir de su identificador
  Future<void> obtenerCarrera({required String collection, required String id,required BuildContext context}) async {
    try {
      verificar.value = true;
      String coleccionCompleta = '/itz/tecnamex/$collection';
      DocumentSnapshot document = await firestore.collection(coleccionCompleta).doc(id).get();
      datosCarrera.value = document.data() as Map<String, dynamic>;
      acortarNombreCarrera();
    } catch (e) {
      mensajeError.value = 'Algo salio mal, porfavor intente de nuevo más tarde';
      if(!context.mounted) return;
      snackBarError(mensaje: mensajeError.value, context: context);
      verificar.value = false;
    }
  }

  // Metodo para actualizar el campo de una cita en firestore por ejemplo 
  // de este arreglo
  // {clavePlanEstudios: ISIC-2010-224, periodoIngreso: 20233, apellidosNombre: ESPINOSA SILVA FRANZ IGNACIO, celular: 7341250002}
  // solo quiero actualizar el campo celular
  // entonces el campo que quiero actualizar es celular y el valor que quiero que tenga es 7341250002
  Future<void> actualizarAlumno({required String collection, required String id, required String campo, required String valor,required BuildContext context}) async {
    try {
      verificar.value = true;
      String coleccionCompleta = '/itz/tecnamex/$collection';
      await firestore.collection(coleccionCompleta).doc(id).update({campo: valor});
      verificar.value = false;
    } catch (e) {
      mensajeError.value = 'Algo salio mal, porfavor intente de nuevo más tarde';
      if(!context.mounted) return;
      snackBarError(mensaje: mensajeError.value, context: context);
      verificar.value = false;
    }
  }

  // metodo para obtener el periodo actual
  // 20223 significa que el periodo escolar se comprende desde Ago - Dic 2022
  // 20222 significa que el periodo escolar se comprende desde Verano 2022
  // 20221 significa que el periodo escolar se comprende desde Ene - Jun 2022
  // en el arreglo esta un campo llamado periodoIngreso donde se encuentra este dato
  obtenerPeriodoEscolar(){
    periodoIngreso.value = datosAlumno['periodoIngreso'].toString();
    String periodoYear = datosAlumno['periodoIngreso'].toString().substring(0, 4);
    String periodoMes = datosAlumno['periodoIngreso'].toString().substring(4, 5);
    if(periodoMes == '1'){
      lastDay.value = DateTime(int.parse(periodoYear), 6, 15);
      periodo.value = 'ENE - JUN $periodoYear';
    }else if(periodoMes == '2'){
      lastDay.value = DateTime(int.parse(periodoYear), 7, 30);
      periodo.value = 'VERANO $periodoYear';
    }else if(periodoMes == '3'){
      lastDay.value = DateTime(int.parse(periodoYear), 12, 15);
      periodo.value = 'AGO - DIC $periodoYear';
    }
  }

  obtenerNumero(){
    telefono.value = datosAlumno['celular'].toString();
    if(telefono.value.isEmpty){
      verificarTelefono.value = true;
    }else{
      verificarTelefono.value = false;
    }
  }


  // Metodo para cambiar nombre carrera por ejemplo:
  // Ingeniería en Sistemas Computacionales
  // Ing. en Sistemas Computacionales
  acortarNombreCarrera(){
    carrera.value = '';
    String nombreCarrera = datosCarrera['nombre'].toString();
    List<String> nombreCarreraSeparado = nombreCarrera.split(' ');
    for(int i = 0; i < nombreCarreraSeparado.length; i++){
      if(i == 0){
        nombreCarreraSeparado[i] = 'ING.';
      }
      carrera.value +=  '${nombreCarreraSeparado[i]} ';
    }
  }

}