import 'dart:async';

import '../event_filter.dart';
import '../event_service.dart';

class LocalEventService implements EventService {
  final StreamController _eventController;

  LocalEventService({bool sync = false})
      : _eventController = StreamController.broadcast(sync: sync);

  LocalEventService.customController(StreamController controller)
      : _eventController = controller;

  @override
  Stream<T> listen<T>({EventFilter filter}) {
    return _eventController.stream
        .where((event) =>
            event is T && (filter != null ? filter.filter(event) : true))
        .cast<T>();
  }

  @override
  void publishEvent(event) {
    _eventController.add(event);
  }

  @override
  void destroy() {
    _eventController.close();
  }
}
