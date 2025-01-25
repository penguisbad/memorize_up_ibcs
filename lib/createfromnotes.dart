import 'package:flutter/material.dart';
import 'package:memorize_up/model/sets.dart';
import 'package:memorize_up/model/ai.dart';
import 'package:memorize_up/util/contentcontainer.dart';
import 'package:memorize_up/util/errordialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CreateFromNotes extends StatefulWidget {

  final String name;
  final String description;

  const CreateFromNotes({super.key, required this.name, required this.description});

  @override
  State<CreateFromNotes> createState() => _CreateFromNotesState();
  
}

class _CreateFromNotesState extends State<CreateFromNotes> {

  String _notes = '';

  var _loading = false;

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
        title: Text('Create from Notes', style: Theme.of(context).textTheme.displayLarge!),
      ),
      body: ContentContainer(
        child: Column(children: [
          Expanded(child: TextField(
            style: Theme.of(context).textTheme.displayMedium!,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: InputDecoration(
              hintText: 'paste notes here',
              hintStyle: Theme.of(context).textTheme.labelMedium!,
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white60)
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white60)
              )
            ),
            onChanged: (value) {
              _notes = value;
            },
          )),
          const SizedBox(height: 20.0),
          Row(children: [
            const SizedBox(width: 50.0),
            Expanded(child: ElevatedButton(
              onPressed: () async {
                if (_loading || !mounted) {
                  return;
                }

                setState(() {
                  _loading = true;
                });

                try {
                  late Set set;
                  
                  set = await createFlashcardsFromAI(name: widget.name, description: widget.description,
                    fromNotes: true, notes: _notes);

                  if (!mounted) return;

                  (() {
                    Navigator.pop(context, set);
                  })();
                
                } on Exception {
                  if (!mounted) return;

                  (() {
                    showDialog(context: context, builder: (context) => const ErrorDialog(message: 'Unable to generate set'));
                    setState(() {
                      _loading = false;
                    });
                  })();
                }
                

              },
              child: _loading ? const SpinKitThreeBounce(color: Colors.white30, size: 30.0)
               : Text('Create set', style: Theme.of(context).textTheme.displayMedium!),
            )),
            const SizedBox(width: 50.0)
          ]),
          const SizedBox(height: 20.0)
        ])
      ),
    ));
  }

}
