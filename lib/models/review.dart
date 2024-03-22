import 'dart:convert';

import 'package:pr_watch/models/member.dart';

class Review {
  final int id;
  final String nodeId;
  final Member? user;
  final String body;
  final String state;
  final String htmlUrl;
  final String pullRequestUrl;
  final DateTime submittedAt;
  final String? commitId;
  final String authorAssociation;

  Review({
    required this.id,
    required this.nodeId,
    required this.user,
    required this.body,
    required this.state,
    required this.htmlUrl,
    required this.pullRequestUrl,
    required this.submittedAt,
    required this.commitId,
    required this.authorAssociation,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      nodeId: json['node_id'],
      user: Member.fromJson(json['user']),
      body: json['body'],
      state: json['state'],
      htmlUrl: json['html_url'],
      pullRequestUrl: json['pull_request_url'],
      submittedAt: DateTime.parse(json['submitted_at']),
      commitId: json['commit_id'],
      authorAssociation: json['author_association'],
    );
  }

  static Map<String, dynamic> toJson(Review value) => {
        'id': value.id,
        'node_id': value.nodeId,
        'user': value.user,
        'body': value.body,
        'state': value.state,
        'html_url': value.htmlUrl,
        'pull_request_url': value.pullRequestUrl,
        'submitted_at': value.submittedAt.toIso8601String(),
        'commit_id': value.commitId,
        'author_association': value.authorAssociation,
      };

  @override
  String toString() {
    return jsonEncode(Review.toJson(this));
  }
}
