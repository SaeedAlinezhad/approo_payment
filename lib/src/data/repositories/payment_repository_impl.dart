import 'package:approo_payment/src/data/datasources/product_remote_data_source.dart';
import 'package:approo_payment/src/data/datasources/payment_remote_data_source.dart';
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
}