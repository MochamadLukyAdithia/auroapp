
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? code;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.code,
  });

  // ✅ Factory untuk success response
  factory ApiResponse.success({
    required String message,
    T? data,
    int code = 200,
  }) {
    return ApiResponse(
      success: true,
      message: message,
      data: data,
      code: code,
    );
  }

  // ✅ Factory untuk error response
  factory ApiResponse.error({
    required String message,
    int code = 500,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      data: null,
      code: code,
    );
  }
}