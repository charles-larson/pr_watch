class Member {
  final String? name;
  final String? email;
  final String login;
  final int id;
  final String nodeId;
  final String? avatarUrl;
  final String gravatarId;
  final String url;
  final String htmlUrl;
  final String followersUrl;
  final String followingUrl;
  final String gistsUrl;
  final String starredUrl;
  final String subscriptionsUrl;
  final String organizationsUrl;
  final String reposUrl;
  final String eventsUrl;
  final String receivedEventsUrl;
  final String type;
  final bool siteAdmin;

  Member({
    required this.name,
    required this.email,
    required this.login,
    required this.id,
    required this.nodeId,
    required this.avatarUrl,
    required this.gravatarId,
    required this.url,
    required this.htmlUrl,
    required this.followersUrl,
    required this.followingUrl,
    required this.gistsUrl,
    required this.starredUrl,
    required this.subscriptionsUrl,
    required this.organizationsUrl,
    required this.reposUrl,
    required this.eventsUrl,
    required this.receivedEventsUrl,
    required this.type,
    required this.siteAdmin,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      name: json['name'],
      email: json['email'],
      login: json['login'],
      id: json['id'],
      nodeId: json['node_id'],
      avatarUrl: json['avatar_url'],
      gravatarId: json['gravatar_id'],
      url: json['url'],
      htmlUrl: json['html_url'],
      followersUrl: json['followers_url'],
      followingUrl: json['following_url'],
      gistsUrl: json['gists_url'],
      starredUrl: json['starred_url'],
      subscriptionsUrl: json['subscriptions_url'],
      organizationsUrl: json['organizations_url'],
      reposUrl: json['repos_url'],
      eventsUrl: json['events_url'],
      receivedEventsUrl: json['received_events_url'],
      type: json['type'],
      siteAdmin: json['site_admin'],
    );
  }

  static Map<String, dynamic> toJson(Member value) => {
        'name': value.name,
        'email': value.email,
        'login': value.login,
        'id': value.id,
        'node_id': value.nodeId,
        'avatar_url': value.avatarUrl,
        'gravatar_id': value.gravatarId,
        'url': value.url,
        'html_url': value.htmlUrl,
        'followers_url': value.followersUrl,
        'following_url': value.followingUrl,
        'gists_url': value.gistsUrl,
        'starred_url': value.starredUrl,
        'subscriptions_url': value.subscriptionsUrl,
        'organizations_url': value.organizationsUrl,
        'repos_url': value.reposUrl,
        'events_url': value.eventsUrl,
        'received_events_url': value.receivedEventsUrl,
        'type': value.type,
        'site_admin': value.siteAdmin,
      };
}
