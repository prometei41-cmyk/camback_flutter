// delivery_app/lib/core/theme/app_text.dart

import 'package:flutter/material.dart';

class AppText {
  // Вспомогательная функция для применения lineHeight
  static TextStyle _applyLineHeight(TextStyle baseStyle, double? lineHeight) {
    if (lineHeight == null || baseStyle.fontSize == null) {
      return baseStyle;
    }
    // height в TextStyle соответствует lineHeight
    return baseStyle.copyWith(height: lineHeight);
  }

  // Универсальный метод для создания Text виджета
  static Text _createTextWidget(
      String data, {
        Key? key,
        TextStyle? style, // Стиль, который может быть передан извне (например, Theme)
        StrutStyle? strutStyle,
        TextDirection? textDirection,
        TextAlign? textAlign,
        TextOverflow? overflow,
        int? maxLines,
        double? textScaleFactor,
        String? semanticsLabel,
        TextWidthBasis? textWidthBasis,
        Locale? locale,
        bool? softWrap,
        // Наши кастомные параметры
        double fontSize = 14.0,
        Color? color,
        FontWeight? fontWeight,
        double? lineHeight,
      }) {
    // Создаем базовый TextStyle
    TextStyle baseStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? Colors.black, // Цвет по умолчанию черный
    );

    // Применяем lineHeight, если он есть
    if (lineHeight != null) {
      baseStyle = _applyLineHeight(baseStyle, lineHeight);
    }

    // Объединяем переданный стиль (если есть) с нашими параметрами
    if (style != null) {
      baseStyle = style.copyWith(
        fontSize: style.fontSize ?? fontSize,
        fontWeight: style.fontWeight ?? fontWeight,
        color: style.color ?? color ?? Colors.black,
        height: style.height ?? baseStyle.height,
      );
    }

    return Text(
      data,
      key: key,
      style: baseStyle,
      strutStyle: strutStyle,
      textDirection: textDirection,
      textAlign: textAlign ?? TextAlign.start,
      overflow: overflow,
      maxLines: maxLines,
      textScaleFactor: textScaleFactor,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      locale: locale,
      softWrap: softWrap,
    );
  }

  // --- Наши кастомные стили ---

  // Заголовок первого уровня (например, как в WelcomeScreen)
  static Text h1(
      String text, {
        Key? key,
        Color? color,
        TextAlign? textAlign,
        double fontSize = 28, // Размер по умолчанию для h1
        FontWeight fontWeight = FontWeight.w700, // Жирность для h1
        double? lineHeight,
      }) =>
      _createTextWidget(
        text,
        key: key,
        fontSize: fontSize,
        color: color,
        textAlign: textAlign,
        fontWeight: fontWeight,
        lineHeight: lineHeight,
      );

  // Заголовок второго уровня (например, как в ProductDetailScreen)
  static Text h2(
      String text, {
        Key? key,
        Color? color,
        TextAlign? textAlign,
        double fontSize = 24, // Размер по умолчанию для h2
        FontWeight fontWeight = FontWeight.w600, // Жирность для h2
        double? lineHeight,
      }) =>
      _createTextWidget(
        text,
        key: key,
        fontSize: fontSize,
        color: color,
        textAlign: textAlign,
        fontWeight: fontWeight,
        lineHeight: lineHeight,
      );

  // Заголовок третьего уровня (например, для подзаголовков)
  static Text h3(
      String text, {
        Key? key,
        Color? color,
        TextAlign? textAlign,
        double fontSize = 20, // Размер по умолчанию для h3
        FontWeight fontWeight = FontWeight.w600, // Жирность для h3
        double? lineHeight,
      }) =>
      _createTextWidget(
        text,
        key: key,
        fontSize: fontSize,
        color: color,
        textAlign: textAlign,
        fontWeight: fontWeight,
        lineHeight: lineHeight,
      );

  // Полужирный текст (используется для названий продуктов в карточках/деталях)
  static Text bold(
      String text, {
        Key? key,
        Color? color,
        TextAlign? textAlign,
        double fontSize = 16, // Размер по умолчанию
        FontWeight fontWeight = FontWeight.bold, // Используем FontWeight.bold
        double? lineHeight,
      }) =>
      _createTextWidget(
        text,
        key: key,
        fontSize: fontSize,
        color: color,
        textAlign: textAlign,
        fontWeight: fontWeight,
        lineHeight: lineHeight,
      );

  // Полужирный текст средней жирности (используется для некоторых подзаголовков)
  static Text semiBold(
      String text, {
        Key? key,
        Color? color,
        TextAlign? textAlign,
        double fontSize = 16, // Размер по умолчанию
        FontWeight fontWeight = FontWeight.w600, // Средняя жирность
        double? lineHeight,
      }) =>
      _createTextWidget(
        text,
        key: key,
        fontSize: fontSize,
        color: color,
        textAlign: textAlign,
        fontWeight: fontWeight,
        lineHeight: lineHeight,
      );

  // Обычный текст (используется для описаний, как в ProductDetailScreen)
  static Text medium(
      String text, {
        Key? key,
        Color? color,
        TextAlign? textAlign,
        double fontSize = 14, // Размер по умолчанию
        FontWeight fontWeight = FontWeight.w500, // Средняя жирность
        double? lineHeight,
      }) =>
      _createTextWidget(
        text,
        key: key,
        fontSize: fontSize,
        color: color,
        textAlign: textAlign,
        fontWeight: fontWeight,
        lineHeight: lineHeight,
      );

  // Регулярный текст (используется для второстепенной информации, как в ProductDetailScreen)
  static Text regular(
      String text, {
        Key? key,
        Color? color,
        TextAlign? textAlign,
        double fontSize = 14, // Размер по умолчанию
        FontWeight fontWeight = FontWeight.normal, // Обычный вес
        double? lineHeight,
      }) =>
      _createTextWidget(
        text,
        key: key,
        fontSize: fontSize,
        color: color,
        textAlign: textAlign,
        fontWeight: fontWeight,
        lineHeight: lineHeight,
      );
}
