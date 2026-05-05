class ProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String type;
  final String linkingCode;
  final LinkedPatientModel? linkedPatient; // caregiver: their linked patient
  final String? linkedCaregiverName; // patient: their caregiver's name

  const ProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.type,
    required this.linkingCode,
    this.linkedPatient,
    this.linkedCaregiverName,
  });

  bool get isPatient => type == 'paciente';
  bool get isCaregiver => type == 'cuidador';
  bool get hasLinkedPatient => linkedPatient != null;
  bool get hasLinkedCaregiver => linkedCaregiverName != null;
}

class LinkedPatientModel {
  final String id;
  final String fullName;
  final String linkingCode;

  const LinkedPatientModel({
    required this.id,
    required this.fullName,
    required this.linkingCode,
  });
}
