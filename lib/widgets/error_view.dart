import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../utils/utils.dart';

class ErrorView extends StatelessWidget {
  final String message;
  const ErrorView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, color: C.muted, size: 68),
            const SizedBox(height: 14),
            Text(message,
                style: TextStyle(
                    color: C.grey, fontSize: R.font(context, 14)),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}