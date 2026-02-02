import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String searchText = ""; // This holds what the user types

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Global Rankings"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // --- THE SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search explorer name...",
                prefixIcon: const Icon(Icons.search, color: Colors.purple),
                filled: true,
                fillColor: Colors.purple.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value; // Update the search as you type
                });
              },
            ),
          ),

          // --- THE LIST ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Logic: If search is empty, show top 20. If typing, filter by name.
              stream: searchText.isEmpty
                  ? FirebaseFirestore.instance
                  .collection('leaderboard')
                  .orderBy('score', descending: true)
                  .limit(20)
                  .snapshots()
                  : FirebaseFirestore.instance
                  .collection('leaderboard')
                  .where('name', isGreaterThanOrEqualTo: searchText)
                  .where('name', isLessThanOrEqualTo: '$searchText\uf8ff')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No explorers found 🔍"));
                }

                final players = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    var data = players[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple[100],
                          child: Text("${index + 1}"),
                        ),
                        title: Text(data['name'] ?? 'Anonymous'),
                        trailing: Text(
                          "${data['score']} pts",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}