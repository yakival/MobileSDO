import 'package:flutter/material.dart';

class LeftMenu extends StatefulWidget {
  const LeftMenu({
    Key? key,
  }) : super(key: key);

  @override
  State<LeftMenu> createState() => _LeftMenu();
}

class _LeftMenu extends State<LeftMenu> {
  @override
  void initState() {
    super.initState();
  }

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Меню',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Список курсов'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.content_copy),
            title: const Text('Загрузить оглавление'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/syncCourses');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Портал'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/config');
            },
          ),
        ],
      ),
    );
  }
}
