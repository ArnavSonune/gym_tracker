import 'package:hive/hive.dart';

part 'achievement_model.g.dart';

@HiveType(typeId: 8)
class AchievementModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String iconName; // Icon identifier

  @HiveField(4)
  bool isUnlocked;

  @HiveField(5)
  DateTime? unlockedAt;

  @HiveField(6)
  int xpReward; // Bonus XP for unlocking achievement

  @HiveField(7)
  String rarity; // 'common', 'rare', 'epic', 'legendary'

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    this.isUnlocked = false,
    this.unlockedAt,
    this.xpReward = 50,
    this.rarity = 'common',
  });

  AchievementModel copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? xpReward,
    String? rarity,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      xpReward: xpReward ?? this.xpReward,
      rarity: rarity ?? this.rarity,
    );
  }
}
