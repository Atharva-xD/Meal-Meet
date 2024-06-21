import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VolunteerInfo extends StatefulWidget {
  final String name;
  final int notificationCount;

  const VolunteerInfo({
    Key? key,
    required this.name,
    required this.notificationCount,
  }) : super(key: key);

  @override
  _VolunteerInfoState createState() => _VolunteerInfoState();
}

class _VolunteerInfoState extends State<VolunteerInfo> {
  int _isApproved =  0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('users').where('name', isEqualTo: widget.name).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('Volunteer data not found');
        }

        final volunteerData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final profileImageUrl = volunteerData['profileImage'] ?? '';
        final score = volunteerData['score']??'';
        final demand = volunteerData['demand']??'';
        return Scaffold(
          appBar: AppBar(
            title: Text('Volunteer Info'),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(profileImageUrl),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 8),
                          Text(
                            widget.name,
                            style: TextStyle(fontSize: 24),
                          ),
                          SizedBox(height: 8),
                          Text(
                            volunteerData['phone'] ?? '', // Fetch volunteer's phone number
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Score:',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(width: 5),
                      Text(
                        score.toString(),
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Requirement:',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(width: 5),
                      Text(
                        demand.toString(),
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
  onPressed: () {
    FirebaseFirestore.instance.collection('users').where('name', isEqualTo: widget.name).get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.update({'approved': 1}); // Update 'approved' field to 1 for approval xD
      });
    });
    setState(() {
      _isApproved = 1;
    });
    // Handle Approve button press
  },
  child: Text('Approve'),
  style: ElevatedButton.styleFrom(
    fixedSize: Size.fromHeight(50), // Adjust the button height
  ),
),
ElevatedButton(
  onPressed: () {
    FirebaseFirestore.instance.collection('users').where('name', isEqualTo: widget.name).get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.update({'approved': -1}); // Update 'approved' field to -1 for rejection
      });
    });
    setState(() {
      _isApproved = -1;
    });
    // Handle Reject button press
  },
  child: Text('Reject'),
  style: ElevatedButton.styleFrom(
    fixedSize: Size.fromHeight(50), // Adjust the button height
  ),
),

                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
