import 'package:flutter/material.dart';
import '../view_models/user_profile_view_model.dart';
import '../widgets/user_profile_dialog.dart'; // Impor UserProfileDialog



class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            color: Colors.white, // Menetapkan warna teks menjadi putih
          ),
        ),
        backgroundColor: const Color(0xFF755330), // Coklat elegan
        elevation: 0,
        automaticallyImplyLeading: false, // Menonaktifkan tombol back otomatis
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Tindakan logout atau navigasi ke halaman login
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header yang elegan
              Text(
                'WPS Mobile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A4E23), // Warna coklat yang lebih lembut
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'What would you like to do today?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),

              // Card untuk menu pilihan
              _buildMenuCard(
                context,
                title: 'Stock Opname',
                icon: Icons.checklist_rtl_rounded,
                onTap: () {
                  Navigator.pushNamed(context, '/dashboard');
                },
              ),
              const SizedBox(height: 16),
              _buildMenuCard(
                context,
                title: 'Mapping Lokasi',
                icon: Icons.location_on_outlined,
                onTap: () {
                  Navigator.pushNamed(context, '/notifications');
                },
              ),
              const SizedBox(height: 16),
              _buildMenuCard(
                context,
                title: 'Pengaturan Akun',
                icon: Icons.account_circle,
                onTap: () {
                  _showChangePasswordDialog(context);
                },
              ),
              const SizedBox(height: 24),

              // Add more options as needed
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Example: Navigate to another screen
                    Navigator.pushNamed(context, '/example');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF755330), // Coklat elegan
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text(
                    'Explore More',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk Card Menu
  Widget _buildMenuCard(BuildContext context,
      {required String title, required IconData icon, required Function onTap}) {
    return Card(
      elevation: 5,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () => onTap(),
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Color(0xFF755330), // Coklat elegan
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFF755330),
        ),
      ),
    );
  }

  // Fungsi untuk menampilkan dialog ganti password
  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UserProfileDialog();
      },
    );
  }
}
