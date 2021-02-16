import 'package:firebase_auth/firebase_auth.dart';
import 'package:xapp/models/UserModel.dart';

class AuthProvider {
  final FirebaseAuth auth;

  UserModel _userModel;
  bool _connected = false;

  AuthProvider({
    this.auth,
  });

  bool get isAuthenticated => _connected;
  UserModel get userModel => _userModel;

  Stream<UserModel> get user {
    return auth.authStateChanges().asyncMap((user) async {
      print('Auth user: $user');

      if (user == null) return null;

      _connected = true;

      _userModel = UserModel(
        id: user.uid,
        email: user.email,
      );

      return _userModel;
    });
  }

  Future login(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print(e.code);
      throw new Exception(e.code);
    }
  }

  Future logout() async {
    await auth.signOut();
  }

  Future<String> createAccount(
    String email,
    String password,
    String displyName,
    String slug,
  ) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    }

    return null;
  }
}
