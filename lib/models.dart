/// Indicates who is responsible (if known) for a failed request.
///
/// For example, if a client is using an invalid AWS access key, the returned
/// exception will indicate that there is an error in the request the caller
/// is sending. Retrying that same request will *not* result in a successful
/// response. The Client ErrorType indicates that there is a problem in the
/// request the user is sending (ex: incorrect access keys, invalid parameter
/// value, missing parameter, etc.), and that the caller must take some
/// action to correct the request before it should be resent. Client errors
/// are typically associated an HTTP error code in the 4xx range.
///
/// The Service ErrorType indicates that although the request the caller sent
/// was valid, the service was unable to fulfill the request because of
/// problems on the service's side. These types of errors can be retried by
/// the caller since the caller's request was valid and the problem occurred
/// while processing the request on the service side. Service errors will be
/// accompanied by an HTTP error code in the 5xx range.
///
/// Finally, if there isn't enough information to determine who's fault the
/// error response is, an Unknown ErrorType will be set.
enum ErrorType { Client, Service, Unknown }

enum UserState {
  SIGNED_IN,
  GUEST,
  SIGNED_OUT_FEDERATED_TOKENS_INVALID,
  SIGNED_OUT_USER_POOLS_TOKENS_INVALID,
  SIGNED_OUT,
  UNKNOWN,
}

enum SignInState {
  /// Next challenge is to supply an SMS_MFA_CODE, delivered via SMS.
  SMS_MFA,

  /// Next challenge is to supply PASSWORD_CLAIM_SIGNATURE, PASSWORD_CLAIM_SECRET_BLOCK, and TIMESTAMP after the client-side SRP calculations.
  PASSWORD_VERIFIER,

  /// This is returned if your custom authentication flow determines that the user should pass another challenge before tokens are issued.
  CUSTOM_CHALLENGE,

  /// If device tracking was enabled on your user pool and the previous challenges were passed, this challenge is returned so that Amazon Cognito can start tracking this device.
  DEVICE_SRP_AUTH,

  /// Similar to PASSWORD_VERIFIER, but for devices only.
  DEVICE_PASSWORD_VERIFIER,

  /// This is returned if you need to authenticate with USERNAME and PASSWORD directly. An app client must be enabled to use this flow.
  ADMIN_NO_SRP_AUTH,

  /// For users which are required to change their passwords after successful first login. This challenge should be passed with NEW_PASSWORD and any other required attributes.
  NEW_PASSWORD_REQUIRED,

  /// The flow is completed and no further steps are possible.
  DONE,

  /// Unknown sign-in state, potentially unsupported state
  UNKNOWN
}

enum ForgotPasswordState { CONFIRMATION_CODE, DONE, UNKNOWN }

/// Determines where the confirmation code was sent.
class UserCodeDeliveryDetails {
  final String attributeName, destination, deliveryMedium;

  UserCodeDeliveryDetails._internal(List msg)
      : attributeName = msg[0],
        destination = msg[1],
        deliveryMedium = msg[2];

  factory UserCodeDeliveryDetails.fromMsg(List msg) {
    return UserCodeDeliveryDetails._internal(msg);
  }

  @override
  String toString() {
    return "UserCodeDeliveryDetails { attributeName: $attributeName, "
        "destination: $destination, deliveryMedium: $deliveryMedium }";
  }
}

/// The result from signing-in. Check the state to determine the next step.
class SignInResult {
  final SignInState signInState;

  /// Used to determine the type of challenge that is being present from the service
  final Map<String, String>? parameters;
  final UserCodeDeliveryDetails userCodeDeliveryDetails;

  @override
  String toString() {
    return "SignInResult { signInState: $signInState, parameters: $parameters, "
        "userCodeDeliveryDetails: $userCodeDeliveryDetails }";
  }

  SignInResult.fromMsg(List msg)
      : signInState = SignInState.values[msg[0]],
        parameters = (msg[1] == null) ? null : Map<String, String>.from(msg[1]),
        userCodeDeliveryDetails =
            UserCodeDeliveryDetails.fromMsg(msg.sublist(2));
}

/// The result of a sign up action. Check the confirmation state and delivery details to proceed.
class SignUpResult {
  /// - [true] -> user is confirmed, no further action is necessary.
  /// - [false] -> check delivery details and call [confirmSignUp()].
  final bool confirmationState;
  final UserCodeDeliveryDetails userCodeDeliveryDetails;

  @override
  String toString() {
    return "SignUpResult { confirmationState: $confirmationState, "
        "userCodeDeliveryDetails: $userCodeDeliveryDetails }";
  }

  SignUpResult.fromMsg(List msg)
      : confirmationState = msg[0],
        userCodeDeliveryDetails =
            UserCodeDeliveryDetails.fromMsg(msg.sublist(1));
}

/// The result of a forgot password action
class ForgotPasswordResult {
  final ForgotPasswordState state;
  final UserCodeDeliveryDetails parameters;

  @override
  String toString() {
    return "ForgotPasswordResult { state: $state, parameters: $parameters }";
  }

  ForgotPasswordResult.fromMsg(List msg)
      : state = ForgotPasswordState.values[msg[0]],
        parameters = UserCodeDeliveryDetails.fromMsg(msg.sublist(1));
}

/// A container for different types of [Token]s.
class Tokens {
  final String accessToken, idToken, refreshToken;

  Tokens.fromMsg(List msg)
      : accessToken = msg[0],
        idToken = msg[1],
        refreshToken = msg[2];

  @override
  String toString() {
    return "Tokens { acessToken: $accessToken, "
        "idToken: $idToken, refreshToken: $refreshToken }";
  }
}

class Credentials {
  final String accessKey, secretKey, sessionToken;
  DateTime expiry;

  Credentials.fromMsg(List msg)
      : accessKey = msg[0],
        secretKey = msg[1],
        sessionToken = msg[2],
        expiry = DateTime.fromMillisecondsSinceEpoch(msg[3]);

  @override
  String toString() {
    return "Credentials { accessKey: $accessKey, secretKey: $secretKey, sesionToken: $sessionToken, expiry: $expiry }";
  }
}
