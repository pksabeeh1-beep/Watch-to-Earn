import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:watch_to_earn_app/providers/user_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('withdrawals')
            .where('userId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No withdrawal history found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final amount = data['amount'] ?? 0;
              final status = data['status'] ?? 'pending';
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
              final dateStr = timestamp != null
                  ? DateFormat('MMM d, y h:mm a').format(timestamp)
                  : 'Unknown Date';

              return ListTile(
                leading: const Icon(Icons.outbond, color: Colors.orange),
                title: Text('Withdrawal: $amount Coins'),
                subtitle: Text(dateStr),
                trailing: Chip(
                  label: Text(status.toUpperCase()),
                  backgroundColor: status == 'paid' ? Colors.green[100] : Colors.orange[100],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
