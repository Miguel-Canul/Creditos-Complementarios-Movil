// Nombres Significativos: Enumeración para representar los meses del año.
enum Meses {
  // Principio Abierto/Cerrado: Fácilmente extensible si se necesitan más propiedades (e.g., abreviatura).
  enero(1, 'Enero'),
  febrero(2, 'Febrero'),
  marzo(3, 'Marzo'),
  abril(4, 'Abril'),
  mayo(5, 'Mayo'),
  junio(6, 'Junio'),
  julio(7, 'Julio'),
  agosto(8, 'Agosto'),
  septiembre(9, 'Septiembre'),
  octubre(10, 'Octubre'),
  noviembre(11, 'Noviembre'),
  diciembre(12, 'Diciembre');

  // Propiedades
  final int valor;
  final String nombre;

  // Constructor constante
  const Meses(this.valor, this.nombre);
}