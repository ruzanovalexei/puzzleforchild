import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Нужен для rootBundle
import 'package:puzzleforchild/screens/puzzle_screen.dart';

class CategorySelectionScreen extends StatefulWidget {
  final String categoryTitle;
  final String categoryAssetPath; // Например, 'assets/images/pets/'

  const CategorySelectionScreen({
    super.key,
    required this.categoryTitle,
    required this.categoryAssetPath,
  });

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  List<String> _imageAssets = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategoryImages();
  }

  Future<void> _loadCategoryImages() async {
    print('[_loadCategoryImages] Начало загрузки категории: ${widget.categoryAssetPath}');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Формируем имя текстового файла со списком ассетов для текущей категории
      // Например, 'assets/images/pets/' -> 'pets' -> 'assets/asset_lists/pets.txt'
      final String categoryName = widget.categoryAssetPath.split('/')[2]; // Получаем 'pets', 'farm_animals' и т.д.
      final String assetListFilePath = 'assets/asset_lists/$categoryName.txt';

      print('[_loadCategoryImages] Попытка загрузить список ассетов из: $assetListFilePath');
      final String assetsContent = await rootBundle.loadString(assetListFilePath);
      print('[_loadCategoryImages] Список ассетов для категории $categoryName загружен успешно.');

      // Разбиваем содержимое по строкам и отфильтровываем пустые
      final List<String> assets = assetsContent
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      if (mounted) {
        setState(() {
          _imageAssets = assets;
          _isLoading = false;
        });
      }
      print('[_loadCategoryImages] Загружено ${_imageAssets.length} ассетов для категории: ${widget.categoryAssetPath}');

    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          _error = 'Ошибка загрузки списка изображений: $e';
          _isLoading = false;
        });
      }
      print('[_loadCategoryImages] Error loading asset list file: $e');
      print('[_loadCategoryImages] Stacktrace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _error = null;
                            });
                            _loadCategoryImages();
                          },
                          child: const Text('Повторить попытку'),
                        ),
                      ],
                    ),
                  ),
                )
              : _imageAssets.isEmpty
                  ? Center(child: Text('В этой категории пока нет изображений: ${widget.categoryAssetPath}'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: _imageAssets.length,
                      itemBuilder: (context, index) {
                        final String imagePath = _imageAssets[index];
                        final String fileName = imagePath.split('/').last.split('.').first;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PuzzleScreen(imageAssetPath: imagePath),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                    child: Image.asset(
                                      imagePath,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    fileName,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}