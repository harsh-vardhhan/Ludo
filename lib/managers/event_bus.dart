class SwitchPointerEvent {}

class BlinkGreenBaseEvent {}

class BlinkBlueBaseEvent {}

class BlinkYellowBaseEvent {}

class BlinkRedBaseEvent {}

class OpenPlayerModalEvent{}

class EventBus {
  static final EventBus _instance = EventBus._internal();

  factory EventBus() {
    return _instance;
  }

  EventBus._internal();

  final Map<Type, List<void Function(dynamic)>> _listeners = {};

  void on<T>(void Function(T event) listener) {
    // Cast the listener to a dynamic function to allow for storing
    _listeners[T] ??= [];
    _listeners[T]!.add(
        (event) => listener(event as T)); // Cast the event to the correct type
  }

  void emit<T>(T event) {
    _listeners[T]?.forEach((listener) => listener(event));
  }
}
