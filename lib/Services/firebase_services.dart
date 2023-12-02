import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';


class FirebaseServicesS extends GetxController{

  var verificar = false.obs;
  var verificarTelefono = false.obs;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  FirebaseStorage storage = FirebaseStorage.instance;

  FirebaseAuth auth = FirebaseAuth.instance;

  var datosCita = <String,dynamic>{}.obs;
  var datosCarrera = <String,dynamic>{}.obs;

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
      verificar.value = false;
    }
  }

  // Metodo para subir información de una cita a firestore
  Future<void> agregarCita({required String collection, required Map<String, dynamic> data}) async {
    try {
      verificar.value = true;
      await firestore.collection(collection).add(data);
      verificar.value = false;
    } catch (e) {
      mensajeError.value = 'Algo salio mal, porfavor intente de nuevo más tarde';
      verificar.value = false;
    }
  }

  // Metodo para obtener un documento a partir de su identificador
  Future<void> obtenerAlumno({required String collection, required String id}) async {
    try {
      verificar.value = true;
      String coleccionCompleta = '/itz/tecnamex/$collection';
      DocumentSnapshot document = await firestore.collection(coleccionCompleta).doc(id).get();
      datosCita.value = document.data() as Map<String, dynamic>;

      numeroControl.value = id;
      obtenerPeriodoEscolar();
      obtenerNumero();
      await obtenerCarrera(collection: 'planes', id: datosCita['clavePlanEstudios'].toString());
      nombre.value = datosCita['apellidosNombre'];

      verificar.value = false;
    } catch (e) {
      mensajeError.value = 'Algo salio mal, porfavor intente de nuevo más tarde';
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
      carrera.value = datosCarrera['nombre'];
      verificar.value = false;
    } catch (e) {
      mensajeError.value = 'Algo salio mal, porfavor intente de nuevo más tarde';
      verificar.value = false;
    }
  }

  // Metodo para actualizar un el campo de una cita en firestore
  Future<void> actualizarCita({required String collection, required String id, required Map<String, dynamic> data}) async {
    try {
      verificar.value = true;
      String coleccionCompleta = '/itz/tecnamex/$collection';
      await firestore.collection(coleccionCompleta).doc(id).update(data);
      await obtenerAlumno(collection: collection, id: id);
      verificar.value = false;
    } catch (e) {
      mensajeError.value = 'Algo salio mal, porfavor intente de nuevo más tarde';
      verificar.value = false;
    }
  }

  // metodo para obtener el periodo actual
  // 20223 significa que el periodo escolar se comprende desde Ago - Dic 2022
  // 20222 significa que el periodo escolar se comprende desde Verano 2022
  // 20221 significa que el periodo escolar se comprende desde Ene - Jun 2022
  // en el arreglo esta un campo llamado periodoIngreso donde se encuentra este dato
  obtenerPeriodoEscolar(){
    String periodoYear = datosCita['periodoIngreso'].toString().substring(0, 4);
    String periodoMes = datosCita['periodoIngreso'].toString().substring(4, 5);
    if(periodoMes == '1'){
      periodo.value = 'Ene - Jun $periodoYear';
    }else if(periodoMes == '2'){
      periodo.value = 'Verano $periodoYear';
    }else if(periodoMes == '3'){
      periodo.value = 'Ago - Dic $periodoYear';
    }
    print(periodo);
  }

  obtenerNumero(){
    telefono.value = datosCita['celular'].toString();
    if(telefono.value.isEmpty){
      verificarTelefono.value = true;
    }else{
      verificarTelefono.value = false;
    }
  }

}