import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:xapp/models/Post.dart';
import 'package:xapp/models/User.dart';
import 'package:xapp/providers/AuthProvider.dart';

enum INVITED {
  INVALID_EMAIL,
  EMAIL_NOT_FOUND,
  VALID,
}

class FirestoreProvider {
  final List<Post> _posts = List<Post>();
  Post _currentPost;

  final StreamController<List<Post>> _postsStream =
      StreamController<List<Post>>.broadcast();

  final FirebaseFirestore firestore;
  final AuthProvider authProvider;

  FirestoreProvider({
    this.firestore,
    this.authProvider,
  });

  get currentPost => _currentPost;

  set currentPost(value) => _currentPost = value;

  Stream<List<Post>> get posts => _postsStream.stream;

  /// Permet de récupérer un post pour le feed
  getPost({
    int limit = 2,
    Post post,
  }) async {
    Query query = this
        .firestore
        .collection('posts')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .limit(limit);

    if (post != null) {
      query = query.startAfterDocument(post.document);
    } else {
      _posts.clear();
    }

    query.snapshots().listen(
          (doc) => doc.docs.forEach(
            (post) {
              final dynamic data = post.data();

              print('Post Id: ${post.id}');

              // TODO: Voir s'il n'es pas possible de stocker les requêtes
              data['userRef'].get().then((user) {
                User userModel = User.fromJson({
                  ...user.data(),
                  ...{User.ID: user.id}
                });

                _posts.add(
                  Post.fromJson({
                    ...data,
                    ...{
                      Post.ID: post.id,
                      Post.DOCUMENT: post,
                      Post.USER: userModel,
                    }
                  }),
                );

                _postsStream.add(_posts);
              });
            },
          ),
        );
  }

  /// Permet de vérifier que le slug n'est pas déjà utilisé
  Future<bool> isUniqueSlug(String slug) async {
    DocumentSnapshot documentSnapshot =
        await firestore.collection('slugs').doc(slug).get();

    return Future.value(!documentSnapshot.exists);
  }

  /// Permet de valider que l'email n'est pas déjà utilisé par quelqu'un d'autre
  Future<bool> isUniqueEmail(String email) async {
    if (!EmailValidator.validate(email)) {
      return false;
    }

    QuerySnapshot querySnapshot = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    return querySnapshot.docs.length == 0;
  }

  /// Permet de vérifier que l'email est bien un email invité
  Future<INVITED> isInvitedEmail(String email) async {
    if (!EmailValidator.validate(email)) {
      return Future.value(INVITED.INVALID_EMAIL);
    }

    DocumentSnapshot documentSnapshot =
        await firestore.collection('invitations').doc(email).get();

    if (!documentSnapshot.exists) {
      return Future.value(INVITED.EMAIL_NOT_FOUND);
    }

    return Future.value(INVITED.VALID);
  }
}
