enum MStatusCode {
  ok(200),
  success(200),
  duplicateSuccess(201),
  noExist(202),
  deleted(204),
  transactionDuplicate(322),
  badRequest(400),
  unauthorized(401),
  identifierBlock(402),
  deviceBlock(403),
  notFound(404),
  duplicate(409),
  transactionFailed(411),
  txPayAuthDeclined(412),
  txPayCaptureDeclined(413),
  unprocessable(422),
  tooManyRequests(429),
  cardExpired(435),
  cvvIncorrect(443),
  invalidCard(450),
  blocked(480),
  readOnly(481),
  transactionHold(488),
  internal(500);

  final int value;

  const MStatusCode(this.value);
}
