class Recipe {
  final String title;
  final String description;
  final String imageUrl;
  final String difficulty;
  final List<String> ingredients;
  final List<String> steps;
  bool isFavorite;

  Recipe({
    required this.title,
    required this.description,
    required this.imageUrl,
    this.difficulty = '보통',
    this.ingredients = const [],
    this.steps = const [],
    this.isFavorite = false,
  });
}