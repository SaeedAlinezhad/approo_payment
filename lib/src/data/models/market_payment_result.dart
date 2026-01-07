import 'package:approo_payment/src/domain/entities/pending_purchase.dart';

sealed class MarketPaymentResult {}

class MarketPaymentSuccess extends MarketPaymentResult {}

class MarketPaymentPending extends MarketPaymentResult {
  final PendingPurchase pending;
  MarketPaymentPending(this.pending);
}

class MarketPaymentFailure extends MarketPaymentResult {
  final String message;
  MarketPaymentFailure(this.message);
}