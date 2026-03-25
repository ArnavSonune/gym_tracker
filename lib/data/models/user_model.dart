import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int totalXP;

  @HiveField(3)
  int currentLevel;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  double? startingWeight;

  @HiveField(6)
  double? targetWeight;

  @HiveField(7)
  int? age;

  @HiveField(8)
  double? heightCm;

  @HiveField(9)
  bool isMale;

  // ── Auth fields (added for login/register flow) ──────────────────────────
  @HiveField(10)
  String? passwordHash; // SHA-256 hex of the user's password

  @HiveField(11)
  bool isLoggedIn; // persist session — user stays logged in across app restarts

  UserModel({
    required this.id,
    required this.name,
    this.totalXP = 0,
    this.currentLevel = 1,
    required this.createdAt,
    this.startingWeight,
    this.targetWeight,
    this.age,
    this.heightCm,
    this.isMale = true,
    this.passwordHash,
    this.isLoggedIn = false,
  });

  UserModel copyWith({
    String? id,
    String? name,
    int? totalXP,
    int? currentLevel,
    DateTime? createdAt,
    double? startingWeight,
    double? targetWeight,
    int? age,
    double? heightCm,
    bool? isMale,
    String? passwordHash,
    bool? isLoggedIn,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      totalXP: totalXP ?? this.totalXP,
      currentLevel: currentLevel ?? this.currentLevel,
      createdAt: createdAt ?? this.createdAt,
      startingWeight: startingWeight ?? this.startingWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      isMale: isMale ?? this.isMale,
      passwordHash: passwordHash ?? this.passwordHash,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}