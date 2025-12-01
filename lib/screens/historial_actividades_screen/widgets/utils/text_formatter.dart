class TextFormatter {
  static String formatearCategoria(String categoria) {
    if (categoria.contains('#')) {
      return categoria.split('#').last;
    }
    return categoria;
  }

  static String formatearPeriodo(String periodo) {
    if (periodo.contains('#')) {
      return periodo.split('#').last;
    }
    return periodo;
  }
}
