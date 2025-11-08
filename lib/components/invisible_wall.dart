import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'body_component_with_user_data.dart';
import 'player.dart';

class InvisibleWall extends BodyComponentWithUserData with ContactCallbacks {
  InvisibleWall({
    required Vector2 position,
    required Vector2 size,
  }) : super(
          renderBody: false,
          bodyDef: BodyDef()
            ..position = position
            ..type = BodyType.static,
          fixtureDefs: [
            FixtureDef(
              PolygonShape()..setAsBoxXY(size.x / 2, size.y / 2),
              friction: 0.3,
            ),
          ],
        );

  @override
  void beginContact(Object other, Contact contact) {
    // Si el que toca es el jugador, desactivar la colisión
    if (other is Player) {
      contact.isEnabled = false;
    }
    super.beginContact(other, contact);
  }
}