bool isAuthUserNotFoundStatus(int? status) => status == 202 || status == 4006;

bool blocksAuthLoginActions(int? status) => status == 4006;
