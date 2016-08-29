import 'package:cobblestone/cobblestone.dart';

class TexturePack {

  GameTexture atlas;
  Map atlasDesc;

  Map<String, GameTexture> textures;

  operator [](String name) => textures[name];
  operator []=(String name, GameTexture value) => textures[name] = value;

  TexturePack(this.atlas, this.atlasDesc) {
    textures = new Map();
    atlasDesc['frames'].forEach((k,v) => textures[k] = new GameTexture.clone(atlas)
      ..setRegion(atlasDesc['frames'][k]['frame']['x'], atlas.height - atlasDesc['frames'][k]['frame']['y'] - atlasDesc['frames'][k]['frame']['h'], atlasDesc['frames'][k]['frame']['w'], atlasDesc['frames'][k]['frame']['h']));
  }

}