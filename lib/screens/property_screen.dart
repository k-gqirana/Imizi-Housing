import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';

class PropertyScreen extends StatelessWidget {
  // Replace this with SQL data
  final List<String> sqlData = [
    "Project 1",
    "Project 2",
    "Project 3",
    "Project 4"
  ];

  PropertyScreen({super.key});

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
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(left: 48.0),
                  itemCount: sqlData.length,
                  itemBuilder: (context, index) {
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
                              print("Pressed ${sqlData[index]}");
                            },
                            child: Text(
                              sqlData[index],
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
