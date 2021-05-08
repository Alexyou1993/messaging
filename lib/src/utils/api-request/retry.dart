part of api_request;


/// Specifies how failing HTTP requests should be retried.
class RetryConfig {
  /// Default retry configuration for HTTP requests. Retries up to 4 times on connection reset and timeout errors
  /// as well as HTTP 503 errors. Exposed as a function to ensure that every HttpClient gets its own RetryConfig
  /// instance.
  RetryConfig({
    this.maxRetries = 4,
    this.statusCodes = const <int>[503],
    this.ioErrorCodes = const <String>['ECONNRESET', 'ETIMEDOUT'],
    this.backOffFactor = 0.5,
    this.maxDelay = const Duration(seconds: 60),
  }) {
    if (maxRetries < 0) {
      throw FirebaseError.app(
        AppErrorCodes.INVALID_ARGUMENT,
        'maxRetries must be a non-negative integer',
      );
    }
    if (backOffFactor < 0) {
      throw FirebaseError.app(
        AppErrorCodes.INVALID_ARGUMENT,
        'backOffFactor must be a non-negative number',
      );
    }
    if (maxDelay < Duration.zero) {
      throw FirebaseError.app(
        AppErrorCodes.INVALID_ARGUMENT,
        'maxDelay must be a non-negative duration',
      );
    }
  }

  /// Maximum number of times to retry a given request.
  final int maxRetries;

  /// HTTP status codes that should be retried.
  final List<int> statusCodes;

  /// Low-level I/O error codes that should be retried.
  final List<String> ioErrorCodes;

  /// The multiplier for exponential back off. The retry delay is calculated in seconds using the formula
  /// `(2^n) * backOffFactor`, where n is the number of retries performed so far. When the backOffFactor is set
  /// to 0, retries are not delayed. When the backOffFactor is 1, retry duration is doubled each iteration.
  final double backOffFactor;

  /// Maximum duration to wait before initiating a retry.
  final Duration maxDelay;
}
