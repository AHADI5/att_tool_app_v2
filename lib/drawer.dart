import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});



  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey,
            ),
            child: Column(
              children: <Widget>[

                Icon(
                    Icons.bookmark_added,
                    color: Colors.white ,
                    size: 85,
                ),
                SizedBox(height: 10,) ,
                Text(
                  'ATT-TOOL-APP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('School Years'),
            onTap: () {
// Add your navigation logic here
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const  Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
// Add your navigation logic here
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
