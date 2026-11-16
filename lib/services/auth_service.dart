import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/app_user.dart';
import '../utils/validators.dart';

/// Holds the logged-in user. In-memory for now; will be swapped for a real
/// backend (e.g. Firebase Auth) later without changing this public API.
///
/// Screens use it through Provider:
/// ```dart
/// final auth = context.watch<AuthService>(); // rebuild on login/logout
/// context.read<AuthService>().logout();      // one-off call
/// ```
class AuthService extends ChangeNotifier {
  final Map<String, AppUser> _usersById = {};
  final Map<String, String> _passwordsByEmail = {};
  AppUser? _currentUser;
  int _nextId = 100;

  AuthService({bool seed = true}) {
    if (seed) {
      for (final u in MockData.users) {
        _usersById[u.id] = u;
      }
      _passwordsByEmail.addAll(MockData.passwords);
    }
  }

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Look up any user, e.g. to show attendee or organizer names.
  AppUser? userById(String id) => _usersById[id];

  List<AppUser> usersByIds(Iterable<String> ids) =>
      ids.map((id) => _usersById[id]).whereType<AppUser>().toList();

  /// Returns null on success, otherwise an error message to show the user.
  String? login(String email, String password) {
    final e = email.trim().toLowerCase();
    final formError =
        Validators.universityEmail(e) ?? Validators.password(password);
    if (formError != null) return formError;

    if (_passwordsByEmail[e] != password) return 'Incorrect email or password';

    _currentUser = _usersById.values.firstWhere((u) => u.email == e);
    notifyListeners();
    return null;
  }

  /// Creates the account and logs the user in.
  /// Returns null on success, otherwise an error message.
  String? signUp({
    required String fullName,
    required String email,
    required String department,
    required String password,
  }) {
    final e = email.trim().toLowerCase();
    final formError =
        Validators.fullName(fullName) ??
        Validators.universityEmail(e) ??
        Validators.department(department) ??
        Validators.password(password);
    if (formError != null) return formError;

    if (_passwordsByEmail.containsKey(e)) {
      return 'An account with this email already exists';
    }

    final user = AppUser(
      id: 'u${_nextId++}',
      fullName: fullName.trim(),
      email: e,
      department: department.trim(),
    );
    _usersById[user.id] = user;
    _passwordsByEmail[e] = password;
    _currentUser = user;
    notifyListeners();
    return null;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
