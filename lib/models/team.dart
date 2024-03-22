class Team {
  final int id;
  final String nodeId;
  final String url;
  final String htmlUrl;
  final String name;
  final String slug;
  final String? description;
  final String privacy;
  final String permission;
  final String membersUrl;
  final String repositoriesUrl;

  Team({
    required this.id,
    required this.nodeId,
    required this.url,
    required this.htmlUrl,
    required this.name,
    required this.slug,
    required this.description,
    required this.privacy,
    required this.permission,
    required this.membersUrl,
    required this.repositoriesUrl,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      nodeId: json['node_id'],
      url: json['url'],
      htmlUrl: json['html_url'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      privacy: json['privacy'],
      permission: json['permission'],
      membersUrl: json['members_url'],
      repositoriesUrl: json['repositories_url'],
    );
  }

  static Map<String, dynamic> toJson(Team value) => {
        'id': value.id,
        'node_id': value.nodeId,
        'url': value.url,
        'html_url': value.htmlUrl,
        'name': value.name,
        'slug': value.slug,
        'description': value.description,
        'privacy': value.privacy,
        'permission': value.permission,
        'members_url': value.membersUrl,
        'repositories_url': value.repositoriesUrl,
      };
}
