class Workout {
  final String id;
  final String type;
  final DateTime date;
  final int durationMinutes;
  final int caloriesBurned;
  final List<String> participantAvatars;

  Workout({
    required this.id,
    required this.type,
    required this.date,
    required this.durationMinutes,
    required this.caloriesBurned,
    this.participantAvatars = const [],
  });

  String get formattedDuration => '$durationMinutes mins';
  String get formattedCalories => '$caloriesBurned kcal';

  // Dummy data for recent workouts
  static List<Workout> getDummyWorkouts() {
    return [
      Workout(
        id: '1',
        type: 'Running',
        date: DateTime(2024, 6, 1, 7, 0),
        durationMinutes: 30,
        caloriesBurned: 300,
        participantAvatars: [],
      ),
      Workout(
        id: '2',
        type: 'Running',
        date: DateTime(2024, 5, 30, 7, 0),
        durationMinutes: 30,
        caloriesBurned: 300,
        participantAvatars: [],
      ),
    ];
  }
}
