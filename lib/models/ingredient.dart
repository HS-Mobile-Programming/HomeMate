class Ingredient {
  final String id;
  final String name;
  final int quantity;
  final String expiryTime;

  Ingredient({
    required this.id,
    required this.name,
    this.quantity = 1,
    required this.expiryTime,
  });
}