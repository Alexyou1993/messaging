import 'dart:io';

import 'package:messaging/src/batch-request-internal.dart';
import 'package:messaging/src/messaging-errors-internal.dart';
import 'package:messaging/src/utils/api_request/index.dart';

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


class FirebaseMessagingRequestHandler {
  FirebaseMessagingRequestHandler(dynamic app) {
    httpClient = AuthorizedHttpClient(app);
    batchClient = BatchRequestClient(httpClient: httpClient!, batchUrl: FIREBASE_MESSAGING_BATCH_URL);
  }

  AuthorizedHttpClient? httpClient;
  BatchRequestClient? batchClient;



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