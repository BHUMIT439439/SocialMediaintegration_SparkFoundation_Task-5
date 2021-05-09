import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedInWithGoogle = false;
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

//*********************  login and logout function for Google   ********************/
  _loginWithGoogle() async {
    try {
      await _googleSignIn.signIn();
      setState(() {
        _isLoggedInWithGoogle = true;
      });
    } catch (err) {
      print(err);
    }
  }

  _logoutWithGoogle() async {
    _googleSignIn.signOut();
    setState(() {
      _isLoggedInWithGoogle = false;
    });
  }

  //**************** End function for google **********************************/

  //***************** login and logout function for facebook ******************************/

  bool _isLoggedInWithFacebook = false;

  Map userFacebookProfile;

  final facebookLogin = FacebookLogin();

  _loginWithFacebook() async {
    final result = await facebookLogin.logIn(['email']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get(Uri.parse(
            'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=$token'));
        final profile = JSON.jsonDecode(graphResponse.body);
        print(profile);
        setState(() {
          userFacebookProfile = profile;
          _isLoggedInWithFacebook = true;
        });
        break;

      case FacebookLoginStatus.cancelledByUser:
        setState(() => _isLoggedInWithFacebook = false);
        break;

      case FacebookLoginStatus.error:
        setState(() => _isLoggedInWithFacebook = false);
        break;
    }
  }

  _logoutWithFacebook() {
    facebookLogin.logOut();
    setState(() {
      _isLoggedInWithFacebook = false;
    });
  }

//************************* End function for facebook ************************/

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Social Media Integration'),
          centerTitle: true,
        ),
        body: Center(
          //******** if login within google ************/
          child: _isLoggedInWithGoogle
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.network(
                      _googleSignIn.currentUser.photoUrl,
                      height: 80.0,
                      width: 80.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                      child: Text(
                        _googleSignIn.currentUser.displayName,
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                    Text(
                      _googleSignIn.currentUser.email,
                      style: TextStyle(fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                      child: OutlineButton(
                          child: Text("Logout"),
                          onPressed: () {
                            _logoutWithGoogle();
                          }),
                    ),
                  ],
                )
              //******** if login within facebook ************/
              : _isLoggedInWithFacebook
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.network(
                            userFacebookProfile["picture"]["data"]["url"],
                            height: 50.0,
                            width: 50.0),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                          child: Text(userFacebookProfile['name']),
                        ),
                        Text(userFacebookProfile['email']),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                          child: OutlineButton(
                              child: Text("Logout"),
                              onPressed: () {
                                _logoutWithFacebook();
                              }),
                        ),
                      ],
                    )
                  //********* not loggedin within google or facebook*************/
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: new Container(
                                margin:
                                    EdgeInsets.fromLTRB(30.0, 5.0, 30.0, 5.0),
                                child: new RaisedButton(
                                  color: const Color(0xFF4285F4),
                                  shape: Border(),
                                  onPressed: () {
                                    _loginWithGoogle();
                                  },
                                  child: new Row(
                                    children: <Widget>[
                                      new Image.asset(
                                        'assets/images/google_logo.png',
                                        height: 48.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            30.0, 0.0, 0.0, 0.0),
                                        child: Text(
                                          'Sign in with Google',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
                              child: Text(
                                "OR",
                                style: TextStyle(fontSize: 25.0),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: new Container(
                                margin:
                                    EdgeInsets.fromLTRB(30.0, 5.0, 30.0, 5.0),
                                child: new RaisedButton(
                                  color: const Color(0xFF4285F4),
                                  shape: Border(),
                                  onPressed: () {
                                    _loginWithFacebook();
                                  },
                                  child: new Row(
                                    children: <Widget>[
                                      new Image.asset(
                                        'assets/images/facebook_logo.png',
                                        height: 48.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10.0, 0.0, 0.0, 0.0),
                                        child: Text(
                                          'Sign in with Facebook',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
