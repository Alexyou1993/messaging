import 'package:messaging/src/utils/api-request/index.dart';
import 'package:messaging/src/utils/error.dart';

FirebaseError createFirebaseError(HttpError err) {
  if (err.response.isJson) {
    final Map<String, dynamic> json = err.response.data!;
    final String errorCode = getErrorCode(json).toString();
    final String errorMessage = getErrorMessage(json).toString();
    return FirebaseError.messagingFromServerCode(errorCode, errorMessage, json);
  }

  ErrorInfo error;
  switch (err.response.status) {
    case 400:
      error = MessagingClientErrorCode.INVALID_ARGUMENT;
      break;
    case 401:
    case 403:
      error = MessagingClientErrorCode.AUTHENTICATION_ERROR;
      break;
    case 500:
      error = MessagingClientErrorCode.INTERNAL_ERROR;
      break;
    case 503:
      error = MessagingClientErrorCode.SERVER_UNAVAILABLE;
      break;
    default:
      // Treat non-JSON responses with unexpected status codes as unknown errors.
      error = MessagingClientErrorCode.UNKNOWN_ERROR;
  }

  return FirebaseError.messaging(ErrorInfo(
    code: error.code,
    message: '${error.message} Raw server response "${err.response.text}". Status code: ' '${err.response.status}.',
  ));
}

String? getErrorCode(Map<String, dynamic> response) {
  if (response.isNotEmpty && response.containsKey('error')) {
    final dynamic error = response['error'];
    if (error is String) {
      return error;
    }
    if (error.details is List) {
      const String fcmErrorType = 'type.googleapis.com/google.firebase.fcm.v1.FcmError';
      for (final dynamic element in error.details) {
        if (element['type'] == fcmErrorType) {
          return element.errorCode.toString();
        }
      }
    }
    if (error is Map && error.containsKey('status')) {
      return error['status'].toString();
    } else {
      return error['message'].toString();
    }
  }
  return null;
}

String? getErrorMessage(Map<String, dynamic> response) {
  if (response.isNotEmpty &&
      response.containsKey('error') &&
      response['error'].message is String &&
      response['error'].message != '') {
    return response['error'].message.toString();
  }
  return null;
}
