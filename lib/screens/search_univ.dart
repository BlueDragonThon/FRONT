import 'package:flutter/material.dart';

class SearchUniv extends StatelessWidget {
  const SearchUniv({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          ],
        ),
      ),
    );
  }
}