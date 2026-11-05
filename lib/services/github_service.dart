import 'dart:async';
import 'dart:collection';
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

  // GitHub's secondary rate limit allows at most 100 concurrent requests.
  static const _maxConcurrentRequests = 80;
  static const _maxRetries = 3;
  // Without this, a request can wait forever if the network drops mid-request.
  static const _requestTimeout = Duration(seconds: 30);
  int _activeRequests = 0;
  final _waitingRequests = Queue<Completer<void>>();
  DateTime? _pausedUntil;

  GithubService._internal();

  void setToken(String token) {
    _token = token;
  }

  // Sends a GET through the concurrency limiter. When GitHub rate limits a
  // request, all requests pause until the wait is over, then it is retried.
  Future<http.Response> _get(Uri uri) async {
    for (var attempt = 0;; attempt++) {
      await _acquireSlot();
      http.Response response;
      try {
        await _waitForPause();
        response = await _send(uri);
      } finally {
        _releaseSlot();
      }

      final wait = _rateLimitWait(response, attempt);
      if (wait == null || attempt >= _maxRetries) {
        return response;
      }
      final resumeAt = DateTime.now().add(wait);
      if (_pausedUntil == null || resumeAt.isAfter(_pausedUntil!)) {
        _pausedUntil = resumeAt;
      }
    }
  }

  // Throws a ClientException if GitHub doesn't respond within _requestTimeout.
  Future<http.Response> _send(Uri uri) async {
    final abort = Completer<void>();
    final timer = Timer(_requestTimeout, abort.complete);
    final client = http.Client();
    try {
      final request = http.AbortableRequest('GET', uri,
          abortTrigger: abort.future)
        ..headers['Authorization'] = 'Bearer $_token';
      return await http.Response.fromStream(await client.send(request));
    } on http.RequestAbortedException {
      throw http.ClientException(
          'GitHub did not respond within ${_requestTimeout.inSeconds} seconds.',
          uri);
    } finally {
      timer.cancel();
      client.close();
    }
  }

  Future<void> _waitForPause() async {
    while (_pausedUntil != null && DateTime.now().isBefore(_pausedUntil!)) {
      await Future.delayed(_pausedUntil!.difference(DateTime.now()));
    }
  }

  Future<void> _acquireSlot() async {
    if (_activeRequests < _maxConcurrentRequests) {
      _activeRequests++;
      return;
    }
    final completer = Completer<void>();
    _waitingRequests.add(completer);
    // _releaseSlot hands its slot directly to the next waiting request.
    await completer.future;
  }

  void _releaseSlot() {
    if (_waitingRequests.isNotEmpty) {
      _waitingRequests.removeFirst().complete();
    } else {
      _activeRequests--;
    }
  }

  // Returns how long to wait before retrying a rate-limited response, or null
  // if the response is not a rate limit (e.g. SSO or permission 403s).
  Duration? _rateLimitWait(http.Response response, int attempt) {
    if (response.statusCode != 403 && response.statusCode != 429) {
      return null;
    }
    final headers = response.headers;

    final retryAfter = int.tryParse(headers['retry-after'] ?? '');
    if (retryAfter != null) {
      return Duration(seconds: retryAfter);
    }

    if (headers['x-ratelimit-remaining'] == '0') {
      final reset = int.tryParse(headers['x-ratelimit-reset'] ?? '');
      if (reset != null) {
        final wait = DateTime.fromMillisecondsSinceEpoch(reset * 1000)
            .difference(DateTime.now());
        return wait.isNegative
            ? const Duration(seconds: 1)
            : wait + const Duration(seconds: 1);
      }
    }

    if (response.body.toLowerCase().contains('secondary rate limit')) {
      // GitHub: wait at least a minute, then back off exponentially.
      return Duration(minutes: 1 << attempt);
    }
    return null;
  }

  Future<User> fetchCurrentUser() async {
    final response = await _get(Uri.parse('$_baseUrl/user'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user. Status code: ${response.statusCode}');
    }
  }

  Future<List<Organization>> fetchOrganizations() async {
    var orgs = <Organization>[];
    var page = 1;
    while (true) {
      final response =
          await _get(Uri.parse('$_baseUrl/user/orgs?page=$page&per_page=100'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        orgs.addAll(data.map((e) => Organization.fromJson(e)));
        if (data.length < 100) {
          break;
        }
        page++;
      } else {
        throw Exception('Failed to load organizations. Status code: ${response.statusCode}');
      }
    }
    return orgs;
  }

  Future<List<Team>> fetchTeams(String org) async {
    var teams = <Team>[];
    var page = 1;
    while (true) {
      final response = await _get(
          Uri.parse('$_baseUrl/orgs/$org/teams?page=$page&per_page=100'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        teams.addAll(data.map((e) => Team.fromJson(e)));
        if (data.length < 100) {
          break;
        }
        page++;
      } else {
        throw Exception('Failed to load teams. Did you enable SSO? 👀 Status code: ${response.statusCode}');
      }
    }
    teams.sort((a, b) => a.name.compareTo(b.name));
    return teams;
  }

  Future<List<PullRequest>> fetchPullRequests(String org, String repo) async {
    var pulls = <PullRequest>[];
    var page = 1;
    while (true) {
      final response = await _get(Uri.parse(
          '$_baseUrl/repos/$org/$repo/pulls?page=$page&per_page=100'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        pulls.addAll(data.map((e) => PullRequest.fromJson(e)));
        if (data.length < 100) {
          break;
        }
        page++;
      } else {
        throw Exception('Failed to load pull requests. Status code: ${response.statusCode}');
      }
    }
    return pulls;
  }

  Future<List<Repository>> fetchRepositories(
      String org, String teamSlug) async {
    var repos = <Repository>[];
    var page = 1;
    while (true) {
      final response = await _get(Uri.parse(
          '$_baseUrl/orgs/$org/teams/$teamSlug/repos?page=$page&per_page=100'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        repos.addAll(data.map((e) => Repository.fromJson(e)));
        if (data.length < 100) {
          break;
        }
        page++;
      } else {
        throw Exception('Failed to load repositories. Status code: ${response.statusCode}');
      }
    }
    return repos;
  }

  Future<List<Member>> fetchMembers(String org, String teamSlug) async {
    var repos = <Member>[];
    var page = 1;
    while (true) {
      final response = await _get(Uri.parse(
          '$_baseUrl/orgs/$org/teams/$teamSlug/members?page=$page&per_page=100'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        repos.addAll(data.map((e) => Member.fromJson(e)));
        if (data.length < 100) {
          break;
        }
        page++;
      } else {
        throw Exception('Failed to load members. Status code: ${response.statusCode}');
      }
    }
    return repos;
  }

  Future<Member> fetchMember(String login) async {
    final response = await _get(
        Uri.parse('$_baseUrl/users/${Uri.encodeComponent(login)}'));

    if (response.statusCode == 200) {
      return Member.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load $login. Status code: ${response.statusCode}');
    }
  }

  Future<List<Review>> fetchReviewState(PullRequest pr) async {
    final response = await _get(Uri.parse(
        '$_baseUrl/repos/${pr.base.repo.owner.login}/${pr.base.repo.name}/pulls/${pr.number}/reviews'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Review.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load review state. Status code: ${response.statusCode}');
    }
  }
}
