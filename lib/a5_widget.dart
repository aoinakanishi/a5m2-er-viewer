// ignore_for_file: must_be_immutable

import 'package:a5er/a5_canvas_painter.dart';
import 'package:flutter/material.dart';
import 'package:ini/ini.dart';

enum CanvasState { pan, draw }

class A5Widget extends StatefulWidget {
  Rect rectCanvas;
  List<Config> entities;
  List<Config> relations;
  A5Widget(
    Map<Rect, Rect> map, {
    Key? key,
    required this.rectCanvas,
    required this.entities,
    required this.relations,
  }) : super(key: key);

  @override
  _A5WidgetState createState() => _A5WidgetState();
}

class _A5WidgetState extends State<A5Widget> {
  List<Offset> points = [];
  CanvasState canvasState = CanvasState.draw;
  Offset offset = const Offset(0, 0);
  double ratio = 1.0;
  double scale = 1;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    var rWidth = size.width / widget.rectCanvas.right;
    var rHeight = size.height / widget.rectCanvas.bottom;
    if (rWidth < rHeight && rWidth < 1.0) {
      ratio = rWidth;
    } else if (rHeight < 1.0) {
      ratio = rHeight;
    }

    return Scaffold(
      body: SizedBox.expand(
        child: ClipRRect(
          child: InteractiveViewer(
            minScale: 1.0,
            maxScale: 5.0,
            child: CustomPaint(
              painter: A5CanvasPainter(
                ratio: ratio,
                screenSize: size,
                rectCanvas: widget.rectCanvas,
                entities: widget.entities,
                relations: widget.relations,
                points: points,
                offset: offset,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
