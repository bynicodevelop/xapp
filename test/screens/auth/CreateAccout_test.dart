import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xapp/providers/FirestoreProvider.dart';
import 'package:xapp/screens/auth/CreateAccount.dart';

main() {
  testWidgets("Doit rendre enable le bouton de création de compte",
      (WidgetTester tester) async {
    // ARRANGE
    final MockFirestoreProvider firestoreProvider = MockFirestoreProvider();

    when(firestoreProvider.isUniqueSlug(any))
        .thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(
      MaterialApp(
        home: CreateAccount(
          firestoreProvider: firestoreProvider,
          email: 'john.doe@domain.tld',
        ),
      ),
    );

    RaisedButton buttonFinder = tester.widget(find.byType(RaisedButton));

    expect(buttonFinder.enabled, false);

    // ASSERT

    final Finder textFormField = find.byType(TextFormField);

    // ACT
    await tester.enterText(textFormField.first, "username");
    await tester.pumpAndSettle();

    await tester.enterText(textFormField.last, "123456");
    await tester.pumpAndSettle();

    // ASSERT
    buttonFinder = tester.widget(find.byType(RaisedButton));

    expect(buttonFinder.enabled, true);
  });
}

class MockFirestoreProvider extends Mock implements FirestoreProvider {}
