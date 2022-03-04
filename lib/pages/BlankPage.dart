import 'package:flutter/material.dart';

import '../widgets/left_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //int _counter = 0;

  @override
  void initState() {
    super.initState();
  }

  //void _incrementCounter() async {
  //  setState(() {
  //    _counter++;
  //  });
  //}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная страница'),
      ),
      drawer: const LeftMenu(),
    );
  }
}
