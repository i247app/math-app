import '../network/network.dart' as network;
import '../responses/contact/list_contact_response.dart';

class ContactRepository {
  Future<ListContactResponse> getContacts({int page = 1, int size = 10}) async {
    final response = await network.getContactsList(page: page, size: size);
    return response;
  }
}
