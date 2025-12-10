import 'package:flutter/material.dart';


enum CardNetwork { Visa, Mastercard, AmericanExpress, Discover, Unknown, Invalid }

abstract class CardUtils {
  static CardNetwork getCardTypeFromString(String cardNumber) {
    String cleanNumber = cardNumber.replaceAll(RegExp(r'[\s-]'), '');

    if (cleanNumber.isEmpty) {
      return CardNetwork.Unknown;
    }

    if (cleanNumber.startsWith('4')) {
      if (cleanNumber.length == 16 || cleanNumber.length == 19) {
        return CardNetwork.Visa;
      } else if (cleanNumber.length > 19) {
        return CardNetwork.Invalid;
      } else if (cleanNumber.length == 1) {
        return CardNetwork.Visa;
      }
    }

    if (RegExp(r'^5[1-5]').hasMatch(cleanNumber)) {
      if (cleanNumber.length == 16) {
        return CardNetwork.Mastercard;
      } else if (cleanNumber.length > 2 && cleanNumber.length < 16) {
        return CardNetwork.Mastercard;
      } else if (cleanNumber.length > 16) {
        return CardNetwork.Invalid;
      } else if (cleanNumber.length <= 2) {
        return CardNetwork.Mastercard;
      }
    }
    if (cleanNumber.length >= 4) {
      int prefix4 = int.tryParse(cleanNumber.substring(0, 4)) ?? 0;
      if (prefix4 >= 2221 && prefix4 <= 2720) {
        if (cleanNumber.length == 16) {
          return CardNetwork.Mastercard;
        } else if (cleanNumber.length < 16) {
          return CardNetwork.Mastercard;
        } else {
          return CardNetwork.Invalid;
        }
      }
    }

    if (cleanNumber.startsWith('34') || cleanNumber.startsWith('37')) {
      if (cleanNumber.length == 15) {
        return CardNetwork.AmericanExpress;
      } else if (cleanNumber.length > 2 && cleanNumber.length < 15) {
        return CardNetwork.AmericanExpress;
      } else if (cleanNumber.length > 15) {
        return CardNetwork.Invalid;
      } else if (cleanNumber.length <= 2) {
        return CardNetwork.AmericanExpress;
      }
    }

    if (cleanNumber.startsWith('6011')) {
      if (cleanNumber.length == 16 || cleanNumber.length == 19) {
        return CardNetwork.Discover;
      } else if (cleanNumber.length > 4 && cleanNumber.length < 16) {
        return CardNetwork.Discover;
      } else if (cleanNumber.length > 19) {
        return CardNetwork.Invalid;
      } else if (cleanNumber.length <= 4) {
        return CardNetwork.Discover;
      }
    }
    if (cleanNumber.startsWith('65')) {
      if (cleanNumber.length == 16 || cleanNumber.length == 19) {
        return CardNetwork.Discover;
      } else if (cleanNumber.length > 2 && cleanNumber.length < 16) {
        return CardNetwork.Discover;
      } else if (cleanNumber.length > 19) {
        return CardNetwork.Invalid;
      } else if (cleanNumber.length <= 2) {
        return CardNetwork.Discover;
      }
    }
    if (cleanNumber.length >= 3) {
      int prefix3 = int.tryParse(cleanNumber.substring(0, 3)) ?? 0;
      if (prefix3 >= 644 && prefix3 <= 649) {
        if (cleanNumber.length == 16 || cleanNumber.length == 19) {
          return CardNetwork.Discover;
        } else if (cleanNumber.length > 3 && cleanNumber.length < 16) {
          return CardNetwork.Discover;
        } else if (cleanNumber.length > 19) {
          return CardNetwork.Invalid;
        } else if (cleanNumber.length == 3) {
          return CardNetwork.Discover;
        }
      }
    }

    if (cleanNumber.startsWith('4')) {
      if (cleanNumber.length < 16) {
        return CardNetwork.Visa;
      }
      if (cleanNumber.length == 16 || cleanNumber.length == 19) {
        return CardNetwork.Visa;
      }
      return CardNetwork.Invalid;
    }
    return CardNetwork.Unknown;
  }

  static String getNetworkPrettyName(CardNetwork cardType) {
    switch (cardType) {
      case CardNetwork.Visa:
        return "Visa";
      case CardNetwork.Mastercard:
        return "Mastercard";
      case CardNetwork.AmericanExpress:
        return "American Express";
      case CardNetwork.Discover:
        return "Discover";
      case CardNetwork.Invalid:
        return "Invalid Card Number";
      case CardNetwork.Unknown:
        return "Unknown Card";
    }
  }

  static String getNetworkServerCode(CardNetwork cardType) {
    switch (cardType) {
      case CardNetwork.Visa:
        return "visa";
      case CardNetwork.Mastercard:
        return "mastercard";
      case CardNetwork.AmericanExpress:
        return "amex";
      case CardNetwork.Discover:
        return "discover";
      case CardNetwork.Invalid:
        return "";
      case CardNetwork.Unknown:
        return "";
    }
  }

  static Widget getCardIcon(CardNetwork cardType, {double size = 40.0}) {
    String? assetName;
    Color iconColor = Colors.grey;

    switch (cardType) {
      case CardNetwork.Visa:
        assetName = 'assets/icons/visa.webp';
        iconColor = Colors.blue[700]!;
        break;
      case CardNetwork.Mastercard:
        assetName = 'assets/icons/mastercard.png';
        iconColor = Colors.orange[700]!;
        break;
      case CardNetwork.AmericanExpress:
        assetName = 'assets/icons/american_express.webp';
        iconColor = Colors.green[700]!;
        break;
      case CardNetwork.Discover:
        assetName = 'assets/icons/discover.png';
        iconColor = Colors.purple[700]!;
        break;
      case CardNetwork.Invalid:
        return Icon(Icons.error_outline, size: size, color: Colors.red);
      case CardNetwork.Unknown:
        return Icon(Icons.credit_card, size: size, color: iconColor);
    }

    return Image.asset(assetName, width: size, height: size);
  }
}
