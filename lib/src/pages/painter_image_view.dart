import 'package:flutter/material.dart';

class PainterImageView extends StatefulWidget {
  final Widget child;
  const PainterImageView({super.key, required this.child});

  @override
  State<PainterImageView> createState() => _PainterImageViewState();
}

class _PainterImageViewState extends State<PainterImageView> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back)),
            ),
            Expanded(
              child: Hero(
                tag: "imageHero",
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
