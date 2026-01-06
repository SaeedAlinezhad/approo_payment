import 'package:approo_payment/src/data/models/payment_gateway.dart';
import 'package:dio/dio.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentGateway> getPaymentGateway({
    required int productId,
    required String description,
  });
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final Dio dio;

  PaymentRemoteDataSourceImpl({required this.dio});

  @override
  Future<PaymentGateway> getPaymentGateway({
    required int productId,
    required String description,
  }) async {
    final response = await dio.post(
      '/zarinpal/gateway',
      data: {
        'product_id': productId.toString(),
        'description': description,
      },
    );

    return PaymentGateway.fromJson(response.data);
  }
}