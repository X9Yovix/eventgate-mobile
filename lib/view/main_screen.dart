import 'package:eventgate_flutter/utils/auth_provider.dart';
import 'package:eventgate_flutter/view/main/manage_events/manage_events_screen.dart';
import 'package:eventgate_flutter/view/main/recent_events/recent_events_screen.dart';
import 'package:eventgate_flutter/view/main/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    RecentEventsScreen(),
    Text('History'),
    ManageEventsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
        builder: (context, value, child) => Scaffold(
              appBar: AppBar(
                title: const Text('Event Gate'),
              ),
              body: Center(
                child: _widgetOptions.elementAt(_selectedIndex),
              ),
              bottomNavigationBar: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.bolt_outlined),
                    label: 'Recent Events',
                    backgroundColor: Color.fromARGB(255, 44, 2, 51),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history_outlined),
                    label: 'History',
                    backgroundColor: Color.fromARGB(255, 44, 2, 51),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.create_new_folder_outlined),
                    label: 'Manage Events',
                    backgroundColor: Color.fromARGB(255, 44, 2, 51),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.manage_accounts_outlined),
                    label: 'Settings',
                    backgroundColor: Color.fromARGB(255, 44, 2, 51),
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: Colors.amber[800],
                //backgroundColor: Colors.deepPurple,
                onTap: _onItemTapped,
              ),
            ));
  }
}
