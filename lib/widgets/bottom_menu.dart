import 'package:flutter/material.dart';

class BottomMenu extends StatefulWidget {
  const BottomMenu({
    Key? key,
  }) : super(key: key);

  @override
  State<BottomMenu> createState() => _BottomMenu();
}

class _BottomMenu extends State<BottomMenu> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.wallet_travel),
          label: 'Мои курсы',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          label: 'Вебинары',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.collections_bookmark_rounded),
          label: 'Библиотека',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.new_releases),
          label: 'Заказ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Портал',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.black54,
      unselectedItemColor: Colors.black54,
      selectedLabelStyle: const TextStyle(
        color: Colors.black54,
      ),
      unselectedLabelStyle: const TextStyle(
        color: Colors.black54,
      ),
      showUnselectedLabels: true,
      onTap: (value) {
        setState(() {
          _selectedIndex = value;
        });
        switch (value) {
          case 0:
            Navigator.pushReplacementNamed(context, '/');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/webinars');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/books');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/zakaz');
            break;
          case 4:
            Navigator.pushReplacementNamed(context, '/config');
            break;
        }
      },
    );
  }
}
