import 'dart:async';

import 'package:approo_payment/src/data/models/market_payment_result.dart';
import 'package:approo_payment/src/data/models/payment_gateway.dart';
import 'package:approo_payment/src/domain/entities/pending_purchase.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:myket_iap/myket_iap.dart';
import 'package:myket_iap/util/purchase.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentGateway> getPaymentGateway({
    required int productId,
    required String description,
    required String projectPackageName,
  });
  Future<MarketPaymentResult> processMarketPayment(
      {required String productId,
      required String productUuid,
      required String marketRSA,
      required String projectPackageName,
      required String payload });
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
  Future<MarketPaymentResult> processMarketPayment(
      {required String productId,
      required String productUuid,
      required String marketRSA,
      required String projectPackageName,
      required String payload 
      }) async {
    try {
      await MyketIAP.init(
        rsaKey: marketRSA,
        enableDebugLogging: true,
      );

      final result = await MyketIAP.launchPurchaseFlow(
        sku: productUuid,
        payload: payload,
      );

      final purchase = result[MyketIAP.PURCHASE] as Purchase?;

      if (purchase == null || purchase.mToken.isEmpty) {
        return MarketPaymentFailure("پرداخت انجام نشد یا ناموفق بود");
      }

      final pending = PendingPurchase(
        productId: productId,
        purchaseToken: purchase.mToken,
      );

      final response = await verifyPurchase(
        productId: productId,
        projectPackageName: projectPackageName,
        purchaseToken: purchase.mToken,
      );

      if (response.statusCode == 200) {
        await MyketIAP.consume(purchase: purchase);
        return MarketPaymentSuccess();
      }

      // ⚠️ PAID — SERVER FAILED
      return MarketPaymentPending(pending);
    } on PlatformException catch (e) {
      if (e.code == "PURCHASE_CANCELLED") {
        return MarketPaymentFailure("پرداخت توسط کاربر لغو شد");
      }

      if (e.message != null && e.message!.contains("IAB")) {
        return MarketPaymentFailure(
            "لطفاً برنامه مایکت را روی دستگاه خود نصب کنید");
      }

      return MarketPaymentFailure(
        e.message ?? "پرداخت انجام نشد یا ناموفق بود",
      );
    } catch (_) {
      return MarketPaymentFailure("پرداخت انجام نشد یا ناموفق بود");
    }
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
        'gateway': 'myket',
      },
      options: Options(
        validateStatus: (status) => true,
      ),
    );
  }
}
