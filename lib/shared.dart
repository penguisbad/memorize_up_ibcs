import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:memorize_up/model/sets.dart';
import 'package:memorize_up/model/database.dart';
import 'package:memorize_up/util/contentcontainer.dart';
import 'package:memorize_up/util/navigation.dart';
import 'package:memorize_up/util/setslist.dart';

class Shared extends StatefulWidget {
  
  const Shared({super.key});

  @override
  State<StatefulWidget> createState() => _SharedState();

}

class _SharedState extends State<Shared> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _notifier = SetsNotifier();

  var _loading = true;

  @override
  void initState() {
    super.initState();
    (() async {
      _notifier.addAll(await loadSharedSets());
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    })();
  }

  @override
  void dispose() {
    _notifier.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: false, child: Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            setState(() {
              _scaffoldKey.currentState?.openDrawer();
            });
          },
          icon: const Icon(Icons.menu),
        ),
        title: Text('Shared with me', style: Theme.of(context).textTheme.displayLarge!),
      ),
      body: ContentContainer(
        child: _loading ? const SpinKitRing(color: Colors.white30) : SetsList(notifier: _notifier),
      ),
      drawer: const Navigation(index: 4),
    ));
  }

}