import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:flutter/cupertino.dart';
import 'package:imiziappthemed/screens/property_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Login {
  final int userId;

  Login({required this.userId});

  Login.fromJson(Map<String, dynamic> json) : userId = json['userId'] as int;
  Map<String, dynamic> toJson() => {'userId': userId};
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _passwordVisible = false;
  TextEditingController userName = TextEditingController();
  TextEditingController password = TextEditingController();
  bool nextScreen = false;

  Future<void> login(BuildContext context) async {
    String url = "https://imiziapi.codeflux.co.za/api/User/login";
    Map<String, String> jsonResponse = {
      'userName': userName.text,
      'password': password.text,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(jsonResponse),
      );

      if (response.statusCode == 200) {
        final loginMap = jsonDecode(response.body) as Map<String, dynamic>;
        Login loggedUser = Login.fromJson(loginMap);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PropertyScreen(
              loginDetails: loggedUser,
            ),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.only(left: 48.0, top: 16.0, bottom: 16.0),
                child: Image.asset(
                  'assets/images/imiziLogo.jpg',
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 48.0),
                child: SizedBox(
                  height: 24,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 48.0),
                child: Text(
                  'Login',
                  style: TextStyle(
                      color: Color.fromARGB(255, 166, 160, 55),
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 48.0),
                child: SizedBox(
                  height: 24,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 48.0, right: 16.0),
                child: Divider(
                  height: 6.0,
                  color: Color.fromARGB(255, 150, 137, 28),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              const SizedBox(
                height: 120.0,
              ),
              Container(
                padding:
                    const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 380.0,
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: CupertinoTextField(
                          controller: userName,
                          decoration: BoxDecoration(
                              color: theme.colorScheme.background,
                              border: Border.all(color: Colors.black)),
                          cursorColor: theme.colorScheme.primary,
                          placeholder: "Username",
                          prefix: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(
                              MdiIcons.contactsOutline,
                              color: Colors.grey,
                            ),
                          ),
                          style:
                              TextStyle(color: theme.colorScheme.onBackground),
                          padding: const EdgeInsets.only(
                              top: 16, bottom: 16, left: 16, right: 8),
                          placeholderStyle: TextStyle(
                              color: theme.colorScheme.onBackground
                                  .withAlpha(160)),
                        ),
                      ),
                      const SizedBox(
                        height: 24.0,
                      ),
                      Container(
                        width: 380.0,
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: CupertinoTextField(
                          controller: password,
                          obscureText: _passwordVisible,
                          decoration: BoxDecoration(
                              color: theme.colorScheme.background,
                              border: Border.all(color: Colors.black)),
                          cursorColor: theme.colorScheme.primary,
                          placeholder: "Password",
                          prefix: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(
                              MdiIcons.lockOutline,
                              color: Colors.grey,
                            ),
                          ),
                          suffix: GestureDetector(
                            onTap: () {
                              setState(() {
                                _passwordVisible = _passwordVisible;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                _passwordVisible
                                    ? MdiIcons.eyeOutline
                                    : MdiIcons.eyeOffOutline,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          placeholderStyle: TextStyle(
                              color: theme.colorScheme.onBackground
                                  .withAlpha(160)),
                          style:
                              TextStyle(color: theme.colorScheme.onBackground),
                          padding: const EdgeInsets.only(
                              top: 16, bottom: 16, left: 16, right: 8),
                        ),
                      ),
                      const SizedBox(
                        height: 24.0,
                      ),
                      Container(
                        width: 380.0,
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: FxButton.large(
                          elevation: 1,
                          borderRadiusAll: 0.0,
                          backgroundColor:
                              const Color.fromARGB(255, 166, 160, 55),
                          onPressed: () async {
                            await login(context);
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16), // Double the font size
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
