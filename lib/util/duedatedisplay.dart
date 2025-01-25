import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:memorize_up/calendar.dart';
import 'package:memorize_up/model/calendar.dart';
import 'package:memorize_up/model/database.dart';
import 'package:memorize_up/model/sets.dart';

class DueDateDisplay extends StatefulWidget {

  final Set set;

  const DueDateDisplay({super.key, required this.set});

  @override
  State<DueDateDisplay> createState() => _DueDateDisplayState();

}

class _DueDateDisplayState extends State<DueDateDisplay> {

  var _loading = false;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const SizedBox(width: 10.0),
      _loading ? const SpinKitThreeBounce(color: Colors.white30, size: 30.0) : Text(widget.set.dueDate == null ? 'No due date' :
      'Due date: ${widget.set.dueDate!.month}/${widget.set.dueDate!.day}/${widget.set.dueDate!.year}', style: Theme.of(context).textTheme.displayMedium),
      const Spacer(),
      IconButton(
        onPressed: () async {
          if (_loading) {
            return;
          }

          if (!mounted) return;
          setState(() {
            _loading = true;
          });

          final result = await Navigator.push(context, MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => const Calendar(isSelecting: true)
          ));

          if (result != null) {
            widget.set.dueDate = result['date'];
            await scheduleEvents(setId: widget.set.id, firstInterval: result['firstInterval'], intervalIncrement: result['intervalIncrement'],
            maxInterval: result['maxInterval'], dueDate: result['date']);
            await saveSet(set: widget.set);
          }

          if (!mounted) return;
          setState(() {
            _loading = false;
          });
        }, 
        icon: const Icon(Icons.calendar_today)
      ),
      ...(widget.set.dueDate == null ? [] : [
        const SizedBox(width: 10.0),
        IconButton(
          onPressed: () async {
            if (_loading || !mounted) {
              return;
            }

            setState(() {
              _loading = true;
            });

            widget.set.dueDate = null;
            await saveSet(set: widget.set);
            await removeEventsForSetId(setId: widget.set.id);

            if (!mounted) return;

            setState(() {
              _loading = false;
            });
          },
          icon: const Icon(Icons.clear)
        )
      ])
    ]);
  }

}