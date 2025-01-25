import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memorize_up/createfromnotes.dart';
import 'package:memorize_up/model/ai.dart';
import 'package:memorize_up/model/database.dart';
import 'package:memorize_up/model/sets.dart';
import 'package:memorize_up/selectset.dart';
import 'package:memorize_up/util/contentcontainer.dart';
import 'package:memorize_up/util/duedatedisplay.dart';
import 'package:memorize_up/util/editoptionsmenu.dart';


class EditFlashcards extends StatefulWidget {
  final FlashcardSet set;

  const EditFlashcards({super.key, required this.set});

  @override
  State<EditFlashcards> createState() => _EditFlashcardsState();

}

class _EditFlashcardsState extends State<EditFlashcards> {

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final _frontControllers = <TextEditingController>[];
  final _backControllers = <TextEditingController>[];
  var _loadingPhoto = false;

  void _updateControllers() {
    for (var i = 0; i < _frontControllers.length; i++) {
      _frontControllers[i].dispose();
      _backControllers[i].dispose();
    }
    _frontControllers.clear();
    _backControllers.clear();

    for (var i = 0; i < widget.set.flashcards.length; i++) {
      var frontController = TextEditingController(text: widget.set.flashcards[i].front);
      frontController.addListener(() {
        widget.set.flashcards[i].front = frontController.text;
      });
      _frontControllers.add(frontController);

      var backController = TextEditingController(text: widget.set.flashcards[i].back);
      backController.addListener(() {
        widget.set.flashcards[i].back = backController.text;
      });
      _backControllers.add(backController);
    }
  }

  @override
  void initState() {
    super.initState();

    _loadingPhoto = false;

    _nameController = TextEditingController(text: widget.set.name)
    ..addListener(() {
      widget.set.name = _nameController.text;
    });

    _descriptionController = TextEditingController(text: widget.set.description)
    ..addListener(() {
      widget.set.description = _descriptionController.text;
    });

    _updateControllers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();

    for (final frontController in _frontControllers) {
      frontController.dispose();
    }

    for (final backController in _backControllers) {
      backController.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: false, child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text('Edit flashcards', style: Theme.of(context).textTheme.displayLarge!),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: IconButton(
              onPressed: () async {
                var shouldDelete = await showDialog<bool?>(context: context, builder: (context) => Dialog(
                  child: EditOptionsMenu(set: widget.set, additionalOptions: {
                    'Swap sides' : () async {
                      setState(() {
                        for (var i = 0; i < widget.set.flashcards.length; i++) {
                          var front = widget.set.flashcards[i].front;
                          widget.set.flashcards[i].front = widget.set.flashcards[i].back;
                          widget.set.flashcards[i].back = front;
                        }
                      });
                      _updateControllers();
                      await saveSet(set: widget.set);

                      if (!mounted) return;
                      (() {
                        Navigator.pop(context, false);
                      })();
                    },
                    'Add cards' : () async {
                      final shouldPop = await showDialog(context: context, builder: (context) => Dialog(child: StatefulBuilder(
                        builder: (context, dialogSetState) => Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 10.0),
                              Center(child: Text('Add cards', style: Theme.of(context).textTheme.displayLarge!)),
                              const SizedBox(height: 20.0),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final set = await Navigator.push(context, MaterialPageRoute(
                                    fullscreenDialog: true,
                                    builder: (context) => SelectSet(excludeSets: (set) => set is! FlashcardSet || set.id == widget.set.id)
                                  ));
                                  if (!context.mounted || set == null) {
                                    return;
                                  }
                                  
                                  setState(() {
                                    widget.set.flashcards.addAll((set as FlashcardSet).flashcards);  
                                  });
                                  
                                  _updateControllers();

                                  if (!context.mounted) return;
                                  (() {
                                    Navigator.pop(context, true);
                                  })();
                                  
                                }, 
                                icon: const Icon(Icons.content_copy),
                                label: Text('Add from another set', style: Theme.of(context).textTheme.displayMedium!)
                              ),
                              const SizedBox(height: 10.0),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  // ignore: use_build_context_synchronously
                                  final set = await Navigator.push(context, MaterialPageRoute(
                                    fullscreenDialog: true,
                                    builder: (context) => const CreateFromNotes(name: '', description: '')
                                  ));

                                  if (!context.mounted || set == null) {
                                    return;
                                  }

                                  setState(() {
                                    widget.set.flashcards.addAll((set as FlashcardSet).flashcards);
                                  });

                                  _updateControllers();
                                  await saveSet(set: widget.set);

                                  (() {
                                    Navigator.pop(context, true);
                                  })();
                                }, 
                                icon: const Icon(Icons.edit_document),
                                label: Text('Add from notes', style: Theme.of(context).textTheme.displayMedium!)
                              ),
                              const SizedBox(height: 10.0),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  if (_loadingPhoto) {
                                    return;
                                  }

                                  final picker = ImagePicker();

                                  if (!context.mounted) return;
                                  dialogSetState(() {
                                    _loadingPhoto = true;
                                  });

                                  final photo = await picker.pickImage(source: ImageSource.gallery);

                                  if (photo == null) {
                                    if (!context.mounted) return;
                                    dialogSetState(() {
                                      _loadingPhoto = false;
                                    });
                                    return;
                                  }

                                  final set = await createFlashcardsFromAI(name: '', description: '', fromNotes: false, photo: photo);
                                  
                                  if (!context.mounted) {
                                    _loadingPhoto = false;
                                    return;
                                  }

                                  setState(() {
                                    widget.set.flashcards.addAll(set.flashcards);
                                  });
                                  dialogSetState(() {
                                    _loadingPhoto = false;
                                  });

                                  _updateControllers();
                                  await saveSet(set: widget.set);

                                  if (!mounted) return;
                                  (() {
                                    Navigator.pop(context, true);
                                  })();
                                }, 
                                icon: _loadingPhoto ? null : const Icon(Icons.photo),
                                label: _loadingPhoto ? const SpinKitThreeBounce(color: Colors.white30, size: 20.0)
                                : Text('Add from photo', style: Theme.of(context).textTheme.displayMedium!)
                              ),
                              const SizedBox(height: 20.0)
                            ]
                          )
                        )
                      )));

                      if (!mounted || shouldPop == null) return;

                      await saveSet(set: widget.set);

                      if (shouldPop && mounted) {
                        (() {
                          Navigator.pop(context);
                        })();
                      }
                    }
                  },
                  additionalIcons: const {
                    'Swap sides' : Icon(Icons.autorenew),
                    'Add cards' : Icon(Icons.add)
                  },),
                ));
                if (!mounted) return;
                if (shouldDelete != null && shouldDelete) {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context, true);
                }
              },
              icon: const Icon(Icons.more_vert)
            )
          )
        ]
      ),
      body: ContentContainer(child: ListView(
        children: [
          TextField(
            controller: _nameController,
            style: Theme.of(context).textTheme.displayMedium!,
            decoration: InputDecoration(
              hintStyle: Theme.of(context).textTheme.labelMedium!,
              hintText: 'title'
            ),
            onSubmitted: (value) async {
              await saveSet(set: widget.set);
            },
          ),
          const SizedBox(height: 20.0),
          TextField(
            controller: _descriptionController,
            style: Theme.of(context).textTheme.displayMedium!,
            decoration: InputDecoration(
              hintStyle: Theme.of(context).textTheme.labelMedium!,
              hintText: 'description'
            ),
            onSubmitted: (value) async {
              await saveSet(set: widget.set);
            },
          ),
          const SizedBox(height: 30.0),
          DueDateDisplay(set: widget.set),
          const SizedBox(height: 30.0),
          ...(() {
            var widgets = <Widget>[];
            for (var i = 0; i < widget.set.flashcards.length; i++) {
              widgets.add(Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(children: [
                    TextField(
                      controller: _frontControllers[i],
                      style: Theme.of(context).textTheme.displayMedium!,
                      decoration: InputDecoration(
                        hintStyle: Theme.of(context).textTheme.labelMedium!,
                        hintText: 'front'
                      ),
                      onSubmitted: (value) async {
                        await saveSet(set: widget.set);
                      },
                    ),
                    const SizedBox(height: 5.0),
                    TextField(
                      controller: _backControllers[i],
                      style: Theme.of(context).textTheme.displayMedium!,
                      decoration: InputDecoration(
                        hintStyle: Theme.of(context).textTheme.labelMedium!,
                        hintText: 'back'
                      ),
                      onSubmitted: (value) async {
                        await saveSet(set: widget.set);
                      },
                    ),
                    const SizedBox(height: 10.0),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                      IconButton(
                        onPressed: () async {
                          if (i == 0) {
                            return;
                          }
                          if (!mounted) return;
                          setState(() {
                            var temp = widget.set.flashcards[i - 1];
                            widget.set.flashcards[i - 1] = widget.set.flashcards[i];
                            widget.set.flashcards[i] = temp;
                          });
                          _updateControllers();
                          await saveSet(set: widget.set);
                        }, 
                        icon: const Icon(Icons.north)
                      ),
                      IconButton(
                        onPressed: () async {
                          if (i == widget.set.flashcards.length - 1) {
                            return;
                          }
                          if (!mounted) return;
                          setState(() {
                            var temp = widget.set.flashcards[i + 1];
                            widget.set.flashcards[i + 1] = widget.set.flashcards[i];
                            widget.set.flashcards[i] = temp;
                          });
                          _updateControllers();
                          await saveSet(set: widget.set);
                        }, 
                        icon: const Icon(Icons.south)
                      ),
                      IconButton(
                        onPressed: () async {
                          if (!mounted) return;
                          setState(() {
                            widget.set.flashcards[i].starred = !widget.set.flashcards[i].starred;
                          });
                          await saveSet(set: widget.set);
                        }, 
                        icon: Icon(widget.set.flashcards[i].starred ? Icons.star : Icons.star_outline)
                      ),
                      IconButton(
                        onPressed: () async {
                          if (!mounted) return;
                          setState(() {
                            widget.set.flashcards.removeAt(i);
                          });
                          _updateControllers();
                          await saveSet(set: widget.set);
                        }, 
                        icon: const Icon(Icons.delete)
                      )
                    ])
                  ])
                ),
              ));
            }
            return widgets;
          })(),
          const SizedBox(height: 50.0),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [ElevatedButton.icon(
            onPressed: () async {
              setState(() {
                widget.set.flashcards.add(Flashcard(
                  front: '', 
                  back: '',
                  starred: false
                ));
              });
              _updateControllers();
              await saveSet(set: widget.set);
            }, 
            icon: const Icon(Icons.add), 
            label: Text('Add', style: Theme.of(context).textTheme.displayMedium!)
          )]),
          const SizedBox(height: 50.0)
        ],
      )),
    ));
  }
}
