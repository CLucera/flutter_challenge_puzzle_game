import 'dart:math';

import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SixteenApp"),
      ),
      body: GamePanel(),
    );
  }
}

class GamePanel extends StatefulWidget {
  GamePanel({Key? key}) : super(key: key);
  final tileCount = 4;
  final shuffleCount = 10;
  final random = Random();

  @override
  _GamePanelState createState() => _GamePanelState();
}

class _GamePanelState extends State<GamePanel> {
  static const animationDuration = Duration(milliseconds: 350);
  final fastAnimationDuration = const Duration(milliseconds: 150);

  late Duration currentAnimationDuration;
  late List<int> currentTileOrder;
  bool enabled = false;
  bool shouldStart = true;
  bool isEnded = false;

  @override
  void initState() {
    super.initState();
    currentAnimationDuration = animationDuration;
    currentTileOrder = List.generate(
      widget.tileCount * widget.tileCount,
      (index) => index,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final tileSize = constraints.maxHeight / (widget.tileCount);
                  return Stack(
                    children: [
                      for (int i = 0; i < currentTileOrder.length; i++)
                        Align(
                          alignment: _indexToAlignment(i),
                          child: SizedBox(
                            height: tileSize,
                            width: tileSize,
                            child: BackgroundTile(
                              number: i + 1,
                            ),
                          ),
                        ),
                      for (int i = 0; i < currentTileOrder.length; i++)
                        i == _currentTarget
                            ? const SizedBox()
                            : GestureDetector(
                                key: ValueKey(currentTileOrder[i]),
                                onTap: enabled
                                    ? () {
                                        if (_canSwap(i)) {
                                          _swap(i);
                                        }
                                      }
                                    : null,
                                child: AnimatedAlign(
                                  duration: currentAnimationDuration,
                                  curve: Curves.decelerate,
                                  alignment: _indexToAlignment(i),
                                  child: SizedBox(
                                    height: tileSize,
                                    width: tileSize,
                                    child: GameTile(
                                      number: currentTileOrder[i] + 1,
                                    ),
                                  ),
                                ),
                              ),
                      if (shouldStart)
                        StartOverlay(
                          onPressed: _shuffle,
                        ),
                      if (isEnded)
                        EndOverlay(
                          onPressed: _restart,
                        ),
                    ],
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }

  int get _currentTarget {
    return currentTileOrder.indexOf((widget.tileCount * widget.tileCount) - 1);
  }

  int _getColForIndex(int index) {
    return index ~/ widget.tileCount;
  }

  int _getRowForIndex(int index) {
    return index % widget.tileCount;
  }

  int getRandomValidTarget({int? avoidTarget}) {
    var viableOptions = currentTileOrder.where((i) {
      return _canSwap(i) && i != avoidTarget;
    }).toList();
    viableOptions.shuffle();
    return viableOptions.first;
  }

  void _shuffle() async {
    setState(() {
      shouldStart = false;
    });

    int? lastTarget;
    for (int i = 0; i < widget.shuffleCount; i++) {
      int newTarget = getRandomValidTarget(avoidTarget: lastTarget);
      lastTarget = _currentTarget;
      await _swap(newTarget, duration: fastAnimationDuration);
    }
  }

  void _restart() async {
    setState(() {
      shouldStart = true;
      isEnded = false;
      currentTileOrder = List.generate(
        widget.tileCount * widget.tileCount,
        (index) => index,
      );
    });
  }

  Future _swap(int from, {Duration duration = animationDuration}) async {
    setState(() {
      final to = _currentTarget;
      currentAnimationDuration = duration;
      final target = currentTileOrder[to];
      currentTileOrder[to] = currentTileOrder[from];
      currentTileOrder[from] = target;
      enabled = false;
    });
    await Future.delayed(duration);
    setState(() {
      enabled = true;
    });
  }

  Alignment _indexToAlignment(int value) {
    final column = _getColForIndex(value);
    final row = _getRowForIndex(value);

    final normalizedCol = (column / (widget.tileCount - 1)) * 2 - 1;
    final normalizedRow = (row / (widget.tileCount - 1)) * 2 - 1;
    return Alignment(normalizedRow, normalizedCol);
  }

  // double _convertToAlign(int value) {
  //   final normalizedValue = value / (widget.tileCount - 1);
  //   final toAlignResult = normalizedValue * 2 - 1;
  //   return toAlignResult;
  // }

  bool _canSwap(int currentPosition) {
    int target = _currentTarget;
    int currentCol = _getColForIndex(currentPosition);
    int currentRow = _getRowForIndex(currentPosition);
    int targetCol = _getColForIndex(target);
    int targetRow = _getRowForIndex(target);

    bool canMove = false;
    if (currentRow == targetRow) {
      canMove = currentCol - 1 == targetCol || currentCol + 1 == targetCol;
    } else if (currentCol == targetCol) {
      canMove = currentRow - 1 == targetRow || currentRow + 1 == targetRow;
    }

    return canMove;
  }
}

class BackgroundTile extends StatelessWidget {
  final int number;

  const BackgroundTile({
    Key? key,
    required this.number,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black26, width: 2),
          gradient: LinearGradient(colors: [
            Colors.grey.withOpacity(0.1),
            Colors.grey.withOpacity(0.2),
          ])),
      child: Container(
          padding: const EdgeInsets.all(12),
          alignment: Alignment.center,
          child: FittedBox(
            child: Text(
              "$number",
              style: Theme.of(context).textTheme.headline1?.copyWith(
                color: Colors.black26,
                shadows: const [
                  Shadow(
                    offset: Offset(2.0, 2.0),
                    blurRadius: 1.0,
                    color: Colors.black12,
                  ),
                ],
              ),
            ),
          )),
    );
  }
}

class GameTile extends StatelessWidget {
  final int number;

  const GameTile({
    Key? key,
    required this.number,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        Colors.blue.shade800,
        Colors.blue.shade300,
      ])),
      child: Container(
          color: Colors.blue,
          padding: const EdgeInsets.all(10),
          alignment: Alignment.center,
          child: FittedBox(
            child: Text(
              "$number",
              style: Theme.of(context)
                  .textTheme
                  .headline1
                  ?.copyWith(color: Colors.white),
            ),
          )),
    );
  }
}

class StartOverlay extends StatelessWidget {
  final VoidCallback onPressed;

  const StartOverlay({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
        child: Container(
      color: Colors.black38,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text("Start game"),
      ),
    ));
  }
}

class EndOverlay extends StatelessWidget {
  final VoidCallback onPressed;

  const EndOverlay({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
        child: Container(
      color: Colors.black38,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text("RESTART"),
      ),
    ));
  }
}
