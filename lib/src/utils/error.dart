import 'dart:convert';

/// Defines error info type. This includes a code and message string.
class ErrorInfo {
  const ErrorInfo({required this.code, required this.message});

  final String code;
  final String message;

  ErrorInfo copyWith({String? message}) {
    return ErrorInfo(code: code, message: message ?? this.message);
  }
}

class FirebaseArrayIndexError {
  const FirebaseArrayIndexError(this.index, this.error);

  final int index;
  final FirebaseError error;
}

/// Firebase error code structure. This extends Error.
///
/// [errorInfo] The error information (code and message).
class FirebaseError extends StateError {
  FirebaseError._(this.code, String message) : super(message);

  /// A FirebaseError with a prefix in front of the error code.
  ///
  /// [codePrefix] The prefix to apply to the error code.
  /// [code] The error code.
  /// [message] The error message.
  factory FirebaseError.prefixed(String codePrefix, String code, String message) {
    return FirebaseError._('$codePrefix/$code', message);
  }

  /// Firebase App error code structure.
  ///
  /// [code] The error code.
  /// [message] The error message.
  factory FirebaseError.app(String code, String message) {
    return FirebaseError.prefixed('app', code, message);
  }

  /// Firebase Auth error code structure.
  ///
  /// [code] The error code.
  /// [message] The error message.
  factory FirebaseError.auth(ErrorInfo info, [String? message]) {
    return FirebaseError.prefixed('auth', info.code, message ?? info.message);
  }

  /// Creates the developer-facing error corresponding to the backend error code.
  ///
  /// [code] The error code.
  /// [message] The error message.
  factory FirebaseError.authFromServerCode(
      String? serverErrorCode,
      String? message,
      Map<String, dynamic>? rawServerResponse,
      ) {
    // serverErrorCode could contain additional details:
    // ERROR_CODE : Detailed message which can also contain colons
    final int colonSeparator = (serverErrorCode ?? '').indexOf(':');
    String? customMessage;
    if (colonSeparator != -1) {
      customMessage = serverErrorCode!.substring(colonSeparator + 1).trim();
      serverErrorCode = serverErrorCode.substring(0, colonSeparator).trim();
    }
    // If not found, default to internal error.
    final String clientCodeKey = AUTH_SERVER_TO_CLIENT_CODE[serverErrorCode] ?? 'INTERNAL_ERROR';
    ErrorInfo error = AuthClientErrorCode.values[clientCodeKey]!;
    // Server detailed message should have highest priority.
    error = error.copyWith(message: customMessage ?? message ?? error.message);

    if (clientCodeKey == 'INTERNAL_ERROR' && rawServerResponse != null) {
      try {
        error = error.copyWith(message: '${error.message} Raw server response: "${jsonEncode(rawServerResponse)}"');
      } catch (e) {
        // Ignore JSON parsing error.
      }
    }

    return FirebaseError.auth(error);
  }

  /// Firebase Database error code structure.
  ///
  /// [code] The error code.
  /// [message] The error message.
  factory FirebaseError.database(ErrorInfo info, [String? message]) {
    return FirebaseError._('database/${info.code}', message ?? info.message);
  }

  /// Firestore error code structure.
  ///
  /// [code] The error code.
  /// [message] The error message.
  factory FirebaseError.firestore(ErrorInfo info, [String? message]) {
    return FirebaseError._('firestore/${info.code}', message ?? info.message);
  }

  /// Firebase instance ID error code structure.
  ///
  /// [code] The error code.
  /// [message] The error message.
  factory FirebaseError.instanceId(ErrorInfo info, [String? message]) {
    return FirebaseError._('instance-id/${info.code}', message ?? info.message);
  }

  /// Firebase Auth error code structure.
  ///
  /// [code] The error code.
  /// [message] The error message.
  factory FirebaseError.messaging(ErrorInfo info, [String? message]) {
    return FirebaseError.prefixed('auth', info.code, message ?? info.message);
  }

  /// Creates the developer-facing error corresponding to the backend error code.
  ///
  /// [serverErrorCode] The server error code.
  /// [message] The error message. The default message is used if not provided.
  /// [rawServerResponse] The error's raw server response.
  /// Returns the corresponding developer-facing error.
  factory FirebaseError.messagingFromServerCode(
      String? serverErrorCode,
      String? message,
      Map<String, dynamic>? rawServerResponse,
      ) {
    // If not found, default to unknown error.
    String clientCodeKey = 'UNKNOWN_ERROR';

    if (serverErrorCode != null && MESSAGING_SERVER_TO_CLIENT_CODE.containsKey(serverErrorCode)) {
      clientCodeKey = MESSAGING_SERVER_TO_CLIENT_CODE[serverErrorCode]!;
    }
    ErrorInfo error = MessagingClientErrorCode.values[clientCodeKey]!;
    error = error.copyWith(message: message ?? error.message);

    if (clientCodeKey == 'UNKNOWN_ERROR' && rawServerResponse != null) {
      try {
        error = error.copyWith(message: '${error.message} Raw server response: "${jsonEncode(rawServerResponse)}"');
      } catch (e) {
        // Ignore JSON parsing error.
      }
    }

    return FirebaseError.messaging(error);
  }

  factory FirebaseError.messagingFromTopicManagementServerError(
      String serverErrorCode, [
        String? message,
        Map<String, dynamic>? rawServerResponse,
      ]) {
    // If not found, default to unknown error.
    final String clientCodeKey = TOPIC_MGT_SERVER_TO_CLIENT_CODE[serverErrorCode] ?? 'UNKNOWN_ERROR';
    ErrorInfo error = MessagingClientErrorCode.values[clientCodeKey]!;
    error = error.copyWith(message: message ?? error.message);
    if (clientCodeKey == 'UNKNOWN_ERROR' && rawServerResponse != null) {
      try {
        error = error.copyWith(message: '${error.message} Raw server response: "${jsonEncode(rawServerResponse)}"');
      } catch (e) {
        // Ignore JSON parsing error.
      }
    }

    return FirebaseError.messaging(error);
  }

  /// Firebase project management error code structure.
  ///
  /// [code] The error code.
  /// [message] The error message.
  factory FirebaseError.projectManagement(ErrorInfo info, [String? message]) {
    return FirebaseError.prefixed('project-management', info.code, message ?? info.message);
  }

  final String code;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'code': code, 'message': message};
  }
}

/// App client error codes and their default messages.
class AppErrorCodes {
  static const String APP_DELETED = 'app-deleted';
  static const String DUPLICATE_APP = 'duplicate-app';
  static const String INVALID_ARGUMENT = 'invalid-argument';
  static const String INTERNAL_ERROR = 'internal-error';
  static const String INVALID_APP_NAME = 'invalid-app-name';
  static const String INVALID_APP_OPTIONS = 'invalid-app-options';
  static const String INVALID_CREDENTIAL = 'invalid-credential';
  static const String NETWORK_ERROR = 'network-error';
  static const String NETWORK_TIMEOUT = 'network-timeout';
  static const String NO_APP = 'no-app';
  static const String UNABLE_TO_PARSE_RESPONSE = 'unable-to-parse-response';
}

/// Auth client error codes and their default messages.
class AuthClientErrorCode {
  static const ErrorInfo BILLING_NOT_ENABLED = ErrorInfo(
    code: 'billing-not-enabled',
    message: 'Feature requires billing to be enabled.',
  );
  static const ErrorInfo CLAIMS_TOO_LARGE = ErrorInfo(
    code: 'claims-too-large',
    message: 'Developer claims maximum payload size exceeded.',
  );
  static const ErrorInfo CONFIGURATION_EXISTS = ErrorInfo(
    code: 'configuration-exists',
    message: 'A configuration already exists with the provided identifier.',
  );
  static const ErrorInfo CONFIGURATION_NOT_FOUND = ErrorInfo(
    code: 'configuration-not-found',
    message: 'There is no configuration corresponding to the provided identifier.',
  );
  static const ErrorInfo ID_TOKEN_EXPIRED = ErrorInfo(
    code: 'id-token-expired',
    message: 'The provided Firebase ID token is expired.',
  );
  static const ErrorInfo INVALID_ARGUMENT = ErrorInfo(
    code: 'argument-error',
    message: 'Invalid argument provided.',
  );
  static const ErrorInfo INVALID_CONFIG = ErrorInfo(
    code: 'invalid-config',
    message: 'The provided configuration is invalid.',
  );
  static const ErrorInfo EMAIL_ALREADY_EXISTS = ErrorInfo(
    code: 'email-already-exists',
    message: 'The email address is already in use by another account.',
  );
  static const ErrorInfo FORBIDDEN_CLAIM = ErrorInfo(
    code: 'reserved-claim',
    message: 'The specified developer claim is reserved and cannot be specified.',
  );
  static const ErrorInfo INVALID_ID_TOKEN = ErrorInfo(
    code: 'invalid-id-token',
    message: 'The provided ID token is not a valid Firebase ID token.',
  );
  static const ErrorInfo ID_TOKEN_REVOKED = ErrorInfo(
    code: 'id-token-revoked',
    message: 'The Firebase ID token has been revoked.',
  );
  static const ErrorInfo INTERNAL_ERROR = ErrorInfo(
    code: 'internal-error',
    message: 'An internal error has occurred.',
  );
  static const ErrorInfo INVALID_CLAIMS = ErrorInfo(
    code: 'invalid-claims',
    message: 'The provided custom claim attributes are invalid.',
  );
  static const ErrorInfo INVALID_CONTINUE_URI = ErrorInfo(
    code: 'invalid-continue-uri',
    message: 'The continue URL must be a valid URL string.',
  );
  static const ErrorInfo INVALID_CREATION_TIME = ErrorInfo(
    code: 'invalid-creation-time',
    message: 'The creation time must be a valid UTC date string.',
  );
  static const ErrorInfo INVALID_CREDENTIAL = ErrorInfo(
    code: 'invalid-credential',
    message: 'Invalid credential object provided.',
  );
  static const ErrorInfo INVALID_DISABLED_FIELD = ErrorInfo(
    code: 'invalid-disabled-field',
    message: 'The disabled field must be a boolean.',
  );
  static const ErrorInfo INVALID_DISPLAY_NAME = ErrorInfo(
    code: 'invalid-display-name',
    message: 'The displayName field must be a valid string.',
  );
  static const ErrorInfo INVALID_DYNAMIC_LINK_DOMAIN = ErrorInfo(
    code: 'invalid-dynamic-link-domain',
    message: 'The provided dynamic link domain is not configured or authorized for the current project.',
  );
  static const ErrorInfo INVALID_EMAIL_VERIFIED = ErrorInfo(
    code: 'invalid-email-verified',
    message: 'The emailVerified field must be a boolean.',
  );
  static const ErrorInfo INVALID_EMAIL = ErrorInfo(
    code: 'invalid-email',
    message: 'The email address is improperly formatted.',
  );
  static const ErrorInfo INVALID_ENROLLED_FACTORS = ErrorInfo(
    code: 'invalid-enrolled-factors',
    message: 'The enrolled factors must be a valid array of MultiFactorInfo objects.',
  );
  static const ErrorInfo INVALID_ENROLLMENT_TIME = ErrorInfo(
    code: 'invalid-enrollment-time',
    message: 'The second factor enrollment time must be a valid UTC date string.',
  );
  static const ErrorInfo INVALID_HASH_ALGORITHM = ErrorInfo(
    code: 'invalid-hash-algorithm',
    message: 'The hash algorithm must match one of the strings in the list of supported algorithms.',
  );
  static const ErrorInfo INVALID_HASH_BLOCK_SIZE = ErrorInfo(
    code: 'invalid-hash-block-size',
    message: 'The hash block size must be a valid number.',
  );
  static const ErrorInfo INVALID_HASH_DERIVED_KEY_LENGTH = ErrorInfo(
    code: 'invalid-hash-derived-key-length',
    message: 'The hash derived key length must be a valid number.',
  );
  static const ErrorInfo INVALID_HASH_KEY = ErrorInfo(
    code: 'invalid-hash-key',
    message: 'The hash key must a valid byte buffer.',
  );
  static const ErrorInfo INVALID_HASH_MEMORY_COST = ErrorInfo(
    code: 'invalid-hash-memory-cost',
    message: 'The hash memory cost must be a valid number.',
  );
  static const ErrorInfo INVALID_HASH_PARALLELIZATION = ErrorInfo(
    code: 'invalid-hash-parallelization',
    message: 'The hash parallelization must be a valid number.',
  );
  static const ErrorInfo INVALID_HASH_ROUNDS = ErrorInfo(
    code: 'invalid-hash-rounds',
    message: 'The hash rounds must be a valid number.',
  );
  static const ErrorInfo INVALID_HASH_SALT_SEPARATOR = ErrorInfo(
    code: 'invalid-hash-salt-separator',
    message: 'The hashing algorithm salt separator field must be a valid byte buffer.',
  );
  static const ErrorInfo INVALID_LAST_SIGN_IN_TIME = ErrorInfo(
    code: 'invalid-last-sign-in-time',
    message: 'The last sign-in time must be a valid UTC date string.',
  );
  static const ErrorInfo INVALID_NAME = ErrorInfo(
    code: 'invalid-name',
    message: 'The resource name provided is invalid.',
  );
  static const ErrorInfo INVALID_OAUTH_CLIENT_ID = ErrorInfo(
    code: 'invalid-oauth-client-id',
    message: 'The provided OAuth client ID is invalid.',
  );
  static const ErrorInfo INVALID_PAGE_TOKEN = ErrorInfo(
    code: 'invalid-page-token',
    message: 'The page token must be a valid non-empty string.',
  );
  static const ErrorInfo INVALID_PASSWORD = ErrorInfo(
    code: 'invalid-password',
    message: 'The password must be a string with at least 6 characters.',
  );
  static const ErrorInfo INVALID_PASSWORD_HASH = ErrorInfo(
    code: 'invalid-password-hash',
    message: 'The password hash must be a valid byte buffer.',
  );
  static const ErrorInfo INVALID_PASSWORD_SALT = ErrorInfo(
    code: 'invalid-password-salt',
    message: 'The password salt must be a valid byte buffer.',
  );
  static const ErrorInfo INVALID_PHONE_NUMBER = ErrorInfo(
    code: 'invalid-phone-number',
    message: 'The phone number must be a non-empty E.164 standard compliant identifier string.',
  );
  static const ErrorInfo INVALID_PHOTO_URL = ErrorInfo(
    code: 'invalid-photo-url',
    message: 'The photoURL field must be a valid URL.',
  );
  static const ErrorInfo INVALID_PROJECT_ID = ErrorInfo(
    code: 'invalid-project-id',
    message: 'Invalid parent project. Either parent project doesn\'t exist or didn\'t enable multi-tenancy.',
  );
  static const ErrorInfo INVALID_PROVIDER_DATA = ErrorInfo(
    code: 'invalid-provider-data',
    message: 'The providerData must be a valid array of UserInfo objects.',
  );
  static const ErrorInfo INVALID_PROVIDER_ID = ErrorInfo(
    code: 'invalid-provider-id',
    message: 'The providerId must be a valid supported provider identifier string.',
  );
  static const ErrorInfo INVALID_PROVIDER_UID = ErrorInfo(
    code: 'invalid-provider-uid',
    message: 'The providerUid must be a valid provider uid string.',
  );
  static const ErrorInfo INVALID_SESSION_COOKIE_DURATION = ErrorInfo(
    code: 'invalid-session-cookie-duration',
    message: 'The session cookie duration must be a valid number in milliseconds between 5 minutes and 2 weeks.',
  );
  static const ErrorInfo INVALID_TENANT_ID = ErrorInfo(
    code: 'invalid-tenant-id',
    message: 'The tenant ID must be a valid non-empty string.',
  );
  static const ErrorInfo INVALID_TENANT_TYPE = ErrorInfo(
    code: 'invalid-tenant-type',
    message: 'Tenant type must be either "full_service" or "lightweight".',
  );
  static const ErrorInfo INVALID_UID = ErrorInfo(
    code: 'invalid-uid',
    message: 'The uid must be a non-empty string with at most 128 characters.',
  );
  static const ErrorInfo INVALID_USER_IMPORT = ErrorInfo(
    code: 'invalid-user-import',
    message: 'The user record to import is invalid.',
  );
  static const ErrorInfo INVALID_TOKENS_VALID_AFTER_TIME = ErrorInfo(
    code: 'invalid-tokens-valid-after-time',
    message: 'The tokensValidAfterTime must be a valid UTC number in seconds.',
  );
  static const ErrorInfo MISMATCHING_TENANT_ID = ErrorInfo(
    code: 'mismatching-tenant-id',
    message: 'User tenant ID does not match with the current TenantAwareAuth tenant ID.',
  );
  static const ErrorInfo MISSING_ANDROID_PACKAGE_NAME = ErrorInfo(
    code: 'missing-android-pkg-name',
    message: 'An Android Package Name must be provided if the Android App is required to be installed.',
  );
  static const ErrorInfo MISSING_CONFIG = ErrorInfo(
    code: 'missing-config',
    message: 'The provided configuration is missing required attributes.',
  );
  static const ErrorInfo MISSING_CONTINUE_URI = ErrorInfo(
    code: 'missing-continue-uri',
    message: 'A valid continue URL must be provided in the request.',
  );
  static const ErrorInfo MISSING_DISPLAY_NAME = ErrorInfo(
    code: 'missing-display-name',
    message: 'The resource being created or edited is missing a valid display name.',
  );
  static const ErrorInfo MISSING_EMAIL = ErrorInfo(
    code: 'missing-email',
    message:
    'The email is required for the specified action. For example, a multi-factor user requires a verified email.',
  );
  static const ErrorInfo MISSING_IOS_BUNDLE_ID = ErrorInfo(
    code: 'missing-ios-bundle-id',
    message: 'The request is missing an iOS Bundle ID.',
  );
  static const ErrorInfo MISSING_ISSUER = ErrorInfo(
    code: 'missing-issuer',
    message: 'The OAuth/OIDC configuration issuer must not be empty.',
  );
  static const ErrorInfo MISSING_HASH_ALGORITHM = ErrorInfo(
    code: 'missing-hash-algorithm',
    message: 'Importing users with password hashes requires that the hashing algorithm and its parameters be provided.',
  );
  static const ErrorInfo MISSING_OAUTH_CLIENT_ID = ErrorInfo(
    code: 'missing-oauth-client-id',
    message: 'The OAuth/OIDC configuration client ID must not be empty.',
  );
  static const ErrorInfo MISSING_PROVIDER_ID = ErrorInfo(
    code: 'missing-provider-id',
    message: 'A valid provider ID must be provided in the request.',
  );
  static const ErrorInfo MISSING_SAML_RELYING_PARTY_CONFIG = ErrorInfo(
    code: 'missing-saml-relying-party-config',
    message: 'The SAML configuration provided is missing a relying party configuration.',
  );
  static const ErrorInfo MAXIMUM_USER_COUNT_EXCEEDED = ErrorInfo(
    code: 'maximum-user-count-exceeded',
    message: 'The maximum allowed number of users to import has been exceeded.',
  );
  static const ErrorInfo MISSING_UID = ErrorInfo(
    code: 'missing-uid',
    message: 'A uid identifier is required for the current operation.',
  );
  static const ErrorInfo OPERATION_NOT_ALLOWED = ErrorInfo(
    code: 'operation-not-allowed',
    message:
    'The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.',
  );
  static const ErrorInfo PHONE_NUMBER_ALREADY_EXISTS = ErrorInfo(
    code: 'phone-number-already-exists',
    message: 'The user with the provided phone number already exists.',
  );
  static const ErrorInfo PROJECT_NOT_FOUND = ErrorInfo(
    code: 'project-not-found',
    message: 'No Firebase project was found for the provided credential.',
  );
  static const ErrorInfo INSUFFICIENT_PERMISSION = ErrorInfo(
    code: 'insufficient-permission',
    message:
    'Credential implementation provided to initializeApp() via the "credential" property has insufficient permission to access the requested resource. See https://firebase.google.com/docs/admin/setup for details on how to authenticate this SDK with appropriate permissions.',
  );
  static const ErrorInfo QUOTA_EXCEEDED = ErrorInfo(
    code: 'quota-exceeded',
    message: 'The project quota for the specified operation has been exceeded.',
  );
  static const ErrorInfo SECOND_FACTOR_LIMIT_EXCEEDED = ErrorInfo(
    code: 'second-factor-limit-exceeded',
    message: 'The maximum number of allowed second factors on a user has been exceeded.',
  );
  static const ErrorInfo SECOND_FACTOR_UID_ALREADY_EXISTS = ErrorInfo(
    code: 'second-factor-uid-already-exists',
    message: 'The specified second factor "uid" already exists.',
  );
  static const ErrorInfo SESSION_COOKIE_EXPIRED = ErrorInfo(
    code: 'session-cookie-expired',
    message: 'The Firebase session cookie is expired.',
  );
  static const ErrorInfo SESSION_COOKIE_REVOKED = ErrorInfo(
    code: 'session-cookie-revoked',
    message: 'The Firebase session cookie has been revoked.',
  );
  static const ErrorInfo TENANT_NOT_FOUND = ErrorInfo(
    code: 'tenant-not-found',
    message: 'There is no tenant corresponding to the provided identifier.',
  );
  static const ErrorInfo UID_ALREADY_EXISTS = ErrorInfo(
    code: 'uid-already-exists',
    message: 'The user with the provided uid already exists.',
  );
  static const ErrorInfo UNAUTHORIZED_DOMAIN = ErrorInfo(
    code: 'unauthorized-continue-uri',
    message: 'The domain of the continue URL is not whitelisted. Whitelist the domain in the Firebase console.',
  );
  static const ErrorInfo UNSUPPORTED_FIRST_FACTOR = ErrorInfo(
    code: 'unsupported-first-factor',
    message: 'A multi-factor user requires a supported first factor.',
  );
  static const ErrorInfo UNSUPPORTED_SECOND_FACTOR = ErrorInfo(
    code: 'unsupported-second-factor',
    message: 'The request specified an unsupported type of second factor.',
  );
  static const ErrorInfo UNSUPPORTED_TENANT_OPERATION = ErrorInfo(
    code: 'unsupported-tenant-operation',
    message: 'This operation is not supported in a multi-tenant context.',
  );
  static const ErrorInfo UNVERIFIED_EMAIL = ErrorInfo(
    code: 'unverified-email',
    message:
    'A verified email is required for the specified action. For example, a multi-factor user requires a verified email.',
  );
  static const ErrorInfo USER_NOT_FOUND = ErrorInfo(
    code: 'user-not-found',
    message: 'There is no user record corresponding to the provided identifier.',
  );
  static const ErrorInfo NOT_FOUND = ErrorInfo(
    code: 'not-found',
    message: 'The requested resource was not found.',
  );
  static const ErrorInfo USER_NOT_DISABLED = ErrorInfo(
    code: 'user-not-disabled',
    message: 'The user must be disabled in order to bulk delete it (or you must pass force=true).',
  );

  static const Map<String, ErrorInfo> values = <String, ErrorInfo>{
    'billing-not-enabled': BILLING_NOT_ENABLED,
    'claims-too-large': CLAIMS_TOO_LARGE,
    'configuration-exists': CONFIGURATION_EXISTS,
    'configuration-not-found': CONFIGURATION_NOT_FOUND,
    'id-token-expired': ID_TOKEN_EXPIRED,
    'argument-error': INVALID_ARGUMENT,
    'invalid-config': INVALID_CONFIG,
    'email-already-exists': EMAIL_ALREADY_EXISTS,
    'reserved-claim': FORBIDDEN_CLAIM,
    'invalid-id-token': INVALID_ID_TOKEN,
    'id-token-revoked': ID_TOKEN_REVOKED,
    'internal-error': INTERNAL_ERROR,
    'invalid-claims': INVALID_CLAIMS,
    'invalid-continue-uri': INVALID_CONTINUE_URI,
    'invalid-creation-time': INVALID_CREATION_TIME,
    'invalid-credential': INVALID_CREDENTIAL,
    'invalid-disabled-field': INVALID_DISABLED_FIELD,
    'invalid-display-name': INVALID_DISPLAY_NAME,
    'invalid-dynamic-link-domain': INVALID_DYNAMIC_LINK_DOMAIN,
    'invalid-email-verified': INVALID_EMAIL_VERIFIED,
    'invalid-email': INVALID_EMAIL,
    'invalid-enrolled-factors': INVALID_ENROLLED_FACTORS,
    'invalid-enrollment-time': INVALID_ENROLLMENT_TIME,
    'invalid-hash-algorithm': INVALID_HASH_ALGORITHM,
    'invalid-hash-block-size': INVALID_HASH_BLOCK_SIZE,
    'invalid-hash-derived-key-length': INVALID_HASH_DERIVED_KEY_LENGTH,
    'invalid-hash-key': INVALID_HASH_KEY,
    'invalid-hash-memory-cost': INVALID_HASH_MEMORY_COST,
    'invalid-hash-parallelization': INVALID_HASH_PARALLELIZATION,
    'invalid-hash-rounds': INVALID_HASH_ROUNDS,
    'invalid-hash-salt-separator': INVALID_HASH_SALT_SEPARATOR,
    'invalid-last-sign-in-time': INVALID_LAST_SIGN_IN_TIME,
    'invalid-name': INVALID_NAME,
    'invalid-oauth-client-id': INVALID_OAUTH_CLIENT_ID,
    'invalid-page-token': INVALID_PAGE_TOKEN,
    'invalid-password': INVALID_PASSWORD,
    'invalid-password-hash': INVALID_PASSWORD_HASH,
    'invalid-password-salt': INVALID_PASSWORD_SALT,
    'invalid-phone-number': INVALID_PHONE_NUMBER,
    'invalid-photo-url': INVALID_PHOTO_URL,
    'invalid-project-id': INVALID_PROJECT_ID,
    'invalid-provider-data': INVALID_PROVIDER_DATA,
    'invalid-provider-id': INVALID_PROVIDER_ID,
    'invalid-provider-uid': INVALID_PROVIDER_UID,
    'invalid-session-cookie-duration': INVALID_SESSION_COOKIE_DURATION,
    'invalid-tenant-id': INVALID_TENANT_ID,
    'invalid-tenant-type': INVALID_TENANT_TYPE,
    'invalid-uid': INVALID_UID,
    'invalid-user-import': INVALID_USER_IMPORT,
    'invalid-tokens-valid-after-time': INVALID_TOKENS_VALID_AFTER_TIME,
    'mismatching-tenant-id': MISMATCHING_TENANT_ID,
    'missing-android-pkg-name': MISSING_ANDROID_PACKAGE_NAME,
    'missing-config': MISSING_CONFIG,
    'missing-continue-uri': MISSING_CONTINUE_URI,
    'missing-display-name': MISSING_DISPLAY_NAME,
    'missing-email': MISSING_EMAIL,
    'missing-ios-bundle-id': MISSING_IOS_BUNDLE_ID,
    'missing-issuer': MISSING_ISSUER,
    'missing-hash-algorithm': MISSING_HASH_ALGORITHM,
    'missing-oauth-client-id': MISSING_OAUTH_CLIENT_ID,
    'missing-provider-id': MISSING_PROVIDER_ID,
    'missing-saml-relying-party-config': MISSING_SAML_RELYING_PARTY_CONFIG,
    'maximum-user-count-exceeded': MAXIMUM_USER_COUNT_EXCEEDED,
    'missing-uid': MISSING_UID,
    'operation-not-allowed': OPERATION_NOT_ALLOWED,
    'phone-number-already-exists': PHONE_NUMBER_ALREADY_EXISTS,
    'project-not-found': PROJECT_NOT_FOUND,
    'insufficient-permission': INSUFFICIENT_PERMISSION,
    'quota-exceeded': QUOTA_EXCEEDED,
    'second-factor-limit-exceeded': SECOND_FACTOR_LIMIT_EXCEEDED,
    'second-factor-uid-already-exists': SECOND_FACTOR_UID_ALREADY_EXISTS,
    'session-cookie-expired': SESSION_COOKIE_EXPIRED,
    'session-cookie-revoked': SESSION_COOKIE_REVOKED,
    'tenant-not-found': TENANT_NOT_FOUND,
    'uid-already-exists': UID_ALREADY_EXISTS,
    'unauthorized-continue-uri': UNAUTHORIZED_DOMAIN,
    'unsupported-first-factor': UNSUPPORTED_FIRST_FACTOR,
    'unsupported-second-factor': UNSUPPORTED_SECOND_FACTOR,
    'unsupported-tenant-operation': UNSUPPORTED_TENANT_OPERATION,
    'unverified-email': UNVERIFIED_EMAIL,
    'user-not-found': USER_NOT_FOUND,
    'not-found': NOT_FOUND,
    'user-not-disabled': USER_NOT_DISABLED,
  };
}

/// Messaging client error codes and their default messages.
class MessagingClientErrorCode {
  static const ErrorInfo INVALID_ARGUMENT = ErrorInfo(code: 'invalid-argument', message: 'Invalid argument provided.');
  static const ErrorInfo INVALID_RECIPIENT =
  ErrorInfo(code: 'invalid-recipient', message: 'Invalid message recipient provided.');
  static const ErrorInfo INVALID_PAYLOAD =
  ErrorInfo(code: 'invalid-payload', message: 'Invalid message payload provided.');
  static const ErrorInfo INVALID_DATA_PAYLOAD_KEY = ErrorInfo(
      code: 'invalid-data-payload-key',
      message:
      'The data message payload contains an invalid key. See the reference documentation for the DataMessagePayload type for restricted keys.');
  static const ErrorInfo PAYLOAD_SIZE_LIMIT_EXCEEDED = ErrorInfo(
      code: 'payload-size-limit-exceeded',
      message:
      'The provided message payload exceeds the FCM size limits. See the error documentation for more details.');
  static const ErrorInfo INVALID_OPTIONS =
  ErrorInfo(code: 'invalid-options', message: 'Invalid message options provided.');
  static const ErrorInfo INVALID_REGISTRATION_TOKEN = ErrorInfo(
      code: 'invalid-registration-token',
      message:
      'Invalid registration token provided. Make sure it matches the registration token the client app receives from registering with FCM.');
  static const ErrorInfo REGISTRATION_TOKEN_NOT_REGISTERED = ErrorInfo(
      code: 'registration-token-not-registered',
      message:
      'The provided registration token is not registered. A previously valid registration token can be unregistered for a variety of reasons. See the error documentation for more details. Remove this registration token and stop using it to send messages.');
  static const ErrorInfo MISMATCHED_CREDENTIAL = ErrorInfo(
      code: 'mismatched-credential',
      message:
      'The credential used to authenticate this SDK does not have permission to send messages to the device corresponding to the provided registration token. Make sure the credential and registration token both belong to the same Firebase project.');
  static const ErrorInfo INVALID_PACKAGE_NAME = ErrorInfo(
      code: 'invalid-package-name',
      message:
      'The message was addressed to a registration token whose package name does not match the provided "restrictedPackageName" option.');
  static const ErrorInfo DEVICE_MESSAGE_RATE_EXCEEDED = ErrorInfo(
      code: 'device-message-rate-exceeded',
      message:
      'The rate of messages to a particular device is too high. Reduce the number of messages sent to this device and do not immediately retry sending to this device.');
  static const ErrorInfo TOPICS_MESSAGE_RATE_EXCEEDED = ErrorInfo(
      code: 'topics-message-rate-exceeded',
      message:
      'The rate of messages to subscribers to a particular topic is too high. Reduce the number of messages sent for this topic, and do not immediately retry sending to this topic.');
  static const ErrorInfo MESSAGE_RATE_EXCEEDED =
  ErrorInfo(code: 'message-rate-exceeded', message: 'Sending limit exceeded for the message target.');
  static const ErrorInfo THIRD_PARTY_AUTH_ERROR = ErrorInfo(
      code: 'third-party-auth-error',
      message:
      'A message targeted to an iOS device could not be sent because the required APNs SSL certificate was not uploaded or has expired. Check the validity of your development and production certificates.');
  static const ErrorInfo TOO_MANY_TOPICS = ErrorInfo(
      code: 'too-many-topics',
      message: 'The maximum number of topics the provided registration token can be subscribed to has been exceeded.');
  static const ErrorInfo AUTHENTICATION_ERROR = ErrorInfo(
      code: 'authentication-error',
      message:
      'An error occurred when trying to authenticate to the FCM servers. Make sure the credential used to authenticate this SDK has the proper permissions. See https://firebase.google.com/docs/admin/setup for setup instructions.');
  static const ErrorInfo SERVER_UNAVAILABLE = ErrorInfo(
      code: 'server-unavailable',
      message: 'The FCM server could not process the request in time. See the error documentation for more details.');
  static const ErrorInfo INTERNAL_ERROR =
  ErrorInfo(code: 'internal-error', message: 'An internal error has occurred. Please retry the request.');
  static const ErrorInfo UNKNOWN_ERROR =
  ErrorInfo(code: 'unknown-error', message: 'An unknown server error was returned.');

  static const Map<String, ErrorInfo> values = <String, ErrorInfo>{
    'invalid-argument': INVALID_ARGUMENT,
    'invalid-recipient': INVALID_RECIPIENT,
    'invalid-payload': INVALID_PAYLOAD,
    'invalid-data-payload-key': INVALID_DATA_PAYLOAD_KEY,
    'payload-size-limit-exceeded': PAYLOAD_SIZE_LIMIT_EXCEEDED,
    'invalid-options': INVALID_OPTIONS,
    'invalid-registration-token': INVALID_REGISTRATION_TOKEN,
    'registration-token-not-registered': REGISTRATION_TOKEN_NOT_REGISTERED,
    'mismatched-credential': MISMATCHED_CREDENTIAL,
    'invalid-package-name': INVALID_PACKAGE_NAME,
    'device-message-rate-exceeded': DEVICE_MESSAGE_RATE_EXCEEDED,
    'topics-message-rate-exceeded': TOPICS_MESSAGE_RATE_EXCEEDED,
    'message-rate-exceeded': MESSAGE_RATE_EXCEEDED,
    'third-party-auth-error': THIRD_PARTY_AUTH_ERROR,
    'too-many-topics': TOO_MANY_TOPICS,
    'authentication-error': AUTHENTICATION_ERROR,
    'server-unavailable': SERVER_UNAVAILABLE,
    'internal-error': INTERNAL_ERROR,
    'unknown-error': UNKNOWN_ERROR,
  };
}

class InstanceIdClientErrorCode {
  static const ErrorInfo INVALID_ARGUMENT = ErrorInfo(code: 'invalid-argument', message: 'Invalid argument provided.');
  static const ErrorInfo INVALID_PROJECT_ID =
  ErrorInfo(code: 'invalid-project-id', message: 'Invalid project ID provided.');
  static const ErrorInfo INVALID_INSTANCE_ID =
  ErrorInfo(code: 'invalid-instance-id', message: 'Invalid instance ID provided.');
  static const ErrorInfo API_ERROR = ErrorInfo(code: 'api-error', message: 'Instance ID API call failed.');
}

class ProjectManagementErrorCode {
  const ProjectManagementErrorCode._(this._value);

  final String _value;

  static const ProjectManagementErrorCode alreadyExists = ProjectManagementErrorCode._('already-exists');
  static const ProjectManagementErrorCode authenticationError = ProjectManagementErrorCode._('authentication-error');
  static const ProjectManagementErrorCode internalError = ProjectManagementErrorCode._('internal-error');
  static const ProjectManagementErrorCode invalidArgument = ProjectManagementErrorCode._('invalid-argument');
  static const ProjectManagementErrorCode invalidProjectId = ProjectManagementErrorCode._('invalid-project-id');
  static const ProjectManagementErrorCode invalidServerResponse =
  ProjectManagementErrorCode._('invalid-server-response');
  static const ProjectManagementErrorCode notFound = ProjectManagementErrorCode._('not-found');
  static const ProjectManagementErrorCode serviceUnavailable = ProjectManagementErrorCode._('service-unavailable');
  static const ProjectManagementErrorCode unknownError = ProjectManagementErrorCode._('unknown-error');

  static ProjectManagementErrorCode valueOf(String name) {
    final int index = _names.indexOf(name);
    if (index == -1) {
      throw ArgumentError('Unknown value. $name');
    }

    return values[index];
  }

  static const List<ProjectManagementErrorCode> values = <ProjectManagementErrorCode>[
    alreadyExists,
    authenticationError,
    internalError,
    invalidArgument,
    invalidProjectId,
    invalidServerResponse,
    notFound,
    serviceUnavailable,
    unknownError,
  ];

  static const List<String> _names = <String>[
    'already-exists',
    'authentication-error',
    'internal-error',
    'invalid-argument',
    'invalid-project-id',
    'invalid-server-response',
    'not-found',
    'service-unavailable',
    'unknown-error',
  ];

  @override
  String toString() => _value;
}

/// Auth server to client enum error codes.
const Map<String, String> AUTH_SERVER_TO_CLIENT_CODE = <String, String>{
  // Feature being configured or used requires a billing account.
  'BILLING_NOT_ENABLED': 'BILLING_NOT_ENABLED',
  // Claims payload is too large.
  'CLAIMS_TOO_LARGE': 'CLAIMS_TOO_LARGE',
  // Configuration being added already exists.
  'CONFIGURATION_EXISTS': 'CONFIGURATION_EXISTS',
  // Configuration not found.
  'CONFIGURATION_NOT_FOUND': 'CONFIGURATION_NOT_FOUND',
  // Provided credential has insufficient permissions.
  'INSUFFICIENT_PERMISSION': 'INSUFFICIENT_PERMISSION',
  // Provided configuration has invalid fields.
  'INVALID_CONFIG': 'INVALID_CONFIG',
  // Provided configuration identifier is invalid.
  'INVALID_CONFIG_ID': 'INVALID_PROVIDER_ID',
  // ActionCodeSettings missing continue URL.
  'INVALID_CONTINUE_URI': 'INVALID_CONTINUE_URI',
  // Dynamic link domain in provided ActionCodeSettings is not authorized.
  'INVALID_DYNAMIC_LINK_DOMAIN': 'INVALID_DYNAMIC_LINK_DOMAIN',
  // uploadAccount provides an email that already exists.
  'DUPLICATE_EMAIL': 'EMAIL_ALREADY_EXISTS',
  // uploadAccount provides a localId that already exists.
  'DUPLICATE_LOCAL_ID': 'UID_ALREADY_EXISTS',
  // Request specified a multi-factor enrollment ID that already exists.
  'DUPLICATE_MFA_ENROLLMENT_ID': 'SECOND_FACTOR_UID_ALREADY_EXISTS',
  // setAccountInfo email already exists.
  'EMAIL_EXISTS': 'EMAIL_ALREADY_EXISTS',
  // Reserved claim name.
  'FORBIDDEN_CLAIM': 'FORBIDDEN_CLAIM',
  // Invalid claims provided.
  'INVALID_CLAIMS': 'INVALID_CLAIMS',
  // Invalid session cookie duration.
  'INVALID_DURATION': 'INVALID_SESSION_COOKIE_DURATION',
  // Invalid email provided.
  'INVALID_EMAIL': 'INVALID_EMAIL',
  // Invalid tenant display name. This can be thrown on CreateTenant and UpdateTenant.
  'INVALID_DISPLAY_NAME': 'INVALID_DISPLAY_NAME',
  // Invalid ID token provided.
  'INVALID_ID_TOKEN': 'INVALID_ID_TOKEN',
  // Invalid tenant/parent resource name.
  'INVALID_NAME': 'INVALID_NAME',
  // OIDC configuration has an invalid OAuth client ID.
  'INVALID_OAUTH_CLIENT_ID': 'INVALID_OAUTH_CLIENT_ID',
  // Invalid page token.
  'INVALID_PAGE_SELECTION': 'INVALID_PAGE_TOKEN',
  // Invalid phone number.
  'INVALID_PHONE_NUMBER': 'INVALID_PHONE_NUMBER',
  // Invalid agent project. Either agent project doesn't exist or didn't enable multi-tenancy.
  'INVALID_PROJECT_ID': 'INVALID_PROJECT_ID',
  // Invalid provider ID.
  'INVALID_PROVIDER_ID': 'INVALID_PROVIDER_ID',
  // Invalid service account.
  'INVALID_SERVICE_ACCOUNT': 'INVALID_SERVICE_ACCOUNT',
  // Invalid tenant type.
  'INVALID_TENANT_TYPE': 'INVALID_TENANT_TYPE',
  // Missing Android package name.
  'MISSING_ANDROID_PACKAGE_NAME': 'MISSING_ANDROID_PACKAGE_NAME',
  // Missing configuration.
  'MISSING_CONFIG': 'MISSING_CONFIG',
  // Missing configuration identifier.
  'MISSING_CONFIG_ID': 'MISSING_PROVIDER_ID',
  // Missing tenant display name: This can be thrown on CreateTenant and UpdateTenant.
  'MISSING_DISPLAY_NAME': 'MISSING_DISPLAY_NAME',
  // Email is required for the specified action. For example a multi-factor user requires
  // a verified email.
  'MISSING_EMAIL': 'MISSING_EMAIL',
  // Missing iOS bundle ID.
  'MISSING_IOS_BUNDLE_ID': 'MISSING_IOS_BUNDLE_ID',
  // Missing OIDC issuer.
  'MISSING_ISSUER': 'MISSING_ISSUER',
  // No localId provided (deleteAccount missing localId).
  'MISSING_LOCAL_ID': 'MISSING_UID',
  // OIDC configuration is missing an OAuth client ID.
  'MISSING_OAUTH_CLIENT_ID': 'MISSING_OAUTH_CLIENT_ID',
  // Missing provider ID.
  'MISSING_PROVIDER_ID': 'MISSING_PROVIDER_ID',
  // Missing SAML RP config.
  'MISSING_SAML_RELYING_PARTY_CONFIG': 'MISSING_SAML_RELYING_PARTY_CONFIG',
  // Empty user list in uploadAccount.
  'MISSING_USER_ACCOUNT': 'MISSING_UID',
  // Password auth disabled in console.
  'OPERATION_NOT_ALLOWED': 'OPERATION_NOT_ALLOWED',
  // Provided credential has insufficient permissions.
  'PERMISSION_DENIED': 'INSUFFICIENT_PERMISSION',
  // Phone number already exists.
  'PHONE_NUMBER_EXISTS': 'PHONE_NUMBER_ALREADY_EXISTS',
  // Project not found.
  'PROJECT_NOT_FOUND': 'PROJECT_NOT_FOUND',
  // In multi-tenancy context: project creation quota exceeded.
  'QUOTA_EXCEEDED': 'QUOTA_EXCEEDED',
  // Currently only 5 second factors can be set on the same user.
  'SECOND_FACTOR_LIMIT_EXCEEDED': 'SECOND_FACTOR_LIMIT_EXCEEDED',
  // Tenant not found.
  'TENANT_NOT_FOUND': 'TENANT_NOT_FOUND',
  // Tenant ID mismatch.
  'TENANT_ID_MISMATCH': 'MISMATCHING_TENANT_ID',
  // Token expired error.
  'TOKEN_EXPIRED': 'ID_TOKEN_EXPIRED',
  // Continue URL provided in ActionCodeSettings has a domain that is not whitelisted.
  'UNAUTHORIZED_DOMAIN': 'UNAUTHORIZED_DOMAIN',
  // A multi-factor user requires a supported first factor.
  'UNSUPPORTED_FIRST_FACTOR': 'UNSUPPORTED_FIRST_FACTOR',
  // The request specified an unsupported type of second factor.
  'UNSUPPORTED_SECOND_FACTOR': 'UNSUPPORTED_SECOND_FACTOR',
  // Operation is not supported in a multi-tenant context.
  'UNSUPPORTED_TENANT_OPERATION': 'UNSUPPORTED_TENANT_OPERATION',
  // A verified email is required for the specified action. For example a multi-factor user
  // requires a verified email.
  'UNVERIFIED_EMAIL': 'UNVERIFIED_EMAIL',
  // User on which action is to be performed is not found.
  'USER_NOT_FOUND': 'USER_NOT_FOUND',
  // Password provided is too weak.
  'WEAK_PASSWORD': 'INVALID_PASSWORD',
};

/// Messaging server to client enum error codes.
const Map<String, String> MESSAGING_SERVER_TO_CLIENT_CODE = <String, String>{
  /* GENERIC ERRORS */
  // Generic invalid message parameter provided.
  'InvalidParameters': 'INVALID_ARGUMENT',
  // Mismatched sender ID.
  'MismatchSenderId': 'MISMATCHED_CREDENTIAL',
  // FCM server unavailable.
  'Unavailable': 'SERVER_UNAVAILABLE',
  // FCM server internal error.
  'InternalServerError': 'INTERNAL_ERROR',

  /* SEND ERRORS */
  // Invalid registration token format.
  'InvalidRegistration': 'INVALID_REGISTRATION_TOKEN',
  // Registration token is not registered.
  'NotRegistered': 'REGISTRATION_TOKEN_NOT_REGISTERED',
  // Registration token does not match restricted package name.
  'InvalidPackageName': 'INVALID_PACKAGE_NAME',
  // Message payload size limit exceeded.
  'MessageTooBig': 'PAYLOAD_SIZE_LIMIT_EXCEEDED',
  // Invalid key in the data message payload.
  'InvalidDataKey': 'INVALID_DATA_PAYLOAD_KEY',
  // Invalid time to live option.
  'InvalidTtl': 'INVALID_OPTIONS',
  // Device message rate exceeded.
  'DeviceMessageRateExceeded': 'DEVICE_MESSAGE_RATE_EXCEEDED',
  // Topics message rate exceeded.
  'TopicsMessageRateExceeded': 'TOPICS_MESSAGE_RATE_EXCEEDED',
  // Invalid APNs credentials.
  'InvalidApnsCredential': 'THIRD_PARTY_AUTH_ERROR',

  /* FCM v1 canonical error codes */
  'NOT_FOUND': 'REGISTRATION_TOKEN_NOT_REGISTERED',
  'PERMISSION_DENIED': 'MISMATCHED_CREDENTIAL',
  'RESOURCE_EXHAUSTED': 'MESSAGE_RATE_EXCEEDED',
  'UNAUTHENTICATED': 'THIRD_PARTY_AUTH_ERROR',

  /* FCM v1 new error codes */
  'APNS_AUTH_ERROR': 'THIRD_PARTY_AUTH_ERROR',
  'INTERNAL': 'INTERNAL_ERROR',
  'INVALID_ARGUMENT': 'INVALID_ARGUMENT',
  'QUOTA_EXCEEDED': 'MESSAGE_RATE_EXCEEDED',
  'SENDER_ID_MISMATCH': 'MISMATCHED_CREDENTIAL',
  'THIRD_PARTY_AUTH_ERROR': 'THIRD_PARTY_AUTH_ERROR',
  'UNAVAILABLE': 'SERVER_UNAVAILABLE',
  'UNREGISTERED': 'REGISTRATION_TOKEN_NOT_REGISTERED',
  'UNSPECIFIED_ERROR': 'UNKNOWN_ERROR',
};

/// Topic management (IID) server to client enum error codes.
const Map<String, String> TOPIC_MGT_SERVER_TO_CLIENT_CODE = <String, String>{
  /* TOPIC SUBSCRIPTION MANAGEMENT ERRORS */
  'NOT_FOUND': 'REGISTRATION_TOKEN_NOT_REGISTERED',
  'INVALID_ARGUMENT': 'INVALID_REGISTRATION_TOKEN',
  'TOO_MANY_TOPICS': 'TOO_MANY_TOPICS',
  'RESOURCE_EXHAUSTED': 'TOO_MANY_TOPICS',
  'PERMISSION_DENIED': 'AUTHENTICATION_ERROR',
  'DEADLINE_EXCEEDED': 'SERVER_UNAVAILABLE',
  'INTERNAL': 'INTERNAL_ERROR',
  'UNKNOWN': 'UNKNOWN_ERROR',
};
