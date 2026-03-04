import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api/api_client.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/view_model/auth_view_model.dart';
import 'features/kyc/data/kyc_repository.dart';
import 'features/kyc/view_model/kyc_view_model.dart';
import 'features/profile/data/profile_repository.dart';
import 'features/profile/view_model/profile_view_model.dart';
import 'routes.dart';

void main() {
  runApp(const MoneyMiningApp());
}

class MoneyMiningApp extends StatelessWidget {
  const MoneyMiningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StorageService>(
          create: (_) => StorageService(),
        ),
        ProxyProvider<StorageService, ApiClient>(
          update: (_, storageService, __) => ApiClient(storageService),
        ),
        ProxyProvider2<ApiClient, StorageService, AuthRepository>(
          update: (_, apiClient, storageService, __) => AuthRepository(apiClient, storageService),
        ),
        ChangeNotifierProxyProvider<AuthRepository, AuthViewModel>(
          create: (context) => AuthViewModel(context.read<AuthRepository>()), 
          update: (_, authRepository, viewModel) => AuthViewModel(authRepository),
        ),
        ProxyProvider<ApiClient, KycRepository>(
           update: (_, apiClient, __) => KycRepository(apiClient),
        ),
        ChangeNotifierProxyProvider<KycRepository, KycViewModel>(
          create: (context) => KycViewModel(context.read<KycRepository>()),
          update: (_, kycRepository, viewModel) => KycViewModel(kycRepository),
        ),
        ProxyProvider<ApiClient, ProfileRepository>(
          update: (_, apiClient, __) => ProfileRepository(apiClient),
        ),
        ChangeNotifierProxyProvider<ProfileRepository, ProfileViewModel>(
          create: (context) => ProfileViewModel(context.read<ProfileRepository>()),
          update: (_, profileRepository, viewModel) => ProfileViewModel(profileRepository),
        ),
      ],
      child: MaterialApp(
        title: 'MoneyMining',
        navigatorKey: Routes.navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: Routes.splash,
        routes: Routes.getRoutes(context),
      ),
    );
  }
}
