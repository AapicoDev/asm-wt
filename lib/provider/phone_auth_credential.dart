import 'package:firebase_auth/firebase_auth.dart';

const _kProviderId = 'phone';

abstract class AuthProvider {
  /// Constructs a new instance with a given provider identifier.
  AuthProvider(this.providerId);

  /// The provider ID.
  final String providerId;

  @override
  String toString() {
    return 'AuthProvider(providerId: $providerId)';
  }
}

/// This class should be used to either create a new Phone credential with an
/// verification ID and SMS code.
///
/// Typically this provider will be used when calling [verifyPhoneNumber] to
/// generate a new [PhoneAuthCredential] when a SMS code has been sent.
class PhoneAuthProvider extends AuthProvider {
  /// Creates a new instance.
  PhoneAuthProvider() : super(_kProviderId);

  // ignore: public_member_api_docs
  static String get PHONE_SIGN_IN_METHOD {
    return _kProviderId;
  }

  // ignore: public_member_api_docs
  static String get PROVIDER_ID {
    return _kProviderId;
  }

  /// Create a new [PhoneAuthCredential] from a provided [verificationId] and
  /// [smsCode].
  static PhoneAuthCredential credential({
    required String verificationId,
    required String smsCode,
  }) {
    return PhoneAuthCredential._credential(verificationId, smsCode);
  }

  /// Create a [PhoneAuthCredential] from an internal token, where the ID
  /// relates to a natively stored credential.
  static PhoneAuthCredential credentialFromToken(int token, {String? smsCode}) {
    return PhoneAuthCredential._credentialFromToken(token, smsCode: smsCode);
  }
}

class PhoneAuthCredential extends AuthCredential {
  PhoneAuthCredential._({
    this.verificationId,
    this.smsCode,
    int? token,
  }) : super(
          providerId: _kProviderId,
          signInMethod: _kProviderId,
          token: token,
        );

  factory PhoneAuthCredential._credential(
      String verificationId, String smsCode) {
    return PhoneAuthCredential._(
        verificationId: verificationId, smsCode: smsCode);
  }

  factory PhoneAuthCredential._credentialFromToken(
    int token, {
    String? smsCode,
  }) {
    return PhoneAuthCredential._(token: token, smsCode: smsCode);
  }

  /// The phone auth verification ID.
  final String? verificationId;

  /// The SMS code sent to and entered by the user.
  final String? smsCode;

  /// Returns the credential as a serialized [Map].
  @override
  Map<String, dynamic> asMap() {
    return <String, dynamic>{
      'providerId': providerId,
      'signInMethod': signInMethod,
      'verificationId': verificationId,
      'smsCode': smsCode,
      'token': token,
    };
  }
}
