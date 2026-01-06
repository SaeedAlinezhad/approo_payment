import 'package:approo_payment/dependencies.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:approo_payment/src/presentation/bloc/payment_bloc.dart';
import 'package:approo_payment/src/data/models/product.dart';

class ApprooPaymentBottomSheet {
  static Future<void> show({
    required BuildContext context,
    required String baseUrl,
    required String projectPackageName,
    required String authToken,
    Map<String, dynamic>? additionalHeaders,
    Dio? existingDio,
    String? title,
    String? description,
    Widget? loadingWidget,
    Widget? errorWidget,
    Widget? emptyWidget,
    Widget Function(BuildContext, Product)? productBuilder,
    void Function(String)? onPaymentUrlLoaded,
    void Function(String)? onError,
    bool useRtl = true,
  }) async {
    // Create bloc instance with fresh token
    final paymentBloc = ApprooPaymentBuilder.createPaymentBloc(
      baseUrl: baseUrl,
      projectPackageName: projectPackageName,
      authToken: authToken,
      additionalHeaders: additionalHeaders,
      existingDio: existingDio,
    );
    await showModalBottomSheet(
      useSafeArea: true,
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: paymentBloc..add(LoadProducts()),
          child: _PaymentBottomSheetContent(
            title: title,
            description: description,
            loadingWidget: loadingWidget,
            errorWidget: errorWidget,
            emptyWidget: emptyWidget,
            productBuilder: productBuilder,
            onPaymentUrlLoaded: onPaymentUrlLoaded,
            onError: onError,
            useRtl: useRtl,
          ),
        );
      },
    ).then((_)=>{
      paymentBloc.close(),
    });
  }
}

class _PaymentBottomSheetContent extends StatelessWidget {
  final String? title;
  final String? description;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final Widget Function(BuildContext, Product)? productBuilder;
  final void Function(String)? onPaymentUrlLoaded;
  final void Function(String)? onError;
  final bool useRtl;

  const _PaymentBottomSheetContent({
    this.title,
    this.description,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.productBuilder,
    this.onPaymentUrlLoaded,
    this.onError,
    required this.useRtl,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) async {
        if (state is PaymentUrlLoaded) {
          if (onPaymentUrlLoaded != null) {
            onPaymentUrlLoaded!(state.url);
          } else {
            Navigator.pop(context);
            final uri = Uri.parse(state.url);
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }

        if (state is PaymentUrlError || state is ProductError) {
          final errorMessage = state is PaymentUrlError
              ? state.message
              : (state as ProductError).message;
          
          if (onError != null) {
            onError!(errorMessage);
          }
        }
      },
      child: Directionality(
        textDirection: useRtl ? TextDirection.rtl : TextDirection.ltr,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    description!,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<PaymentBloc, PaymentState>(
                    builder: (context, state) {
                      // Loading state
                      if (state is ProductLoading) {
                        return loadingWidget ??
                            const Center(
                              child: CircularProgressIndicator(),
                            );
                      }

                      // Error state
                      if (state is ProductError) {
                        return errorWidget ??
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'خطا در بارگذاری محصولات',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    state.message,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                      }

                      // Success state with products
                      if (state is ProductLoaded) {
                        if (state.products.isEmpty) {
                          return emptyWidget ??
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      color: Colors.grey[400],
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'هیچ محصولی برای خرید موجود نیست',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.products.length,
                          itemBuilder: (context, index) {
                            final product = state.products[index];
                            
                            if (productBuilder != null) {
                              return productBuilder!(context, product);
                            }

                            return _defaultProductItem(context, product);
                          },
                        );
                      }

                      // Payment loading state
                      if (state is PaymentUrlLoading) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('در حال هدایت به درگاه پرداخت...'),
                            ],
                          ),
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _defaultProductItem(BuildContext context, Product product) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          product.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${product.price.toStringAsFixed(0).seRagham()} تومان',
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () {
            context.read<PaymentBloc>().add(SelectProduct(product.id));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('خرید'),
        ),
      ),
    );
  }
}