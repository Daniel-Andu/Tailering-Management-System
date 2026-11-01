import 'package:flutter/foundation.dart';
import 'package:tailoring_system/features/settings/data/app_settings_repository.dart';

class AppSettingsProvider extends ChangeNotifier {
  AppSettingsProvider({AppSettingsRepository? repository})
      : _repository = repository ?? AppSettingsRepository();

  final AppSettingsRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, String?> _settings = {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, String?> get settings => Map.unmodifiable(_settings);
  bool get isDarkMode => _settings['appearance.dark_mode'] == 'true';

  String? value(String key) => _settings[key];

  Future<void> setDarkMode(bool enabled) => save(
        'appearance.dark_mode',
        enabled ? 'true' : 'false',
      );

  Future<void> load() async {
    await _run(() async {
      _settings = await _repository.loadAll();
    });
  }

  Future<void> save(String key, String? value) async {
    await _run(() async {
      await _repository.save(key, value);
      _settings = await _repository.loadAll();
    });
  }

  Future<void> saveShopProfile({
    required String shopName,
    String? phone,
    String? address,
    String? receiptFooter,
  }) async {
    await _run(() async {
      await _repository.saveShopProfile(
        shopName: shopName,
        phone: phone,
        address: address,
        receiptFooter: receiptFooter,
      );
      _settings = await _repository.loadAll();
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    _scheduleNotify();

    try {
      await action();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      _scheduleNotify();
    }
  }

  void _scheduleNotify() {
    if (!hasListeners) return;

    Future.microtask(() {
      if (hasListeners) {
        notifyListeners();
      }
    });
  }
}
