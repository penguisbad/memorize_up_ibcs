import 'package:flutter/material.dart';
import 'package:memorize_up/calendar.dart';
import 'package:memorize_up/folders.dart';
import 'package:memorize_up/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memorize_up/manageaccount.dart';
import 'package:memorize_up/shared.dart';
import 'package:memorize_up/signin.dart';

class Navigation extends StatelessWidget {

  final int index;

  const Navigation({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: index,
      children: [
        const SizedBox(height: 10.0),
        NavigationDrawerDestination(
          icon: const Icon(Icons.list),
          label: Text('My sets', style: Theme.of(context).textTheme.displayMedium!)
        ),
        const SizedBox(height: 10.0),
        NavigationDrawerDestination(
          icon: const Icon(Icons.folder), 
          label: Text('Folders', style: Theme.of(context).textTheme.displayMedium!)
        ),
        const SizedBox(height: 10.0),
        NavigationDrawerDestination(
          icon: const Icon(Icons.calendar_today),
          label: Text('Calendar', style: Theme.of(context).textTheme.displayMedium!)
        ),
        const SizedBox(height: 10.0),
        NavigationDrawerDestination(
          icon: const Icon(Icons.share),
          label: Text('Shared with me', style: Theme.of(context).textTheme.displayMedium!)
        ),
        const SizedBox(height: 10.0),
        NavigationDrawerDestination(
          icon: const Icon(Icons.account_circle),
          label: Text('Account', style: Theme.of(context).textTheme.displayMedium!),
        ),
        const SizedBox(height: 10.0),
        NavigationDrawerDestination(
          icon: const Icon(Icons.logout),
          label: Text('Sign out', style: Theme.of(context).textTheme.displayMedium!),
        )
      ],
      onDestinationSelected: (index) async {
        if (index == 0) {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => const Home()
          ));
        } else if (index == 1) {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => const Folders()
          ));
        } else if (index == 2) {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => const Calendar()
          ));
        } else if (index == 3) {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => const Shared()
          ));
        } else if (index == 4) {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => const ManageAccount()
          ));
        } else if (index == 5) {
          await FirebaseAuth.instance.signOut();
          (() {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => const SignIn()
            ));
          })();
        }
      },
    );
  }
}