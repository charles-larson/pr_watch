import 'package:pr_watch/models/member.dart';

class Repository {
  final int id;
  final String nodeId;
  final String name;
  final String fullName;
  final Member owner;
  final bool private;
  final String htmlUrl;
  final String? description;
  final bool fork;
  final String url;
  final String archiveUrl;
  final String assigneesUrl;
  final String blobsUrl;
  final String branchesUrl;
  final String collaboratorsUrl;
  final String commentsUrl;
  final String commitsUrl;
  final String compareUrl;
  final String contentsUrl;
  final String contributorsUrl;
  final String deploymentsUrl;
  final String downloadsUrl;
  final String eventsUrl;
  final String forksUrl;
  final String gitCommitsUrl;
  final String gitRefsUrl;
  final String gitTagsUrl;
  final String gitUrl;
  final String issueCommentUrl;
  final String issueEventsUrl;
  final String issuesUrl;
  final String keysUrl;
  final String labelsUrl;
  final String languagesUrl;
  final String mergesUrl;
  final String milestonesUrl;
  final String notificationsUrl;
  final String pullsUrl;
  final String releasesUrl;
  final String sshUrl;
  final String stargazersUrl;
  final String statusesUrl;
  final String subscribersUrl;
  final String subscriptionUrl;
  final String tagsUrl;
  final String teamsUrl;
  final String treesUrl;
  final String cloneUrl;
  final String? mirrorUrl;
  final String hooksUrl;
  final String svnUrl;
  final String? homepage;
  final String? language;
  final int forksCount;
  final int stargazersCount;
  final int watchersCount;
  final int size;
  final String defaultBranch;
  final int openIssuesCount;
  final bool? isTemplate;
  final List<String> topics;
  final bool hasIssues;
  final bool hasProjects;
  final bool hasWiki;
  final bool hasPages;
  final bool hasDownloads;
  final bool archived;
  final bool disabled;
  final String visibility;
  final DateTime? pushedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, bool>? permissions;
  final dynamic securityAndAnalysis;

  Repository({
    required this.id,
    required this.nodeId,
    required this.name,
    required this.fullName,
    required this.owner,
    required this.private,
    required this.htmlUrl,
    required this.description,
    required this.fork,
    required this.url,
    required this.archiveUrl,
    required this.assigneesUrl,
    required this.blobsUrl,
    required this.branchesUrl,
    required this.collaboratorsUrl,
    required this.commentsUrl,
    required this.commitsUrl,
    required this.compareUrl,
    required this.contentsUrl,
    required this.contributorsUrl,
    required this.deploymentsUrl,
    required this.downloadsUrl,
    required this.eventsUrl,
    required this.forksUrl,
    required this.gitCommitsUrl,
    required this.gitRefsUrl,
    required this.gitTagsUrl,
    required this.gitUrl,
    required this.issueCommentUrl,
    required this.issueEventsUrl,
    required this.issuesUrl,
    required this.keysUrl,
    required this.labelsUrl,
    required this.languagesUrl,
    required this.mergesUrl,
    required this.milestonesUrl,
    required this.notificationsUrl,
    required this.pullsUrl,
    required this.releasesUrl,
    required this.sshUrl,
    required this.stargazersUrl,
    required this.statusesUrl,
    required this.subscribersUrl,
    required this.subscriptionUrl,
    required this.tagsUrl,
    required this.teamsUrl,
    required this.treesUrl,
    required this.cloneUrl,
    required this.mirrorUrl,
    required this.hooksUrl,
    required this.svnUrl,
    required this.homepage,
    required this.language,
    required this.forksCount,
    required this.stargazersCount,
    required this.watchersCount,
    required this.size,
    required this.defaultBranch,
    required this.openIssuesCount,
    required this.isTemplate,
    required this.topics,
    required this.hasIssues,
    required this.hasProjects,
    required this.hasWiki,
    required this.hasPages,
    required this.hasDownloads,
    required this.archived,
    required this.disabled,
    required this.visibility,
    required this.pushedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.permissions,
    required this.securityAndAnalysis,
  });

  factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
      id: json['id'],
      nodeId: json['node_id'],
      name: json['name'],
      fullName: json['full_name'],
      owner: Member.fromJson(json['owner']),
      private: json['private'],
      htmlUrl: json['html_url'],
      description: json['description'],
      fork: json['fork'],
      url: json['url'],
      archiveUrl: json['archive_url'],
      assigneesUrl: json['assignees_url'],
      blobsUrl: json['blobs_url'],
      branchesUrl: json['branches_url'],
      collaboratorsUrl: json['collaborators_url'],
      commentsUrl: json['comments_url'],
      commitsUrl: json['commits_url'],
      compareUrl: json['compare_url'],
      contentsUrl: json['contents_url'],
      contributorsUrl: json['contributors_url'],
      deploymentsUrl: json['deployments_url'],
      downloadsUrl: json['downloads_url'],
      eventsUrl: json['events_url'],
      forksUrl: json['forks_url'],
      gitCommitsUrl: json['git_commits_url'],
      gitRefsUrl: json['git_refs_url'],
      gitTagsUrl: json['git_tags_url'],
      gitUrl: json['git_url'],
      issueCommentUrl: json['issue_comment_url'],
      issueEventsUrl: json['issue_events_url'],
      issuesUrl: json['issues_url'],
      keysUrl: json['keys_url'],
      labelsUrl: json['labels_url'],
      languagesUrl: json['languages_url'],
      mergesUrl: json['merges_url'],
      milestonesUrl: json['milestones_url'],
      notificationsUrl: json['notifications_url'],
      pullsUrl: json['pulls_url'],
      releasesUrl: json['releases_url'],
      sshUrl: json['ssh_url'],
      stargazersUrl: json['stargazers_url'],
      statusesUrl: json['statuses_url'],
      subscribersUrl: json['subscribers_url'],
      subscriptionUrl: json['subscription_url'],
      tagsUrl: json['tags_url'],
      teamsUrl: json['teams_url'],
      treesUrl: json['trees_url'],
      cloneUrl: json['clone_url'],
      mirrorUrl: json['mirror_url'],
      hooksUrl: json['hooks_url'],
      svnUrl: json['svn_url'],
      homepage: json['homepage'],
      language: json['language'],
      forksCount: json['forks_count'],
      stargazersCount: json['stargazers_count'],
      watchersCount: json['watchers_count'],
      size: json['size'],
      defaultBranch: json['default_branch'],
      openIssuesCount: json['open_issues_count'],
      isTemplate: json['is_template'],
      topics: List<String>.from(json['topics']),
      hasIssues: json['has_issues'],
      hasProjects: json['has_projects'],
      hasWiki: json['has_wiki'],
      hasPages: json['has_pages'],
      hasDownloads: json['has_downloads'],
      archived: json['archived'],
      disabled: json['disabled'],
      visibility: json['visibility'],
      pushedAt:
          json['pushed_at'] != null ? DateTime.parse(json['pushed_at']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      permissions: json['permissions'] != null
          ? Map<String, bool>.from(json['permissions'])
          : null,
      securityAndAnalysis: json['security_and_analysis'],
    );
  }

  static Map<String, dynamic> toJson(Repository value) => {
        'id': value.id,
        'node_id': value.nodeId,
        'name': value.name,
        'full_name': value.fullName,
        'owner': value.owner,
        'private': value.private,
        'html_url': value.htmlUrl,
        'description': value.description,
        'fork': value.fork,
        'url': value.url,
        'archive_url': value.archiveUrl,
        'assignees_url': value.assigneesUrl,
        'blobs_url': value.blobsUrl,
        'branches_url': value.branchesUrl,
        'collaborators_url': value.collaboratorsUrl,
        'comments_url': value.commentsUrl,
        'commits_url': value.commitsUrl,
        'compare_url': value.compareUrl,
        'contents_url': value.contentsUrl,
        'contributors_url': value.contributorsUrl,
        'deployments_url': value.deploymentsUrl,
        'downloads_url': value.downloadsUrl,
        'events_url': value.eventsUrl,
        'forks_url': value.forksUrl,
        'git_commits_url': value.gitCommitsUrl,
        'git_refs_url': value.gitRefsUrl,
        'git_tags_url': value.gitTagsUrl,
        'git_url': value.gitUrl,
        'issue_comment_url': value.issueCommentUrl,
        'issue_events_url': value.issueEventsUrl,
        'issues_url': value.issuesUrl,
        'keys_url': value.keysUrl,
        'labels_url': value.labelsUrl,
        'languages_url': value.languagesUrl,
        'merges_url': value.mergesUrl,
        'milestones_url': value.milestonesUrl,
        'notifications_url': value.notificationsUrl,
        'pulls_url': value.pullsUrl,
        'releases_url': value.releasesUrl,
        'ssh_url': value.sshUrl,
        'stargazers_url': value.stargazersUrl,
        'statuses_url': value.statusesUrl,
        'subscribers_url': value.subscribersUrl,
        'subscription_url': value.subscriptionUrl,
        'tags_url': value.tagsUrl,
        'teams_url': value.teamsUrl,
        'trees_url': value.treesUrl,
        'clone_url': value.cloneUrl,
        'mirror_url': value.mirrorUrl,
        'hooks_url': value.hooksUrl,
        'svn_url': value.svnUrl,
        'homepage': value.homepage,
        'language': value.language,
        'forks_count': value.forksCount,
        'stargazers_count': value.stargazersCount,
        'watchers_count': value.watchersCount,
        'size': value.size,
        'default_branch': value.defaultBranch,
        'open_issues_count': value.openIssuesCount,
        'is_template': value.isTemplate,
        'topics': value.topics,
        'has_issues': value.hasIssues,
        'has_projects': value.hasProjects,
        'has_wiki': value.hasWiki,
        'has_pages': value.hasPages,
        'has_downloads': value.hasDownloads,
        'archived': value.archived,
        'disabled': value.disabled,
        'visibility': value.visibility,
        'pushed_at': value.pushedAt?.toIso8601String(),
        'created_at': value.createdAt?.toIso8601String(),
        'updated_at': value.updatedAt?.toIso8601String(),
        'permissions': value.permissions,
        'security_and_analysis': value.securityAndAnalysis,
      };
}
