import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PaystackService {
  static String get _secretKey {
    final key = dotenv.env['PAYSTACK_SECRET_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('PAYSTACK_SECRET_KEY not found in .env file. Please add your test key.');
    }
    return key;
  }

  static Future<Map<String, dynamic>> initializePayment({
    required String email,
    required int amountInKobo,
    required String reference,
  }) async {
    final response = await http.post(
      Uri.parse('https://api.paystack.co/transaction/initialize'),
      headers: {
        'Authorization': 'Bearer $_secretKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'amount': amountInKobo,
        'reference': reference,
        'channels': ['card', 'bank', 'ussd', 'qr', 'mobile_money', 'bank_transfer'],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']; // contains authorization_url, access_code, reference
    } else {
      throw Exception('Paystack init failed: ${response.body}');
    }
  }

  static Future<bool> verifyPayment(String reference) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.paystack.co/transaction/verify/$reference'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['status'] == 'success';
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
