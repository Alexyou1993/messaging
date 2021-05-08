part of api_request;

class AsyncHttpCall extends DelegatingFuture<LowLevelResponse> {
  factory AsyncHttpCall(HttpRequestConfig config) {
    final Completer<LowLevelResponse> completer = Completer<LowLevelResponse>();

    final Uint8List? entity = config.buildEntity();
    final io.HttpClient client = io.HttpClient()
      ..userAgent = config.httpAgent
      ..autoUncompress = true
      ..connectionTimeout = config.timeout;

    final AsyncHttpCall call = AsyncHttpCall._(completer, config, entity, client);
    call._execute();
    return call;
  }

  AsyncHttpCall._(this._completer, this._config, this._entity, this._client) : super(_completer.future);

  final Completer<LowLevelResponse> _completer;
  final HttpRequestConfig _config;
  final Uint8List? _entity;
  final io.HttpClient _client;

  Future<void> _execute() async {
    final io.HttpClientRequest request = await _client.openUrl(_config.method, _config.buildUrl());
    _config.headers.forEach(request.headers.add);
    request.add(_entity ?? <int>[]);

    try {
      final io.HttpClientResponse response = await request.close();
      _handleResponse(response, request);
    } catch (e, s) {
      _enhanceAndThrow(e, s, null, request);
    }
  }

  Future<void> _handleResponse(io.HttpClientResponse response, io.HttpClientRequest request) async {
    final Map<String, List<String>> headers = <String, List<String>>{};
    response.headers.forEach((String name, List<String> values) => headers[name] = values);

    LowLevelResponse lowLevelResponse = LowLevelResponse(
      status: response.statusCode,
      headers: headers,
      request: request,
      config: _config,
    );

    final String? boundary = _getMultipartBoundary(response.headers);

    if (boundary != null) {
      final List<Uint8List> data = await _handleMultipartResponse(response, boundary) //
          .catchError((dynamic error, StackTrace stackTrace) =>
          _enhanceAndThrow(error, stackTrace, null, request, lowLevelResponse));

      lowLevelResponse = lowLevelResponse.copyWith(multipart: data);
    } else {
      final String data = await _handleRegularResponse(response) //
          .catchError((dynamic error, StackTrace stackTrace) =>
          _enhanceAndThrow(error, stackTrace, null, request, lowLevelResponse));

      lowLevelResponse = lowLevelResponse.copyWith(data: data);
    }

    _finalizeResponse(lowLevelResponse);
  }

  /// Extracts multipart boundary from the HTTP header. The content-type header of a multipart
  /// response has the form 'multipart/subtype; boundary=string'.
  ///
  /// If the content-type header does not exist, or does not start with
  /// 'multipart/', then null will be returned.
  String? _getMultipartBoundary(io.HttpHeaders headers) {
    final io.ContentType? contentType = headers.contentType;
    if (contentType == null || contentType.primaryType != 'multipart') {
      return null;
    }

    return contentType.parameters['boundary'];
  }

  Future<List<Uint8List>> _handleMultipartResponse(io.HttpClientResponse response, String boundary) async {
    return response //
        .transform(MimeMultipartTransformer(boundary))
        .flatMap((MimeMultipart event) => event)
        .map((List<int> event) => Uint8List.fromList(event))
        .toList();
  }

  Future<String> _handleRegularResponse(io.HttpClientResponse response) async {
    return response //
        .transform(const Utf8Decoder())
        .join();
  }

  void _finalizeResponse(LowLevelResponse response) {
    if (response.status >= 200 && response.status < 300) {
      _completer.complete(response);
    } else {
      _rejectWithError('Request failed with status code ${response.status}', null, null, response.request, response);
    }
  }

  /// Creates a new error from the given message, and enhances it with other information available.
  /// Then the promise associated with this HTTP call is rejected with the resulting error.
  void _rejectWithError(
      String message,
      StackTrace? stackTrace, [
        String? code,
        io.HttpClientRequest? request,
        LowLevelResponse? response,
      ]) {
    final StateError error = StateError(message);
    _enhanceAndThrow(error, stackTrace, code, request, response);
  }

  void _enhanceAndThrow(
      dynamic error,
      StackTrace? stackTrace, [
        String? code,
        io.HttpClientRequest? request,
        LowLevelResponse? response,
      ]) {
    _completer.completeError(_enhanceError(error, code, request, response), stackTrace);
  }

  LowLevelError _enhanceError(dynamic error, String? code, io.HttpClientRequest? request, LowLevelResponse? response) {
    String message;
    if (error is io.SocketException && error.message.startsWith('HTTP connection timed out')) {
      code = 'ETIMEDOUT';
      message = 'timeout of $timeout exceeded';
    } else {
      try {
        message = '${error.message}';
      } catch (_) {
        message = '$error';
      }
    }

    return LowLevelError(
      message: message,
      config: _config,
      code: code,
      request: request,
      response: response,
    );
  }
}
