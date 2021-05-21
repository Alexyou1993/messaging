import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:messaging/src/utils/api-request/index.dart';
import 'package:messaging/src/utils/error.dart';

const String PART_BOUNDARY = '__EDN_OF_PART__';
const Duration TEN_SECONDS_IN_MILLIS = Duration(seconds: 10);

/// Represents a request that can be sent as part of an HTTP batch request.
class SubRequest {
  SubRequest({required this.url, required this.body, this.headers});

  final String url;
  final Map<String, dynamic> body;
  Map<String, dynamic>? headers;
}

/// An HTTP client that can be used to make batch requests. This client is not tied to any service
/// (FCM or otherwise). Therefore it can be used to make batch requests to any service that allows
/// it. If this requirement ever arises we can move this implementation to the utils module
/// where it can be easily shared among other modules.

class BatchRequestClient {
  /// @param {HttpClient} httpClient The client that will be used to make HTTP calls.
  /// @param {String} batchUrl The URL that accepts batch requests.
  /// @param {Map<String, String>} commonHeaders Optional headers that will be included in all requests.
  ///
  /// @constructor

  const BatchRequestClient({
    required this.httpClient,
    required this.batchUrl,
    this.commonHeaders = const <String, String>{},
  });

  final HttpClient httpClient;
  final String batchUrl;
  final Map<String, String>? commonHeaders;

  /// Sends the given list of sub requests as a single batch, and parses the results into an list
  /// of HttpResponse objects.
  ///
  /// @param {List<SubRequest>} requests An list of sub requests to send.
  /// @return {Future<List<HttpResponse>>} A future is return when the send operation is complete.

  Future<List<HttpResponse>> send(List<SubRequest> requests) async {
    if (commonHeaders != null) {
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

  /// Creates a single part in a multipart HTTP request body. The part consists of several headers
  /// followed by the serialized sub request as the body. As per the requirements of the FCM batch
  /// API, sets the content-type header to application/http, and the content-transfer-encoding to
  /// binary.
  ///
  /// @param {SubRequest} request A sub request that will be used to populate the part.
  /// @param {string} boundary Multipart boundary string.
  /// @param {number} idx An index number that is used to set the content-id header.
  /// @return {string} The part as a string that can be included in the HTTP body.

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

  /// Serializes a sub request into a string that can be embedded in a multipart HTTP request. The
  /// format of the string is the wire format of a typical HTTP request, consisting of a header and a
  /// body.
  ///
  /// @param request {SubRequest} The sub request to be serialized.
  /// @return {string} String representation of the SubRequest.

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
