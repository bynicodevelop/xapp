import 'package:cloud_functions/cloud_functions.dart';

class FunctionProvider {
  final FirebaseFunctions functions;

  const FunctionProvider({
    this.functions,
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
}
