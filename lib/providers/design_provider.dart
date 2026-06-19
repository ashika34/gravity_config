import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/seat_design_model.dart';
import '../models/seat_design_detail_model.dart';

enum LoadingStatus { idle, loading, success, error }

class DesignListProvider extends ChangeNotifier {
  final ApiService _apiService;
  LoadingStatus _status = LoadingStatus.idle;
  List<SeatDesign> _designs = [];
  String? _errorMessage;

  DesignListProvider(this._apiService);

  LoadingStatus get status => _status;
  List<SeatDesign> get designs => _designs;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDesigns() async {
    _status = LoadingStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiConstants.seatDesigns);
      final dataList = response['data'] as List<dynamic>;
      _designs = dataList
          .map((d) => SeatDesign.fromJson(d as Map<String, dynamic>))
          .toList();
      _status = LoadingStatus.success;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : 'Failed to load designs.';
      _status = LoadingStatus.error;
    }

    notifyListeners();
  }
}

class DesignDetailProvider extends ChangeNotifier {
  final ApiService _apiService;
  LoadingStatus _status = LoadingStatus.idle;
  SeatDesignDetail? _detail;
  String? _errorMessage;

  // Maps layer index -> selected variant index
  final Map<int, int> _selectedVariants = {};

  DesignDetailProvider(this._apiService);

  LoadingStatus get status => _status;
  SeatDesignDetail? get detail => _detail;
  String? get errorMessage => _errorMessage;
  Map<int, int> get selectedVariants => _selectedVariants;

  Future<void> fetchDetail(int id) async {
    _status = LoadingStatus.loading;
    _errorMessage = null;
    _detail = null;
    _selectedVariants.clear();
    notifyListeners();

    try {
      final response = await _apiService.get(ApiConstants.seatDesignDetail(id));
      _detail = SeatDesignDetail.fromJson(
          response['data'] as Map<String, dynamic>);

      // Pre-select first variant for each layer
      for (var i = 0; i < _detail!.layers.length; i++) {
        if (_detail!.layers[i].variants.isNotEmpty) {
          _selectedVariants[i] = 0;
        }
      }

      _status = LoadingStatus.success;
    } catch (e) {
      _errorMessage =
          e is ApiException ? e.message : 'Failed to load design details.';
      _status = LoadingStatus.error;
    }

    notifyListeners();
  }

  void selectVariant(int layerIndex, int variantIndex) {
    _selectedVariants[layerIndex] = variantIndex;
    notifyListeners();
  }

  DesignVariant? getSelectedVariant(int layerIndex) {
    if (_detail == null) return null;
    final index = _selectedVariants[layerIndex];
    if (index == null) return null;
    final layer = _detail!.layers[layerIndex];
    if (index >= layer.variants.length) return null;
    return layer.variants[index];
  }
}
