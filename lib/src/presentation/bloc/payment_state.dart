part of 'payment_bloc.dart';

abstract class PaymentState extends Equatable {
  final PaymentStatus? paymentStatus;
  
  const PaymentState({this.paymentStatus});
  
  @override
  List<Object?> get props => [paymentStatus];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial() : super(paymentStatus: null);
}

class ProductLoading extends PaymentState {
  const ProductLoading() : super(paymentStatus: null);
}

class ProductLoaded extends PaymentState {
  final List<Product> products;
  
  const ProductLoaded(this.products, {PaymentStatus? paymentStatus}) 
    : super(paymentStatus: paymentStatus);

  @override
  List<Object?> get props => [products, paymentStatus];
}

class ProductError extends PaymentState {
  final int? statusCode;
  final String message;
  
  const ProductError(this.message, this.statusCode, {PaymentStatus? paymentStatus}) 
    : super(paymentStatus: paymentStatus);

  @override
  List<Object?> get props => [message, statusCode, paymentStatus];
}

class PaymentUrlLoading extends PaymentState {
  const PaymentUrlLoading() : super(paymentStatus: null);
}

class PaymentUrlLoaded extends PaymentState {
  final String url;
  
  const PaymentUrlLoaded(this.url, {PaymentStatus? paymentStatus}) 
    : super(paymentStatus: paymentStatus);

  @override
  List<Object?> get props => [url, paymentStatus];
}

class PaymentUrlError extends PaymentState {
  final String message;
  final int? statusCode;

  const PaymentUrlError(this.message, this.statusCode, {PaymentStatus? paymentStatus}) 
    : super(paymentStatus: paymentStatus);

  @override
  List<Object?> get props => [message, statusCode, paymentStatus];
}

// Add copyWith method to PaymentState
extension PaymentStateCopyWith on PaymentState {
  PaymentState copyWith({PaymentStatus? paymentStatus}) {
    if (this is ProductLoaded) {
      return ProductLoaded(
        (this as ProductLoaded).products,
        paymentStatus: paymentStatus ?? this.paymentStatus,
      );
    } else if (this is ProductError) {
      final current = this as ProductError;
      return ProductError(
        current.message,
        current.statusCode,
        paymentStatus: paymentStatus ?? this.paymentStatus,
      );
    } else if (this is PaymentUrlLoaded) {
      return PaymentUrlLoaded(
        (this as PaymentUrlLoaded).url,
        paymentStatus: paymentStatus ?? this.paymentStatus,
      );
    } else if (this is PaymentUrlError) {
      final current = this as PaymentUrlError;
      return PaymentUrlError(
        current.message,
        current.statusCode,
        paymentStatus: paymentStatus ?? this.paymentStatus,
      );
    }
    return this;
  }
}

// Payment Status classes
abstract class PaymentStatus extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductPaymentSuccess extends PaymentStatus {
  final String result;
  
   ProductPaymentSuccess(this.result);
  
  @override
  List<Object?> get props => [result];
}

class ProductPaymentError extends PaymentStatus {
  final String message;
  
   ProductPaymentError(this.message);
  
  @override
  List<Object?> get props => [message];
}
class ProductPaymentPending extends PaymentStatus {
  final PendingPurchase pending;

  ProductPaymentPending(this.pending);

  @override
  List<Object?> get props => [pending];
}
