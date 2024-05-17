// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class RoombaWidget extends StatefulWidget {
  //const RoombaWidget({super.key});

  const RoombaWidget({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  State<RoombaWidget> createState() => _RoombaWidgetState();
}

class _RoombaWidgetState extends State<RoombaWidget> {
  // c40 e31
  var dirty = [];
  var origin = 56;
  var current = 56;
  var battery = 1000;
  var score = 0;
  var logs = [];

  var path = [];
  var controller = TextEditingController();
  Map<int, List<int>> route = {};

  @override
  void initState() {
    super.initState();
    dirty.sort();
    generateUniqueRandomNumbers(0, 64, 18);
    //dirty.add(56);
    //makePaths();
  }

  makePaths() {
    bool isLast = false;
    if (dirty.isEmpty) {
      dirty.add(origin);
      isLast = true;
    }
    for (int i = 0; i < dirty.length; i++) {
      var tempPath = <int>[];
      tempPath.add(current);
      var element = dirty[i];
      var diff;

      if (element < current) {
        //move up or left
        diff = current - element;
        var q = diff ~/ 8;
        var r = diff % 8;
        if (q > 0) {
          for (int i = 0; i < q; i++) {
            tempPath.add(tempPath.last - 8);
          }
          checkIfSameLineOrMoveUp(r, element, tempPath);
        } else {
          checkIfSameLineOrMoveUp(r, element, tempPath);
        }
      } else {
        //move down or right
        diff = element - current;
        var q = diff ~/ 8;
        var r = diff % 8;
        if (q > 0) {
          for (int i = 0; i < q; i++) {
            tempPath.add(tempPath.last + 8);
          }
          checkIfSameLineOrMoveDown(r, element, tempPath);
        } else {
          // check if number is in same line or next line
          checkIfSameLineOrMoveDown(r, element, tempPath);
        }
      }
      route[dirty[i]] = tempPath;
    }
    var distance = route[route.keys.first]!.length;
    var number = route.keys.first;
    route.forEach((key, value) {
      if (value.isEmpty || value.length < distance) {
        distance = value.length;
        number = key;
      }
    });
    var array = route[number];
    var initialBattery = battery;
    if (distance == 0) {
      path.add(number);
      current = number;
      logs.add('Remove $number directly');
    } else {
      for (int i = 0; i < distance; i++) {
        path.add(array![i]);
        current = array[i];
        if (i > 0) {
          battery = battery - 10;
          score = score - 1;
        }
      }
      logs.add(
          'Clean tile $number using $array initial battery $initialBattery current battery $battery and Current Score $score');
    }
    route.remove(number);
    dirty.remove(number);
    if (!isLast) {
      score = score + 10;
    }
    setState(() {});
    //logs.add(route);
  }

  generateUniqueRandomNumbers(int min, int max, int count) {
    if (count > max - min + 1) {
      throw ArgumentError("Count must be less than or equal to max - min + 1");
    }

    Set<int> uniqueNumbers = Set<int>();
    Random random = Random();

    while (uniqueNumbers.length < count) {
      var uniqueNo = min + random.nextInt(max - min + 1);
      uniqueNumbers.add(uniqueNo);
      dirty.add(uniqueNo);
    }
  }

  @override
  Widget build(BuildContext context) {
    controller.text = '$current';
    return Container(
        height: widget.height,
        width: widget.width,
        child: Scaffold(
          body: Column(
            children: [
              Row(
                children: [
                  Card(
                    child: Column(
                      children: [
                        Text('Battery'),
                        Text('$battery'),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      children: [
                        Text('Current'),
                        Text('$current'),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      children: [
                        Text('Score'),
                        Text('$score'),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        makePaths();
                      },
                      child: const Text('Next Position')),
                ],
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        itemCount: 64,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                crossAxisCount: 8),
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            color: path.contains(index)
                                ? Colors.lightBlueAccent
                                : dirty.contains(index)
                                    ? Colors.yellow
                                    : Colors.green,
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text('$index'),
                                ),
                                if (index == current)
                                  const Center(
                                    child: Icon(
                                      Icons.mouse,
                                      color: Colors.white,
                                    ),
                                  )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                        child: ListView.separated(
                            itemBuilder: (context, index) => Text(logs[index]),
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemCount: logs.length))
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  void checkIfSameLineOrMoveUp(int r, int element, List<int> tempPath) {
    // check if number is in same line or previous line
    var array = [];
    int q = tempPath.last ~/ 8;
    for (int i = 0; i < 8; i++) {
      array.add((q * 8) + i);
    }
    if (array.contains(element)) {
      // move on same line
      if (r > 0) {
        for (int i = 0; i < r; i++) {
          tempPath.add(tempPath.last - 1);
        }
      }
    } else {
      // move up
      var tempElement = tempPath.last - 8;
      tempPath.add(tempElement);
      for (int i = 0; i < element - tempElement; i++) {
        tempPath.add(tempElement + i + 1);
      }
    }
  }

  void checkIfSameLineOrMoveDown(int r, int element, List<int> tempPath) {
    // check if number is in same line or previous line
    var array = [];
    int q = tempPath.last ~/ 8;
    for (int i = 0; i < 8; i++) {
      array.add((q * 8) + i);
    }
    if (array.contains(element)) {
      // move on same line
      if (r > 0) {
        for (int i = 0; i < r; i++) {
          tempPath.add(tempPath.last + 1);
        }
      }
    } else {
      // move down
      var tempElement = tempPath.last + 8;
      tempPath.add(tempElement);
      for (int i = 0; i < tempElement - element; i++) {
        tempPath.add(tempElement - i - 1);
      }
    }
  }
}
