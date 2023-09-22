import 'package:flutter/material.dart';

// Use this unction to set up Data for the Blocks
void listingBlocks() {
  List<Map<String, dynamic>> blocks = [];

  for (int i = 1; i <= 4; i++) {
    Map<String, dynamic> block = {
      'Units': ['Unit 1', 'Unit 2', 'Unit 3', 'Unit 4'],
      'Meters': ['Meter 1', 'Meter 2', 'Meter 3', 'Meter 4'],
      'Previous': [456, 456, 456, 456],
      'Average': [420, 420, 420, 420],
    };

    blocks.add(block);
  }

  //Accessing Blocks
  // print('Block ${i + 1}:');
  //   print('Units: ${blocks[i]['Units']}');
  //   print('Meters: ${blocks[i]['Meters']}');
  //   print('Previous: ${blocks[i]['Previous']}');
  //   print('Average: ${blocks[i]['Average']}');
  //   print('');
}

// Create a List of Blocks based on the number of items in the Blocks List, i.e. something resebling what's below
final List<String> blocks = <String>[
  'Block 1',
  'Block 2',
  'Block 3',
  'Block 4'
];

class BlocksWidget extends StatefulWidget {
  const BlocksWidget({super.key});
  // Make it take a list as a paramter

  @override
  State<BlocksWidget> createState() => _BlocksWidgetState();
}

class _BlocksWidgetState extends State<BlocksWidget> {
  String dropDownValue = blocks.first;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      initialSelection: blocks.first,
      onSelected: (String? value) {
        // When a user selects an item, call function to display the next block of units on Meter Screen
        // pass back index of selected item to meter screen to be able to show set of next units
        setState(() {
          dropDownValue = value!;
        });
      },
      dropdownMenuEntries:
          blocks.map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(value: value, label: value);
      }).toList(),
    );
  }
}
