import 'package:flutter/material.dart';
import 'package:ucanvas/src/components/side_bar.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Row(
        children: [SideBar()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add new note
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
