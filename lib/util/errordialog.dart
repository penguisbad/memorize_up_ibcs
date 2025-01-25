import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {

  final String message;

  const ErrorDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text('Error', style: Theme.of(context).textTheme.displayLarge!)),
      content: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Text(message, style: Theme.of(context).textTheme.displayMedium!, textAlign: TextAlign.center, overflow: TextOverflow.visible)
      ),
      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Close', style: Theme.of(context).textTheme.displayMedium!),
        )
      ],
    );
  }

}