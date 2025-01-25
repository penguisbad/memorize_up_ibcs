import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:memorize_up/createset.dart';
import 'package:memorize_up/model/sets.dart';
import 'package:memorize_up/model/database.dart';
import 'package:memorize_up/util/contentcontainer.dart';
import 'package:memorize_up/util/navigation.dart';
import 'package:memorize_up/util/setslist.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => _HomeState();

}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  final _notifier = SetsNotifier();
  final _addNotifier = ValueNotifier<bool>(true);

  var _loading = true;
  var _subscribed = false;

  @override
  void initState() {
    super.initState();
    (() async {
      _notifier.sets.addAll(await loadSets());
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    })();
  }

  @override
  void dispose() {
    _notifier.dispose();
    _addNotifier.dispose();
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
        title: Text('My sets', style: Theme.of(context).textTheme.displayLarge!)
      ),
      body: ContentContainer(
        child: _loading ? const SpinKitRing(
          color: Colors.white30,
        ) : SetsList(notifier: _notifier, addNotifier: _addNotifier)
      ),
      drawer: const Navigation(index: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_loading) {
            return;
          }
          
          if (!_subscribed && _notifier.sets.length >= 10) {
            await RevenueCatUI.presentPaywall(displayCloseButton: true);
            _subscribed = (await Purchases.getCustomerInfo()).entitlements.active.isNotEmpty;

            if (!mounted) return;

            setState(() {});

            return;
          }
          
          var newSet = await Navigator.push(context, MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => const CreateSet()
          ));
          if (!mounted || newSet == null) return;
          _notifier.addSet(newSet);
          await addSet(set: newSet);
          _addNotifier.value = !_addNotifier.value;
        },
        child: const Icon(Icons.add),
      ),
    ));
  }
}
