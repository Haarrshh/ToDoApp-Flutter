class ApiEndpoints {
  ApiEndpoints._();

  static const String todos = '/todos';
  static String todo(int id) => '/todos/$id';
}
