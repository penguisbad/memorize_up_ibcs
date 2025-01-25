import 'package:flutter/material.dart';

class ContentContainer extends StatefulWidget {

  final Widget child;
  final bool showAds;

  const ContentContainer({super.key, required this.child, this.showAds = false});

  @override
  State<ContentContainer> createState() => _ContentContainerState();

}


class _ContentContainerState extends State<ContentContainer> {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 0.0),
      child: Column(
        children: [
          Expanded(child: Center(child: widget.child))
        ]
      ),
    ));
  }

}