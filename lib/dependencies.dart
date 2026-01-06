// dependencies.dart - Updated version
import 'package:approo_payment/src/data/datasources/product_remote_data_source.dart';
import 'package:approo_payment/src/data/datasources/payment_remote_data_source.dart';
import 'package:approo_payment/src/data/repositories/payment_repository_impl.dart';
import 'package:approo_payment/src/domain/repositories/payment_repository.dart';
import 'package:approo_payment/src/presentation/bloc/payment_bloc.dart';
import 'package:dio/dio.dart';

class ApprooPaymentConfig {
  final String baseUrl;
  final String projectPackageName;
  final Map<String, dynamic>? additionalHeaders;

  ApprooPaymentConfig({
    required this.baseUrl,
    required this.projectPackageName,
    this.additionalHeaders,
  });
}

class ApprooPaymentBuilder {
  static PaymentBloc createPaymentBloc({
    required String baseUrl,
    required String projectPackageName,
    required String authToken,
    Map<String, dynamic>? additionalHeaders,
    Dio? existingDio,
  }) {
    // Create Dio instance
    final dio = existingDio ?? Dio();
    dio.options.baseUrl = baseUrl;
    dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
      ...?additionalHeaders,
    };

    // Create data sources
    final productDataSource = ProductRemoteDataSourceImpl(dio: dio);
    final paymentDataSource = PaymentRemoteDataSourceImpl(dio: dio);

    // Create repository
    final paymentRepository = PaymentRepositoryImpl(
      productRemoteDataSource: productDataSource,
      paymentRemoteDataSource: paymentDataSource,
      projectPackageName: projectPackageName,
    );

    // Create and return bloc
    return PaymentBloc(paymentRepository: paymentRepository);
  }

  static PaymentRepository createPaymentRepository({
    required String baseUrl,
    required String projectPackageName,
    required String authToken,
    Map<String, dynamic>? additionalHeaders,
    Dio? existingDio,
  }) {
    // Create Dio instance
    final dio = existingDio ?? Dio();
    dio.options.baseUrl = baseUrl;
    dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
      ...?additionalHeaders,
    };

    // Create data sources
    final productDataSource = ProductRemoteDataSourceImpl(dio: dio);
    final paymentDataSource = PaymentRemoteDataSourceImpl(dio: dio);

    // Create and return repository
    return PaymentRepositoryImpl(
      productRemoteDataSource: productDataSource,
      paymentRemoteDataSource: paymentDataSource,
      projectPackageName: projectPackageName,
    );
  }
}