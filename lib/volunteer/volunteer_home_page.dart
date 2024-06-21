import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pirateprogrammers/Bank/volunteer_info.dart';
import 'package:pirateprogrammers/login_page.dart';
import 'package:pirateprogrammers/volunteer/bank_info.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _demand = 0;
  String pincode = '';

  @override
  void initState() {
    super.initState();
    _fetchPincode();
  }

  void _fetchPincode() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      final userData =
          await _firestore.collection('users').doc(user!.uid).get();
      if (userData.exists) {
        setState(() {
          pincode = userData['pincode'].toString();
        });
      }
    } catch (e) {
      print('Error fetching pincode: $e');
    }
  }

  void _incrementCounter() {
    setState(() {
      _demand++;
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_demand > 0) {
        _demand--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.location_on), // Location icon
            SizedBox(width: 8),
            Expanded(
              child: Text(
                pincode.isNotEmpty
                    ? pincode
                    : pincode, // Display pincode dynamically
                textAlign: TextAlign.left,
              ),
            ),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  final score = snapshot.data?['score'] ?? 0;
                  return Text('$score');
                }
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          if (_selectedIndex == 0) // Render only if "Home" tab is selected
            _buildPageView(),
          if (_selectedIndex == 1) // Render only if "Search" tab is selected
            _buildSearchOverlay(),
          if (_selectedIndex == 2) // Render only if "Settings" tab is selected
            _buildProfileOverlay(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note_rounded),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}


  Widget _buildPageView() {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .where('role', isEqualTo: 'Foodbank')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // If no volunteer data found, display a message
            return Center(child: Text('No Foodbank found'));
          }
          final bankData = snapshot.data!.docs;

          return ListView.builder(
            itemCount: bankData.length,
            itemBuilder: (context, index) {
              final name = bankData[index]['name'];
              final profileImageUrl = bankData[index]['profileImage'];
              final notificationCount = 10;

              return GestureDetector(
                onTap: () {
                  _navigateToBankInfo(context, name, notificationCount);
                },
                child: NameItem(
                  name: name,
                  notificationCount: notificationCount, profileImageUrl: profileImageUrl,
                ),
              );
            },
          );
        }
      },
    );
  }

  void _navigateToBankInfo(
      BuildContext context, String name, int notificationCount) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              BankInfo(name: name, notificationCount: notificationCount)),
    );
  }

  Widget _buildSearchOverlay() {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .where('role', isEqualTo: 'Foodbank')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // If no volunteer data found, display a message
            return Center(child: Text('No Foodbank found'));
          }
          final bankData = snapshot.data!.docs;

          return ListView.builder(
            itemCount: bankData.length,
            itemBuilder: (context, index) {
              final name = bankData[index]['name'];
              final profileImageUrl = bankData[index]['profileImage'];
              final notificationCount = 10;

              return GestureDetector(
                onTap: () {
                  _navigateToBankInfo(context, name, notificationCount);
                },
                child: NameItem(
                  name: name,
                  notificationCount: notificationCount, profileImageUrl: profileImageUrl,
                ),
              );
            },
          );
        }
      },
    );
  }

  // void _navigateToBankInfo(
  //     BuildContext context, String name, int notificationCount) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //         builder: (context) =>
  //             BankInfo(name: name, notificationCount: notificationCount)),
  //   );
  // }

  void _saveDemandToFirestore(String userId, int demandValue) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    _firestore.collection('users').doc(userId).update({
      'demand': demandValue,
    }).then((value) {
      // Successfully saved to Firestore
      print('Demand value saved to Firestore: $demandValue');
    }).catchError((error) {
      // Failed to save to Firestore
      print('Failed to save demand value: $error');
    });
  }

  Widget _buildProfileOverlay() {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(user!.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            // If no data or no user found, display an appropriate message
            return Text('No profile data found');
          }
          final profileData = snapshot.data!.data() as Map<String, dynamic>;
          final name =
              profileData['name']; // Fetch the 'name' field from Firestore
          final email =
              profileData['email']; // Fetch the 'email' field from Firestore
          final profileImage = profileData[
              'profileImage']; // Fetch the 'profileImage' field from Firestore
          final role =
              profileData['role']; // Fetch the 'role' field from Firestore
          final address =
              profileData['address']; // Fetch the 'role' field from Firestore
          final phone =
              profileData['phone']; // Fetch the 'role' field from Firestore
          final pincode =
              profileData['pincode']; // Fetch the 'role' field from Firestore

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: NetworkImage(profileImage),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  name,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              SizedBox(height: 10),
              Divider(color: Colors.grey),
              ListTile(
                leading: Icon(Icons.work, color: Colors.blue),
                title: Text('Role: $role', style: TextStyle(fontSize: 18)),
              ),
              ListTile(
                leading: Icon(Icons.email, color: Colors.red),
                title: Text('Email: $email', style: TextStyle(fontSize: 18)),
              ),
              ListTile(
                leading: Icon(Icons.phone, color: Colors.red),
                title: Text('phone: $phone', style: TextStyle(fontSize: 18)),
              ),
              ListTile(
                leading: Icon(Icons.location_city_rounded, color: Colors.red),
                title:
                    Text('Address: $address', style: TextStyle(fontSize: 18)),
              ),
              ListTile(
                leading: Icon(Icons.add_location, color: Colors.red),
                title:
                    Text('pincode: $pincode', style: TextStyle(fontSize: 18)),
              ),
              Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await _auth.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                  child: Text('Logout', style: TextStyle(fontSize: 16)),
                ),
              ),
              SizedBox(height: 20),
            ],
          );
        }
      },
    );
  }


class NameItem extends StatelessWidget {
  final String name;
  final int notificationCount;
  final String profileImageUrl; // Add profile image URL

  const NameItem({
    required this.name,
    required this.notificationCount,
    required this.profileImageUrl, // Receive profile image URL
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(profileImageUrl), // Use profile image URL
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Requirement ${notificationCount.toString()}',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

