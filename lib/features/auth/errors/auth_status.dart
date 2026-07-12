bool isOtpValidationStatus(int? status) =>
    status == 400 || status == 422 || status == 4706;

bool isAuthUserNotFoundStatus(int? status) => status == 202 || status == 4006;

bool blocksAuthLoginActions(int? status) => status == 4006;
