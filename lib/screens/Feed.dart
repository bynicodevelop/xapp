import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xapp/Config.dart';
import 'package:xapp/providers/AuthProvider.dart';
import 'package:xapp/providers/FirestoreProvider.dart';
import 'package:xapp/providers/FunctionProvider.dart';
import 'package:xapp/widget/FeedPost.dart';

class Feed extends StatefulWidget {
  final Function goToProfile;

  const Feed({
    Key key,
    this.goToProfile,
  }) : super(key: key);

  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  PageController _pageController;

  FirestoreProvider _firestoreProvider;
  AuthProvider _authProvider;
  FunctionProvider _functionProvider;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);
    _functionProvider = Provider.of<FunctionProvider>(context, listen: false);

    // TODO: Trouver une solution pour retrouner sur le bon index en fonction des données déjà chargées
    _pageController = PageController(initialPage: 0);

    // Charge 2 images par default
    _firestoreProvider.getPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: StreamBuilder(
        stream: _firestoreProvider.posts,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return SizedBox.shrink();
          }

          if (_currentIndex == 0) {
            _firestoreProvider.currentPost = snapshot.data[_currentIndex];
          }

          List<Widget> widgets = snapshot.data
              .asMap()
              .entries
              .map<Widget>(
                (entry) => FeedPost(
                  onProfilePressed: () {
                    widget.goToProfile();
                    _firestoreProvider.currentPost = entry.value;
                  },
                  authProvider: _authProvider,
                  firestoreProvider: _firestoreProvider,
                  functionProvider: _functionProvider,
                  post: entry.value,
                  isLast: entry.key == Config.maxPostWhenUserIsNotAuthenticated,
                ),
              )
              .toList();

          return PageView(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              if (_currentIndex > index) {
                print('Go to back...');
                setState(() => _currentIndex = index);
                return;
              }

              // Si l'utilisateur n'est pas connecté, alors on le block à X vue de photos
              if (!_authProvider.isAuthenticated &&
                  widgets.length > Config.maxPostWhenUserIsNotAuthenticated)
                return;

              setState(() => _currentIndex = index);

              _firestoreProvider.currentPost = snapshot.data[_currentIndex];

              if (snapshot.data.length - 1 == index) {
                print('Load new post...');
                _firestoreProvider.getPost(
                  limit: 1,
                  post: snapshot.data[index],
                );
              }
            },
            children: widgets,
          );
        },
      ),
    );
  }
}
