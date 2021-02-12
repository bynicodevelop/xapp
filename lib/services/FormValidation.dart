library form_validation;

import 'package:slugify/slugify.dart';
import 'package:xapp/providers/FirestoreProvider.dart';

slugifyField(String text) {
  String string = Slugify(text);

  string = string.substring(string.length - 1).contains('-')
      ? string.substring(0, string.length - 1)
      : string;

  return string;
}

isUniqueSlug(String slug, FirestoreProvider firestoreProvider,
    {int minSize = 3}) async {
  if (slug.isNotEmpty && slug.length >= minSize) {
    return await firestoreProvider.isUniqueSlug(slug);
  }

  return false;
}
