import 'package:flutter/material.dart';
import 'package:memorize_up/model/database.dart';
import 'package:memorize_up/model/folders.dart';
import 'package:memorize_up/util/contentcontainer.dart';
import 'package:memorize_up/util/navigation.dart';
import 'package:memorize_up/viewfolder.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class Folders extends StatefulWidget {

  final bool isSelecting;

  const Folders({super.key, this.isSelecting = false});

  @override
  State<Folders> createState() => _FoldersState();

}

class _FoldersState extends State<Folders> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final  _folders = <Folder>[];
  var _name = '';

  var _loading = true;

  @override
  void initState() {
    super.initState();

    _loading = true;

    updateFolders();
  }

  Future<void> updateFolders() async {
    final foldersToAdd = await loadFolders();
    if (!mounted) return;
    setState(() {
      _folders.clear();
      _folders.addAll(foldersToAdd);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (widget.isSelecting) {
              Navigator.pop(context);
            } else {
              setState(() {
                _scaffoldKey.currentState!.openDrawer();
              });
            }
          },
          icon: Icon(widget.isSelecting ? Icons.arrow_back : Icons.menu)
        ),
        title: Text(widget.isSelecting ? 'Select folder' : 'Folders', style: Theme.of(context).textTheme.displayLarge!),
      ),
      drawer: widget.isSelecting ? null : const Navigation(index: 2),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_loading) {
            return;
          }

          _name = '';
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
                      final newFolder = Folder(
                        id: const Uuid().v6(), 
                        name: _name, 
                        setIds: []
                      );
                      setState(() {
                        _folders.add(newFolder);
                      });
                      await addFolder(folder: newFolder);
                      if (!mounted) return;
                      (() {
                        Navigator.pop(context);
                      })();
                    }, 
                    child: Text('Create folder', style: Theme.of(context).textTheme.displayMedium!)
                  )
                ],
              ),
            ),
          ));
        },
        child: const Icon(Icons.add),
      ),
      body: ContentContainer(child: _loading ? const SpinKitRing(color: Colors.white30)
       : ListView(
        children: [
          ..._folders.map((folder) => Card(child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(folder.name.isEmpty ? 'no name' : folder.name, style: Theme.of(context).textTheme.displayMedium!),
                const SizedBox(height: 10.0),
                Text(folder.setIds.isEmpty ? 'no sets' : '${folder.setIds.length} sets', style: Theme.of(context).textTheme.displaySmall!),
                const SizedBox(height: 30.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () async {
                      if (widget.isSelecting) {
                        Navigator.pop(context, folder);
                      } else {
                        final shouldDelete = await Navigator.push(context, MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (context) => ViewFolder(folder: folder)
                        ));

                        if (!mounted) return;
                        setState(() {
                          _loading = true;
                        });

                        if (shouldDelete!) {
                          await deleteFolder(folder: folder);
                          _folders.remove(folder);
                        }
                        await updateFolders();
                      }
                    }, 
                    icon: const Icon(Icons.copy),
                    label: Text(widget.isSelecting ? 'Select' : 'Open', style: Theme.of(context).textTheme.displaySmall!)
                  )
                )
              ]
            ),
          ))),
          const SizedBox(height: 100.0)
        ],
      )),
    );
  }

}