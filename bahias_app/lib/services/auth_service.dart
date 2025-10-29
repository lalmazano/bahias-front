import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb; 

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Stream<User?> get userChanges => _auth.userChanges();

  Future<void> signInWithGoogle() async {
    try {
      // ✅ Diferente configuración para Web y móvil
      GoogleSignIn googleSignIn;

      if (kIsWeb) {
        googleSignIn = GoogleSignIn(
          clientId:
              '286265416101-l9ufepdosekt2pk59po6ftli29695782.apps.googleusercontent.com', 
        );
      } else {
        googleSignIn = GoogleSignIn(); // usa config nativa
      }

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // usuario canceló

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (kIsWeb) {
      await _auth.signOut();
    } else {
      await GoogleSignIn().signOut();
      await _auth.signOut();
    }
  }
}

