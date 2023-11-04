import 'package:flutter/material.dart';

class QRPayPage extends StatelessWidget {
  const QRPayPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Pay'),
      ),
      body: const Center(
          child: Text('QR Pay', style: TextStyle(fontSize: 32.0))),
    );
  }
}