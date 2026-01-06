part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends PaymentEvent {}

class SelectProduct extends PaymentEvent {
  final int productId;
  final String? description;

  const SelectProduct(this.productId, {this.description});

  @override
  List<Object?> get props => [productId, description];
}