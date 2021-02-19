import 'package:xapp/providers/AuthProvider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginService {
  Future<String> auth(String email, String password, AuthProvider authProvider,
      AppLocalizations t) async {
    try {
      await authProvider.login(
        email,
        password,
      );
    } catch (e) {
      String message = t.conectionErrorMessage;

      switch (e.message) {
        case 'user-not-found':
        case 'wrong-password':
          message = t.badCredentialErrorMessage;
          break;
        case 'too-many-requests':
          message = t.tooManyRequestErrorMessage;
          break;
      }

      return Future.value(message);
    }

    return Future.value(null);
  }
}
