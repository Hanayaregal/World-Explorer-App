import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../theme_provider.dart'; // For theme switching

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String userName = "Guest";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        setState(() {
          userName = doc.data()?['name'] ?? "Guest";
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUserName(String newName) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {'name': newName},
        SetOptions(merge: true),
      );
      setState(() => userName = newName);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating name: $e")),
      );
    }
  }

  Future<void> _pickImage() async {
    final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() {
        _image = File(selectedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),

            // Photo
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 90,
                    backgroundColor: Colors.purple.withOpacity(0.1),
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? const Icon(Icons.person, size: 70, color: Colors.purple)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: const CircleAvatar(
                        backgroundColor: Colors.purple,
                        radius: 20,
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Name + Edit & Settings buttons (centered, nice row)
            Center(
              child: Column(
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit Profile button
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text("Edit Profile"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 2,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfileScreen(
                                currentName: userName,
                                onSave: _updateUserName,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(width: 16),

                      // Settings button
                      OutlinedButton.icon(
                        icon: const Icon(Icons.settings, size: 18),
                        label: const Text("Settings"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.purple,
                          side: BorderSide(color: Colors.purple[300]!),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "World Explorer Champion",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),

            const SizedBox(height: 25),

            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Level 5", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("70%", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.7,
                      minHeight: 10,
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : const Color(0xFFE0E0E0),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem("13/13", "Best", Icons.star, Colors.orange),
                  _statItem("42", "Quizzes", Icons.quiz, Colors.purple),
                  _statItem("5 Days", "Streak", Icons.local_fire_department, Colors.red),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Achievements
            _buildSectionCard(
              title: "Recent Achievements",
              children: [
                _buildAchievementItem("Ethiopia Expert", Icons.home, true),
                _buildAchievementItem("Perfect Score", Icons.emoji_events, true),
                _buildAchievementItem("Flag Master", Icons.public, false),
              ],
            ),

            const SizedBox(height: 30),

            // Sync Score Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                icon: const Icon(Icons.cloud_upload),
                label: const Text("Sync Score to Leaderboard"),
                onPressed: () async {
                  await savePlayerScore(userName, 1500);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Score synced to leaderboard!")),
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

// Helper widgets (unchanged)
Widget _statItem(String val, String label, IconData icon, Color color) {
  return Column(
    children: [
      Icon(icon, color: color, size: 28),
      Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ],
  );
}

Widget _buildSectionCard({required String title, required List<Widget> children}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.purple.withOpacity(0.04),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        ...children,
      ],
    ),
  );
}

Widget _buildAchievementItem(String title, IconData icon, bool unlocked) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, color: unlocked ? Colors.purple : Colors.grey),
        const SizedBox(width: 15),
        Text(title, style: TextStyle(color: unlocked ? Colors.black87 : Colors.grey)),
        const Spacer(),
        Icon(unlocked ? Icons.check_circle : Icons.lock,
            color: unlocked ? Colors.green : Colors.grey, size: 20),
      ],
    ),
  );
}

// Save score function
Future<void> savePlayerScore(String name, int score) async {
  try {
    await FirebaseFirestore.instance.collection('leaderboard').doc(name).set({
      'name': name,
      'score': score,
      'title': 'World Explorer Champion',
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  } catch (e) {
    print("Error saving score: $e");
  }
}

// Edit Profile Screen
class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final Function(String) onSave;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.onSave,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: "Write your name",
                  border: OutlineInputBorder(),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  final newName = _nameController.text.trim();
                  if (newName.isNotEmpty) {
                    widget.onSave(newName);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Name cannot be empty")),
                    );
                  }
                },
                child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Settings Screen (with dark mode toggle)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(  // ← Safer than Provider.of
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Settings"),
            backgroundColor: Colors.purple[800],  // ← Fixed: direct purple color
            foregroundColor: Colors.white,   // White text/icons on purple
            centerTitle: true,               // Optional: makes title centered (looks nicer)
            elevation: 0,                    // Optional: flat look, no shadow
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("App Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                SwitchListTile(
                  title: const Text("Dark Mode"),
                  subtitle: Text(themeProvider.isDarkMode ? "Enabled" : "Disabled"),
                  value: themeProvider.isDarkMode,
                  onChanged: (val) {
                    themeProvider.toggleTheme();
                  },
                  activeColor: Colors.purple,
                ),

                const SizedBox(height: 30),
                const Text("Account", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Log Out", style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}