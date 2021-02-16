import 'package:cloud_functions/cloud_functions.dart';
import 'package:xapp/providers/AuthProvider.dart';

class FunctionProvider {
  final FirebaseFunctions functions;
  final AuthProvider auth;

  const FunctionProvider({
    this.functions,
    this.auth,
  });

  Future<bool> createUserReservation(
      String email, String displayName, String slug) async {
    try {
      await functions.httpsCallable('createUserReservation').call({
        'email': email,
        'displayName': displayName,
        'slug': slug,
      });

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> createAccount(
      String email, String displayName, String slug, String uid) async {
    try {
      HttpsCallableResult callableResult =
          await functions.httpsCallable("createUserAccount").call({
        'email': email,
        'displayName': displayName,
        'slug': slug,
        'uid': uid,
      });

      return callableResult.data['status'] == 'ok' ? true : false;
    } catch (e) {
      print(e);
    }

    return false;
  }

  Future follow(String userId) async {
    if (!auth.isAuthenticated) {
      throw Exception("user/unauthenticated");
    }

    try {
      await functions.httpsCallable("follow").call({
        "userIdFrom": auth.userModel.id,
        "userIdTo": userId,
      });
    } catch (e) {
      print(e);
    }
  }

  Future unfollow(String userId) async {
    if (!auth.isAuthenticated) {
      throw Exception("user/unauthenticated");
    }

    try {
      await functions.httpsCallable("unfollow").call({
        "userIdFrom": auth.userModel.id,
        "userIdTo": userId,
      });
    } catch (e) {
      print(e);
    }
  }
}
