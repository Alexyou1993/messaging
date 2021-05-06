part of api_request;

class LowLevelResponse {
  LowLevelResponse({
    required this.status,
    required this.headers,
    this.request,
    this.data,
    this.multipart,
    required this.config,
  });

  final int status;

  final Map<String, List<String>> headers;

  final io.HttpClientRequest? request;

  final String? data;

  final List<Uint8List>? multipart;

  final HttpRequestConfig config;

  LowLevelResponse copyWith({List<Uint8List>? multipart, String? data}) {
    return LowLevelResponse(
      status: status,
      headers: headers,
      request: request,
      data: data ?? this.data,
      multipart: multipart ?? this.multipart,
      config: config,
    );
  }
}

class LowLevelError extends StateError {
  LowLevelError({
    required String message,
    required this.config,
    this.code,
    this.request,
    this.response,
  }) : super(message);

  final HttpRequestConfig config;
  final String? code;
  final io.HttpClientRequest? request;
  final LowLevelResponse? response;
}

class HttpError extends StateError {
  HttpError(this.response) : super('Server responded with status ${response.status}.');

  final HttpResponse response;
}
