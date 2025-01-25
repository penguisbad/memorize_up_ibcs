import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:memorize_up/home.dart';
import 'package:memorize_up/model/database.dart';
import 'package:memorize_up/util/contentcontainer.dart';
import 'package:memorize_up/util/errordialog.dart';

class CreateAccount extends StatefulWidget {

  final bool fromAnonymous;

  const CreateAccount({super.key, this.fromAnonymous = false});

  @override
  State<CreateAccount> createState() => _CreateAccountState();

}

class _CreateAccountState extends State<CreateAccount> {

  var _email = '';
  var _password = '';
  var _confirmPassword = '';
  var _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: false, child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text('Create Account', style: Theme.of(context).textTheme.displayLarge!),
      ),
      body: ContentContainer(child: Column(children: [
        TextField(
          style: Theme.of(context).textTheme.displayMedium!,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'email',
            hintStyle: Theme.of(context).textTheme.labelMedium!
          ),
          onChanged: (value) {
            _email = value.toLowerCase();
          },
        ),
        const SizedBox(height: 20.0),
        TextField(
          style: Theme.of(context).textTheme.displayMedium!,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'password',
            hintStyle: Theme.of(context).textTheme.labelMedium!
          ),
          onChanged: (value) {
            _password = value;
          }
        ),
        const SizedBox(height: 20.0),
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
        const SizedBox(height: 50.0),
        Row(children: [
          const SizedBox(width: 50.0),
          Expanded(child: ElevatedButton(
            onPressed: () async {
              if (_loading) {
                return;
              }
              
              if (_password != _confirmPassword) {
                showDialog(context: context, builder: (context) => const ErrorDialog(message: 'Passwords do not match'));
                return;
              }

              if (!mounted) return;
              setState(() {
                _loading = true;
              });

              if (await checkIfEmailExists(email: _email)) {
                (() {
                  showDialog(context: context, builder: (context) => const ErrorDialog(message: 'Email already exists'));
                })();
                if (!mounted) return;
                setState(() {
                  _loading = false;
                });
                return;
              }
              try {
                if (widget.fromAnonymous) {
                  final credential = EmailAuthProvider.credential(email: _email, password: _password);
                  await FirebaseAuth.instance.currentUser!.linkWithCredential(credential);
                } else {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: _email,
                    password: _password
                  );
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: _email,
                    password: _password
                  );
                  await createUser(email: _email);
                }
                
                (() {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const Home()
                  ));
                })();
              } on FirebaseAuthException catch (e) {
                setState(() {
                  _loading = false;
                });
                (() {
                  showDialog(context: context, builder: (context) => ErrorDialog(message: e.message ?? ''));
                })();
              }
            },
            child: _loading ? const SpinKitThreeBounce(color: Colors.white30, size: 30.0) : Text('Create account', style: Theme.of(context).textTheme.displayMedium!),
          )),
          const SizedBox(width: 50.0)
        ])
      ])),
    ));
  }

}