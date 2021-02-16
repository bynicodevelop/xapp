import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:xapp/Config.dart';
import 'package:xapp/models/PostModel.dart';
import 'package:xapp/models/UserModel.dart';
import 'package:xapp/providers/AuthProvider.dart';

enum INVITED {
  INVALID_EMAIL,
  EMAIL_NOT_FOUND,
  VALID,
}

class FirestoreProvider {
  final List<PostModel> _posts = List<PostModel>();
  PostModel _currentPost;

  final StreamController<List<PostModel>> _postsStream =
      StreamController<List<PostModel>>.broadcast();

  final List<PostModel> _profilePostModels = List<PostModel>();

  final FirebaseFirestore firestore;
  final AuthProvider authProvider;

  FirestoreProvider({
    this.firestore,
    this.authProvider,
  });

  get currentPost => _currentPost;

  set currentPost(value) => _currentPost = value;

  Stream<List<PostModel>> get posts => _postsStream.stream;

  get profilPosts => _profilePostModels;

  /// Permet de récupérer un post pour le feed
  getPost({
    int limit = 2,
    PostModel post,
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

              print('PostModel Id: ${post.id}');

              // TODO: Voir s'il n'es pas possible de stocker les requêtes
              data['userRef'].get().then((user) {
                UserModel userModel = UserModel.fromJson({
                  ...user.data(),
                  ...{UserModel.ID: user.id}
                });

                _posts.add(
                  PostModel.fromJson({
                    ...data,
                    ...{
                      PostModel.ID: post.id,
                      PostModel.DOCUMENT: post,
                      PostModel.USER: userModel,
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

  Future getProfilePosts(String userId) async {
    if (_profilePostModels.length >= Config.maxPostWhenUserIsNotAuthenticated)
      return;

    DocumentReference documentReference =
        firestore.collection('users').doc(userId);

    Query postQuery = firestore
        .collection('posts')
        .orderBy('createdAt')
        .where('userRef', isEqualTo: documentReference)
        .limit(6);

    if (_profilePostModels.length > 0) {
      postQuery =
          postQuery.startAfterDocument(_profilePostModels.last.document);
    }

    QuerySnapshot postQuerySnapshot = await postQuery.get();

    postQuerySnapshot.docs.forEach((doc) {
      _profilePostModels.add(
        PostModel.fromJson({
          ...doc.data(),
          ...{
            PostModel.ID: doc.id,
            PostModel.DOCUMENT: doc,
          }
        }),
      );
    });
  }
}
