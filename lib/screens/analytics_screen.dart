import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 10,
          bottom: const TabBar(
            labelColor: Colors.purple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.yellow,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.leaderboard), text: "Leaderboard"),
              Tab(icon: Icon(Icons.person), text: "My Stats"),
              Tab(icon: Icon(Icons.trending_up), text: "Progress"),
              Tab(icon: Icon(Icons.emoji_events), text: "Achievements"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            GlobalLeaderboardTab(),
            PersonalStatsTab(),
            ProgressChartTab(),
            AchievementsTab(),
          ],
        ),
      ),
    );
  }
}

// ── 1. Global Leaderboard Tab ───────────────────────────────────────────────
class GlobalLeaderboardTab extends StatelessWidget {
  const GlobalLeaderboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('leaderboard').limit(20).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Something went wrong: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var docs = snapshot.data?.docs ?? [];
        docs = docs..sort((a, b) {
          final scoreA = (a.data() as Map)['score'] as num? ?? 0;
          final scoreB = (b.data() as Map)['score'] as num? ?? 0;
          return scoreB.compareTo(scoreA);
        });

        if (docs.isEmpty) {
          return const Center(
            child: Text(
              "No scores yet!\nBe the first to play a quiz and appear here!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final rank = index + 1;
            final isTop3 = rank <= 3;

            return Card(
              elevation: isTop3 ? 1 : 0,
              color: isTop3 ? Colors.amber[50] : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isTop3 ? Colors.amber[700] : Colors.blueGrey,
                  radius: 24,
                  child: Text(
                    "$rank",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  data['name'] ?? 'Anonymous Player',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: Text(
                  "${NumberFormat.compact().format(data['score'] ?? 0)} points",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── 2. My Stats Tab ──────────────────────────────────────────────────────────
class PersonalStatsTab extends StatelessWidget {
  const PersonalStatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Center(child: Text("Please play a quiz to see your stats!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: Colors.grey)));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('leaderboard').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text(
              "You haven't played any quizzes yet!\nComplete your first quiz to unlock your stats! 🚀",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final name = data['name'] ?? 'You';
        final totalScore = (data['score'] as num?)?.toInt() ?? 0;
        final quizzesPlayed = (data['quizzesPlayed'] as num?)?.toInt() ?? 0;
        final avgScore = quizzesPlayed > 0 ? (totalScore / quizzesPlayed).toStringAsFixed(1) : "0.0";

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.purple[100],
                child: Icon(Icons.person, size: 60, color: Colors.purple[800]),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _StatCard("Total Points", NumberFormat.compact().format(totalScore), Icons.star, Colors.amber),
                  _StatCard("Quizzes Completed", "$quizzesPlayed", Icons.quiz, Colors.blue),
                  _StatCard("Average Score", "$avgScore%", Icons.trending_up, Colors.green),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.purple.withAlpha(38), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
        ],
      ),
    );
  }
}

// ── 3. Progress Chart Tab ───────────────────────────────────────────────────
class ProgressChartTab extends StatelessWidget {
  const ProgressChartTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Example data - replace with real data from Firestore later
    final spots = const [
      FlSpot(1, 45), FlSpot(2, 62), FlSpot(3, 58), FlSpot(4, 78),
      FlSpot(5, 85), FlSpot(6, 92), FlSpot(7, 88), FlSpot(8, 95),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Score Progress Over Time",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Showing your last ${spots.length} quiz scores",
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 320,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) => Text(
                        "Quiz ${value.toInt()}",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 20,
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.4,
                    color: Colors.purple,
                    barWidth: 4,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.purple.withAlpha(38),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (LineBarSpot touchedSpot) {
                      return Colors.purple.shade900;
                    },
                    tooltipBorderRadius: const BorderRadius.all(Radius.circular(12)),
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          "${spot.y.toStringAsFixed(0)} points",
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 4. Achievements / Badges Tab ────────────────────────────────────────────
class AchievementsTab extends StatelessWidget {
  const AchievementsTab({super.key});

  final List<Map<String, dynamic>> _badges = const [
    {"title": "Early Bird", "icon": Icons.wb_sunny, "color": Colors.amber, "unlocked": true},
    {"title": "Quiz Master", "icon": Icons.school, "color": Colors.blue, "unlocked": true},
    {"title": "Perfect Score", "icon": Icons.star, "color": Colors.purple, "unlocked": false},
    {"title": "10 Quizzes Completed", "icon": Icons.format_list_numbered, "color": Colors.green, "unlocked": false},
    {"title": "Streak King", "icon": Icons.local_fire_department, "color": Colors.orange, "unlocked": false},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _badges.length,
      itemBuilder: (context, index) {
        final badge = _badges[index];
        final unlocked = badge["unlocked"] as bool;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              badge["icon"] as IconData,
              color: unlocked ? badge["color"] as Color : Colors.grey,
              size: 36,
            ),
            title: Text(
              badge["title"] as String,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: unlocked ? Colors.black : Colors.grey[700],
              ),
            ),
            trailing: unlocked
                ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
                : const Text(
              "Locked",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        );
      },
    );
  }
}