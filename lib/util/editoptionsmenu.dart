import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorize_up/folders.dart';
import 'package:memorize_up/model/database.dart';
import 'package:memorize_up/model/sets.dart';
import 'package:memorize_up/model/folders.dart';
import 'package:memorize_up/share.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:memorize_up/util/errordialog.dart';

class EditOptionsMenu extends StatefulWidget {

  final Set set;

  final Map<String, void Function()> additionalOptions;
  final Map<String, Icon> additionalIcons;

  const EditOptionsMenu({super.key, required this.set, 
  required this.additionalOptions, required this.additionalIcons});

  @override
  State<EditOptionsMenu> createState() => _EditOptionsMenuState();

}

class _EditOptionsMenuState extends State<EditOptionsMenu> {

  var _loading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10.0),
          Center(child: Text('Options', style: Theme.of(context).textTheme.displayLarge!)),
          const SizedBox(height: 20.0),
          ...(() {
            var widgets = <Widget>[];
            for (final key in widget.additionalOptions.keys) {
              widgets.add(OutlinedButton.icon(
                onPressed: () {
                  if (_loading) {
                    return;
                  }

                  widget.additionalOptions[key]!();
                },
                icon: widget.additionalIcons[key],
                label: Text(key, style: Theme.of(context).textTheme.displayMedium!)
              ));
              widgets.add(const SizedBox(height: 10.0));
            }
            return widgets;
          })(),
          OutlinedButton.icon(
            onPressed: () async {
              if (_loading || !mounted) {
                return;
              }              

              if (widget.set.inFolder) {
                setState(() {
                  _loading = true;
                });

                final folder = await loadFolder(folderId: widget.set.folderId!);

                if (!mounted) return;

                folder.setIds.remove(widget.set.id);
                setState(() {
                  widget.set.inFolder = false;
                  widget.set.folderId = null;
                });

                await saveFolder(folder: folder);
                await saveSet(set: widget.set);

                if (!mounted) return;
                
                setState(() {
                  _loading = false;
                });
              } else {
                setState(() {
                  _loading = true;
                });

                final folder = await Navigator.push<Folder>(context, MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => const Folders(isSelecting: true)
                ));

                if (!mounted) return;

                if (folder != null) {
                  folder.setIds.add(widget.set.id);
                  setState(() {
                    widget.set.inFolder = true;
                    widget.set.folderId = folder.id;
                  });

                  await saveFolder(folder: folder);
                  await saveSet(set: widget.set);

                  if (!mounted) return;
                }
                
                setState(() {
                  _loading = false;
                });
              }
            },
            icon: _loading ? null : const Icon(Icons.folder),
            label: _loading ? const SpinKitThreeBounce(color: Colors.white30, size: 20.0)
            : Text(widget.set.inFolder ? 'Remove from folder' : 'Add to folder', style: Theme.of(context).textTheme.displayMedium!)
          ),
          const SizedBox(height: 10.0),
          OutlinedButton.icon(
            onPressed: () async {
              if (_loading) {
                return;
              }

              await showDialog(context: context, builder: (context) => Dialog(child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Edit visibility', style: Theme.of(context).textTheme.displayLarge!),
                    const SizedBox(height: 20.0),
                    DropdownMenu(
                      initialSelection: widget.set.isPublic,
                      textStyle: Theme.of(context).textTheme.displayMedium!,
                      dropdownMenuEntries: [
                        DropdownMenuEntry( style: ButtonStyle(
                          textStyle: WidgetStatePropertyAll(Theme.of(context).textTheme.displayMedium!),
                          foregroundColor: const WidgetStatePropertyAll(Colors.white60)
                        ), value: true, label: 'Everyone'),
                        DropdownMenuEntry(style: ButtonStyle(
                          textStyle: WidgetStatePropertyAll(Theme.of(context).textTheme.displayMedium!),
                          foregroundColor: const WidgetStatePropertyAll(Colors.white60)
                        ), value: false, label: 'Only invites')
                      ],
                      onSelected: (value) {
                        if (value == null) return;

                        widget.set.isPublic = value;
                      },
                    ),
                    const SizedBox(height: 20.0),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      }, 
                      child: Text('Close', style: Theme.of(context).textTheme.displayMedium!)
                    )
                  ],
                ),
              )));
            }, 
            icon: const Icon(Icons.visibility),
            label: Text('Edit visibility', style: Theme.of(context).textTheme.displayMedium!)
          ),
          const SizedBox(height: 10.0),
          OutlinedButton.icon(
            onPressed: () {
              if (_loading) {
                return;
              }

              if (FirebaseAuth.instance.currentUser!.isAnonymous) {
                showDialog(context: context, builder: (context) => const ErrorDialog(message: 'You must have an account to share sets'));
                return;
              }

              Navigator.push(context, MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) => Share(set: widget.set)
              ));
            }, 
            icon: const Icon(Icons.share), 
            label: Text('Share', style: Theme.of(context).textTheme.displayMedium!)
          ),
          const SizedBox(height: 10.0),
          OutlinedButton.icon(
            onPressed: () {
              if (_loading) {
                return;
              }

              Navigator.pop(context, true);
            }, 
            icon: const Icon(Icons.delete), 
            label: Text('Delete', style: Theme.of(context).textTheme.displayMedium!)
          ),
          const SizedBox(height: 20.0)
        ],
      ),
    );
  }
}