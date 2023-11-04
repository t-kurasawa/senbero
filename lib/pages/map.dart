import 'package:flutter/material.dart';

class MapPage extends StatelessWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('マップ'),
      ),
      body: const Center(
          child: Text('マップ画面', style: TextStyle(fontSize: 32.0))),
    );
  }
}