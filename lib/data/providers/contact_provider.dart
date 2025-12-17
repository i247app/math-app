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
  final Set<String> _readIds = {};

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
        // populate read ids from response if provided
        _readIds.clear();
        for (final it in _items!) {
          if (it.isRead == true) _readIds.add(it.id);
        }
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

  Future<bool> markAsRead(String contactId) async {
    try {
      final success = await _contactRepository.markAsRead(contactId);
      if (success) {
        _readIds.add(contactId);
        // also update local model if present
        if (_items != null) {
          for (var i = 0; i < _items!.length; i++) {
            if (_items![i].id == contactId) {
              _items![i] = ContactModel(
                id: _items![i].id,
                uid: _items![i].uid,
                contactName: _items![i].contactName,
                contactEmail: _items![i].contactEmail,
                contactPhone: _items![i].contactPhone,
                contactMessage: _items![i].contactMessage,
                isRead: true,
              );
              break;
            }
          }
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
