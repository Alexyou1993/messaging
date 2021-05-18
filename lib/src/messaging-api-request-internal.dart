import 'dart:io';

import 'package:messaging/src/batch-request-internal.dart';
import 'package:messaging/src/messaging-errors-internal.dart';
import 'package:messaging/src/utils/api-request/index.dart';

import 'batch-request-internal.dart';
import 'index.dart';

const String sdkVersion = '9.7.0';

const Duration FIREBASE_MESSAGING_TIMEOUT = Duration(seconds: 10);
const String FIREBASE_MESSAGING_BATCH_URL = 'https://fcm.googleapis.com/batch';
const String FIREBASE_MESSAGING_HTTP_METHOD = 'POST';
const Map<String, String> FIREBASE_MESSAGING_HEADERS = <String, String>{
  'X-Firebase-Client': 'fire-admin-node/$sdkVersion}',
};
const Map<String, String> LEGACY_FIREBASE_MESSAGING_HEADERS = <String, String>{
  'X-Firebase-Client': 'fire-admin-node/$sdkVersion',
  'access_token_auth': 'true',
};

/// Class that provides a mechanism to send requests to the Firebase Cloud Messaging backend.

class FirebaseMessagingRequestHandler {
  FirebaseMessagingRequestHandler(dynamic app) {
    httpClient = AuthorizedHttpClient(app);
    batchClient = BatchRequestClient(httpClient: httpClient!, batchUrl: FIREBASE_MESSAGING_BATCH_URL);
  }

  AuthorizedHttpClient? httpClient;
  BatchRequestClient? batchClient;

  /// Invokes the request handler with the provided request data.
  ///
  /// @param {string} host The host to which to send the request.
  /// @param {string} path The path to which to send the request.
  /// @param {object} requestData The request data.
  /// @return {Promise<object>} A promise that resolves with the response.

  Future<Map<dynamic, dynamic>> invokeRequestHandler(String host, String path, Map<String, dynamic> requestData) async {
    try {
      final HttpRequestConfig request = HttpRequestConfig(
        method: FIREBASE_MESSAGING_HTTP_METHOD,
        url: 'https://$host$path',
        data: requestData,
        headers: LEGACY_FIREBASE_MESSAGING_HEADERS,
        timeout: FIREBASE_MESSAGING_TIMEOUT,
      );

      final HttpResponse response = await httpClient!.send(request);
      return response.data!;
    } catch (err) {
      if (err is HttpError) {
        throw createFirebaseError(err);
      }
      rethrow;
    }
  }

  /// Sends the given array of sub requests as a single batch to FCM, and parses the result into
  /// a BatchResponse object.
  ///
  /// @param {SubRequest[]} requests An array of sub requests to send.
  /// @return {Future<BatchResponse>} A future that resolves when the send operation is complete.

  Future<BatchResponse> sendBatchRequest(List<SubRequest> requests) async{
  try{
    final List<HttpResponse> responses = await batchClient!.send(requests);
    final List<SendResponse> sendResponse = responses.map((HttpResponse part) => _buildSendResponse(part)).toList();
    final int successCount = sendResponse.where((SendResponse resp) => resp.success).length;
    return BatchResponse(sendResponse, successCount, sendResponse.length - successCount);
  } catch(err) {
    if(err is HttpError) {
      throw createFirebaseError(err);
    }
    rethrow;
  }
}

  SendResponse _buildSendResponse(HttpResponse response) {
    final SendResponse result = SendResponse(response.status == 200);
    if(result.success) {
      result.messageId = response.data!['name'].toString();
    } else {
      result.error = createFirebaseError(HttpError(response));
    }
    return result;
  }
}