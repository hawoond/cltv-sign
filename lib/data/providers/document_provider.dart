import 'package:flutter/foundation.dart';
import '../models/document_model.dart';
import '../services/mock_data_service.dart';

class DocumentProvider extends ChangeNotifier {
  List<Document> _documents = [];
  List<DocumentTemplate> _templates = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  DocumentStatus? _filterStatus;
  String? _filterCategory;

  List<Document> get documents => _filteredDocuments;
  List<DocumentTemplate> get templates => _templates;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  DocumentStatus? get filterStatus => _filterStatus;

  List<Document> get _filteredDocuments {
    var result = _documents;
    if (_searchQuery.isNotEmpty) {
      result = result.where((d) =>
        d.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (d.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }
    if (_filterStatus != null) {
      result = result.where((d) => d.status == _filterStatus).toList();
    }
    if (_filterCategory != null) {
      result = result.where((d) => d.category == _filterCategory).toList();
    }
    return result;
  }

  List<Document> get pendingDocuments =>
      _documents.where((d) => d.status == DocumentStatus.pending || d.status == DocumentStatus.inProgress).toList();
  List<Document> get completedDocuments =>
      _documents.where((d) => d.status == DocumentStatus.completed).toList();
  List<Document> get draftDocuments =>
      _documents.where((d) => d.status == DocumentStatus.draft).toList();
  List<Document> get recentDocuments =>
      _documents.take(5).toList();

  Future<void> loadDocuments(String userId) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    _documents = MockDataService.getDemoDocuments(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTemplates(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _templates = MockDataService.getDemoTemplates(userId);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterStatus(DocumentStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setFilterCategory(String? category) {
    _filterCategory = category;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterStatus = null;
    _filterCategory = null;
    notifyListeners();
  }

  Future<Document> createDocument({
    required String title,
    required String ownerId,
    required String ownerName,
    String? description,
    String? fileName,
    int? fileSize,
    int pageCount = 1,
    String? category,
  }) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    final doc = Document(
      title: title,
      ownerId: ownerId,
      ownerName: ownerName,
      description: description,
      fileName: fileName,
      fileSize: fileSize,
      pageCount: pageCount,
      category: category,
      status: DocumentStatus.draft,
    );
    _documents.insert(0, doc);
    _isLoading = false;
    notifyListeners();
    return doc;
  }

  Future<void> updateDocument(Document document) async {
    final index = _documents.indexWhere((d) => d.id == document.id);
    if (index != -1) {
      _documents[index] = document;
      notifyListeners();
    }
  }

  Future<void> sendSignRequest(String documentId) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));
    final index = _documents.indexWhere((d) => d.id == documentId);
    if (index != -1) {
      _documents[index] = _documents[index].copyWith(
        status: DocumentStatus.pending,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> cancelDocument(String documentId) async {
    final index = _documents.indexWhere((d) => d.id == documentId);
    if (index != -1) {
      _documents[index] = _documents[index].copyWith(status: DocumentStatus.cancelled);
      notifyListeners();
    }
  }

  Future<void> deleteDocument(String documentId) async {
    _documents.removeWhere((d) => d.id == documentId);
    notifyListeners();
  }

  Document? getDocumentById(String id) {
    try {
      return _documents.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addParticipant(String documentId, Participant participant) async {
    final index = _documents.indexWhere((d) => d.id == documentId);
    if (index != -1) {
      final doc = _documents[index];
      final updatedParticipants = [...doc.participants, participant];
      _documents[index] = doc.copyWith(participants: updatedParticipants);
      notifyListeners();
    }
  }

  Future<void> removeParticipant(String documentId, String participantId) async {
    final index = _documents.indexWhere((d) => d.id == documentId);
    if (index != -1) {
      final doc = _documents[index];
      final updatedParticipants = doc.participants.where((p) => p.id != participantId).toList();
      _documents[index] = doc.copyWith(participants: updatedParticipants);
      notifyListeners();
    }
  }

  Future<void> addSignField(String documentId, SignField field) async {
    final index = _documents.indexWhere((d) => d.id == documentId);
    if (index != -1) {
      final doc = _documents[index];
      final updatedFields = [...doc.signFields, field];
      _documents[index] = doc.copyWith(signFields: updatedFields);
      notifyListeners();
    }
  }

  Future<void> updateSignField(String documentId, SignField field) async {
    final index = _documents.indexWhere((d) => d.id == documentId);
    if (index != -1) {
      final doc = _documents[index];
      final updatedFields = doc.signFields.map((f) => f.id == field.id ? field : f).toList();
      _documents[index] = doc.copyWith(signFields: updatedFields);
      notifyListeners();
    }
  }

  Future<void> removeSignField(String documentId, String fieldId) async {
    final index = _documents.indexWhere((d) => d.id == documentId);
    if (index != -1) {
      final doc = _documents[index];
      final updatedFields = doc.signFields.where((f) => f.id != fieldId).toList();
      _documents[index] = doc.copyWith(signFields: updatedFields);
      notifyListeners();
    }
  }

  Future<bool> submitSignature({
    required String documentId,
    required String participantId,
    required String signatureData,
  }) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1000));
    final index = _documents.indexWhere((d) => d.id == documentId);
    if (index != -1) {
      final doc = _documents[index];
      final updatedParticipants = doc.participants.map((p) {
        if (p.id == participantId) {
          return p.copyWith(
            status: ParticipantStatus.signed,
            signedAt: DateTime.now(),
            signatureData: signatureData,
          );
        }
        return p;
      }).toList();
      final allSigned = updatedParticipants.every((p) => p.status == ParticipantStatus.signed);
      _documents[index] = doc.copyWith(
        participants: updatedParticipants,
        status: allSigned ? DocumentStatus.completed : DocumentStatus.inProgress,
        completedAt: allSigned ? DateTime.now() : null,
      );
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }
}
