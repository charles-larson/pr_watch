import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pr_watch/split_circle.dart';
import 'package:pr_watch/models/app_state.dart';
import 'package:pr_watch/models/pull_request.dart';
import 'package:pr_watch/models/settings.dart';
import 'package:pr_watch/services/github_service.dart';
import 'package:pr_watch/services/snackbar_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pr_watch/models/review_info.dart';

class Watch extends StatefulWidget {
  const Watch({super.key, required this.appState});
  final AppState appState;

  @override
  State<Watch> createState() => _WatchState();
}

class _WatchState extends State<Watch> {
  final List<PullRequest> _myPullRequests = [];
  final List<PullRequest> _pullRequests = [];
  final List<PullRequest> _filteredMyPullRequests = [];
  final List<PullRequest> _filteredPullRequests = [];
  final Map<int, String> _level1 = {};
  final Map<int, ReviewInfo> _level2Reviews = {};
  int _loadingCount = 0;
  int _refreshCountdown = 0;
  bool get _loading => _loadingCount > 0;

  void refresh() {
    setState(() {
      _refreshCountdown = 600;
    });
    _pullRequests.clear();
    _myPullRequests.clear();
    for (var i = 0; i < widget.appState.repositories.length; i++) {
      _loadReview(widget.appState.currentOrganization!.login,
          widget.appState.repositories[i].name);
    }
  }

  void _updateLevel2ReviewInfo(
      int prId, String level2aStatus, String level2bStatus,
      [bool isAdminReview = false]) {
    setState(() {
      _level2Reviews[prId] = ReviewInfo(
        level2aStatus: level2aStatus,
        level2bStatus: level2bStatus,
        isAdminReview: isAdminReview,
      );
    });
  }

  void _updateLevel2aReviewInfo(int prId, String level2aStatus) {
    setState(() {
      _level2Reviews[prId] ??= ReviewInfo(
          level2aStatus: 'PENDING',
          level2bStatus: 'PENDING',
          isAdminReview: false);

      _level2Reviews[prId]?.level2aStatus = level2aStatus;
      _level2Reviews[prId]?.level2bStatus ??= 'PENDING';
      _level2Reviews[prId]?.isAdminReview ??= false;
    });
  }

  void _updateLevel2bReviewInfo(int prId, String level2bStatus) {
    setState(() {
      _level2Reviews[prId] ??= ReviewInfo(
          level2aStatus: 'PENDING',
          level2bStatus: 'PENDING',
          isAdminReview: false);

      _level2Reviews[prId]?.level2aStatus ??= 'PENDING';
      _level2Reviews[prId]?.level2bStatus = level2bStatus;
      _level2Reviews[prId]?.isAdminReview ??= false;
    });
  }

  Future<void> _loadReview(String org, String repo) async {
    try {
      _loadingCount++;
      var prs = (await GithubService.instance.fetchPullRequests(org, repo))
          .where((pr) => widget.appState.isMemberWatched[pr.user!.id] == true)
          .toList();
      for (var pr in prs) {
        _loadReviewedState(pr);
      }
      _loadingCount--;
      _finalizeList();
    } on Exception catch (e) {
      if (!mounted) return;
      SnackbarService.show(context, e.toString());
    }
  }

  Future<void> _loadReviewedState(PullRequest pr) async {
    try {
      // If the PR is a draft and not created by the current user, skip it
      if (pr.draft && pr.user?.id != widget.appState.currentUser?.id) {
        _finalizeList();
        return;
      }
      _loadingCount++;

      var requestedReviewers =
          pr.requestedReviewers?.map((e) => e.id).toList() ?? [];

      // fetch reviews and filter out requested reviewers or comments
      var reviews = (await GithubService.instance.fetchReviewState(pr))
          .where((element) =>
              element.user != null &&
              (element.state == 'APPROVED' ||
                  element.state == 'CHANGES_REQUESTED') &&
              !requestedReviewers.contains(element.user!.id))
          .toList();

      final level1 = reviews
          .where((pr) => widget.appState.memberLevel[pr.user!.id] == 1)
          .toList();
      final level2 = reviews
          .where((pr) => widget.appState.memberLevel[pr.user!.id] == 2)
          .toList();
      var adminReviews = [];
      if (widget.appState.settings.useTwoStepLevel2Reviews) {
        adminReviews = reviews
            .where((pr) =>
                widget.appState.isAdminReviewer[pr.user!.id] == true &&
                widget.appState.memberLevel[pr.user!.id] == 2)
            .toList();
      }

      for (var i = 0; i < level1.length; i++) {
        if (level1.any((element) =>
            element.id != level1[i].id &&
            element.submittedAt.isAfter(level1[i].submittedAt) &&
            element.user?.id == level1[i].user?.id)) {
          level1.removeAt(i);
          i--;
        }
      }

      for (var i = 0; i < level2.length; i++) {
        if (level2.any((element) =>
            element.id != level2[i].id &&
            element.submittedAt.isAfter(level2[i].submittedAt) &&
            element.user?.id == level2[i].user?.id)) {
          level2.removeAt(i);
          i--;
        }
      }

      for (var i = 0; i < adminReviews.length; i++) {
        if (adminReviews.any((element) =>
            element.id != adminReviews[i].id &&
            element.submittedAt.isAfter(adminReviews[i].submittedAt) &&
            element.user?.id == adminReviews[i].user?.id)) {
          adminReviews.removeAt(i);
          i--;
        }
      }

      setState(() {
        if (level1.any((element) => element.state == 'CHANGES_REQUESTED')) {
          _level1[pr.id] = 'CHANGES_REQUESTED';
        } else if (level1.any((element) => element.state == 'APPROVED')) {
          _level1[pr.id] = 'APPROVED';
        } else {
          _level1[pr.id] = 'PENDING';
        }

        if (widget.appState.settings.useTwoStepLevel2Reviews) {
          if (adminReviews.isNotEmpty &&
              !level2.any((element) =>
                  element.state == 'CHANGES_REQUESTED' &&
                  widget.appState.isAdminReviewer[element.user!.id] != true)) {
            if (adminReviews
                .any((element) => element.state == 'CHANGES_REQUESTED')) {
              _updateLevel2ReviewInfo(
                  pr.id, 'CHANGES_REQUESTED', 'CHANGES_REQUESTED', true);
            } else if (adminReviews
                .any((element) => element.state == 'APPROVED')) {
              _updateLevel2ReviewInfo(pr.id, 'APPROVED', 'APPROVED', true);
            } else {
              _updateLevel2ReviewInfo(pr.id, 'PENDING', 'PENDING', true);
            }
          } else {
            int changesRequestedCount = level2
                .where((element) => element.state == 'CHANGES_REQUESTED')
                .length;
            int approvedCount =
                level2.where((element) => element.state == 'APPROVED').length;

            if (changesRequestedCount >= 2) {
              _updateLevel2ReviewInfo(
                  pr.id, 'CHANGES_REQUESTED', 'CHANGES_REQUESTED');
            } else if (changesRequestedCount == 1) {
              if (approvedCount >= 1) {
                _updateLevel2ReviewInfo(pr.id, 'CHANGES_REQUESTED', 'APPROVED');
              } else {
                _updateLevel2ReviewInfo(pr.id, 'CHANGES_REQUESTED', 'PENDING');
              }
            } else if (approvedCount >= 2) {
              _updateLevel2ReviewInfo(pr.id, 'APPROVED', 'APPROVED');
            } else if (approvedCount == 1) {
              _updateLevel2ReviewInfo(pr.id, 'APPROVED', 'PENDING');
            } else {
              _updateLevel2ReviewInfo(pr.id, 'PENDING', 'PENDING');
            }
          }
        } else {
          if (level2.isNotEmpty) {
            if (level2.any((element) => element.state == 'CHANGES_REQUESTED')) {
              _updateLevel2ReviewInfo(
                  pr.id, 'CHANGES_REQUESTED', 'CHANGES_REQUESTED');
            } else if (level2.any((element) => element.state == 'APPROVED')) {
              _updateLevel2ReviewInfo(pr.id, 'APPROVED', 'APPROVED');
            } else {
              _updateLevel2ReviewInfo(pr.id, 'PENDING', 'PENDING');
            }
          } else {
            _updateLevel2ReviewInfo(pr.id, 'PENDING', 'PENDING');
          }
        }
      });

      if (pr.user!.id == widget.appState.currentUser!.id) {
        if (widget.appState.settings.showYourDrafts) {
          _myPullRequests.add(pr);
        } else if (!pr.draft) {
          _myPullRequests.add(pr);
        }
        _loadingCount--;
        _finalizeList();
        return;
      }

      var level =
          widget.appState.memberLevel[widget.appState.currentUser!.id] ?? 1;

      if (widget.appState.settings.showReviewed) {
        _pullRequests.add(pr);
      } else if (pr.requestedReviewers
              ?.any((e) => e.id == widget.appState.currentUser!.id) ==
          true) {
        _pullRequests.add(pr);
      } else if (level == 1 && level1.isEmpty) {
        _pullRequests.add(pr);
      } else if (level == 2 && level2.isEmpty) {
        _pullRequests.add(pr);
      }

      _loadingCount--;
      _finalizeList();
    } on Exception catch (e) {
      if (!mounted) return;
      SnackbarService.show(context, e.toString());
      _loadingCount--;
      _finalizeList();
    }
  }

  void _finalizeList() {
    if (_loadingCount != 0) {
      return;
    }
    switch (widget.appState.settings.sortMode) {
      case SortMode.alphabetical:
        _pullRequests.sort((a, b) => a.title.compareTo(b.title));
        _myPullRequests.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortMode.mostRecent:
        _pullRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _myPullRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortMode.leastRecent:
        _pullRequests.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        _myPullRequests.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortMode.bogo:
        _pullRequests.shuffle();
        _myPullRequests.shuffle();
        break;
    }

    setState(() {
      _filteredPullRequests.clear();
      _filteredPullRequests.addAll(_pullRequests);
      _filteredMyPullRequests.clear();
      _filteredMyPullRequests.addAll(_myPullRequests);
    });
  }

  Color _getColor(String state) {
    switch (state) {
      case 'CHANGES_REQUESTED':
        return Colors.yellow;
      case 'APPROVED':
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  @override
  void initState() {
    refresh();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_refreshCountdown > 0) {
        if (_loadingCount == 0) {
          setState(() {
            _refreshCountdown--;
          });
        }
      } else {
        refresh();
      }
    });
    super.initState();
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: _filteredPullRequests.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Container(
          color: index.isEven ? Colors.black26 : Colors.black12,
          child: ListTile(
            title: Text(
              _filteredPullRequests[index].title,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            subtitle: Text(_filteredPullRequests[index].base.repo.name,
                style: const TextStyle(color: Colors.white60)),
            leading: CircleAvatar(
              backgroundImage:
                  NetworkImage(_filteredPullRequests[index].user!.avatarUrl!),
            ),
            onTap: () =>
                launchUrl(Uri.parse(_filteredPullRequests[index].htmlUrl)),
            mouseCursor: SystemMouseCursors.click,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Level 1',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                const SizedBox(width: 5),
                Icon(
                  Icons.circle,
                  color: _getColor(_level1[_filteredPullRequests[index].id]!),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Level 2',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                const SizedBox(width: 5),
                Row(
                  children: [
                    SplitCircle(
                      colorLeft: _getColor(
                          _level2Reviews[_filteredPullRequests[index].id]!
                              .level2aStatus),
                      colorRight: _getColor(
                          _level2Reviews[_filteredPullRequests[index].id]!
                              .level2bStatus),
                      showStar: _level2Reviews[_filteredPullRequests[index].id]!
                          .isAdminReview,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildYourList() {
    return ListView.builder(
      itemCount: _filteredMyPullRequests.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Container(
          color: index.isEven ? Colors.black26 : Colors.black12,
          child: ListTile(
            title: Text(
              _filteredMyPullRequests[index].title,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            subtitle: Text(_filteredMyPullRequests[index].base.repo.name,
                style: const TextStyle(color: Colors.white60)),
            leading: CircleAvatar(
              backgroundImage:
                  NetworkImage(_filteredMyPullRequests[index].user!.avatarUrl!),
            ),
            onTap: () =>
                launchUrl(Uri.parse(_filteredMyPullRequests[index].htmlUrl)),
            mouseCursor: SystemMouseCursors.click,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Level 1',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                const SizedBox(width: 5),
                Icon(
                  Icons.circle,
                  color: _getColor(_level1[_filteredMyPullRequests[index].id]!),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Level 2',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                const SizedBox(width: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SplitCircle(
                      colorLeft: _getColor(
                          _level2Reviews[_filteredMyPullRequests[index].id]!
                              .level2aStatus),
                      colorRight: _getColor(
                          _level2Reviews[_filteredMyPullRequests[index].id]!
                              .level2bStatus),
                      showStar:
                          _level2Reviews[_filteredMyPullRequests[index].id]!
                              .isAdminReview,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _secondsToTime() {
    var minutes = (_refreshCountdown / 60).floor();
    var remainingSeconds = _refreshCountdown % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _filter(String value) {
    setState(() {
      _filteredPullRequests.clear();
      _filteredPullRequests.addAll(_pullRequests
          .where((pr) => pr.title.toLowerCase().contains(value.toLowerCase())));
      _filteredMyPullRequests.clear();
      _filteredMyPullRequests.addAll(_myPullRequests
          .where((pr) => pr.title.toLowerCase().contains(value.toLowerCase())));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Colors.white10,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        labelStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.search, color: Colors.white),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: _filter,
                    ),
                  ),
                  const Spacer(),
                  Text('Refresh in ${_secondsToTime()}',
                      style:
                          const TextStyle(fontSize: 24, color: Colors.white)),
                  const SizedBox(width: 20),
                  _loading
                      ? const SizedBox(
                          height: 32,
                          width: 32,
                          child: CircularProgressIndicator(),
                        )
                      : IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          onPressed: refresh,
                        ),
                ],
              ),
            ),
          ),
          if (_filteredMyPullRequests.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Your pull requests',
                style: TextStyle(fontSize: 24, color: Colors.white)),
            const SizedBox(height: 20),
            _buildYourList(),
          ],
          const SizedBox(height: 20),
          const Text('Pull requests',
              style: TextStyle(fontSize: 24, color: Colors.white)),
          const SizedBox(height: 20),
          if (_filteredPullRequests.isEmpty && !_loading) ...[
            const Text('No pull requests',
                style: TextStyle(fontSize: 20, color: Colors.white)),
          ] else ...[
            _buildList(),
          ],
          if (_loading) ...[
            const SizedBox(height: 10),
            const CircularProgressIndicator(),
          ],
        ],
      ),
    );
  }
}
