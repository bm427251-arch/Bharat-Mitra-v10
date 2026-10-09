import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String id;
  final String companyId;
  final String companyName;
  final String jobTitle;
  final String payrollType; // 'Company Payroll' | 'Vendor Payroll' | 'Private'
  final String salary;
  final String location;
  final bool postedFree;
  final String contactPhone;
  final String description;
  final int vacancies;
  final DateTime createdAt;

  const JobModel({
    required this.id,
    this.companyId = 'current_company_id',
    required this.companyName,
    required this.jobTitle,
    required this.payrollType,
    required this.salary,
    required this.location,
    this.postedFree = true,
    this.contactPhone = '',
    this.description = '',
    this.vacancies = 1,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'company_id': companyId,
      'company_name': companyName,
      'job_title': jobTitle,
      'payroll_type': payrollType,
      'salary': salary,
      'location': location,
      'posted_free': postedFree,
      'contact_phone': contactPhone,
      'description': description,
      'vacancies': vacancies,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  factory JobModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return JobModel.fromMap(data, doc.id);
  }

  factory JobModel.fromMap(Map<String, dynamic> map, [String id = '']) {
    DateTime created;
    final rawDate = map['created_at'];
    if (rawDate is Timestamp) {
      created = rawDate.toDate();
    } else if (rawDate is String) {
      created = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      created = DateTime.now();
    }

    return JobModel(
      id: id.isNotEmpty ? id : (map['id'] as String? ?? ''),
      companyId: map['company_id'] as String? ?? 'current_company_id',
      companyName: map['company_name'] as String? ?? '',
      jobTitle: map['job_title'] as String? ?? 'Driver',
      payrollType: map['payroll_type'] as String? ?? 'Company Payroll',
      salary: map['salary'] as String? ?? '₹18,000 / month',
      location: map['location'] as String? ?? 'Kolkata',
      postedFree: map['posted_free'] as bool? ?? true,
      contactPhone: map['contact_phone'] as String? ?? '',
      description: map['description'] as String? ?? '',
      vacancies: (map['vacancies'] as num?)?.toInt() ?? 1,
      createdAt: created,
    );
  }
}
