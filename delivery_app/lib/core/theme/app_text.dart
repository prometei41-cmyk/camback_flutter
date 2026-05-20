import 'package:flutter/material.dart';

class AppText {
  static Text h1(
      String text, {
        Color? color,
        TextAlign? textAlign,
      }) =>
      Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: color ?? Colors.black,
        ),
      );

  static Text h2(
      String text, {
        Color? color,
        TextAlign? textAlign,
      }) =>
      Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: color ?? Colors.black,
        ),
      );

  static Text h3(
      String text, {
        Color? color,
        TextAlign? textAlign,
      }) =>
      Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: color ?? Colors.black,
        ),
      );

  static Text body(
      String text, {
        Color? color,
        TextAlign? textAlign,
        int? maxLines,
        TextOverflow? overflow,
      }) =>
      Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: color ?? Colors.black,
        ),
      );

  static Text caption(
      String text, {
        Color? color,
        TextAlign? textAlign,
      }) =>
      Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: color ?? Colors.grey,
        ),
      );
}
