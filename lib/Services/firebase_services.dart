import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';


class FirebaseServicesS extends GetxController{

  var verificar = false.obs;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  FirebaseStorage storage = FirebaseStorage.instance;

  FirebaseAuth auth = FirebaseAuth.instance;

  var datosCita = {};

  var numeroControl = ''.obs;

  // User? usuario;
  // UserCredential? usuarioCredencial;

  // obtenerNumeroContol(String email){
  //   String nc = email.split('@')[0];
  //   nc = nc.replaceAll('L', '');
  //   nc = nc.replaceAll('l', '');
  //   numeroControl = nc;
  // }

  // // Metodo para autenticar un usuario
  // Future<void> autenticarUsuario({required String email, required String password}) async {
  //   try {
  //     usuarioCredencial = await auth.signInWithEmailAndPassword(email: email, password: password);
  //     if(usuarioCredencial != null){
  //       usuario = usuarioCredencial!.user;
  //       obtenerNumeroContol(email);
  //       verificar.value = true;
  //     }else{
  //       verificar.value = false;
  //     }
  //   } catch (e) {
  //     verificar.value = false;
  //   }
  // }

  // Metodo para subir información de una cita a firestore
  Future<void> agregarCita({required String collection, required Map<String, dynamic> data}) async {
    try {
      await firestore.collection(collection).add(data);
      verificar.value = true;
    } catch (e) {
      verificar.value = false;
    }
  }

  // Metodo para obtener un documento a partir de su identificador
  Future<void> obtenerDocumento({required String collection, required String id}) async {
    try {
      DocumentSnapshot document = await firestore.collection(collection).doc(id).get();
      datosCita = document.data() as Map<String, dynamic>;
      verificar.value = true;
    } catch (e) {
      verificar.value = false;
    }
  }
}