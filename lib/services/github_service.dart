import 'dart:convert';

import 'package:pr_watch/models/member.dart';
import 'package:pr_watch/models/organization.dart';
import 'package:pr_watch/models/pull_request.dart';
import 'package:pr_watch/models/repository.dart';
import 'package:pr_watch/models/review.dart';
import 'package:pr_watch/models/team.dart';
import 'package:pr_watch/models/user.dart';
import 'package:http/http.dart' as http;

class GithubService {
  static final GithubService instance = GithubService._internal();
  final _baseUrl = 'https://api.github.com';
  String _token = '';

  GithubService._internal();

  void setToken(String token) {
    _token = token;
  }

  Future<User> fetchCurrentUser() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/user'),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<List<Organization>> fetchOrganizations() async {
    var orgs = <Organization>[];
    var page = 1;
    while (true) {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/orgs?page=$page&per_page=100'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        orgs.addAll(data.map((e) => Organization.fromJson(e)));
        if (data.length < 100) {
          break;
        }
        page++;
      } else {
        throw Exception('Failed to load organizations');
      }
    }
    return orgs;
  }

  Future<List<Team>> fetchTeams(String org) async {
    var teams = <Team>[];
    var page = 1;
    while (true) {
      final response = await http.get(
        Uri.parse('$_baseUrl/orgs/$org/teams?page=$page&per_page=100'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        teams.addAll(data.map((e) => Team.fromJson(e)));
        if (data.length < 100) {
          break;
        }
        page++;
      } else {
        throw Exception('Failed to load teams');
      }
    }
    teams.sort((a, b) => a.name.compareTo(b.name));
    return teams;
  }

  Future<List<PullRequest>> fetchPullRequests(String org, String repo) async {
    var pulls = <PullRequest>[];
    var page = 1;
    while (true) {
      final response = await http.get(
        Uri.parse('$_baseUrl/repos/$org/$repo/pulls?page=$page&per_page=100'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        pulls.addAll(data.map((e) => PullRequest.fromJson(e)));
        if (data.length < 100) {
          break;
        }
        page++;
      } else {
        throw Exception('Failed to load pull requests');
      }
    }
    return pulls;
  }

  Future<List<Repository>> fetchRepositories(
      String org, String teamSlug) async {
    var repos = <Repository>[];
    var page = 1;
    while (true) {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/orgs/$org/teams/$teamSlug/repos?page=$page&per_page=100'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        repos.addAll(data.map((e) => Repository.fromJson(e)));
        if (data.length < 100) {
          break;
        }
        page++;
      } else {
        throw Exception('Failed to load repositories');
      }
    }
    return repos;
  }

  Future<List<Member>> fetchMembers(String org, String teamSlug) async {
    var repos = <Member>[];
    var page = 1;
    while (true) {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/orgs/$org/teams/$teamSlug/members?page=$page&per_page=100'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        repos.addAll(data.map((e) => Member.fromJson(e)));
        if (data.length < 100) {
          break;
        }
        page++;
      } else {
        throw Exception('Failed to load members');
      }
    }
    return repos;
  }

  Future<List<Review>> fetchReviewState(PullRequest pr) async {
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/repos/${pr.base.repo.owner.login}/${pr.base.repo.name}/pulls/${pr.number}/reviews'),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Review.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load review state');
    }
  }
}
