import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:approo_payment/src/domain/repositories/payment_repository.dart';
import 'package:approo_payment/src/data/models/product.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository paymentRepository;

  PaymentBloc({required this.paymentRepository}) : super(PaymentInitial()) {
    on<LoadProducts>((event, emit) async {
      emit(ProductLoading());
      try {
        final products = await paymentRepository.getProducts();
        emit(ProductLoaded(products));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });

    on<SelectProduct>((event, emit) async {
      emit(PaymentUrlLoading());
      try {
        final paymentGateway = await paymentRepository.getPaymentGateway(
          productId: event.productId,
          description: event.description ?? 'Payment for subscription',
        );
        emit(PaymentUrlLoaded(paymentGateway.url));
      } catch (e) {
        emit(PaymentUrlError(e.toString()));
      }
    });
  }
}