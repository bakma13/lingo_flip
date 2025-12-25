import 'dart:convert';
import 'package:flutter/services.dart';

class WordService {
  // Kelimeleri ilk yüklemeden sonra hafızada tutmak için cache
  static Map<String, dynamic>? _allWords;

  /// Tüm kelimeleri JSON dosyasından yükler ve hafızaya alır.
  static Future<void> _loadAllWords() async {
    if (_allWords == null) {
      final String jsonString = await rootBundle.loadString('assets/words.json');
      _allWords = json.decode(jsonString);
    }
  }

  /// Belirtilen seviye için kelimelerin listesini döndürür.
  ///
  /// [levelKey], words.json dosyasındaki bir anahtarla eşleşmelidir (ör. "A2", "TOEFL").
  static Future<List<Map<String, String>>> getWordsForLevel(String levelKey) async {
    try {
      await _loadAllWords(); // Kelimelerin yüklendiğinden emin ol

      final List<dynamic> levelWordsDynamic = _allWords?[levelKey] ?? [];

      final List<Map<String, String>> levelWords =
          levelWordsDynamic.map((word) => Map<String, String>.from(word)).toList();

      levelWords.shuffle(); // Listeyi karıştır
      return levelWords;
    } catch (e) {
      print('Error loading words for level $levelKey: $e');
      return []; // Hata durumunda boş liste döndür
    }
  }

  /// A1, B1, B2, C1 seviyeleri için kelimeleri ilgili Oxford_Lists_*.json dosyasından yükler.
  /// Bu dosyalar özel ve tutarsız bir formata sahip olduğu için bu özel ayrıştırıcı kullanılır.
  static Future<List<Map<String, String>>> getWordsFromOxfordList(
      String level) async {
    String assetPath;
    switch (level) {
      case 'A1':
        assetPath = 'assets/Oxford_Lists_A1.json';
        break;
      case 'A2':
        assetPath = 'assets/Oxford_Lists_A2.json';
        break;
      case 'B1':
        assetPath = 'assets/Oxford_Lists_B1.json';
        break;
      case 'B2':
        assetPath = 'assets/Oxford_Lists_B2.json';
        break;
      case 'C1':
        assetPath = 'assets/Oxford_Lists_C1.json';
        break;
      default:
        print('Unsupported Oxford List level: $level');
        return [];
    }

    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList = json.decode(jsonString);

      final List<Map<String, String>> words = [];
      for (var item in jsonList) {
        final Map<String, dynamic> wordMap = item as Map<String, dynamic>;

        if (wordMap.keys.length < 2) continue;

        // JSON formatı { "kelime1_en": "kelime2_en", "kelime1_tr": "kelime2_tr" } şeklinde.
        // İlk kelime ("about", "absolutely" vb.) her satırda tekrarlandığı için bir veri giriş hatası gibi görünüyor.
        // Bu yüzden sadece ikinci, yani asıl kelimeyi alıyoruz.
        final en = wordMap.values.elementAt(0);
        final trRaw = wordMap.values.elementAt(1);

        // Sadece asıl kelimeyi listeye ekle
        _addWordToList(words, en, trRaw);
      }

      words.shuffle(); // Listeyi karıştır
      return words;
    } catch (e) {
      print('Error loading words from Oxford list $assetPath: $e');
      return []; // Hata durumunda boş liste döndür
    }
  }

  static void _addWordToList(
      List<Map<String, String>> list, String en, String trRaw) {
    if (en.isEmpty) return;

    final String cleanTr = trRaw
        .split(',')
        .map((m) => m.replaceAll(RegExp(r'\[.*?\]'), '').trim())
        .where((m) => m.isNotEmpty)
        .toSet()
        .join(' / ');

    if (cleanTr.isNotEmpty) {
      list.add({'en': en, 'tr': cleanTr});
    }
  }
}