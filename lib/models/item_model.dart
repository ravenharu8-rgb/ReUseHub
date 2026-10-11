class ReuseItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final String condition;
  final String imagePath;
  final String locationZone;
  final double estimatedValue;
  final String userId;
  final String userName;
  bool isClaimed;

  ReuseItem({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.condition,
    required this.imagePath,
    this.locationZone = 'Main Campus',
    required this.estimatedValue,
    this.userId = '',
    this.userName = 'Campus Student',
    this.isClaimed = false,
  });
}