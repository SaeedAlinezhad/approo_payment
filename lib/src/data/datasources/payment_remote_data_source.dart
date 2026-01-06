import 'dart:async';

import 'package:approo_payment/src/data/models/payment_gateway.dart';
import 'package:dio/dio.dart';
import 'package:flutter_poolakey/flutter_poolakey.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentGateway> getPaymentGateway({
    required int productId,
    required String description,
    required String projectPackageName,
  });
    Future<String> processMarketPayment({
    required String productId,
    required String productUuid,
    required String marketRSA,
    required String projectPackageName,
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
  Future<String> processMarketPayment({
    required String productId,
    required String productUuid,
    required String marketRSA,
    required String projectPackageName,
  }) async {
    final completer = Completer<String>();

    try {
      FlutterPoolakey.connect(
        marketRSA,
        onDisconnected: () {
          if (!completer.isCompleted) {
            completer
                .completeError(Exception("اتصال به کافه بازار برقرار نشد"));
          }
        },
        onFailed: () {
          if (!completer.isCompleted) {
            completer
                .completeError(Exception("اتصال به کافه بازار برقرار نشد"));
          }
        },
        onSucceed: () async {
          try {
            // Use subscribe() for subscription-based products
            final purchaseInfo = await FlutterPoolakey.subscribe(productUuid);
            final subUserResponse = await _verifyPurchaseWithServer(
              productId: productId,
              projectPackageName: projectPackageName,
              purchaseToken: purchaseInfo.purchaseToken,
            );

            if (subUserResponse.statusCode == 200) {
              print("Purchase verified with server successfully.");
              // Clear pending purchase from local storage
              // await _clearPendingPurchase();
              if (!completer.isCompleted) completer.complete('ok');
            } else {
              print(
                  "Purchase verification failed: ${subUserResponse.statusCode}");
              // Save pending purchase to local storage for retry
              // await _savePendingPurchase(
              //   purchaseToken: purchaseInfo.purchaseToken,
              //   productId: productId,
              // );
              if (!completer.isCompleted) {
                print("Completing with error due to failed verification.");
                completer.completeError(
                    Exception("خطا: ${subUserResponse.statusCode}"));
              }
            }
          } catch (e) {
            if (!completer.isCompleted) completer.completeError(e);
          }
        },
      );
    } catch (e) {
      if (!completer.isCompleted) completer.completeError(e);
    }

    return completer.future;
  }

  // Private helper method to verify purchase with server
  Future<Response> _verifyPurchaseWithServer({
    required String productId,
    required String projectPackageName,
    required String purchaseToken,
  }) async {
    return await dio.put(
      'https://payment.vada.ir/api/package-names/$projectPackageName/products/$productId/subscribe',
      data: {
        'purchase_token': purchaseToken,
        'gateway': 'cafe',
      },
      options: Options(
        validateStatus: (status) => true,
      ),
      queryParameters: {
        'name': projectPackageName,
        'product_id': productId,
      },
    );
  }
}