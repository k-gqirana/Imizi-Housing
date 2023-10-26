import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imiziappthemed/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersive); // removing top and bottom bar

    Future.delayed(const Duration(seconds: 4), () {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        // gradient: LinearGradient(
        //   colors: [Colors.lime, Colors.orange],
        //   begin: Alignment.topRight,
        //   end: Alignment.bottomLeft,
        // ),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Image.asset('assets/images/imiziLogo.jpg'),
        const SizedBox(
          height: 20,
        ),
        const Text(
          'Imizi Housing',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Color.fromARGB(255, 166, 160, 55),
            fontSize: 32,
          ),
        ),
      ]),
    ));
  }
}
