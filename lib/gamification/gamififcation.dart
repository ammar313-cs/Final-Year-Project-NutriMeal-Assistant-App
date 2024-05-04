// ignore_for_file: avoid_print

class Nutripoints {
  String? username;
  int pointsM1;
  int pointsM2;

  int m2star;
  int totalStars;
  int totalPoints;

  Nutripoints({
    required this.username,
    this.pointsM1 = 0,
    this.pointsM2 = 0,
    this.m2star = 0,
    this.totalStars = 0,
    this.totalPoints = 100,
  });

  void pointsCosumeM1() {
    //to deduct 10 points for M1
    if (totalPoints >= 10) {
      pointsM1 += 5; // Adding 10 points for usage Module 1
      totalPoints -= 5; // Deducting total points accordingly
    }
  }

  void pointsCosumeM2() {
    //to deduct 10 points for M2
    if (totalPoints >= 10) {
      pointsM2 += 10; // Adding 10 points for usage Module 2
      totalPoints -= 10; // Deducting total points accordingly
    }
  }

  int alotstars(int pointsM1, int pointsM2) {
    if (pointsM1 == 10) {
      totalStars = 1;
      print("Game1 acc");
      return totalStars;
    } else if (pointsM1 == 20) {
      totalStars = 2;
      print("Game2 acc");

      return totalStars;
    } else if (pointsM1 == 30) {
      totalStars = 3;
      print("Game3 acc");

      return totalStars;
    } else if (pointsM1 == 40) {
      totalStars = 4;
      print("Game4 acc");

      return totalStars;
    } else if (pointsM1 == 45) {
      totalStars = 5;
      print("Game5 acc");

      return totalStars;
    } else {
      print("Game Null acc");

      return totalStars;
    }
  }

  int alotstarsM2(int pointsM2) {
    if (pointsM2 == 20) {
      m2star = 1;
      print("M2 Game1 acc");
      return m2star;
    } else if (pointsM2 == 40) {
      m2star = 2;
      print("M2  Game2 acc");

      return m2star;
    } else if (pointsM2 == 50) {
      m2star = 3;
      print("M2  Game3 acc");

      return m2star;
    } else if (pointsM2 == 60) {
      m2star = 4;
      print("M2  Game4 acc");

      return m2star;
    } else if (pointsM2 == 70) {
      m2star = 5;
      print("M2  Game5 acc");

      return m2star;
    } else {
      print("M2 Game Null acc");

      return m2star;
    }
  }
}
