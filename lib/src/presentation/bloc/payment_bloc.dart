import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:approo_payment/src/domain/repositories/payment_repository.dart';
import 'package:approo_payment/src/data/models/product.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

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
        if (e is DioError) {
          final status = e.response?.statusCode;
          emit(ProductError(e.toString(), status));
        } else {
          emit(ProductError(e.toString(), null));
        }
      }
    });

    on<SelectProduct>((event, emit) async {
      // Clear any previous payment status
      emit(state.copyWith(paymentStatus: null));
      
      try {
        // Call market payment
        final result = await paymentRepository.marketPayment(
          event.productId,
          event.productUuid ?? '',
          event.marketRSA??""
        );
        
        // Update state with success status
        emit(state.copyWith(paymentStatus: ProductPaymentSuccess(result)));
        
      } on PlatformException catch (e) {
        if (e.code == "PURCHASE_CANCELLED") {
          emit(state.copyWith(paymentStatus: ProductPaymentError("پرداخت توسط کاربر لغو شد")));
        } else {
          emit(state.copyWith(paymentStatus: ProductPaymentError("خطای پلتفرم: ${e.message}")));
        }
      } catch (e) {
        emit(state.copyWith(paymentStatus: ProductPaymentError("خطای ناشناخته: $e")));
      }
    });
  }
}