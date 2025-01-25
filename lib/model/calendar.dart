import 'package:memorize_up/model/database.dart';
import 'package:uuid/uuid.dart';
 
class Event {

  String id;
  DateTime date;
  String setId;

  Event({required this.id, required this.date, required this.setId});

  factory Event.fromMap(Map data) {
    return Event(id: data['id'], date: DateTime(data['year'], data['month'], data['day']), setId: data['setId']);
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'year': date.year,
    'month': date.month,
    'day': date.day,
    'setId': setId
  };
}

Future<void> scheduleEvents({required String setId, required int firstInterval, required int intervalIncrement,
                            required int maxInterval, required DateTime dueDate}) async {
  final now = DateTime.now();
  var nextDay = now.day;
  var interval = firstInterval;

  await removeEventsForSetId(setId: setId);

  while (DateTime(now.year, now.month, nextDay + interval).isBefore(dueDate)) {

    nextDay += interval;
    if (interval + intervalIncrement <= maxInterval) {
      interval += intervalIncrement;
    }
    
    await addEvent(event: Event(id: const Uuid().v6(), date: DateTime(now.year, now.month, nextDay), setId: setId));
    
  }
  final lastDay = DateTime(dueDate.year, dueDate.month, dueDate.day - 1);
  if (!lastDay.isAtSameMomentAs(DateTime(now.year, now.month, nextDay))) {
    await addEvent(event: Event(id: const Uuid().v6(), date: lastDay, setId: setId));
  }
  await addEvent(event: Event(id: const Uuid().v6(), date: DateTime(lastDay.year, lastDay.month, lastDay.day + 1), setId: setId));
}