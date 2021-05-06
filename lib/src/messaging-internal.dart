import 'package:messaging/src/utils/error.dart';
import 'package:string_validator/string_validator.dart';

import 'index.dart';

void validateMessage(Message message) {
  final String anyMessage = message.toString();
  if(anyMessage.contains('/topics/')) {
    anyMessage.replaceAll('/topics/', '');
  }
  //check topic
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
  // if(config == null){
  //   throw FirebaseMessagingError(MessagingClientErrorCode.INVALID_PAYLOAD, 'webpush must be a non-null object');
  // }
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