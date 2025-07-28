import 'dart:convert';

class Settings {
  SortMode sortMode;
  bool showYourDrafts;
  bool showReviewed;
  bool useTwoStepLevel2Reviews;

  Settings({
    required this.sortMode,
    required this.showYourDrafts,
    required this.showReviewed,
    required this.useTwoStepLevel2Reviews,
  });

  static Settings defaultSettings = Settings(
    sortMode: SortMode.mostRecent,
    showYourDrafts: true,
    showReviewed: true,
    useTwoStepLevel2Reviews: false,
  );

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
        sortMode: SortMode.values[json['sortMode']],
        showYourDrafts: json['showYourDrafts'],
        showReviewed: json['showReviewed'],
        useTwoStepLevel2Reviews: json['useTwoStepLevel2Reviews']);
  }

  static Map<String, dynamic> toJson(Settings value) => {
        'sortMode': value.sortMode.index,
        'showYourDrafts': value.showYourDrafts,
        'showReviewed': value.showReviewed,
        'useTwoStepLevel2Reviews': value.useTwoStepLevel2Reviews,
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
