import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xapp/models/User.dart';
import 'package:xapp/providers/FirestoreProvider.dart';
import 'package:xapp/widget/Stat.dart';

class PublicProfile extends StatefulWidget {
  const PublicProfile({Key key}) : super(key: key);

  @override
  _PublicProfileState createState() => _PublicProfileState();
}

class _PublicProfileState extends State<PublicProfile> {
  FirestoreProvider _firestoreProvider;

  User _user;

  @override
  void initState() {
    super.initState();

    _firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);

    setState(() => _user = _firestoreProvider.currentPost.user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10.0,
                  ),
                  child: Hero(
                    tag: _user.id,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(_user.photoURL),
                      radius: 70,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                  ),
                  child: Text(
                    _user.displayName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline3,
                  ),
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
                        label: 'Followers',
                        number: _user.followers,
                        align: Stat.LEFT,
                      ),
                      Stat(
                        label: 'Followings',
                        number: _user.followings,
                        align: Stat.RIGHT,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 50.0,
                  ),
                  child: SizedBox(
                    height: 45.0,
                    width: MediaQuery.of(context).size.width,
                    child: RaisedButton(
                      onPressed: () => print('Follow'),
                      child: Text('Follow'.toUpperCase()),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
