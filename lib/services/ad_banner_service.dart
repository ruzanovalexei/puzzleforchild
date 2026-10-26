import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

/// Сервис для управления баннерами и рекламой с вознаграждением
class AdBannerService {
  static final AdBannerService _instance = AdBannerService._internal();
  factory AdBannerService() => _instance;
  AdBannerService._internal();

  // Ключ для сохранения счётчика завершённых уровней
  static const String completedLevelsKey = 'completed_levels_count';

  // Флаг инициализации для предотвращения повторной инициализации
  bool _isInitialized = false;

  // Список adUnitId для round-robin ротации баннеров DEV
  static const List<String> _bannerAdUnitIds = [
    'R-M-18531801-1',
    'R-M-18531801-2',
    'R-M-18531801-3',
    'R-M-18531801-4',
    'R-M-18531801-5',
    'R-M-18531801-6',
    'R-M-18531801-7',
    'R-M-18531801-8',
    'R-M-18531801-9',
    'R-M-18531801-10',

  ];
  // Список adUnitId для round-robin ротации баннеров Прод R-M-17946414-6
  // static const List<String> _bannerAdUnitIds = [
  //   'R-M-17946414-3',
  //   'R-M-17946414-4',
  //   'R-M-17946414-5',
  // ];



  // adUnitId для рекламы с вознаграждением DEV
  static const String _rewardedAdUnitId = 'demo-rewarded-yandex';
  // adUnitId для рекламы с вознаграждением Прод
  //  static const String _rewardedAdUnitId = 'R-M-17946414-2';

  // adUnitId для межстраничной рекламы DEV
  static const String _interstitialAdUnitId = 'R-M-18531801-11';
  // adUnitId для межстраничной рекламы Прод
  // static const String _interstitialAdUnitId = 'R-M-17946414-6';

  // Счётчик созданных баннеров
  int _totalBannersCreated = 0;
  
  // Round-robin индекс для выбора adUnitId баннеров
  int _currentBannerIndex = 0;
  
  // Статистика баннеров
  int _failedBannerLoads = 0;
  int _successfulBannerLoads = 0;
  
  // Статистика rewarded ads
  int _rewardedAdShownCount = 0;
  int _rewardedAdCompletedCount = 0;

  // Счётчик завершённых уровней (сохраняется между сессиями)
  int _completedLevelsCount = 0;
  int get completedLevelsCount => _completedLevelsCount;

  /// Увеличивает счётчик завершённых уровней и сохраняет его.
  /// Возвращает true, если достигнут порог показа interstitial рекламы.
  Future<bool> incrementCompletedLevels() async {
    _completedLevelsCount++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(completedLevelsKey, _completedLevelsCount);
    debugPrint('[AdBannerService] Completed levels: $_completedLevelsCount');

    if (_completedLevelsCount >= _interstitialAfterLevels) {
      _completedLevelsCount = 0;
      await prefs.setInt(completedLevelsKey, 0);
      return true;
    }
    return false;
  }

  static const int _interstitialAfterLevels = 3;

  // Stream для мониторинга
  final StreamController<BannerStats> _statsController = 
      StreamController<BannerStats>.broadcast();
  Stream<BannerStats> get statsStream => _statsController.stream;

  

  // Getters для мониторинга баннеров
  int get totalBannersCreated => _totalBannersCreated;
  int get failedBannerLoads => _failedBannerLoads;
  int get successfulBannerLoads => _successfulBannerLoads;

  // Getters для мониторинга rewarded ads
  int get rewardedAdShownCount => _rewardedAdShownCount;
  int get rewardedAdCompletedCount => _rewardedAdCompletedCount;

  /// Инициализация сервиса
  Future<void> initialize() async {
    // Предотвращаем повторную инициализацию
    if (_isInitialized) {
      // debugPrint('AdBannerService: Already initialized, skipping...');
      return;
    }
    
    // debugPrint('AdBannerService: Initializing...');
    
    // Инициализируем Yandex Mobile Ads SDK
    await YandexAds.initialize();
    
    // Загружаем сохранённый счётчик завершённых уровней
    final prefs = await SharedPreferences.getInstance();
    _completedLevelsCount = prefs.getInt(completedLevelsKey) ?? 0;
    
    _isInitialized = true;
    _emitStats();
    // debugPrint('AdBannerService: Initialized successfully');
  }

  /// Создание одного баннера
  BannerAd _createBanner(String adUnitId) {
    final screenWidth = 320;
    final adSize = BannerAdSize.sticky(width: screenWidth);
    
    final banner = BannerAd(adSize: adSize);
    
    // Подписываемся на состояние загрузки баннера (stream-based API в SDK 8.x)
    banner.loadStateStream.listen((state) {
      if (state is BannerAdLoadStateLoaded) {
        _successfulBannerLoads++;
        _emitStats();
        debugPrint('AdBannerService: Banner loaded successfully with adUnitId: $adUnitId');
      } else if (state is BannerAdLoadStateError) {
        _failedBannerLoads++;
        _emitStats();
        // debugPrint('AdBannerService: Ad failed to load with adUnitId $adUnitId: ${state.error}');
      }
    });
    
    // Загружаем рекламу
    banner.load(AdRequest(adUnitId: adUnitId));
    
    return banner;
  }

  /// Получение баннера по запросу с round-robin
  BannerAd? getBanner() {
    // Round-robin выбор adUnitId
    final adUnitId = _bannerAdUnitIds[_currentBannerIndex % _bannerAdUnitIds.length];
    // debugPrint('AdBannerService: Requesting banner with adUnitId: $adUnitId (index: ${_currentBannerIndex % _bannerAdUnitIds.length})');
    
    // Переходим к следующему adUnitId для следующего запроса
    _currentBannerIndex++;
    
    try {
      final banner = _createBanner(adUnitId);
      _totalBannersCreated++;
      // debugPrint('AdBannerService: Created new banner with adUnitId: $adUnitId');
      _emitStats();
      return banner;
    } catch (e) {
      // debugPrint('AdBannerService: Failed to create banner: $e');
      return null;
    }
  }
  
  /// Создание BannerAd с round-robin и возврат BannerAd (не виджета)
  BannerAd createBannerAd() {
    final banner = getBanner();
    if (banner == null) {
      throw StateError('Failed to create banner ad');
    }
    return banner;
  }
    
  /// Создание виджета баннера с автоматическим управлением
  Widget createBannerWidget() {
    final banner = getBanner();
    if (banner == null) {
      return const SizedBox.shrink();
    }
    return BannerWidget(bannerAd: banner);
  }

  /// Принудительная очистка всех ресурсов
  void dispose() {
    // debugPrint('AdBannerService: Disposing all resources...');
    
    _isInitialized = false;
    _statsController.close();
    
    // debugPrint('AdBannerService: All resources disposed');
  }

  /// Отправка статистики
  void _emitStats() {
    final stats = BannerStats(
      totalCreated: _totalBannersCreated,
      successfulLoads: _successfulBannerLoads,
      failedLoads: _failedBannerLoads,
    );
    
    _statsController.add(stats);
  }

  

  

  /// Показ interstitial ad после завершения уровня
  Future<void> showInterstitialAd({
    required BuildContext context,
    Function()? onAdCompleted,
    Function()? onAdDismissed,
  }) async {
    if (!_isInitialized) {
      debugPrint('[InterstitialAd] Сервис не инициализирован');
      return;
    }
    
    debugPrint('[InterstitialAd] Начало загрузки рекламы...');
    
    InterstitialAd? ad;
    
    try {
      // Создаем InterstitialAdLoader (синхронный конструктор в SDK 8.x)
      final interstitialAdLoader = InterstitialAdLoader();
      
      // Загружаем рекламу — loadAd возвращает Future<InterstitialAd> напрямую
      debugPrint('[InterstitialAd] Запрос загрузки рекламы с adUnitId: $_interstitialAdUnitId');
      ad = await interstitialAdLoader.loadAd(
        adRequest: AdRequest(adUnitId: _interstitialAdUnitId),
      );
      
      debugPrint('[InterstitialAd] Реклама успешно загружена');
      
      // Устанавливаем слушатель событий до показа
      await ad.setAdEventListener(
        eventListener: InterstitialAdEventListener(
          onAdDismissed: () {
            debugPrint('[InterstitialAd] Реклама закрыта пользователем');
            onAdDismissed?.call();
            onAdCompleted?.call();
            ad?.destroy();
          },
          onAdFailedToShow: (error) {
            debugPrint('[InterstitialAd] Ошибка показа рекламы: $error');
            ad?.destroy();
          },
        ),
      );
      
      debugPrint('[InterstitialAd] Показ рекламы...');
      await ad.show();
      
      debugPrint('[InterstitialAd] Межстраничная реклама показана');
    } on AdRequestError catch (error) {
      debugPrint('[InterstitialAd] Ошибка загрузки рекламы: $error');
    } catch (e, stackTrace) {
      debugPrint('[InterstitialAd] Исключение при показе рекламы: $e');
      debugPrint('[InterstitialAd] StackTrace: $stackTrace');
    }
  }

  /// Показ rewarded ad с загрузкой рекламы на лету
  Future<Reward?> showRewardedAd({
    required BuildContext context,
    Function()? onAdShown,
    Function(Reward)? onAdCompleted,
    Function()? onAdDismissed,
    Function()? onAdClicked,
  }) async {
    if (!_isInitialized) {
      debugPrint('AdBannerService: Ошибка! Сервис не инициализирован. Call initialize() first.');
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Ошибка рекламы'),
              content: const Text('Сервис рекламы не инициализирован. Перезапустите приложение.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Понятно'),
                ),
              ],
            );
          },
        );
      }
      return null;
    }
    
    debugPrint('[RewardedAd] Начало загрузки рекламы...');
    
    RewardedAd? ad;
    
    try {
      // Создаем RewardedAdLoader (синхронный конструктор в SDK 8.x)
      final rewardedAdLoader = RewardedAdLoader();
      
      // Загружаем рекламу — loadAd возвращает Future<RewardedAd> напрямую
      debugPrint('[RewardedAd] Запрос загрузки рекламы с adUnitId: $_rewardedAdUnitId');
      ad = await rewardedAdLoader.loadAd(
        adRequest: AdRequest(adUnitId: _rewardedAdUnitId),
      );
      
      debugPrint('[RewardedAd] Реклама успешно загружена');
      
      _rewardedAdShownCount++;
      debugPrint('[RewardedAd] Показ рекламы...');
      onAdShown?.call();
      
      // Используем Completer для ожидания результата с таймаутом
      final completer = Completer<Reward?>();
      late Timer timeoutTimer;
      
      // Таймаут 60 секунд (реклама может длиться долго)
      timeoutTimer = Timer(const Duration(seconds: 60), () {
        if (!completer.isCompleted) {
          debugPrint('[RewardedAd] Таймаут ожидания закрытия рекламы');
          completer.complete(null);
        }
      });
      
      // Устанавливаем слушатель событий до показа
      await ad.setAdEventListener(
        eventListener: RewardedAdEventListener(
          onAdShown: () {
            debugPrint('[RewardedAd] Реклама показана на экране');
          },
          onAdFailedToShow: (error) {
            debugPrint('[RewardedAd] Ошибка показа рекламы: $error');
            timeoutTimer.cancel();
            if (!completer.isCompleted) {
              completer.complete(null);
            }
            ad?.destroy();
          },
          onAdClicked: () {
            debugPrint('[RewardedAd] Клик по рекламе');
            onAdClicked?.call();
          },
          onAdDismissed: () {
            debugPrint('[RewardedAd] Реклама закрыта пользователем (onAdDismissed)');
            timeoutTimer.cancel();
            if (!completer.isCompleted) {
              completer.complete(null);
            }
            onAdDismissed?.call();
            ad?.destroy();
          },
          onAdImpression: (impressionData) {
            debugPrint('[RewardedAd] Зарегистрирован показ рекламы (impression)');
          },
          onRewarded: (Reward reward) {
            _rewardedAdCompletedCount++;
            debugPrint('[RewardedAd] Награда выдана: ${reward.amount} ${reward.type}');
            onAdCompleted?.call(reward);
            // Не завершаем completer здесь — ждём onAdDismissed
          },
        ),
      );
      
      // Показываем рекламу
      debugPrint('[RewardedAd] Вызов show()...');
      await ad.show();
      
      // Ждем завершения просмотра
      debugPrint('[RewardedAd] Ожидание завершения просмотра...');
      final reward = await completer.future;
      
      timeoutTimer.cancel();
      debugPrint('[RewardedAd] Просмотр завершён. Reward: $reward');
      
      return reward;
    } on AdRequestError catch (error) {
      debugPrint('[RewardedAd] Ошибка загрузки рекламы: $error');
      
      // Показываем диалог с ошибкой
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Реклама недоступна'),
              content: const Text(
                'Нет рекламы для показа: проверьте соединение с интернетом или отключите блокировщик рекламы'
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Понятно'),
                ),
              ],
            );
          },
        );
      }
      
      return null;
    } catch (e, stackTrace) {
      debugPrint('[RewardedAd] Исключение при показе рекламы: $e');
      debugPrint('[RewardedAd] StackTrace: $stackTrace');
      
      // Показываем диалог с ошибкой при исключении
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Ошибка загрузки рекламы'),
              content: const Text(
                'Нет рекламы для показа: проверьте соединение с интернетом или отключите блокировщик рекламы'
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Понятно'),
                ),
              ],
            );
          },
        );
      }
      
      return null;
    }
  }

  

  /// Получение отчета о состоянии
  String getReport() {
    return '''
AdBannerService Report:
- Total created: $_totalBannersCreated
- Successful banner loads: $_successfulBannerLoads
- Failed banner loads: $_failedBannerLoads
- RewardedAd shown count: $_rewardedAdShownCount
- RewardedAd completed count: $_rewardedAdCompletedCount
''';
  }
}

/// Виджет баннера
class BannerWidget extends StatelessWidget {
  final BannerAd bannerAd;
  
  const BannerWidget({
    super.key,
    required this.bannerAd,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: IgnorePointer(
        ignoring: true, // Всегда игнорировать жесты
        child: AdWidget(bannerAd: bannerAd),
      ),
    );
  }
}

/// Класс для статистики баннеров
class BannerStats {
  final int totalCreated;
  final int successfulLoads;
  final int failedLoads;

  const BannerStats({
    required this.totalCreated,
    required this.successfulLoads,
    required this.failedLoads,
  });

  @override
  String toString() {
    return 'BannerStats(created: $totalCreated, success: $successfulLoads, failed: $failedLoads)';
  }
}

/// Класс для статистики rewarded ads
class RewardedAdStats {
  final int shownCount;
  final int completedCount;

  const RewardedAdStats({
    required this.shownCount,
    required this.completedCount,
  });

  @override
  String toString() {
    return 'RewardedAdStats(shown: $shownCount, completed: $completedCount)';
  }
}