import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart'; // Добавляем импорт
import 'package:puzzleforchild/screens/settings_screen.dart'; // Импортируем для доступа к ключу


// ===================================
// Вспомогательные классы - ВСЕ ОНИ ДОЛЖНЫ БЫТЬ ОПРЕДЕЛЕНЫ ЗДЕСЬ, ДО PuzzleScreen
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

  // Метод copyWith должен быть здесь, вне конструктора, но внутри класса PuzzlePiece
  PuzzlePiece copyWith() {
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

// Виджет для отображения кусочка изображения
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
        painter: _ImagePiecePainter( // <-- Вот здесь используется _ImagePiecePainter
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
  final String imageAssetPath;
  const PuzzleScreen({super.key, required this.imageAssetPath});

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

  int rows = 4; // Будет загружаться из настроек
  int cols = 4; // Будет загружаться из настроек

  final double _activePiecesTrayHeight = 150;

  final GlobalKey _puzzleBoardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadGridSettingsAndImage(); // Новый метод для загрузки настроек и изображения
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Новый метод для загрузки настроек сетки
  Future<void> _loadGridSettingsAndImage() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    // Изменено: используем новое имя поля без '_'
    final int? savedGridSize = prefs.getInt(SettingsScreen.puzzleGridSizeKey);
    
    // Устанавливаем rows и cols
    rows = savedGridSize ?? 4; // Используем сохраненное значение или 4 по умолчанию
    cols = savedGridSize ?? 4; // Устанавливаем такое же значение для cols

    print('[PuzzleScreen] Загружены настройки сетки: $rows x $cols');

    // Затем продолжаем загружать изображение и разбивать его на кусочки
    _loadImageAndSplit();
  }

  Future<void> _loadImageAndSplit() async {
    setState(() {
      // Это часть общего процесса загрузки, поэтому isLoading уже true
      _placedPiecesPositions.clear();
      _activePiecesIds.clear();
      _pieceQueueIds.clear();
      _score = 0;
      _isGameComplete = false;
    });

    final ByteData data = await rootBundle.load(widget.imageAssetPath);
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

    // Используем `rows` и `cols`, загруженные из настроек
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

        pieces.add(PuzzlePiece( // Открывающая скобка конструктора
          id: id,
          image: image,
          sourceRect: sourceRect,
          correctRelativePosition: correctRelativePosition,
        )); // <--- Правильно закрыта скобка и добавлена точка с запятой
      }
    }
    return pieces;
  }

  void _checkGameCompletion() {
    if (_placedPiecesPositions.length == _allPieces.length && !_isGameComplete) {
      bool allPiecesAreCorrectlyPositioned = true;
      // Мы уже знаем, что _placedPiecesPositions содержит только правильно
      // размещенные куски. Но для дополнительной проверки, если нужно,
      // можно сравнить каждую позицию.
      // Если же логика onPiecePlaced гарантирует, что мы добавляем Оффсет
      // именно в correctAbsolutePositionOnBoard, то этой проверки достаточно.

      // Для строгой проверки, что каждый кусок действительно находится в
      // правильной позиции (например, чтобы поймать баги или если threshold большой)
      // необходимо получать RenderBox и пересчитывать позиции.
      // Для простоты, если кусок помещается в _placedPiecesPositions,
      // мы считаем его правильно расположенным.

      // Однако, если вы хотите более строгую проверку по расстоянию,
      // как в _onPiecePlaced, то ее можно добавить сюда:
      final RenderBox? puzzleBoardRenderBox = _puzzleBoardKey.currentContext?.findRenderObject() as RenderBox?;
      if (puzzleBoardRenderBox == null) {
        // Если не можем получить RenderBox, не можем проверить позиции строго.
        // Допустим, что все правильно.
        allPiecesAreCorrectlyPositioned = true;
      } else {
        final Size actualPuzzleBoardSize = puzzleBoardRenderBox.size;

        for (var entry in _placedPiecesPositions.entries) {
          final pieceId = entry.key;
          final actualPlacedPosition = entry.value;
          final piece = _allPieces.firstWhere((p) => p.id == pieceId);

          final Offset correctAbsolutePositionOnBoard = Offset(
            piece.correctRelativePosition.dx * actualPuzzleBoardSize.width,
            piece.correctRelativePosition.dy * actualPuzzleBoardSize.height,
          );

          // Проверяем, что размещенная позиция очень близка к идеально правильной
          final double distance = (actualPlacedPosition - correctAbsolutePositionOnBoard).distance;
          if (distance > 1.0) { // Очень маленький порог для идеального совпадения
            allPiecesAreCorrectlyPositioned = false;
            break;
          }
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
    });
    _loadGridSettingsAndImage(); // Загружаем настройки и изображение
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

    final Offset correctAbsolutePositionOnBoard = Offset(
      currentPiece.correctRelativePosition.dx * actualPuzzleBoardSize.width,
      currentPiece.correctRelativePosition.dy * actualPuzzleBoardSize.height,
    );

    final double pieceWidth = actualPuzzleBoardSize.width / cols;
    final double pieceHeight = actualPuzzleBoardSize.height / rows;

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
      _loadGridSettingsAndImage(); // Повторно вызываем загрузку, если контекст меняется или изображение не загружено
      return const Center(child: CircularProgressIndicator());
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double maxPuzzleBoardWidth = screenWidth * 0.95;
    final double maxPuzzleBoardHeight = (screenHeight - kToolbarHeight - _activePiecesTrayHeight - (MediaQuery.of(context).padding.top)) * 0.95;

    // Используем обновленные `rows` и `cols` из настроек
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
                              // Передаем обновленные `rows` и `cols`
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
      floatingActionButton: FloatingActionButton(
        onPressed: _resetGame,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}