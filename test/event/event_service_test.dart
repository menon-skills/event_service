import 'dart:async';

import 'package:event_service/event_service.dart';
import 'package:test/test.dart';

class EventA {
  final int id;
  final String text;

  EventA(this.id, this.text);
}

class EventB {
  final int id;
  final String text;

  EventB(this.id, this.text);
}

class EventAIDFilter implements EventFilter {
  final int filterId;
  EventAIDFilter(this.filterId);

  @override
  bool filter(event) {
    return event is EventA && event.id == filterId;
  }
}

class GenericIDFilter implements EventFilter {
  final int filterId;
  GenericIDFilter(this.filterId);

  @override
  bool filter(event) {
    return event.id == filterId;
  }
}

main() {
  group('event_service', () {
    group('without filter', () {
      test('Publish different events. Listen on no specific type', () async {
        // given
        EventService eventService = LocalEventService();
        Future f = eventService.listen().toList();

        // when
        eventService.publishEvent(EventA(1, 'a1'));
        eventService.publishEvent(EventB(1, 'b1'));
        eventService.publishEvent(EventA(2, 'a2'));
        eventService.publishEvent(EventB(2, 'b2'));
        eventService.destroy();

        // then
        return f.then((events) {
          expect(events.length, 4);
        });
      });

      test('Publish different events. Listen on specific type', () async {
        // given
        EventService eventService = LocalEventService();
        Future fA = eventService.listen<EventA>().toList();
        Future fB = eventService.listen<EventB>().toList();

        // when
        eventService.publishEvent(EventA(1, 'a1'));
        eventService.publishEvent(EventB(1, 'b1'));
        eventService.publishEvent(EventA(2, 'a2'));
        eventService.publishEvent(EventB(2, 'b2'));
        eventService.destroy();

        // then
        return Future.wait([
          fA.then((events) {
            expect(events.length, 2);
          }),
          fB.then((events) {
            expect(events.length, 2);
          })
        ]);
      });
    });
    group('with filter', () {
      test('Publish different events. Listen on no specific type', () async {
        // given
        EventService eventService = LocalEventService();
        Future fA1 = eventService.listen(filter: EventAIDFilter(1)).toList();
        Future f1 = eventService.listen(filter: GenericIDFilter(1)).toList();
        Future f2 = eventService.listen(filter: GenericIDFilter(2)).toList();

        // when
        eventService.publishEvent(EventA(1, 'a1'));
        eventService.publishEvent(EventB(1, 'b1'));
        eventService.publishEvent(EventA(2, 'a2'));
        eventService.publishEvent(EventB(2, 'b2'));
        eventService.destroy();

        // then
        return Future.wait([
          fA1.then((events) {
            expect(events.length, 1);
          }),
          f1.then((events) {
            expect(events.length, 2);
          }),
          f2.then((events) {
            expect(events.length, 2);
          })
        ]);
      });

      test('Publish different events. Listen on specific type', () async {
        // given
        EventService eventService = LocalEventService();
        Future fA = eventService.listen<EventA>(filter: GenericIDFilter(1)).toList();
        Future fB = eventService.listen<EventB>(filter: GenericIDFilter(2)).toList();

        // when
        eventService.publishEvent(EventA(1, 'a1'));
        eventService.publishEvent(EventB(1, 'b1'));
        eventService.publishEvent(EventA(2, 'a2'));
        eventService.publishEvent(EventB(2, 'b2'));
        eventService.destroy();

        // then
        return Future.wait([
          fA.then((events) {
            expect(events.length, 1);
          }),
          fB.then((events) {
            expect(events.length, 1);
          })
        ]);
      });
    });
  });
}
