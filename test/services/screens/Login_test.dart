import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xapp/providers/AuthProvider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xapp/services/screens/LoginService.dart';

main() {
  test("Doit retourner null", () async {
    // ARRANGE
    String email = 'john.doe@domaint.tld';
    String password = 'john.doe@domaint.tld';
    MockAuthProvider authProvider = MockAuthProvider();
    MockAppLocalizations appLocalizations = MockAppLocalizations();

    when(authProvider.login(email, password))
        .thenAnswer((_) => Future.value(true));

    LoginService login = LoginService();

    // ACT
    String result =
        await login.auth(email, password, authProvider, appLocalizations);

    // ASSERT
    expect(result, null);
  });

  test(
      "Doit un message indiquant qu'il y a eu trop de connexion (too-many-requests)",
      () async {
    // ARRANGE
    String email = 'john.doe@domaint.tld';
    String password = 'john.doe@domaint.tld';
    MockAuthProvider authProvider = MockAuthProvider();
    MockAppLocalizations appLocalizations = MockAppLocalizations();

    when(authProvider.login(email, password))
        .thenThrow(Exception('too-many-requests'));

    when(appLocalizations.tooManyRequestErrorMessage)
        .thenReturn('too-many-request');

    LoginService login = LoginService();

    // ACT
    String result =
        await login.auth(email, password, authProvider, appLocalizations);

    // ASSERT
    expect(result, appLocalizations.tooManyRequestErrorMessage);
  });

  test(
      "Doit un message indiquant que les identifiants ne sont pas correcte (wrong-password)",
      () async {
    // ARRANGE
    String email = 'john.doe@domaint.tld';
    String password = 'john.doe@domaint.tld';
    MockAuthProvider authProvider = MockAuthProvider();
    MockAppLocalizations appLocalizations = MockAppLocalizations();

    when(authProvider.login(email, password))
        .thenThrow(Exception('wrong-password'));

    when(appLocalizations.badCredentialErrorMessage)
        .thenReturn('wrong-password');

    LoginService login = LoginService();

    // ACT
    String result =
        await login.auth(email, password, authProvider, appLocalizations);

    // ASSERT
    expect(result, appLocalizations.badCredentialErrorMessage);
  });

  test(
      "Doit un message indiquant que les identifiants ne sont pas correcte (user-not-found)",
      () async {
    // ARRANGE
    String email = 'john.doe@domaint.tld';
    String password = 'john.doe@domaint.tld';
    MockAuthProvider authProvider = MockAuthProvider();
    MockAppLocalizations appLocalizations = MockAppLocalizations();

    when(authProvider.login(email, password))
        .thenThrow(Exception('user-not-found'));

    when(appLocalizations.badCredentialErrorMessage)
        .thenReturn('wrong-password');

    LoginService login = LoginService();

    // ACT
    String result =
        await login.auth(email, password, authProvider, appLocalizations);

    // ASSERT
    expect(result, appLocalizations.badCredentialErrorMessage);
  });
}

class MockAuthProvider extends Mock implements AuthProvider {}

class MockAppLocalizations extends Mock implements AppLocalizations {}
