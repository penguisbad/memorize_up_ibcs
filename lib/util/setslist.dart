import 'package:flutter/material.dart';
import 'package:memorize_up/flashcards/editflashcards.dart';
import 'package:memorize_up/model/sets.dart';
import 'package:memorize_up/model/database.dart';
import 'package:memorize_up/flashcards/learnflashcards.dart';
import 'package:memorize_up/util/errordialog.dart';

class SetsList extends StatefulWidget {

  final SetsNotifier notifier;
  final void Function()? onEdit;
  final bool showSearch;
  final ValueNotifier<bool>? addNotifier;

  const SetsList({super.key, required this.notifier, this.onEdit, this.showSearch = true, this.addNotifier});

  @override
  State<SetsList> createState() => _SetsListState();

}

class _SetsListState extends State<SetsList> {

  var _searchText = '';

  final _allSetIds = <String>[];

  @override
  void initState() {
    super.initState();
    
    _updateAllSetIds();
    widget.addNotifier?.addListener(() {
      _updateAllSetIds();
    });
  }

  Future<void> _updateAllSetIds() async {
    final setIdsToAdd = (await loadUser())['sets'];
    _allSetIds.clear();
    for (final setId in setIdsToAdd) {
      _allSetIds.add(setId);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.notifier,
      builder: (context, child) => ListView(
        children: (widget.showSearch ? <Widget>[
          TextField(
            style: Theme.of(context).textTheme.displayMedium!,
            decoration: InputDecoration(
              hintText: 'search',
              hintStyle: Theme.of(context).textTheme.labelMedium!
            ),
            onChanged: (text) {
              setState(() {
                _searchText = text;
              });
            },
          ),
          const SizedBox(height: 20.0)
        ] : <Widget>[]) + [...widget.notifier.sets.where((set) => _searchText.isEmpty ? true : 
        (set.name.toLowerCase().contains(_searchText.toLowerCase()) 
        || set.description.toLowerCase().contains(_searchText.toLowerCase()))).map((set) => Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(set.name.isNotEmpty ? set.name : 'no name', style: Theme.of(context).textTheme.displayMedium!),
                const SizedBox(height: 10.0),
                Text(set.sharedBy == null ? (set.description.isNotEmpty ? set.description : 'no description')
                : 'Shared by: ${set.sharedBy!}', style: Theme.of(context).textTheme.displaySmall!),
                const SizedBox(height: 10.0),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  set.readonly ? const SizedBox() : TextButton.icon(
                    onPressed: () async {

                      var result = await Navigator.push(context, MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) {
                          return EditFlashcards(set: set as FlashcardSet);
                        } 
                      ));
                      if (result != null && result) {
                        widget.notifier.remove(set);
                        _allSetIds.remove(set.id);
                        await deleteSet(set: set);
                        
                        return;
                      }
                      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                      widget.notifier.notifyListeners();
                      await saveSet(set: set);
                      if (widget.onEdit != null) {
                        widget.onEdit!();
                      }
                    },
                    icon: const Icon(Icons.edit, size: 20.0),
                    label: Text('Edit', style: Theme.of(context).textTheme.displaySmall!)
                  ),
                  const SizedBox(width: 5.0),
                  TextButton.icon(
                    onPressed: () async {
                      if (!set.canStudy()) {
                        showDialog(context: context, builder: (context) => const ErrorDialog(message: 'Set must have at least 4 cards'));
                        return;
                      }
                      await Navigator.push(context, MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) {
                          if (set is FlashcardSet) {
                            return LearnFlashcards(flashcards: set.flashcards, name: set.name);
                          }
                          return const SizedBox();
                        },
                      ));
                    },
                    icon: const Icon(Icons.copy, size: 20.0),
                    label: Text('Study', style: Theme.of(context).textTheme.displaySmall!)
                  )
                ])
              ]
            )
          )
        )),
        const SizedBox(height: 100.0)
      ])
    );
  }
}
