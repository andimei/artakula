String _thousandSeparator(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );
}

/// Formats an integer as Rupiah with "Rp" prefix, e.g. "Rp1.000.000"
String formatRupiah(int value) {
  return "Rp${_thousandSeparator(value)}";
}

/// Formats an integer with thousand separators only, no "Rp" prefix
String formatNumber(int value) {
  return _thousandSeparator(value);
}
