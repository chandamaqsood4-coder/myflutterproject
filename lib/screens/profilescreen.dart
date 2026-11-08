import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              const SizedBox(height: 5),

              // Profile Picture
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green, width: 3),
                ),
                child: const CircleAvatar(
                  radius: 45,
                  backgroundColor: Color(0xFFE0F2E9),
                  child: Icon(Icons.person, size: 80, color: Colors.green),
                ),
              ),

              const SizedBox(height: 15),

              // User Name
              const Text(
                'Saman Liaqat',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222),
                ),
              ),

              const SizedBox(height: 3),

              // Profession
              const Text(
                'Flutter Developer',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),

              const SizedBox(height: 10),

              // Edit Profile Button
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edit Profile button pressed!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Personal Information Heading
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Personal Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              // Email Card
              _buildInfoCard(
                icon: Icons.email_outlined,
                title: 'Email Address',
                value: 'sanam9liaqat@gmail.com',
              ),

              const SizedBox(height: 10),

              // Phone Card
              _buildInfoCard(
                icon: Icons.phone_outlined,
                title: 'Phone Number',
                value: '+92 300 1234567',
              ),

              const SizedBox(height: 10),

              // Location Card
              _buildInfoCard(
                icon: Icons.location_on_outlined,
                title: 'Location',
                value: 'Pakistan',
              ),

              const SizedBox(height: 10),

              // About Card
              _buildInfoCard(
                icon: Icons.info_outline,
                title: 'About Me',
                value: 'Passionate about learning Flutter.',
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          if (index != 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  index == 1 ? 'Home selected' : 'Settings selected',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // Reusable Information Card
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.green, size: 20),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF222222),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
