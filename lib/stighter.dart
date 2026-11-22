import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/image_composition.dart';
import 'package:stighter/levels/level.dart';

class Stighter extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFF211F30);

  late final CameraComponent cam;
  final myWorld = Level(levelName: 'level-02');

  @override
  FutureOr<void> onLoad() async {
    //into cache
    await images.loadAllImages();
    cam = CameraComponent.withFixedResolution(
      width: 640,
      height: 360,
      world: myWorld,
    );
    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam, myWorld]);

    return super.onLoad();
  }
}
