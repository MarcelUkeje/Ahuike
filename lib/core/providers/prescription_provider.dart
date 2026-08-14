import 'package:flutter/foundation.dart';
import '../../shared/models/page_meta.dart';
import '../../shared/models/prescription.dart';
import '../../shared/repositories/prescription_repository.dart';

class PrescriptionProvider extends ChangeNotifier {
  final PrescriptionRepository _repository;

  PrescriptionProvider(this._repository);

  static const int _pageSize = 20;

  List<Prescription> _prescriptions = [];
  List<Prescription> get prescriptions => _prescriptions;

  PageMeta _meta = PageMeta.empty;
  PageMeta get meta => _meta;
  bool get hasMore => _meta.hasMore;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool? _currentActiveFilter;

  Future<void> loadPrescriptions({bool? active}) async {
    _currentActiveFilter = active;
    _isLoading = true;
    _errorMessage = null;
    _prescriptions = [];
    notifyListeners();

    try {
      final result = await _repository.getPrescriptions(
        active: active,
        limit: _pageSize,
        offset: 0,
      );
      _prescriptions = result.items;
      _meta = result.meta;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_meta.hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _repository.getPrescriptions(
        active: _currentActiveFilter,
        limit: _pageSize,
        offset: _prescriptions.length,
      );
      _prescriptions = [..._prescriptions, ...result.items];
      _meta = result.meta;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
