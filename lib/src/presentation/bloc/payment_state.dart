part of 'payment_bloc.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class ProductLoading extends PaymentState {}

class ProductLoaded extends PaymentState {
  final List<Product> products;
  const ProductLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class ProductError extends PaymentState {
  final String message;
  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentUrlLoading extends PaymentState {}

class PaymentUrlLoaded extends PaymentState {
  final String url;
  const PaymentUrlLoaded(this.url);

  @override
  List<Object?> get props => [url];
}

class PaymentUrlError extends PaymentState {
  final String message;
  const PaymentUrlError(this.message);

  @override
  List<Object?> get props => [message];
}