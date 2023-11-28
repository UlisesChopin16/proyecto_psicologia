import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FirebaseServices {

  bool verificar = false;
  
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  FirebaseStorage storage = FirebaseStorage.instance;

  FirebaseAuth auth = FirebaseAuth.instance;

  Map<String,dynamic> datosCita = {};

  String numeroControl = '';

  User? usuario;
  UserCredential? usuarioCredencial;

  obtenerNumeroContol(String email){
    String nc = email.split('@')[0];
    nc = nc.replaceAll('L', '');
    nc = nc.replaceAll('l', '');
    numeroControl = nc;
  }

  // Metodo para autenticar un usuario
  Future<void> autenticarUsuario({required String email, required String password}) async {
    try {
      obtenerNumeroContol(email);
      usuarioCredencial = await auth.signInWithEmailAndPassword(email: email, password: password);
      usuario = usuarioCredencial!.user;
      verificar = true;
    } catch (e) {
      verificar = false;
    }
  }

  // Metodo para subir información de una cita a firestore
  Future<void> agregarCita({required String collection, required Map<String, dynamic> data}) async {
    try {
      await firestore.collection(collection).add(data);
      verificar = true;
    } catch (e) {
      verificar = false;
    }
  }

  // Metodo para obtener un documento a partir de su identificador
  Future<void> obtenerDocumento({required String collection, required String id}) async {
    try {
      DocumentSnapshot document = await firestore.collection(collection).doc(id).get();
      datosCita = document.data() as Map<String, dynamic>;
      verificar = true;
    } catch (e) {
      verificar = false;
    }
  }
}