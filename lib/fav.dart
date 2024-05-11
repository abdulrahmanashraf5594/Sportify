import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserEventsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Events'),
      ),
      body: UserEventsList(),
    );
  }
}

class UserEventsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(
        child: Text('Please login to view your events.'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('accepted_events')
          .where('userId', isEqualTo: user.uid) // استعرض الفعاليات التي أضافها اليوزر الحالي فقط
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final events = snapshot.data!.docs;
        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index].data() as Map<String, dynamic>;

            return ListTile(
              title: Text(event['eventName']),
              subtitle: Text(event['eventDate']),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  // عند الضغط على زر الحذف
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Delete Event"),
                        content: Text("Are you sure you want to delete this event?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              // حذف الفعالية
                              FirebaseFirestore.instance
                                  .collection('accepted_events')
                                  .doc(events[index].id)
                                  .delete()
                                  .then((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Event deleted successfully.'),
                                  ),
                                );
                                Navigator.of(context).pop(); // إغلاق الحوار
                              }).catchError((error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to delete event: $error'),
                                  ),
                                );
                              });
                            },
                            child: Text("Delete"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
