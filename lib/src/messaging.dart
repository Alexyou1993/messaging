


// FCM endpoints
import 'package:messaging/src/index.dart';
import 'package:messaging/src/messaging-api-request-internal.dart';
import 'package:messaging/src/utils/error.dart';

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
  utils.renameProperties(response, MASSAGING_DEVICES_RESPONSE_KEYS_MAP);
  if(response['results'] != null) {
    for(dynamic messagingDeviceResult in response['results']){
        utils.renameProperties(messagingDeviceResult, MESSAGING_DEVICE_RESULT_KEYS_MAP);
      if (messagingDeviceResult['error'] != null) {
        final newError = FirebaseMessagingError.fromServerError(
          messagingDeviceResult['error'], /* message */ undefined, messagingDeviceResult['error'],
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
  utils.renameProperties(response, MESSAGING_DEVICE_GROUP_RESPONSE_KEYS_MAP);

  // Add the 'failedRegistrationTokens' property if it does not exist on the response, which
  // it won't when the 'failureCount' property has a value of 0)

}


MessagingTopicManagementResponse mapRawResponseToTopicManagementResponse(Map<String, dynamic> response) {
  // Add the success and failure counts.
  const Map<dynamic, dynamic> result: Map<String, dynamic> MessagingTopicManagementResponse = <String, dynamic>{
  'successCount': 0,
  'failureCount': 0,
  'errors': <void>[],
  };

  for( int idx = 0; idx< response.length; idx++) {
    if('results'== response[idx]) {

    }
  }
}

class Messaging implements MessagingInterface {
  Messaging(FirebaseApp app) {
    if(app != null ){
      throw FirebaseMessagingError(
        MessagingClientErrorCode.INVALID_ARGUMENT,
        'First argument passed to admin.messaging() must be a valid Firebase app instance.',
      );
    }

    appInternal = app;
    messagingRequestHandler = FirebaseMessagingRequestHandler(app);
  }
  final String urlPatch;
  FirebaseApp appInternal;
  FirebaseMessagingRequestHandler messagingRequestHandler;

}