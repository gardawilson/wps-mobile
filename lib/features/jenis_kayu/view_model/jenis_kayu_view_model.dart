import 'package:flutter/foundation.dart';
import '../model/jenis_kayu_model.dart';
import '../repository/jenis_kayu_repository.dart';

class JenisKayuViewModel extends ChangeNotifier {
  final JenisKayuRepository repo;
  JenisKayuViewModel({required this.repo}); // <-- named

  bool _loading = false;
  String _error = '';
  List<JenisKayu> _items = [];

  bool get isLoading => _loading;
  String get error => _error;
  List<JenisKayu> get items => _items;

  Future<void> load({bool force = false}) async {
    _loading = true; _error = ''; notifyListeners();
    try {
      _items = await repo.getAllEnabled(force: force);
    } catch (e) {
      _error = '$e';
    } finally {
      _loading = false; notifyListeners();
    }
  }
}
