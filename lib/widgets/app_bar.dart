import 'package:flutter/material.dart';

class Bar extends StatefulWidget {
  final String? screenTitle;
  const Bar({Key? key, required this.screenTitle}) : super(key: key);

  @override
  State<Bar> createState() => _BarState();
}

class _BarState extends State<Bar> {
  late String _displayText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _displayText = widget.screenTitle ?? 'Another Screen';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Align children to the left
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0),
          child: Image.asset(
            'assets/images/imiziLogo.jpg',
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: SizedBox(
            height: 24,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Text(
            _displayText,
            style: const TextStyle(
                color: Color.fromARGB(255, 150, 137, 28),
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: SizedBox(
            height: 24,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 16.0, right: 16.0),
          child: Divider(
            height: 6.0,
            color: Color.fromARGB(255, 150, 137, 28),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }
}

// widget_list.dart

// import 'package:flutter/material.dart';

// class WidgetList {
//   static List<Widget> widgets = [
//     Text('Widget 1'),
//     Text('Widget 2'),
//     Text('Widget 3'),
//   ];
// }

// main.dart

// import 'package:flutter/material.dart';
// import 'widget_list.dart'; // Import the file with the list of widgets

// void main() {
//   runApp(MaterialApp(
//     home: Scaffold(
//       appBar: AppBar(
//         title: Text('Widgets from Another File'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: WidgetList.widgets, // Access the list of widgets
//         ),
//       ),
//     ),
//   ));
// }

