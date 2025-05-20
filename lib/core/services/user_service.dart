// core/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lopako_app_lis/features/auth/models/user_model.dart';
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
  Future<AppUser> edit(AppUser user) async {
    final docRef = _db.collection('users').doc(user.id);
    final data = {
      'email': user.email,
      'name': user.name,
      'age': user.age,
    };
    await docRef.update(data);
    return (await get(uid: user.id))!;
  }

  /* ───── GET ───── */
  Future<AppUser?> get({String? uid, String? email}) async {
    assert(uid != null || email != null, 'Necesitas uid o email');

    final docSnap = uid != null
        ? await _db.collection('users').doc(uid).get()
        : await (await _byEmail(email!)).get();

    if (!docSnap.exists) return null;
    final data = docSnap.data()!;
    return AppUser(
      docSnap.id,
      email: data['email'] as String,
      name: data['name'] as String,
      age: data['age'] as int?,
    );
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
