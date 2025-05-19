// core/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'service_manager.dart';

class UserService extends BaseService {
  final _db = FirebaseFirestore.instance;

  /* ───── CREATE ───── */
  Future<void> create({
    required String uid,
    required String email,
    required String name,
    required int? age,
  }) =>
      _db.collection('users').doc(uid).set({
        'email': email,
        'name': name,
        'age': age,
        'createdAt': FieldValue.serverTimestamp(),
      });

  /* ───── EDIT ───── */
  Future<void> edit({String? uid, String? email, String? name, int? age}) async {
    assert(uid != null || email != null, 'Necesitas uid o email');

    final doc = uid != null
        ? _db.collection('users').doc(uid)
        : await _byEmail(email!);

    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (age != null) data['age'] = age;
    data['updatedAt'] = FieldValue.serverTimestamp();

    await doc.update(data);
  }

  /* ───── GET ───── */
  Future<Map<String, dynamic>?> get({String? uid, String? email}) async {
    assert(uid != null || email != null, 'Necesitas uid o email');

    final docSnap = uid != null
        ? await _db.collection('users').doc(uid).get()
        : await (await _byEmail(email!)).get();

    return docSnap.data();
  }

  /* ───── FAMILY CIRCLES DEL USUARIO ───── */
  Future<List<String>> getFamilyCircles(String uid) async {
    final query = await _db
        .collection('family_circles')
        .where('members', arrayContains: uid)
        .get();

    return query.docs.map((d) => d.id).toList();
  }

  /* ───── helper byEmail ───── */
  Future<DocumentReference<Map<String, dynamic>>> _byEmail(String email) async {
    final q = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (q.docs.isEmpty) throw Exception('Usuario con email $email no existe');
    return q.docs.first.reference;
  }
}
