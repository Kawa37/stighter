import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:stighter/components/collision_block.dart';
import 'package:stighter/components/utils.dart';
import 'package:stighter/stighter.dart';

enum PlayerState { idle, running, jumping, falling }

class Player extends SpriteAnimationGroupComponent
    with HasGameReference<Stighter>, KeyboardHandler {
  String character;
  Player({this.character = 'Mask Dude', position}) : super(position: position);

  final double stepTime = .05;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;

  final double _gravity = 9.8;
  final double _jumpForce = 260;
  final double _terminalVel = 300;
  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 vel = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];
  bool isOnGround = false;
  bool hasJumped = false;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    debugMode = true;
    return super.onLoad();
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);
    runningAnimation = _spriteAnimation('Run', 12);
    jumpingAnimation = _spriteAnimation('Fall', 1);
    fallingAnimation = _spriteAnimation('Jump', 1);

    // list all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
    };
    // set current animation
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) =>
      SpriteAnimation.fromFrameData(
        game.images.fromCache('Main Characters/$character/$state (32x32).png'),
        SpriteAnimationData.sequenced(
          amount: amount,
          stepTime: stepTime,
          textureSize: Vector2.all(32),
        ),
      );

  @override
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerMovement(dt);
    _checkHorizontalCollisions();
    _applyGravity(dt);
    _checkVertCollisions();
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    return super.onKeyEvent(event, keysPressed);
  }

  void _updatePlayerMovement(double dt) {
    vel.x = horizontalMovement * moveSpeed;
    if (hasJumped && isOnGround) _playerJump(dt);

    if (vel.y > _gravity) {
      isOnGround = false;
    }

    position.x += vel.x * dt;
  }

  void _playerJump(double dt) {
    vel.y = -_jumpForce;
    position.y += vel.y * dt;
    hasJumped = false;
    isOnGround = false;
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;
    if (vel.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (vel.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    if (vel.x > 0 || vel.x < 0) {
      playerState = PlayerState.running;
    }

    if (vel.y > _gravity) {
      playerState = PlayerState.falling;
    }

    if (vel.y < 0) {
      playerState = PlayerState.jumping;
    }

    current = playerState;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (vel.x > 0) {
            vel.x = 0;
            position.x = block.x - width;
            break;
          } else if (vel.x < 0) {
            vel.x = 0;
            position.x = block.x + block.width + width;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    vel.y += _gravity;
    vel.y = vel.y.clamp(-_jumpForce, _terminalVel);
    position.y += vel.y * dt;
  }

  void _checkVertCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (vel.y + width > 0 && checkCollision(this, block)) {
          // if (checkCollision(this, block)) {
          vel.y = 0;
          position.y = block.y - width;
          isOnGround = true;
          break;
          // }
        }
      } else {
        if (checkCollision(this, block)) {
          if (vel.y > 0) {
            vel.y = 0;
            position.y = block.y - width;
            isOnGround = true;
            break;
          } else if (vel.y < 0) {
            vel.y = 0;
            position.y = block.y + block.height;
          }
        }
      }
    }
  }
}
