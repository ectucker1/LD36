import 'package:cobblestone/cobblestone.dart';

class Arrow {

  GameTexture texture;

  Vector2 position;
  Vector2 velocity;
  num angleRad;
  int arrowWidth = 14;
  int arrowHeight = 3;
  num scale;

  num get x => position.x;
  num get y => position.y;

  Vector3 center;
  Vector3 extents;
  Obb3 bound;

  bool moving = true;

  num damage = 5;
  num speed = 300;
  num drawback = 1;

  Arrow(this.position, this.angleRad, this.texture, this.scale) {
    arrowWidth *= scale;
    arrowHeight *= scale;
    velocity = new Vector2.all(0.0);
    angle = angleRad;
    center = new Vector3(x + arrowWidth, y + arrowHeight, 0.0);
    extents = new Vector3(arrowWidth.toDouble() / 2, arrowHeight.toDouble() / 2, 10.0);
    bound = new Obb3();
    updateBounds();
  }

  update(delta) {
    if(moving) {
      position.x += delta * speed * drawback * velocity.x;
      position.y += delta * speed * drawback * velocity.y;
    }
    if(y <= 25) {
      moving = false;
    }
    center.setValues(x + arrowWidth / 2, y + arrowHeight / 2, 0.0);
    updateBounds();
  }

  updateBounds() {
    bound
      ..center.setFrom(center)
      ..halfExtents.setFrom(extents)
      ..resetRotation()
      ..rotate(new Matrix3.rotationZ(angleRad));
  }

  void set angle(num angle) {
    this.angleRad = angle;
    velocity.x = cos(angle);
    velocity.y = sin(angle);
  }

  num get angle => angleRad;

}