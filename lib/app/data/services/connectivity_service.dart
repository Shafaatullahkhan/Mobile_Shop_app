import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService extends ChangeNotifier {
  bool _isConnected = true;
  bool _isChecking = false;
  ConnectivityResult _connectionType = ConnectivityResult.other;

  bool get isConnected => _isConnected;
  bool get isChecking => _isChecking;
  ConnectivityResult get connectionType => _connectionType;
  bool get isWifi => _connectionType == ConnectivityResult.wifi;
  bool get isMobile => _connectionType == ConnectivityResult.mobile;

  ConnectivityService() {
    _initializeConnectivity();
    _listenToConnectivityChanges();
  }

  Future<void> _initializeConnectivity() async {
    _isChecking = true;
    notifyListeners();

    try {
      final results = await Connectivity().checkConnectivity();
      if (results.isNotEmpty) {
        _updateConnectionStatus(results.first);
      }
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      _isConnected = false;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  void _listenToConnectivityChanges() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        _updateConnectionStatus(results.first);
      }
    });
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    _connectionType = result;
    _isConnected = result != ConnectivityResult.none;
    debugPrint('Connectivity changed: $_isConnected (${result.name})');
    notifyListeners();
  }

  Future<bool> checkConnection() async {
    await _initializeConnectivity();
    return _isConnected;
  }

  // Method to manually test connectivity by making a request
  Future<bool> testConnectivity() async {
    try {
      // You could make a simple HTTP request here to test actual connectivity
      // For now, we'll just check the connectivity status
      final result = await Connectivity().checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      debugPrint('Error testing connectivity: $e');
      return false;
    }
  }

  String get connectionStatusText {
    if (_isChecking) return 'Checking...';
    if (!_isConnected) return 'Offline';
    switch (_connectionType) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'Offline';
      default:
        return 'Unknown';
    }
  }
}
