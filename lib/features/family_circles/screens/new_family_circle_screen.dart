import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lopako_app_lis/features/family_circles/widgets/new_family_circle_widget.dart';
import 'package:lopako_app_lis/generated/l10n.dart';

class NewFamilyCircleScreen extends StatefulWidget {
  const NewFamilyCircleScreen({Key? key}) : super(key: key);

  @override
  _NewFamilyCircleScreenState createState() => _NewFamilyCircleScreenState();
}

class _NewFamilyCircleScreenState extends State<NewFamilyCircleScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NewFamilyCircleWidget(
              onCreatePressed: () {
                // TODO: Implementa la creación de círculo
              },
              onJoinPressed: () {
                // TODO: Implementa unirse a círculo
              },
            ),

          ]
        )
      )
    );
  }
}

