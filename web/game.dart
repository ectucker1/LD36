import 'package:cobblestone/cobblestone.dart';
import 'state.dart';
import 'combat_state.dart';
import 'package:yaml/yaml.dart';
import 'dart:convert';

main() {
  new GameStart();
}

enum GameMode {
  COMBAT, LOOT, FINAL
}

Camera2D fullscreenCamera;
bool running = true;

Map gameData;

Future<Map> loadYAMLAsync(String url) {
  return HttpRequest.getString(url).then((String text) => loadYaml(text));
}

Future<Map> loadJSONAsync(String url) {
  return HttpRequest.getString(url).then((String text) => JSON.decode(text));
}

GameMode mode;

class GameStart extends BaseGame {

  SpriteBatch batch;
  State combatState;

  config() {
    scaleMode = ScaleMode.resize;
  }

  @override
  create() {
    batch = new SpriteBatch.defaultShader();
    fullscreenCamera = new Camera2D.originBottomLeft(width, height);
    combatState = new CombatState(batch);
    combatState.unpause();
    mode = GameMode.COMBAT;
  }

  @override
  preload() {
    assetManager.load("art/combat/sprites.png", loadTexture("art/combat/sprites.png", nearest));
    assetManager.load("art/combat/sprites.json", loadJSONAsync("art/combat/sprites.json"));
    assetManager.load("game.yaml", loadYAMLAsync("game.yaml"));

    assetManager.load("sound/Barel_Death.wav", loadGameSound("sound/Barel_Death.wav"));
    assetManager.load("sound/Barel_Wall_Hit.wav", loadGameSound("sound/Barel_Wall_Hit.wav"));
    assetManager.load("sound/Boss.wav", loadGameSound("sound/Boss.wav"));
    assetManager.load("sound/Bow Twang.wav", loadGameSound("sound/Bow Twang.wav"));
    assetManager.load("sound/Epic Orchestra.wav", loadGameSound("sound/Epic Orchestra.wav"));
    assetManager.load("sound/Giant_Wall_Hit.wav", loadGameSound("sound/Giant_Wall_Hit.wav"));
    assetManager.load("sound/Giant_Death.wav", loadGameSound("sound/Giant_Death.wav"));
    assetManager.load("sound/Mole_Death.wav", loadGameSound("sound/Mole_Death.wav"));
    assetManager.load("sound/Mole_Wall_Hit.wav", loadGameSound("sound/Mole_Wall_Hit.wav"));
    assetManager.load("sound/Peasant_Death.wav", loadGameSound("sound/Peasant_Death.wav"));
    assetManager.load("sound/Peasant_Wall_Hit.wav", loadGameSound("sound/Peasant_Wall_Hit.wav"));
    assetManager.load("sound/ThemeVariation.wav", loadGameSound("sound/ThemeVariation.wav"));
    assetManager.load("sound/TitleScreen.wav", loadGameSound("sound/TitleScreen.wav"));
    assetManager.load("sound/Wall_Crumble.wav", loadGameSound("sound/Wall_Crumble.wav"));
    assetManager.load("sound/World.wav", loadGameSound("sound/World.wav"));
    assetManager.load("sound/Zombie_Death.wav", loadGameSound("sound/Zombie_Death.wav"));
    assetManager.load("sound/Zombie_Wall_Hit.wav", loadGameSound("sound/Zombie_Wall_Hit.wav"));
    assetManager.load("sound/Goblin_Death.wav", loadGameSound("sound/Goblin_Death.wav"));
    assetManager.load("sound/Goblin_Wall_Hit.wav", loadGameSound("sound/Goblin_Wall_Hit.wav"));
    assetManager.load("sound/Knight_Death.wav", loadGameSound("sound/Knight_Death.wav"));
    assetManager.load("sound/Knight_Wall_Hit.wav", loadGameSound("sound/Knight_Wall_Hit.wav"));
  }

  @override
  render(num delta) {
    clearScreen(0, 0, 0, 1);
    batch.projection = fullscreenCamera.combined;
    batch.begin();
    switch (mode) {
      case GameMode.COMBAT:
        combatState.render(delta);
        break;
      case GameMode.LOOT:
        break;
      case GameMode.FINAL:
        break;
    }
  }

  @override
  update(num delta) {
    if(running) {
      fullscreenCamera.update();
      switch (mode) {
        case GameMode.COMBAT:
          combatState.update(delta);
          break;
        case GameMode.LOOT:
          break;
        case GameMode.FINAL:
          break;
      }
    }
  }

  @override
  resize(num width, num height) {
    fullscreenCamera = new Camera2D.originBottomLeft(width, height);
    combatState.resize(width, height);
  }

}