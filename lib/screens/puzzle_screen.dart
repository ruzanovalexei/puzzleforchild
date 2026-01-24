import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart'; // Добавляем импорт
import 'package:puzzleforchild/screens/settings_screen.dart'; // Импортируем для доступа к ключу
import 'package:puzzleforchild/services/ad_banner_service.dart';
// import 'package:confetti/confetti.dart'; // <-- Удаляем импорт Confetti

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
  final String categoryAssetPath; // Добавляем путь к папке категории

  const PuzzleScreen({
    super.key,
    required this.imageAssetPath,
    required this.categoryAssetPath, // Делаем обязательным
  });

  @override
  _PuzzleScreenState createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  ui.Image? _image;
  List<PuzzlePiece> _allPieces = [];
  final Map<int, Offset> _placedPiecesPositions = {};
  final Set<int> _activePiecesIds = {};
  final List<int> _pieceQueueIds = [];
  final _adBannerService = AdBannerService();
  Timer? _timer;
  bool _isGameComplete = false;
  bool _isLoading = true;
  Widget? _bannerWidget;
  int rows = 4;
  int cols = 4;

  final GlobalKey _puzzleBoardKey = GlobalKey();
  String? _currentImagePath; // Для отслеживания текущего пазла
  List<String> _categoryImagePaths = []; // Список всех изображений в категории


  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.imageAssetPath; // Инициализируем текущий путь
    _loadCategoryImages().then((_) { // Сначала загружаем список всех изображений
      _loadGridSettingsAndImage();
    });
    _initializeBannerWidget();
  }

  void _initializeBannerWidget() {
    if (_bannerWidget == null) {
      _bannerWidget = _adBannerService.createBannerWidget();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bannerWidget = null;
    super.dispose();
  }

  // Метод для загрузки списка всех изображений из категории
  Future<void> _loadCategoryImages() async {
    try {
      // Извлекаем имя категории из categoryAssetPath
      // Например, 'assets/images/pets/' -> 'pets'
      final String categoryName = widget.categoryAssetPath.split('/')[2];
      final String assetListFilePath = 'assets/asset_lists/$categoryName.txt';
      final String assetsContent = await rootBundle.loadString(assetListFilePath);

      // Разбиваем содержимое по строкам и отфильтровываем пустые
      final List<String> assets = assetsContent
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      if (mounted) {
        setState(() {
          _categoryImagePaths = assets;
        });
      }
    } catch (e) {
      print('Error loading category image list: $e');
      if (mounted) {
        setState(() {
          // Возможно, стоит вывести ошибку пользователю
        });
      }
    }
  }

  Future<void> _loadGridSettingsAndImage() async {
    setState(() {
      _isLoading = true;
      _isGameComplete = false;
    });

    final prefs = await SharedPreferences.getInstance();
    final int? savedGridSize = prefs.getInt(SettingsScreen.puzzleGridSizeKey);
    
    rows = savedGridSize ?? 4;
    cols = savedGridSize ?? 4;

    await _loadImageAndSplit(_currentImagePath!); // Используем _currentImagePath
  }

  Future<void> _loadImageAndSplit(String imagePath) async {
    setState(() {
      _placedPiecesPositions.clear();
      _activePiecesIds.clear();
      _pieceQueueIds.clear();
      _isGameComplete = false;
      _currentImagePath = imagePath; // Обновляем текущий путь изображения
    });

    final ByteData data = await rootBundle.load(imagePath);
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
      bool allPiecesAreCorrectlyPositioned = true;

      final RenderBox? puzzleBoardRenderBox = _puzzleBoardKey.currentContext?.findRenderObject() as RenderBox?;
      if (puzzleBoardRenderBox == null) {
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

          final double distance = (actualPlacedPosition - correctAbsolutePositionOnBoard).distance;
          if (distance > 1.0) {
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
        // Диалог убран, надпись и кнопки будут показаны в build
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
      _isGameComplete = false;
      _isLoading = true;
    });
    // Загружаем новый случайный пазл
    _loadNewRandomPuzzle();
  }

  void _loadNewRandomPuzzle() {
    if (_categoryImagePaths.isEmpty) {
      print("No images in category or not loaded.");
      _loadCategoryImages().then((_) => _selectAndLoadRandomPuzzle());
    } else {
      _selectAndLoadRandomPuzzle();
    }
  }

  void _selectAndLoadRandomPuzzle() {
    if (_categoryImagePaths.isEmpty) return;

    String previousImagePath = _currentImagePath!; // Сохраняем текущий пазл
    String newImagePath = previousImagePath;
    final _random = Random();

    // Ищем новый пазл, который не является текущим
    if (_categoryImagePaths.length > 1) {
      while (newImagePath == previousImagePath) {
        newImagePath = _categoryImagePaths[_random.nextInt(_categoryImagePaths.length)];
      }
    } else {
      // Если только одна картинка, то просто перезапускаем её
      newImagePath = _categoryImagePaths.first;
    }

    _loadImageAndSplit(newImagePath).then((_) {
      _loadGridSettingsAndImage(); // Перезагружаем настройки и пазл
    });
  }


  void _onPiecePlaced(int pieceId, Offset globalDropPosition) {
    if (_isGameComplete) return;

    PuzzlePiece currentPiece = _allPieces.firstWhere((p) => p.id == pieceId);

    final RenderBox? renderBox = _puzzleBoardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
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

    const double threshold = 50.0;


    if (distance < threshold) {
      setState(() {
        _activePiecesIds.remove(pieceId);
        _placedPiecesPositions[pieceId] = correctAbsolutePositionOnBoard;
        if (_pieceQueueIds.isNotEmpty) {
          _activePiecesIds.add(_pieceQueueIds.removeAt(0));
        }
        _checkGameCompletion();
      });
    } else {
      // Ничего не делаем при неправильном ходе
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_image == null && !_isLoading) {
      // _loadGridSettingsAndImage(); // Уже вызывается в initState через _loadCategoryImages
      return const Center(child: CircularProgressIndicator());
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double appBarHeight = AppBar().preferredSize.height;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double topPadding = MediaQuery.of(context).padding.top;

    final double availableBodyHeight = screenHeight - appBarHeight - bottomPadding - topPadding;

    final double maxPuzzleBoardWidth = screenWidth * 0.95; 

    final double estimatedAvailableHeightForPuzzleBoard = availableBodyHeight * 0.7;

    double estimatedCandidatePieceSideForBoard = min(maxPuzzleBoardWidth / cols, estimatedAvailableHeightForPuzzleBoard / rows);
    final Size estimatedPieceRenderSize = Size.square(max(50.0, estimatedCandidatePieceSideForBoard));


    const double textContentHeight = 16.0 + (2 * 8.0);
    const double rowOuterPadding = 8.0;
    final double dynamicTrayHeight = textContentHeight + rowOuterPadding + estimatedPieceRenderSize.height + rowOuterPadding;


    final double actualAvailableHeightForPuzzleBoard = availableBodyHeight - dynamicTrayHeight;

    double finalCandidatePieceSide = min(maxPuzzleBoardWidth / cols, actualAvailableHeightForPuzzleBoard / rows);
    final Size finalActualPieceRenderSize = Size.square(max(50.0, finalCandidatePieceSide));

    final Size finalActualTotalPuzzleBoardSize = Size(
        finalActualPieceRenderSize.width * cols,
        finalActualPieceRenderSize.height * rows
    );


    return Scaffold(
      appBar: AppBar(
        title: const Text('Детский пазл'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        key: _puzzleBoardKey,
                        width: finalActualTotalPuzzleBoardSize.width,
                        height: finalActualTotalPuzzleBoardSize.height,
                        child: Stack(
                          children: [
                            // Сетка
                            Positioned.fill(
                              child: CustomPaint(
                                painter: GridPainter(rows: rows, cols: cols, actualPuzzleBoardSize: finalActualTotalPuzzleBoardSize),
                              ),
                            ),
                            // Фоновое изображение (или полная картинка после завершения)
                            Positioned.fill(
                              child: Opacity(
                                opacity: _isGameComplete ? 1.0 : 0.1, // Полная картинка при завершении
                                child: RawImage(
                                  image: _image,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            
                            // Размещенные кусочки (только если игра не завершена)
                            if (!_isGameComplete)
                              ..._placedPiecesPositions.entries.map((entry) {
                                final pieceId = entry.key;
                                final position = entry.value;
                                final piece = _allPieces.firstWhere((p) => p.id == pieceId);
                                return Positioned(
                                  left: position.dx,
                                  top: position.dy,
                                  child: ImagePiece(piece: piece, pieceRenderSize: finalActualPieceRenderSize),
                                );
                              }).toList(),

                            // Надпись "Поздравляю!"
                            if (_isGameComplete)
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: const Text(
                                    'Поздравляю!',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            
                            // Область для размещения кусочков (DragTarget), занимающая весь Stack
                            // Активна только если игра не завершена
                            if (!_isGameComplete)
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
                // Нижняя часть - доступные кусочки или кнопки управления после завершения
                Container(
                  height: dynamicTrayHeight,
                  color: Colors.grey[100],
                  child: _isGameComplete
                      ? Row( // Две кнопки после завершения игры
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'На главную',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.popUntil(context, (route) => route.isFirst);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent, // Более яркий красный
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0), // Обтекаемая форма
                                      ),
                                      padding: const EdgeInsets.all(16.0),
                                    ),
                                    child: const Icon(Icons.stop, color: Colors.white, size: 40),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Продолжить',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: _resetGame,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightGreen, // Более яркий зеленый
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0), // Обтекаемая форма
                                      ),
                                      padding: const EdgeInsets.all(16.0),
                                    ),
                                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column( // Доступные кусочки во время игры
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
                                          feedback: ImagePiece(piece: piece, opacity: 0.7, pieceRenderSize: finalActualPieceRenderSize),
                                          childWhenDragging: ImagePiece(piece: piece, opacity: 0.3, pieceRenderSize: finalActualPieceRenderSize),
                                          child: ImagePiece(piece: piece, pieceRenderSize: finalActualPieceRenderSize),
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
                        // Блок рекламы - используем созданный один раз виджет
          if (_bannerWidget != null) ...[
            _bannerWidget!,
          ] else ...[
            // Показываем загрузку, если виджет еще не создан
            const SizedBox(
              height: 50,
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
              ],
            ),

    );
  }
}