import 'dart:convert';

import 'package:pr_watch/models/branch.dart';
import 'package:pr_watch/models/member.dart';
import 'package:pr_watch/models/team.dart';

class PullRequest {
  final String url;
  final int id;
  final String nodeId;
  final String htmlUrl;
  final String diffUrl;
  final String patchUrl;
  final String issueUrl;
  final String commitsUrl;
  final String reviewCommentsUrl;
  final String reviewCommentUrl;
  final String commentsUrl;
  final String statusesUrl;
  final int number;
  final String state;
  final bool locked;
  final String title;
  final Member? user;
  final String? body;
  final dynamic labels;
  final dynamic milestone;
  final String? activeLockReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? closedAt;
  final DateTime? mergedAt;
  final String? mergeCommitSha;
  final Member? assignee;
  final List<Member>? assignees;
  final List<Member>? requestedReviewers;
  final List<Team>? requestedTeams;
  final dynamic head;
  final Branch base;
  final dynamic links;
  final String authorAssociation;
  final dynamic autoMerge;
  final bool draft;

  PullRequest({
    required this.url,
    required this.id,
    required this.nodeId,
    required this.htmlUrl,
    required this.diffUrl,
    required this.patchUrl,
    required this.issueUrl,
    required this.commitsUrl,
    required this.reviewCommentsUrl,
    required this.reviewCommentUrl,
    required this.commentsUrl,
    required this.statusesUrl,
    required this.number,
    required this.state,
    required this.locked,
    required this.title,
    required this.user,
    required this.body,
    required this.labels,
    required this.milestone,
    required this.activeLockReason,
    required this.createdAt,
    required this.updatedAt,
    required this.closedAt,
    required this.mergedAt,
    required this.mergeCommitSha,
    required this.assignee,
    required this.assignees,
    required this.requestedReviewers,
    required this.requestedTeams,
    required this.head,
    required this.base,
    required this.links,
    required this.authorAssociation,
    required this.autoMerge,
    required this.draft,
  });

  factory PullRequest.fromJson(Map<String, dynamic> json) {
    return PullRequest(
      url: json['url'],
      id: json['id'],
      nodeId: json['node_id'],
      htmlUrl: json['html_url'],
      diffUrl: json['diff_url'],
      patchUrl: json['patch_url'],
      issueUrl: json['issue_url'],
      commitsUrl: json['commits_url'],
      reviewCommentsUrl: json['review_comments_url'],
      reviewCommentUrl: json['review_comment_url'],
      commentsUrl: json['comments_url'],
      statusesUrl: json['statuses_url'],
      number: json['number'],
      state: json['state'],
      locked: json['locked'],
      title: json['title'],
      user: json['user'] != null ? Member.fromJson(json['user']) : null,
      body: json['body'],
      labels: json['labels'],
      milestone: json['milestone'],
      activeLockReason: json['active_lock_reason'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      closedAt:
          json['closed_at'] != null ? DateTime.parse(json['closed_at']) : null,
      mergedAt:
          json['merged_at'] != null ? DateTime.parse(json['merged_at']) : null,
      mergeCommitSha: json['merge_commit_sha'],
      assignee:
          json['assignee'] != null ? Member.fromJson(json['assignee']) : null,
      assignees: json['asignees'] != null
          ? List<Member>.from(json['assignees'].map((x) => Member.fromJson(x)))
          : null,
      requestedReviewers: json['requested_reviewers'] != null
          ? List<Member>.from(
              json['requested_reviewers'].map((x) => Member.fromJson(x)))
          : null,
      requestedTeams: json['requested_teams'] != null
          ? List<Team>.from(
              json['requested_teams'].map((x) => Team.fromJson(x)))
          : null,
      head: json['head'],
      base: Branch.fromJson(json['base']),
      links: json['_links'],
      authorAssociation: json['author_association'],
      autoMerge: json['auto_merge'],
      draft: json['draft'],
    );
  }

  static Map<String, dynamic> toJson(PullRequest value) => {
        'url': value.url,
        'id': value.id,
        'node_id': value.nodeId,
        'html_url': value.htmlUrl,
        'diff_url': value.diffUrl,
        'patch_url': value.patchUrl,
        'issue_url': value.issueUrl,
        'commits_url': value.commitsUrl,
        'review_comments_url': value.reviewCommentsUrl,
        'review_comment_url': value.reviewCommentUrl,
        'comments_url': value.commentsUrl,
        'statuses_url': value.statusesUrl,
        'number': value.number,
        'state': value.state,
        'locked': value.locked,
        'title': value.title,
        'user': value.user,
        'body': value.body,
        'labels': value.labels,
        'milestone': value.milestone,
        'active_lock_reason': value.activeLockReason,
        'created_at': value.createdAt.toIso8601String(),
        'updated_at': value.updatedAt.toIso8601String(),
        'closed_at': value.closedAt?.toIso8601String(),
        'merged_at': value.mergedAt?.toIso8601String(),
        'merge_commit_sha': value.mergeCommitSha,
        'assignee':
            value.assignee != null ? Member.toJson(value.assignee!) : null,
        'assignees': value.assignees?.map((e) => Member.toJson(e)).toList(),
        'requested_reviewers':
            value.requestedReviewers?.map((e) => Member.toJson(e)).toList(),
        'requested_teams':
            value.requestedTeams?.map((e) => Team.toJson(e)).toList(),
        'head': value.head,
        'base': value.base,
        '_links': value.links,
        'author_association': value.authorAssociation,
        'auto_merge': value.autoMerge,
        'draft': value.draft,
      };

  @override
  String toString() {
    return jsonEncode(PullRequest.toJson(this));
  }
}
