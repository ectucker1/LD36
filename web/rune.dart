import 'player.dart';
import 'dart:math';

class Rune {

  num fire = 0; //dps
  num poison = 0; //dps
  num projSpeed = 0; //mod
  num rateOfFire = 0; //mod
  num damage = 0; //mod

  String description;
  String imgSrc;

  Rune.random() {
    Random rand = new Random();
    switch(rand.nextInt(5)) {
      case 0:
        fire = rand.nextInt(12) + 1;
        description = "+$fire Fire Damage";
        imgSrc = "art/runes/Ruin_Fire.png";
        break;
      case 1:
        poison = rand.nextInt(12) + 1;
        description = "+$poison Poison Damage";
        imgSrc = "art/runes/Ruin_Poision.png";
        break;
      case 2:
        damage = rand.nextInt(8) + 1;
        description = "+$damage Damage";
        imgSrc = "art/runes/Ruin_Power.png";
        break;
      case 3:
        projSpeed = rand.nextInt(40) + 1;
        description = "+$projSpeed% Projectile Speed";
        imgSrc = "art/runes/Ruin_Proj_Speed.png";
        break;
      case 4:
        rateOfFire = rand.nextInt(40) + 1;
        description = "+$rateOfFire% Draw Speed";
        imgSrc = "art/runes/Ruin_Rate_of_Fire.png";
        break;
    }
  }

  void giveToPlayer(Player player) {
    player.fire += fire;
    player.poison += poison;
    player.projSpeed += projSpeed / 100;
    player.rateOfFire += rateOfFire / 100;
    player.damage += damage;
  }

}