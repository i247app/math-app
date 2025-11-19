import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_font_size.dart';

class AppTextStyle {
  static final TextStyle title = GoogleFonts.heebo(
    fontSize: AppFontSize.xxLarge,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle title2 = GoogleFonts.heebo(
    fontSize: AppFontSize.xxxxxxxxLarge,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle title3 = GoogleFonts.heebo(
    fontSize: AppFontSize.xxxxxLarge,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle title4 = GoogleFonts.heebo(
    fontSize: AppFontSize.xxxxLarge,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle subtitle = GoogleFonts.heebo(
    fontSize: AppFontSize.large,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle body = GoogleFonts.heebo(fontSize: AppFontSize.medium);

  static final TextStyle caption = GoogleFonts.heebo(
    fontSize: AppFontSize.small,
  );

  static final TextStyle button = GoogleFonts.heebo(
    fontSize: AppFontSize.medium,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle error = GoogleFonts.heebo(
    fontSize: AppFontSize.small,
    color: Colors.red,
  );

  static final TextStyle success = GoogleFonts.heebo(
    fontSize: AppFontSize.small,
    color: Colors.greenAccent,
  );

  static final TextStyle warning = GoogleFonts.heebo(
    fontSize: AppFontSize.small,
    color: Colors.orangeAccent,
  );

  static final TextStyle info = GoogleFonts.heebo(
    fontSize: AppFontSize.small,
    color: Colors.blueAccent,
  );

  static final TextStyle link = GoogleFonts.heebo(
    fontSize: AppFontSize.small,
    color: Colors.blueAccent,
    decoration: TextDecoration.underline,
  );

  static final TextStyle linkBold = GoogleFonts.heebo(
    fontSize: AppFontSize.small,
    color: Colors.blue,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.underline,
  );

  static final TextStyle linkBoldUnderline = GoogleFonts.heebo(
    fontSize: AppFontSize.small,
    color: Colors.blue,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.underline,
  );

  static final TextStyle linkUnderline = GoogleFonts.heebo(
    fontSize: AppFontSize.small,
    color: Colors.blue,
    decoration: TextDecoration.underline,
  );

  static final TextStyle linkBoldUnderlineWhite = GoogleFonts.heebo(
    fontSize: AppFontSize.small,
    color: Colors.white,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.underline,
  );

  static final TextStyle linkUnderlineWhite = GoogleFonts.heebo(
    fontSize: AppFontSize.small,
    color: Colors.white,
    decoration: TextDecoration.underline,
  );

  static final TextStyle linkBoldWhite = GoogleFonts.heebo(
    fontSize: AppFontSize.small,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle linkWhite = GoogleFonts.heebo(
    fontSize: AppFontSize.small,
    color: Colors.white,
  );

  static final TextStyle linkBoldUnderlineBlack = GoogleFonts.heebo(
    fontSize: AppFontSize.small,
    color: Colors.black,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.underline,
  );

  static final TextStyle linkUnderlineBlack = GoogleFonts.heebo(
    fontSize: AppFontSize.small,
    color: Colors.black,
    decoration: TextDecoration.underline,
  );

  static TextStyle boldTextStyle() => GoogleFonts.heebo(
    fontSize: AppFontSize.medium,
    fontWeight: FontWeight.w600,
  );
}
