import 'package:cobblestone/cobblestone.dart';

abstract class State {

  update(num delta);

  render(num delta);

  resize(num width, num height);

  pause();

  unpause();

}