import 'package:flutter/material.dart';

class ReviewInfo extends ChangeNotifier {
  String level2aStatus;
  String level2bStatus;
  bool isAdminReview;

  ReviewInfo({
    required this.level2aStatus,
    required this.level2bStatus,
    required this.isAdminReview,
  });
}
