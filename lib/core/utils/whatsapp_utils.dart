import 'package:url_launcher/url_launcher.dart';
import 'package:kimo_clean/core/constants/app_strings.dart';

class WhatsAppUtils {
  /// Converts a local Egyptian mobile number (011xxx / 010xxx / 012xxx / 015xxx)
  /// to international format required by wa.me.
  static String _toInternational(String local) {
    final cleaned = local.replaceAll(RegExp(r'[\s\-\+]'), '');
    if (cleaned.startsWith('0') && cleaned.length == 11) {
      return '20${cleaned.substring(1)}';
    }
    // Already international or unknown format — return as-is.
    return cleaned;
  }

  /// Sends the order details to the **customer's** WhatsApp number.
  static Future<void> launch({
    required int serialNumber,
    required String customerCode,
    required String customerName,
    required String phone,
    required String address,
    required Map<String, int> items,
    required int totalPieces,
    String? notes,
  }) async {
    final StringBuffer message = StringBuffer();
    message.writeln(AppStrings.whatsappMessageHeader);
    message.writeln(AppStrings.whatsappMessageSeparator);
    message.writeln('${AppStrings.whatsappCustomerCodePrefix}$customerCode');
    message.writeln(AppStrings.whatsappOrderReceivedSuccess);
    message.writeln(AppStrings.whatsappMessageSeparator);
    message.writeln('${AppStrings.whatsappOrderNumberPrefix}$serialNumber');
    message.writeln('${AppStrings.whatsappCustomerPrefix}$customerName');
    message.writeln('${AppStrings.whatsappPhonePrefix}$phone');
    message.writeln('${AppStrings.whatsappAddressPrefix}$address');
    message.writeln('');
    message.writeln(AppStrings.whatsappItemsHeader);

    items.forEach((name, quantity) {
      if (quantity > 0) {
        message.writeln('▫️ $name: ($quantity)');
      }
    });

    message.writeln(AppStrings.whatsappMessageSeparator);
    message.writeln('${AppStrings.whatsappTotalPiecesPrefix}$totalPieces');

    if (notes != null && notes.isNotEmpty) {
      message.writeln('');
      message.writeln('${AppStrings.whatsappNotesPrefix}$notes');
    }

    // Target = customer's phone in international format.
    final String internationalPhone = _toInternational(phone);

    // Build URL using Uri constructor for correct query-parameter encoding.
    final Uri whatsappUrl = Uri.https('wa.me', '/$internationalPhone', {
      'text': message.toString(),
    });

    // Launch directly — canLaunchUrl is unreliable on Android 11+.
    final bool launched = await launchUrl(
      whatsappUrl,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      throw Exception(AppStrings.whatsappErrorLaunch);
    }
  }
}
