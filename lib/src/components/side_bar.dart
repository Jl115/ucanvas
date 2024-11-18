import 'package:flutter/material.dart';

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double width = 200; // Initial width
          return StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: Stack(
                  children: [
                    // Sidebar content
                    Container(
                      width: width.clamp(150.0, 300.0),
                      color: Colors.blueGrey,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.home),
                            title: Text('Home'),
                            onTap: () {
                              // Handle Home tap
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.settings),
                            title: Text('Settings'),
                            onTap: () {
                              // Handle Settings tap
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.logout),
                            title: Text('Logout'),
                            onTap: () {
                              // Handle Logout tap
                            },
                          ),
                        ],
                      ),
                    ),
                    // Drag handle for resizing
                    Positioned(
                      left: width.clamp(150.0, 300.0) - 10,
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            width += details.delta.dx;
                            width = width.clamp(100.0, constraints.maxWidth);
                          });
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.resizeColumn,
                          child: Container(
                            width: 20,
                            height: constraints
                                .maxHeight, // Respect parent's constraints
                            color: Colors.transparent,
                            child: Center(
                                child: Transform.rotate(
                              angle: 90 * 3.1415926535 / 180,
                              child:
                                  Icon(Icons.drag_handle, color: Colors.white),
                            )),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
