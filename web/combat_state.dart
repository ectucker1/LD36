import 'state.dart';
import 'package:cobblestone/cobblestone.dart';
import 'arrow.dart';
import 'enemy.dart';
import 'game.dart';
import 'texture_pack.dart';
import 'player.dart';
import 'rune.dart';

class CombatState extends State {

  SpriteBatch batch;
  TexturePack textures;

  num scale;

  int guyFrame = 1;
  int bowFrame = 1;

  Vector2 arrowLook;
  List<StreamSubscription> subscriptions;

  Arrow drawing;
  List<Arrow> arrows;

  List<Enemy> enemies;

  num drawTime = 0;

  Map gameData;
  Map<String, Enemy> enemyTemplates;
  num waveTime = 0;
  List<num> timesPlaced;

  num castleHealth = 100;

  List<Enemy> toRemoveE = [];
  List<Arrow> toRemoveA = [];

  int currentWave = 9;
  bool upgrading = false;

  Player player = new Player();
  List<Rune> runeOptions;

  Sound bowTwang;

  Sound exploring;
  Sound world;
  Sound finalWave;

  bool defeat = false;

  CombatState(this.batch) {
    textures = new TexturePack(assetManager.get("art/combat/sprites.png"), assetManager.get("art/combat/sprites.json"));
    scale = height / 200;

    gameData = assetManager.get("game.yaml");
    enemyTemplates = new Map();
    for(Map map in gameData['enemies']) {
      List<GameTexture> enemyTextures = [];
      for(String tex in map['texture']) {
        enemyTextures.add(textures[tex]);
        if(textures[tex] == null) {
          print(tex);
        }
      }
      Enemy enemy = new Enemy(new Vector2(width.toDouble(), 5 * scale), enemyTextures, map['animSpeed'], scale, assetManager.get(map['attackSfx']), assetManager.get(map['deathSfx']))
        ..health = map['health']
        ..speed = map['speed']
        ..damage = map['damage'];
      enemyTemplates[map['name']] = enemy;
    }

    arrows = [];
    enemies = [];
    timesPlaced = [];
    runeOptions = [];

    arrowLook = new Vector2(0.0, 0.0);
    subscriptions = [];

    updateWaveHTML();

    querySelector("#rune0").onClick.listen(selectRune0);
    querySelector("#rune1").onClick.listen(selectRune1);
    querySelector("#rune2").onClick.listen(selectRune1);

    querySelector("#loading").style.opacity = "0";

    bowTwang = assetManager.get("sound/Bow Twang.wav");

    world = assetManager.get("sound/Epic Orchestra.wav");
    exploring = assetManager.get("sound/World.wav");
    finalWave = assetManager.get("sound/Boss.wav");
    startWaveMusic();
  }

  selectRune0(MouseEvent e) {
    if(upgrading) {
      upgrading = false;
      runeOptions[0].giveToPlayer(player);
      updateWaveHTML();
      exploring.stop();
      startWaveMusic();
    }
  }

  selectRune1(MouseEvent e) {
    if(upgrading) {
      upgrading = false;
      runeOptions[1].giveToPlayer(player);
      updateWaveHTML();
      exploring.stop();
      startWaveMusic();
    }
  }

  selectRune2(MouseEvent e) {
    if(upgrading) {
      upgrading = false;
      runeOptions[2].giveToPlayer(player);
      updateWaveHTML();
      exploring.stop();
      startWaveMusic();
    }
  }

  startWaveMusic() {
    if(currentWave >= gameData['numWaves'] - 1) {
      finalWave.loop();
    } else {
      world.loop();
    }
  }

  @override
  render(num delta) {
    clearScreen(72 / 256, 178 / 256, 255 / 256, 1.0);
    batch.draw(textures['Backround.png'], 0, 0, scaleX: scale, scaleY: scale);

    if(castleHealth >= 75) {
      batch.draw(textures['wall_1.png'], 0, 0, scaleX: scale, scaleY: scale);
    } else {
      int wallTex = 4 - (castleHealth / 25).floor();
      if(wallTex > 4) {
        wallTex = 4;
      }
      batch.draw(textures['wall_$wallTex.png'], 0, 0, scaleX: scale, scaleY: scale);
    }
    for(int i = 0; i < (width / (scale * 32)); i++) {
      batch.draw(textures['ground_1.png'], i * scale * 32, 0, scaleX: scale, scaleY: scale);
    }

    num bowAngle = 0;
    if(drawing != null) {
      bowAngle = drawing.angleRad;
    }
    batch.draw(textures["bow_$bowFrame.png"], 30 * scale, 115 * scale, scaleX: scale, scaleY: scale, angle: bowAngle);

    batch.draw(textures["Archer_$guyFrame.png"], 10 * scale, 90 * scale, scaleX: scale, scaleY: scale);

    for(Enemy enemy in enemies) {
      if(enemy != null) {
        batch.draw(
            enemy.texture, enemy.x, enemy.y, scaleX: scale, scaleY: scale);
      }
    }

    for(Arrow arrowData in arrows) {
      batch.draw(arrowData.texture, arrowData.x, arrowData.y, scaleX: scale, scaleY: scale, angle: arrowData.angle);
    }
    if(drawing != null) {
      batch.draw(drawing.texture, drawing.x, drawing.y, scaleX: scale, scaleY: scale, angle: drawing.angle);
    }

    batch.draw(textures['healthbar.png'], 8 * scale, 140 * scale, scaleX: scale, scaleY: scale);
  }

  @override
  resize(num width, num height) {
    scale = height / 200;
  }

  @override
  update(num delta) {
    turnDrawing();
    if(drawing != null) {
      drawTime += delta * player.rateOfFire;
      if (drawTime > 3) {
        drawTime = 3;
        guyFrame = 4;
        bowFrame = 2;
      } else {
        guyFrame = drawTime.floor() + 1;
        bowFrame = 1;
      }
      if (drawing == null) {
        drawTime = 0;
      }
    }

    for(Enemy enemy in enemies) {
      enemy.update(delta);
      if(enemy.attack) {
        castleHealth -= enemy.damage;
        if(castleHealth <= 0) {
          castleHealth = 0;
        }
        enemy.attackSfx.play();
        toRemoveE.add(enemy);
      }
    }
    toRemoveE.add(null);
    for(Enemy enemy in toRemoveE) {
      enemies.remove(enemy);
    }
    toRemoveE.clear();

    for(Arrow arrowData in arrows) {
      arrowData.update(delta);
      if(arrowData.x < 0 || arrowData.y > height || arrowData.x > width) {
        toRemoveA.add(arrowData);
      }
      for(Enemy enemy in enemies) {
        if(arrowData.bound.intersectsWithObb3(enemy.bound) && !toRemoveA.contains(arrowData) && arrowData.moving) {
          player.applyToEnemy(enemy, arrowData.drawback);
          if(enemy.health <= 0) {
            if(!toRemoveE.contains(enemy)) {
              enemy.dieSfx.play();
            }
            toRemoveE.add(enemy);
          }
          toRemoveA.add(arrowData);
        }
      }
    }

    for(Enemy enemy in toRemoveE) {
      enemies.remove(enemy);
    }
    toRemoveE.clear();
    for(Arrow arrowData in toRemoveA) {
      arrows.remove(arrowData);
    }
    toRemoveA.clear();

    if(!upgrading) {
      waveTime += delta;
    }
    bool enemiesLeft = false;
    for(Map enemy in gameData["waves"][currentWave]['enemies']) {
      if(enemy['time'] <= waveTime && !timesPlaced.contains(enemy['time'])) {
        enemies.add(new Enemy.copy(enemyTemplates[enemy['type']]));
        timesPlaced.add(enemy['time']);
      } else if(!timesPlaced.contains(enemy['time'])) {
        enemiesLeft = true;
      }
    }

    textures['healthbar.png'].setRegionCoords(textures['healthbar.png'].u, textures['healthbar.png'].v, ((castleHealth / 100) * 32).floor() / textures['healthbar.png'].sourceWidth, textures['healthbar.png'].v2);
    //print(((castleHealth / 100) * 32).floor());
    if(castleHealth <= 0) {
      updateWaveHTML();
      running = false;
      defeat = true;
    }

    if(waveTime >= 2 && castleHealth > 0) {
      Element element = querySelector("#message");
      element.style.opacity = "0";
    }
    if(!enemiesLeft && enemies.isEmpty && !defeat) {
      world.stop();
      if(currentWave + 1 < gameData['numWaves']) {
        exploring.loop();
      }
      waveTime = 0;
      currentWave++;
      castleHealth += 50;
      if(castleHealth > 100) {
        castleHealth = 100;
      }
      upgrading = true;
      updateWaveHTML();
    }
  }

  updateWaveHTML() {
    Element waveNum = querySelector("#waveCount");
    int waveDisplay = currentWave + 1;
    waveNum.text = "Wave: $waveDisplay / 10";

    if(waveDisplay > gameData['numWaves']) {
      upgrading = false;
    }

    Element runeContainer = querySelector("#runes");
    if(upgrading) {
      makeRunes();
      runeContainer.style.opacity = "1.0";
    } else {
      runeContainer.style.opacity = "0";

      Element message = querySelector("#message");
      message.style.opacity = "1.0";
      message.text = "Wave $waveDisplay Begins";
      if(waveDisplay > gameData['numWaves']) {
        message.text = "Victory!";
        waveNum.style.opacity = "0";
        running = false;
      }
      if(castleHealth <= 0) {
        message.text = "Defeat";
        message.style.opacity = "1.0";
        waveNum.style.opacity = "0";
      }
    }
  }

  makeRunes() {
    runeOptions.clear();
    for(int i = 0; i < 3; i++) {
      runeOptions.add(new Rune.random());
      ImageElement runeImg = querySelector("#runeImg$i");
      runeImg.src = runeOptions[i].imgSrc;

      Element runeDesc = querySelector("#runeDesc$i");
      runeDesc.text = runeOptions[i].description;
    }
  }

  turnDrawing() {
    if(drawing != null) {
      num distX = arrowLook.x - drawing.x;
      num distY = arrowLook.y - drawing.y;

      num angleRadians = atan2(distY, distX);
      num angleDegrees = degrees(angleRadians);

      drawing.angle = radians((360 - angleDegrees) - 17);
    }
  }

  fireArrow(MouseEvent event) {
      arrowLook.x = event.client.x.toDouble();
      arrowLook.y = event.client.y.toDouble();
      turnDrawing();

      drawing.drawback = (drawTime + 1);
      drawTime = 0;

      arrows.add(drawing);
      drawing = null;

      guyFrame = 4;
      bowFrame = 1;

      bowTwang.play();
  }

  drawArrow(MouseEvent event) {
    arrowLook.x = event.client.x.toDouble();
    arrowLook.y = event.client.y.toDouble();

    drawing = new Arrow(new Vector2(30 * scale, 125 * scale), 0, textures['Arrow.png'], scale)
      ..speed *= player.projSpeed;

    drawTime = 0;
    guyFrame = 1;
  }

  turnArrow(MouseEvent event) {
    arrowLook.x = event.client.x.toDouble();
    arrowLook.y = event.client.y.toDouble();
  }

  @override
  pause() {
    for(StreamSubscription subscription in subscriptions) {
      subscription.cancel();
    }
  }

  @override
  unpause() {
    subscriptions.add(document.onMouseDown.listen(drawArrow));
    subscriptions.add(document.onMouseUp.listen(fireArrow));
    subscriptions.add(document.onMouseMove.listen(turnArrow));
  }

}