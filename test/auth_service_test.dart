import 'package:flutter_test/flutter_test.dart';
import 'package:sumeet/data/mock_data.dart';
import 'package:sumeet/services/auth_service.dart';

void main() {
  late AuthService auth;
  setUp(() => auth = AuthService());

  test('demo user can log in and out', () {
    expect(auth.login(MockData.demoEmail, MockData.demoPassword), isNull);
    expect(auth.currentUser?.fullName, 'Demo Student');
    auth.logout();
    expect(auth.isLoggedIn, isFalse);
  });

  test('wrong password is rejected', () {
    expect(
      auth.login(MockData.demoEmail, 'wrongpass'),
      'Incorrect email or password',
    );
    expect(auth.isLoggedIn, isFalse);
  });

  test('non-university email is rejected', () {
    expect(
      auth.login('demo@gmail.com', 'demo123'),
      'Use your @sabanciuniv.edu email',
    );
  });

  test('sign up creates and logs in the user', () {
    final err = auth.signUp(
      fullName: 'Kaan Test',
      email: 'Kaan.Test@sabanciuniv.edu',
      department: 'CS',
      password: 'secret1',
    );
    expect(err, isNull);
    expect(auth.currentUser?.email, 'kaan.test@sabanciuniv.edu');

    auth.logout();
    expect(auth.login('kaan.test@sabanciuniv.edu', 'secret1'), isNull);
  });

  test('duplicate email cannot sign up', () {
    final err = auth.signUp(
      fullName: 'Someone',
      email: MockData.demoEmail,
      department: 'CS',
      password: 'secret1',
    );
    expect(err, 'An account with this email already exists');
  });

  test('short name for attendee list', () {
    expect(auth.userById('u2')?.shortName, 'Ayşe Y.');
  });
}
