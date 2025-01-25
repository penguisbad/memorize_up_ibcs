import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:memorize_up/createaccount.dart';
import 'package:memorize_up/home.dart';
import 'package:memorize_up/model/database.dart';
import 'package:memorize_up/resetpassword.dart';
import 'package:memorize_up/util/contentcontainer.dart';
import 'package:memorize_up/util/errordialog.dart';

class SignIn extends StatefulWidget {

  final bool reauthenticate;

  const SignIn({super.key, this.reauthenticate = false});

  @override
  State<SignIn> createState() => _SignInState();

}

class _SignInState extends State<SignIn> {

  var _email = '';
  var _password = '';
  var _loadingSignIn = false;

  @override
  void initState() {
    super.initState();
    _loadingSignIn = false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: false, child: Scaffold(
      appBar: AppBar(
        leading: widget.reauthenticate ? IconButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          icon: const Icon(Icons.arrow_back)
        ) : const SizedBox(),
        title: Text('Sign In', style: Theme.of(context).textTheme.displayLarge!),
      ),
      body: ContentContainer(child: ListView(children: [
        TextField(
          style: Theme.of(context).textTheme.displayMedium!,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'email',
            hintStyle: Theme.of(context).textTheme.labelMedium
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
          },
        ),
        const SizedBox(height: 50.0),
        Row(children: [
          const SizedBox(width: 50.0),
          Expanded(child: ElevatedButton(
            onPressed: () async {
              if (_loadingSignIn || !mounted) {
                return;
              }
              try {
                setState(() {
                  _loadingSignIn = true;
                });

                if (widget.reauthenticate) {
                  final credential = EmailAuthProvider.credential(email: _email, password: _password);

                  await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(credential);
                  (() {
                    Navigator.pop(context, true);
                  })();
                  return;
                } else {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: _email,
                    password: _password
                  );
                  await updateUserEmail(email: FirebaseAuth.instance.currentUser!.email!);
                  
                }
                
              } on FirebaseAuthException catch (e) {
                late String message;
                if (e.code == 'invalid-credential' || e.code == 'invalid-email' 
                    || e.code == 'wrong-password' || e.code == 'wrong-email' || e.code == 'user-not-found') {
                  message = 'The email or password is invalid';
                } else {
                  message = e.message ?? 'no message';
                }
                if (!mounted) return;
                setState(() {
                  _loadingSignIn = false;
                });
                (() {
                  showDialog(context: context, builder: (context) => ErrorDialog(message: message));
                })();
                return;
              } on Exception catch (e) {
                FirebaseCrashlytics.instance.recordError(e, null, reason: e.toString());
                if (!mounted) return;
                setState(() {
                  _loadingSignIn = false;
                });
                (() {
                  showDialog(context: context, builder: (context) => ErrorDialog(message: e.toString()));
                })();
                return;
              }

              if (!mounted) return;
              (() {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()));
              })();

            },
            child: _loadingSignIn ? const SpinKitThreeBounce(color: Colors.white30, size: 30.0) : Text('Sign In', style: Theme.of(context).textTheme.displayMedium!),
          )),
          const SizedBox(width: 50.0)
        ]),
        const SizedBox(height: 20.0),
        Row(children: [
          const SizedBox(width: 50.0),
          Expanded(child: ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateAccount()));
            },
            child: Text('Create account', style: Theme.of(context).textTheme.displayMedium!),
          )),
          const SizedBox(width: 50.0)
          ]),
          const SizedBox(height: 20.0),
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => const ResetPassword()
              ));
            }, 
            child: Text('Reset password', style: Theme.of(context).textTheme.labelMedium!)
          ),
          const SizedBox(height: 50.0)
        ])
      )),
    );
  }

}