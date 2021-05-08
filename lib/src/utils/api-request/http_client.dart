part of api_request;

class HttpClient {
  HttpClient([RetryConfig? retry]) : _retry = retry ?? RetryConfig();

  final RetryConfig? _retry;

  /// Sends an HTTP request to a remote server. If the server responds with a successful response (2xx), the returned
  /// promise resolves with an HttpResponse. If the server responds with an error (3xx, 4xx, 5xx), the future throws
  /// with an HttpError. In case of all other errors, the future throws a [FirebaseError.app]. If a request fails
  /// due to a low-level network error, transparently retries the request once before throwing.
  ///
  /// If the request data is specified as an Map, it will be serialized into a JSON string. The application/json
  /// content-type header will also be automatically set in this case. For all other payload types, the content-type
  /// header should be explicitly set by the caller. To send a JSON leaf value (e.g. "foo", 5), parse it into JSON,
  /// and pass as a string or a [Uint8List] along with the appropriate content-type header.
  Future<HttpResponse> send(HttpRequestConfig config) {
    return sendWithRetry(config);
  }

  /// Sends an HTTP request. In the event of an error, retries the HTTP request according to the
  /// RetryConfig set on the HttpClient.
  ///
  /// [config] HTTP request to be sent.
  /// [retryAttempts] Number of retries performed up to now.
  /// returns a [HttpResponse] with the response details.
  Future<HttpResponse> sendWithRetry(HttpRequestConfig config, [int retryAttempts = 0]) async {
    try {
      final LowLevelResponse resp = await AsyncHttpCall(config);
      return _createHttpResponse(resp);
    } on LowLevelError catch (err) {
      final RetryConfig? _retry = this._retry;
      final LowLevelResponse? response = err.response;

      final List<dynamic> result = _getRetryDelayMillis(retryAttempts, err);
      final Duration delay = result[0] as Duration;
      final bool canRetry = result[1] as bool;

      if (canRetry && _retry != null && delay <= _retry.maxDelay) {
        await _waitForRetry(delay);
        return sendWithRetry(config, retryAttempts + 1);
      }

      if (response != null) {
        throw HttpError(_createHttpResponse(response));
      } else if (err.code == 'ETIMEDOUT') {
        throw FirebaseError.app(
          AppErrorCodes.NETWORK_TIMEOUT,
          'Error while making request: ${err.message}.',
        );
      } else {
        throw FirebaseError.app(
          AppErrorCodes.NETWORK_ERROR,
          'Error while making request: ${err.message}. Error code: ${err.code}',
        );
      }
    }
  }

  HttpResponse _createHttpResponse(LowLevelResponse resp) {
    if (resp.multipart != null) {
      return MultipartHttpResponse(resp);
    } else {
      return DefaultHttpResponse(resp);
    }
  }

  Future<void> _waitForRetry(Duration delay) async {
    if (delay > Duration.zero) {
      return Future<void>.delayed(delay);
    } else {
      return Future<void>.value();
    }
  }

  List<dynamic> _getRetryDelayMillis(int retryAttempts, LowLevelError err) {
    if (!_isRetryEligible(retryAttempts, err)) {
      return <dynamic>[0, false];
    }

    final LowLevelResponse? response = err.response;
    final List<String>? retryAfterHeader = response?.headers['retry-after'];
    if (response != null && retryAfterHeader != null && retryAfterHeader.isNotEmpty) {
      final Duration delayMillis = parseRetryAfterIntoMillis(retryAfterHeader.first);
      if (delayMillis > Duration.zero) {
        return <dynamic>[delayMillis, true];
      }
    }

    return <dynamic>[backOffDelayMillis(retryAttempts), true];
  }

  bool _isRetryEligible(int retryAttempts, LowLevelError err) {
    final RetryConfig? _retry = this._retry;
    final LowLevelResponse? response = err.response;

    if (_retry == null) {
      return false;
    } else if (retryAttempts >= _retry.maxRetries) {
      return false;
    } else if (response != null) {
      return _retry.statusCodes.contains(response.status);
    } else if (err.code != null) {
      return _retry.ioErrorCodes.contains(err.code);
    } else {
      return false;
    }
  }

  /// Parses the Retry-After HTTP header as a duration.
  ///
  /// Return value is [Duration.zero] if the Retry-After header contains
  /// an expired timestamp or otherwise malformed.
  Duration parseRetryAfterIntoMillis(String retryAfter) {
    final int? delaySeconds = int.tryParse(retryAfter);
    if (delaySeconds != null) {
      return Duration(seconds: delaySeconds);
    }

    final DateTime? date = DateTime.tryParse(retryAfter);
    if (date != null) {
      final Duration difference = date.difference(DateTime.now());

      if (difference < Duration.zero) {
        return Duration.zero;
      } else {
        return difference;
      }
    }
    return Duration.zero;
  }

  Duration backOffDelayMillis(int retryAttempts) {
    if (retryAttempts == 0) {
      return Duration.zero;
    }

    final RetryConfig? _retry = this._retry;
    if (_retry == null) {
      throw FirebaseError.app(AppErrorCodes.INTERNAL_ERROR, 'Expected _retry to exist.');
    }

    final double backOffFactor = _retry.backOffFactor;
    final num delayInSeconds = pow(2, retryAttempts) * backOffFactor;
    final int value = min((delayInSeconds * 1000).toInt(), _retry.maxDelay.inMilliseconds);
    return Duration(milliseconds: value);
  }
}

class AuthorizedHttpClient extends HttpClient {
  AuthorizedHttpClient(this.app);

  final FirebaseApp app;

  @override
  Future<HttpResponse> send(HttpRequestConfig config) async {
    final FirebaseAccessToken token = await app.getToken();
    config.headers['Authorization'] = 'Bearer ${token.accessToken}';

    final String? httpAgent = app.options.httpAgent;
    if (httpAgent != null) {
      config = config.copyWith(httpAgent: httpAgent);
    }
    return super.send(config);
  }
}
