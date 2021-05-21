import 'package:messaging/src/utils/error.dart';

class BaseMessage {
  BaseMessage({
    this.token,
    this.data,
    this.notification,
    this.android,
    this.webpush,
    this.apns,
    this.fcmOptions,
  });

  String? token;
  Map<String, String>? data;
  Notification? notification;
  AndroidConfig? android;
  WebpushConfig? webpush;
  ApnsConfig? apns;
  FcmOptions? fcmOptions;
}

// class TokenMessage extends BaseMessage {
//   TokenMessage({required this.token});
//
//   final String token;
// }
//
// class TopicMessage extends BaseMessage {
//   TopicMessage({required this.topic});
//
//   final String topic;
// }
//
// class ConditionMessage extends BaseMessage {
//   ConditionMessage({required this.condition});
//
//   final String condition;
// }

/// Payload for the admin.messaging.send() operation. The payload contains all the fields
/// in the BaseMessage type, and exactly one of token, topic or condition.

//todo: check if the dart implementation is correct;
class Message extends BaseMessage {
  Message({
    this.token,
    this.topic,
    this.condition,
    this.dataMessage,
    this.notificationMessage,
    this.androidMessage,
    this.fcmOptionsMessage,
    this.apnsMessage,
    this.webpushMessage,
  }) : super(
          token: token,
          data: dataMessage,
          notification: notificationMessage,
          android: androidMessage,
          webpush: webpushMessage,
          apns: apnsMessage,
          fcmOptions: fcmOptionsMessage,
        );

  @override
  String? token;

  final String? topic;

  final String? condition;

  Map<String, String>? dataMessage;
  Notification? notificationMessage;
  AndroidConfig? androidMessage;
  WebpushConfig? webpushMessage;
  ApnsConfig? apnsMessage;
  FcmOptions? fcmOptionsMessage;
}

/// Payload for the admin.messaing.sendMulticase() method.

/// The payload contains all the fields in the BaseMessage type, and a list of tokens.

class MulticastMessage extends BaseMessage {
  MulticastMessage({required this.tokens});

  final List<String> tokens;
}

/// A notification that can be included in [link messaging.Message].

class Notification {
  /// The title of the notification.

  String? title;

  /// The notification body

  String? body;

  /// URL of an image to be displayed in the notification.

  String? imageUrl;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
    };
  }
}

/// Represents platform-independent options for features provided by the FCM SDKs.

class FcmOptions {
  /// The label associated with the message's analytics data.

  String? analyticsLabel;
}

/// Represents the WebPush protocol options that can be included in an [link messaging.Message].

class WebpushConfig {
  /// A collection of WebPush headers. Header values must be strings.

  /// See [WebPush specification](https://tools.ietf.org/html/rfc8030#section-5) for supported headers.

  Map<String, String>? headers;

  /// A collection of data fields.

  Map<String, String>? data;

  /// A WebPush notification payload to be included in the message.

  WebpushNotification? notification;

  /// Options for features provided by the FCM SDK for Web.

  WebpushFcmOptions? fcmOptions;
}

/// Represents options for features provided by the FCM SDK for Web (which are not part of the Webpush standard).

class WebpushFcmOptions {
  /// The link to open when the user clicks on the notification.
  /// For all URL values, HTTPS is required.

  String? link;
}

/// Represents the WebPush-specific notification options that can be included in [link messaging.WebpushConfig].

/// This supports most of the standard options as defined in the Web Notification
/// [specification](https://developer.mozilla.org/en-US/docs/Web/API/notification/Notification).

class WebpushNotification {
  WebpushNotification({required this.dataData});

  /// Title text of the notification.

  String? title;

  /// An array of notification actions representing the actions available to the user when the notification is presented.

//todo: check the corresponding value for "actions?: Array<{action: string;icon?: string;title: string;}>;

  /// URL of the image used to represent the notification when there is
  /// not enough space to display the notification itself.

  String? badge;

  /// Body text of the notification.

  String? body;

  /// Arbitrary data that you want associated with the notification.
  /// This can be of any data type.

  dynamic? data;

  /// The direction in which to display the notification.
  /// Must be one of `auto`, `ltr` or `rtl`.

  Dir? dir;

  /// URL to the notification icon.

  String? icon;

  /// URL of an image to be displayed in the notification.

  String? image;

  /// The notification's language as a BCP 47 language tag.

  String? lang;

  /// A boolean specifying whether the user should be notified after a
  /// new notification replaces an old one. Defaults to false.

  bool? renotify;

  /// Indicates that a notification should remain active until the user
  /// clicks or dismisses it, rather than closing automatically.
  /// Defaults to false.

  bool? requireInteraction;

  /// A boolean specifying whether the notification should be silent.
  /// Defaults to false.

  bool? silent;

  /// An identifying tag for the notification.

  String? tag;

  /// Timestamp of the notification. Refer to
  /// https://developer.mozilla.org/en-US/docs/Web/API/notification/timestamp
  /// for details.

  Duration? timestamp;

  /// A vibration pattern for the device's vibration hardware to emit when the notification fires.

  List<Duration>? vibrate; //todo: check if correspond to "vibrate?: number | number[];";

//"[key: string]: any;"
  final Map<String, dynamic> dataData;
}

enum Dir {
  auto,
  ltr,
  rtl,
}

/// Represents the APNs-specific options that can be included in an [link messaging.Message].

/// Refer to [Apple documentation](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CommunicatingwithAPNs.html)
/// for various headers and payload fields supported by APNs.

class ApnsConfig {
  /// A collection of APNs headers. Header values must be strings.

  Map<String, String>? headers;

  /// An APNs payload to be included in the message.

  ApnsPayload? payload;

  /// Options for features provided by the FCM SDK for iOS.

  ApnsFcmOptions? fcmOptions;
}

/// Represents the payload of an APNs message.

/// Mainly consists of the `aps` dictionary. But may also contain other arbitrary custom keys.

class ApnsPayload {
  ApnsPayload({required this.aps, required this.customData});

  /// The `aps` dictionary to be included in the message.

  final Aps aps;

  final Map<String, dynamic> customData;
}

/// Represents the [aps dictionary](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/PayloadKeyReference.html)
/// that is part of APNs messages.

class Aps {
  Aps({required this.customData});

  /// Alert to be included in the message. This may be a string or an object of type `admin.messaging.ApsAlert`.

  ApsAlert? alert;

  /// Badge to be displayed with the message. Set to 0 to remove the badge. When
  /// not specified, the badge will remain unchanged.

  Duration? badge;

  /// Sound to be played with the message.

  CriticalSound? sound;

  /// Specifies whether to configure a background update notification.

  bool? contentAvailable;

  /// Specifies whether to set the `mutable-content` property on the message
  /// so the clients can modify the notification via app extensions.

  bool? mutableContent;

  /// Type of the notification

  String? category;

  /// An app-specific identifier for grouping notifications.

  String? threadId;

  final Map<String, dynamic> customData;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'alert': alert,
      'badge': badge,
      'sound': sound,
      'contentAvailable': contentAvailable,
      'mutableContent': mutableContent,
      'category': category,
      'threadId': threadId,
      'customData': customData,
    };
  }
}

class ApsAlert {
  String? title;
  String? subtitle;
  String? body;
  String? locKey;
  List<String>? locArgs;
  String? titleLocKey;
  List<String>? titleLocArgs;
  String? subtitleLocKey;
  List<String>? subtitleLocArgs;
  String? actionLocKey;
  String? launchImage;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'subtitle': subtitle,
      'body': body,
      'locKey': locKey,
      'locArgs': locArgs,
      'titleLocKey': titleLocKey,
      'titleLocArgs': titleLocArgs,
      'subtitleLocKey': subtitleLocKey,
      'subtitleLocArgs': subtitleLocArgs,
      'actionLocKey': actionLocKey,
      'launchImage': launchImage,
    };
  }
}

/// Represents a critical sound configuration that can be included in the
/// `aps` dictionary of an APNs payload.

class CriticalSound {
  /// The critical alert flag. Set to `true` to enable the critical alert.

  bool? critical;

  /// The name of a sound file in the app's main bundle or in the `Library/Sounds`
  /// folder of the app's container directory. Specify the string "default" to play the system sound.

  String? name;

  /// The volume for the critical alert's sound. Must be a value between 0.0
  /// (silent) and 1.0 (full volume).

  double? volume;
}

/// Represents options for features provided by the FCM SDK for iOS.

class ApnsFcmOptions {
  /// The label associated with the message's analytics data.

  String? analyticsLabel;

  /// URL of an image to be displayed in the notification.

  String? imageUrl;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'analyticsLabel': analyticsLabel,
      'imageUrl': imageUrl,
    };
  }
}

/// Represents the Android-specific options that can be included in an [link messaging.Message].

class AndroidConfig {
  /// Collapse key for the message. Collapse key serves as an identifier for a
  /// group of messages that can be collapsed, so that only the last message gets
  /// sent when delivery can be resumed. A maximum of four different collapse keys
  /// may be active at any given time.

  String? collapseKey;

  ///  Priority of the message. Must be either `normal` or `high`.

  PriorityAndroidConfig? priority;

  /// Time-to-live duration of the message in milliseconds.

  Duration? ttl;

  /// Package name of the application where the registration tokens must match in order to receive the message.

  String? restrictedPackageName;

  /// A collection of data fields to be included in the message. All values must
  /// be strings. When provided, overrides any data fields set on the top-level `admin.messaging.Message`.

  Map<String, String>? data;

  /// Android notification to be included in the message.

  AndroidNotification? notification;

  /// Options for features provided by the FCM SDK for Android.

  AndroidFcmOptions? fcmOptions;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'collapseKey': collapseKey,
      'priority': priority,
      'ttl': ttl,
      'restrictedPackageName': restrictedPackageName,
      'data': data,
      'notification': notification,
      'fcmOptions': fcmOptions,
    };
  }
}

enum PriorityAndroidConfig { high, normal }

/// Represents the Android-specific notification options that can be included in
/// [link messaging.AndroidConfig].

class AndroidNotification {
  /// Title of the Android notification. When provided, overrides the title set via
  /// `admin.messaging.Notification`.

  String? title;

  /// Body of the Android notification. When provided, overrides the body set via
  /// `admin.messaging.Notification`.

  String? body;

  /// Icon resource for the Android notification.

  String? icon;

  /// Notification icon color in `#rrggbb` format.

  String? color;

  /// File name of the sound to be played when the device receives the notification.

  String? sound;

  /// Notification tag. This is an identifier used to replace existing
  /// notifications in the notification drawer. If not specified, each request
  /// creates a new notification.

  String? tag;

  /// URL of an image to be displayed in the notification.

  String? imageUrl;

  /// Action associated with a user click on the notification. If specified, an
  /// activity with a matching Intent Filter is launched when a user clicks on the notification.

  String? clickAction;

  /// Key of the body string in the app's string resource to use to localize the body text.

  String? bodyLocKey;

  /// An array of resource keys that will be used in place of the format specifiers in `bodyLocKey`.

  List<String>? bodyLocArgs;

  /// Key of the title string in the app's string resource to use to localize the title text.

  String? titleLocKey;

  /// An array of resource keys that will be used in place of the format specifiers in `titleLocKey`.

  List<String>? titleLocArgs;

  /// The Android notification channel ID (new in Android O). The app must create
  /// a channel with this channel ID before any notification with this channel ID
  /// can be received. If you don't send this channel ID in the request, or if the
  /// channel ID provided has not yet been created by the app, FCM uses the channel
  /// ID specified in the app manifest.

  String? channelId;

  /// Sets the "ticker" text, which is sent to accessibility services. Prior to
  ///  API level 21 (Lollipop), sets the text that is displayed in the status bar
  ///  when the notification first arrives.

  String? ticker;

  /// When set to `false` or unset, the notification is automatically dismissed when
  /// the user clicks it in the panel. When set to `true`, the notification persists
  /// even when the user clicks it.

  bool? sticky;

  /// For notifications that inform users about events with an absolute time reference, sets
  ///  the time that the event in the notification occurred. Notifications
  ///  in the panel are sorted by this time.

  DateTime? eventTimestamp;

  /// Sets whether or not this notification is relevant only to the current device.
  /// Some notifications can be bridged to other devices for remote display, such as
  /// a Wear OS watch. This hint can be set to recommend this notification not be bridged.
  /// See [Wear OS guides](https://developer.android.com/training/wearables/notifications/bridger#existing-method-of-preventing-bridging)

  bool? localOnly;

  /// Sets the relative priority for this notification. Low-priority notifications
  /// may be hidden from the user in certain situations. Note this priority differs
  /// from `AndroidMessagePriority`. This priority is processed by the client after
  /// the message has been delivered. Whereas `AndroidMessagePriority` is an FCM concept
  /// that controls when the message is delivered.

  PriorityAndroidNotification? priority;

  /// Sets the vibration pattern to use. Pass in an array of milliseconds to
  /// turn the vibrator on or off. The first value indicates the duration to wait before
  /// turning the vibrator on. The next value indicates the duration to keep the
  /// vibrator on. Subsequent values alternate between duration to turn the vibrator
  /// off and to turn the vibrator on. If `vibrate_timings` is set and `default_vibrate_timings`
  /// is set to `true`, the default value is used instead of the user-specified `vibrate_timings`.

  List<Duration>? vibrateTimingsMillis;

  /// If set to `true`, use the Android framework's default vibrate pattern for the notification.
  /// Default values are specified in [`config.xml`](https://android.googlesource.com/platform/frameworks/base/+/master/core/res/res/values/config.xml).
  /// If `default_vibrate_timings` is set to `true` and `vibrate_timings` is also set,
  /// the default value is used instead of the user-specified `vibrate_timings`.

  bool? defaultVibrateTimings;

  /// If set to `true`, use the Android framework's default sound for the notification.
  /// Default values are specified in [`config.xml`](https://android.googlesource.com/platform/frameworks/base/+/master/core/res/res/values/config.xml).

  bool? defaultSound;

  /// Settings to control the notification's LED blinking rate and color if LED is
  /// available on the device. The total blinking time is controlled by the OS.

  LightSettings? lightSettings;

  /// If set to `true`, use the Android framework's default LED light settings for the notification.
  /// Default values are specified in [`config.xml`](https://android.googlesource.com/platform/frameworks/base/+/master/core/res/res/values/config.xml).
  /// If `default_light_settings` is set to `true` and `light_settings` is also set,
  /// the user-specified `light_settings` is used instead of the default value.

  bool? defaultLightSettings;

  /// Sets the visibility of the notification. Must be either `private`, `public`, or `secret`.
  /// If unspecified, defaults to `private`.

  VisibilityAndroidNotification? visibility;

  /// Sets the number of items this notification represents. May be displayed as a
  /// badge count for Launchers that support badging. See [`NotificationBadge`(https://developer.android.com/training/notify-user/badges).
  /// For example, this might be useful if you're using just one notification to
  /// represent multiple new messages but you want the count here to represent
  /// the number of total new messages. If zero or unspecified, systems
  /// that support badging use the default, which is to increment a number
  /// displayed on the long-press menu each time a new notification arrives.

  int? notificationCount;
}

enum PriorityAndroidNotification { min, low, def, high, max }

enum VisibilityAndroidNotification { private, public, secret }

/// Represents settings to control notification LED that can be included in
/// [link messaging.AndroidNotification].

class LightSettings {
  LightSettings({required this.color, required this.lightOnDurationMillis});

  /// Required. Sets color of the LED in `#rrggbb` or `#rrggbbaa` format.

  final String color;

  /// Required. Along with `light_off_duration`, defines the blink rate of LED flashes.

  final Duration lightOnDurationMillis;
}

/// Represents options for features provided by the FCM SDK for Android.

class AndroidFcmOptions {
  /// The label associated with the message's analytics data.

  String? analyticsLabel;
}

/// Interface representing an FCM legacy API data message payload.

/// Data messages let developers send up to 4KB of custom key-value pairs. The
/// keys and values must both be strings. Keys can be any custom string,
/// except for the following reserved strings:

/// `"from"`
/// Anything starting with `"google."`.

/// See [Build send requests](/docs/cloud-messaging/send-message)
/// for code samples and detailed documentation.

class DataMessagePayload {
  DataMessagePayload({required this.data});

  final Map<String, String> data;
}

/// Interface representing an FCM legacy API notification message payload.

/// Notification messages let developers send up to 4KB of predefined
/// key-value pairs. Accepted keys are outlined below.

/// See [Build send requests](/docs/cloud-messaging/send-message)
/// for code samples and detailed documentation.

class NotificationMessagePayload {
  /// Identifier used to replace existing notifications in the notification drawer.

  /// If not specified, each request creates a new notification.

  /// If specified and a notification with the same tag is already being shown,
  /// the new notification replaces the existing one in the notification drawer.

  /// Platforms: Android

  String? tag;

  /// The notification's body text.

  /// Platforms:** iOS, Android, Web

  String? body;

  /// The notification's icon.

  /// Android:** Sets the notification icon to `myicon` for drawable resource
  /// `myicon`. If you don't send this key in the request, FCM displays the
  /// launcher icon specified in your app manifest.

  /// Web:** The URL to use for the notification's icon.

  /// Platforms:** Android, Web

  String? icon;

  /// The value of the badge on the home screen app icon.

  /// If not specified, the badge is not changed.

  /// If set to `0`, the badge is removed.

  /// Platforms:** iOS

  String? badge;

  /// The notification icon's color, expressed in `#rrggbb` format.

  /// Platforms:** Android

  String? color;

  /// The sound to be played when the device receives a notification.

  /// Supports "default" for the default notification sound of the device or the filename of a
  /// sound resource bundled in the app.
  /// Sound files must reside in `/res/raw/`.

  /// Platforms:** Android

  String? sound;

  /// The notification's title.

  /// Platforms:** iOS, Android, Web

  String? title;

  /// The key to the body string in the app's string resources to use to localize the body text to the user's current localization.

  /// iOS:** Corresponds to `loc-key` in the APNs payload. See
  /// [Payload Key Reference](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/PayloadKeyReference.html)
  /// and
  /// [Localizing the Content of Your Remote Notifications](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CreatingtheNotificationPayload.html#//apple_ref/doc/uid/TP40008194-CH10-SW9)
  /// for more information.

  /// Android:** See
  /// [String Resources](http://developer.android.com/guide/topics/resources/string-resource.html)      * for more information.

  /// Platforms:** iOS, Android

  String? bodyLocKey;

  /// Variable string values to be used in place of the format specifiers in
  /// `body_loc_key` to use to localize the body text to the user's current
  /// localization.

  /// The value should be a toString JSON array.

  /// iOS:** Corresponds to `loc-args` in the APNs payload. See
  /// [Payload Key Reference](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/PayloadKeyReference.html)
  /// and
  /// [Localizing the Content of Your Remote Notifications](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CreatingtheNotificationPayload.html#//apple_ref/doc/uid/TP40008194-CH10-SW9)
  /// for more information.

  /// Android:** See
  /// [Formatting and Styling](http://developer.android.com/guide/topics/resources/string-resource.html#FormattingAndStyling)
  /// for more information.

  /// Platforms:** iOS, Android

  String? bodyLocArgs;

  /// Action associated with a user click on the notification. If specified, an
  /// activity with a matching Intent Filter is launched when a user clicks on the
  /// notification.

  /// Platforms:** Android

  String? clickAction;

  /// The key to the title string in the app's string resources to use to localize
  /// the title text to the user's current localization.

  /// iOS:** Corresponds to `title-loc-key` in the APNs payload. See
  /// [Payload Key Reference](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/PayloadKeyReference.html)
  /// and
  /// [Localizing the Content of Your Remote Notifications](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CreatingtheNotificationPayload.html#//apple_ref/doc/uid/TP40008194-CH10-SW9)
  /// for more information.

  /// Android:** See
  /// [String Resources](http://developer.android.com/guide/topics/resources/string-resource.html)
  /// for more information.

  /// Platforms:** iOS, Android

  String? titleLocKey;

  /// Variable string values to be used in place of the format specifiers in
  /// `title_loc_key` to use to localize the title text to the user's current
  /// localization.

  /// The value should be a stringified JSON array.

  /// iOS:** Corresponds to `title-loc-args` in the APNs payload. See
  ///[Payload Key Reference](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/PayloadKeyReference.html)
  /// and
  /// [Localizing the Content of Your Remote Notifications](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CreatingtheNotificationPayload.html#//apple_ref/doc/uid/TP40008194-CH10-SW9)
  /// for more information.

  /// Android:** See
  /// [Formatting and Styling](http://developer.android.com/guide/topics/resources/string-resource.html#FormattingAndStyling)
  /// for more information.

  /// Platforms:** iOS, Android

  String? titleLocArgs;

//[key: string]: any | undefined
  Map<String, dynamic>? data;
}

/// Interface representing a Firebase Cloud Messaging message payload. One or
/// both of the `data` and `notification` keys are required.

/// See
/// [Build send requests](/docs/cloud-messaging/send-message)
/// for code samples and detailed documentation.

class MessagingPayload {
  /// The data message payload.

  DataMessagePayload? data;

  /// The notification message payload.

  NotificationMessagePayload? notification;
}

/// Interface representing the options that can be provided when sending a
/// message via the FCM legacy APIs.

/// See [Build send requests](/docs/cloud-messaging/send-message)
/// for code samples and detailed documentation.

class MessagingOptions {
  /// Whether or not the message should actually be sent. When set to `true`,
  /// allows developers to test a request without actually sending a message. When
  /// set to `false`, the message will be sent.

  /// Default value: `false`

  bool? dryRun;

  /// The priority of the message. Valid values are `"normal"` and `"high".` On
  /// iOS, these correspond to APNs priorities `5` and `10`.

  /// By default, notification messages are sent with high priority, and data
  /// messages are sent with normal priority. Normal priority optimizes the client
  /// app's battery consumption and should be used unless immediate delivery is
  /// required. For messages with normal priority, the app may receive the message
  /// with unspecified delay.

  /// When a message is sent with high priority, it is sent immediately, and the
  /// app can wake a sleeping device and open a network connection to your server.

  /// For more information, see
  /// [Setting the priority of a message](/docs/cloud-messaging/concept-options#setting-the-priority-of-a-message).

  /// Default value: `"high"` for notification messages, `"normal"` for data messages

  String? priority;

  /// How long (in seconds) the message should be kept in FCM storage if the device
  /// is offline. The maximum time to live supported is four weeks, and the default
  /// value is also four weeks. For more information, see
  /// [Setting the lifespan of a message](/docs/cloud-messaging/concept-options#ttl).

  /// Default value: `2419200` (representing four weeks, in seconds)

  Duration? timeToLive;

  /// String identifying a group of messages (for example, "Updates Available")
  /// that can be collapsed, so that only the last message gets sent when delivery
  /// can be resumed. This is used to avoid sending too many of the same messages
  /// when the device comes back online or becomes active.

  /// There is no guarantee of the order in which messages get sent.

  /// A maximum of four different collapse keys is allowed at any given time. This
  /// means FCM server can simultaneously store four different
  /// send-to-sync messages per client app. If you exceed this number, there is no
  /// guarantee which four collapse keys the FCM server will keep.

  /// Default value: None

  String? collapseKey;

  /// On iOS, use this field to represent `mutable-content` in the APNs payload.
  /// When a notification is sent and this is set to `true`, the content of the
  /// notification can be modified before it is displayed, using a
  /// [Notification Service app extension](https://developer.apple.com/reference/usernotifications/unnotificationserviceextension)

  /// On Android and Web, this parameter will be ignored.

  /// Default value: `false`

  bool? mutableContent;

  ///  On iOS, use this field to represent `content-available` in the APNs payload.

  ///  When a notification or data message is sent and this is set to `true`, an
  ///  inactive client app is awoken. On Android, data messages wake the app by
  ///  default. On Chrome, this flag is currently not supported.

  ///  Default value: `false`

  bool? contentAvailable;

  /// The package name of the application which the registration tokens must match
  /// in order to receive the message.

  /// Default value:** None

  String? restrictedPackageName;

//[key: string]: any | undefined
  Map<String, dynamic>? data;
}

// Individual status response payload from single devices
class MessagingDeviceResult {
  /// The error that occurred when processing the message for the recipient.

  FirebaseError? error;

  /// A unique ID for the successfully processed message.

  String? messageId;

  /// The canonical registration token for the client app that the message was processed and sent to.

  /// You should use this value as the registration token
  /// for future requests. Otherwise, future messages might be rejected.

  String? canonicalRegistrationToken;
}

/// Interface representing the status of a message sent to an individual device via the FCM legacy APIs.

/// See
/// [Send to individual devices](/docs/cloud-messaging/admin/send-messages#send_to_individual_devices)
/// for code samples and detailed documentation.

class MessagingDevicesResponse {
  MessagingDevicesResponse(
    this.canonicalRegistrationTokenCount,
    this.failureCount,
    this.multicastId,
    this.successCount,
    this.results,
  );

  MessagingDevicesResponse.fromJson(Map<dynamic, dynamic> json)
      : canonicalRegistrationTokenCount = int.parse('${json['canonicalRegistrationTokenCount']}'),
        failureCount = int.parse('${json['failureCount']}'),
        multicastId = int.parse('${json['multicastId']}'),
        successCount = int.parse('${json['successCount']}'),
        results = <MessagingDeviceResult>[json['results'] as MessagingDeviceResult];

  int canonicalRegistrationTokenCount;
  int failureCount;
  int multicastId;
  int successCount;
  List<MessagingDeviceResult> results;

// MessagingDevicesResponse fromJson(Map<String, dynamic> json) {
//   canonicalRegistrationTokenCount = int.parse('${json['canonicalRegistrationTokenCount']}');
//   failureCount = int.parse('${json['failureCount']}');
//   multicastId = int.parse('${json['multicastId']}');
//   successCount = int.parse('${json['successCount']}');
//   results = <MessagingDeviceResult>[json['results'] as MessagingDeviceResult];
// }
}

/// Interface representing the server response from the
/// [link messaging.Messaging.sendToDeviceGroup `sendToDeviceGroup()`] method.

/// See
/// [Send messages to device groups](/docs/cloud-messaging/send-message?authuser=0#send_messages_to_device_groups)
/// for code samples and detailed documentation.

class MessagingDeviceGroupResponse {
  MessagingDeviceGroupResponse(this.successCount, this.failureCount, this.failedRegistrationTokens);

  MessagingDeviceGroupResponse.fromJson(Map<dynamic, dynamic> json)
      : successCount = int.parse('${json['successCount']}'),
        failureCount = int.parse('${json['failureCount']}'),
        failedRegistrationTokens = <String>['${json['failedRegistrationTokens']}'];

  /// The number of messages that could not be processed and resulted in an error.

  int successCount;

  /// The number of messages that could not be processed and resulted in an error.

  int failureCount;

  /// An array of registration tokens that failed to receive the message.

  List<String> failedRegistrationTokens;
}

/// Interface representing the server response from the legacy
/// [link messaging.Messaging.sendToTopic `sendToTopic()`] method.

/// See
/// [Send to a topic](/docs/cloud-messaging/admin/send-messages#send_to_a_topic)
/// for code samples and detailed documentation.

class MessagingTopicResponse {
  MessagingTopicResponse(this.messageId);

  MessagingTopicResponse.fromJson(Map<dynamic, dynamic> json): messageId = int.parse('${json['messageId']}');

  /// The message ID for a successfully received request which FCM will attempt to
  /// deliver to all subscribed devices.

  int messageId;
}

/// Interface representing the server response from the legacy
/// [link messaging.Messaging.sendToCondition `sendToCondition()`] method.

/// See
/// [Send to a condition](/docs/cloud-messaging/admin/send-messages#send_to_a_condition)
/// for code samples and detailed documentation.

class MessagingConditionResponse {
  MessagingConditionResponse(this.messageId);

  MessagingConditionResponse.fromJson(Map<dynamic, dynamic> json): messageId = int.parse('${json['messageId']}');

  /// The message ID for a successfully received request which FCM will attempt to
  /// deliver to all subscribed devices.

  int messageId;
}

/// Interface representing the server response from the
/// [link messaging.Messaging.subscribeToTopic `subscribeToTopic()`] and
/// [link messaging.Messaging.unsubscribeFromTopic `unsubscribeFromTopic()`] methods.

/// See
/// [Manage topics from the server](/docs/cloud-messaging/manage-topics)
/// for code samples and detailed documentation.

class MessagingTopicManagementResponse {
  MessagingTopicManagementResponse(this.failureCount, this.successCount, this.errors);

  /// The number of registration tokens that could not be subscribed to the topic
  /// and resulted in an error.

  int failureCount;

  /// The number of registration tokens that were successfully subscribed to the
  /// topic.

  int successCount;

  /// An array of errors corresponding to the provided registration token(s). The
  /// length of this array will be equal to [`failureCount`](#failureCount).

  List<FirebaseArrayIndexError> errors;
}

/// Interface representing the server response from the [link messaging.Messaging.sendAll `sendAll()`] and
/// [link messaging.Messaging.sendMulticast `sendMulticast()`] methods.

class BatchResponse {
  BatchResponse(this.responses, this.successCount, this.failureCount);

  /// An array of responses, each corresponding to a message.

  List<SendResponse> responses;

  /// The number of messages that were successfully handed off for sending.

  int successCount;

  /// The number of messages that resulted in errors when sending.

  int failureCount;
}

/// Interface representing the status of an individual message that was sent as
/// part of a batch request.

class SendResponse {
  SendResponse(this.success, {this.messageId, this.error});

  /// A boolean indicating if the message was successfully handed off to FCM or not.

  /// When true, the `messageId` attribute is guaranteed to be set. When
  /// false, the `error` attribute is guaranteed to be set.
  bool success;

  /// A unique message ID string, if the message was handed off to FCM for delivery.

  String? messageId;

  /// An error, if the message was not handed off to FCM successfully.

  FirebaseError? error;
}

class Messaging {
  /// The {@link app.App app} associated with the current `Messaging` service instance
  static const Messaging app = app.App;

  /// Sends the given message via FCM.
  ///
  /// @param message The message payload.
  /// @param dryRun Whether to send the message in the dry-run
  ///   (validation only) mode.
  /// @return A promise fulfilled with a unique message ID
  ///   string after the message has been successfully handed off to the FCM
  ///   service for delivery.

  Future<String>? send(Message message, bool? dryRun) {}

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

  Future<BatchResponse>? sendAll(List<Message> messages, bool? dryRun) {}

  /// Sends the given multicast message to all the FCM registration tokens
  /// specified in it.
  ///
  /// This method uses the `sendAll()` API under the hood to send the given
  /// message to all the target recipients. The responses list obtained from the
  /// return value corresponds to the order of tokens in the `MulticastMessage`.
  /// An error from this method indicates a total failure -- i.e. the message was
  /// not sent to any of the tokens in the list. Partial failures are indicated by
  /// a `BatchResponse` return value.
  ///
  /// @param message A multicast message
  ///   containing up to 500 tokens.
  /// @param dryRun Whether to send the message in the dry-run
  ///   (validation only) mode.
  /// @return A Promise fulfilled with an object representing the result of the
  ///   send operation.

  Future<BatchResponse>? sendMulticastMessage(MulticastMessage message, bool? dryRun) {}

  /// Sends an FCM message to a single device corresponding to the provided
  /// registration token.
  ///
  /// See
  /// [Send to individual devices](/docs/cloud-messaging/admin/legacy-fcm#send_to_individual_devices)
  /// for code samples and detailed documentation. Takes either a
  /// `registrationToken` to send to a single device or a
  /// `registrationTokens` parameter containing an array of tokens to send
  /// to multiple devices.
  ///
  /// @param registrationToken A device registration token or an array of
  ///   device registration tokens to which the message should be sent.
  /// @param payload The message payload.
  /// @param options Optional options to
  ///   alter the message.
  ///
  /// @return A promise fulfilled with the server's response after the message
  ///   has been sent.

  Future<MessagingDevicesResponse>? sendToDevice(
      List<String> registrationToken, MessagingPayload payload, MessagingOptions? options) {}

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

  Future<MessagingDeviceGroupResponse>? sendToDeviceGroup(
      String notificationKey, MessagingPayload payload, MessagingOptions? options) {}

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

  Future<MessagingTopicResponse>? sendToTopic(String topic, MessagingPayload payload, MessagingOptions? options) {}

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

  Future<MessagingConditionResponse>? sendToConditions(
      String conditions, MessagingPayload payload, MessagingOptions? options) {}

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

  Future<MessagingTopicManagementResponse>? subscribeToTopic(List<String> registrationTokens, String topic) {}

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

  Future<MessagingTopicManagementResponse>? unsubscribeFromTopic(List<String> registrationTokens, String topic) {}
}
