import 'package:flutter/foundation.dart';
import '../../shared/models/medical_record.dart';
import '../../shared/models/page_meta.dart';
import '../../shared/repositories/medical_record_repository.dart';

class MedicalRecordProvider extends ChangeNotifier {
  final MedicalRecordRepository _repository;

  MedicalRecordProvider(this._repository);

  static const int _pageSize = 20;

  List<MedicalRecord> _records = [];
  List<MedicalRecord> get records => _records;

  PageMeta _meta = PageMeta.empty;
  PageMeta get meta => _meta;
  bool get hasMore => _meta.hasMore;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadMedicalRecords() async {
    _isLoading = true;
    _errorMessage = null;
    _records = [];
    notifyListeners();

    try {
      final result = await _repository.getMedicalRecords(
        limit: _pageSize,
        offset: 0,
      );
      _records = result.items;
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
      final result = await _repository.getMedicalRecords(
        limit: _pageSize,
        offset: _records.length,
      );
      _records = [..._records, ...result.items];
      _meta = result.meta;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
