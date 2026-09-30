import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// When Company Posts Job - FREE - Trigger Alert to Candidates
Future<void> sendAlertToCandidates(String jobTitle, String payrollType) async {
  try {
    var candidates = await FirebaseFirestore.instance
        .collection('candidates')
        .where('subscription_active', isEqualTo: true)
        .get();

    // If no candidate exists in Firestore yet, ensure default candidate doc exists so alert can be saved & observed
    if (candidates.docs.isEmpty) {
      await FirebaseFirestore.instance.collection('candidates').doc('current_user_id').set({
        'name': 'Candidate User',
        'subscription_active': true,
        'subscription_plan': '349/Y Active',
        'created_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      candidates = await FirebaseFirestore.instance
          .collection('candidates')
          .where('subscription_active', isEqualTo: true)
          .get();
    }

    for (var cand in candidates.docs) {
      await FirebaseFirestore.instance
          .collection('candidates')
          .doc(cand.id)
          .collection('alerts')
          .add({
        'title': 'New Job Alert - $payrollType',
        'message': '$jobTitle - Company FREE Posted - Apply Now',
        'time': FieldValue.serverTimestamp(),
      });
    }
  } catch (e) {
    debugPrint('Error triggering candidate alerts: $e');
  }
}

// When Candidate Applies - Trigger Alert to Company
Future<void> sendAlertToCompany(String companyId, String candidateName) async {
  try {
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(companyId)
        .collection('alerts')
        .add({
      'title': 'New Application',
      'message': '$candidateName applied for your job - Check Dashboard',
      'time': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    debugPrint('Error triggering company alert: $e');
  }
}
