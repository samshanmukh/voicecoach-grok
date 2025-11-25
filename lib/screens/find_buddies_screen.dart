import 'package:flutter/material.dart';
import '../models/buddy.dart';

class FindBuddiesScreen extends StatefulWidget {
  const FindBuddiesScreen({super.key});

  @override
  State<FindBuddiesScreen> createState() => _FindBuddiesScreenState();
}

class _FindBuddiesScreenState extends State<FindBuddiesScreen> {
  List<Buddy> _allBuddies = [];
  List<Buddy> _filteredBuddies = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final Set<String> _addedBuddies = {};

  @override
  void initState() {
    super.initState();
    _allBuddies = Buddy.getDummyBuddies();
    _filteredBuddies = _allBuddies;
    _searchController.addListener(_filterBuddies);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterBuddies() {
    setState(() {
      _filteredBuddies = _allBuddies.where((buddy) {
        // Search filter
        final searchMatch = buddy.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            buddy.username.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            buddy.location.toLowerCase().contains(_searchController.text.toLowerCase());

        // Category filter
        final categoryMatch = _selectedFilter == 'All' || buddy.tags.contains(_selectedFilter);

        return searchMatch && categoryMatch;
      }).toList();
    });
  }

  void _showFilterDialog() {
    final allTags = <String>{'All'};
    for (var buddy in _allBuddies) {
      allTags.addAll(buddy.tags);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('Filter by Interest', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: allTags.map((tag) => RadioListTile<String>(
            title: Text(tag, style: const TextStyle(color: Colors.white)),
            value: tag,
            groupValue: _selectedFilter,
            activeColor: const Color(0xFFC8FF00),
            onChanged: (value) {
              setState(() => _selectedFilter = value!);
              Navigator.pop(context);
              _filterBuddies();
            },
          )).toList(),
        ),
      ),
    );
  }

  void _toggleBuddy(String username) {
    setState(() {
      if (_addedBuddies.contains(username)) {
        _addedBuddies.remove(username);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed $username from buddies'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _addedBuddies.add(username);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $username as buddy!'),
            backgroundColor: const Color(0xFFC8FF00),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Find Buddies',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFFC8FF00)),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, color: Color(0xFFC8FF00)),
                    hintText: 'Search buddies...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
                // Map exploration card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8FF00),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Explore our interactive map!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Explore the Map to Find Workout Buddies Near You!',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.map, color: Color(0xFFC8FF00), size: 28),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

              // Filter indicator
              if (_selectedFilter != 'All')
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Chip(
                    label: Text('Filter: $_selectedFilter'),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() => _selectedFilter = 'All');
                      _filterBuddies();
                    },
                    backgroundColor: const Color(0xFFC8FF00),
                    labelStyle: const TextStyle(color: Colors.black),
                  ),
                ),

              // Near-by Buddies section
              Text(
                'Near-by Buddies (${_filteredBuddies.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Buddies list
              Expanded(
                child: _filteredBuddies.isEmpty
                    ? Center(
                        child: Text(
                          'No buddies found.\nTry adjusting your filters.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[400], fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredBuddies.length,
                        itemBuilder: (context, index) {
                          return _buildBuddyCard(context, _filteredBuddies[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBuddyCard(BuildContext context, Buddy buddy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  buddy.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  buddy.username,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: const Color(0xFFC8FF00)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        buddy.location,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[300],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: buddy.tags.map((tag) => _buildTag(tag)).toList(),
                ),
              ],
            ),
          ),

          // Action button
          GestureDetector(
            onTap: () => _toggleBuddy(buddy.username),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _addedBuddies.contains(buddy.username)
                    ? Colors.green
                    : const Color(0xFFC8FF00),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _addedBuddies.contains(buddy.username)
                    ? Icons.check
                    : Icons.person_add,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC8FF00).withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey[300],
        ),
      ),
    );
  }
}
