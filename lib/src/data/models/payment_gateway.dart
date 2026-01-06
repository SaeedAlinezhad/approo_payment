import 'package:approo_payment/src/domain/entities/payment_entity.dart';

class PaymentGateway extends PaymentEntity {
  const PaymentGateway({required super.url});

  factory PaymentGateway.fromJson(Map<String, dynamic> json) =>
      PaymentGateway(url: json['url']);

  Map<String, dynamic> toJson() => {'url': url};
}