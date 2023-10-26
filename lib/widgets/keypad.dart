import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CustomKeypad extends StatefulWidget {
  final Function(String) onKeypadButtonPressed;
  CustomKeypad({required this.onKeypadButtonPressed});

  @override
  // ignore: library_private_types_in_public_api
  _CustomKeypadState createState() => _CustomKeypadState();
}

class _CustomKeypadState extends State<CustomKeypad> {
  TextEditingController _textController = TextEditingController();
  final List<String> keypadButtons = [
    '1', '2', '3',
    '4', '5', '6',
    '7', '8', '9',
    'C', '0', '<', // 'C' for clear, '<' for back
    // 'Submit'
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          decoration: const BoxDecoration(
            // border: Border.all(color: Colors.black),
            color: Colors.white,
          ),
          width: 320,
          height: MediaQuery.of(context).size.height * 0.65,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: CupertinoTextField(
                  controller: _textController,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  cursorColor: Colors.black,
                  style: TextStyle(fontSize: 16),
                  padding: const EdgeInsets.only(
                      top: 8, bottom: 8, left: 8, right: 4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: keypadButtons.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 14.0,
                    mainAxisSpacing: 14.0,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        onKeypadButtonPressed(keypadButtons[index]);
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          // border: Border.all(color: Colors.black),
                          color: Color.fromARGB(255, 166, 160, 55),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          keypadButtons[index],
                          style: const TextStyle(
                              fontSize: 34.0, color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
                child: Container(
                  height: 45.0,
                  child: ElevatedButton(
                    onPressed: () {
                      onKeypadButtonPressed('Submit');
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 207, 119, 40),
                      shape: const RoundedRectangleBorder(),
                    ),
                    child: const Center(
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 24.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onKeypadButtonPressed(String buttonText) {
    if (buttonText == 'C') {
      _textController.clear();
    } else if (buttonText == '<') {
      if (_textController.text.isNotEmpty) {
        setState(() {
          _textController.text = _textController.text
              .substring(0, _textController.text.length - 1);
        });
      }
    } else if (buttonText == 'Submit') {
      // Handle submit button press, e.g., save the input text
      String enteredText = _textController.text;
      print('Entered Text: $enteredText');

      // Call the callback to update the CupertinoTextField value
      widget.onKeypadButtonPressed(enteredText);

      // Close the keypad widget
      Navigator.of(context).pop();
    } else {
      setState(() {
        _textController.text += buttonText;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}


// void main() {
//   runApp(MaterialApp(
//     home: Scaffold(
//       appBar: AppBar(
//         title: Text('Custom Keypad Example'),
//       ),
//       body: CustomKeypad(
//         onKeypadButtonPressed: (text) {
//           print('Text entered: $text');
//         },
//       ),
//     ),
//   ));
// }





