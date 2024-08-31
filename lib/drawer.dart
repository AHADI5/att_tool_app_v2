import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import 'Features/Attendance/Services/synchronisation.dart';
import 'error_page.dart';

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
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.school),
            title: Text('School Years'),
            onTap: () {
// Add your navigation logic here
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
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
