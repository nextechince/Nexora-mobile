import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth/phone_login_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/auth/create_account_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/groups/groups_screen.dart';
import '../screens/groups/group_info_screen.dart';
import '../screens/groups/create_group_screen.dart';
import '../screens/groups/group_members_screen.dart';
import '../screens/channels/channels_screen.dart';
import '../screens/channels/channel_screen.dart';
import '../screens/channels/create_channel_screen.dart';
import '../screens/channels/channel_info_screen.dart';
import '../screens/calls/call_history_screen.dart';
import '../screens/calls/call_screen.dart';
import '../screens/stories/story_viewer.dart';
import '../screens/stories/create_story_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import '../screens/wallet/transaction_history.dart';
import '../screens/wallet/buy_coins_screen.dart';
import '../screens/wallet/withdraw_screen.dart';
import '../screens/wallet/deposit_screen.dart';
import '../screens/premium/premium_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/privacy_screen.dart';
import '../screens/settings/security_screen.dart';
import '../screens/settings/appearance_screen.dart';
import '../screens/settings/devices_screen.dart';
import '../screens/settings/blocked_users_screen.dart';
import '../screens/settings/storage_screen.dart';
import '../screens/settings/language_screen.dart';
import '../screens/settings/delete_account_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../providers/auth_provider.dart';
import '../screens/folders/folders_screen.dart';
import '../screens/folders/folder_detail_screen.dart';
import '../screens/settings/app_lock_screen.dart';
import '../screens/bot_platform/bot_creator_screen.dart';
import '../screens/bot_platform/bot_list_screen.dart';
import '../screens/bot_platform/bot_detail_screen.dart';
import '../screens/bot_platform/bot_webhook_screen.dart';
import '../screens/bot_platform/bot_commands_screen.dart';
import '../screens/bot_platform/bot_analytics_screen.dart';
import '../screens/bot_platform/bot_permissions_screen.dart';
import '../screens/bot_platform/bot_logs_screen.dart';
import '../screens/settings/developer_settings_screen.dart';
import '../screens/contacts/contacts_screen.dart';
import '../screens/contacts/contact_picker_screen.dart';
import '../screens/chat/secret_chat_screen.dart';
import '../screens/chat/ai_chat_screen.dart';
import '../screens/streaming/live_stream_screen.dart';
import '../screens/settings/chat_themes_screen.dart';
import '../screens/settings/auto_reply_screen.dart';
import '../screens/stickers/sticker_store_screen.dart';
import '../screens/wallet/crypto_wallet_screen.dart';
import '../screens/groups/group_voice_chat_screen.dart';
import '../screens/channels/channel_comments_screen.dart';
import '../screens/nft/nft_gallery_screen.dart';
import '../screens/nft/nft_detail_screen.dart';
import '../screens/stories/screen_recording_screen.dart';
import '../screens/premium/voice_cloning_screen.dart';
import '../screens/stories/ar_filter_screen.dart';
import '../screens/games/game_screen.dart';
import '../screens/games/game_lobby_screen.dart';
import '../screens/settings/translation_options_screen.dart';
import '../screens/security/two_factor_setup_screen.dart';
import '../screens/wallet/p2p_payment_screen.dart';
import '../screens/groups/group_admin_logs_screen.dart';
import '../screens/settings/language_selection_screen.dart';
import '../screens/calls/screen_share_screen.dart';

final onboardingCompleteProvider = Provider<bool>((ref) => false);

class AppRouter {
  static GoRouter router(ProviderRef ref) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final auth = ref.read(authStateProvider);
        final isLoggedIn = auth.value != null;
        final isOnboardingComplete = ref.read(onboardingCompleteProvider);
        if (state.matchedLocation == '/splash') return null;
        if (!isLoggedIn) return '/auth/login';
        if (!isOnboardingComplete) return '/onboarding';
        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
        GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
        GoRoute(path: '/auth/login', builder: (context, state) => const PhoneLoginScreen()),
        GoRoute(path: '/auth/otp', builder: (context, state) => const OtpVerificationScreen()),
        GoRoute(path: '/auth/create-account', builder: (context, state) => const CreateAccountScreen()),
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/chat/:chatId', builder: (context, state) => ChatScreen(chatId: state.params['chatId']!)),
        GoRoute(path: '/groups', builder: (context, state) => const GroupsScreen()),
        GoRoute(path: '/create-group', builder: (context, state) => const CreateGroupScreen()),
        GoRoute(path: '/group/:groupId', builder: (context, state) => GroupInfoScreen(groupId: state.params['groupId']!)),
        GoRoute(path: '/group/:groupId/members', builder: (context, state) => GroupMembersScreen(groupId: state.params['groupId']!)),
        GoRoute(path: '/channels', builder: (context, state) => const ChannelsScreen()),
        GoRoute(path: '/create-channel', builder: (context, state) => const CreateChannelScreen()),
        GoRoute(path: '/channel/:channelId', builder: (context, state) => ChannelScreen(channelId: state.params['channelId']!)),
        GoRoute(path: '/channel/:channelId/info', builder: (context, state) => ChannelInfoScreen(channelId: state.params['channelId']!)),
        GoRoute(path: '/calls', builder: (context, state) => const CallHistoryScreen()),
        GoRoute(path: '/call/:callId', builder: (context, state) => CallScreen(callId: state.params['callId']!)),
        GoRoute(path: '/stories', builder: (context, state) => const StoryViewer()),
        GoRoute(path: '/create-story', builder: (context, state) => const CreateStoryScreen()),
        GoRoute(path: '/profile/:userId', builder: (context, state) => ProfileScreen(userId: state.params['userId']!)),
        GoRoute(path: '/edit-profile', builder: (context, state) => const EditProfileScreen()),
        GoRoute(path: '/wallet', builder: (context, state) => const WalletScreen()),
        GoRoute(path: '/wallet/transactions', builder: (context, state) => const TransactionHistoryScreen()),
        GoRoute(path: '/wallet/buy-coins', builder: (context, state) => const BuyCoinsScreen()),
        GoRoute(path: '/wallet/withdraw', builder: (context, state) => const WithdrawScreen()),
        GoRoute(path: '/wallet/deposit', builder: (context, state) => const DepositScreen()),
        GoRoute(path: '/premium', builder: (context, state) => const PremiumScreen()),
        GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
        GoRoute(path: '/settings/privacy', builder: (context, state) => const PrivacyScreen()),
        GoRoute(path: '/settings/security', builder: (context, state) => const SecurityScreen()),
        GoRoute(path: '/settings/appearance', builder: (context, state) => const AppearanceScreen()),
        GoRoute(path: '/settings/devices', builder: (context, state) => const DevicesScreen()),
        GoRoute(path: '/settings/blocked', builder: (context, state) => const BlockedUsersScreen()),
        GoRoute(path: '/settings/storage', builder: (context, state) => const StorageScreen()),
        GoRoute(path: '/settings/language', builder: (context, state) => const LanguageScreen()),
        GoRoute(path: '/settings/delete-account', builder: (context, state) => const DeleteAccountScreen()),
        GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
        GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
        // Bot Platform
        GoRoute(path: '/bot-creator', builder: (context, state) => const BotCreatorScreen()),
        GoRoute(path: '/bots', builder: (context, state) => const BotListScreen()),
        GoRoute(path: '/bot/:botId', builder: (context, state) => BotDetailScreen(botId: state.params['botId']!)),
        GoRoute(path: '/bot/:botId/webhook', builder: (context, state) => BotWebhookScreen(botId: state.params['botId']!)),
        GoRoute(path: '/bot/:botId/commands', builder: (context, state) => BotCommandsScreen(botId: state.params['botId']!)),
        GoRoute(path: '/bot/:botId/analytics', builder: (context, state) => BotAnalyticsScreen(botId: state.params['botId']!)),
        GoRoute(path: '/bot/:botId/permissions', builder: (context, state) => BotPermissionsScreen(botId: state.params['botId']!)),
        GoRoute(path: '/bot/:botId/logs', builder: (context, state) => BotLogsScreen(botId: state.params['botId']!)),
        // Folders
        GoRoute(path: '/folders', builder: (context, state) => const FoldersScreen()),
        GoRoute(path: '/folder/:folderId', builder: (context, state) => FolderDetailScreen(folderId: state.params['folderId']!)),
        // App Lock
        GoRoute(path: '/settings/app-lock', builder: (context, state) => const AppLockScreen()),
        // Contacts
        GoRoute(path: '/contacts', builder: (context, state) => const ContactsScreen()),
        GoRoute(path: '/new-chat', builder: (context, state) => const ContactPickerScreen()),
        // Secret Chat
        GoRoute(path: '/secret-chat/:chatId/:userId', builder: (context, state) => SecretChatScreen(chatId: state.params['chatId']!, otherUserId: state.params['userId']!)),
        // AI Chat
        GoRoute(path: '/ai-chat', builder: (context, state) => const AIChatScreen()),
        // Live Stream
        GoRoute(path: '/stream/:channelName?', builder: (context, state) => LiveStreamScreen(channelName: state.params['channelName'], isViewer: state.queryParams['viewer'] == 'true')),
        // Chat Themes
        GoRoute(path: '/themes/:chatId?', builder: (context, state) => ChatThemesScreen(chatId: state.params['chatId'])),
        // Auto Reply
        GoRoute(path: '/auto-reply/:chatId', builder: (context, state) => AutoReplyScreen(chatId: state.params['chatId']!)),
        // Stickers
        GoRoute(path: '/stickers', builder: (context, state) => const StickerStoreScreen()),
        // Crypto Wallet
        GoRoute(path: '/crypto-wallet', builder: (context, state) => const CryptoWalletScreen()),
        // Voice Chat
        GoRoute(path: '/voice-chat/:groupId/:channelName', builder: (context, state) => GroupVoiceChatScreen(groupId: state.params['groupId']!, channelName: state.params['channelName']!)),
        // Comments
        GoRoute(path: '/comments/:postId', builder: (context, state) => ChannelCommentsScreen(postId: state.params['postId']!)),
        // NFT
        GoRoute(path: '/nft-gallery', builder: (context, state) => const NFTGalleryScreen()),
        GoRoute(path: '/nft-detail', builder: (context, state) => NFTDetailScreen(nft: state.extra as Map<String, dynamic>)),
        // Screen Recording
        GoRoute(path: '/screen-recording', builder: (context, state) => const ScreenRecordingScreen()),
        // Voice Cloning
        GoRoute(path: '/voice-cloning', builder: (context, state) => const VoiceCloningScreen()),
        // AR Filters
        GoRoute(path: '/ar-filters', builder: (context, state) => const ARFilterScreen()),
        // Games
        GoRoute(path: '/game/:chatId/:sessionId', builder: (context, state) => GameScreen(chatId: state.params['chatId']!, sessionId: state.params['sessionId']!)),
        GoRoute(path: '/game-lobby/:chatId', builder: (context, state) => GameLobbyScreen(chatId: state.params['chatId']!)),
        // Translation Options
        GoRoute(path: '/settings/translation', builder: (context, state) => const TranslationOptionsScreen()),
        // Two-Factor Auth
        GoRoute(path: '/settings/2fa', builder: (context, state) => const TwoFactorSetupScreen()),
        // P2P Payments
        GoRoute(path: '/p2p-payment', builder: (context, state) => const P2PPaymentScreen()),
        // Group Admin Logs
        GoRoute(path: '/group/:groupId/admin-logs', builder: (context, state) => GroupAdminLogsScreen(groupId: state.params['groupId']!)),
        // Language Selection
        GoRoute(path: '/settings/language-select', builder: (context, state) => const LanguageSelectionScreen()),
        // Screen Share
        GoRoute(path: '/screen-share/:channelName', builder: (context, state) => ScreenShareScreen(channelName: state.params['channelName']!)),
      ],
    );
  }
}