import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../utils/utils.dart';

class ErrorView extends StatelessWidget {
  final String       message;
  final VoidCallback onRetry;   // ← new

  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

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
            Text(
              message,
              style: TextStyle(
                  color: C.grey, fontSize: R.font(context, 14)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // ── Retry Button ──────────────────────────────────
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  color: C.accent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Try Again',
                  style: TextStyle(
                    color: C.white,
                    fontSize: R.font(context, 14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}