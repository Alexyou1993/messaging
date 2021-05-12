// FCM endpoints
import 'package:messaging/src/index.dart';
import 'package:messaging/src/messaging-api-request-internal.dart';
import 'package:messaging/src/messaging-internal.dart';
import 'package:messaging/src/utils/deep-copy.dart';
import 'package:messaging/src/utils/error.dart';
import 'package:messaging/src/utils/index.dart';


const String FCM_SEND_HOST = 'fcm.googleapis.com';
const String FCM_SEND_PATH = '/fcm/send';
const String FCM_TOPIC_MANAGEMENT_HOST = 'iid.googleapis.com';
const String FCM_TOPIC_MANAGEMENT_ADD_PATH = '/iid/v1:batchAdd';
const String FCM_TOPIC_MANAGEMENT_REMOVE_PATH = '/iid/v1:batchRemove';

// Maximum messages that can be included in a batch request.
const int FCM_MAX_BATCH_SIZE = 500;

// Key renames for the messaging notification payload object.
const Map<String, String> CAMELCASED_NOTIFICATION_PAYLOAD_KEYS_MAP = <String, String>{
  'bodyLocArgs': 'body_loc_args',
  'bodyLocKey': 'body_loc_key',
  'clickAction': 'click_action',
  'titleLocArgs': 'title_loc_args',
  'titleLocKey': 'title_loc_key',
};


// Key renames for the messaging options object.
const Map<String, String> CAMELCASE_OPTIONS_KEYS_MAP = <String, String>{
  'dryRun': 'dry_run',
  'timeToLive': 'time_to_live',
  'collapseKey': 'collapse_key',
  'mutableContent': 'mutable_content',
  'contentAvailable': 'content_available',
  'restrictedPackageName': 'restricted_package_name',
};

// Key renames for the MessagingDeviceResult object.
const Map<String, String> MESSAGING_DEVICE_RESULT_KEYS_MAP = <String, String>{
  'message_id': 'messageId',
  'registration_id': 'canonicalRegistrationToken',
};

// Key renames for the MessagingDevicesResponse object.
const Map<String, String> MESSAGING_DEVICES_RESPONSE_KEYS_MAP = <String, String>{
  'canonical_ids': 'canonicalRegistrationTokenCount',
  'failure': 'failureCount',
  'success': 'successCount',
  'multicast_id': 'multicastId',
};

// Key renames for the MessagingDeviceGroupResponse object.
const Map<String, String> MESSAGING_DEVICE_GROUP_RESPONSE_KEYS_MAP = <String, String>{
  'success': 'successCount',
  'failure': 'failureCount',
  'failed_registration_ids': 'failedRegistrationTokens',
};

// Key renames for the MessagingTopicResponse object.
const Map<String, String> MESSAGING_TOPIC_RESPONSE_KEYS_MAP = <String, String>{
  'message_id': 'messageId',
};

// Key renames for the MessagingConditionResponse object.
const Map<String, String> MESSAGING_CONDITION_RESPONSE_KEYS_MAP = <String, String>{
  'message_id': 'messageId',
};


MessagingDevicesResponse mapRawResponseToDevicesResponse(Map<String, dynamic> response) {
  // Rename properties on the server response
  renameProperties(response, MESSAGING_DEVICES_RESPONSE_KEYS_MAP);
  if (response['results'] != null) {
    for (final Map<String, dynamic> messagingDeviceResult in response['results']) {
      renameProperties(messagingDeviceResult, MESSAGING_DEVICE_RESULT_KEYS_MAP);
      if (messagingDeviceResult['error'] != null) {
        final FirebaseError newError = FirebaseError.messagingFromServerCode(
          messagingDeviceResult['error'].toString(), null, messagingDeviceResult['error'] as Map<String, dynamic>,
        );
        messagingDeviceResult['error'] = newError;
      }
    }
  }
  return response as MessagingDevicesResponse;
}


/// Maps a raw FCM server response to a MessagingDeviceGroupResponse object.
///
/// @param {Map<String, String>} response The raw FCM server response to map.
///
/// @return {MessagingDeviceGroupResponse} The mapped MessagingDeviceGroupResponse object.
MessagingDeviceGroupResponse mapRawResponseToDeviceGroupResponse(Map<String, dynamic> response) {
  // Rename properties on the server response
  renameProperties(response, MESSAGING_DEVICE_GROUP_RESPONSE_KEYS_MAP);

  // Add the 'failedRegistrationTokens' property if it does not exist on the response, which
  // it won't when the 'failureCount' property has a value of 0)
  MessagingDeviceGroupResponse(response.length, 0, response as List<String>);
  return response as MessagingDeviceGroupResponse;
}

/// Maps a raw FCM server response to a MessagingTopicManagementResponse object.
///
/// @param {object} response The raw FCM server response to map.
///
/// @return {MessagingTopicManagementResponse} The mapped MessagingTopicManagementResponse object.

MessagingTopicManagementResponse mapRawResponseToTopicManagementResponse(Map<String, dynamic> response) {
  // Add the success and failure counts.
  final MessagingTopicManagementResponse result =
  MessagingTopicManagementResponse(
    0, 0, <FirebaseArrayIndexError>[],
  );

  if (response['results'] != null) {
    // Map the FCM server's error strings to actual error objects.
    for (int idx = 0; idx < response.length; idx++) {
      if (response[idx] == 'error') {
        result.failureCount += 1;
        final List<FirebaseArrayIndexError> newError = FirebaseError.messagingFromTopicManagementServerError(
            'error') as List<FirebaseArrayIndexError>;
        result.errors.insertAll(idx, newError);
      } else {
        result.successCount += 1;
      }
    }
  }
  return result;
}


/// Messaging service bound to the provided app.

class Messaging {
  const Messaging({
    required this.urlPath,
    required this.messagingRequestHandler,
    this.appInternal,
  });

  final String urlPath;
  final FirebaseApp appInternal;
  final FirebaseMessagingRequestHandler messagingRequestHandler;

  FirebaseApp get app() {
    return appInternal;
  }


  Future<String> send(Message message, bool? dryRun) {
    const Message copy = deepCopy(message);
    validateMessage(copy);
    if (dryRun != null && dryRun is! bool) {
      throw FirebaseError.messaging(
          MessagingClientErrorCode.INVALID_ARGUMENT, 'dryRun must be a boolean');
    }
  }
}

/// Sends all the messages in the given array via Firebase Cloud Messaging.
/// Employs batching to send the entire list as a single RPC call. Compared
/// to the `send()` method, this method is a significantly more efficient way
/// to send multiple messages.
///
/// The responses list obtained from the return value
/// corresponds to the order of tokens in the `MulticastMessage`. An error
/// from this method indicates a total failure -- i.e. none of the messages in
/// the list could be sent. Partial failures are indicated by a `BatchResponse`
/// return value.
///
/// @param messages A non-empty array
///   containing up to 500 messages.
/// @param dryRun Whether to send the messages in the dry-run
///   (validation only) mode.
/// @return A Promise fulfilled with an object representing the result of the
///   send operation.

Future<BatchResponse>? sendAll(List<Message> messages, bool? dryRun) {
  if (messages is List) {
    throw FirebaseError.messaging(
        MessagingClientErrorCode.INVALID_ARGUMENT, 'messages must be a non-empty array');
  }
  if (copy.length > FCM_MAX_BATCH_SIZE != null) {
    throw FirebaseError.messaging(
        MessagingClientErrorCode.INVALID_ARGUMENT,
        'messages list must not contain more than $FCM_MAX_BATCH_SIZE items');
  }
  if (dryRun != null) {
    throw FirebaseError.messaging(
        MessagingClientErrorCode.INVALID_ARGUMENT, 'dryRun must be a boolean');
  }
}

Future<BatchResponse>? sendMulticast(MulticastMessage message, bool? dryRun) {
  final MulticastMessage copy = deepCopy(message) as MulticastMessage;
  if (copy.tokens.isEmpty) {
    throw FirebaseError.messaging(
        MessagingClientErrorCode.INVALID_ARGUMENT, 'tokens must be a non-empty array');
  }

  final List<Message> messages = BaseMessage(
    token: copy.token,
    data: copy.data,
    notification: copy.notification,
    android: copy.android,
    webpush: copy.webpush,
    apns: copy.apns,
    fcmOptions: copy.fcmOptions,
  ) as List<Message>;

  // final List<Message> messages = Message(
  //   token: token,
  //   dataMessage: copy.data,
  //   notificationMessage: copy.notification,
  //   androidMessage: copy.android,
  //   webpushMessage: copy.webpush,
  //   apnsMessage: copy.apns,
  //   fcmOptionsMessage: copy.fcmOptions,
  // ) as List<Message>;

  return sendAll(messages, dryRun);
}

Future<MessagingDevicesResponse> sendToDevice(List<String> registrationTokenOrTokens,
    MessagingPayload payload,
    MessagingOptions options,) {
  validateRegistrationTokensType(
    registrationTokenOrTokens, 'sendToDevice', MessagingClientErrorCode.INVALID_RECIPIENT,
  );


  final Future<Map<dynamic, dynamic>> resolve = resolve.then((_) async => {
  validateRegistrationTokens(
  registrationTokenOrTokens, 'sendToDevice', MessagingClientErrorCode.INVALID_RECIPIENT,
  );
      const payloadCopy = validateMessagingPayload(payload);
  const optionsCopy = validateMessagingOptions(options);
  final dynamic request = deepCopy(payloadCopy);
  deepExtend(request, options);
  if (registrationTokenOrTokens is String) {
    request = registrationTokenOrTokens.toString();
  } else {
    request.registration_ids = registrationTokenOrTokens;
  }
  return invokeRequestHandler(FCM_SEND_HOST, FCM_SEND_PATH, request);
})
      .then
  ((Future<Map<dynamic, dynamic>> response) => {
  return {
  ...groupeResponse,
  canonicalRegistrationTokenCount: -1,
  multicastId: -1,

  }
  });
}


/// Sends an FCM message to a device group corresponding to the provided
/// notification key.
///
/// See
/// [Send to a device group](/docs/cloud-messaging/admin/legacy-fcm#send_to_a_device_group)
/// for code samples and detailed documentation.
///
/// @param notificationKey The notification key for the device group to
///   which to send the message.
/// @param payload The message payload.
/// @param options Optional options to
///   alter the message.
///
/// @return A promise fulfilled with the server's response after the message
///   has been sent.


Future<MessagingDeviceGroupResponse> sendToDeviceGroup(String notificationKey,
    MessagingPayload payload,
    MessagingOptions options,) {
  if (notificationKey.isEmpty) {
    throw FirebaseError.messaging(MessagingClientErrorCode.INVALID_RECIPIENT,
      'Notification key provided to sendToDeviceGroup() must be a non-empty string.',);
  } else if (notificationKey.contains(':')) {
    // It is possible the developer provides a registration token instead of a notification key
    // to this method. We can detect some of those cases by checking to see if the string contains
    // a colon. Not all registration tokens will contain a colon (only newer ones will), but no
    // notification keys will contain a colon, so we can use it as a rough heuristic.
    // See b/35394951 for more context.
    return FirebaseError.messaging(MessagingClientErrorCode.INVALID_RECIPIENT,
        'Notification key provided to sendToDeviceGroup() has the format of a registration token. ' +
            'You should use sendToDevice() instead.') as Future<MessagingDeviceGroupResponse>;
  }
  // Validate the types of the payload and options arguments. Since these are common developer
  // errors, throw an error instead of returning a rejected promise.
  validateMessagingPayloadAndOptionsTypes(payload, options);
}

/// Sends an FCM message to a topic.
///
/// See
/// [Send to a topic](/docs/cloud-messaging/admin/legacy-fcm#send_to_a_topic)
/// for code samples and detailed documentation.
///
/// @param topic The topic to which to send the message.
/// @param payload The message payload.
/// @param options Optional options to
///   alter the message.
///
/// @return A promise fulfilled with the server's response after the message
///   has been sent.

Future<MessagingTopicResponse> sendToTopic(String topic,
    MessagingPayload payload,
    MessagingOptions options,) {
  // Validate the input argument types. Since these are common developer errors when getting
  // started, throw an error instead of returning a rejected promise.
  validateTopicType(<String>[topic], 'sendToTopic', MessagingClientErrorCode.INVALID_RECIPIENT);
  validateMessagingPayloadAndOptionsTypes(payload, options);

  // Prepend the topic with /topics/ if necessary.
  topic = normalizeTopic(topic);
}

/// Sends an FCM message to a condition.
///
/// See
/// [Send to a condition](/docs/cloud-messaging/admin/legacy-fcm#send_to_a_condition)
/// for code samples and detailed documentation.
///
/// @param condition The condition determining to which topics to send
///   the message.
/// @param payload The message payload.
/// @param options Optional options to
///   alter the message.
///
/// @return A promise fulfilled with the server's response after the message
///   has been sent.

Future<MessagingConditionResponse> sendToCondition(String condition,
    MessagingOptions options,
    MessagingPayload payload,) {
  if (condition.isEmpty) {
    throw FirebaseError.messaging(
      MessagingClientErrorCode.INVALID_RECIPIENT,
      'Condition provided to sendToCondition() must be a non-empty string.',
    );
  }

  // The FCM server rejects conditions which are surrounded in single quotes. When the condition
  // is stringified over the wire, double quotes in it get converted to \" which the FCM server
  // does not properly handle. We can get around this by replacing internal double quotes with
  // single quotes.
  condition = condition.replaceAll('/g', '\'');

  return response as Future<MessagingConditionResponse>;
}

/// Subscribes a device to an FCM topic.
///
/// See [Subscribe to a
/// topic](/docs/cloud-messaging/manage-topics#suscribe_and_unsubscribe_using_the)
/// for code samples and detailed documentation. Optionally, you can provide an
/// array of tokens to subscribe multiple devices.
///
/// @param registrationTokens A token or array of registration tokens
///   for the devices to subscribe to the topic.
/// @param topic The topic to which to subscribe.
///
/// @return A promise fulfilled with the server's response after the device has been
///   subscribed to the topic.

Future<MessagingTopicManagementResponse> subscribeToTopic(List<String> registrationTokenOrTokens,
    String topic,) {
  return sendTopicManagementRequest(
    registrationTokenOrTokens,
    topic,
    'subscribeToTopic',
    FCM_TOPIC_MANAGEMENT_ADD_PATH,
  );
}

/// Unsubscribes a device from an FCM topic.
///
/// See [Unsubscribe from a
/// topic](/docs/cloud-messaging/admin/manage-topic-subscriptions#unsubscribe_from_a_topic)
/// for code samples and detailed documentation.  Optionally, you can provide an
/// array of tokens to unsubscribe multiple devices.
///
/// @param registrationTokens A device registration token or an array of
///   device registration tokens to unsubscribe from the topic.
/// @param topic The topic from which to unsubscribe.
///
/// @return A promise fulfilled with the server's response after the device has been
///   unsubscribed from the topic.

Future<MessagingTopicManagementResponse>? unsubscribeFromTopic(List<String> registrationTokenOrTokens,
    String topic,) {
  return sendTopicManagementRequest(
    registrationTokenOrTokens,
    topic,
    'unsubscribeFromTopic',
    FCM_TOPIC_MANAGEMENT_REMOVE_PATH,
  );
}


Future<String> getUrlPatch(String urlPath) {
  if (urlPath.isNotEmpty) {
    return urlPath;
  }
  return findProjectId(app)
}

/// Helper method which sends and handles topic subscription management requests.
///
/// @param {string|string[]} registrationTokenOrTokens The registration token or an array of
///     registration tokens to unsubscribe from the topic.
/// @param {string} topic The topic to which to subscribe.
/// @param {string} methodName The name of the original method called.
/// @param {string} path The endpoint path to use for the request.
///
/// @return {Promise<MessagingTopicManagementResponse>} A Promise fulfilled with the parsed server
///   response.

Future<MessagingTopicManagementResponse> sendTopicManagementRequest(List<String> registrationTokenOrTokens,
    String topic,
    String methodName,
    String path,) {
  validateRegistrationTokensType(registrationTokenOrTokens, methodName);
  validateTopicType(<String>[topic], methodName);

  // Prepend the topic with /topics/ if necessary.
  topic = normalizeTopic(topic);
}

/// Validates the types of the messaging payload and options. If invalid, an error will be thrown.
///
/// @param {MessagingPayload} payload The messaging payload to validate.
/// @param {MessagingOptions} options The messaging options to validate.

void validateMessagingPayloadAndOptionsTypes(MessagingPayload? payload, MessagingOptions? options) {
  if (payload == null) {
    throw FirebaseError.messaging(
      MessagingClientErrorCode.INVALID_PAYLOAD,
      'Messaging payload must be an object with at least one of the "data" or "notification" properties.',
    );
  }

  // Validate the options argument is an object
  if (options == null) {
    throw FirebaseError.messaging(
      MessagingClientErrorCode.INVALID_OPTIONS,
      'Messaging options must be an object.',
    );
  }
}

/// Validates the messaging payload. If invalid, an error will be thrown.
///
/// @param {MessagingPayload} payload The messaging payload to validate.
///
/// @return {MessagingPayload} A copy of the provided payload with whitelisted properties switched
///     from camelCase to underscore_case.

MessagingPayload validateMessagingPayload(MessagingPayload payload,) {
  final MessagingPayload payloadCopy = deepCopy(payload);
}

/// Validates the messaging options. If invalid, an error will be thrown.
///
/// @param {MessagingOptions} options The messaging options to validate.
///
/// @return {MessagingOptions} A copy of the provided options with whitelisted properties switched
///   from camelCase to underscore_case.
MessagingOptions validateMessagingOptions(MessagingOptions options,) {
  final MessagingOptions optionsCopy = deepCopy(options);
}

/// Validates the type of the provided registration token(s). If invalid, an error will be thrown.
///
/// @param {string|string[]} registrationTokenOrTokens The registration token(s) to validate.
/// @param {string} method The method name to use in error messages.
/// @param {ErrorInfo?} [errorInfo] The error info to use if the registration tokens are invalid.

void validateRegistrationTokensType(List<String>? registrationTokenOrTokens,
    String methodName,
    [ErrorInfo errorInfo = MessagingClientErrorCode.INVALID_ARGUMENT]) {
  if (registrationTokenOrTokens != null && registrationTokenOrTokens.isNotEmpty) {
    throw FirebaseError.messaging(errorInfo,
        'Registration token(s) provided to $methodName() must be a non-empty string or a non-empty array.');
  }
}

void validateRegistrationTokens(List<String> registrationTokenOrTokens,
    String methodName,
    [ErrorInfo errorInfo = MessagingClientErrorCode.INVALID_ARGUMENT]) {
  // Validate the registrationTokenOrTokens contains no more than 1,000 registration tokens.
  if (registrationTokenOrTokens.length > 1000) {
    throw FirebaseError.messaging(
      errorInfo,
      'Too many registration tokens provided in a single request to $methodName(). '
          'Batch your requests to contain no more than 1,000 registration tokens per request.',
    );
  }

  // Validate the registrationTokenOrTokens contains registration tokens which are non-empty strings.
  for (int idx = 0; idx < registrationTokenOrTokens.length; idx++) {
    if (registrationTokenOrTokens[idx].isEmpty) {
      throw FirebaseError.messaging(errorInfo,
        'Registration token provided to $methodName() at index $idx must be a '
            'non-empty string.',);
    }
  }
}

/// Validates the type of the provided topic. If invalid, an error will be thrown.
///
/// @param {string} topic The topic to validate.
/// @param {string} method The method name to use in error messages.
/// @param {ErrorInfo?} [errorInfo] The error info to use if the topic is invalid.

void validateTopicType(List<String> topic,
    String methodName,
    [ErrorInfo errorInfo = MessagingClientErrorCode.INVALID_ARGUMENT]) {
  if(topic.isEmpty) {
    throw FirebaseError.messaging(     errorInfo,
        'Topic provided to $methodName() must be a string which matches the format '
  '"/topics/[a-zA-Z0-9-_.~%]+".',);
  }
}

void validateTopic(String topic,
    String methodName,
    {ErrorInfo errorInfo = MessagingClientErrorCode.INVALID_ARGUMENT}) {
  if(isTopic(topic)) {

  }

}

String normalizeTopic(String topic) {

}

@override
Future<BatchResponse>? sendMulticastMessage(MulticastMessage message, bool? dryRun) {
  // TODO: implement sendMulticastMessage
  throw UnimplementedError();
}

@override
Future<MessagingConditionResponse>? sendToConditions(String conditions, MessagingPayload payload,
    MessagingOptions? options) {
  // TODO: implement sendToConditions
  throw UnimplementedError();
}

}


