import 'enemy.dart';

class Player {

  num fire = 0;
  num poison = 0;
  num projSpeed = 1;
  num rateOfFire = 1;
  num damage = 5;

  Player();

  void applyToEnemy(Enemy enemy, num drawback) {
    enemy.health -= damage * drawback + fire + poison;
  }

}