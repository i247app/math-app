bool isAuthUserNotFoundStatus(int? status) =>
    status == 202 || status == 4006 || status == 4206;

bool blocksAuthLoginActions(int? status) => status == 4006;
