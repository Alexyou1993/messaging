part of api_request;

/// Configuration for constructing a new HTTP request
class HttpRequestConfig {
  HttpRequestConfig({
    required this.method,
    required this.url,
    Map<String, String>? headers,
    this.data,
    this.timeout,
    this.httpAgent,
  })  : assert(validMethods.contains(method)),
        headers = headers ?? <String, String>{};

  final String method;

  /// Target URL of the request. Should be a well-formed URL including protocol, hostname, port and path.
  final String url;

  final Map<String, String> headers;

  final dynamic? data;

  ///  Connect and read timeout for the outgoing request.
  final Duration? timeout;

  final String? httpAgent;

  Uint8List? buildEntity() {
    Uint8List? entity;
    if (!hasEntity || !isEntityEnclosingRequest) {
      return entity;
    }

    final dynamic data = this.data;
    if (data is List<int>) {
      entity = Uint8List.fromList(data);
    } else if (data is Map) {
      entity = Uint8List.fromList(utf8.encode(jsonEncode(this.data)));
      headers['content-type'] ??= 'application/json;charset=utf-8';
    } else if (data is String) {
      entity = Uint8List.fromList(utf8.encode(data));
    } else {
      throw ArgumentError('Request data must be a string, a Uint8List or a json serializable Map');
    }

    // Add Content-Length header if data exists.
    headers['content-length'] = '${entity.length}';
    return entity;
  }

  Uri buildUrl() {
    final String fullUrl = urlWithProtocol;
    Uri uri = Uri.parse(fullUrl);
    final int port = uri.hasPort ? uri.port : uri.isScheme('https') ? 443 : 80;
    uri = uri.replace(port: port);

    if (!hasEntity || isEntityEnclosingRequest) {
      return uri;
    }

    final dynamic data = this.data;
    if (data != null && data is Map<String, dynamic>) {
      return uri.replace(queryParameters: <String, dynamic>{...uri.queryParameters, ...data});
    } else {
      return Uri.parse(fullUrl);
    }
  }

  String get urlWithProtocol {
    if (url.startsWith('https://') || url.startsWith('https://')) {
      return url;
    }
    return 'https://$url';
  }

  bool get hasEntity => data != null;

  bool get isEntityEnclosingRequest {
    // GET and HEAD requests do not support entity (body) in request.
    return method != 'GET' && method != 'HEAD';
  }

  HttpRequestConfig copyWith({String? httpAgent}) {
    return HttpRequestConfig(
      method: method,
      url: url,
      headers: headers,
      data: data,
      timeout: timeout,
      httpAgent: httpAgent ?? this.httpAgent,
    );
  }
}
