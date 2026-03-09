import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/ambience.dart';

class AmbienceRepository {
  Future<List<Ambience>> loadAmbiences() async {
    final raw = await rootBundle.loadString('assets/data/ambiences.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Ambience.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

