import 'event_filter.dart';

abstract class EventService {
  Stream<T> listen<T>({EventFilter filter});

  void publishEvent(event);

  void destroy();
}
