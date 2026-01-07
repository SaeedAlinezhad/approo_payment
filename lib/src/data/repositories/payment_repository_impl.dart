import 'package:approo_payment/src/data/datasources/product_remote_data_source.dart';
import 'package:approo_payment/src/data/datasources/payment_remote_data_source.dart';
import 'package:approo_payment/src/data/models/market_payment_result.dart';
import 'package:approo_payment/src/data/models/product.dart';
import 'package:approo_payment/src/data/models/payment_gateway.dart';
import 'package:approo_payment/src/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final ProductRemoteDataSource productRemoteDataSource;
  final PaymentRemoteDataSource paymentRemoteDataSource;
  final String projectPackageName;

  PaymentRepositoryImpl({
    required this.productRemoteDataSource,
    required this.paymentRemoteDataSource,
    required this.projectPackageName,
  });

  @override
  Future<List<Product>> getProducts() {
    return productRemoteDataSource.getProducts(projectPackageName);
  }

  @override
  Future<PaymentGateway> getPaymentGateway({
    required int productId,
    String description = 'Payment for subscription',
  }) async{
    return await paymentRemoteDataSource.getPaymentGateway(
      productId: productId,
      description: description,
      projectPackageName: projectPackageName,
    );
  }

    @override
  Future<MarketPaymentResult> marketPayment(String productId, String productUuid, String marketRSA) =>
      paymentRemoteDataSource.processMarketPayment( productId: productId, productUuid: productUuid, marketRSA: marketRSA, projectPackageName: projectPackageName, );
@override
Future<void> retryVerification({
  required String productId,
  required String purchaseToken,
}) async {
  final response = await paymentRemoteDataSource.verifyPurchase(
    productId: productId,
    projectPackageName: projectPackageName,
    purchaseToken: purchaseToken,
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Verification failed: ${response.statusCode}',
    );
  }
}

}