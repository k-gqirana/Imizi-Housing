import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:flutter/cupertino.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _passwordVisible = false;

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
                          decoration: BoxDecoration(
                              color: theme.colorScheme.background,
                              border:
                                  Border.all(color: theme.colorScheme.primary)),
                          cursorColor: theme.colorScheme.primary,
                          placeholder: "Username",
                          prefix: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(
                              MdiIcons.contactsOutline,
                              color: theme.colorScheme.primary,
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
                          obscureText: _passwordVisible,
                          decoration: BoxDecoration(
                              color: theme.colorScheme.background,
                              border:
                                  Border.all(color: theme.colorScheme.primary)),
                          cursorColor: theme.colorScheme.primary,
                          placeholder: "Password",
                          prefix: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(
                              MdiIcons.lockOutline,
                              color: theme.colorScheme.primary,
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
                                color: theme.colorScheme.primary,
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
