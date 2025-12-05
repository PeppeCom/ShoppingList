import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/pages/services/database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Autenticazione {
  FirebaseAuth auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();
  CollectionReference utente = FirebaseFirestore.instance.collection('Utenti');

  // Current User
  Future getCurrentUser() async {
    return auth.currentUser;
  }

  //ACCESSO CON GOOGLE
  Future signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn
          .signIn();

      GoogleSignInAuthentication? googleSignInAuthentication =
          await googleSignInAccount?.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication?.idToken,
        accessToken: googleSignInAuthentication?.accessToken,
      );

      final UserCredential authResult = await auth.signInWithCredential(
        credential,
      );
      final User? user = authResult.user;

      await DatabaseService(uid: user?.uid).updateUserData(
        user!.displayName ?? 'N/A',
        user.email ?? 'N/A',
        user.providerData[0].providerId,
      );
      // ignore: non_constant_identifier_names
    } catch (PlatformException) {
      // ignore: avoid_print
      print(PlatformException);
      // ignore: avoid_print
      print('Accesso non riuscito');
    }
  }

  //Metodo di Accesso con Email e Password
  Future signInWithEmailAndPassword(
    String email,
    String password,
    String nome,
    String immagine,
  ) async {
    UserCredential result = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    User? user = result.user;
    user?.updateProfile(displayName: nome, photoURL: immagine);
    await DatabaseService(uid: user?.uid).updateUserData(
      user!.displayName ?? 'N/A',
      user.email ?? 'N/A',
      user.providerData[0].providerId,
    );
  }

  //Metodo Registrazione con Email e Password
  Future registerWithEmailAndPassword(
    String email,
    String password,
    String nome,
    String immagine,
  ) async {
    try {
      UserCredential result = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      user?.updateProfile(displayName: nome, photoURL: immagine);
      await DatabaseService(uid: user?.uid).updateUserData(
        user!.displayName ?? 'N/A',
        user.email ?? 'N/A',
        user.providerData[0].providerId,
      );
    } catch (e) {
      // ignore: avoid_print
      print(e.toString());
      return null;
    }
  }

  // METDODO LOGOUT FROM GOOGLE
  Future signOutGoogleUser() async {
    try {
      await googleSignIn.disconnect();
    } catch (e) {
      // ignore: avoid_print
      print(e.toString());
    }
  }
}
