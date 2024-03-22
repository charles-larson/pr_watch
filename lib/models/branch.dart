import 'package:pr_watch/models/member.dart';
import 'package:pr_watch/models/repository.dart';

class Branch {
  String label;
  String ref;
  String sha;
  Member user;
  Repository repo;

  Branch({
    required this.label,
    required this.ref,
    required this.sha,
    required this.user,
    required this.repo,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      label: json['label'],
      ref: json['ref'],
      sha: json['sha'],
      user: Member.fromJson(json['user']),
      repo: Repository.fromJson(json['repo']),
    );
  }

  static Map<String, dynamic> toJson(Branch value) => {
        'label': value.label,
        'ref': value.ref,
        'sha': value.sha,
        'user': Member.toJson(value.user),
        'repo': Repository.toJson(value.repo),
      };
}
