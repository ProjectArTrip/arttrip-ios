import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ArtTripText.pretendard().body01Bold().build().text('옥승철: 프로토타입 PROTOTYPE'),
            ArtTripText.pretendard().body01Light().build().text('옥승철: 프로토타입 PROTOTYPE'),
            ArtTripText.pretendard().title01Bold().build().text('옥승철: 프로토타입 PROTOTYPE'),
            ArtTripText.pretendard().title02Bold().build().text('옥승철: 프로토타입 PROTOTYPE'),
            ArtTripText.pretendard().body03Regular().build().text('옥승철: 프로토타입 PROTOTYPE'),
            ArtTripText.pretendard().headline().build().text('옥승철: 프로토타입 PROTOTYPE'),
          ],
        ),
      ),
    );
  }
}
