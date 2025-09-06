// lib/screens/leaderboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/leaderboard_provider.dart';
import '../providers/auth_provider.dart';
import '../models/leaderboard.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedTestId;
  String? _selectedAgeGroup;
  String? _selectedGender;
  final List<String> _ageGroups = ['Under 15', '15-18', '19-25', '26-35', 'Above 35'];
  final List<String> _genders = ['All', 'Male', 'Female'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final leaderboardProvider = Provider.of<LeaderboardProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    leaderboardProvider.loadNationalRankings();
    leaderboardProvider.loadAthleteRankings();
    
    if (authProvider.currentAthlete != null) {
      leaderboardProvider.loadStateRankings(authProvider.currentAthlete!.state);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Rankings'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Age Group:'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedAgeGroup,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: const Text('All Age Groups'),
                items: _ageGroups.map((group) => DropdownMenuItem(
                  value: group,
                  child: Text(group),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAgeGroup = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Gender:'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedGender ?? 'All',
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _genders.map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value == 'All' ? null : value;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedAgeGroup = null;
                _selectedGender = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _applyFilters();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    final leaderboardProvider = Provider.of<LeaderboardProvider>(context, listen: false);
    
    switch (_tabController.index) {
      case 0:
        leaderboardProvider.loadNationalRankings(
          ageGroup: _selectedAgeGroup,
          gender: _selectedGender,
        );
        break;
      case 1:
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.currentAthlete != null) {
          leaderboardProvider.loadStateRankings(authProvider.currentAthlete!.state);
        }
        break;
      case 2:
        leaderboardProvider.loadAthleteRankings();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadInitialData();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.flag), text: 'National'),
            Tab(icon: Icon(Icons.location_on), text: 'State'),
            Tab(icon: Icon(Icons.person), text: 'My Rankings'),
          ],
        ),
      ),
      body: Consumer<LeaderboardProvider>(
        builder: (context, leaderboardProvider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildNationalTab(leaderboardProvider),
              _buildStateTab(leaderboardProvider),
              _buildMyRankingsTab(leaderboardProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNationalTab(LeaderboardProvider leaderboardProvider) {
    if (leaderboardProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (leaderboardProvider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error: ${leaderboardProvider.errorMessage}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => leaderboardProvider.loadNationalRankings(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (leaderboardProvider.nationalRankings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No national rankings available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Filters Applied Info
        if (_selectedAgeGroup != null || _selectedGender != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.orange.withOpacity(0.1),
            child: Text(
              'Filters: ${_selectedAgeGroup ?? 'All Ages'}, ${_selectedGender ?? 'All Genders'}',
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: leaderboardProvider.nationalRankings.length,
            itemBuilder: (context, index) {
              final entry = leaderboardProvider.nationalRankings[index];
              return _buildLeaderboardCard(entry, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStateTab(LeaderboardProvider leaderboardProvider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.currentAthlete == null) {
      return const Center(
        child: Text('Please login to view state rankings'),
      );
    }

    if (leaderboardProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (leaderboardProvider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error: ${leaderboardProvider.errorMessage}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => leaderboardProvider.loadStateRankings(
                authProvider.currentAthlete!.state,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (leaderboardProvider.stateRankings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${authProvider.currentAthlete!.state} rankings available',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // State Info Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.blue.withOpacity(0.1),
          child: Text(
            '${authProvider.currentAthlete!.state} State Rankings',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: leaderboardProvider.stateRankings.length,
            itemBuilder: (context, index) {
              final entry = leaderboardProvider.stateRankings[index];
              return _buildLeaderboardCard(entry, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMyRankingsTab(LeaderboardProvider leaderboardProvider) {
    if (leaderboardProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (leaderboardProvider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error: ${leaderboardProvider.errorMessage}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => leaderboardProvider.loadAthleteRankings(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (leaderboardProvider.athleteRankings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No personal rankings available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Complete fitness assessments to see your rankings',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leaderboardProvider.athleteRankings.length,
      itemBuilder: (context, index) {
        final entry = leaderboardProvider.athleteRankings[index];
        return _buildMyRankingCard(entry);
      },
    );
  }

  Widget _buildLeaderboardCard(LeaderboardEntry entry, int index) {
    final isTopThree = entry.currentRank <= 3;
    final rankChange = entry.rankChange;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isTopThree ? 4 : 1,
      child: Container(
        decoration: isTopThree
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [
                    _getRankColor(entry.currentRank).withOpacity(0.1),
                    Colors.white,
                  ],
                ),
              )
            : null,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: _buildRankBadge(entry.currentRank),
          title: Text(
            entry.athleteName ?? 'Unknown Athlete',
            style: TextStyle(
              fontWeight: isTopThree ? FontWeight.bold : FontWeight.normal,
              fontSize: isTopThree ? 16 : 14,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.athleteState != null)
                Text('${entry.athleteState}, ${entry.athleteDistrict ?? ''}'),
              if (entry.fitnessTestName != null)
                Text(
                  'Test: ${entry.fitnessTestName}',
                  style: const TextStyle(fontSize: 12),
                ),
              Text(
                'Score: ${entry.bestScore.toStringAsFixed(1)} | Points: ${entry.totalPoints}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (rankChange != 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      rankChange > 0 ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: rankChange > 0 ? Colors.green : Colors.red,
                    ),
                    Text(
                      '${rankChange.abs()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: rankChange > 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              Text(
                '${entry.totalParticipants} total',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyRankingCard(LeaderboardEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [
              Colors.orange.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    entry.leaderboardType == 'national' ? Icons.flag : Icons.location_on,
                    color: entry.leaderboardType == 'national' ? Colors.blue : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${entry.leaderboardType.toUpperCase()} RANKING',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (entry.fitnessTestName != null)
                        Text(
                          entry.fitnessTestName!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        'Best Score: ${entry.bestScore.toStringAsFixed(1)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Points: ${entry.totalPoints}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '#${entry.currentRank}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        'of ${entry.totalParticipants}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              if (entry.rankChange != 0) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      entry.rankChange > 0 ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: entry.rankChange > 0 ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.rankChange > 0 ? 'Up' : 'Down'} ${entry.rankChange.abs()} ${entry.rankChange.abs() == 1 ? 'position' : 'positions'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: entry.rankChange > 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              if (entry.ageGroup != null || entry.gender != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Category: ${entry.ageGroup ?? 'All Ages'}, ${entry.gender ?? 'All'}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    final color = _getRankColor(rank);
    final icon = _getRankIcon(rank);
    
    return CircleAvatar(
      backgroundColor: color,
      radius: 20,
      child: rank <= 3
          ? Icon(icon, color: Colors.white, size: 20)
          : Text(
              '$rank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // Gold
      case 2:
        return Colors.grey[600]!; // Silver
      case 3:
        return Colors.brown; // Bronze
      default:
        return Colors.orange;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.looks_one;
      case 2:
        return Icons.looks_two;
      case 3:
        return Icons.looks_3;
      default:
        return Icons.person;
    }
  }
}