import 'package:uuid/uuid.dart';

enum DocumentStatus {
  draft,
  pending,
  inProgress,
  completed,
  rejected,
  expired,
  cancelled,
}

enum SignFieldType {
  signature,
  text,
  date,
  checkbox,
  stamp,
  initial,
  initials,
}

enum SendMethod {
  email,
  kakao,
  link,
  qr,
  inPerson,
  bulk,
}

class SignField {
  final String id;
  final SignFieldType type;
  final double x;
  final double y;
  final double width;
  final double height;
  final int pageIndex;
  final String participantId;
  final String? label;
  final bool required;
  final String? value;

  SignField({
    String? id,
    required this.type,
    required this.x,
    required this.y,
    this.width = 160,
    this.height = 50,
    required this.pageIndex,
    required this.participantId,
    this.label,
    this.required = true,
    this.value,
  }) : id = id ?? const Uuid().v4();

  SignField copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    String? value,
    String? label,
  }) {
    return SignField(
      id: id,
      type: type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      pageIndex: pageIndex,
      participantId: participantId,
      label: label ?? this.label,
      required: required,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    'pageIndex': pageIndex,
    'participantId': participantId,
    'label': label,
    'required': required,
    'value': value,
  };
}

class Participant {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final int order;
  final SendMethod sendMethod;
  final ParticipantStatus status;
  final DateTime? signedAt;
  final String? signatureData;

  Participant({
    String? id,
    required this.name,
    required this.email,
    this.phone,
    required this.order,
    this.sendMethod = SendMethod.email,
    this.status = ParticipantStatus.pending,
    this.signedAt,
    this.signatureData,
  }) : id = id ?? const Uuid().v4();

  Participant copyWith({
    ParticipantStatus? status,
    DateTime? signedAt,
    String? signatureData,
  }) {
    return Participant(
      id: id,
      name: name,
      email: email,
      phone: phone,
      order: order,
      sendMethod: sendMethod,
      status: status ?? this.status,
      signedAt: signedAt ?? this.signedAt,
      signatureData: signatureData ?? this.signatureData,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'order': order,
    'sendMethod': sendMethod.name,
    'status': status.name,
    'signedAt': signedAt?.toIso8601String(),
  };
}

enum ParticipantStatus {
  pending,
  viewed,
  signed,
  rejected,
}

class Document {
  final String id;
  final String title;
  final String? description;
  final String ownerId;
  final String ownerName;
  final DocumentStatus status;
  final List<Participant> participants;
  final List<SignField> signFields;
  final String? filePath;
  final String? fileName;
  final int? fileSize;
  final int pageCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;
  final DateTime? completedAt;
  final String? category;
  final List<String> tags;
  final String? message;
  final bool requireAuth;
  final String? signLink;
  final String? templateId;

  Document({
    String? id,
    required this.title,
    this.description,
    required this.ownerId,
    required this.ownerName,
    this.status = DocumentStatus.draft,
    List<Participant>? participants,
    List<SignField>? signFields,
    this.filePath,
    this.fileName,
    this.fileSize,
    this.pageCount = 1,
    DateTime? createdAt,
    this.updatedAt,
    this.expiresAt,
    this.completedAt,
    this.category,
    List<String>? tags,
    this.message,
    this.requireAuth = false,
    this.signLink,
    this.templateId,
  })  : id = id ?? const Uuid().v4(),
        participants = participants ?? [],
        signFields = signFields ?? [],
        tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now();

  Document copyWith({
    String? title,
    String? description,
    DocumentStatus? status,
    List<Participant>? participants,
    List<SignField>? signFields,
    String? filePath,
    String? fileName,
    int? fileSize,
    int? pageCount,
    DateTime? updatedAt,
    DateTime? expiresAt,
    DateTime? completedAt,
    String? category,
    List<String>? tags,
    String? message,
    bool? requireAuth,
    String? signLink,
  }) {
    return Document(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      ownerId: ownerId,
      ownerName: ownerName,
      status: status ?? this.status,
      participants: participants ?? this.participants,
      signFields: signFields ?? this.signFields,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      pageCount: pageCount ?? this.pageCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      expiresAt: expiresAt ?? this.expiresAt,
      completedAt: completedAt ?? this.completedAt,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      message: message ?? this.message,
      requireAuth: requireAuth ?? this.requireAuth,
      signLink: signLink ?? this.signLink,
      templateId: templateId,
    );
  }

  int get signedCount => participants.where((p) => p.status == ParticipantStatus.signed).length;
  int get totalCount => participants.length;
  double get progress => totalCount == 0 ? 0 : signedCount / totalCount;

  String get statusLabel {
    switch (status) {
      case DocumentStatus.draft: return '임시저장';
      case DocumentStatus.pending: return '서명 대기';
      case DocumentStatus.inProgress: return '서명 진행중';
      case DocumentStatus.completed: return '완료';
      case DocumentStatus.rejected: return '거절됨';
      case DocumentStatus.expired: return '만료됨';
      case DocumentStatus.cancelled: return '취소됨';
    }
  }
}

class DocumentTemplate {
  final String id;
  final String title;
  final String? description;
  final String ownerId;
  final String category;
  final List<SignField> signFields;
  final String? filePath;
  final String? fileName;
  final int pageCount;
  final DateTime createdAt;
  final int usageCount;
  final bool isPublic;

  DocumentTemplate({
    String? id,
    required this.title,
    this.description,
    required this.ownerId,
    required this.category,
    List<SignField>? signFields,
    this.filePath,
    this.fileName,
    this.pageCount = 1,
    DateTime? createdAt,
    this.usageCount = 0,
    this.isPublic = false,
  })  : id = id ?? const Uuid().v4(),
        signFields = signFields ?? [],
        createdAt = createdAt ?? DateTime.now();
}
