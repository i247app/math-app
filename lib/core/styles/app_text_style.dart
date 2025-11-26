import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_font_size.dart';

class AppTextStyle {
  static final TextStyle title = GoogleFonts.nunito(
    fontSize: AppFontSize.xxLarge,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle title2 = GoogleFonts.nunito(
    fontSize: AppFontSize.xxxxxxxxLarge,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle title3 = GoogleFonts.nunito(
    fontSize: AppFontSize.xxxxxLarge,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle title4 = GoogleFonts.nunito(
    fontSize: AppFontSize.xxxxLarge,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle subtitle = GoogleFonts.nunito(
    fontSize: AppFontSize.large,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle body = GoogleFonts.nunito(
    fontSize: AppFontSize.medium,
  );

  static final TextStyle caption = GoogleFonts.nunito(
    fontSize: AppFontSize.small,
  );

  static final TextStyle button = GoogleFonts.nunito(
    fontSize: AppFontSize.medium,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle error = GoogleFonts.nunito(
    fontSize: AppFontSize.small,
    color: Colors.red,
  );

  static final TextStyle success = GoogleFonts.nunito(
    fontSize: AppFontSize.small,
    color: Colors.greenAccent,
  );

  static final TextStyle warning = GoogleFonts.nunito(
    fontSize: AppFontSize.small,
    color: Colors.orangeAccent,
  );

  static final TextStyle info = GoogleFonts.nunito(
    fontSize: AppFontSize.small,
    color: Colors.blueAccent,
  );

  static final TextStyle link = GoogleFonts.nunito(
    fontSize: AppFontSize.small,
    color: Colors.blueAccent,
    decoration: TextDecoration.underline,
  );

  static final TextStyle linkBold = GoogleFonts.nunito(
    fontSize: AppFontSize.small,
    color: Colors.blue,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.underline,
  );

  static final TextStyle linkBoldUnderline = GoogleFonts.nunito(
    fontSize: AppFontSize.small,
    color: Colors.blue,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.underline,
  );

  static final TextStyle linkUnderline = GoogleFonts.nunito(
    fontSize: AppFontSize.small,
    color: Colors.blue,
    decoration: TextDecoration.underline,
  );

  static final TextStyle linkBoldUnderlineWhite = GoogleFonts.nunito(
    fontSize: AppFontSize.small,
    color: Colors.white,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.underline,
  );

  static final TextStyle linkUnderlineWhite = GoogleFonts.nunito(
    fontSize: AppFontSize.small,
    color: Colors.white,
    decoration: TextDecoration.underline,
  );

  static final TextStyle linkBoldWhite = GoogleFonts.nunito(
    fontSize: AppFontSize.small,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle linkWhite = GoogleFonts.nunito(
    fontSize: AppFontSize.small,
    color: Colors.white,
  );

  static final TextStyle linkBoldUnderlineBlack = GoogleFonts.nunito(
    fontSize: AppFontSize.small,
    color: Colors.black,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.underline,
  );

  static final TextStyle linkUnderlineBlack = GoogleFonts.nunito(
    fontSize: AppFontSize.small,
    color: Colors.black,
    decoration: TextDecoration.underline,
  );

  static TextStyle boldTextStyle() => GoogleFonts.nunito(
    fontSize: AppFontSize.medium,
    fontWeight: FontWeight.w600,
  );
}
