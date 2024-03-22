import 'package:pr_watch/models/member.dart';
import 'package:pr_watch/models/organization.dart';
import 'package:pr_watch/models/repository.dart';
import 'package:pr_watch/models/settings.dart';
import 'package:pr_watch/models/team.dart';
import 'package:pr_watch/models/user.dart';

class AppState {
  User? currentUser;
  Organization? currentOrganization;
  Team? currentTeam;
  List<Repository> repositories = [];
  List<Member> members = []; // create wrapper model for this list and maps
  Map<int, bool> isMemberWatched = {};
  Map<int, int> memberLevel = {};
  Settings settings = Settings.defaultSettings;

  AppState({
    this.currentUser,
    this.currentOrganization,
    this.currentTeam,
    this.repositories = const [],
    this.members = const [],
  });

  bool get configured => currentOrganization != null && currentTeam != null;
}
