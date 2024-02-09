import 'package:flutter/material.dart';

void showSnackBar({required BuildContext context, required String content}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        content,
        style: const TextStyle(
            color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500),
      ),
      backgroundColor: const Color(0xFFFFFDF4),
    ),
  );
}
