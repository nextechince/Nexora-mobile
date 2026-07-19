nexora_mobile/
├── android/                         # Android native
├── ios/                             # iOS native
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── config/
│   │   ├── constants.dart
│   │   ├── env.dart
│   │   ├── routes.dart
│   │   └── theme.dart
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── chat_model.dart
│   │   ├── message_model.dart
│   │   ├── story_model.dart
│   │   ├── transaction_model.dart
│   │   └── ...
│   ├── providers/                   # Riverpod providers
│   │   ├── auth_provider.dart
│   │   ├── chat_provider.dart
│   │   ├── message_provider.dart
│   │   ├── story_provider.dart
│   │   ├── wallet_provider.dart
│   │   └── ...
│   ├── services/
│   │   ├── supabase_service.dart
│   │   ├── auth_service.dart
│   │   ├── storage_service.dart
│   │   ├── notification_service.dart
│   │   ├── call_service.dart       # via Twilio or Agora
│   │   └── payment_service.dart    # Paystack/Flutterwave etc.
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── auth/
│   │   │   ├── phone_login_screen.dart
│   │   │   ├── otp_verification_screen.dart
│   │   │   └── create_account_screen.dart
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   ├── chat_list_tile.dart
│   │   │   ├── stories_carousel.dart
│   │   │   └── ...
│   │   ├── chat/
│   │   │   ├── chat_screen.dart
│   │   │   ├── message_bubble.dart
│   │   │   ├── input_bar.dart
│   │   │   └── media_picker.dart
│   │   ├── groups/
│   │   │   ├── group_info_screen.dart
│   │   │   ├── create_group_screen.dart
│   │   │   └── ...
│   │   ├── channels/
│   │   │   ├── channel_screen.dart
│   │   │   └── ...
│   │   ├── calls/
│   │   │   ├── call_screen.dart
│   │   │   ├── call_history_screen.dart
│   │   │   └── ...
│   │   ├── stories/
│   │   │   ├── story_viewer.dart
│   │   │   └── create_story_screen.dart
│   │   ├── profile/
│   │   │   ├── profile_screen.dart
│   │   │   └── edit_profile_screen.dart
│   │   ├── wallet/
│   │   │   ├── wallet_screen.dart
│   │   │   ├── transaction_history.dart
│   │   │   ├── buy_coins_screen.dart
│   │   │   └── withdraw_screen.dart
│   │   ├── premium/
│   │   │   └── premium_screen.dart
│   │   ├── settings/
│   │   │   ├── settings_screen.dart
│   │   │   ├── privacy_screen.dart
│   │   │   ├── security_screen.dart
│   │   │   ├── appearance_screen.dart
│   │   │   ├── devices_screen.dart
│   │   │   ├── blocked_users_screen.dart
│   │   │   └── delete_account_screen.dart
│   │   └── ...
│   ├── widgets/
│   │   ├── glassmorphic_card.dart
│   │   ├── glowing_button.dart
│   │   ├── animated_logo.dart
│   │   ├── shimmer_loading.dart
│   │   └── ...
│   ├── utils/
│   │   ├── helpers.dart
│   │   ├── validators.dart
│   │   └── extensions.dart
│   └── main.dart
├── assets/
│   ├── fonts/
│   ├── images/
│   ├── icons/
│   ├── animations/                # Rive/Flare files
│   └── env/
│       ├── .env.dev
│       └── .env.prod
├── pubspec.yaml
└── ...