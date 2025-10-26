import 'package:flutter/foundation.dart';
import '../model/mesin_sawmill_model.dart';
import '../repository/mesin_sawmill_repository.dart';

class MesinSawmillViewModel extends ChangeNotifier {
  final MesinSawmillRepository repo;
  MesinSawmillViewModel({required this.repo}); // samakan dengan JenisKayuViewModel

  bool _loading = false;
  String _error = '';
  List<MesinSawmill> _items = [];

  bool get isLoading => _loading;
  String get error => _error;
  List<MesinSawmill> get items => _items;

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
