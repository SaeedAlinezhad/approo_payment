import 'package:approo_payment/src/data/datasources/product_remote_data_source.dart';
import 'package:approo_payment/src/data/datasources/payment_remote_data_source.dart';
import 'package:approo_payment/src/data/repositories/payment_repository_impl.dart';
import 'package:approo_payment/src/domain/repositories/payment_repository.dart';
import 'package:approo_payment/src/presentation/bloc/payment_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

class ApprooPaymentConfig {
  final String baseUrl;
  final String projectPackageName;
  final String? authToken;
  final Map<String, dynamic>? additionalHeaders;

  ApprooPaymentConfig({
    required this.baseUrl,
    required this.projectPackageName,
    this.authToken,
    this.additionalHeaders,
  });
}

void initApprooPayment(ApprooPaymentConfig config) {
  // Dio Client
  sl.registerLazySingleton(() => Dio()
    ..options.baseUrl = config.baseUrl
    ..options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (config.authToken != null) 'Authorization': 'Bearer ${config.authToken}',
      ...?config.additionalHeaders,
    });

  // Data Sources
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(dio: sl()),
  );

  // Repository
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(
      productRemoteDataSource: sl(),
      paymentRemoteDataSource: sl(),
      projectPackageName: config.projectPackageName,
    ),
  );

  // Bloc
  sl.registerFactory(
    () => PaymentBloc(paymentRepository: sl()),
  );
}

PaymentBloc getPaymentBloc() => sl<PaymentBloc>();