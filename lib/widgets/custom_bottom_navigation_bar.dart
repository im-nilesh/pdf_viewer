// custom_bottom_navigation_bar.dart

import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final Function(int) onTap;
  final int currentIndex;

  const CustomBottomNavigationBar({
    Key? key,
    required this.onTap,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80, // Adjust height as needed
      color: Colors.black, // Change color as needed
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            onPressed: () => onTap(0),
            child: const Text('Home', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: currentIndex == 0 ? Colors.white : Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(0), // Adjust border radius as needed
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => onTap(1),
            child:
                const Text('List View', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: currentIndex == 1 ? Colors.white : Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(0), // Adjust border radius as needed
              ),
            ),
          ),
        ],
      ),
    );
  }
}
