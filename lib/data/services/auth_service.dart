import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Check if user is already logged in
  User? get currentUser => _auth.currentUser;

  // 2. Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 3. Start Phone Login (Sends SMS)
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String, int?) onCodeSent,
    required Function(FirebaseAuthException) onVerificationFailed,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,

      // Handle automatic verification (Android only feature)
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },

      // Handle errors (invalid number, blocked, etc.)
      verificationFailed: onVerificationFailed,

      // When SMS is sent, we get a verificationId. We need this to check the OTP later.
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId, resendToken);
      },

      // Auto-retrieval timeout (usually for Android auto-fill)
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // 4. Verify OTP (User enters code)
  Future<UserCredential> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    // Create a credential using the ID we got earlier + the code user typed
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    // Sign in
    return await _auth.signInWithCredential(credential);
  }
}
