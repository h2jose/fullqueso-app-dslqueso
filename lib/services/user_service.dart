
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ubiiqueso/models/models.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<DocumentSnapshot> signin(String id, String password) async {
  final code = id.toLowerCase();
  final DocumentSnapshot data = await db.collection('users').doc(code).get();
  if (data.exists) {

    UserModel user = UserModel.fromJson(data.data() as Map<String, dynamic>);

    if (user.role != 'EXPRESS') {
      throw 'Usuario no autorizado';
    }

    final emailAddress = "$code@full.queso";

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailAddress, password: password);
      //FirebaseMessaging.instance.subscribeToTopic(user.code!);

      //debugPrint("credential: $credential");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        debugPrint('No user found for that email.');
        throw 'Código de Usuario no existe';
      } else if (e.code == 'wrong-password') {
        debugPrint('Wrong password provided for that user.');
        throw 'Contraseña incorrecta';
      }
    }
    return data;
  } else {
    throw 'Usuario no encontrado';
  }
}