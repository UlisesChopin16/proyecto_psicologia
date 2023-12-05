import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class FirebaseServicesS extends GetxController{

  var verificar = false.obs;
  var verificarCitaExistente = false.obs; 
  var verificarTelefono = false.obs;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  FirebaseStorage storage = FirebaseStorage.instance;

  FirebaseAuth auth = FirebaseAuth.instance;

  RxList<Map<String,dynamic>> datosCitas = <Map<String,dynamic>>[].obs;

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


  // Metodo para autenticar un usuario
  Future<void> autenticarUsuario({required String numeroC, required String password}) async {
    try {
      verificar.value = true;
      String email = '$numeroC@tecnamex.com';
      usuarioCredencial = await auth.signInWithEmailAndPassword(email: email, password: password);
      if(usuarioCredencial != null){
        numeroControl.value = numeroC;
        usuario = usuarioCredencial!.user;
        verificar.value = false;
      }else{
        mensajeError.value = 'Usuario o contraseña incorrectos';
        verificar.value = false;
      }
    } catch (e) {
      mensajeError.value = 'Algo salio mal, porfavor intente de nuevo más tarde';
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(
            mensajeError.value,
            style: const TextStyle(
              fontSize: 18
            ),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        )
      );
      verificar.value = false;
    }
  }


  // Metodo para verificar si existe la cita el nombre del documento es la fecha y hora de la cita
  Future<void> verificarCita({required String collection,required String id,}) async {
    try {
      verificar.value = true;
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
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(
            mensajeError.value,
            style: const TextStyle(
              fontSize: 18
            ),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        )
      );
      verificar.value = false;
    }
  }


  // Metodo para subir información de una cita a firestore con un identificador
  Future<void> agregarCita({required String collection,required String id, required Map<String, dynamic> data}) async {
    try {
      verificar.value = true;
      await firestore.collection(collection).doc(id).set(data);
    } catch (e) {
      mensajeError.value = 'Algo salio mal, porfavor intente de nuevo más tarde';
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(
            mensajeError.value,
            style: const TextStyle(
              fontSize: 18
            ),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        )
      );
      verificar.value = false;
    }
  }

  // Metodo para subir un archivo pdf a firebase storage con Uint8List
  Future<void> subirArchivo({required Uint8List data,required String nombre}) async {
    try {
      verificar.value = true;
      final Reference ref = storage.ref().child('CitasPsicologia').child(nombre);
      final UploadTask uploadTask = ref.putData(data);

      await uploadTask.whenComplete(() => true);
      verificar.value = false;
    } catch (e) {
      mensajeError.value = 'Algo salio mal, porfavor intente de nuevo más tarde';
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(
            mensajeError.value,
            style: const TextStyle(
              fontSize: 18
            ),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        )
      );
      verificar.value = false;
    }
  }

  // Metodo para obtener un documento a partir de su identificador
  Future<void> obtenerCita({required DateTime fecha}) async {
    try {
      verificar.value = true;
      print(fecha.toString().split(' ')[0]);
      // obtenemos los documentos de la coleccion Citas que tengan el campo fechaNormal igual a la fecha dada del alumno
      QuerySnapshot querySnapshot = await firestore.collection('Citas').
      where('fechaNormal', isEqualTo: fecha.toString().split(' ')[0]).get();
      querySnapshot.docs.forEach((element) {
        datosCitas.add(element.data() as Map<String, dynamic>);
        print(datosCitas);
      });
      verificar.value = false;
    } catch (e) {
      mensajeError.value = 'Algo salio mal, porfavor intente de nuevo más tarde';
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(
            mensajeError.value,
            style: const TextStyle(
              fontSize: 18
            ),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        )
      );
      verificar.value = false;
    }
  }

  // Metodo para obtener un documento a partir de su identificador
  Future<void> obtenerAlumno({required String collection, required String id}) async {
    try {
      verificar.value = true;
      String coleccionCompleta = '/itz/tecnamex/$collection';
      DocumentSnapshot document = await firestore.collection(coleccionCompleta).doc(id).get();
      datosAlumno.value = document.data() as Map<String, dynamic>;

      numeroControl.value = id;
      obtenerPeriodoEscolar();
      obtenerNumero();
      await obtenerCarrera(collection: 'planes', id: datosAlumno['clavePlanEstudios'].toString());
      nombre.value = datosAlumno['apellidosNombre'];
      verificar.value = false;
    } catch (e) {
      mensajeError.value = 'Algo salio mal, porfavor intente de nuevo más tarde';
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(
            mensajeError.value,
            style: const TextStyle(
              fontSize: 18
            ),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        )
      );
      verificar.value = false;
    }
  }

  // Metodo para obtener un documento a partir de su identificador
  Future<void> obtenerCarrera({required String collection, required String id}) async {
    try {
      verificar.value = true;
      String coleccionCompleta = '/itz/tecnamex/$collection';
      DocumentSnapshot document = await firestore.collection(coleccionCompleta).doc(id).get();
      datosCarrera.value = document.data() as Map<String, dynamic>;
      acortarNombreCarrera();
    } catch (e) {
      mensajeError.value = 'Algo salio mal, porfavor intente de nuevo más tarde';
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(
            mensajeError.value,
            style: const TextStyle(
              fontSize: 18
            ),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        )
      );
      verificar.value = false;
    }
  }

  // Metodo para actualizar el campo de una cita en firestore por ejemplo 
  // de este arreglo
  // {clavePlanEstudios: ISIC-2010-224, periodoIngreso: 20233, apellidosNombre: ESPINOSA SILVA FRANZ IGNACIO, celular: 7341250002}
  // solo quiero actualizar el campo celular
  // entonces el campo que quiero actualizar es celular y el valor que quiero que tenga es 7341250002
  Future<void> actualizarAlumno({required String collection, required String id, required String campo, required String valor}) async {
    try {
      verificar.value = true;
      String coleccionCompleta = '/itz/tecnamex/$collection';
      await firestore.collection(coleccionCompleta).doc(id).update({campo: valor});
      verificar.value = false;
    } catch (e) {
      mensajeError.value = 'Algo salio mal, porfavor intente de nuevo más tarde';
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(
            mensajeError.value,
            style: const TextStyle(
              fontSize: 18
            ),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        )
      );
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