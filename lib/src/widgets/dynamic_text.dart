// Flutter imports:
import 'package:flutter/material.dart';

class DynamicText extends StatelessWidget {
  const DynamicText({
    Key? key,
    required this.text,
    this.fontSize,
    this.overflow,
    this.fontWeight,
    this.color,
    this.maxlines,
    this.wrapWords = true,
    this.softwrap = false,
    this.textAlign = TextAlign.start,
    this.padding,
    this.textTheme,
    this.height,
    this.fontFamily = "ProductSan",
    this.onTap,
    this.closeText = false,
    this.italic = false,
  }) : super(key: key);
  final String? text;
  final double? fontSize;
  final double? height;
  final bool? wrapWords;
  final Color? color;
  final bool? softwrap;
  final int? maxlines;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;
  final EdgeInsets? padding;
  final TextStyle? textTheme;
  final bool closeText;
  final bool italic;
  final VoidCallback? onTap;
  final String fontFamily;

  @override
  Widget build(BuildContext context) {
    //comfortaa
    //nunito
    //DMSans
    //Inter
    //ProductSan
    return GestureDetector(
      onTap: onTap,
      key: UniqueKey(),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(0),
        child: Text(
          text ?? '',
          style: textTheme ??
              TextStyle(
                fontSize: fontSize,
                color: color,
                fontFamily: fontFamily,
                fontWeight: fontWeight ?? FontWeight.normal,
                height: height,
                fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                decoration: closeText
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
          overflow: overflow ?? TextOverflow.ellipsis,
          softWrap: softwrap,
          textAlign: textAlign,
          maxLines: maxlines,
        ),
      ),
    );
  }
}
