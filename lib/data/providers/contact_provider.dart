import 'package:flutter/foundation.dart';

import '../models/contact/contact_model.dart';
import '../repositories/contact_repository.dart';
import '../models/grades/metadata_model.dart';

class ContactProvider with ChangeNotifier, DiagnosticableTreeMixin {
  final ContactRepository _contactRepository = ContactRepository();

  List<ContactModel>? _items;
  MetadataModel? _metadata;
  bool _isLoading = false;
  String? _error;

  List<ContactModel>? get items => _items;
  MetadataModel? get metadata => _metadata;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadContacts({int page = 1, int size = 10}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _contactRepository.getContacts(
        page: page,
        size: size,
      );
      if (response.isSuccess && response.items != null) {
        _items = response.items;
        _metadata = response.metadata;
      } else {
        _error =
            response.error ?? response.message ?? 'Failed to load contacts';
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
