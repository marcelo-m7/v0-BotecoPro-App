/// Utilitário para converter tipos da API para tipos Dart
class ApiConverter {
  /// Converte para um int, lidando com diferentes formatos da API
  static int? toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return null;
      }
    }
    if (value is double) return value.toInt();
    return null;
  }

  /// Converte para um double, lidando com diferentes formatos da API
  static double? toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Converte para uma string
  static String? toStr(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }
  


  /// Converte um valor booleano da API (geralmente 'True' ou 'False')
  static bool toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    if (value is int || value is double) {
      return value > 0;
    }
    return false;
  }
}