// lib/core/utils.dart
class Utils {
  static String removeTrailingZeros(double value) {
    return value.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  static String formatSummary({
    required String name,
    double? amount,
    String? unit,
    double? quantity,
    String? form,
    String? time,
    List<String>? days,
    String? calculatedDose,
  }) {
    final parts = <String>[];
    if (amount != null && amount > 0) {
      parts.add('${amount.toInt()} x $amount${unit ?? ''}');
    }
    if (name.isNotEmpty) parts.add(name);
    if (form != null) parts.add(form);
    if (quantity != null && quantity > 0 && amount != null) {
      final total = amount * quantity;
      if (total > 0) parts.add('(${total}${unit ?? ''} total)');
    }
    if (time != null && time.isNotEmpty) parts.add('at $time');
    if (days != null && days.isNotEmpty) parts.add('on ${days.join(', ')}');
    if (calculatedDose != null) parts.add('($calculatedDose)');
    return parts.isEmpty ? 'No details specified' : parts.join(' ');
  }
}