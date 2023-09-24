import 'dart:convert';
import 'package:flutter/material.dart';
import '../widgets/blocks.dart';
import '../screens/property_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutx/flutx.dart';
import 'package:flutter/cupertino.dart';

// Lists just to see View, will set Data up to extract info for each block
final List<String> uni = ['Unit 1', 'Unit 2', 'Unit 3', 'Unit 4'];
final List<String> meters = ['Meter 1', 'Meter 2', 'Meter 3', 'Meter 4'];
final List<int> previous = [456, 456, 456, 456];
final List<int> average = [420, 420, 420, 420];

//Data Model for Blocks associated with each property
class Blocks {
  final int blockId;
  final int propertyId;
  final String blockNumber;
  final bool blockAcitve;
  final String propertyName;
  final bool propertyActive;
  final String description;

  Blocks(
      {required this.blockId,
      required this.propertyId,
      required this.blockNumber,
      required this.blockAcitve,
      required this.propertyName,
      required this.propertyActive,
      required this.description});

  factory Blocks.fromJson(Map<String, dynamic> json) {
    return Blocks(
        blockId: json['blockId'],
        propertyId: json['propertyId'],
        blockNumber: json['blockNumber'],
        blockAcitve: json['blockActive'],
        propertyName: json['propertyName'],
        propertyActive: json['propertyActive'],
        description: json['description']);
  }
}

// Data Model for List of units
class Units {
  final int unitId;
  final int blockId;
  final int unitNumber;
  final int propertyId;
  final int payPropUnitId;
  final String createDate;
  final bool active;

  Units(
      {required this.unitId,
      required this.blockId,
      required this.unitNumber,
      required this.propertyId,
      required this.payPropUnitId,
      required this.createDate,
      required this.active});

  factory Units.fromJson(Map<String, dynamic> json) {
    return Units(
        unitId: json['unitId'],
        blockId: json['blockId'],
        unitNumber: json['unitNumber'],
        propertyId: json['propertyId'],
        payPropUnitId: json['payPropUnitId'],
        createDate: json['createDate'],
        active: json['active']);
  }
}

class MeterScreen extends StatefulWidget {
  final Property property;
  const MeterScreen({Key? key, required this.property}) : super(key: key);

  @override
  State<MeterScreen> createState() => _MeterScreenState();
}

class _MeterScreenState extends State<MeterScreen> {
  late Property _prop;
  late Future<List<Blocks>> futureBlocks;
  late Future<List<Units>> futureUnits;
  Blocks? selectedBlock; // Define selectedBlock as nullable
  int? selectedBlockID; // To fetch the units of the selected block

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _prop = widget.property;
    // When screen loads, get the blocks for the current Property
    futureBlocks = fetchBlocks();
    // Initialize selectedBlock with the first item in blocks when available
    futureBlocks.then((blocks) {
      if (blocks.isNotEmpty) {
        setState(() {
          selectedBlock = blocks.first;

          selectedBlockID = selectedBlock?.blockId;
          // call method to fetch units when block is clicked
          futureUnits = fetchUnits();
        });
      }
    });
    futureUnits = fetchUnits();
  }

  // Fetching the blocks from the API endpoint
  Future<List<Blocks>> fetchBlocks() async {
    final response = await http.get(Uri.parse(
        'https://imiziapi.codeflux.co.za/api/Block/GetFilteredBlocks/${_prop.propertyId}'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      List<Blocks> blocks =
          jsonResponse.map((block) => Blocks.fromJson(block)).toList();

      //sort the blocks in ascending order of blockNumber
      blocks.sort((a, b) => a.blockNumber.compareTo(b.blockNumber));
      return blocks;
    } else {
      throw Exception('Could not get list of blocks within ${_prop.name}');
    }
  }

  //Bring List of Units when a block is pressed
  Future<List<Units>> fetchUnits() async {
    final Map<String, dynamic> queryParams = {};

    if (selectedBlockID != null) {
      queryParams['BlockId'] = 1; // Include BlockId if it's not null
    }

    final uri =
        Uri.https('imiziapi.codeflux.co.za', 'api/Unit/Search', queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      print(jsonResponse);
      List<Units> units =
          jsonResponse.map((unit) => Units.fromJson(unit)).toList();

      // Sorting the units based on Unit Number
      units.sort((a, b) => a.unitNumber.compareTo(b.unitNumber));
      print(units);
      return units;
    } else {
      throw Exception(
          'Could not get the List of Units from the selected Block');
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
                padding: const EdgeInsets.only(
                    left: 48.0, top: 16.0, bottom: 16.0, right: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Property Name: ${_prop.name}',
                      style: const TextStyle(
                          fontSize: 20.0,
                          color: Color.fromARGB(255, 166, 160, 55),
                          fontWeight: FontWeight.bold),
                    ),
                    FutureBuilder<List<Blocks>>(
                        future: futureBlocks,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                  color: Color.fromARGB(255, 166, 160, 55)),
                            );
                          } else if (snapshot.hasError) {
                            return Center(child: Text('${snapshot.error}'));
                          } else {
                            // Build Blocks Widget Here
                            List<Blocks> blocks = snapshot.data!;
                            List<DropdownMenuItem<Blocks>> items = blocks
                                .map(
                                  (block) => DropdownMenuItem<Blocks>(
                                    value: block,
                                    child: Text(block.blockNumber),
                                  ),
                                )
                                .toList();

                            return DropdownButton<Blocks>(
                              items: items,
                              onChanged: (selectedBlock) {
                                setState(() {
                                  this.selectedBlock = selectedBlock;
                                  selectedBlockID = selectedBlock
                                      ?.blockId; // BlockId to be able to select units

                                  // call method to fetch units when block is clicked
                                });
                              },
                              value: selectedBlock, // Set initial value
                            );
                          }
                        }),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(
                    left: 48.0, top: 16.0, bottom: 6.0, right: 28.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Unit',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Meter',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Reading',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Previous',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Average',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 44.0, bottom: 0.5, right: 24.0),
                child: Divider(
                  height: 6,
                  color: Colors.black,
                  thickness: 1.5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 31.0, top: 16.0, bottom: 6.0, right: 18.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.7,
                  color: Colors.purple,
                  // Add code here:
                  child: SingleChildScrollView(
                    child: Wrap(direction: Axis.horizontal, children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8 / 5,
                        height: MediaQuery.of(context).size.height,
                        color: Colors.blue,
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height,
                              child: FutureBuilder<List<Units>>(
                                future: futureUnits,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                          color: Color.fromARGB(
                                              255, 166, 160, 55)),
                                    );
                                  } else if (snapshot.hasError) {
                                    print(snapshot.error);
                                    return Center(
                                        child: Text('${snapshot.error}'));
                                  } else {
                                    List<Units> units = snapshot.data!;

                                    return ListView.separated(
                                        padding: const EdgeInsets.all(2.0),
                                        itemBuilder:
                                            (BuildContext context, index) {
                                          Units unit = units[index];
                                          print(unit.unitNumber);
                                          return Text(
                                              'Unit ${unit.unitNumber}');
                                        },
                                        separatorBuilder:
                                            (BuildContext context, int index) =>
                                                const SizedBox(height: 8.0),
                                        itemCount: units.length);
                                  }
                                },
                              ),
                              //ListView.separated(
                              //     padding: const EdgeInsets.all(2.0),
                              //     itemBuilder:
                              //         (BuildContext context, int index) {
                              //       return Text(uni[index]);
                              //     },
                              //     separatorBuilder:
                              //         (BuildContext context, int index) =>
                              //             const SizedBox(
                              //               height: 8.0,
                              //             ),
                              //     itemCount: uni.length),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8 / 5,
                        height: 40,
                        color: Colors.amber,
                      ),
                      Container(
                        width: ((MediaQuery.of(context).size.width) +
                                (MediaQuery.of(context).size.width) * 0.4) /
                            5,
                        height: 40,
                        color: Colors.green,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8 / 5,
                        height: 40,
                        color: Colors.orange,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8 / 5,
                        height: 40,
                        color: Colors.red,
                      ),
                    ]),
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

//  ListView.separated(
//                                   padding: const EdgeInsets.all(2.0),
//                                   itemBuilder:
//                                       (BuildContext context, int index) {
//                                     return Text('$meters[index]');
//                                   },
//                                   separatorBuilder:
//                                       (BuildContext context, int index) =>
//                                           const SizedBox(
//                                             height: 8.0,
//                                           ),
//                                   itemCount: meters.length),
//                           ListView.separated(
//                               padding: const EdgeInsets.all(2.0),
//                               itemBuilder: (BuildContext context, int index) {
//                                 return Container(
//                                   child: CupertinoTextField(
//                                     decoration: BoxDecoration(
//                                         color: theme.colorScheme.background,
//                                         border:
//                                             Border.all(color: Colors.black)),
//                                     cursorColor: theme.colorScheme.primary,
//                                     placeholder: "Enter Meter Reading",
//                                     style: TextStyle(
//                                         color: theme.colorScheme.onBackground),
//                                     padding: const EdgeInsets.only(
//                                         top: 8, bottom: 8, left: 8, right: 4),
//                                     placeholderStyle: TextStyle(
//                                         color: theme.colorScheme.onBackground
//                                             .withAlpha(160)),
//                                   ),
//                                 );
//                               },
//                               separatorBuilder:
//                                   (BuildContext context, int index) =>
//                                       const SizedBox(
//                                         height: 8.0,
//                                       ),
//                               itemCount: meters.length),
//                           ListView.separated(
//                               padding: const EdgeInsets.all(2.0),
//                               itemBuilder: (BuildContext context, int index) {
//                                 return Text('$previous[index]');
//                               },
//                               separatorBuilder:
//                                   (BuildContext context, int index) =>
//                                       const SizedBox(
//                                         height: 8.0,
//                                       ),
//                               itemCount: previous.length),
//                           ListView.separated(
//                               padding: const EdgeInsets.all(2.0),
//                               itemBuilder: (BuildContext context, int index) {
//                                 return Text('$average[index]');
//                               },
//                               separatorBuilder:
//                                   (BuildContext context, int index) =>
//                                       const SizedBox(
//                                         height: 8.0,
//                                       ),
//                               itemCount: average.length),
