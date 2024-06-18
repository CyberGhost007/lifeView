import 'package:flutter/material.dart';
import '../services/themes/app_colors.dart';
import 'dynamic_text.dart';
import 'spring_button.dart';

class DynamicButton extends StatefulWidget {
  final Widget? child;
  final String? title;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final List<Color>? backgroundGradientColor;
  final double? width;
  final double height;
  const DynamicButton({
    Key? key,
    this.child,
    this.backgroundColor,
    this.onPressed,
    this.title,
    this.backgroundGradientColor,
    this.width,
    this.height = 48,
  }) : super(key: key);

  @override
  State<DynamicButton> createState() => _DynamicButtonState();
}

class _DynamicButtonState extends State<DynamicButton> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SpringButton(
      SpringButtonType.onlyScale,
      Container(
        height: widget.height,
        width: widget.width ?? size.width * .8,
        decoration: widget.backgroundGradientColor == null
            ? BoxDecoration(
                color:
                    widget.backgroundColor ?? AppColors.appButtonPrimaryColor,
                borderRadius: BorderRadius.circular(100),
              )
            : BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.backgroundGradientColor ??
                      AppColors.themes.first.gradient!,
                ),
              ),
        child: Center(
          child: widget.child ??
              DynamicText(
                text: widget.title ?? "",
                color: Colors.white,
                fontSize: 17,
              ),
        ),
      ),
      onTap: () => widget.onPressed!(),
      useCache: true,
      alignment: Alignment.center,
      scaleCoefficient: 0.75,
      duration: 1000,
    );
  }
}
