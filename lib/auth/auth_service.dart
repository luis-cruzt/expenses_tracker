import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// The `userStream` is a stream of `User` objects that will emit a new `User` object whenever the
/// user's authentication state changes
class AuthService {
  /// Creating a stream of `User` objects that will emit a new `User` object whenever the user's
  /// authentication state changes.
  final userStream = FirebaseAuth.instance.authStateChanges();

  /// A getter that returns the current user.
  final user = FirebaseAuth.instance.currentUser;

  Future<void> googleLogin() async {
    try {
      final googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(authCredential);
    } on FirebaseAuthException catch (e) {
      // handle error
    }
  }

  /// It signs out the user from the app
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
