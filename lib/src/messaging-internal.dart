import 'dart:core';
import 'dart:html';

import 'package:messaging/src/utils/error.dart';
import 'package:messaging/src/utils/index.dart';
import 'package:messaging/src/utils/validator.dart';
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

void validateMessage(Message? message) {
  if (message == null) {
    throw FirebaseError.messaging(
      MessagingClientErrorCode.INVALID_PAYLOAD,
      'Message must be a non-null object',
    );
  } else {
    final Message anyMessage = message;

    if (anyMessage.topic!.startsWith('/topics/')) {
      anyMessage.topic!.replaceAll('/topics/', '');
    }

    final RegExp validCharacters = RegExp(r'^[a-zA-Z0-9-_.~%]');
    if (!anyMessage.topic!.contains(validCharacters) && anyMessage.topic!.isEmpty) {
      throw FirebaseError.messaging(
        MessagingClientErrorCode.INVALID_PAYLOAD,
        'Malformed topic name',
      );
    }
    final List<dynamic> targets = <dynamic>[anyMessage.token, anyMessage.topic, anyMessage.condition];
    if (targets.length != 1) {
      FirebaseError.messaging(
        MessagingClientErrorCode.INVALID_PAYLOAD,
        'Exactly one of topic, token or condition is required',
      );
    }

    validateStringMap(message.data!, 'data');
    validateAndroidConfig(message.android!);
    validateWebpushConfig(message.webpush!);
    validateApnsConfig(message.apns!);
    validateFcmOptions(message.fcmOptions);
    validateNotification(message.notification);
  }
}

/// Checks if the given object only contains strings as child values.
///
/// @param {Map<String, dynamic>} map An object to be validated.
/// @param {string} label A label to be included in the errors thrown.

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

/// Checks if the given WebpushConfig object is valid. The object must have valid headers and data.
///
/// @param {WebpushConfig} config An object to be validated.

void validateWebpushConfig(WebpushConfig? config) {
  if (config == null) {
    FirebaseError.messaging(
      MessagingClientErrorCode.INVALID_PAYLOAD,
      'webpush must be a non-null object',
    );
  } else {
    validateStringMap(config.headers!, 'webpush.headers');
    validateStringMap(config.data!, 'webpush.data');
  }
}

/// Checks if the given ApnsConfig object is valid. The object must have valid headers and a
/// payload.
///
/// @param {ApnsConfig} config An object to be validated.

void validateApnsConfig(ApnsConfig? config) {
  if (config == null) {
    throw FirebaseError.messaging(
      MessagingClientErrorCode.INVALID_PAYLOAD,
      'apns must be a non-null object',
    );
  } else {
    validateStringMap(config.headers!, 'apns.headers');
    validateApnsPayload(config.payload);
    validateApnsFcmOptions(config.fcmOptions!);
  }
}

/// Checks if the given ApnsFcmOptions object is valid.
///
/// @param {ApnsFcmOptions} fcmOptions An object to be validated.

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

  for (int idx = 0; idx < propertyMappings.length; idx++) {
    for (int idy = 0; idy < fcmOptions.imageUrl!.length; idy++) {
      if (propertyMappings[idx] == fcmOptions.imageUrl![idy]) {
        throw FirebaseError.messaging(
          MessagingClientErrorCode.INVALID_PAYLOAD,
          'Multiple specifications for ${propertyMappings[idx]} in ApnsFcmOptions',
        );
      }
    }
  }
  renameProperties(fcmOptions as Map<String, dynamic>, propertyMappings);
}

/// Checks if the given FcmOptions object is valid.
///
/// @param {FcmOptions} fcmOptions An object to be validated.

void validateFcmOptions(FcmOptions? fcmOptions) {
  if (fcmOptions == null) {
    throw FirebaseError.messaging(
      MessagingClientErrorCode.INVALID_PAYLOAD,
      'analyticsLabel must be a string value',
    );
  }

  if (fcmOptions.analyticsLabel == null && isString(fcmOptions.analyticsLabel) == false) {
    throw FirebaseError.messaging(
      MessagingClientErrorCode.INVALID_PAYLOAD,
      'analyticsLabel must be a string value',
    );
  }
}

/// Checks if the given Notification object is valid.
///
/// @param {Notification} notification An object to be validated.

void validateNotification(Notification? notification) {
  if (notification == null) {
    throw FirebaseError.messaging(
      MessagingClientErrorCode.INVALID_PAYLOAD,
      'notification must be a non-null object',
    );
  }

  if (notification.imageUrl == null && isUrl(notification.imageUrl) == false) {
    throw FirebaseError.messaging(
      MessagingClientErrorCode.INVALID_PAYLOAD,
      'notification.imageUrl must be a valid URL string',
    );
  }

  final Map<String, String> propertyMappings = {
    'imageUrl': 'image',
  };

  for (int idx = 0; idx < propertyMappings.length; idx++) {
    for (int idy = 0; idy < notification.imageUrl!.length; idy++) {
      if (propertyMappings[idx] == notification.imageUrl![idy]) {
        throw FirebaseError.messaging(
          MessagingClientErrorCode.INVALID_PAYLOAD,
          'Multiple specifications for ${propertyMappings[idx]} in Notification',
        );
      }
    }
  }
  renameProperties(notification as Map<String, dynamic>, propertyMappings);
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
  validateApsAlert(aps!.alert!);
  validateApsSound(aps.sound);

  final Map<String, String> propertyMappings = <String, String>{
    'contentAvailable': 'content-available',
    'mutableContent': 'mutable-content',
    'threadId': 'thread-id',
  };
  for (int idx = 0; idx < propertyMappings.length; idx++) {
    if (aps.toString().contains(propertyMappings[idx]!)) {
      throw FirebaseError.messaging(
          MessagingClientErrorCode.INVALID_PAYLOAD, 'Multiple specifications for ${propertyMappings[idx]} in Aps');
    }
  }
  renameProperties(aps as Map<String, dynamic>, propertyMappings);
}

void validateApsSound(CriticalSound? sound) {
  if (sound.toString().isEmpty && sound == null) {
    throw FirebaseError.messaging(
      MessagingClientErrorCode.INVALID_PAYLOAD,
      'apns.payload.aps.sound must be a non-empty string or a non-null object',
    );
  }
  //TODO isNumber

  final double? volume = sound!.volume;
  if (volume! < 0 || volume > 1) {
    throw FirebaseError.messaging(
      MessagingClientErrorCode.INVALID_PAYLOAD,
      'apns.payload.aps.sound.volume must be in the interval [0, 1]',
    );
  }
  final Map<String, dynamic> soundObject = sound as Map<String, dynamic>;
  const String key = 'critical';
  final dynamic critical = soundObject[key];
  if (critical != null && critical != 1) {
    if (critical == true) {
      soundObject[key] = 1;
    } else {
      soundObject.remove(key);
    }
  }
}

/// Checks if the given alert object is valid. Alert could be a string or a complex object.
/// If specified as an object, it must have valid localization parameters. If successful, transforms
/// the input object by renaming the keys to valid APNS payload keys.
///
/// @param {string | ApsAlert} alert An alert string or an object to be validated.

void validateApsAlert(ApsAlert? alert) {
  if (alert == null || isString(alert) == false) {
    throw FirebaseError.messaging(
      MessagingClientErrorCode.INVALID_PAYLOAD,
      'apns.payload.aps.alert must be a string or a non-null object',
    );
  }

  if (alert.locArgs!.isNotEmpty && alert.locKey!.isEmpty) {
    throw FirebaseError.messaging(
      MessagingClientErrorCode.INVALID_PAYLOAD,
      'apns.payload.aps.alert.locKey is required when specifying locArgs',
    );
  }

  if (alert.titleLocArgs!.isNotEmpty && alert.titleLocKey!.isEmpty) {
    throw FirebaseError.messaging(
      MessagingClientErrorCode.INVALID_PAYLOAD,
      'apns.payload.aps.alert.titleLocKey is required when specifying titleLocArgs',
    );
  }

  if (alert.subtitleLocArgs!.isNotEmpty && alert.subtitleLocKey!.isEmpty) {
    throw FirebaseError.messaging(
      MessagingClientErrorCode.INVALID_PAYLOAD,
      'apns.payload.aps.alert.subtitleLocKey is required when specifying subtitleLocArgs',
    );
  }

  final Map<String, String> propertyMappings = <String, String>{
    'locKey': 'loc-key',
    'locArgs': 'loc-args',
    'titleLocKey': 'title-loc-key',
    'titleLocArgs': 'title-loc-args',
    'subtitleLocKey': 'subtitle-loc-key',
    'subtitleLocArgs': 'subtitle-loc-args',
    'actionLocKey': 'action-loc-key',
    'launchImage': 'launch-image',
  };
  renameProperties(alert as Map<String, String>, propertyMappings);
}

/// Checks if the given AndroidConfig object is valid. The object must have valid ttl, data,
/// and notification fields. If successful, transforms the input object by renaming keys to valid
/// Android keys. Also transforms the ttl value to the format expected by FCM service.
///
/// @param {AndroidConfig} config An object to be validated.

void validateAndroidConfig(AndroidConfig? config) {
  if (config == null) {
    throw FirebaseError.messaging(
      MessagingClientErrorCode.INVALID_PAYLOAD,
      'android must be a non-null object',
    );
  }

  if (config.ttl != null) {
    if (config.ttl! < const Duration(milliseconds: 0)) {
      throw FirebaseError.messaging(
        MessagingClientErrorCode.INVALID_PAYLOAD,
        'TTL must be a non-negative duration in milliseconds',
      );
    }
    final String duration = transformMillisecondsToSecondsString(config.ttl!.inMilliseconds);
    config.ttl = duration as Duration;
  }

  validateStringMap(config.data!, 'data');
  validateAndroidNotification(config.notification);
  validateAndroidFcmOptions(config.fcmOptions);

  final Map<String, String> propertyMappings = <String, String>{
    'collapseKey': 'collapse_key',
    'restrictedPackageName': 'restricted_package_name',
  };

  renameProperties(config as Map<String, dynamic>, propertyMappings);
}

/// Checks if the given AndroidNotification object is valid. The object must have valid color and
/// localization parameters. If successful, transforms the input object by renaming keys to valid
/// Android keys.
///
/// @param {AndroidNotification} notification An object to be validated.

void validateAndroidNotification(AndroidNotification? notification) {
  if (notification == null) {
    throw FirebaseError.messaging(
      MessagingClientErrorCode.INVALID_PAYLOAD,
      'android.notification must be a non-null object',
    );
  }
  final RegExp validCharacters = RegExp(r'^[a-fA-F0-9]');
  if (notification.color != null && !notification.color!.contains(validCharacters)) {
    throw FirebaseError.messaging(
      MessagingClientErrorCode.INVALID_PAYLOAD,
      'android.notification.color must be in the form #RRGGBB',
    );
  }
  if (notification.bodyLocArgs!.isNotEmpty && notification.bodyLocKey!.isEmpty) {
    throw FirebaseError.messaging(
      MessagingClientErrorCode.INVALID_PAYLOAD,
      'android.notification.bodyLocKey is required when specifying bodyLocArgs',
    );
  }

  if (notification.titleLocArgs!.isNotEmpty && notification.titleLocKey!.isEmpty) {
    throw FirebaseError.messaging(
      MessagingClientErrorCode.INVALID_PAYLOAD,
      'android.notification.titleLocKey is required when specifying titleLocArgs',
    );
  }

  if (!isUrl(notification.imageUrl!)) {
    throw FirebaseError.messaging(
      MessagingClientErrorCode.INVALID_PAYLOAD,
      'android.notification.imageUrl must be a valid URL string',
    );
  }

  if (notification.eventTimestamp != null) {
    if (notification.eventTimestamp.runtimeType != DateTime) {
      throw FirebaseError.messaging(
        MessagingClientErrorCode.INVALID_PAYLOAD,
        'android.notification.eventTimestamp must be a valid `Date` object',
      );
    }
    // Convert timestamp to RFC3339 UTC "Zulu" format, example "2014-10-02T15:01:23.045123456Z"
    final String zuluTimestamp = notification.eventTimestamp!.toIso8601String();
    notification.eventTimestamp = zuluTimestamp as DateTime;
  }

  if (notification.vibrateTimingsMillis != null) {
    if (notification.vibrateTimingsMillis!.isEmpty) {
      throw FirebaseError.messaging(
        MessagingClientErrorCode.INVALID_PAYLOAD,
        'android.notification.vibrateTimingsMillis must be a non-empty array of numbers',
      );
    }
    List<String>? vibrateTimings;
    for (int idx = 0; idx < notification.vibrateTimingsMillis!.length; idx++) {
      if (notification.vibrateTimingsMillis![idx] < const Duration(milliseconds: 0)) {
        throw FirebaseError.messaging(
          MessagingClientErrorCode.INVALID_PAYLOAD,
          'android.notification.vibrateTimingsMillis must be non-negative durations in milliseconds',
        );
      }
      final String duration = transformMillisecondsToSecondsString(notification.vibrateTimingsMillis![idx] as int);
      vibrateTimings!.add(duration);
    }
    notification.vibrateTimingsMillis = vibrateTimings!.cast<Duration>();
  }
}

/// Transforms milliseconds to the format expected by FCM service.
/// Returns the duration in seconds with up to nine fractional
/// digits, terminated by 's'. Example: "3.5s".
///
/// @param {number} milliseconds The duration in milliseconds.
/// @return {string} The resulting formatted string in seconds with up to nine fractional
/// digits, terminated by 's'.

String transformMillisecondsToSecondsString(int milliseconds) {
  final Duration timeDuration = Duration(milliseconds: milliseconds);
  final int seconds = timeDuration.inSeconds;
  final String duration;
  final int nanos = (milliseconds - seconds * 1000) * 1000000;
  if (nanos > 0) {
    String nanoString = nanos.toString();
    while (nanoString.length < 9) {
      nanoString = '0' + nanoString;
    }
    duration = '$seconds.${nanoString}s';
  } else {
    duration = '${seconds}s';
  }

  return duration;
}
