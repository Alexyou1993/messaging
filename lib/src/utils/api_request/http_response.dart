part of api_request;



/// Represents an HTTP response received from a remote server.
abstract class HttpResponse {
  HttpResponse._(this.status, this.headers, this.text);

  final int status;

  final Map<String, List<String>> headers;

  /// Response data as a raw string.
  final String? text;

  /// Response data as a parsed JSON object.
  Map<String, dynamic>? get data;

  /// For multipart responses, the payloads of individual parts.
  List<Uint8List>? get multipart {}

  /// Indicates if the response content is JSON-formatted or not. If true,
  /// data field can be used to retrieve the content as a parsed JSON object.
  bool get isJson;
}

class DefaultHttpResponse extends HttpResponse {
  DefaultHttpResponse(LowLevelResponse resp)
      : _request = '${resp.config.method} ${resp.config.url}',
        super._(resp.status, resp.headers, resp.data) {
    try {
      final String? data = resp.data;
      if (data == null) {
        throw FirebaseError.app(AppErrorCodes.INTERNAL_ERROR, 'HTTP response missing data.');
      }
      _parsedData = jsonDecode(data) as Map<String, dynamic>;
    } catch (err) {
      _parsedError = err;
    }
  }

  factory DefaultHttpResponse.fromBytesResponse(List<int> response, HttpRequestConfig config) {
    return DefaultHttpResponse.fromStringResponse(utf8.decode(response), config);
  }

  /// Parses a full HTTP response message containing both a header and a body.
  ///
  /// [response] The HTTP response to be parsed.
  /// [config] The request configuration that resulted in the HTTP response.
  /// Returns an object containing the parsed HTTP status, headers and the body.
  factory DefaultHttpResponse.fromStringResponse(String response, HttpRequestConfig config) {
    final int endOfHeaderPos = response.indexOf('\r\n\r\n');
    final List<String> headerLines = response.substring(0, endOfHeaderPos).split('\r\n');

    final String statusLine = headerLines[0];
    final String status = statusLine.trim().split(r'\s')[1];

    final Map<String, List<String>> headers = headerLines //
        .skip(1)
        .toList()
        .fold(<String, List<String>>{}, (Map<String, List<String>> map, String line) {
      final List<String> segments = line.split(':');
      final String name = segments[0].toLowerCase();
      final List<String> values = segments[1].split(';').map((String value) => value.trim()).toList();
      map[name] = values;
      return map;
    });

    String data = response.substring(endOfHeaderPos + 4);
    if (data.endsWith('\n')) {
      data = data.substring(0, data.length - 1);
    }
    if (data.endsWith('\r')) {
      data = data.substring(0, data.length - 1);
    }

    final int? statusCode = int.tryParse(status);
    if (statusCode == null) {
      throw ArgumentError('Malformed HTTP status line.');
    }

    final LowLevelResponse lowLevelResponse = LowLevelResponse(
      status: statusCode,
      headers: headers,
      data: data,
      config: config,
    );

    return DefaultHttpResponse(lowLevelResponse);
  }

  final String _request;

  Map<String, dynamic>? _parsedData;

  Object? _parsedError;

  @override
  Map<String, dynamic>? get data {
    if (isJson) {
      return _parsedData;
    }

    throw FirebaseError.app(
      AppErrorCodes.UNABLE_TO_PARSE_RESPONSE,
      'Error while parsing response data: "$_parsedError". '
          'Raw server response: "$text". Status code: "$status". '
          'Outgoing request: "$_request."',
    );
  }

  @override
  bool get isJson => _parsedData != null;
}

/// Represents a multipart HTTP response. Parts that constitute the response body can be accessed
/// via the multipart getter. Getters for text and data throw errors.
class MultipartHttpResponse extends HttpResponse {
  MultipartHttpResponse(LowLevelResponse resp)
      : multipart = resp.multipart,
        super._(resp.status, resp.headers, null);

  @override
  String? get text {
    throw FirebaseError.app(
      AppErrorCodes.UNABLE_TO_PARSE_RESPONSE,
      'Unable to parse multipart payload as text',
    );
  }

  @override
  final List<Uint8List>? multipart;

  @override
  Map<String, dynamic>? get data {
    throw FirebaseError.app(
      AppErrorCodes.UNABLE_TO_PARSE_RESPONSE,
      'Unable to parse multipart payload as JSON',
    );
  }

  @override
  bool get isJson => false;
}
