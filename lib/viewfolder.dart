import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:memorize_up/model/database.dart';
import 'package:memorize_up/model/folders.dart';
import 'package:memorize_up/model/sets.dart';
import 'package:memorize_up/selectset.dart';
import 'package:memorize_up/util/contentcontainer.dart';
import 'package:memorize_up/util/setslist.dart';

class ViewFolder extends StatefulWidget {

  final Folder folder;

  const ViewFolder({super.key, required this.folder});

  @override
  State<ViewFolder> createState() => _ViewFolderState();

}

class _ViewFolderState extends State<ViewFolder> {

  final _notifier = SetsNotifier();
  var _name = '';

  var _loading = true;

  @override
  void initState() {
    super.initState();
    _loading = true;

    updateSets();
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  Future<void> updateSets() async {
    _notifier.sets.clear();
    _notifier.sets.addAll(await loadSetIds(setIds: widget.folder.setIds));

    if (!mounted) return;
    
    setState(() {
      _loading = false;
    });
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
        title: Text(widget.folder.name, style: Theme.of(context).textTheme.displayLarge!),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: IconButton(
              onPressed: () async {
                _name = '';
                final shouldDelete = await showDialog<bool>(context: context, builder: (context) => Dialog(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10.0),
                        Center(child: Text('Options', style: Theme.of(context).textTheme.displayLarge!)),
                        const SizedBox(height: 20.0),
                        OutlinedButton.icon(
                          onPressed: () {
                            showDialog(context: context, builder: (context) => Dialog(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.displayMedium!,
                                      decoration: InputDecoration(
                                        hintText: 'name',
                                        hintStyle: Theme.of(context).textTheme.labelMedium!
                                      ),
                                      onChanged: (value) {
                                        _name = value;
                                      },
                                    ),
                                    const SizedBox(height: 20.0),
                                    OutlinedButton(
                                      onPressed: () async {
                                        if (!mounted) return;
                                        setState(() {
                                          widget.folder.name = _name;
                                        });
                                        await saveFolder(folder: widget.folder);

                                        if (!mounted) return;
                                        (() {
                                          Navigator.pop(context, false);
                                        })();
                                      }, 
                                      child: Text('Rename', style: Theme.of(context).textTheme.displayMedium!)
                                    )
                                  ],
                                ),
                              ),
                            ));
                          }, 
                          icon: const Icon(Icons.text_fields),
                          label: Text('Rename', style: Theme.of(context).textTheme.displayMedium!)
                        ),
                        const SizedBox(height: 10.0),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context, true);
                          }, 
                          icon: const Icon(Icons.delete),
                          label: Text('Delete', style: Theme.of(context).textTheme.displayMedium!)
                        ),
                        const SizedBox(height: 20.0)
                      ],
                    ),
                  ),
                ));

                if (shouldDelete != null && shouldDelete && mounted) {
                  (() {
                    Navigator.pop(context, true);
                  })();
                }
              }, 
              icon: const Icon(Icons.more_vert)
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final set = await Navigator.push<Set>(context, MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => SelectSet(excludeSets: (set) => set.inFolder)
          ));
          if (set != null && mounted) {
            setState(() {
              _loading = true;
              widget.folder.setIds.add(set.id);
            });
            set.inFolder = true;
            set.folderId = widget.folder.id;
            await saveSet(set: set);
            await saveFolder(folder: widget.folder);
            await updateSets();
            
            if (mounted) {
              setState(() {});
            }
          }
        },
        child: const Icon(Icons.add),
      ),
      body: ContentContainer(child: _loading ? const SpinKitRing(color: Colors.white30) 
      : SetsList(
        notifier: _notifier,
        onEdit: () async {
          if (!mounted) return;
          setState(() {
            _loading = true;
          });
          widget.folder.setIds = (await loadFolder(folderId: widget.folder.id)).setIds;
          updateSets();
        }
      )),
    ));
  }
}