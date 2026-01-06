import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final String url;

  const PaymentEntity({required this.url});

  @override
  List<Object?> get props => [url];
}