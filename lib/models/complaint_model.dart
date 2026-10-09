class ComplaintModel {
  final String id;
  final String bookingId;
  final String serviceType; // 'ride', 'rent', 'sevak', 'driver'
  final String customerId;
  final String customerName;
  final String providerId;
  final String providerName;
  final String complaintType; // 'Overcharge', 'Late', 'BadBehaviour', 'VehicleIssue', 'PaymentIssue', 'Other'
  final String description;
  final String photoUrl;
  final String status; // 'pending_admin', 'resolved', 'warning', 'blocked'
  final String createdAt;

  ComplaintModel({
    required this.id,
    required this.bookingId,
    required this.serviceType,
    required this.customerId,
    required this.customerName,
    required this.providerId,
    required this.providerName,
    required this.complaintType,
    required this.description,
    this.photoUrl = '',
    this.status = 'pending_admin',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingId': bookingId,
      'serviceType': serviceType,
      'customerId': customerId,
      'customerName': customerName,
      'providerId': providerId,
      'providerName': providerName,
      'complaintType': complaintType,
      'description': description,
      'photoUrl': photoUrl,
      'status': status,
      'createdAt': createdAt,
    };
  }

  factory ComplaintModel.fromMap(Map<String, dynamic> map, String docId) {
    return ComplaintModel(
      id: docId,
      bookingId: map['bookingId'] ?? '',
      serviceType: map['serviceType'] ?? 'ride',
      customerId: map['customerId'] ?? 'user_current',
      customerName: map['customerName'] ?? 'Bharat Customer',
      providerId: map['providerId'] ?? '',
      providerName: map['providerName'] ?? 'Partner',
      complaintType: map['complaintType'] ?? 'Other',
      description: map['description'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      status: map['status'] ?? 'pending_admin',
      createdAt: map['createdAt'] ?? DateTime.now().toIso8601String(),
    );
  }
}
