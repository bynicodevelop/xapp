import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xapp/providers/FirestoreProvider.dart';
import 'package:xapp/services/FormValidation.dart';

main() {
  test("Doit transfomer un text en slug", () async {
    // ARRANGE
    Map<String, dynamic> texts = {
      'john-doe': 'John doe',
      "test": "TEST",
      "coucou": "Coucou !"
    };

    texts.entries.forEach((value) {
      String slug = slugifyField(value.value);

      expect(slug, value.key);
    });
  });

  test("Doit retrouner true, si le slug est unique et conforme", () async {
    // ARRANGE
    final MockFirestoreProvider firestoreProvider = MockFirestoreProvider();

    when(firestoreProvider.isUniqueSlug(any))
        .thenAnswer((_) => Future.value(true));

    // ACT
    final bool result = await isUniqueSlug('test', firestoreProvider);

    // ASSERT
    expect(result, true);
  });

  test(
      "Doit retrouner false, si le slug n'a pas la bonne taille (la méthode isUniqueSlug n'est pas appellée)",
      () async {
    // ARRANGE
    final MockFirestoreProvider firestoreProvider = MockFirestoreProvider();

    // ACT
    final bool result =
        await isUniqueSlug('test', firestoreProvider, minSize: 6);

    // ASSERT
    verifyNever(firestoreProvider.isUniqueSlug(any));
    expect(result, false);
  });

  test(
      "Doit retrouner false, si le slug n'a pas la bonne taille (par default 3) (la méthode isUniqueSlug n'est pas appellée)",
      () async {
    // ARRANGE
    final MockFirestoreProvider firestoreProvider = MockFirestoreProvider();

    // ACT
    final bool result = await isUniqueSlug('te', firestoreProvider);

    // ASSERT
    verifyNever(firestoreProvider.isUniqueSlug(any));
    expect(result, false);
  });
}

class MockFirestoreProvider extends Mock implements FirestoreProvider {}
