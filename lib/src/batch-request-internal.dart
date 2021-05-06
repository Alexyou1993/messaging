import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:messaging/src/utils/api_request/index.dart';
import 'package:messaging/src/utils/error.dart';

const String PART_BOUNDARY = '__EDN_OF_PART__';
const Duration TEN_SECONDS_IN_MILLIS = Duration(seconds: 10);

/// Represents a request that can be sent as part of an HTTP batch request.
class SubRequest {
  SubRequest(this.url, this.body, this.headers);

  final String url;
  final Object body;
  Map<String, dynamic>? headers;
}

class BatchRequestClient {
  const BatchRequestClient({
    required this.httpClient,
    required this.batchUrl,
    this.commonHeaders = const <String, String>{},
  });

  final HttpClient httpClient;
  final String batchUrl;
  final Map<String, String> commonHeaders;

  Future<List<HttpResponse>> send(List<SubRequest> requests) async {
    if(commonHeaders != null) {
      requests = requests.map<SubRequest>((SubRequest req) {
        req.headers!.addAll(<String, dynamic>{...commonHeaders!, ...req.headers!});
        return req;
      }).toList();
    }
    const Map<String, String> requestHeaders = <String, String>{
      'Content-Type': 'multipart/mixed; boundary=$PART_BOUNDARY',
    };

    final HttpRequestConfig request = HttpRequestConfig(
      method: 'POST',
      url: batchUrl,
      data: _getMultipartPayload(requests),
      headers: <String, String>{...commonHeaders!, ...requestHeaders},
      timeout: TEN_SECONDS_IN_MILLIS,
    );

    final HttpResponse response = await httpClient.send(request);
    if (response.multipart == null) {
      throw FirebaseError.app(AppErrorCodes.INTERNAL_ERROR, 'Expected a multipart response.');
    }
    return response.multipart!.map((List<int> buff) => DefaultHttpResponse.fromBytesResponse(buff, request)).toList();
  }

  List<int> _getMultipartPayload(List<SubRequest> requests) {
    final StringBuffer buffer = StringBuffer();
    for (int idx = 0; idx < requests.length; idx++) {
      final SubRequest request = requests[idx];
      createPart(request, PART_BOUNDARY, idx);
    }
    buffer.write('--$PART_BOUNDARY--\r\n');
    return utf8.encode('$buffer');
  }

  String createPart(SubRequest request, String boundary, int idx) {
    final String serializedRequest = serializeSubRequest(request);
    String part = '--$boundary\r\n';
    part += 'Content-Length: ${serializedRequest.length}\r\n';
    part += 'Content-Type: application/http\r\n';
    part += 'content-id: ${idx + 1}\r\n';
    part += 'content-transfer-encoding: binary\r\n';
    part += '\r\n';
    part += '$serializedRequest\r\n';
    return part;
  }

  String serializeSubRequest(SubRequest request) {
    final String requestBody = jsonEncode(request.body);
    String messagePayload = 'POST ${request.url} HTTP/1.1\r\n';
    messagePayload += 'Content-Length: ${requestBody.length}\r\n';
    messagePayload += 'Content-Type: application/json; charset=UTF-8\r\n';
    if (request.headers != null) {
      for (final String key in request.headers!.keys) {
        messagePayload += '$key: ${request.headers![key]}\r\n';
      }
    }
    messagePayload += '\r\n';
    messagePayload += requestBody;
    return messagePayload;
  }
}
