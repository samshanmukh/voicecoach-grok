class Buddy {
  final String id;
  final String name;
  final String username;
  final String? avatarUrl;
  final String location;
  final List<String> tags;
  final bool isOnline;

  Buddy({
    required this.id,
    required this.name,
    required this.username,
    this.avatarUrl,
    required this.location,
    required this.tags,
    this.isOnline = false,
  });

  // Dummy data for recommended buddies
  static List<Buddy> getDummyBuddies() {
    return [
      Buddy(
        id: '1',
        name: 'Jacob Jones',
        username: '@jacobjones',
        location: 'Lansing, Illinois',
        tags: ['Newbie/Beginner', 'Weightlifting', 'Cardio'],
        isOnline: true,
      ),
      Buddy(
        id: '2',
        name: 'Guy Hawkins',
        username: '@guyhawkins',
        location: 'Olathe, KS',
        tags: ['Newbie/Beginner', 'Weightlifting', 'Cardio'],
        isOnline: true,
      ),
      Buddy(
        id: '3',
        name: 'Floyd Miles',
        username: '@floydmiles',
        location: '2118 Thornridge Cir, Syracuse',
        tags: ['Newbie/Beginner', 'Weightlifting', 'Cardio'],
        isOnline: true,
      ),
      Buddy(
        id: '4',
        name: 'Marvin McKinney',
        username: '@marvinmckinney',
        location: '2464 Royal Ln, Mesa, NJ',
        tags: ['Newbie/Beginner', 'Weightlifting', 'Cardio'],
        isOnline: true,
      ),
    ];
  }
}
