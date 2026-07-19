import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL']!;
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY']!;
  static String get paystackPublicKey => dotenv.env['PAYSTACK_PUBLIC_KEY'] ?? '';
  static String get flutterwavePublicKey => dotenv.env['FLUTTERWAVE_PUBLIC_KEY'] ?? '';
  static String get stripePublishableKey => dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  static String get agoraAppId => dotenv.env['AGORA_APP_ID'] ?? '';
  static String get openAIApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get googleTranslateApiKey => dotenv.env['GOOGLE_TRANSLATE_API_KEY'] ?? '';
  static String get infuraProjectId => dotenv.env['INFURA_PROJECT_ID'] ?? '';
  static String get openSeaApiKey => dotenv.env['OPENSEA_API_KEY'] ?? '';
  static String get elevenLabsApiKey => dotenv.env['ELEVENLABS_API_KEY'] ?? '';
}