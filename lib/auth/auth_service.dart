import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// The `userStream` is a stream of `User` objects that will emit a new `User` object whenever the
/// user's authentication state changes
class AuthService {
  /// Creating a stream of `User` objects that will emit a new `User` object whenever the user's
  /// authentication state changes.
  final userStream = FirebaseAuth.instance.authStateChanges();

  /// A getter that returns the current user.
  final user = FirebaseAuth.instance.currentUser;

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// `signInWithApple()` is a function that uses the `SignInWithApple` plugin to get an
  /// `AppleIDCredential` from the user, then uses the `FirebaseAuth` plugin to sign in the user with the
  /// `AppleIDCredential`
  ///
  /// Returns:
  ///   A UserCredential object.
  Future<UserCredential> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    return FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  /// It signs out the user from the app
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
