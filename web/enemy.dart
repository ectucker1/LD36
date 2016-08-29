import 'package:cobblestone/cobblestone.dart';

class Enemy {

  List<GameTexture> textures;
  GameTexture texture;
  num frame = 0;
  num frameSpeed = 4;

  Vector2 position;
  num enemyWidth = 0;
  num enemyHeight = 0;
  num scale;

  bool moving = true;

  Vector3 center;
  Vector3 extents;
  Obb3 bound;

  bool attack = false;

  num damage = 5;
  num health = 10;
  num speed = 100;

  Sound attackSfx;
  Sound dieSfx;

  Enemy(this.position, this.textures, this.frameSpeed, this.scale, this.attackSfx, this.dieSfx) {
    this.texture = textures[frame.floor()];
    enemyWidth = textures[0].width * scale;
    enemyHeight = textures[0].height * scale;
    bound = new Obb3();
    updateBounds();
  }

  Enemy.copy(Enemy template) {
    if(template == null) {
      print("Null template!");
    }

    enemyWidth = template.enemyWidth;
    enemyHeight = template.enemyHeight;
    this.position = template.position.clone();
    this.textures = template.textures;
    this.texture = template.texture;
    this.frameSpeed = template.frameSpeed;
    this.scale = template.scale;

    bound = new Obb3();
    updateBounds();

    this.damage = template.damage;
    this.health = template.health;
    this.speed = template.speed;

    this.attackSfx = template.attackSfx;
    this.dieSfx = template.dieSfx;

    this.frame = 0;
  }

  updateBounds() {
    center = new Vector3(x + enemyWidth / 2, y + enemyHeight / 2, 0.0);
    extents = new Vector3(enemyWidth.toDouble() / 2, enemyHeight.toDouble() / 2, 0.0);
    bound
      ..center.setFrom(center)
      ..halfExtents.setFrom(extents);
  }

  update(delta) {
    if(moving) {
      position.x -= delta * speed;
    }
    if(position.x <= 32 * scale) {
      attack = true;
    }
    updateBounds();

    frame += delta * frameSpeed;
    if(frame.floor() >= textures.length) {
      frame = 0;
    }
    texture = textures[frame.floor()];
  }

  num get x => position.x;
  num get y => position.y;

}