import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BankInfo extends StatefulWidget {
  final String name;
  final int notificationCount;

  const BankInfo({
    Key? key,
    required this.name,
    required this.notificationCount,
  }) : super(key: key);

  @override
  _BankInfoState createState() => _BankInfoState();
}

class _BankInfoState extends State<BankInfo> {
  int _request = 0;
  late User? user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
  }

  void _incrementCounter() {
    setState(() {
      _request++;
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_request > 0) {
        _request--;
      }
    });
  }

  void _saveResultToFirestore(String userId, int requestValue) {
    _firestore.collection('users').doc(userId).update({
      'request': requestValue,
    }).then((value) {
      // Successfully saved to Firestore
      print('Counter value saved to Firestore: $requestValue');
    }).catchError((error) {
      // Failed to save to Firestore
      print('Failed to save counter value: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: widget.name)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('DataBank data not found');
        }

        final bankData =
            snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final profileImageUrl = bankData['profileImage'] ?? '';

        return Scaffold(
          appBar: AppBar(
            title: Text('Bank Info'),
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
                            bankData['phone'] ??
                                '', // Fetch DataBank's phone number
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  StatefulBuilder(
                    builder: (context, StateSetter setState) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _decrementCounter();
                              });
                            },
                            icon: Icon(Icons.remove),
                          ),
                          Text(
                            '$_request',
                            style: TextStyle(fontSize: 20),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _incrementCounter();
                              });
                            },
                            icon: Icon(Icons.add),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _saveResultToFirestore(user!.uid, _request);
                    },
                    child: Text('Request'),
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
