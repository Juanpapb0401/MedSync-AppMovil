class ProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String type;
  final LinkedPatientModel? linkedPatient; // caregiver: their linked patient
  final String? linkedCaregiverName; // patient: their caregiver's name

  const ProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.type,
    this.linkedPatient,
    this.linkedCaregiverName,
  });

  bool get isCaregiver => type == 'cuidador';
  bool get hasLinkedPatient => linkedPatient != null;
  bool get hasLinkedCaregiver => linkedCaregiverName != null;

  /// Full UUID — shared by the patient so a caregiver can link to them.
  String get linkingCode => id;
}

class LinkedPatientModel {
  final String id;
  final String fullName;

  const LinkedPatientModel({required this.id, required this.fullName});
}
