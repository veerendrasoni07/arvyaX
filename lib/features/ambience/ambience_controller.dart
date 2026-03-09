import 'package:flutter/foundation.dart';

import '../../data/models/ambience.dart';
import '../../data/repositories/ambience_repository.dart';

class AmbienceController extends ChangeNotifier {
  AmbienceController(this._repository);

  final AmbienceRepository _repository;

  List<Ambience> _all = const [];
  String _query = '';
  String _tag = 'All';

  List<Ambience> get all => _all;
  String get query => _query;
  String get tag => _tag;

  List<String> get tags => ['All', ...{..._all.map((e) => e.tag)}];

  List<Ambience> get filtered {
    return _all.where((item) {
      final tagOk = _tag == 'All' || item.tag == _tag;
      final queryOk = item.title.toLowerCase().contains(_query.toLowerCase());
      return tagOk && queryOk;
    }).toList();
  }

  Future<void> load() async {
    _all = await _repository.loadAmbiences();
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value.trim();
    notifyListeners();
  }

  void setTag(String value) {
    _tag = value;
    notifyListeners();
  }
}

