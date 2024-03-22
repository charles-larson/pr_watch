class Organization {
  final String login;
  final int id;
  final String nodeId;
  final String url;
  final String reposUrl;
  final String eventsUrl;
  final String hooksUrl;
  final String issuesUrl;
  final String membersUrl;
  final String publicMembersUrl;
  final String avatarUrl;
  final String? description;

  Organization({
    required this.login,
    required this.id,
    required this.nodeId,
    required this.url,
    required this.reposUrl,
    required this.eventsUrl,
    required this.hooksUrl,
    required this.issuesUrl,
    required this.membersUrl,
    required this.publicMembersUrl,
    required this.avatarUrl,
    required this.description,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      login: json['login'],
      id: json['id'],
      nodeId: json['node_id'],
      url: json['url'],
      reposUrl: json['repos_url'],
      eventsUrl: json['events_url'],
      hooksUrl: json['hooks_url'],
      issuesUrl: json['issues_url'],
      membersUrl: json['members_url'],
      publicMembersUrl: json['public_members_url'],
      avatarUrl: json['avatar_url'],
      description: json['description'],
    );
  }

  static Map<String, dynamic> toJson(Organization value) => {
        'login': value.login,
        'id': value.id,
        'node_id': value.nodeId,
        'url': value.url,
        'repos_url': value.reposUrl,
        'events_url': value.eventsUrl,
        'hooks_url': value.hooksUrl,
        'issues_url': value.issuesUrl,
        'members_url': value.membersUrl,
        'public_members_url': value.publicMembersUrl,
        'avatar_url': value.avatarUrl,
        'description': value.description,
      };
}
