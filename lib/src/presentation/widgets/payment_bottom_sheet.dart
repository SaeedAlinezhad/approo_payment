import 'package:approo_payment/dependencies.dart';
import 'package:approo_payment/src/domain/entities/pending_purchase.dart';
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
    required String marketRSA,
    String? payload,
    Map<String, dynamic>? additionalHeaders,
    Dio? existingDio,
    String? title,
    String? description,
    Widget? loadingWidget,
    Widget? errorWidget,
    Widget? emptyWidget,
    Widget Function(BuildContext, Product)? productBuilder,
    void Function(String)? onPaymentUrlLoaded,
    void Function(String)? onPaymentSuccess,
    void Function(int statusCode, String message)? onError,
    void Function(PendingPurchase pending)? onPendingPurchase,
    bool useRtl = true,
  }) async {
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
          child: SafeArea(
            child: _PaymentBottomSheetContent(
              title: title,
              description: description,
              loadingWidget: loadingWidget,
              errorWidget: errorWidget,
              emptyWidget: emptyWidget,
              productBuilder: productBuilder,
              onPaymentUrlLoaded: onPaymentUrlLoaded,
              onPaymentSuccess: onPaymentSuccess,
              onPendingPurchase:onPendingPurchase,
              onError: onError,
              useRtl: useRtl,
              marketRSA: marketRSA,
              payload: payload,
            ),
          ),
        );
      },
    ).then((_) {
      paymentBloc.close();
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
  final void Function(String)? onPaymentSuccess;
  final void Function(int statusCode, String message)? onError;
  final Function(PendingPurchase pending)? onPendingPurchase;
  final bool useRtl;
  final String marketRSA;
  final String? payload;
  const _PaymentBottomSheetContent({
    this.title,
    this.description,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.productBuilder,
    this.onPaymentUrlLoaded,
    this.onPaymentSuccess,
    this.onError,
    this.onPendingPurchase,
    required this.useRtl,
    required this.marketRSA,
    this.payload,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) async {
        final status = state.paymentStatus;

        if (status is ProductPaymentError && onError != null) {
          Navigator.of(context).pop();
          onError!(400, status.message);
        }
        if (status is ProductPaymentSuccess &&
            onError != null &&
            onPaymentSuccess != null) {
          Navigator.of(context).pop();
          onPaymentSuccess!(status.result);
        }
        if (status is ProductPaymentPending) {
          Navigator.of(context).pop();
          onPendingPurchase!(status.pending);

        }

        if (state is PaymentUrlLoaded) {
          if (onPaymentUrlLoaded != null) {
            Navigator.of(context).pop();
            onPaymentUrlLoaded!(state.url);
          } else {
            Navigator.of(context).pop();
            final uri = Uri.parse(state.url);
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }

        // ✅ Updated error handling to include status codes
        if (state is PaymentUrlError) {
          if (onError != null) {
            Navigator.of(context).pop();
            onError!(state.statusCode ?? 400, state.message);
          }
        }

        if (state is ProductError) {
          if (onError != null) {
            Navigator.of(context).pop();
            onError!(state.statusCode ?? 400, state.message);
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),

                // Description
                if (description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Content
                BlocBuilder<PaymentBloc, PaymentState>(
                  builder: (context, state) {
                    return _buildContent(context, state, marketRSA,payload);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, PaymentState state, String marketRsa, String? payload) {
    // 🕓 Payment loading state
    if (state is PaymentUrlLoading) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'در حال هدایت به درگاه پرداخت...',
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ⏳ Loading state
    if (state is ProductLoading) {
      return loadingWidget ?? _buildShimmerLoading();
    }

    // ⚠️ Error state - Updated to show status code if available
    if (state is ProductError) {
      return errorWidget ??
          SizedBox(
            height: 150,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 40,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'خطا در بارگذاری محصولات',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // ✅ Show status code if available
                  if (state.statusCode != null)
                    Text(
                      'کد خطا: ${state.statusCode}',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  Text(
                    state.message,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
    }

    // ✅ Success state with products
    if (state is ProductLoaded) {
      if (state.products.isEmpty) {
        return emptyWidget ??
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 40,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'هیچ محصولی برای خرید موجود نیست',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
      }

      return _buildProductsList(context, state.products, marketRsa, payload);
    }

    return Row(
      children: [
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildProductsList(
      BuildContext context, List<Product> products, String marketRsa, String? payload) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = products[index];
        if (productBuilder != null) {
          return productBuilder!(context, product);
        }

        return _buildProductCard(context, product, marketRsa, payload);
      },
    );
  }

  Widget _buildProductCard(
      BuildContext context, Product product, String marketRsa, String? payload) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.price.toStringAsFixed(0).seRagham()} تومان',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<PaymentBloc>().add(SelectProduct(
                    product.id.toString(),
                    productUuid: product.uuid.toString(),
                    marketRSA: marketRsa, payload:payload));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'خرید',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 2,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 80,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
