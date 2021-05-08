import 'package:messaging/src/utils/error.dart';
import 'package:string_validator/string_validator.dart';

import 'index.dart';


// Keys which are not allowed in the messaging data payload object.
const List<String> BLACKLISTED_DATA_PAYLOAD_KEYS = <String>['from'];

// Keys which are not allowed in the messaging options object.
const List<String> BLACKLISTED_OPTIONS_KEYS = [
  'condition', 'data', 'notification', 'registrationIds', 'registration_ids', 'to',
];

/// Checks if the given Message object is valid. Recursively validates all the child objects
/// included in the message (android, apns, data etc.). If successful, transforms the message
/// in place by renaming the keys to what's expected by the remote FCM service.
///
/// @param {Message message} Message An object to be validated.


void validateMessage(Message message) {
  final String anyMessage = message.toString();
  if(anyMessage.contains('/topics/')) {
    anyMessage.replaceAll('/topics/', '');
  }
  //TODO check topic

  const targets = [anyMessage.token, anyMessage.topic, anyMessage.coditions];
}

void validateStringMap(Map<String, dynamic> map, String label) {
    if(map.isNotEmpty) {
      throw FirebaseMessagingError(MessagingClientErrorCode.INVALID_PAYLOAD, '$label must be a non-null object');
    }
    for(int idx=0; idx<map.length; idx++){
      if(map[idx] != String){
        throw FirebaseMessagingError(MessagingClientErrorCode.INVALID_PAYLOAD, '$label must only contain string value');
      }
    }
}

void validateWebpushConfig(WebpushConfig config) {
  validateStringMap(config.headers, 'webpush.headers');
  validateStringMap(config.data, 'webpush.data');
}

void validateApnsConfig(ApnsConfig config) {
  validateStringMap(config.headers, 'apns.headers');
  validateApnsPayload(config.payload);
  validateApnsFcmOptions(config.fcmOptions);
}

void validateApnsFcmOptions(ApnsFcmOptions fcmOptions) {
  if(fcmOptions.imageUrl == null) {
    throw FirebaseMessagingError(MessagingClientErrorCode.INVALID_PAYLOAD, '$label must be a non-null object');
  }
  if(isURL(fcmOptions.imageUrl!) == false){
    throw FirebaseMessagingError(MessagingClientErrorCode.INVALID_PAYLOAD, 'imageUrl must be a valid URL string');
  }

  if((fcmOptions.analyticsLabel is String) == false && fcmOptions.analyticsLabel == null){
    throw FirebaseMessagingError(MessagingClientErrorCode.INVALID_PAYLOAD, 'analysticsLabel must be a string value');
  }

  const Map<String, String> propertyMappings = <String, String>{'imageUrl': 'image',};

  for(int idx = 0; idx < propertyMappings.length; idx++){

  }

}