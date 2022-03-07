import 'dart:math';

import 'package:a5er/a5_widget.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ini/ini.dart';

void main() {
  runApp(const A5ERApp());
}

class A5ERApp extends StatelessWidget {
  const A5ERApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'A5:ER Viewer',
      home: BaseWidget(),
    );
  }
}

class BaseWidget extends StatefulWidget {
  const BaseWidget({Key? key}) : super(key: key);

  @override
  State<BaseWidget> createState() => BaseState();
}

class BaseState extends State<BaseWidget> {
  bool _dragging = false;
  bool _hasFile = false;
  final List<Config> _manager = [];
  final List<Config> entities = [];
  final List<Config> relations = [];
  final List<Config> _line = [];
  Rect rectCanvas = const Rect.fromLTWH(0, 0, 0, 0);

  resetConfig() {
    _manager.clear();
    entities.clear();
    relations.clear();
    _line.clear();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: DropTarget(
      onDragDone: (detail) async {
        if (kDebugMode) {
          for (final file in detail.files) {
            // print('  ${file.path} ${file.name}'
            //     '  ${await file.lastModified()}'
            //     '  ${await file.length()}'
            //     '  ${file.mimeType}');
            final String fileContent = await file.readAsString();
            resetConfig();
            var sections = fileContent.split("\r\n\r\n");

            setState(() {
              for (var section in sections) {
                Config config = Config.fromString(section);
                if (config.sections().isNotEmpty) {
                  final name = config.sections().first;
                  switch (name) {
                    case 'Manager':
                      _manager.add(config);
                      break;
                    case 'Entity':
                      var lines = section.split("\r\n");
                      var i = 0;
                      for (var line in lines) {
                        if (line.startsWith("Field")) {
                          config.set(
                            'Entity',
                            'Field' + i.toString(),
                            line.substring(6),
                          );
                          i++;
                        }
                      }
                      config.set(
                        'Entity',
                        'FieldCount',
                        i.toString(),
                      );
                      config.removeOption('Entity', 'Field');
                      entities.add(config);
                      break;
                    case 'Relation':
                      relations.add(config);
                      break;
                    case 'Line':
                      _line.add(config);
                      break;
                  }
                }
              }
            });
            List<int> xStart = [];
            List<int> yStart = [];
            List<int> xEnd = [];
            List<int> yEnd = [];
            for (var entity in entities) {
              var position = entity.get("Entity", "Position");
              // print(position);
              var pos = position?.split(",");
              // print(pos?.length);
              xStart.add(int.parse(pos![1]));
              yStart.add(int.parse(pos[2]));
              if (pos.length == 5) {
                // print(pos);
                xEnd.add(int.parse(pos[1]) + int.parse(pos[3]));
                yEnd.add(int.parse(pos[2]) + int.parse(pos[4]));
              }
            }
            // set canvas rect
            setState(() {
              rectCanvas = Rect.fromLTWH(
                // xStart.reduce(min).toDouble(),
                // yStart.reduce(min).toDouble(),
                0,
                0,
                (xEnd.reduce(max) + xStart.reduce(min)).toDouble(),
                (yEnd.reduce(max) + yStart.reduce(min)).toDouble(),
              );
              _hasFile = true;
            });
          }
        }
      },
      onDragEntered: (detail) {
        if (kDebugMode) {
          print(detail);
        }
        setState(() {
          _dragging = true;
        });
      },
      onDragExited: (detail) {
        if (kDebugMode) {
          print(detail);
        }
        setState(() {
          _dragging = false;
        });
      },
      child: Container(
          height: size.height,
          width: size.width,
          color: _dragging ? Colors.blue.withOpacity(0.4) : Colors.black26,
          child: Stack(
            children: [
              A5Widget(
                const {},
                rectCanvas: rectCanvas,
                entities: entities,
                relations: relations,
              ),
              Center(
                  child: _hasFile
                      ? const Text("")
                      : const Text("Drop A5:ER file here!"))
            ],
          )),
    ));
  }
}
