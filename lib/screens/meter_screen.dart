import 'dart:convert';
import 'package:flutter/material.dart';
import '../screens/property_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutx/flutx.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

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
  final String payPropUnitId;
  final String createDate;
  final bool active;
  final String blockNumber;
  final String blockDescription;
  final String name;

  Units({
    required this.unitId,
    required this.blockId,
    required this.unitNumber,
    required this.propertyId,
    required this.payPropUnitId,
    required this.createDate,
    required this.active,
    required this.blockNumber,
    required this.blockDescription,
    required this.name,
  });

  factory Units.fromJson(Map<String, dynamic> json) {
    return Units(
        unitId: json['unitId'],
        blockId: json['blockId'],
        unitNumber: json['unitNumber'],
        propertyId: json['propertyId'],
        payPropUnitId: json['payPropUnitId'],
        createDate: json['createDate'],
        active: json['active'],
        blockNumber: json['blockNumber'],
        blockDescription: json['blockDescription'],
        name: json['name']);
  }
}

// Data Model for Meters
class Meters {
  final int meterId;
  final int unitId;
  final String meterNumber;
  final String createDate;
  final bool active;
  final String meterType;
  final int blockId;
  final int propertyId;

  Meters(
      {required this.meterId,
      required this.unitId,
      required this.meterNumber,
      required this.createDate,
      required this.active,
      required this.meterType,
      required this.blockId,
      required this.propertyId});

  factory Meters.fromJson(Map<String, dynamic> json) {
    return Meters(
        meterId: json['meterId'],
        unitId: json['unitId'],
        meterNumber: json['meterNumber'],
        createDate: json['createDate'],
        active: json['active'],
        meterType: json['meterType'],
        blockId: json['blockId'],
        propertyId: json['propertyId']);
  }
}

// Getting Everything for the MeterScreen
// Required params for enpoint are: year, month, selectedBlockId
class MeterReading {
  final int propertyId;
  final String name;
  final int blockId;
  final String blockNumber;
  final int unitId;
  final int meterId;
  final String meterNumber;
  final int reading;
  final int previous;
  final int unitNumber;
  final int average;
  final int month;
  final int year;

  MeterReading(
      {required this.propertyId,
      required this.name,
      required this.blockId,
      required this.blockNumber,
      required this.unitId,
      required this.meterId,
      required this.meterNumber,
      required this.reading,
      required this.previous,
      required this.unitNumber,
      required this.average,
      required this.month,
      required this.year});

  factory MeterReading.fromJson(Map<String, dynamic> json) {
    return MeterReading(
        propertyId: json['propertyId'],
        name: json['name'],
        blockId: json['blockId'],
        blockNumber: json['blockNumber'],
        unitId: json['unitId'],
        meterId: json['meterId'],
        meterNumber: json['meterNumber'],
        reading: json['reading'],
        previous: json['previous'],
        unitNumber: json['unitNumber'],
        average: json['average'],
        month: json['month'],
        year: json['year']);
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
  late Future<List<Meters>> futureMeters;
  late Future<List<MeterReading>> futureMeterReading;
  // late Future<List<dynamic>> fetch;
  Blocks? selectedBlock; // Define selectedBlock as nullable
  late int selectedBlockID; // To fetch the units of the selected block

  //Scroll Controller
  final ScrollController _firstController = ScrollController();

  //Using DIO package to get units
  final dio = Dio();

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
          selectedBlockID = selectedBlock!.blockId;
          // call method to fetch units when block is clicked
          futureUnits = fetchUnits();
          futureMeterReading = fetchMeterReading();

          // fetch = request();
        });
      }
    });
    // fetch = request();
    futureMeters = fetchMeters();
    futureUnits = fetchUnits();
    futureMeterReading = fetchMeterReading();
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

  //Trying Units another way

  // Future<List<dynamic>> request() async {
  //   var options = Options();
  //   options.contentType = 'application/json';
  //   String url = 'https://imiziapi.codeflux.co.za/api/Unit/UnitFilter';
  //   Map<String, int> qParams = {
  //     'blockId': selectedBlockID,
  //     'propertyId': _prop.propertyId
  //   };
  //   Response response =
  //       await dio.get(url, options: options, queryParameters: qParams);

  //   print(response.data);

  //   if (response.statusCode == 200) {
  //     List<dynamic> data = response.data;
  //     return data;
  //   } else {
  //     throw Exception(
  //         'Could not get the List of Units from the selected Block');
  //   }
  // }

  //Bring List of Units when a block is pressed
  Future<List<Units>> fetchUnits() async {
    var options = Options();
    options.contentType = 'application/json';
    String url = 'https://imiziapi.codeflux.co.za/api/Unit/UnitFilter';
    Map<String, int> qParams = {
      'blockId': selectedBlockID,
      'propertyId': _prop.propertyId
    };
    Response response =
        await dio.get(url, options: options, queryParameters: qParams);
    if (response.statusCode == 200) {
      // Fix decoding here
      List<dynamic> jsonResponse = response.data;
      List<Units> units =
          jsonResponse.map((unit) => Units.fromJson(unit)).toList();

      // Sorting the units based on Unit Number
      units.sort((a, b) => a.unitNumber.compareTo(b.unitNumber));
      return units;
    } else {
      throw Exception(
          'Could not get the List of Units from the selected Block');
    }
  }

  // Fetching Meters for Units
  Future<List<Meters>> fetchMeters() async {
    final response =
        await http.get(Uri.parse('https://imiziapi.codeflux.co.za/api/Meter'));
    // pass {propertyId}/{blockId}/{unitId} to get specific Meters

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      print(jsonResponse);
      List<Meters> meters =
          jsonResponse.map((unit) => Meters.fromJson(unit)).toList();
      // Find a way to sort Meters by Unit Number
      return meters;
    } else {
      throw Exception('Could not get List of Meters');
    }
  }

  Future<List<MeterReading>> fetchMeterReading() async {
    DateTime now = DateTime.now();
    int year = now.year;
    int month = now.month;
    final response = await http.get(Uri.parse(
        'https://imiziapi.codeflux.co.za/api/MeterReading/search/$year/$month/$selectedBlockID'));
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      List<MeterReading> meterReadings = jsonResponse
          .map((meterReading) => MeterReading.fromJson(meterReading))
          .toList();

      meterReadings.sort((a, b) => a.unitNumber.compareTo(b.unitNumber));
      return meterReadings;
    } else {
      throw Exception('Could not fetch readings for ${_prop.name}');
    }
  }

  // Pagination Funtionality:
  int currentPage = 0; //Keeping track of current Page
  int itemsPerPage = 6; //Number of items to Display per page

  // Displaying capped List of Units
  List<Units> getUnitsForCurrentPage(List<Units> allUnits) {
    final startIndex = currentPage * itemsPerPage;

    // Ensure startIndex is within a valid range
    if (startIndex >= allUnits.length) {
      return [];
    }

    final endIndex = startIndex + itemsPerPage;

    // Ensure endIndex doesn't exceed the total number of items
    if (endIndex > allUnits.length) {
      return allUnits.sublist(startIndex);
    } else {
      return allUnits.sublist(startIndex, endIndex);
    }
  }

  //Displaying capped List of Meters
  List<Meters> getMetersForCurrentPage(List<Meters> allMeters) {
    final startIndex = currentPage * itemsPerPage;

    // Ensure startIndex is within a valid range
    if (startIndex >= allMeters.length) {
      return [];
    }

    final endIndex = startIndex + itemsPerPage;

    // Ensure endIndex doesn't exceed the total number of items
    if (endIndex > allMeters.length) {
      return allMeters.sublist(startIndex);
    } else {
      return allMeters.sublist(startIndex, endIndex);
    }
  }

  // List of everything capped
  List<MeterReading> getMeterReadingForCurrentPage(
      List<MeterReading> meterReadings) {
    final startIndex = currentPage * itemsPerPage;

    // Ensure startIndex is within a valid range
    if (startIndex >= meterReadings.length) {
      return [];
    }

    final endIndex = startIndex + itemsPerPage;

    // Ensure endIndex doesn't exceed the total number of items
    if (endIndex > meterReadings.length) {
      return meterReadings.sublist(startIndex);
    } else {
      return meterReadings.sublist(startIndex, endIndex);
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
                          fontSize: 17.0,
                          color: Color.fromARGB(255, 166, 160, 55),
                          fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: FutureBuilder<List<Blocks>>(
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

                              return Container(
                                width: 130,
                                height: 40,
                                padding: const EdgeInsets.only(
                                    left: 6.0, right: 2.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors
                                          .black), // Set the border color to black
                                ),
                                child: DropdownButton<Blocks>(
                                  items: items,
                                  isExpanded: true,
                                  iconSize: 36.0,
                                  underline: Container(),
                                  onChanged: (selectedBlock) {
                                    setState(() {
                                      this.selectedBlock = selectedBlock;
                                      selectedBlockID = selectedBlock!
                                          .blockId; // BlockId to be able to select units
                                      // call method to fetch units when block is clicked
                                      // fetch = request();
                                      futureUnits = fetchUnits();
                                    });
                                  },
                                  value: selectedBlock, // Set initial value
                                ),
                              );
                            }
                          }),
                    )
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
                    left: 26.0, top: 16.0, bottom: 6.0, right: 18.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.6,
                  color: Colors.purple,
                  // Add code here:
                  child: RawScrollbar(
                    thumbColor: Color.fromARGB(255, 166, 160, 55),
                    radius: Radius.zero,
                    thickness: 10,
                    controller: _firstController,
                    child: SingleChildScrollView(
                      controller: _firstController,
                      child: Wrap(direction: Axis.horizontal, children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.80 / 5,
                          height: MediaQuery.of(context).size.height,
                          color: Colors.blue,
                          child: Column(
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                height: MediaQuery.of(context).size.height,
                                child: FutureBuilder(
                                  future: futureMeterReading,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(
                                            color: Color.fromARGB(
                                                255, 166, 160, 55)),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child: Text('${snapshot.error}'));
                                    } else {
                                      // List<dynamic> data = snapshot.data!
                                      List<MeterReading> units = snapshot.data!;
                                      final unitsToDisplay =
                                          getMeterReadingForCurrentPage(units);

                                      return ListView.separated(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          padding: const EdgeInsets.only(
                                              left: 15.0,
                                              top: 10.0,
                                              bottom: 25.0,
                                              right: 10.0),
                                          itemBuilder:
                                              (BuildContext context, index) {
                                            MeterReading unit =
                                                unitsToDisplay[index];
                                            return Text(
                                              'Unit ${unit.unitNumber}',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            );
                                          },
                                          separatorBuilder:
                                              (BuildContext context,
                                                      int index) =>
                                                  const SizedBox(height: 34),
                                          itemCount: unitsToDisplay.length);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.82 / 5,
                          height: MediaQuery.of(context).size.height,
                          color: Colors.amber,
                          child: Column(
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                height: MediaQuery.of(context).size.height,
                                child: FutureBuilder(
                                    future: futureMeterReading,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator(
                                                color: Color.fromARGB(
                                                    255, 166, 160, 55)));
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child: Text('${snapshot.error}'));
                                      } else {
                                        List<MeterReading> meters =
                                            snapshot.data!;
                                        final metersToDisplay =
                                            getMeterReadingForCurrentPage(
                                                meters);
                                        return ListView.separated(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          padding: const EdgeInsets.only(
                                              left: 15.0,
                                              top: 10.0,
                                              bottom: 25.0,
                                              right: 10.0),
                                          itemCount: metersToDisplay.length,
                                          itemBuilder:
                                              (BuildContext context, index) {
                                            MeterReading meter =
                                                metersToDisplay[index];
                                            return Text('${meter.meterNumber}');
                                          },
                                          separatorBuilder:
                                              (BuildContext context,
                                                      int index) =>
                                                  const SizedBox(height: 34.0),
                                        );
                                      }
                                    }),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: ((MediaQuery.of(context).size.width) +
                                  (MediaQuery.of(context).size.width) * 0.4) /
                              5,
                          height: MediaQuery.of(context).size.height,
                          color: Colors.green,
                          child: Column(
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                height: MediaQuery.of(context).size.height,
                                child: FutureBuilder(
                                  future: futureMeterReading,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator(
                                              color: Color.fromARGB(
                                                  255, 166, 160, 55)));
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child: Text('${snapshot.error}'));
                                    } else {
                                      List<MeterReading> units = snapshot.data!;
                                      final unitsToDisplay =
                                          getMeterReadingForCurrentPage(units);
                                      return ListView.separated(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          padding: const EdgeInsets.only(
                                              right: 8.0,
                                              left: 8.0,
                                              top: 9.0,
                                              bottom: 16.0),
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            // Units unit = unitsToDisplay[index];
                                            return Container(
                                              child: CupertinoTextField(
                                                decoration: BoxDecoration(
                                                    color: theme
                                                        .colorScheme.background,
                                                    border: Border.all(
                                                        color: Colors.black)),
                                                cursorColor:
                                                    theme.colorScheme.primary,
                                                placeholder:
                                                    "Enter Meter Reading",
                                                style: TextStyle(
                                                    color: theme.colorScheme
                                                        .onBackground,
                                                    fontSize: 14),
                                                padding: const EdgeInsets.only(
                                                    top: 8,
                                                    bottom: 8,
                                                    left: 8,
                                                    right: 4),
                                                placeholderStyle: TextStyle(
                                                    color: theme.colorScheme
                                                        .onBackground
                                                        .withAlpha(160)),
                                              ),
                                            );
                                          },
                                          separatorBuilder:
                                              (BuildContext context,
                                                      int index) =>
                                                  const SizedBox(
                                                    height: 22.0,
                                                  ),
                                          itemCount: unitsToDisplay.length);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.82 / 5,
                          height: MediaQuery.of(context).size.height,
                          color: Colors.orange,
                          child: Column(
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                height: MediaQuery.of(context).size.height,
                                child: FutureBuilder(
                                  future: futureMeterReading,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator(
                                              color: Color.fromARGB(
                                                  255, 166, 160, 55)));
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child: Text('${snapshot.error}'));
                                    } else {
                                      List<MeterReading> previous =
                                          snapshot.data!;
                                      final previousToDisplay =
                                          getMeterReadingForCurrentPage(
                                              previous);
                                      return ListView.separated(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          padding: const EdgeInsets.only(
                                              left: 15.0,
                                              top: 10.0,
                                              bottom: 25.0,
                                              right: 10.0),
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            MeterReading prev =
                                                previousToDisplay[index];
                                            return Text(
                                              '${prev.previous}',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            );
                                          },
                                          separatorBuilder:
                                              (BuildContext context,
                                                      int index) =>
                                                  const SizedBox(height: 34.0),
                                          itemCount: previousToDisplay.length);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.82 / 5,
                          height: MediaQuery.of(context).size.height,
                          color: Colors.red,
                          child: Column(children: <Widget>[
                            Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height,
                              child: FutureBuilder(
                                  future: futureMeterReading,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator(
                                              color: Color.fromARGB(
                                                  255, 166, 160, 55)));
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child: Text('${snapshot.error}'));
                                    } else {
                                      List<MeterReading> average =
                                          snapshot.data!;
                                      final averageToDisplay =
                                          getMeterReadingForCurrentPage(
                                              average);
                                      return ListView.separated(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          padding: const EdgeInsets.only(
                                              left: 15.0,
                                              top: 10.0,
                                              bottom: 25.0,
                                              right: 10.0),
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            MeterReading ave =
                                                averageToDisplay[index];
                                            return Text(
                                              '${ave.average}',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            );
                                          },
                                          separatorBuilder:
                                              (BuildContext context,
                                                      int index) =>
                                                  const SizedBox(height: 34.0),
                                          itemCount: averageToDisplay.length);
                                    }
                                  }),
                            ),
                          ]),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 31.0, top: 28.0, bottom: 1.0, right: 18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // Home and Submit buttons at flex ends
                  children: <Widget>[
                    // Spacer to push buttons to the flex ends
                    FxButton.medium(
                      elevation: 1,
                      borderRadiusAll: 0.0,
                      backgroundColor: const Color.fromARGB(255, 207, 119, 40),
                      onPressed: () {
                        // Logic for 'Home' button
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (_) => PropertyScreen(),
                        ));
                      },
                      child: const Text(
                        'Home',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    // SizedBox(width: 16), // Add spacing between buttons

                    Spacer(), // Spacer to center the 'Next' and 'Previous' buttons
                    FxButton.medium(
                      elevation: 1,
                      borderRadiusAll: 0.0,
                      backgroundColor: const Color.fromARGB(255, 166, 160, 55),
                      onPressed: () {
                        if (currentPage > 0) {
                          setState(() {
                            currentPage--;
                          });
                        }
                      },
                      child: const Text(
                        '<<',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(width: 16), // Add some spacing between the buttons
                    FxButton.medium(
                      elevation: 1,
                      borderRadiusAll: 0.0,
                      backgroundColor: const Color.fromARGB(255, 166, 160, 55),
                      onPressed: () async {
                        final List<Units> allUnits =
                            await futureUnits; // Wait for the future to complete
                        final List<Meters> allMeters = await futureMeters;
                        final totalPages =
                            (allUnits.length / itemsPerPage).ceil();
                        if (currentPage < totalPages - 1) {
                          setState(() {
                            currentPage++;
                          });
                        }
                      },
                      child: const Text(
                        '>>',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Spacer(),
                    FxButton.medium(
                      elevation: 1,
                      borderRadiusAll: 0.0,
                      backgroundColor: const Color.fromARGB(255, 207, 119, 40),
                      onPressed: () {
                        // Logic for 'Submit' button
                        // Implement the submission logic here
                      },
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
