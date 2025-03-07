import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'view/splash.dart';

void main() async {
  // Make sure all plugins are initialized before runApp()
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const majorapp());
}

class majorapp extends StatelessWidget {
  const majorapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'hey, you there?',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(),
    );
  }
}
