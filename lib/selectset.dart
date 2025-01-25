import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:memorize_up/model/database.dart';
import 'package:memorize_up/util/contentcontainer.dart';
import 'package:memorize_up/model/sets.dart';

class SelectSet extends StatefulWidget {

  final bool Function(Set set) excludeSets;

  const SelectSet({super.key, required this.excludeSets});

  @override
  State<SelectSet> createState() => _SelectSetState();

}

class _SelectSetState extends State<SelectSet> {

  final _sets = <Set>[];
  var _loading = true;
  var _searchText = '';

  @override
  void initState() {
    super.initState();

    _loading = true;

    (() async {
      final setsToAdd = await loadSets();
      setsToAdd.removeWhere(widget.excludeSets);
      if (!mounted) return;
      setState(() {
        _sets.clear();
        _sets.addAll(setsToAdd);
        _loading = false;
      });
    })();    
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back)
        ),
        title: Text('Select set', style: Theme.of(context).textTheme.displayLarge!)
      ),
      body: ContentContainer(child: _loading ? const SpinKitRing(color: Colors.white30) : ListView(
        children: [
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
          const SizedBox(height: 20.0),
          ..._sets.where((set) => _searchText.isEmpty ? true : 
          (set.name.toLowerCase().contains(_searchText.toLowerCase()) 
          || set.description.toLowerCase().contains(_searchText.toLowerCase()))).map(
            (set) => Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                title: Text(set.name.isEmpty ? 'no name' : set.name, style: Theme.of(context).textTheme.displayMedium),
                subtitle: Text(set.description.isEmpty ? 'no description' : set.description, style: Theme.of(context).textTheme.displaySmall!),
                onTap: () {
                  Navigator.pop(context, set);
                },
              ),
              const Divider(color: Colors.white30),
            ])
          )
        ],
      )),
    ));
  }
}