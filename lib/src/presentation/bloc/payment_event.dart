part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends PaymentEvent {}

class SelectProduct extends PaymentEvent {
  final String productId;
  final String? productUuid; // Add this for market payments
  final String? description; // Keep this for backward compatibility
  final String? marketRSA; // Keep this for backward compatibility
  final String? payload; // Keep this for backward compatibility

  const SelectProduct(this.productId, {this.productUuid, this.description, this.marketRSA, this.payload});

  @override
  List<Object?> get props => [productId, productUuid, description];
}