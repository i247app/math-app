/// A returned user means the identifier is already registered.
/// An unrecognized response must not be treated as an available identifier.
bool? identifierExistsFromResponse(Object? response) {
  if (response is! Map || !response.containsKey('user')) return null;

  final user = response['user'];
  if (user == null) return false;
  if (user is Map && user.isNotEmpty) return true;
  return null;
}
