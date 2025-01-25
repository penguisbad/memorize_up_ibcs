import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorize_up/util/contentcontainer.dart';
import 'package:memorize_up/util/errordialog.dart';

class ResetPassword extends StatefulWidget {

  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();

}

class _ResetPasswordState extends State<ResetPassword> {

  var _email = '';

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
        title: Text('Reset password', style: Theme.of(context).textTheme.displayLarge!),
      ),
      body: ContentContainer(child: Column(children: [
        const SizedBox(height: 50.0),
        TextField(
          style: Theme.of(context).textTheme.displayMedium!,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'email',
            hintStyle: Theme.of(context).textTheme.labelMedium!
          ),
          onChanged: (value) {
            _email = value;
          },
        ),
        const SizedBox(height: 20.0),
        Row(children: [
          const SizedBox(width: 50.0),
          Expanded(child: ElevatedButton(
            onPressed: () {
              try {
                FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
                showDialog(context: context, builder: (context) => AlertDialog(
                  content: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text('Reset link sent', style: Theme.of(context).textTheme.displayLarge!, textAlign: TextAlign.center)
                  ),
                  actions: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      }, 
                      child: Text('Close', style: Theme.of(context).textTheme.displayMedium!)
                    )
                  ],
                ));
              } on FirebaseAuthException catch (e) {
                showDialog(context: context, builder: (context) => ErrorDialog(message: e.message ?? 'no message'));
              }
              
            },
            child: Text('Send reset link', style: Theme.of(context).textTheme.displayMedium!,)
          )),
          const SizedBox(width: 50.0)
        ])
      ])),
    ));
  }

}