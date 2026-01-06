import 'package:approo_payment/src/data/models/product.dart';
import 'package:approo_payment/src/data/models/payment_gateway.dart';

abstract class PaymentRepository {
  Future<List<Product>> getProducts();
  Future<PaymentGateway> getPaymentGateway({
    required int productId,
    String description,
  });
}