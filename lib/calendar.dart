import 'package:flutter/material.dart';
import 'package:memorize_up/flashcards/learnflashcards.dart';
import 'package:memorize_up/model/sets.dart';
import 'package:memorize_up/model/database.dart';
import 'package:memorize_up/model/calendar.dart';
import 'package:memorize_up/selectset.dart';
import 'package:memorize_up/util/contentcontainer.dart';
import 'package:memorize_up/util/errordialog.dart';
import 'package:memorize_up/util/navigation.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:uuid/uuid.dart';

class Calendar extends StatefulWidget {

  final bool isSelecting;

  const Calendar({super.key, this.isSelecting = false});

  @override
  State<StatefulWidget> createState() => _CalendarState();
}

const months = ['January', 'February', 'March', 'April', 'May', 'June',
                'July', 'August', 'September', 'October', 'November', 'December'];

class _CalendarState extends State<Calendar> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  var _month = 0;
  var _year = 0;
  int? _day;
  var _loading = true;
  var _loadingSets = true;

  var _firstInterval = 1;
  var _intervalIncrement = 1;
  var _maxInterval = 30;

  late TextEditingController _firstIntervalController;
  late TextEditingController _intervalIncrementController;
  late TextEditingController _maxIntervalController;

  final _events = <Event>[];
  final _sets = <Set>[];

  @override
  void initState() {
    super.initState();

    _firstIntervalController = TextEditingController(text: '1')
    ..addListener(() {
      final n = int.tryParse(_firstIntervalController.text);
      if (n != null && n > 0 && n < _maxInterval) {
        _firstInterval = n;
      }
    });

    _intervalIncrementController = TextEditingController(text: '1')
    ..addListener(() {
      final n = int.tryParse(_intervalIncrementController.text);
      if (n != null && n > 0 && n < _maxInterval) {
        _intervalIncrement = n;
      }
    });

    _maxIntervalController = TextEditingController(text: '30')
    ..addListener(() {
      final n = int.tryParse(_maxIntervalController.text);
      if (n != null && n > 0) {
        _maxInterval = n;
      }
    });

    final today = DateTime.now();
    _month = today.month;
    _year = today.year;
    _day = today.day;

    if (widget.isSelecting) {
      _loading = false;
      return;
    }

    (() async {
      final events = await loadEvents();

      if (!mounted) return;
      setState(() {
        _events.clear();
        _events.addAll(events);
        _loading = false;
        _loadingSets = true;
      });

      if (!widget.isSelecting) {
        await updateSets();
      }
    })();
  }

  Future<void> updateSets() async {
    final sets = <Set>[];
    final eventsToday = _events.where(
      (event) => event.date.day == _day && event.date.month == _month && event.date.year == _year
    );

    for (final event in eventsToday) {
      sets.add(await loadSet(setId: event.setId));
    }

    if (!mounted) return;
    setState(() {
      _sets.clear();
      _sets.addAll(sets);
      _loadingSets = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: false, child: Scaffold(
      key: _scaffoldKey,
      drawer: widget.isSelecting ? null : const Navigation(index: 3),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (widget.isSelecting) {
              Navigator.pop(context);
            } else {
              setState(() {
                _scaffoldKey.currentState?.openDrawer();
              });
            }
          }, 
          icon: widget.isSelecting ? const Icon(Icons.arrow_back) : const Icon(Icons.menu)
        ),
        title: Text(widget.isSelecting ? 'Select date' : 'Calendar', style: Theme.of(context).textTheme.displayLarge!),
      ),
      floatingActionButton: widget.isSelecting ? null : FloatingActionButton(
        onPressed: () async {
          if (_day == null) return;

          final set = await Navigator.push<Set>(context, MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => SelectSet(excludeSets: (set) => _sets.map((set) => set.id).contains(set.id))
          ));

          if (set == null || !mounted) return;

          setState(() {
            _loadingSets = true;
          });

          final newEvent = Event(
            id: const Uuid().v6(), 
            date: DateTime(_year, _month, _day!), 
            setId: set.id
          );
          _events.add(newEvent);
          await addEvent(event: newEvent);
          await updateSets();
        },
        child: const Icon(Icons.add),
      ),
      body: ContentContainer(child: _loading ? const SpinKitRing(
        color: Colors.white30,
      ) : ListView(children: [
        Row(children: [
          IconButton(
            onPressed: () {
              setState(() {
                _day = null;
                _month--;
                if (_month < 1) {
                  _month = 12;
                  _year--;
                }
                updateSets();
              });
            }, 
            icon: const Icon(Icons.arrow_back)
          ),
          const Spacer(),
          Text('${months[_month - 1]} $_year', style: Theme.of(context).textTheme.displayMedium!),
          const Spacer(),
          IconButton(
            onPressed: () {
              setState(() {
                _day = null;
                _month++;
                if (_month > 12) {
                  _month = 1;
                  _year++;
                }
              });
              updateSets();
            }, 
            icon: const Icon(Icons.arrow_forward)
          )
        ]),
        const SizedBox(height: 20.0),
        ...(() {
          var widgets = <Widget>[];
          var count = -1;

          var firstDay = DateTime(_year, _month).weekday;
          const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

          for (var i = 0; i < 7; i++) {
            
            widgets.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: (() {
              var widgets2 = <Widget>[];
              for (var k = 1; k < 8; k++) {
                if (i == 1 && k == firstDay) {
                  count = 1;
                }

                final c = count;

                widgets2.add(GestureDetector(
                  onTap: () async {
                    if (c < 0 || DateTime(_year, _month, c + 1).isBefore(DateTime.now()) || !mounted) {
                      return;
                    }
                    setState(() {
                      _day = c;
                    });
                    if (!widget.isSelecting && mounted) {
                      setState(() {
                        _loadingSets = true;
                      });
                      await updateSets();
                    }
                  },
                  child: Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: count > 0 ? const Color.fromARGB(255, 50, 60, 70) : Colors.transparent,
                      shape: BoxShape.circle,
                      border: _day == count ? Border.all(color: Colors.white60) : (_events.where(
                        (event) => event.date.day == count && event.date.month == _month
                        && event.date.year == _year
                      ).isEmpty ? null : Border.all(color: Colors.white30))
                    ),
                    child: Center(child: i == 0 ? Text(weekdays[k - 1], style: Theme.of(context).textTheme.displayMedium!)
                    : (count > 0 ? Text('$count', style: DateTime(_year, _month, c + 1).isBefore(DateTime.now()) ? 
                    Theme.of(context).textTheme.labelMedium! : Theme.of(context).textTheme.displayMedium!) : null)),
                  )
                ));
                if (DateTime(_year, _month, count + 1).month != _month) {
                  count = -1;
                }
                if (count > 0) {
                  count++;
                }
                
              }
              return widgets2;
            })()));
            widgets.add(const SizedBox(height: 10.0));
          }

          return widgets;
        })(),
        ...(() {
          if (widget.isSelecting) {
            return [
              Row(children: [
                const SizedBox(width: 50.0),
                Expanded(child: TextField(
                  style: Theme.of(context).textTheme.displayMedium!,
                  textAlign: TextAlign.right,
                  controller: _firstIntervalController,
                  decoration: InputDecoration(
                    prefixIcon: Text('First interval: ', style: Theme.of(context).textTheme.displayMedium!),
                    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    suffixIcon: Text(' days', style: Theme.of(context).textTheme.labelMedium!),
                    suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0)
                  ),
                )),
                const SizedBox(width: 50.0)
              ]),
              const SizedBox(height: 20.0),
              Row(children: [
                const SizedBox(width: 50.0),
                Expanded(child: TextField(
                  style: Theme.of(context).textTheme.displayMedium!,
                  textAlign: TextAlign.right,
                  controller: _intervalIncrementController,
                  decoration: InputDecoration(
                    prefixIcon: Text('Interval increment:', style: Theme.of(context).textTheme.displayMedium!),
                    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    suffixIcon: Text(' days', style: Theme.of(context).textTheme.labelMedium!),
                    suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0)
                  ),
                )),
                const SizedBox(width: 50.0)
              ]),
              const SizedBox(height: 20.0),
              Row(children: [
                const SizedBox(width: 50.0),
                Expanded(child: TextField(
                  style: Theme.of(context).textTheme.displayMedium!,
                  textAlign: TextAlign.right,
                  controller: _maxIntervalController,
                  decoration: InputDecoration(
                    prefixIcon: Text('Maximum interval:', style: Theme.of(context).textTheme.displayMedium!),
                    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    suffixIcon: Text(' days', style: Theme.of(context).textTheme.labelMedium!),
                    suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0)
                  ),
                )),
                const SizedBox(width: 50.0)
              ]),
              const SizedBox(height: 50.0),
              Row(children: [
                const SizedBox(width: 50.0),
                Expanded(child: ElevatedButton(
                  onPressed: _day == null ? null : () {
                    final today = DateTime.now();
                    if (DateTime(_year, _month, _day!).isAfter(DateTime(today.year + 2, today.month, today.day))) {
                      showDialog(context: context, builder: (context) => const ErrorDialog(message: 'Due date must be within 2 years'));
                      return;
                    }

                    Navigator.pop(context, {
                      'firstInterval': _firstInterval,
                      'intervalIncrement': _intervalIncrement,
                      'maxInterval': _maxInterval,
                      'date': DateTime(_year, _month, _day!)
                    });
                  },
                  child: Text('Select', style: Theme.of(context).textTheme.displayMedium!)
                )),
                const SizedBox(width: 50.0)
              ]),
              const SizedBox(height: 50.0)
            ];
          } else {
            return _loadingSets ? [
              const SizedBox(height: 50.0), 
              const SpinKitRing(color: Colors.white30)
            ] : [
              const Divider(),
              ...(() {
                var widgets = <Widget>[];

                for (var i = 0; i < _sets.length; i++) {
                  final set = _sets[i];
                  widgets.add(ListTile(
                    title: Text(set.name.isEmpty ? 'no name' : set.name, style: Theme.of(context).textTheme.displayMedium!),
                    subtitle: Text(set.description.isEmpty ? 'no description' : set.description, style: Theme.of(context).textTheme.displaySmall!),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      TextButton.icon(
                        onPressed: !set.canStudy() ? null : () async {
                          await Navigator.push(context, MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) {
                              if (set is FlashcardSet) {
                                return LearnFlashcards(flashcards: set.flashcards, name: set.name);
                              }
                              return const SizedBox();
                            }
                          ));
                        }, 
                        label: Text('Study', style: set.canStudy() ? Theme.of(context).textTheme.displaySmall!
                        : Theme.of(context).textTheme.labelSmall!),
                        icon: const Icon(Icons.content_copy, size: 20.0)
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          if (_day == null || !mounted) return;
                          
                          setState(() {
                            _loadingSets = true;
                          });
                          final event = _events.where((event) => event.setId == set.id && event.date.isAtSameMomentAs(DateTime(_year, _month, _day!))).first;
                          _events.remove(event);
                          await deleteEvent(eventId: event.id);
                          await updateSets();
                        },
                        icon: const Icon(Icons.delete, size: 20.0),
                        label: Text('Delete', style: Theme.of(context).textTheme.displaySmall!)
                      )
                    ])
                  ));
                  widgets.add(const Divider(color: Colors.white30));
                }
                widgets.add(const SizedBox(height: 100.0));
                return widgets;
              })()
            ];
          }
        })()
      ])) 
    ));
  }
}