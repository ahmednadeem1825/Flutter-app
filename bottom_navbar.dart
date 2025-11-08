import 'package:flutter/material.dart';

class _BottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const _BottomBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      Icons.menu,
      Icons.folder_open_outlined,
      Icons.public,
      Icons.play_circle_outline,
      Icons.person,
    ];

    return BottomAppBar(
      color: Colors.white,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isSelected = index == selectedIndex;
            final color =
                isSelected ? const Color(0xFFFFD54F) : const Color(0xFF374151);

            return GestureDetector(
              onTap: () => onTap(index),
              child: Icon(items[index], color: color, size: isSelected ? 30 : 26),
            );
          }),
        ),
      ),
    );
  }
}