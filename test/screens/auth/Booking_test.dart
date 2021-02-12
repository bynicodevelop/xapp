import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xapp/providers/FirestoreProvider.dart';
import 'package:xapp/providers/FunctionProvider.dart';
import 'package:xapp/screens/auth/Booking.dart';

main() {
  testWidgets("Le bouton submit doit être disabled",
      (WidgetTester tester) async {
    // ARRANGE
    final MockFirestoreProvider firestoreProvider = MockFirestoreProvider();

    await tester.pumpWidget(MaterialApp(
      home: Booking(
        firestoreProvider: firestoreProvider,
      ),
    ));

    // ACT
    final RaisedButton submitFinder = tester.widget(find.byType(RaisedButton));
    final texts = tester.widgetList(find.byType(Text));

    // ASSERT
    expect(submitFinder.enabled, false);
    expect(texts.length, 7);
  });

  testWidgets(
      "Doit faire apparaitre un champs email si aucun mail envoyé dans le constructeur",
      (WidgetTester tester) async {
    // ARRANGE
    final MockFirestoreProvider firestoreProvider = MockFirestoreProvider();

    await tester.pumpWidget(MaterialApp(
      home: Booking(
        firestoreProvider: firestoreProvider,
      ),
    ));

    // ACT
    final Finder emailFinder = find.text("Entrez votre email principal");

    // ASSERT
    expect(emailFinder, findsOneWidget);
  });

  testWidgets("Le champs email ne doit pas apparaitre",
      (WidgetTester tester) async {
    // ARRANGE
    final MockFirestoreProvider firestoreProvider = MockFirestoreProvider();

    await tester.pumpWidget(MaterialApp(
      home: Booking(
        firestoreProvider: firestoreProvider,
        email: 'john.doe@domain.tld',
      ),
    ));

    // ACT
    final Finder emailFinder = find.text("Entrez votre email principal");

    // ASSERT
    expect(emailFinder, findsNothing);
  });

  testWidgets(
      "Doit auto compléter le slug quand l'utilisateur saisi sont nom d'utilisateur",
      (WidgetTester tester) async {
    // ARRANGE
    final MockFirestoreProvider firestoreProvider = MockFirestoreProvider();

    when(firestoreProvider.isUniqueSlug(any))
        .thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(MaterialApp(
      home: Booking(
        firestoreProvider: firestoreProvider,
        email: 'john.doe@domain.tld',
      ),
    ));

    final Finder usernameFinder = find.byType(TextFormField).first;
    final Finder slugFinder = find.byType(TextFormField).at(1);

    // ACT
    await tester.enterText(usernameFinder, "john doe");
    await tester.pumpAndSettle();

    final TextFormField textFormField =
        tester.widget(slugFinder) as TextFormField;

    // ASSERT
    expect(textFormField.controller.text, "john-doe");
  });

  testWidgets("Doit rendre enable le bouton submit (slug unique)",
      (WidgetTester tester) async {
    // ARRANGE
    final MockFirestoreProvider firestoreProvider = MockFirestoreProvider();

    when(firestoreProvider.isUniqueSlug(any))
        .thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(MaterialApp(
      home: Booking(
        firestoreProvider: firestoreProvider,
        email: 'john.doe@domain.tld',
      ),
    ));

    final Finder usernameFinder = find.byType(TextFormField).first;

    // ACT
    await tester.enterText(usernameFinder, "john doe");
    await tester.pumpAndSettle();

    final RaisedButton submitRaisedButton =
        tester.widget(find.byType(RaisedButton));

    // ASSERT
    expect(submitRaisedButton.enabled, true);
  });

  testWidgets(
      "Doit afficher une notification quand l'utilisateur utilise un identifiant non unique",
      (WidgetTester tester) async {
    // ARRANGE
    final MockFirestoreProvider firestoreProvider = MockFirestoreProvider();

    when(firestoreProvider.isUniqueSlug(any))
        .thenAnswer((_) => Future.value(false));

    await tester.pumpWidget(MaterialApp(
      home: Booking(
        firestoreProvider: firestoreProvider,
        email: 'john.doe@domain.tld',
      ),
    ));

    final Finder usernameFinder = find.byType(TextFormField).first;

    // ACT
    await tester.enterText(usernameFinder, "john doe");
    await tester.pumpAndSettle();

    final RaisedButton submitRaisedButton =
        tester.widget(find.byType(RaisedButton));

    // ASSERT
    expect(submitRaisedButton.enabled, false);
  });

  // testWidgets(
  //     "Doit rediriger l'utilisateur vers une page de remerciement quand il a cliqué sur le bouton reservé",
  //     (WidgetTester tester) async {
  //   // ARRANGE
  //   final MockNavigatorObserver mockObserver = MockNavigatorObserver();
  //   final MockFirestoreProvider firestoreProvider = MockFirestoreProvider();
  //   final MockFunctionProvider functionProvider = MockFunctionProvider();

  //   when(firestoreProvider.isUniqueSlug(any))
  //       .thenAnswer((_) => Future.value(true));

  //   when(functionProvider.createUserReservation(any, any, any))
  //       .thenAnswer((_) => Future.value(true));

  //   await tester.pumpWidget(
  //     MaterialApp(
  //       navigatorObservers: [mockObserver],
  //       home: Booking(
  //         firestoreProvider: firestoreProvider,
  //         email: 'john.doe@domain.tld',
  //       ),
  //     ),
  //   );

  //   final Finder usernameFinder = find.byType(TextFormField).first;

  //   await tester.enterText(usernameFinder, "john doe");
  //   await tester.pumpAndSettle();

  //   // ACT
  //   await tester.tap(find.byType(RaisedButton));
  //   await tester.pumpAndSettle();

  //   // ASSERT
  //   verify(mockObserver.didPush(any, any));
  // });

  // testWidgets(
  //     "Doit afficher un message d'erreur si un problème technique est survenue",
  //     (WidgetTester tester) async {
  //   // ARRANGE
  //   final MockNavigatorObserver mockObserver = MockNavigatorObserver();
  //   final MockFirestoreProvider firestoreProvider = MockFirestoreProvider();
  //   final MockFunctionProvider functionProvider = MockFunctionProvider();

  //   when(firestoreProvider.isUniqueSlug(any))
  //       .thenAnswer((_) => Future.value(true));

  //   when(functionProvider.createUserReservation(any, any, any))
  //       .thenAnswer((_) => Future.value(false));

  //   await tester.pumpWidget(
  //     MaterialApp(
  //       navigatorObservers: [mockObserver],
  //       home: Booking(
  //         firestoreProvider: firestoreProvider,
  //         email: 'john.doe@domain.tld',
  //       ),
  //     ),
  //   );

  //   final Finder usernameFinder = find.byType(TextFormField).first;

  //   await tester.enterText(usernameFinder, "john doe");
  //   await tester.pumpAndSettle();

  //   // ACT
  //   await tester.tap(find.byType(RaisedButton));
  //   await tester.pumpAndSettle();

  //   final Finder errorMessage = find.byType(SnackBar);
  //   await tester.pumpAndSettle();

  //   // ASSERT
  //   expect(errorMessage, findsOneWidget);
  // });
}

class MockFirestoreProvider extends Mock implements FirestoreProvider {}

class MockFunctionProvider extends Mock implements FunctionProvider {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}
