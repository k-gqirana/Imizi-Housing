import 'dart:convert';
// import 'dart:html';
import 'package:flutter/material.dart';
import '../screens/property_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutx/flutx.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/keypad.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import './login_screen.dart';

//Data Model for Blocks associated with each property
class Blocks {
  final int blockId;
  final int propertyId;
  final String blockNumber;
  // final bool blockAcitve;
  final String propertyName;
  // final bool propertyActive;
  final String description;

  Blocks(
      {required this.blockId,
      required this.propertyId,
      required this.blockNumber,
      // required this.blockAcitve,
      required this.propertyName,
      // required this.propertyActive,
      required this.description});

  Map<String, dynamic> toMap() {
    return {
      'blockId': blockId,
      'propertyId': propertyId,
      'blockNumber': blockNumber,
      'propertyName': propertyName,
      'description': description
    };
  }

  factory Blocks.fromJson(Map<String, dynamic> json) {
    return Blocks(
        blockId: json['blockId'],
        propertyId: json['propertyId'],
        blockNumber: json['blockNumber'],
        // blockAcitve: json['blockActive'],
        propertyName: json['propertyName'],
        // propertyActive: json['propertyActive'],
        description: json['description']);
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
  final int currentReading;
  final int previousReading;
  // final String meterType;
  final int lastMonthConsumption;
  final dynamic unitNumber;
  final int averageConsumption;
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
      required this.currentReading,
      required this.previousReading,
      // required this.meterType,
      required this.lastMonthConsumption,
      required this.unitNumber,
      required this.averageConsumption,
      required this.month,
      required this.year});

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'name': name,
      'blockId': blockId,
      'blockNumber': blockNumber,
      'unitId': unitId,
      'meterId': meterId,
      'meterNumber': meterNumber,
      'currentReading': currentReading,
      'previousReading': previousReading,
      // 'meterType': meterType,
      'lastMonthConsumption': lastMonthConsumption,
      'unitNumber': unitNumber,
      'averageConsumption': averageConsumption,
      'month': month,
      'year': year
    };
  }

  factory MeterReading.fromJson(Map<String, dynamic> json) {
    return MeterReading(
        propertyId: json['propertyId'],
        name: json['name'],
        blockId: json['blockId'],
        blockNumber: json['blockNumber'],
        unitId: json['unitId'],
        meterId: json['meterId'],
        meterNumber: json['meterNumber'],
        currentReading: json['currentReading'],
        previousReading: json['previousReading'],
        // meterType: json['meterType'],
        lastMonthConsumption: json['lastMonthConsumption'],
        unitNumber: json['unitNumber'],
        averageConsumption: json['averageConsumption'],
        month: json['month'],
        year: json['year']);
  }
}

class MeterScreen extends StatefulWidget {
  final Property property;
  final Login loginDetails;
  const MeterScreen(
      {Key? key, required this.property, required this.loginDetails})
      : super(key: key);

  @override
  State<MeterScreen> createState() => _MeterScreenState();
}

class _MeterScreenState extends State<MeterScreen> {
  late Property _prop;
  late Login _login;
  late Future<List<Blocks>> futureBlocks;
  // late Future<List<Units>> futureUnits;
  // late Future<List<Meters>> futureMeters;
  late Future<List<MeterReading>> futureMeterReading;
  late Future<List<MeterReading>> futureUncapturedMeterReading;
  late Future<void> futureTextControllers;
  late Future<void> futureSavedTextControllers;
  // late Future<List<dynamic>> fetch;
  Blocks? selectedBlock; // Define selectedBlock as nullable
  late int selectedBlockID; // To fetch the units of the selected block

  //Scroll Controller
  final ScrollController _firstController = ScrollController();

  // Define a list of controllers outside the FutureBuilder
  List<TextEditingController> textControllers = [];
  List<bool> showTextFields = [];

// Creating a unique List of Text Editing Controllers for each block
  final Map<int, List<TextEditingController>> listOfTextControllers = {};

  //Controllers for empty fields when checking uncaptured textbox
  final Map<int, List<TextEditingController>> emptyController = {};

  //Checkbox bool
  bool isChecked = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _prop = widget.property;
    _login = widget.loginDetails;
    // When screen loads, get the blocks for the current Property
    futureBlocks = fetchBlocks();
    // Initialize selectedBlock with the first item in blocks when available
    futureBlocks.then((blocks) {
      if (blocks.isNotEmpty) {
        setState(() {
          selectedBlock = blocks.first;
          selectedBlockID = selectedBlock!.blockId;
          // call method to fetch units when block is clicked
          futureMeterReading = fetchMeterReading();
          // Create List of Controllers for each Block
          futureTextControllers = fetchControllers();
        });
      }
    });
    futureMeterReading = fetchMeterReading();
  }

  Future<void> fetchControllers() async {
    // Fix building off TextEdidting controllers

    bool meterTableExist = await doesMeterReadingTableExist();
    if (meterTableExist) {
      List<MeterReading> meterData = await getMeterReadingFromDB();
      for (var i = 0; i < meterData.length; i++) {
        listOfTextControllers[selectedBlockID]!.add(TextEditingController());
      }
      print(
          'TextControllers length: ${listOfTextControllers[selectedBlockID]!.length}');
    }
  }

  Future<void> fetchSavedControllers() async {
    // Update current readings with values in Textfield
    //get controllers
    // get List of Meters
    List<MeterReading> meterReadings = await getMeterReadingFromDB();
    updateCurrentReadings(
        meterReadings, listOfTextControllers[selectedBlockID]!);
  }

  // Fetching the blocks from the API endpoint
  Future<List<Blocks>> fetchBlocks() async {
    try {
      final response = await http.get(Uri.parse(
          'https://imiziapi.codeflux.co.za/api/Block/GetFilteredBlocks/${_prop.propertyId}'));

      if (response.statusCode == 200) {
        bool tableExists = await doesBlocksTableExist();

        if (tableExists) {
          await deleteAllBlocks();
          await insertBlocksFromAPI(response.body);
        } else {
          await createBlocksTable();
          await insertBlocksFromAPI(response.body);
        }

        List<Blocks> blocks = await getBlocksFromDB();
        for (var block in blocks) {
          final List<TextEditingController> controllers = [];
          listOfTextControllers[block.blockId] = controllers;
        }

        // blocks.sort((a, b) => a.blockNumber.compareTo(b.blockNumber));

        return blocks;
      } else {
        throw Exception('Could not get list of blocks within ${_prop.name}');
      }
    } catch (e) {
      // No internet connection
      bool tableExists = await doesBlocksTableExist();
      if (tableExists) {
        List<Blocks> blocks = await getBlocksFromDB();
        for (var block in blocks) {
          final List<TextEditingController> controllers = [];
          listOfTextControllers[block.blockId] = controllers;
        }
        // blocks.sort((a, b) => a.blockNumber.compareTo(b.blockNumber));
        return blocks;
      } else {
        throw Exception('Could not get list of blocks within ${_prop.name}');
      }
    }
  }

  Future<void> createBlocksTable() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'block_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE blocks(id INTEGER  PRIMARY KEY, blockId INTEGER, propertyId INTEGER, blockNumber TEXT, propertyName TEXT, description TEXT)',
        );
      },
      version: 1,
    );
    await database.close();
  }

  Future<bool> doesBlocksTableExist() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'block_database.db'),
    );
    final tables = await database
        .query('sqlite_master', where: 'name = ?', whereArgs: ['blocks']);
    await database.close();
    return tables.isNotEmpty;
  }

  Future<void> deleteAllBlocks() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'block_database.db'),
    );
    await database.delete('blocks');
    await database.close();
  }

  Future<void> insertBlocksFromAPI(String responseBody) async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'block_database.db'),
    );
    final List<dynamic> jsonResponse = json.decode(responseBody);
    for (var block in jsonResponse) {
      await database.insert(
        'blocks',
        Blocks.fromJson(block).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await database.close();
  }

  Future<List<Blocks>> getBlocksFromDB() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'block_database.db'),
    );
    final List<Map<String, dynamic>> maps = await database.query('blocks');
    await database.close();
    return List.generate(maps.length, (i) {
      return Blocks.fromJson(maps[i]);
    });
  }

  Future<List<MeterReading>> fetchMeterReading() async {
    try {
      DateTime now = DateTime.now();
      int year = now.year;
      int month = now.month;
      final response = await http.get(Uri.parse(
          'https://imiziapi.codeflux.co.za/api/MeterReading/search/$year/$month/$selectedBlockID'));
      if (response.statusCode == 200) {
        bool tableExists = await doesMeterReadingTableExist();
        if (tableExists) {
          await deleteAllMeterReading();
          await insertMeterReadingFromAPI(response.body);
        } else {
          await createMeterReadingTable();
          await insertMeterReadingFromAPI(response.body);
        }

        List<MeterReading> meterReadings = await getMeterReadingFromDB();

        meterReadings.sort((a, b) => a.unitNumber.compareTo(b.unitNumber));
        for (int i = 0; i < meterReadings.length; i++) {
          // textControllers.add(TextEditingController());
          showTextFields.add(true); // Initially, all text fields are shown
        }
        return meterReadings;
      } else {
        throw Exception(
            'Could not fetch readings for ${selectedBlock?.blockNumber}');
      }
    } on SocketException {
      // No internet connection
      bool tableExists = await doesMeterReadingTableExist();
      if (tableExists) {
        List<MeterReading> meterReadings = await getMeterReadingFromDB();
        meterReadings.sort((a, b) => a.unitNumber.compareTo(b.unitNumber));
        for (int i = 0; i < meterReadings.length; i++) {
          // textControllers.add(TextEditingController());
        }
        return meterReadings;
      } else {
        throw Exception(
            'Could not fetch readings for ${selectedBlock?.blockNumber}');
      }
    } catch (e) {
      throw Exception(
          'Could not fetch readings for ${selectedBlock?.blockNumber}');
    }
    // if (response.statusCode == 200) {
    //   List<dynamic> jsonResponse = json.decode(response.body);
    //   List<MeterReading> meterReadings = jsonResponse
    //       .map((meterReading) => MeterReading.fromJson(meterReading))
    //       .toList();
    //   for (int i = 0; i < meterReadings.length; i++) {
    //     textControllers.add(TextEditingController());
    //   }
    //   print('Text Controllers: ${textControllers.length}');
    //   meterReadings.sort((a, b) => a.unitNumber.compareTo(b.unitNumber));
    //   return meterReadings;
    // } else {
    //   throw Exception('Could not fetch readings for ${_prop.name}');
    // }
  }

  Future<void> createMeterReadingTable() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'meter_database.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE meters(id INTEGER PRIMARY KEY, propertyId INTEGER, name TEXT, blockId INTEGER, blockNumber TEXT, unitId INTEGER, meterId INTEGER, meterNumber TEXT, currentReading INTEGER, previousReading INTEGER, lastMonthConsumption INTEGER , unitNumber INTEGER, averageConsumption INTEGER, month INTEGER, year INTEGER)');
      },
      version: 1,
    );
    await database.close();
  }

  Future<bool> doesMeterReadingTableExist() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'meter_database.db'),
    );
    final tables = await database
        .query('sqlite_master', where: 'name = ?', whereArgs: ['meters']);
    await database.close();
    return tables.isNotEmpty;
  }

  Future<void> deleteAllMeterReading() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'meter_database.db'),
    );
    await database.delete('meters');
    await database.close();
  }

  Future<void> insertMeterReadingFromAPI(String responseBody) async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'meter_database.db'),
    );
    final List<dynamic> jsonResponse = json.decode(responseBody);
    for (var meter in jsonResponse) {
      await database.insert(
        'meters',
        MeterReading.fromJson(meter).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await database.close();
  }

  Future<List<MeterReading>> getMeterReadingFromDB() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'meter_database.db'),
    );
    final List<Map<String, dynamic>> maps = await database.query('meters');
    await database.close();
    return List.generate(maps.length, (i) {
      return MeterReading.fromJson(maps[i]);
    });
  }

  Future<List<MeterReading>> uncapturedMeters() async {
    // check is table exist
    bool tableExists = await doesMeterReadingTableExist();
    if (tableExists) {
      //get Meter Readings from Local DB
      List<MeterReading> meterReadings = await getMeterReadingFromDB();
      // meterReadings.sort((a, b) => a.unitNumber.compareTo(b.unitNumber));
      List<MeterReading> emptyMeter = [];

      for (var i = 0; i < meterReadings.length; i++) {
        MeterReading meterReading = meterReadings[i];
        if (listOfTextControllers[selectedBlockID]?[i].text == "") {
          emptyMeter.add(meterReading);
        }
      }
      // if (emptyMeter.length != 0) {
      //   for (var i = 0; i < emptyMeter.length; i++) {
      //     listOfTextControllers[selectedBlockID]?[i].clear();
      //   }
      // }

      return emptyMeter;
    } else {
      throw Exception('Could not show empty Meter Readings');
    }
  }

  Future<void> updateCurrentReadings(List<MeterReading> meterReadings,
      List<TextEditingController> controllers) async {
    bool tableExists = await doesMeterReadingTableExist();
    if (tableExists) {
      // Open the database (replace _database.db' with  actual database path)
      final database = await openDatabase(
        join(await getDatabasesPath(), 'meter_database.db'),
      );

      // Loop through  MeterReading objects and update the 'currentReading' field
      for (int i = 0; i < meterReadings.length; i++) {
        final currentReading = int.tryParse(controllers[i].text) ?? 0;
        MeterReading meterReading = meterReadings[i];

        var updatedData = MeterReading(
            propertyId: meterReading.propertyId,
            name: meterReading.name,
            blockId: meterReading.blockId,
            blockNumber: meterReading.blockNumber,
            unitId: meterReading.unitId,
            meterId: meterReading.meterId,
            meterNumber: meterReading.meterNumber,
            currentReading: currentReading,
            previousReading: meterReading.previousReading,
            // meterType: meterReading.meterType,
            lastMonthConsumption: meterReading.lastMonthConsumption,
            unitNumber: meterReading.unitNumber,
            averageConsumption: meterReading.averageConsumption,
            month: meterReading.month,
            year: meterReading.year);

        // Update the 'currentReading' field in the database
        await database.update(
          'meters',
          updatedData.toMap(),
          where: 'meterId = ?',
          whereArgs: [meterReading.meterId],
        );
      }

      // Close the database
      await database.close();
    } else {
      print("The meterReading Table does not exits in the device");
    }
  }

  String formatMeterReadingsForPrint(List<MeterReading> meterReadings) {
    final List<String> formattedReadings = [];
    for (var reading in meterReadings) {
      formattedReadings.add('MeterReading('
          'propertyId: ${reading.propertyId}, '
          'name: ${reading.name}, '
          'blockId: ${reading.blockId}, '
          'blockNumber: ${reading.blockNumber}, '
          'unitId: ${reading.unitId}, '
          'meterId: ${reading.meterId}, '
          'meterNumber: ${reading.meterNumber}, '
          'currentReading: ${reading.currentReading}, '
          'previousReading: ${reading.previousReading}, '
          // 'meterType: ${reading.meterType}, '
          'lastMonthConsumption: ${reading.lastMonthConsumption}, '
          'unitNumber: ${reading.unitNumber}, '
          'averageConsumption: ${reading.averageConsumption}, '
          'month: ${reading.month}, '
          'year: ${reading.year}'
          ')');
    }
    return formattedReadings.join('\n');
  }

  // Showing readings on Textfield even when user exists the app

  // Pagination Funtionality:
  int currentPage = 0; //Keeping track of current Page
  int itemsPerPage = 12; //Number of items to Display per page
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

  //Function to show the CustomKeypad when a Textfield input is tapped
  void showCustomKeypad(BuildContext context, TextEditingController? controller,
      int unitPrevious, Function(String) onSubmitted) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: CustomKeypad(
            textController: controller!,
            onKeypadButtonPressed: (String buttonText) {
              if (buttonText == 'C') {
                controller.clear();
              } else if (buttonText == '<') {
                if (controller.text.isNotEmpty) {
                  controller.text =
                      controller.text.substring(0, controller.text.length - 1);
                }
                // Close the keypad widget
                Navigator.of(context).pop();
              } else if (buttonText == 'Submit') {
                // Handle submit button press, to post readings to API
                String enteredText = controller.text;
                print('Entered Text: $enteredText');
                // Call the onSubmitted callback and pass the entered text
                onSubmitted(enteredText);
                // Close the keypad widget
                // futureMeterReading = uncapturedMeters();
                Navigator.of(context).pop();
              } else {
                controller.text += buttonText;
              }
              // Call the callback function to update the controller's value
              // onSubmitted(controller.text);
            },
          ),
        );
      },
    );
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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Property Name: ${_prop.name}',
                          style: const TextStyle(
                              fontSize: 17.0,
                              color: Color.fromARGB(255, 166, 160, 55),
                              fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: <Widget>[
                            Checkbox(
                              checkColor: Colors.white,
                              // fillColor: MaterialStateProperty.resolveWith(getColor),
                              value: isChecked,
                              onChanged: (bool? value) async {
                                if (value != null) {
                                  if (value) {
                                    futureUncapturedMeterReading =
                                        uncapturedMeters();
                                  }
                                }
                                setState(() {
                                  isChecked = value!;
                                });
                              },
                            ),
                            const SizedBox(width: 1.5),
                            const Text('Uncaptured Meters Only',
                                style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ],
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
                                      futureMeterReading = fetchMeterReading();
                                      futureTextControllers =
                                          fetchControllers();
                                      futureSavedTextControllers =
                                          fetchSavedControllers();
                                    });
                                    // Do local database update here
                                    // List<MeterReading> updateOnClick =
                                    //     await getMeterReadingFromDB();
                                    // await updateCurrentReadings(
                                    //     updateOnClick,
                                    //     listOfTextControllers[
                                    //         selectedBlockID]!);
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
                      'Previous',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Reading',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Consumption',
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
                  // color: Colors.purple,
                  child: RawScrollbar(
                    thumbColor: Color.fromARGB(255, 166, 160, 55),
                    radius: Radius.zero,
                    thickness: 10,
                    controller: _firstController,
                    child: SingleChildScrollView(
                      controller: _firstController,
                      child: Wrap(direction: Axis.horizontal, children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.75 / 6,
                          height: MediaQuery.of(context).size.height,
                          // color: Colors.blue,
                          child: Column(
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                height: MediaQuery.of(context).size.height,
                                child: FutureBuilder(
                                  future: isChecked
                                      ? futureUncapturedMeterReading
                                      : futureMeterReading,
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
                                                  const TextStyle(fontSize: 15),
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
                          width: MediaQuery.of(context).size.width * 0.95 / 6,
                          height: MediaQuery.of(context).size.height,
                          // color: Colors.amber,
                          child: Column(
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                height: MediaQuery.of(context).size.height,
                                child: FutureBuilder(
                                    future: isChecked
                                        ? futureUncapturedMeterReading
                                        : futureMeterReading,
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
                                            return Text(
                                              '${meter.meterNumber}',
                                              style: const TextStyle(
                                                  fontSize: 15.0),
                                            );
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
                          width: MediaQuery.of(context).size.width * 0.73 / 6,
                          height: MediaQuery.of(context).size.height,
                          // color: Colors.orange,
                          child: Column(
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                height: MediaQuery.of(context).size.height,
                                child: FutureBuilder(
                                  future: isChecked
                                      ? futureUncapturedMeterReading
                                      : futureMeterReading,
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
                                              left: 25.0,
                                              top: 10.0,
                                              bottom: 25.0,
                                              right: 10.0),
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            MeterReading prev =
                                                previousToDisplay[index];
                                            return Text(
                                              '${prev.previousReading}',
                                              style:
                                                  const TextStyle(fontSize: 15),
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
                          width: ((MediaQuery.of(context).size.width) +
                                  (MediaQuery.of(context).size.width) * 0.46) /
                              6,
                          height: MediaQuery.of(context).size.height,
                          // color: Colors.green,
                          child: Column(
                            children: <Widget>[
                              Container(
                                  width: double.infinity,
                                  height: MediaQuery.of(context).size.height,
                                  child: FutureBuilder(
                                    future: isChecked
                                        ? futureUncapturedMeterReading
                                        : futureMeterReading,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            color: Color.fromARGB(
                                                255, 166, 160, 55),
                                          ),
                                        );
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child: Text('${snapshot.error}'));
                                      } else {
                                        List<MeterReading> units =
                                            snapshot.data!;
                                        final unitsToDisplay =
                                            getMeterReadingForCurrentPage(
                                                units);

                                        return ListView.separated(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          padding: const EdgeInsets.only(
                                            right: 8.0,
                                            left: 8.0,
                                            top: 7.0,
                                            bottom: 16.0,
                                          ),
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            MeterReading unit =
                                                unitsToDisplay[index];
                                            ValueNotifier<String>
                                                textValueNotifier =
                                                ValueNotifier<String>("");
                                            return ValueListenableBuilder<
                                                String>(
                                              valueListenable:
                                                  textValueNotifier,
                                              builder: (context, text, child) {
                                                Color textColor = text.isEmpty
                                                    ? Colors.black
                                                    : int.tryParse(text)! >
                                                            (unit.previousReading +
                                                                unit.previousReading *
                                                                    0.25)
                                                        ? Colors.red
                                                        : Colors.black;
                                                if (unit.currentReading != 0) {
                                                  final textValue = unit
                                                      .currentReading
                                                      .toString();
                                                  listOfTextControllers[
                                                                  selectedBlockID]
                                                              ?[
                                                              index +
                                                                  (currentPage *
                                                                      itemsPerPage)]
                                                          .value =
                                                      TextEditingValue(
                                                          text: textValue,
                                                          selection: TextSelection
                                                              .fromPosition(
                                                                  TextPosition(
                                                                      offset: textValue
                                                                          .length)));
                                                }
                                                return Container(
                                                  child: CupertinoTextField(
                                                    readOnly: true,
                                                    onTap: () {
                                                      showCustomKeypad(
                                                        context,
                                                        listOfTextControllers[
                                                                selectedBlockID]
                                                            ?[index +
                                                                (currentPage *
                                                                    itemsPerPage)],
                                                        unit.previousReading,
                                                        (String updatedValue) {
                                                          // The updatedValue parameter contains the latest value from the controller

                                                          textValueNotifier
                                                                  .value =
                                                              updatedValue;

                                                          print(
                                                              'Updated Value: $updatedValue');

                                                          listOfTextControllers[
                                                                      selectedBlockID]
                                                                  ?[index +
                                                                      (currentPage *
                                                                          itemsPerPage)]
                                                              .value = TextEditingValue(
                                                            text: updatedValue,
                                                            selection: listOfTextControllers[
                                                                        selectedBlockID]![
                                                                    index +
                                                                        (currentPage *
                                                                            itemsPerPage)]
                                                                .selection,
                                                          );
                                                        },
                                                      );
                                                    },
                                                    controller:
                                                        listOfTextControllers[
                                                                selectedBlockID]
                                                            ?[index +
                                                                (currentPage *
                                                                    itemsPerPage)],
                                                    decoration: BoxDecoration(
                                                      color: theme.colorScheme
                                                          .background,
                                                      border: Border.all(
                                                          color: Colors.black),
                                                    ),
                                                    cursorColor: theme
                                                        .colorScheme.primary,
                                                    placeholder:
                                                        "Enter Meter Reading",
                                                    style: TextStyle(
                                                      color: textColor,
                                                      fontSize: 14,
                                                    ),
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8,
                                                            bottom: 8,
                                                            left: 8,
                                                            right: 4),
                                                    placeholderStyle: TextStyle(
                                                      color: theme.colorScheme
                                                          .onBackground
                                                          .withAlpha(160),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          separatorBuilder:
                                              (BuildContext context,
                                                      int index) =>
                                                  const SizedBox(
                                            height: 21.0,
                                          ),
                                          itemCount: unitsToDisplay.length,
                                        );
                                      }
                                    },
                                  )),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.73 / 6,
                          height: MediaQuery.of(context).size.height,
                          // color: Colors.orange,
                          child: Column(children: <Widget>[
                            Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height,
                              child: FutureBuilder(
                                  future: isChecked
                                      ? futureUncapturedMeterReading
                                      : futureMeterReading,
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
                                      List<MeterReading> consumption =
                                          snapshot.data!;
                                      final consumptionToDisplay =
                                          getMeterReadingForCurrentPage(
                                              consumption);
                                      return ListView.separated(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          padding: const EdgeInsets.only(
                                              left: 25.0,
                                              top: 10.0,
                                              bottom: 25.0,
                                              right: 10.0),
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            MeterReading consumed =
                                                consumptionToDisplay[index];
                                            return Text(
                                              '${consumed.lastMonthConsumption}',
                                              style:
                                                  const TextStyle(fontSize: 15),
                                            );
                                          },
                                          separatorBuilder:
                                              (BuildContext context,
                                                      int index) =>
                                                  const SizedBox(height: 34.0),
                                          itemCount:
                                              consumptionToDisplay.length);
                                    }
                                  }),
                            ),
                          ]),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.73 / 6,
                          height: MediaQuery.of(context).size.height,
                          // color: Colors.red,
                          child: Column(children: <Widget>[
                            Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height,
                              child: FutureBuilder(
                                  future: isChecked
                                      ? futureUncapturedMeterReading
                                      : futureMeterReading,
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
                                              left: 45.0,
                                              top: 10.0,
                                              bottom: 25.0,
                                              right: 0),
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            MeterReading ave =
                                                averageToDisplay[index];
                                            return Text(
                                              '${ave.averageConsumption}',
                                              style:
                                                  const TextStyle(fontSize: 15),
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
                          builder: (_) => PropertyScreen(
                            loginDetails: _login,
                          ),
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

                    const Spacer(), // Spacer to center the 'Next' and 'Previous' buttons
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
                    const SizedBox(
                        width: 16), // Add some spacing between the buttons
                    FxButton.medium(
                      elevation: 1,
                      borderRadiusAll: 0.0,
                      backgroundColor: const Color.fromARGB(255, 166, 160, 55),
                      onPressed: () async {
                        final List<MeterReading> allUnits =
                            await futureMeterReading; // Wait for the future to complete
                        // final List<Meters> allMeters = await futureMeters;
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
                    const Spacer(),
                    FxButton.medium(
                      elevation: 1,
                      borderRadiusAll: 0.0,
                      backgroundColor: const Color.fromARGB(255, 207, 119, 40),
                      onPressed: () async {
                        String url =
                            'https://imiziapi.codeflux.co.za/api/MeterReading/update-mobile-readings';

                        List<MeterReading> updateLocal =
                            await getMeterReadingFromDB();
                        await updateCurrentReadings(updateLocal,
                            listOfTextControllers[selectedBlockID]!);
                        List<MeterReading> recent =
                            await getMeterReadingFromDB();
                        print(formatMeterReadingsForPrint(recent));
                        List<Map<String, dynamic>> jsonResponse = [];
                        final List<MeterReading> readings =
                            await fetchMeterReading();

                        for (int i = 0; i < readings.length; i++) {
                          MeterReading reading = readings[i];
                          jsonResponse.add({
                            'meterId': reading.meterId,
                            'reading': int.tryParse(
                                    listOfTextControllers[selectedBlockID]![i]
                                        .text) ??
                                0,
                            'userId': _login.userId,
                          });
                        }
                        //Updating local

                        // // Post method
                        try {
                          final response = await http.post(Uri.parse(url),
                              headers: <String, String>{
                                'Content-Type': 'application/json'
                              },
                              body: jsonEncode(jsonResponse));
                          if (response.statusCode == 200) {
                            print('Response successful');
                          } else {
                            print('Error code: ${response.statusCode}');
                            print('Error message: ${response.body}');
                          }
                        } catch (e) {
                          print('Post Error: ${e.runtimeType}');
                        }
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
