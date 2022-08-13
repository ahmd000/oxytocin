import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextApp extends StatelessWidget {
 late String? text;
 late FontWeight? fontWeight;
 late double? fontSize;
 late TextAlign? textAlign;
 late double? height;
 late Color? fontColor;

   TextApp(
      { this.text,
      this.fontWeight = FontWeight.normal,
       this.fontSize,
      this.textAlign = TextAlign.center,
      this.height = 1,
       this.fontColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      text!,
      softWrap: true,
      textAlign: textAlign,
      style: GoogleFonts.abel(
        fontWeight:fontWeight,

        fontSize: fontSize,
        color: fontColor,
      ),
    );
  }
}

