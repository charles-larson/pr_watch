import 'dart:convert';

class Settings {
  SortMode sortMode;
  bool showYourDrafts;
  bool showReviewed;

  Settings({
    required this.sortMode,
    required this.showYourDrafts,
    required this.showReviewed,
  });

  static Settings defaultSettings = Settings(
    sortMode: SortMode.mostRecent,
    showYourDrafts: true,
    showReviewed: true,
  );

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      sortMode: SortMode.values[json['sortMode']],
      showYourDrafts: json['showYourDrafts'],
      showReviewed: json['showReviewed'],
    );
  }

  static Map<String, dynamic> toJson(Settings value) => {
        'sortMode': value.sortMode.index,
        'showYourDrafts': value.showYourDrafts,
        'showReviewed': value.showReviewed,
      };

  @override
  String toString() {
    return jsonEncode(Settings.toJson(this));
  }
}

enum SortMode {
  alphabetical,
  mostRecent,
  leastRecent,
  bogo,
}
