import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

// ===================================
// Вспомогательные классы (без изменений)
// ===================================

// Класс для представления кусочка пазла
class PuzzlePiece {
  final int id;
  final ui.Image image;
  final Rect sourceRect; // Часть исходного, возможно, обрезанного изображения
  final Offset correctRelativePosition; // Правильная относительная позиция (0.0 до 1.0) внутри всего пазла

  const PuzzlePiece({
    required this.id,
    required this.image,
    required this.sourceRect,
    required this.correctRelativePosition,
  });

  PuzzlePiece copyWith() { // copyWith без параметров, так как текущее положение будет храниться вовне
    return PuzzlePiece(
      id: id,
      image: image,
      sourceRect: sourceRect,
      correctRelativePosition: correctRelativePosition,
    );
  }
}

// Художник для отрисовки части изображения
class _ImagePiecePainter extends CustomPainter {
  final ui.Image image;
  final Rect sourceRect;
  final double opacity;

  _ImagePiecePainter({
    required this.image,
    required this.sourceRect,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..filterQuality = FilterQuality.high
      ..color = Colors.white.withOpacity(opacity);
    canvas.drawImageRect(image, sourceRect, Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _ImagePiecePainter oldDelegate) {
    return oldDelegate.image != image || oldDelegate.sourceRect != sourceRect || oldDelegate.opacity != opacity;
  }
}

// Виджет для отображения кусочка изображения (название ImagePiece сохраним)
class ImagePiece extends StatelessWidget {
  final PuzzlePiece piece;
  final double opacity;
  final Size? pieceRenderSize; // Размер, который должен быть у кусочка на экране

  const ImagePiece({
    super.key,
    required this.piece,
    this.opacity = 1.0,
    this.pieceRenderSize, // Может быть null, тогда SizedBox будет использовать parent constraints
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: pieceRenderSize?.width ?? piece.sourceRect.width,
      height: pieceRenderSize?.height ?? piece.sourceRect.height,
      child: CustomPaint(
        painter: _ImagePiecePainter(
          image: piece.image,
          sourceRect: piece.sourceRect,
          opacity: opacity,
        ),
      ),
    );
  }
}

// Художник для отрисовки сетки
class GridPainter extends CustomPainter {
  final int rows;
  final int cols;
  final Size actualPuzzleBoardSize; // Фактический размер доски пазла на экране

  GridPainter({required this.rows, required this.cols, required this.actualPuzzleBoardSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black45
      ..strokeWidth = 2;

    final double cellWidth = actualPuzzleBoardSize.width / cols;
    final double cellHeight = actualPuzzleBoardSize.height / rows;

    // Рисуем горизонтальные линии
    for (int i = 1; i < rows; i++) {
      canvas.drawLine(Offset(0, i * cellHeight), Offset(actualPuzzleBoardSize.width, i * cellHeight), paint);
    }
    // Рисуем вертикальные линии
    for (int i = 1; i < cols; i++) {
      canvas.drawLine(Offset(i * cellWidth, 0), Offset(i * cellWidth, actualPuzzleBoardSize.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.rows != rows || oldDelegate.cols != cols || oldDelegate.actualPuzzleBoardSize != actualPuzzleBoardSize;
  }
}

// ===================================
// Основной виджет экрана пазла
// ===================================

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  _PuzzleScreenState createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  ui.Image? _image;
  List<PuzzlePiece> _allPieces = [];
  final Map<int, Offset> _placedPiecesPositions = {};
  final Set<int> _activePiecesIds = {};
  final List<int> _pieceQueueIds = [];

  Timer? _timer;
  int _score = 0;
  bool _isGameComplete = false;
  bool _isLoading = true;
  String _currentImageAsset = ''; // Для хранения текущего случайного имени файла

  int rows = 4;
  int cols = 4;

  final double _activePiecesTrayHeight = 150;

  final GlobalKey _puzzleBoardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentImageAsset = _getRandomImageAsset(); // Генерируем случайное изображение при старте
    _loadImageAndSplit();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Новый метод для получения случайного имени файла
  String _getRandomImageAsset() {
    final random = Random();
    final int imageNumber = random.nextInt(14) + 1; // Число от 1 до 4
    return 'assets/images/fon$imageNumber.webp';
  }

  Future<void> _loadImageAndSplit() async {
    setState(() {
      _isLoading = true;
      _placedPiecesPositions.clear();
      _activePiecesIds.clear();
      _pieceQueueIds.clear();
      _score = 0;
      _isGameComplete = false;
    });

    // Загружаем изображение по текущему случайному пути
    final ByteData data = await rootBundle.load(_currentImageAsset);
    _image = await decodeImageFromList(data.buffer.asUint8List());

    if (_image != null) {
      _allPieces = _splitImageIntoPieces(_image!);

      List<int> shuffledPieceIds = _allPieces.map((p) => p.id).toList()..shuffle();

      for (int i = 0; i < min(3, shuffledPieceIds.length); i++) {
        _activePiecesIds.add(shuffledPieceIds[i]);
      }
      if (shuffledPieceIds.length > 3) {
        _pieceQueueIds.addAll(shuffledPieceIds.sublist(3));
      }

      _isLoading = false;
    }

    setState(() {});
  }

  List<PuzzlePiece> _splitImageIntoPieces(ui.Image image) {
    final List<PuzzlePiece> pieces = [];

    final double actualImageWidth = (image.width / cols).floorToDouble() * cols;
    final double actualImageHeight = (image.height / rows).floorToDouble() * rows;

    final double originalPieceWidth = actualImageWidth / cols;
    final double originalPieceHeight = actualImageHeight / rows;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final int id = r * cols + c;
        final Rect sourceRect = Rect.fromLTWH(
          c * originalPieceWidth,
          r * originalPieceHeight,
          originalPieceWidth,
          originalPieceHeight,
        );
        final Offset correctRelativePosition = Offset(
          c / cols,
          r / rows,
        );

        pieces.add(PuzzlePiece(
          id: id,
          image: image,
          sourceRect: sourceRect,
          correctRelativePosition: correctRelativePosition,
        ));
      }
    }
    return pieces;
  }

  void _checkGameCompletion() {
    if (_placedPiecesPositions.length == _allPieces.length && !_isGameComplete) {
      // Здесь мы должны проверить, что все placedPiecesPositions соответствуют их correctRelativePosition.
      // Так как мы добавляем в _placedPiecesPositions только при "прилипании",
      // можно считать, что они уже "правильно расположены" в рамках threshold.
      // Но если нужна строгая проверка, то нужно пересчитать.
      bool allPiecesAreCorrectlyPositioned = true;
      for (var entry in _placedPiecesPositions.entries) {
        final pieceId = entry.key;
        final actualPosition = entry.value;
        final piece = _allPieces.firstWhere((p) => p.id == pieceId);

        final RenderBox? puzzleBoardRenderBox = _puzzleBoardKey.currentContext?.findRenderObject() as RenderBox?;
        if (puzzleBoardRenderBox == null) continue;

        final Size actualPuzzleBoardSize = puzzleBoardRenderBox.size;
         final Offset correctAbsolutePositionOnBoard = Offset(
          piece.correctRelativePosition.dx * actualPuzzleBoardSize.width,
          piece.correctRelativePosition.dy * actualPuzzleBoardSize.height,
        );

        final double distance = (actualPosition - correctAbsolutePositionOnBoard).distance;
        if (distance >= 5.0) { // Используем небольшой порог для проверки "правильности"
          allPiecesAreCorrectlyPositioned = false;
          break;
        }
      }

      if (allPiecesAreCorrectlyPositioned) {
        setState(() {
          _isGameComplete = true;
        });

        _timer?.cancel();

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Поздравляем!'),
            content: Text('Вы собрали пазл!\nВаш счет: $_score'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetGame();
                },
                child: const Text('Играть снова'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _resetGame() {
    setState(() {
      _image = null;
      _allPieces.clear();
      _placedPiecesPositions.clear();
      _activePiecesIds.clear();
      _pieceQueueIds.clear();
      _score = 0;
      _isGameComplete = false;
      _isLoading = true;
      _currentImageAsset = _getRandomImageAsset(); // Генерируем новое случайное изображение
    });
    _loadImageAndSplit();
  }

  void _onPiecePlaced(int pieceId, Offset globalDropPosition) {
    print('[_onPiecePlaced] Called for piece ID: $pieceId, globalDropPosition: $globalDropPosition');

    PuzzlePiece currentPiece = _allPieces.firstWhere((p) => p.id == pieceId);

    final RenderBox? renderBox = _puzzleBoardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      print('[_onPiecePlaced] Could not find RenderBox for puzzle board.');
      return;
    }

    final Offset globalPuzzleBoardOrigin = renderBox.localToGlobal(Offset.zero);
    final Size actualPuzzleBoardSize = renderBox.size;

    final Offset localDropPositionOnPuzzleBoard = globalDropPosition - globalPuzzleBoardOrigin;

    // Вычисляем правильную абсолютную позицию на доске пазла
    final Offset correctAbsolutePositionOnBoard = Offset(
      currentPiece.correctRelativePosition.dx * actualPuzzleBoardSize.width,
      currentPiece.correctRelativePosition.dy * actualPuzzleBoardSize.height,
    );

    // Определяем размер одного кусочка на доске
    final double pieceWidth = actualPuzzleBoardSize.width / cols;
    final double pieceHeight = actualPuzzleBoardSize.height / rows;

    // Вычисляем расстояние от центра брошенного Draggable до центра правильного места
    final Offset droppedPieceCenter = Offset(
      localDropPositionOnPuzzleBoard.dx + (pieceWidth / 2),
      localDropPositionOnPuzzleBoard.dy + (pieceHeight / 2),
    );
    final Offset correctPositionCenter = Offset(
      correctAbsolutePositionOnBoard.dx + (pieceWidth / 2),
      correctAbsolutePositionOnBoard.dy + (pieceHeight / 2),
    );

    final double distance = (droppedPieceCenter - correctPositionCenter).distance;

    const double threshold = 50.0; // Порог для "прилипания"

    print('[_onPiecePlaced] localDropPositionOnPuzzleBoard: $localDropPositionOnPuzzleBoard');
    print('[_onPiecePlaced] correctAbsolutePositionOnBoard (top-left): $correctAbsolutePositionOnBoard');
    print('[_onPiecePlaced] Dropped Piece Center: $droppedPieceCenter');
    print('[_onPiecePlaced] Correct Position Center: $correctPositionCenter');
    print('[_onPiecePlaced] Rendered Piece Size: ${pieceWidth}x${pieceHeight}');
    print('[_onPiecePlaced] Puzzle Board Size: $actualPuzzleBoardSize');
    print('[_onPiecePlaced] Distance: $distance, Threshold: $threshold');


    if (distance < threshold) {
      print('[_onPiecePlaced] Condition met: Piece will stick. ID: $pieceId');
      setState(() {
        _activePiecesIds.remove(pieceId);
        _placedPiecesPositions[pieceId] = correctAbsolutePositionOnBoard;
        _score += 100;
        if (_pieceQueueIds.isNotEmpty) {
          _activePiecesIds.add(_pieceQueueIds.removeAt(0));
        }
        _checkGameCompletion();
      });
    } else {
      print('[_onPiecePlaced] Condition NOT met: Piece will return. ID: $pieceId');
      setState(() {
        _score = max(0, _score - 10);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_image == null && !_isLoading) {
      // Если изображение еще не загружено, показываем индикатор загрузки
      // и запускаем загрузку, когда BuildContext доступен для MediaQuery
      _loadImageAndSplit();
      return const Center(child: CircularProgressIndicator());
    }

    // Расчет размеров центрального пазла и кусочков
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double maxPuzzleBoardWidth = screenWidth * 0.95;
    final double maxPuzzleBoardHeight = (screenHeight - kToolbarHeight - _activePiecesTrayHeight - (MediaQuery.of(context).padding.top)) * 0.95; // Учитываем AppBar и нижний трей

    double candidatePieceSide = min(maxPuzzleBoardWidth / cols, maxPuzzleBoardHeight / rows);
    final Size actualPieceRenderSize = Size.square(max(50.0, candidatePieceSide));
    final Size actualTotalPuzzleBoardSize = Size(
        actualPieceRenderSize.width * cols,
        actualPieceRenderSize.height * rows
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детский пазл'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.yellow),
                const SizedBox(width: 4),
                Text(
                  '$_score',
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        key: _puzzleBoardKey,
                        width: actualTotalPuzzleBoardSize.width,
                        height: actualTotalPuzzleBoardSize.height,
                        child: Stack(
                          children: [
                            // Сетка
                            Positioned.fill(
                              child: CustomPaint(
                                painter: GridPainter(rows: rows, cols: cols, actualPuzzleBoardSize: actualTotalPuzzleBoardSize),
                              ),
                            ),
                            // Фоновое изображение (очень прозрачное)
                            Positioned.fill(
                              child: Opacity(
                                opacity: 0.1,
                                child: RawImage(
                                  image: _image,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            // Размещенные кусочки
                            ..._placedPiecesPositions.entries.map((entry) {
                              final pieceId = entry.key;
                              final position = entry.value;
                              final piece = _allPieces.firstWhere((p) => p.id == pieceId);
                              return Positioned(
                                left: position.dx,
                                top: position.dy,
                                child: ImagePiece(piece: piece, pieceRenderSize: actualPieceRenderSize),
                              );
                            }).toList(),
                            // Область для размещения кусочков (DragTarget), занимающая весь Stack
                            Positioned.fill(
                              child: DragTarget<int>(
                                onWillAccept: (data) => true,
                                onAcceptWithDetails: (details) {
                                  _onPiecePlaced(details.data, details.offset);
                                },
                                builder: (context, candidateData, rejectedData) {
                                  return Container();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Нижняя часть - доступные кусочки
                Container(
                  height: _activePiecesTrayHeight,
                  color: Colors.grey[100],
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Доступные кусочки (${_activePiecesIds.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _activePiecesIds.map((pieceId) {
                            PuzzlePiece piece = _allPieces.firstWhere((p) => p.id == pieceId);
                            // Здесь ImagePiece всегда будет отрисован с actualPieceRenderSize
                            return Expanded(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Draggable<int>(
                                    data: piece.id,
                                    feedback: ImagePiece(piece: piece, opacity: 0.7, pieceRenderSize: actualPieceRenderSize),
                                    childWhenDragging: ImagePiece(piece: piece, opacity: 0.3, pieceRenderSize: actualPieceRenderSize),
                                    child: ImagePiece(piece: piece, pieceRenderSize: actualPieceRenderSize),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _resetGame,
      //   child: const Icon(Icons.refresh),
      // ),
    );
  }
}