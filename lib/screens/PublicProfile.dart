import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:xapp/Home.dart';
import 'package:xapp/models/PostModel.dart';
import 'package:xapp/models/UserModel.dart';
import 'package:xapp/providers/AuthProvider.dart';
import 'package:xapp/providers/FirestoreProvider.dart';
import 'package:xapp/providers/FunctionProvider.dart';
import 'package:xapp/screens/auth/Booking.dart';
import 'package:xapp/screens/auth/Login.dart';
import 'package:xapp/services/Translate.dart';
import 'package:xapp/transitions/FadeRouteTransition.dart';
import 'package:xapp/widget/FollowButton.dart';
import 'package:xapp/widget/Stat.dart';
import 'package:xapp/widget/ThumbPost.dart';
import 'package:xapp/widget/form/SecondaryButton.dart';

class PublicProfile extends StatefulWidget {
  final Function onBack;
  const PublicProfile({
    Key key,
    this.onBack,
  }) : super(key: key);

  @override
  _PublicProfileState createState() => _PublicProfileState();
}

class _PublicProfileState extends State<PublicProfile> {
  final ScrollController _scrollController = new ScrollController();
  AuthProvider _authProvider;
  FirestoreProvider _firestoreProvider;
  FunctionProvider _functionProvider;

  bool _loading = false;
  bool _reload = false;

  UserModel _user;
  //  = UserModel(
  //   id: "7Bu8TQsvGTSvIUnGKsXMXI3qvgmx",
  //   displayName: "Jess e",
  //   slug: "jess-e",
  //   status: "Coucou mon petit",
  //   followers: 2,
  //   followings: 3,
  //   photoURL:
  //       "https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
  // );

  @override
  void initState() {
    super.initState();

    // Permet de charger les donner lorsque le scroll est au plus bas
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = 50.0;

      if (maxScroll - currentScroll <= delta && !_reload) {
        print('load next posts...');
        setState(() => _reload = true);

        _firestoreProvider.getProfilePosts(_user.id);
      }
    });

    // Chargement des providers
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _functionProvider = Provider.of<FunctionProvider>(context, listen: false);
    _firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);

    // Chargement des données de l'utilisateur dès que la vue s'affiche
    setState(() => _user = _firestoreProvider.currentPost.user);

    _firestoreProvider.getProfile(_user.id).listen((user) {
      if (mounted) {
        setState(() => _user = user);
      }
    });

    _firestoreProvider.getProfilePosts(_user.id);
  }

  @override
  void dispose() {
    _firestoreProvider.cleanProfilePosts();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => widget.onBack(),
      child: Scaffold(
        body: NestedScrollView(
          controller: _scrollController,
          floatHeaderSlivers: true,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: Row(
                  children: [
                    IconButton(
                      onPressed: widget.onBack,
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                floating: true,
                actions: <Widget>[
                  Visibility(
                    visible: _authProvider.isAuthenticated,
                    child: IconButton(
                      icon: Icon(
                        Icons.logout,
                        color: Colors.black,
                      ),
                      onPressed: () async {
                        await _authProvider.logout();

                        Navigator.pushAndRemoveUntil(
                          context,
                          FadeRouteTransition(
                            page: Home(),
                          ),
                          (_) => false,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ];
          },
          body: ListView(
            physics: BouncingScrollPhysics(),
            padding: const EdgeInsets.all(0),
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      Hero(
                        tag: _user.id,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(_user.photoURL),
                          radius: 70,
                        ),
                      ),
                      Text(
                        _user.displayName,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                        ),
                        child: Text(
                          (_user.status ?? ''),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Stat(
                              label: t(context).followers.toUpperCase(),
                              number: _user.followers,
                              align: Stat.LEFT,
                            ),
                            Stat(
                              label: t(context).followings.toUpperCase(),
                              number: _user.followings,
                              align: Stat.RIGHT,
                            ),
                          ],
                        ),
                      ),
                      FollowButton(
                        functionProvider: _functionProvider,
                        firestoreProvider: _firestoreProvider,
                        profileUserId: _user.id,
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      Visibility(
                        visible: _loading,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 70.0,
                          ),
                          child: SpinKitThreeBounce(
                            color: Colors.black,
                            size: 15.0,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: !_loading,
                        child: StreamBuilder(
                          stream: _firestoreProvider.profilPosts,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                ConnectionState.active) {
                              return SpinKitThreeBounce(
                                color: Colors.black,
                                size: 15.0,
                              );
                            }

                            return GridView(
                              padding: const EdgeInsets.all(0),
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 2,
                                mainAxisSpacing: 2,
                                childAspectRatio: .7,
                              ),
                              children: snapshot.data
                                  .map<Widget>(
                                    (PostModel post) => ThumbPost(
                                      authProvider: _authProvider,
                                      firestoreProvider: _firestoreProvider,
                                      functionProvider: _functionProvider,
                                      post: post,
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        ),
                      ),
                      Visibility(
                        visible: !_authProvider.isAuthenticated && !_loading,
                        child: Positioned(
                          top: 0,
                          left: 0,
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50.0,
                              vertical: 50.0,
                            ),
                            color: Colors.black.withOpacity(.3),
                            child: Center(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 15.0,
                                    ),
                                    child: Text(
                                      "Pour accéder au contenu de ${_user.displayName}, veuillez vous connecter.",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                            height: 1.4,
                                            fontSize: 16.0,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 50.0,
                                    width: 200.0,
                                    child: SecondaryButton(
                                      label: t(context).connectMeButton,
                                      onPressed: () => Navigator.push(
                                        context,
                                        FadeRouteTransition(
                                          page: Login(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  MaterialButton(
                                    child: Text(
                                      t(context).createAccountBtn,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.white,
                                          ),
                                    ),
                                    onPressed: () => Navigator.push(
                                      context,
                                      FadeRouteTransition(
                                        page: Booking(
                                          firestoreProvider: _firestoreProvider,
                                          functionProvider: _functionProvider,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
