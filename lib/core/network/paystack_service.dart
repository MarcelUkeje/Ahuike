import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_client.dart';

/// Handles Paystack payment operations by proxying through the Ahuike backend.
///
/// The Paystack *secret* key lives only in the backend environment.
/// This service uses the shared [ApiClient] (which attaches the patient's JWT)
/// to call the backend's /api/v1/payments endpoints.
class PaystackService {
  final ApiClient _client;

  PaystackService(this._client);

  /// Returns the Paystack public key from .env (safe to expose — not a secret).
  static String get publicKey {
    final key = dotenv.env['PAYSTACK_PUBLIC_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('PAYSTACK_PUBLIC_KEY not found in .env file.');
    }
    return key;
  }

  /// Initialize a payment via the backend.
  ///
  /// Returns a map containing at minimum:
  ///   - `authorization_url` — open this URL in the browser
  ///   - `reference`         — store this for verification
  Future<Map<String, dynamic>> initializePayment({
    required String email,
    required int amountInKobo,
    required String reference,
  }) async {
    final response = await _client.post(
      '/payments/initialize',
      body: {
        'email': email,
        'amountInKobo': amountInKobo,
        'reference': reference,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// Verify a payment via the backend.
  ///
  /// Returns `true` if Paystack reports the transaction as successful.
  Future<bool> verifyPayment(String reference) async {
    try {
      final response = await _client.get('/payments/verify/$reference');
      final data = response.data as Map<String, dynamic>;
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }
}
