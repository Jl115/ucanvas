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
                    // Sidebar header
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        height: 40,
                        width: width.clamp(150.0, 300.0),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          border: Border(
                            bottom: BorderSide(color: Colors.white),
                          ),
                        ),
                        child: Container(
                          color: Colors.blueGrey,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.menu, color: Colors.white),
                                Icon(Icons.menu, color: Colors.white),
                                Icon(Icons.menu, color: Colors.white),
                                Icon(Icons.menu, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Reorderable content
                    Positioned(
                      top: 40, // Offset below the header
                      child: Container(
                        width: width.clamp(150.0, 300.0),
                        height: constraints.maxHeight - 40, // Remaining height
                        color: Colors.blueGrey,
                        child: ReorderableListView(
                          padding: EdgeInsets.zero,
                          onReorder: (int oldIndex, int newIndex) {
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }
                            setState(() {
                              // Logic to reorder items
                              final item = _items.removeAt(oldIndex);
                              _items.insert(newIndex, item);
                            });
                          },
                          children: [
                            for (int index = 0; index < _items.length; index++)
                              ListTile(
                                key: ValueKey(_items[index]),
                                leading: Icon(_items[index]['icon']),
                                title: Text(_items[index]['title']),
                                onTap: _items[index]['onTap'],
                              ),
                          ],
                        ),
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
                            height: constraints.maxHeight,
                            color: Colors.transparent,
                            child: Center(
                              child: Transform.rotate(
                                angle: 90 * 3.1415926535 / 180,
                                child: Icon(Icons.drag_handle,
                                    color: Colors.white),
                              ),
                            ),
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

// Sample items for the sidebar
final List<Map<String, dynamic>> _items = [
  {
    'icon': Icons.home,
    'title': 'Home',
    'onTap': () {
      // Handle Home tap
    },
  },
  {
    'icon': Icons.settings,
    'title': 'Settings',
    'onTap': () {
      // Handle Settings tap
    },
  },
  {
    'icon': Icons.logout,
    'title': 'Logout',
    'onTap': () {
      // Handle Logout tap
    },
  },
];
