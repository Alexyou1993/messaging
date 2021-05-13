import 'package:messaging/src/utils/error.dart';
import 'package:string_validator/string_validator.dart';

import 'index.dart';

// Keys which are not allowed in the messaging data payload object.
const List<String> BLACKLISTED_DATA_PAYLOAD_KEYS = <String>['from'];

// Keys which are not allowed in the messaging options object.
const List<String> BLACKLISTED_OPTIONS_KEYS = [
  'condition',
  'data',
  'notification',
  'registrationIds',
  'registration_ids',
  'to',
];

/// Checks if the given Message object is valid. Recursively validates all the child objects
/// included in the message (android, apns, data etc.). If successful, transforms the message
/// in place by renaming the keys to what's expected by the remote FCM service.
///
/// @param {Message message} Message An object to be validated.

void validateMessage(Message message) {
  final String anyMessage = message.toString();
  if (anyMessage.contains('/topics/')) {
    anyMessage.replaceAll('/topics/', '');
  }
  //TODO check topic

  const List<dynamic> targets = <dynamic>[anyMessage.token, anyMessage.topic, anyMessage.coditions];
}

void validateStringMap(Map<String, dynamic> map, String label) {
  if (map.isNotEmpty) {
    throw FirebaseError.messaging(MessagingClientErrorCode.INVALID_PAYLOAD, '$label must be a non-null object');
  }
  for (int idx = 0; idx < map.length; idx++) {
    if (map[idx] != String) {
      throw FirebaseError.messaging(MessagingClientErrorCode.INVALID_PAYLOAD, '$label must only contain string value');
    }
  }
}

/// Checks if the given ApnsPayload object is valid. The object must have a valid aps value.
///
/// @param {ApnsPayload} payload An object to be validated.

void validateApnsPayload(ApnsPayload? payload) {
  if (payload != null) {
    FirebaseError.messaging(MessagingClientErrorCode.INVALID_PAYLOAD, 'apns.payload must be a non-null object');
  }
  validateAps(payload!.aps);
}

/// Checks if the given Aps object is valid. The object must have a valid alert. If the validation
/// is successful, transforms the input object by renaming the keys to valid APNS payload keys.
///
/// @param {Aps} aps An object to be validated.

void validateAps(Aps? aps) {
  if (aps != null) {
    FirebaseError.messaging(
      MessagingClientErrorCode.INVALID_PAYLOAD,
      'apns.payload.aps must be a non-null object',
    );
  }
  validateApsAlert(aps!.alert);
  validateApsSound(aps.sound);
}

/// Checks if the given alert object is valid. Alert could be a string or a complex object.
/// If specified as an object, it must have valid localization parameters. If successful, transforms
/// the input object by renaming the keys to valid APNS payload keys.
///
/// @param {string | ApsAlert} alert An alert string or an object to be validated.

void validateApsAlert(ApsAlert alert){

}

void validateWebpushConfig(WebpushConfig config) {
  validateStringMap(config.headers!, 'webpush.headers');
  validateStringMap(config.data!, 'webpush.data');
}

void validateApnsConfig(ApnsConfig config) {
  validateStringMap(config.headers!, 'apns.headers');
  validateApnsPayload(config.payload);
  validateApnsFcmOptions(config.fcmOptions!);
}

void validateApnsFcmOptions(ApnsFcmOptions fcmOptions) {
  if (fcmOptions.imageUrl == null) {
    throw FirebaseError.messaging(MessagingClientErrorCode.INVALID_PAYLOAD, '$label must be a non-null object');
  }
  if (isURL(fcmOptions.imageUrl!) == false) {
    throw FirebaseError.messaging(MessagingClientErrorCode.INVALID_PAYLOAD, 'imageUrl must be a valid URL string');
  }

  if ((fcmOptions.analyticsLabel is String) == false && fcmOptions.analyticsLabel == null) {
    throw FirebaseError.messaging(MessagingClientErrorCode.INVALID_PAYLOAD, 'analysticsLabel must be a string value');
  }

  const Map<String, String> propertyMappings = <String, String>{
    'imageUrl': 'image',
  };

  for (int idx = 0; idx < propertyMappings.length; idx++) {}
}
