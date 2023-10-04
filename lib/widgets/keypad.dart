import 'package:flutter/material.dart';

class CustomKeypad extends StatefulWidget {
  final Function(String) onKeypadButtonPressed;
  CustomKeypad({required this.onKeypadButtonPressed});

  @override
  _CustomKeypadState createState() => _CustomKeypadState();
}

class _CustomKeypadState extends State<CustomKeypad> {
  TextEditingController _textController = TextEditingController();
  final List<String> keypadButtons = [
    '1', '2', '3',
    '4', '5', '6',
    '7', '8', '9',
    'C', '0', '<', // 'C' for clear, '<' for back
    'Submit'
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      // Center the keypad
      child: Padding(
        padding: EdgeInsets.all(20.0), // Add padding around the keypad
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
          ),
          width: 260,
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: EdgeInsets.all(
                10.0), // Add padding between the container and buttons
            child: GridView.builder(
              itemCount: keypadButtons.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10.0, // Add spacing between buttons
                mainAxisSpacing: 10.0, // Add spacing between buttons
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    widget.onKeypadButtonPressed(keypadButtons[index]);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    alignment: Alignment.center,
                    child: (keypadButtons[index] == 'Submit')
                        ? SizedBox(
                            // Make the Submit button span the width of the container
                            width: double.infinity,
                            child: Text(
                              keypadButtons[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 24.0),
                            ),
                          )
                        : Text(
                            keypadButtons[index],
                            style: TextStyle(fontSize: 24.0),
                          ),
                  ),
                );
              },
            ),
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
