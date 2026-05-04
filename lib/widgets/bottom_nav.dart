import 'package:flutter/material.dart';
import '../constants/constants.dart';

class BottomNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;
  const BottomNav({super.key, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      color: C.card,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: Dims.dividerWidth, color: C.divider),
          Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10 + bottom),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _item(context, 0, Icons.home_rounded),
                _item(context, 1, Icons.search_rounded),
                _item(context, 2, Icons.notifications_none_rounded),
                _item(context, 3, Icons.map_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext ctx, int i, IconData icon) {
    final sel = selected == i;
    return GestureDetector(
      onTap: () => onTap(i),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        height: Dims.navHeight,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: sel ? C.accent.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: sel ? C.accent : C.muted, size: 26),
          ),
        ),
      ),
    );
  }
}