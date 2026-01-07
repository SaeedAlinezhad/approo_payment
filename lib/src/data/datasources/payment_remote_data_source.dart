import 'dart:async';

import 'package:approo_payment/src/data/models/market_payment_result.dart';
import 'package:approo_payment/src/data/models/payment_gateway.dart';
import 'package:approo_payment/src/domain/entities/pending_purchase.dart';
import 'package:dio/dio.dart';
import 'package:flutter_poolakey/flutter_poolakey.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentGateway> getPaymentGateway({
    required int productId,
    required String description,
    required String projectPackageName,
  });
    Future<MarketPaymentResult> processMarketPayment({
    required String productId,
    required String productUuid,
    required String marketRSA,
    required String projectPackageName,
  });
    Future<Response> verifyPurchase({
    required String productId,
    required String projectPackageName,
    required String purchaseToken,
  });
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final Dio dio;

  PaymentRemoteDataSourceImpl({required this.dio});

  @override
  Future<PaymentGateway> getPaymentGateway({
    required int productId,
    required String description,
    required String projectPackageName,
  }) async {
    final response = await dio.post(
      '/zarinpal/gateway',
      data: {
        'product_id': productId.toString(),
        'description': description,
        'package_name': projectPackageName,
      },
    );

    return PaymentGateway.fromJson(response.data);
  }
@override
Future<MarketPaymentResult> processMarketPayment({
  required String productId,
  required String productUuid,
  required String marketRSA,
  required String projectPackageName,
}) async {
  final completer = Completer<MarketPaymentResult>();

  FlutterPoolakey.connect(
    marketRSA,
    onDisconnected: () {
      if (!completer.isCompleted) {
        completer.complete(
          MarketPaymentFailure("اتصال به کافه بازار برقرار نشد"),
        );
      }
    },
    onFailed: () {
      if (!completer.isCompleted) {
        completer.complete(
          MarketPaymentFailure("اتصال به کافه بازار برقرار نشد"),
        );
      }
    },
    onSucceed: () async {
      try {
        final purchaseInfo = await FlutterPoolakey.subscribe(productUuid);

        final pending = PendingPurchase(
          productId: productId,
          purchaseToken: purchaseInfo.purchaseToken,
        );

        final response = await verifyPurchase(
          productId: productId,
          projectPackageName: projectPackageName,
          purchaseToken: purchaseInfo.purchaseToken,
        );

        if (response.statusCode == 200) {
          completer.complete(MarketPaymentSuccess());
        } else {
          // ⚠️ PAYMENT DONE — SERVER FAILED
          completer.complete(MarketPaymentPending(pending));
        }
      } catch (e) {
        // ⚠️ PAYMENT DONE — UNKNOWN FAILURE
        completer.complete(
          MarketPaymentPending(
            PendingPurchase(
              productId: productId,
              purchaseToken: "unknown",
            ),
          ),
        );
      }
    },
  );

  return completer.future;
}

@override
Future<Response> verifyPurchase({
  required String productId,
  required String projectPackageName,
  required String purchaseToken,
}) {
  return dio.put(
    '/package-names/$projectPackageName/products/$productId/subscribe',
    data: {
      'purchase_token': purchaseToken,
      'gateway': 'cafe',
    },
    options: Options(
      validateStatus: (status) => true,
    ),
  );
}

}