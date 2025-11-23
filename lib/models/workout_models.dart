import 'dart:convert';

/// Exercise model
class Exercise {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final int restSeconds;
  final String? notes;
  int completedSets;
  bool isCompleted;

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.notes,
    this.completedSets = 0,
    this.isCompleted = false,
  });

  double get progress => sets > 0 ? completedSets / sets : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sets': sets,
      'reps': reps,
      'restSeconds': restSeconds,
      'notes': notes,
      'completedSets': completedSets,
      'isCompleted': isCompleted,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      sets: json['sets'] as int,
      reps: json['reps'] as int,
      restSeconds: json['restSeconds'] as int,
      notes: json['notes'] as String?,
      completedSets: json['completedSets'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Exercise copyWith({
    String? id,
    String? name,
    int? sets,
    int? reps,
    int? restSeconds,
    String? notes,
    int? completedSets,
    bool? isCompleted,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      restSeconds: restSeconds ?? this.restSeconds,
      notes: notes ?? this.notes,
      completedSets: completedSets ?? this.completedSets,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// Workout routine model
class WorkoutRoutine {
  final String id;
  final String name;
  final List<Exercise> exercises;
  final String difficulty;
  final String? description;

  WorkoutRoutine({
    required this.id,
    required this.name,
    required this.exercises,
    required this.difficulty,
    this.description,
  });

  int get totalDuration {
    int total = 0;
    for (var exercise in exercises) {
      // Assume ~30 seconds per set + rest time
      total += (exercise.sets * (30 + exercise.restSeconds));
    }
    return total ~/ 60; // Return in minutes
  }

  double get progress {
    if (exercises.isEmpty) return 0.0;
    int totalCompleted = exercises.where((e) => e.isCompleted).length;
    return totalCompleted / exercises.length;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'difficulty': difficulty,
      'description': description,
    };
  }

  factory WorkoutRoutine.fromJson(Map<String, dynamic> json) {
    return WorkoutRoutine(
      id: json['id'] as String,
      name: json['name'] as String,
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      difficulty: json['difficulty'] as String,
      description: json['description'] as String?,
    );
  }
}

/// Workout session (active workout tracking)
class WorkoutSession {
  final String id;
  final WorkoutRoutine routine;
  final DateTime startTime;
  DateTime? endTime;
  int currentExerciseIndex;
  bool isCompleted;

  WorkoutSession({
    required this.id,
    required this.routine,
    required this.startTime,
    this.endTime,
    this.currentExerciseIndex = 0,
    this.isCompleted = false,
  });

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  Exercise? get currentExercise {
    if (currentExerciseIndex < routine.exercises.length) {
      return routine.exercises[currentExerciseIndex];
    }
    return null;
  }

  double get progress => routine.progress;

  int get completedExercises {
    return routine.exercises.where((e) => e.isCompleted).length;
  }

  int get totalExercises => routine.exercises.length;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routine': routine.toJson(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'currentExerciseIndex': currentExerciseIndex,
      'isCompleted': isCompleted,
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String,
      routine: WorkoutRoutine.fromJson(json['routine'] as Map<String, dynamic>),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      currentExerciseIndex: json['currentExerciseIndex'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

/// Pre-built workout routines
class WorkoutTemplates {
  static final List<WorkoutRoutine> templates = [
    WorkoutRoutine(
      id: 'arm_day',
      name: 'Arm Day',
      difficulty: 'Intermediate',
      description: 'Build bigger biceps and triceps',
      exercises: [
        Exercise(
          id: 'barbell_curls',
          name: 'Barbell Curls',
          sets: 3,
          reps: 10,
          restSeconds: 60,
          notes: 'Keep elbows locked at sides',
        ),
        Exercise(
          id: 'tricep_dips',
          name: 'Tricep Dips',
          sets: 3,
          reps: 12,
          restSeconds: 60,
          notes: 'Lower until 90° angle',
        ),
        Exercise(
          id: 'hammer_curls',
          name: 'Hammer Curls',
          sets: 3,
          reps: 10,
          restSeconds: 60,
          notes: 'Neutral grip throughout',
        ),
        Exercise(
          id: 'overhead_extension',
          name: 'Overhead Extension',
          sets: 3,
          reps: 12,
          restSeconds: 60,
          notes: 'Keep elbows close to head',
        ),
      ],
    ),
    WorkoutRoutine(
      id: 'leg_day',
      name: 'Leg Day',
      difficulty: 'Advanced',
      description: 'Build powerful legs and glutes',
      exercises: [
        Exercise(
          id: 'squats',
          name: 'Squats',
          sets: 4,
          reps: 8,
          restSeconds: 90,
          notes: 'Go below parallel',
        ),
        Exercise(
          id: 'lunges',
          name: 'Walking Lunges',
          sets: 3,
          reps: 12,
          restSeconds: 60,
          notes: '12 reps per leg',
        ),
        Exercise(
          id: 'leg_press',
          name: 'Leg Press',
          sets: 3,
          reps: 15,
          restSeconds: 90,
          notes: 'Full range of motion',
        ),
        Exercise(
          id: 'calf_raises',
          name: 'Calf Raises',
          sets: 4,
          reps: 15,
          restSeconds: 45,
          notes: 'Squeeze at the top',
        ),
      ],
    ),
    WorkoutRoutine(
      id: 'core_blast',
      name: 'Core Blast',
      difficulty: 'Beginner',
      description: 'Strengthen your core',
      exercises: [
        Exercise(
          id: 'planks',
          name: 'Planks',
          sets: 3,
          reps: 60,
          restSeconds: 60,
          notes: '60 seconds hold',
        ),
        Exercise(
          id: 'crunches',
          name: 'Crunches',
          sets: 3,
          reps: 20,
          restSeconds: 45,
          notes: 'Control the movement',
        ),
        Exercise(
          id: 'russian_twists',
          name: 'Russian Twists',
          sets: 3,
          reps: 30,
          restSeconds: 45,
          notes: '30 total (15 each side)',
        ),
        Exercise(
          id: 'leg_raises',
          name: 'Leg Raises',
          sets: 3,
          reps: 15,
          restSeconds: 60,
          notes: 'Keep lower back pressed down',
        ),
      ],
    ),
    WorkoutRoutine(
      id: 'cardio',
      name: 'Cardio Blast',
      difficulty: 'Intermediate',
      description: 'Get that heart rate up!',
      exercises: [
        Exercise(
          id: 'jumping_jacks',
          name: 'Jumping Jacks',
          sets: 3,
          reps: 50,
          restSeconds: 45,
          notes: 'Keep a steady pace',
        ),
        Exercise(
          id: 'burpees',
          name: 'Burpees',
          sets: 3,
          reps: 15,
          restSeconds: 60,
          notes: 'Full chest to ground',
        ),
        Exercise(
          id: 'high_knees',
          name: 'High Knees',
          sets: 3,
          reps: 60,
          restSeconds: 45,
          notes: '60 seconds continuous',
        ),
        Exercise(
          id: 'mountain_climbers',
          name: 'Mountain Climbers',
          sets: 3,
          reps: 40,
          restSeconds: 60,
          notes: '40 total (20 each leg)',
        ),
      ],
    ),
  ];

  static WorkoutRoutine? getById(String id) {
    try {
      return templates.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }
}
