import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xapp/providers/FirestoreProvider.dart';
import 'package:xapp/screens/auth/Booking.dart';
import 'package:xapp/screens/auth/Login.dart';
import 'package:xapp/screens/auth/Registration.dart';

main() {
  testWidgets('Le bouton doit être disabled', (WidgetTester tester) async {
    // ARRANGE
    final MockFirestoreProvider firestoreProvider = MockFirestoreProvider();

    final String errorMessageText =
        'Nous ne pouvons pas vous inscrire avec cette adresse email';

    await tester.pumpWidget(
      MaterialApp(
        home: Registration(
          firestoreProvider: firestoreProvider,
        ),
      ),
    );

    // ACT
    final RaisedButton raisedButton =
        tester.widget<RaisedButton>(find.byType(RaisedButton));

    final Finder errorMessage = find.text(errorMessageText);

    // ASSERT
    expect(raisedButton.enabled, false);
    expect(errorMessage, findsNothing);
  });

  testWidgets(
      'Doit ne pas rendre le bouton clickable avec une adresse email invalide',
      (WidgetTester tester) async {
    // ARRANGE
    final MockFirestoreProvider firestoreProvider = MockFirestoreProvider();

    final String email = 'john.doe';
    final String errorMessageText =
        "Actuellement, votre email n'est pas valide.";

    await tester.pumpWidget(
      MaterialApp(
        home: Registration(
          firestoreProvider: firestoreProvider,
        ),
      ),
    );

    final Finder textFormField = find.byType(TextFormField);

    // ACT
    await tester.enterText(textFormField, email);
    await tester.pumpAndSettle();

    // ASSERT
    final RaisedButton raisedButton =
        tester.widget<RaisedButton>(find.byType(RaisedButton));

    final Finder errorMessage = find.text(errorMessageText);

    expect(raisedButton.enabled, false);
    expect(errorMessage, findsOneWidget);
  });

  testWidgets(
      "Doit rediriger l'utilisateur vers la page de reservation de nom d'utilisateur",
      (WidgetTester tester) async {
    // ARRANGE
    final MockNavigatorObserver mockObserver = MockNavigatorObserver();
    final MockFirestoreProvider firestoreProvider = MockFirestoreProvider();

    final String email = 'john.doe@domain.tld';

    when(firestoreProvider.isInvitedEmail(email))
        .thenAnswer((_) => Future.value(INVITED.EMAIL_NOT_FOUND));

    when(firestoreProvider.isUniqueEmail(email))
        .thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [mockObserver],
        home: Registration(
          firestoreProvider: firestoreProvider,
        ),
      ),
    );

    final Finder textFormField = find.byType(TextFormField);

    // ACT
    await tester.enterText(textFormField, email);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(RaisedButton));
    await tester.pumpAndSettle();

    // ASSERT
    verify(mockObserver.didPush(any, any));
    expect(find.byType(Booking), findsOneWidget);
  });

  testWidgets(
      "Doit rediriger l'utilisateur vers un fomulaire de login, si celui-ci à déjà un compte.",
      (WidgetTester tester) async {
    // ARRANGE
    final MockNavigatorObserver mockObserver = MockNavigatorObserver();
    final MockFirestoreProvider firestoreProvider = MockFirestoreProvider();

    final String email = 'john.doe@domain.tld';

    when(firestoreProvider.isInvitedEmail(email))
        .thenAnswer((_) => Future.value(INVITED.EMAIL_NOT_FOUND));

    when(firestoreProvider.isUniqueEmail(email))
        .thenAnswer((_) => Future.value(false));

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [mockObserver],
        home: Registration(
          firestoreProvider: firestoreProvider,
        ),
      ),
    );

    final Finder textFormField = find.byType(TextFormField);

    // ACT
    await tester.enterText(textFormField, email);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(RaisedButton));
    await tester.pumpAndSettle();

    // ASSERT
    verify(mockObserver.didPush(any, any));
    expect(find.byType(Login), findsOneWidget);
  });
}

class MockFirestoreProvider extends Mock implements FirestoreProvider {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}
