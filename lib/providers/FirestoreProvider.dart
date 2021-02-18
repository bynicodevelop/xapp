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
  final List<PostModel> _profilePostModels = List<PostModel>();

  PostModel _currentPost;

  final StreamController<UserModel> _currentUserProfile =
      StreamController<UserModel>.broadcast();

  final StreamController<UserModel> _currentUser =
      StreamController<UserModel>.broadcast();

  final StreamController<bool> isFollowedController =
      StreamController<bool>.broadcast();

  final StreamController<List<PostModel>> _postsStream =
      StreamController<List<PostModel>>.broadcast();

  final StreamController<List<PostModel>> _profilePostsStream =
      StreamController<List<PostModel>>.broadcast();

  final FirebaseFirestore firestore;
  final AuthProvider authProvider;

  FirestoreProvider({
    this.firestore,
    this.authProvider,
  });

  get currentPost => _currentPost;

  set currentPost(value) => _currentPost = value;

  Stream<List<PostModel>> get profilPosts => _profilePostsStream.stream;

  Stream<List<PostModel>> get posts => _postsStream.stream;

  cleanProfilePosts() => _profilePostModels.clear();

  PostModel _convertToPostModel(
    DocumentSnapshot post,
    DocumentSnapshot user,
  ) {
    return PostModel.fromJson({
      ...post.data(),
      ...{
        PostModel.ID: post.id,
        PostModel.DOCUMENT: post,
        PostModel.USER: UserModel.fromJson({
          ...user.data(),
          ...{
            UserModel.ID: user.id,
          }
        }),
      }
    });
  }

  UserModel _convertToUserModel(
    DocumentSnapshot user, {
    DocumentSnapshot followings,
    QuerySnapshot likes,
  }) {
    return UserModel.fromJson({
      ...user.data(),
      ...{
        UserModel.ID: user.id,
        UserModel.LIST_FOLLOWINGS:
            followings != null ? followings.data() : Map<String, dynamic>(),
        UserModel.LIKES: likes != null
            ? likes.docs
                .map((doc) => doc.data()['postRef'] as DocumentReference)
                .toList()
            : List<DocumentReference>()
      }
    });
  }

  // Retourne le profile d'un utilisateur connecté sous forme de stream
  Stream<UserModel> get user {
    authProvider.user.listen((UserModel user) {
      if (user == null) {
        _currentUser.add(null);
        return;
      }

      firestore.collection('users').doc(user.id).snapshots().listen((userDoc) {
        userDoc.reference.collection('likes').snapshots().listen((likesDoc) {
          firestore
              .collection('followings')
              .doc(user.id)
              .snapshots()
              .listen((followingsDoc) {
            UserModel userModel = _convertToUserModel(
              userDoc,
              followings: followingsDoc,
              likes: likesDoc,
            );

            _currentUser.add(userModel);
          });
        });
      });
    });

    return _currentUser.stream;
  }

  // Retourne le public d'un utilisateur sous forme de stream
  Stream<UserModel> getProfile(String userId) {
    Stream<DocumentSnapshot> documentSnapshot =
        firestore.collection('users').doc(userId).snapshots();

    documentSnapshot.listen((doc) async {
      print(doc.data());

      _currentUserProfile.add(_convertToUserModel(doc));
    });

    return _currentUserProfile.stream;
  }

  Stream<bool> isFollowed(String profileUserId) {
    user.listen((UserModel user) {
      if (user == null) {
        isFollowedController.add(false);
        return;
      }

      final dynamic found = user.listFollowings.entries.firstWhere(
        (entry) => (entry.value as DocumentReference).id == profileUserId,
        orElse: () => null,
      );

      isFollowedController.add(found != null);
    });

    return isFollowedController.stream;
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

  // Permet de récupérer un post pour le feed
  Stream<List<PostModel>> getPost({
    int limit = 2,
    PostModel post,
  }) {
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
          (doc) => doc.docChanges.forEach(
            (post) {
              final dynamic data = post.doc.data();

              // TODO: Voir s'il n'es pas possible de stocker les requêtes
              data['userRef'].get().then((user) {
                // Est-ce que le post est déjà dans la liste
                final int index = _posts.indexWhere((p) => p.id == post.doc.id);

                // Si le résultat est négatif on ajout un post
                if (index == -1) {
                  _posts.add(_convertToPostModel(post.doc, user));
                } else if (post.type == DocumentChangeType.modified) {
                  _posts[index] = _convertToPostModel(post.doc, user);
                }

                _postsStream.add(_posts);
              });
            },
          ),
        );

    return _postsStream.stream;
  }

  // Permet de charger en lazy loading les posts d'un utilisateur
  Stream<List<PostModel>> getProfilePosts(String userId) {
    if (_profilePostModels.length >= Config.maxPostWhenUserIsNotAuthenticated &&
        !authProvider.isAuthenticated) return _profilePostsStream.stream;

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

    Stream<QuerySnapshot> postQuerySnapshot = postQuery.snapshots();

    // TODO: Peut-être que cette requête peut être appellée qu'une seule fois.
    Future<DocumentSnapshot> userDocumentSnapshot = documentReference.get();

    userDocumentSnapshot.then((user) {
      postQuerySnapshot.listen((post) {
        post.docChanges.forEach((docChange) {
          final int index =
              _profilePostModels.indexWhere((p) => p.id == docChange.doc.id);

          if (index == -1) {
            _profilePostModels.add(_convertToPostModel(docChange.doc, user));
          } else if (docChange.type == DocumentChangeType.modified) {
            _profilePostModels[index] =
                _convertToPostModel(docChange.doc, user);
          }
        });

        _profilePostsStream.add(_profilePostModels);
      });
    });

    return _profilePostsStream.stream;
  }
}
