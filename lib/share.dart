import 'package:flutter/material.dart';
import 'package:memorize_up/util/contentcontainer.dart';
import 'package:memorize_up/model/sets.dart' as model;

class Share extends StatefulWidget {
  
  final model.Set set;

  const Share({super.key, required this.set});

  @override
  State<Share> createState() => _ShareState();

}

class _ShareState extends State<Share> {

  final _emailControllers = <TextEditingController>[];

  void _disposeControllers() {
    for (var i = 0; i < _emailControllers.length; i++) {
      _emailControllers[i].dispose();
    }
  }

  void _updateControllers() {
    _disposeControllers();

    _emailControllers.clear();
    for (var i = 0; i < widget.set.sharedWith.length; i++) {
      final controller = TextEditingController(text: widget.set.sharedWith[i]);
      controller.addListener(() {
        widget.set.sharedWith[i] = controller.text;
      });
      _emailControllers.add(controller);
    }
  }

  @override
  void initState() {
    super.initState();
    _updateControllers();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: false, child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text('Share', style: Theme.of(context).textTheme.displayLarge!),
      ),
      body: ContentContainer(child: ListView(children: (() {
        var widgets = <Widget>[];

        for (var i = 0; i < _emailControllers.length; i++) {
          widgets.add(Row(children: [
            Expanded(child: TextField(
              controller: _emailControllers[i],
              style: Theme.of(context).textTheme.displayMedium!,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'email',
                hintStyle: Theme.of(context).textTheme.labelMedium!
              ),
            )),
            const SizedBox(width: 5.0),
            IconButton(
              onPressed: () {
                setState(() {
                  widget.set.sharedWith.removeAt(i);
                  _updateControllers();
                });
              }, 
              icon: const Icon(Icons.close)
            )
          ]));
          widgets.add(const SizedBox(height: 10.0));
        }

        widgets.add(const SizedBox(height: 20.0));
        widgets.add(Align(child: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              widget.set.sharedWith.add('');
              _updateControllers();
            });
          },
          icon: const Icon(Icons.add),
          label: Text('Add', style: Theme.of(context).textTheme.displayMedium!)
        )));
        widgets.add(const SizedBox(height: 50.0));
        

        return widgets;
      })())),
    ));
  }

}