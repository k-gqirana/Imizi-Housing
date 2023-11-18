import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:flutter/cupertino.dart';
import 'package:imiziappthemed/screens/property_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Login {
  final int userId;

  Login({required this.userId});

  Login.fromJson(Map<String, dynamic> json) : userId = json['userId'] as int;
  Map<String, dynamic> toJson() => {'userId': userId};
}

class Users {
  final int userId;
  final String userName;
  final String password;

  Users({required this.userId, required this.userName, required this.password});

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'password': password,
    };
  }

  Map<String, dynamic> toUserId() {
    return {'userId': userId};
  }

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      userId: json['userId'],
      userName: json['userName'],
      password: json['password'],
    );
  }
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
    late Future<List<Users>> futureUsers;

  @override
  void initState() {
    super.initState();
    futureUsers = fetchUsers();
  }

    Future<List<Users>> fetchUsers() async {
    try {
      final response =
          await http.get(Uri.parse('https://imiziapi.codeflux.co.za/api/User'));
      if (response.statusCode == 200) {
        bool tableExists = await doesUsersTableExist();

        if (tableExists) {
          await deleteAllUsers();
          await insertUsersFromAPI(response.body);
        } else {
          await createUsersTable();
          await insertUsersFromAPI(response.body);
        }

        List<Users> users = await getUsersFromDB();

        return users;
      } else {
        throw Exception(
            'Could not get users, response code: ${response.statusCode}');
      }
    } on SocketException {
      bool tableExitst = await doesUsersTableExist();
      if (tableExitst) {
        List<Users> users = await getUsersFromDB();
        return users;
      } else {
        throw Exception('Users Table does not exist');
      }
    } catch (e) {
      throw Exception('Could not log in $e');
    }
  }

  Future<void> createUsersTable() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'user_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users(id INTEGER  PRIMARY KEY, userId INTEGER, userName TEXT, password TEXT)',
        );
      },
      version: 1,
    );
    await database.close();
  }

  Future<bool> doesUsersTableExist() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'user_database.db'),
    );
    final tables = await database
        .query('sqlite_master', where: 'name = ?', whereArgs: ['users']);
    await database.close();
    return tables.isNotEmpty;
  }

  Future<void> deleteAllUsers() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'user_database.db'),
    );
    await database.delete('users');
    await database.close();
  }

  Future<void> insertUsersFromAPI(String responseBody) async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'user_database.db'),
    );
    final List<dynamic> jsonResponse = json.decode(responseBody);
    for (var block in jsonResponse) {
      await database.insert(
        'users',
        Users.fromJson(block).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await database.close();
  }

  Future<List<Users>> getUsersFromDB() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'user_database.db'),
    );
    final List<Map<String, dynamic>> maps = await database.query('users');
    await database.close();
    return List.generate(maps.length, (i) {
      return Users.fromJson(maps[i]);
    });
  }

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
    } on SocketException {
      bool tableExists = await doesUsersTableExist();
      if (tableExists) {
        bool isUser = false;
        List<Users> users = await getUsersFromDB();
        for (var i = 0; i < users.length; i++) {
          Users user = users[i];
          print(user.password);
          if (user.userName == userName.text &&
              user.password == password.text) {
            isUser = true;
            Login loggedUser = Login.fromJson(user.toUserId());
            print(loggedUser);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => PropertyScreen(
                  loginDetails: loggedUser,
                ),
              ),
            );
          }
        }
        if (!isUser) {
          throw Exception('Incorrect Login Details');
        }
      } else {
        throw Exception('Users Table does not exist');
      }
    } catch (e) {
      throw Exception('Could not login, $e');
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
                    const EdgeInsets.only(left: 48.0, top: 46.0, bottom: 16.0),
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
                          enableSuggestions: false,
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
                          enableSuggestions: false,
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
                                _passwordVisible = !_passwordVisible;
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
