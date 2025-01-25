import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memorize_up/createfromnotes.dart';
import 'package:memorize_up/model/ai.dart';
import 'package:memorize_up/model/sets.dart';
import 'package:memorize_up/util/contentcontainer.dart';
import 'package:memorize_up/util/errordialog.dart';
import 'package:uuid/uuid.dart';

class CreateSet extends StatefulWidget {

  const CreateSet({super.key});

  @override
  State<CreateSet> createState() => _CreateSetState();

}

enum SetType {
  flashcards, list, table, text, mindmap
}

class _CreateSetState extends State<CreateSet> {

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  var _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = false;
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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
          icon: const Icon(Icons.arrow_back)
        ),
        title: Text('Create set', style: Theme.of(context).textTheme.displayLarge!),
      ),
      body: ContentContainer(
        child: Column(children: [
          TextField(
            controller: _nameController,
            style: Theme.of(context).textTheme.displayMedium!,
            decoration: InputDecoration(
              hintStyle: Theme.of(context).textTheme.labelMedium!,
              hintText: 'name'
            ),
          ),
          const SizedBox(height: 20.0),
          TextField(
            controller: _descriptionController,
            style: Theme.of(context).textTheme.displayMedium!,
            decoration: InputDecoration(
              hintStyle: Theme.of(context).textTheme.labelMedium!,
              hintText: 'description'
            ),
          ),
          const Spacer(),
          Row(children: [
            const SizedBox(width: 50.0),
            Expanded(child: ElevatedButton(
              onPressed: () {
                if (_loading) {
                  return;
                }

                final id = const Uuid().v6();
                Navigator.pop(context, FlashcardSet(
                  id: id,
                  name: _nameController.text, 
                  description: _descriptionController.text, 
                  flashcards: [],
                  sharedWith: []
                ));
              },
              child: Text('Create set', style: Theme.of(context).textTheme.displayMedium!),
            )),
            const SizedBox(width: 50.0)
          ]),
          const SizedBox(height: 10.0),
          Row(children: [
            const SizedBox(width: 50.0),
            Expanded(child: ElevatedButton(
              onPressed: () async {
                if (_loading) {
                  return;
                }

                final picker = ImagePicker();

                if (!mounted) return;
                setState(() {
                  _loading = true;
                });

                final photo = await picker.pickImage(source: ImageSource.gallery);

                if (!mounted) return;

                if (photo == null) {
                  setState(() {
                    _loading = false;
                  });
                  return;
                }
                
                try {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context, await createFlashcardsFromAI(name: _nameController.text, 
                  description: _descriptionController.text, fromNotes: false, photo: photo));
                } on Exception {
                  if (!mounted) return;

                  (() {
                    setState(() {
                      _loading = false;
                    });
                    showDialog(context: context, builder: (context) => const ErrorDialog(message: 'Unable to generate set'));
                  })();
                }
                
              }, 
              child: _loading ? const SpinKitThreeBounce(color: Colors.white30, size: 30.0) 
              : Text('Create from photo', style: Theme.of(context).textTheme.displayMedium!)
            )),
            const SizedBox(width: 50.0)
          ]),
          const SizedBox(height: 10.0),
          Row(children: [
            const SizedBox(width: 50.0),
            Expanded(child: ElevatedButton(
              onPressed: () async {
                if (_loading) {
                  return;
                }

                final result = await Navigator.push(context, MaterialPageRoute(
                  builder: (context) => CreateFromNotes(
                    name: _nameController.text,
                    description: _descriptionController.text,
                  )
                ));
                if (result == null || !mounted) {
                  return;
                }
                (() {
                  Navigator.pop(context, result);
                })();
              },
              child: Text('Create from notes', style: Theme.of(context).textTheme.displayMedium!),
            )),
            const SizedBox(width: 50.0)
          ]),
          const SizedBox(height: 20.0),
        ])
      ),
    ));
  }

}