import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FamilyCircleSettingsScreen extends StatefulWidget {
  const FamilyCircleSettingsScreen({super.key});

  @override
  State<FamilyCircleSettingsScreen> createState() => _FamilyCircleSettingsScreenState();
}

class _FamilyCircleSettingsScreenState extends State<FamilyCircleSettingsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _codeController = TextEditingController();
  bool _showJoinInput = false;
  List<DocumentSnapshot> _userCircles = [];

  @override
  void initState() {
    super.initState();
    _loadUserCircles();
  }

  Future<void> _loadUserCircles() async {
    final userRef = _firestore.collection('users').doc(_auth.currentUser!.uid);

    final query = await _firestore
        .collection('familiar_circle_routines')
        .where('associated_users', arrayContains: userRef)
        .get();

    setState(() {
      _userCircles = query.docs;
    });
  }

  Future<void> _leaveCircle(String docId) async {
    final userRef = _firestore.collection('users').doc(_auth.currentUser!.uid);

    await _firestore.collection('familiar_circle_routines').doc(docId).update({
      'associated_users': FieldValue.arrayRemove([userRef])
    });

    await _loadUserCircles(); // Refresh
  }

  Future<void> _joinCircle(String code) async {
    final userRef = _firestore.collection('users').doc(_auth.currentUser!.uid);

    final query = await _firestore
        .collection('familiar_circle_routines')
        .where('family_id', isEqualTo: code)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código no válido')),
      );
      return;
    }

    final doc = query.docs.first;

    await _firestore.collection('familiar_circle_routines').doc(doc.id).update({
      'associated_users': FieldValue.arrayUnion([userRef])
    });

    _codeController.clear();
    setState(() => _showJoinInput = false);
    await _loadUserCircles();
  }

  Future<List<Map<String, dynamic>>> _loadAssociatedUsers(List<dynamic> refs) async {
    final results = <Map<String, dynamic>>[];

    for (final ref in refs) {
      if (ref is DocumentReference) {
        final doc = await ref.get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          results.add({
            'name': data['name'] ?? '',
            'email': data['email'] ?? '',
            'bond': data['bond'] ?? '',
          });
        }
      }
    }

    return results;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Círculo familiar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_userCircles.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _userCircles.length,
                  itemBuilder: (context, index) {
                    final data = _userCircles[index].data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        title: Text('Familia de ${data['patientName'] ?? 'Paciente'}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Código: ${data['family_id']}'),
                            const SizedBox(height: 8),
                            FutureBuilder<List<Map<String, dynamic>>>(
                              future: _loadAssociatedUsers(data['associated_users']),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return const Text('Cargando usuarios...');
                                final users = snapshot.data!;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: users.map((user) {
                                    final name = user['name'];
                                    final email = user['email'];
                                    final bond = user['bond'];
                                    return Text('👤 $name | $email | Rol: $bond');
                                  }).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                        trailing: TextButton(
                          onPressed: () => _leaveCircle(_userCircles[index].id),
                          child: const Text('Abandonar', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    );
                  },
                ),
              )
            else ...[
              const Text('No perteneces a ningún círculo familiar.'),
              const SizedBox(height: 20),
              if (_showJoinInput)
                Column(
                  children: [
                    TextField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Código de 6 dígitos',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _joinCircle(_codeController.text.trim()),
                      child: const Text('Unirse'),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: () => setState(() => _showJoinInput = true),
                  child: const Text('Unirse a un círculo'),
                ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
