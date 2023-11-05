import 'package:flutter/material.dart';

class QRPayPage extends StatelessWidget {
  const QRPayPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Column(
          children: [
            Container(
              child: Image.network(
                'https://qr.quel.jp/tmp/51b340dcabb40bc25c9cb4d87852ab112ec07ccb.png',
                height: 200, // 画像の高さを調整
              ),
            ),
            Container(
              child: Text(
                'QR Pay',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Container(
              child: Image.network(
                'https://senbero-image.s3.ap-northeast-1.amazonaws.com/ticket.jpg',
                height: 200, // 画像の高さを調整
              ),
            ),
            Container(
              child: Text(
                'Your flight ticket.',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
      )
    );
  }
}