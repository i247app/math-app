/// Shared HTTP status predicates. Feature-specific API statuses belong in the
/// feature that defines them.
bool isUnauthorizedHttpStatus(int? status) => status == 401 || status == 403;
