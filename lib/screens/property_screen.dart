import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:imiziappthemed/screens/meter_screen.dart';
import 'package:http/http.dart' as http;

// Class for the Data Model
//check if we need propertyImage and imageFile attrributes
class Property {
  final int propertyId;
  final String name;
  final String description;
  final String createDate;
  final bool active;

  Property(
      {required this.propertyId,
      required this.name,
      required this.description,
      required this.createDate,
      required this.active});

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
        propertyId: json['propertyId'],
        name: json['name'],
        description: json['description'],
        createDate: json['createDate'],
        active: json['active']);
  }
}

class PropertyScreen extends StatefulWidget {
  const PropertyScreen({Key? key}) : super(key: key);

  @override
  State<PropertyScreen> createState() => _PropertyScreenState();
}

class _PropertyScreenState extends State<PropertyScreen> {
  late Future<List<Property>> futureProperties;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //When Sccreen loads get the Properties
    futureProperties = fetchProperties();
  }

  // Method to get Properties from API endpoint
  Future<List<Property>> fetchProperties() async {
    final response = await http
        .get(Uri.parse('https://imiziapi.codeflux.co.za/api/Property/'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      List<Property> properties =
          jsonResponse.map((property) => Property.fromJson(property)).toList();

      // Sorting the List of Properties by name
      properties.sort((a, b) => a.name.compareTo(b.name));
      return properties;
    } else {
      throw Exception('Failed Loading Properties');
    }
  }

  // Handling Navigation to the next screen
  void navigateToMeterScreen(BuildContext context, Property property) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return MeterScreen(property: property);
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
