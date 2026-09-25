import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Current user profile model
enum UserRole { artisan, customer, unselected }

class AppUser {
  final String id;
  final String? email;
  final String? phone;
  final String? name;
  final UserRole role;

  const AppUser({
    required this.id,
    this.email,
    this.phone,
    this.name,
    this.role = UserRole.unselected,
  });

  AppUser copyWith({
    String? id,
    String? email,
    String? phone,
    String? name,
    UserRole? role,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      role: role ?? this.role,
    );
  }
}

class AuthService {
  final SupabaseClient? _client;

  AuthService(this._client);

  bool get isInitialized => _client != null;

  /// Send Phone OTP via Supabase
  Future<void> sendOtp(String phoneNumber) async {
    final client = _client;
    if (client == null) {
      debugPrint('[AuthService] Supabase client not initialized (running on mock auth)');
      return;
    }
    await client.auth.signInWithOtp(
      phone: phoneNumber,
    );
  }

  /// Verify 6-digit OTP
  Future<AuthResponse?> verifyOtp(String phoneNumber, String token) async {
    final client = _client;
    if (client == null) {
      debugPrint('[AuthService] Mock OTP verified for $phoneNumber');
      return null;
    }
    return await client.auth.verifyOTP(
      phone: phoneNumber,
      token: token,
      type: OtpType.sms,
    );
  }

  /// Sign In with Google
  ///
  /// PLATFORM SETUP REQUIRED OUTSIDE DART:
  /// 1. Android:
  ///    - Generate SHA-1 fingerprint: `cd android && ./gradlew signingReport`
  ///    - Register SHA-1 fingerprint in Firebase / Google Cloud Console.
  ///    - Place `google-services.json` inside `frontend/android/app/`.
  /// 2. iOS:
  ///    - Place `GoogleService-Info.plist` inside `frontend/ios/Runner/`.
  ///    - Add CFBundleURLSchemes into `Info.plist` corresponding to REVERSED_CLIENT_ID.
  /// 3. Supabase Dashboard:
  ///    - Enable Google provider under Authentication -> Providers.
  ///    - Add Google Client ID and Secret from Google Cloud Console.
  Future<void> signInWithGoogle() async {
    final client = _client;
    if (client == null) {
      debugPrint('[AuthService] Mock Google Sign In executed');
      return;
    }

    try {
      const webClientId = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';
      const iosClientId = 'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com';

      final googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
      );
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;

      if (googleAuth?.idToken == null) {
        throw 'Missing Google ID Token';
      }

      await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth!.idToken!,
        accessToken: googleAuth.accessToken,
      );
    } catch (e) {
      debugPrint('[AuthService] Supabase OAuth sign-in fallback: $e');
      await client.auth.signInWithOAuth(OAuthProvider.google);
    }
  }

  Future<void> signOut() async {
    final client = _client;
    if (client != null) {
      await client.auth.signOut();
    }
  }
}

// User state notifier holding session + active role
class AuthStateNotifier extends StateNotifier<AppUser?> {
  AuthStateNotifier() : super(null) {
    _checkInitialState();
  }

  void _checkInitialState() {
    try {
      final supaUser = Supabase.instance.client.auth.currentUser;
      if (supaUser != null) {
        state = AppUser(
          id: supaUser.id,
          email: supaUser.email,
          phone: supaUser.phone,
          role: UserRole.artisan, // default to artisan for demonstration
        );
      }
    } catch (_) {
      // Supabase not yet connected to live cloud project
    }
  }

  void setAuthenticatedUser(AppUser user) {
    state = user;
  }

  void selectRole(UserRole role) {
    if (state != null) {
      state = state!.copyWith(role: role);
    } else {
      state = AppUser(id: 'usr_mock_1', role: role);
    }
  }

  void signOut() {
    state = null;
  }
}

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AppUser?>((ref) {
  return AuthStateNotifier();
});

final authServiceProvider = Provider<AuthService>((ref) {
  try {
    return AuthService(Supabase.instance.client);
  } catch (_) {
    return AuthService(null);
  }
});
