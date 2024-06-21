import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pirateprogrammers/login_page.dart';

import 'volunteer_info.dart';

class HomeBankScreen extends StatefulWidget {
  final User user; // Define the user variable

  const HomeBankScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HomeBankScreenState createState() => _HomeBankScreenState();
}

class _HomeBankScreenState extends State<HomeBankScreen> {
  int _selectedIndex = 0;
  int _counter = 0;
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
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_counter > 0) {
        _counter--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
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
                  .doc(widget.user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || !snapshot.data!.exists) {
                  // Handle case where document does not exist
                  return Text('Document does not exist');
                } else {
                  final Map<String, dynamic>? data =
                      snapshot.data!.data() as Map<String, dynamic>?;

                  final counterValue = data?['counter'] ?? 0;
                  if (!data!.containsKey('counter')) {
                    // If the field 'counter' does not exist, initialize it with 0
                    _saveCounterToFirestore(
                        widget.user.uid, 0); // Save 0 to Firestore
                  }
                  return Text('$counterValue');
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
            label: 'Update',
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

  Widget _buildPageView() {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .where('role', isEqualTo: 'Volunteer')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // If no volunteer data found, display a message
            return Center(child: Text('No volunteers found'));
          }
          // Extract volunteer data and sort based on the 'score' field
          List<DocumentSnapshot> volunteerData = snapshot.data!.docs;
          volunteerData.sort((a, b) => b['score'].compareTo(a['score']));

          return ListView.builder(
            itemCount: volunteerData.length,
            itemBuilder: (context, index) {
              final name = volunteerData[index]['name'];
              final profileImageUrl = volunteerData[index]['profileImage'];
              final notificationCount = 10;

              return GestureDetector(
                onTap: () {
                  _navigateToVolunteerInfo(context, name, notificationCount);
                },
                child: NameItem(
                  name: name,
                  demand: notificationCount,
                  profileImageUrl: profileImageUrl,
                ),
              );
            },
          );
        }
      },
    );
  }

  void _navigateToVolunteerInfo(
      BuildContext context, String name, int notificationCount) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => VolunteerInfo(
                name: name,
                notificationCount: notificationCount,
              )),
    );
  }

  Widget _buildSearchOverlay() {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      margin: EdgeInsets.all(20), // Margin for the container
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Data Update',
                style: TextStyle(fontSize: 24),
              ),
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag,
                    size: 24,
                    color: Colors.black,
                  ),
                  SizedBox(width: 4),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('approved_records')
                        .doc(user!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || !snapshot.data!.exists) {
                        // Handle case where document does not exist
                        return Text('0'); // Assuming the initial count is 0
                      } else {
                        final Map<String, dynamic>? data =
                            snapshot.data!.data() as Map<String, dynamic>?;

                        final recordCount = data?['approved_records'] ?? 0;
                        return Text('$recordCount');
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                onPressed: _decrementCounter,
                tooltip: 'Decrement',
                child: Icon(Icons.remove),
              ),
              SizedBox(width: 20),
              Text(
                '$_counter',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 20),
              FloatingActionButton(
                onPressed: _incrementCounter,
                tooltip: 'Increment',
                child: Icon(Icons.add),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Save counter value to Firestore
              _saveCounterToFirestore(user!.uid, _counter);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _saveCounterToFirestore(String userId, int counterValue) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    _firestore.collection('users').doc(userId).update({
      'counter': counterValue,
    }).then((value) {
      // Successfully saved to Firestore
      print('Counter value saved to Firestore: $counterValue');
    }).catchError((error) {
      // Failed to save to Firestore
      print('Failed to save counter value: $error');
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
          final address = profileData['address'];
          final phone = profileData['phone'];
          final pincode = profileData['pincode'];

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
}

class NameItem extends StatelessWidget {
  final String name;
  final int demand;
  final String profileImageUrl; // Add profile image URL

  const NameItem({
    required this.name,
    required this.demand,
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
              backgroundImage:
                  NetworkImage(profileImageUrl), // Use profile image URL
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
                  Row(
                    children: [
                      Text(
                        'Available:',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      SizedBox(width: 5),
                      Text(
                        demand.toString(),
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
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
