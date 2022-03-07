// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ini/ini.dart';

Map<String, List<String>> fieldNameCache = {};
Map<String, List<String>> foreignKeys = {};
Map<String, Rect> tableSize = {};

class A5CanvasPainter extends CustomPainter {
  static const baseBackgroundColor = Color.fromARGB(255, 255, 251, 241);
  static const canvasBackgroundColor = Colors.white;

  double ratio;
  Size screenSize;
  Rect rectCanvas;
  List<Config> entities;
  List<Config> relations;
  List<Offset> points;
  Offset offset;

  // Paint
  Paint background = Paint()..color = baseBackgroundColor;
  Paint backgroundCanvas = Paint()..color = canvasBackgroundColor;
  Paint paintCanvasBorder = Paint()
    ..color = const Color.fromARGB(255, 227, 225, 227)
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true
    ..strokeWidth = 1.0;
  Paint paintEntiryBorder = Paint()
    ..color = const Color.fromARGB(255, 128, 127, 128)
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true
    ..strokeWidth = 1.0;
  Paint paintRelation = Paint()
    ..color = Colors.black
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true
    ..strokeWidth = 0.2;
  Paint paintRed = Paint()
    ..color = Colors.red
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true
    ..strokeWidth = 1.0;

  // Text
  TextStyle textStyle = const TextStyle(
    color: Colors.black,
    fontSize: 16,
  );
  TextStyle textStyleFields = const TextStyle(
    color: Colors.black,
    fontSize: 17,
  );
  Offset tableNameOffset = const Offset(0.0, -24.0);
  TextStyle textStyleTag = const TextStyle(
    color: Color.fromARGB(255, 166, 206, 183),
    fontSize: 16,
  );
  Offset tableTagOffset = const Offset(10.0, 3.0);
  int fieldHeight = 25;
  int fieldOffset = 4;

  A5CanvasPainter({
    required this.ratio,
    required this.screenSize,
    required this.rectCanvas,
    required this.entities,
    required this.relations,
    required this.points,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (foreignKeys.isEmpty) {
      for (var relation in relations) {
        String entity2 = relation.get("Relation", "Entity2")!;
        String fields2 = relation.get("Relation", "Fields2")!;
        var fields = fields2.split(",");
        if (foreignKeys.containsKey(entity2)) {
          foreignKeys[entity2]!.addAll(fields);
        } else {
          foreignKeys[entity2] = fields;
        }
      }
    }

    // Text
    TextStyle textStyle = TextStyle(
      color: Colors.black,
      fontSize: 16 * ratio,
      fontFamily: GoogleFonts.sawarabiGothic().fontFamily,
    );
    TextStyle textStyleFields = TextStyle(
      color: Colors.black,
      fontSize: 17 * ratio,
      fontFamily: GoogleFonts.sawarabiGothic().fontFamily,
    );
    Offset tableNameOffset = Offset(0.0 * ratio, -24.0 * ratio);
    TextStyle textStyleTag = TextStyle(
      color: const Color.fromARGB(255, 166, 206, 183),
      fontSize: 16 * ratio,
      fontFamily: GoogleFonts.sawarabiGothic().fontFamily,
    );
    Offset tableTagOffset = Offset(10.0 * ratio, 3.0 * ratio);
    double fieldHeight = 25 * ratio;
    double fieldOffset = 4 * ratio;

    Rect rectBackground = Rect.fromLTWH(0, 0, size.width, size.height);

    // Canvas rect with offset
    Rect rectCanvasWithOffset = Rect.fromLTWH(
      (rectCanvas.left + offset.dx) * ratio,
      (rectCanvas.top + offset.dy) * ratio,
      (rectCanvas.right) * ratio,
      (rectCanvas.bottom) * ratio,
    );
    // Draw background
    canvas.drawRect(rectBackground, background);
    canvas.clipRect(rectCanvasWithOffset);

    // Draw Canvas area
    canvas.drawRect(rectCanvasWithOffset, backgroundCanvas);
    canvas.drawRect(rectCanvasWithOffset, paintCanvasBorder);

    // Entity
    for (var entity in entities) {
      var tableName = entity.get("Entity", "PName");
      var position = entity.get("Entity", "Position");
      var pos = position?.split(",");

      // Table
      Offset entityOffset = Offset(
        (double.parse(pos![1]) + offset.dx) * ratio,
        (double.parse(pos[2]) + offset.dy) * ratio,
      );

      if (pos.length == 5) {
        Rect entityRect = entityOffset &
            Size(
              double.parse(pos[3]) * ratio,
              double.parse(pos[4]) * ratio,
            );

        canvas.drawRect(entityRect, paintEntiryBorder);
        canvas.drawLine(
            Offset(
              (entityOffset.dx),
              (entityOffset.dy + fieldHeight),
            ),
            Offset(
              (entityOffset.dx + double.parse(pos[3]) * ratio),
              (entityOffset.dy + fieldHeight),
            ),
            paintEntiryBorder);

        tableSize[tableName!] = entityRect;
      }

      // LName
      String lName = entity.get("Entity", "LName")!;
      final textPainterLName = TextPainter(
        text: TextSpan(
          text: lName,
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      textPainterLName.layout(
        minWidth: 0,
        maxWidth: size.width * ratio,
      );
      textPainterLName.paint(
          canvas,
          Offset(
            (entityOffset.dx + tableNameOffset.dx) * 1,
            (entityOffset.dy + tableNameOffset.dy) * 1,
          ));

      // Max position
      double maxWidth = textPainterLName.size.width;
      double maxHeight = textPainterLName.size.height;

      // Tag
      var tag = entity.get("Entity", "Tag");
      if (tag != null) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: "<" + tag + ">",
            style: textStyleTag,
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(
          minWidth: 0,
          maxWidth: size.width * ratio,
        );
        textPainter.paint(
            canvas,
            Offset(
              (entityOffset.dx +
                      tableNameOffset.dx +
                      textPainterLName.size.width +
                      tableTagOffset.dx) *
                  1,
              (entityOffset.dy + tableNameOffset.dy + tableTagOffset.dy) * 1,
            ));

        if (maxWidth < textPainter.size.width) {
          maxWidth = textPainter.size.width;
        }
        if (maxHeight < textPainter.size.height) {
          maxHeight = textPainter.size.height;
        }
      }
      // Field
      if (!fieldNameCache.containsKey(tableName)) {
        List<String> fileds = [];
        int fieldCount = int.parse(entity.get("Entity", "FieldCount")!);
        for (int i = 0; i < fieldCount; i++) {
          var field = entity.get("Entity", "Field" + i.toString());
          List<String> item = field!.split(",");
          String fieldName = item[1].substring(1, item[1].length - 1);
          String foreignKey = "";
          if (foreignKeys.containsKey(tableName)) {
            if (foreignKeys[tableName]!.contains(fieldName)) {
              foreignKey = " <FK>";
            }
          }
          // NOT NULL
          if (item.length > 3) {
            if (item[3] == '"NOT NULL"') {
              fileds.add(
                  "■" + item[0].substring(1, item[0].length - 1) + foreignKey);
            } else {
              fileds.add(
                  "□" + item[0].substring(1, item[0].length - 1) + foreignKey);
            }
          } else {
            fileds.add(
                "□" + item[0].substring(1, item[0].length - 1) + foreignKey);
          }
        }
        fieldNameCache[tableName!] = fileds;
      }
      // Field Name
      final textPainterField = TextPainter(
        text: TextSpan(
          text: fieldNameCache[tableName]!.join("\n"),
          style: textStyleFields,
        ),
        textDirection: TextDirection.ltr,
      );
      textPainterField.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      textPainterField.paint(
          canvas,
          Offset(
            entityOffset.dx + fieldOffset,
            entityOffset.dy,
          ));
      if (maxWidth < textPainterField.size.width) {
        maxWidth = textPainterField.size.width;
      }
      if (maxHeight < textPainterField.size.height) {
        maxHeight = textPainterField.size.height;
      }
      int addOnHeight = fieldNameCache[tableName]!.length > 20 ? 40 : 20;
      // Table
      if (pos.length != 5) {
        maxWidth = maxWidth + addOnHeight * ratio;
        maxHeight = maxHeight + addOnHeight * ratio;
        Rect entityRect = entityOffset &
            Size(
              maxWidth,
              maxHeight,
            );

        canvas.drawRect(entityRect, paintEntiryBorder);
        canvas.drawLine(
            Offset(
              entityOffset.dx,
              entityOffset.dy + fieldHeight,
            ),
            Offset(
              entityOffset.dx + maxWidth,
              entityOffset.dy + fieldHeight,
            ),
            paintEntiryBorder);
        tableSize[tableName!] = entityRect;
      }
    }

    // Relation
    for (var relation in relations) {
      String entity1 = relation.get("Relation", "Entity1")!;
      String entity2 = relation.get("Relation", "Entity2")!;
      int bar1 = int.parse(relation.get("Relation", "Bar1")!);
      int bar2 = int.parse(relation.get("Relation", "Bar2")!);
      int bar3 = int.parse(relation.get("Relation", "Bar3")!);
      var t1 = tableSize[entity1]!;
      var t2 = tableSize[entity2]!;
      if (t1.bottom < t2.top) {
        t2 = Rect.fromLTWH(t2.left, t2.top - fieldHeight, t2.right - t2.left,
            t2.bottom - t2.top);
        final p1 = Offset(
          t1.left + (t1.right - t1.left) * bar1 / 1000,
          t1.bottom,
        );
        final p2 = Offset(
          p1.dx,
          p1.dy + (t2.top - t1.bottom) * bar2 / 1000,
        );
        final p4 = Offset(
          t2.left + (t2.right - t2.left) * bar3 / 1000,
          t2.top,
        );
        final p3 = Offset(
          p4.dx,
          p2.dy,
        );
        canvas.drawLine(p1, p2, paintRelation);
        canvas.drawLine(p2, p3, paintRelation);
        canvas.drawLine(p3, p4, paintRelation);
      } else if (t1.top > t2.bottom) {
        // T1の左上からT2の左下
        final p1 = Offset(
          t1.left + (t1.right - t1.left) * bar1 / 1000,
          t1.top,
        );
        final p2 = Offset(
          p1.dx,
          p1.dy - (t1.top - t2.bottom) * (1000 - bar2) / 1000,
        );
        final p4 = Offset(
          t2.left + (t2.right - t2.left) * bar3 / 1000,
          t2.bottom,
        );
        final p3 = Offset(
          p4.dx,
          p2.dy,
        );
        canvas.drawLine(p1, p2, paintRelation);
        canvas.drawLine(p2, p3, paintRelation);
        canvas.drawLine(p3, p4, paintRelation);
      } else if (t1.left > t2.right) {
        // T1の左上からT2の右上
        final p1 = Offset(
          t1.left,
          t1.top + (t1.bottom - t1.top) * bar1 / 1000,
        );
        final p2 = Offset(
          p1.dx - (t1.left - t2.right) * (1000 - bar2) / 1000,
          p1.dy,
        );
        final p4 = Offset(
          t2.right,
          t2.top + (t2.bottom - t2.top) * bar3 / 1000,
        );
        final p3 = Offset(
          p2.dx,
          p4.dy,
        );
        canvas.drawLine(p1, p2, paintRelation);
        canvas.drawLine(p2, p3, paintRelation);
        canvas.drawLine(p3, p4, paintRelation);
      } else {
        // T1の右上からT2の左上
        final p1 = Offset(
          t1.right,
          t1.top + (t1.bottom - t1.top) * bar1 / 1000,
        );
        final p2 = Offset(
          p1.dx + (t2.left - t1.right) * bar2 / 1000,
          p1.dy,
        );
        final p4 = Offset(
          t2.left,
          t2.top + (t2.bottom - t2.top) * bar3 / 1000,
        );
        final p3 = Offset(
          p2.dx,
          p4.dy,
        );
        canvas.drawLine(p1, p2, paintRelation);
        canvas.drawLine(p2, p3, paintRelation);
        canvas.drawLine(p3, p4, paintRelation);
      }
    }
  }

  @override
  bool shouldRepaint(A5CanvasPainter oldDelegate) {
    return true;
  }
}
