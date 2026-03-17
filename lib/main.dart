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
import 'features/payment/data/payment_repository.dart';
import 'features/payment/view_model/payment_view_model.dart';
import 'features/withdrawal/data/withdrawal_repository.dart';
import 'features/withdrawal/view_model/withdrawal_view_model.dart';
import 'features/dashboard/data/transaction_repository.dart';
import 'features/dashboard/view_model/transaction_view_model.dart';
import 'features/support/data/support_repository.dart';
import 'features/support/view_model/support_view_model.dart';
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
        ChangeNotifierProxyProvider2<AuthRepository, StorageService, AuthViewModel>(
          create: (context) => AuthViewModel(context.read<AuthRepository>(), context.read<StorageService>()), 
          update: (_, authRepository, storageService, viewModel) => AuthViewModel(authRepository, storageService),
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
        ChangeNotifierProxyProvider2<ProfileRepository, StorageService, ProfileViewModel>(
          create: (context) => ProfileViewModel(context.read<ProfileRepository>(), context.read<StorageService>()),
          update: (_, profileRepository, storageService, viewModel) => ProfileViewModel(profileRepository, storageService),
        ),

        ProxyProvider<ApiClient, PaymentRepository>(
          update: (_, apiClient, __) => PaymentRepository(apiClient),
        ),
        ChangeNotifierProxyProvider<PaymentRepository, PaymentViewModel>(
          create: (context) => PaymentViewModel(context.read<PaymentRepository>()),
          update: (_, paymentRepository, viewModel) => PaymentViewModel(paymentRepository),
        ),
        ProxyProvider<ApiClient, WithdrawalRepository>(
          update: (_, apiClient, __) => WithdrawalRepository(apiClient),
        ),
        ChangeNotifierProxyProvider<WithdrawalRepository, WithdrawalViewModel>(
          create: (context) => WithdrawalViewModel(context.read<WithdrawalRepository>()),
          update: (_, withdrawalRepository, viewModel) => WithdrawalViewModel(withdrawalRepository),
        ),
        ProxyProvider<ApiClient, TransactionRepository>(
          update: (_, apiClient, __) => TransactionRepository(apiClient),
        ),
        ChangeNotifierProxyProvider<TransactionRepository, TransactionViewModel>(
          create: (context) => TransactionViewModel(context.read<TransactionRepository>()),
          update: (_, transactionRepository, viewModel) => TransactionViewModel(transactionRepository),
        ),
        ProxyProvider<ApiClient, SupportRepository>(
          update: (_, apiClient, __) => SupportRepository(apiClient),
        ),
        ChangeNotifierProxyProvider<SupportRepository, SupportViewModel>(
          create: (context) => SupportViewModel(context.read<SupportRepository>()),
          update: (_, supportRepository, viewModel) => SupportViewModel(supportRepository),
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
