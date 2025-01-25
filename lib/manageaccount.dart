import 'package:flutter/material.dart';
import 'package:memorize_up/util/contentcontainer.dart';
import 'package:memorize_up/util/errordialog.dart';
import 'package:memorize_up/util/navigation.dart';
import 'package:memorize_up/signin.dart';
import 'package:memorize_up/model/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class ManageAccount extends StatefulWidget {

  const ManageAccount({super.key});

  @override
  State<ManageAccount> createState() => _MangeAccountState();

}

class _MangeAccountState extends State<ManageAccount> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  var _email = '';
  var _password = '';
  var _confirmPassword = '';

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
        title: Text('Manage Account', style: Theme.of(context).textTheme.displayLarge!),
      ),
      body: ContentContainer(child: ListView(children: [
        TextField(
          style: Theme.of(context).textTheme.displayMedium!,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'new email',
            hintStyle: Theme.of(context).textTheme.labelMedium!
          ),
          onChanged: (value) {
            _email = value.toLowerCase();
          },
        ),
        const SizedBox(height: 20.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) => const SignIn(reauthenticate: true)
              ));
              if (result) {
                try {
                  await FirebaseAuth.instance.currentUser?.verifyBeforeUpdateEmail(_email);
                  (() {
                    showDialog(context: context, builder: (context) => AlertDialog(
                      title: Text('Verification email sent', style: Theme.of(context).textTheme.displayLarge!),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          }, 
                          child: Text('Close', style: Theme.of(context).textTheme.displayMedium!)
                        )
                      ],
                    ));
                  })();
                } on FirebaseAuthException catch (e) {
                  (() {
                    showDialog(context: context, builder: (context) => ErrorDialog(message: e.message ?? 'no message'));
                  })();
                }
              }
            },
            child: Text('Change email', style: Theme.of(context).textTheme.displayMedium!)
          )
        ),
        const SizedBox(height: 50.0),
        TextField(
          style: Theme.of(context).textTheme.displayMedium!,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'new password',
            hintStyle: Theme.of(context).textTheme.labelMedium!
          ),
          onChanged: (value) {
            _password = value;
          },
        ),
        const SizedBox(height: 10.0),
        TextField(
          style: Theme.of(context).textTheme.displayMedium!,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'confirm password',
            hintStyle: Theme.of(context).textTheme.labelMedium!
          ),
          onChanged: (value) {
            _confirmPassword = value;
          },
        ),
        const SizedBox(height: 20.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: ElevatedButton(
            onPressed: () async {
              if (_password != _confirmPassword) {
                showDialog(context: context, builder: (context) => const ErrorDialog(message: 'Passwords must be the same'));
                return;
              }
              final result = await Navigator.push(context, MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) => const SignIn(reauthenticate: true)
              ));
              if (result) {
                try {
                  await FirebaseAuth.instance.currentUser?.updatePassword(_password);
                  (() {
                    showDialog(context: context, builder: (context) => AlertDialog(
                      title: Center(child: Text('Password changed', style: Theme.of(context).textTheme.displayMedium!)),
                      actions: [
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Close', style: Theme.of(context).textTheme.displayMedium!)
                        )
                      ],
                    ));
                  })();
                } on FirebaseAuthException catch (e) {
                  (() {
                    showDialog(context: context, builder: (context) => ErrorDialog(message: e.message ?? 'no message'));
                  })();
                }
              }
            },
            child: Text('Change password', style: Theme.of(context).textTheme.displayMedium!),
          ),
        ),
        const SizedBox(height: 50.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: ElevatedButton(
            onPressed: () async {
              if ((await Purchases.getCustomerInfo()).entitlements.active.isNotEmpty) {
                (() {
                  showDialog(context: context, builder: (context) => const ErrorDialog(
                    message: 'Account already upgraded',
                  ));
                })();
                return;
              }
              await RevenueCatUI.presentPaywall(displayCloseButton: true);
            },
            child: Text('Upgrade', style: Theme.of(context).textTheme.displayMedium!)
          ),
        ),
        const SizedBox(height: 20.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) => const SignIn(reauthenticate: true)
              ));
              if (!result) {
                return;
              }
              late bool shouldDelete;
              await (() async {
                shouldDelete = await showDialog(
                  context: context, 
                  builder: (context) => AlertDialog(
                    title: Text('Delete account?', style: Theme.of(context).textTheme.displayMedium!),
                    actions: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        }, 
                        child: Text('Yes', style: Theme.of(context).textTheme.displayMedium!)
                      ),
                      const SizedBox(width: 5.0),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        }, 
                        child: Text('No', style: Theme.of(context).textTheme.displayMedium!)
                      )
                    ],
                  )
                );
                if (!shouldDelete) {
                  return;
                }
                await deleteUser();
                await FirebaseAuth.instance.currentUser?.delete();
                (() {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const SignIn()
                  ));
                })();
                
              })();
              
            }, 
            child: Text('Delete account', style: Theme.of(context).textTheme.displayMedium!)
          )
        ),
        const SizedBox(height: 20.0)
      ])),
      drawer: const Navigation(index: 5),
    ));
  }
}