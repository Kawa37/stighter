import 'package:stighter/components/collision_block.dart';
import 'package:stighter/components/player.dart';

bool checkCollision(Player player, CollisionBlock block) {
  final playerX = player.position.x;
  final playerY = player.position.y;
  final playerWidth = player.width;
  final playerHeight = player.height;

  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  final fixX = player.scale.x < 0 ? playerX - playerWidth : playerX;
  final fixY = block.isPlatform ? playerY + playerHeight : playerY;

  return (fixY < blockY + blockHeight &&
      playerY + playerHeight > blockY &&
      fixX < blockX + blockWidth &&
      fixX + playerWidth > blockX);
}
