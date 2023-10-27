import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:imiziappthemed/screens/meter_screen.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import './login_screen.dart';

class Property {
  final int propertyId;
  final String name;
  final String description;
  final String createDate;

  Property({
    required this.propertyId,
    required this.name,
    required this.description,
    required this.createDate,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      propertyId: json['propertyId'],
      name: json['name'],
      description: json['description'],
      createDate: json['createDate'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'name': name,
      'description': description,
      'createDate': createDate,
    };
  }

  factory Property.fromMap(Map<String, dynamic> map) {
    return Property(
      propertyId: map['propertyId'],
      name: map['name'],
      description: map['description'],
      createDate: map['createDate'],
    );
  }
}

class PropertyScreen extends StatefulWidget {
  final Login loginDetails;
  const PropertyScreen({Key? key, required this.loginDetails})
      : super(key: key);

  @override
  State<PropertyScreen> createState() => _PropertyScreenState();
}

class _PropertyScreenState extends State<PropertyScreen> {
  late Future<List<Property>> futureProperties;
  late Login _login;
  @override
  void initState() {
    super.initState();
    _login = widget.loginDetails;
    futureProperties = fetchProperties();
  }

  Future<List<Property>> fetchProperties() async {
    try {
      final response = await http.get(Uri.parse(
          'https://imiziapi.codeflux.co.za/api/Property/GetPropertyByUserId/${_login.userId}'));

      if (response.statusCode == 200) {
        bool tableExists = await doesPropertyTableExist();

        if (tableExists) {
          await deleteAllProperties();
          await insertPropertiesFromAPI(response.body);
        } else {
          await createPropertyTable();
          await insertPropertiesFromAPI(response.body);
        }

        List<Property> properties = await getPropertiesFromDB();
        properties.sort((a, b) => a.name.compareTo(b.name));
        return properties;
      } else {
        throw Exception('Failed Loading Properties from Live Database');
      }
    } catch (e) {
      // No internet connection
      bool tableExists = await doesPropertyTableExist();
      if (tableExists) {
        List<Property> properties = await getPropertiesFromDB();
        properties.sort((a, b) => a.name.compareTo(b.name));
        return properties;
      } else {
        throw Exception('${e.runtimeType}');
      }
    }
  }

  Future<void> createPropertyTable() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'property_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE properties(id INTEGER PRIMARY KEY, propertyId INTEGER, name TEXT, description TEXT, createDate TEXT)',
        );
      },
      version: 1,
    );
    await database.close();
  }

  Future<bool> doesPropertyTableExist() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'property_database.db'),
    );
    final tables = await database
        .query('sqlite_master', where: 'name = ?', whereArgs: ['properties']);
    await database.close();
    return tables.isNotEmpty;
  }

  Future<void> deleteAllProperties() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'property_database.db'),
    );
    await database.delete('properties');
    await database.close();
  }

  Future<void> insertPropertiesFromAPI(String responseBody) async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'property_database.db'),
    );
    final List<dynamic> jsonResponse = json.decode(responseBody);
    for (var property in jsonResponse) {
      await database.insert(
        'properties',
        Property.fromJson(property).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await database.close();
  }

  Future<List<Property>> getPropertiesFromDB() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'property_database.db'),
    );
    final List<Map<String, dynamic>> maps = await database.query('properties');
    await database.close();
    return List.generate(maps.length, (i) {
      return Property.fromMap(maps[i]);
    });
  }

  void navigateToMeterScreen(BuildContext context, Property property) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return MeterScreen(
            property: property,
            loginDetails: _login,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.centerLeft, // Align everything to the left
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align children to the left
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
                  'Select Property',
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
                height: 24.0,
              ),
              FutureBuilder<List<Property>>(
                future: futureProperties,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 166, 160, 55)),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('${snapshot.error}'));
                  } else {
                    List<Property> properties = snapshot.data!;

                    return Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.only(left: 48.0),
                        itemCount: properties.length,
                        itemBuilder: (context, index) {
                          Property property = properties[index];
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 190.0,
                                height: 40.0,
                                child: FxButton.medium(
                                  elevation: 1,
                                  borderRadiusAll: 0.0,
                                  backgroundColor:
                                      const Color.fromARGB(255, 166, 160, 55),
                                  onPressed: () {
                                    // Logic to Navigate to next screen
                                    navigateToMeterScreen(context, property);
                                  },
                                  child: Text(
                                    property.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16), // Double the font size
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(
                          height: 16.0,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
