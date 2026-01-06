// import 'dart:async';
// import 'dart:ui';

// import 'package:app_links/app_links.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:golbeen_flutter/core/widgets/show_toast.dart';
// import 'package:golbeen_flutter/features/home/presentation/pages/home_container_page.dart';
// import 'package:golbeen_flutter/features/product/data/models/product.dart';
// import 'package:persian_number_utility/persian_number_utility.dart';
// import 'package:toastification/toastification.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../bloc/product_bloc.dart';

// class ProductScreen extends StatefulWidget {
//   const ProductScreen({super.key});

//   @override
//   State<ProductScreen> createState() => _ProductScreenState();
// }

// class _ProductScreenState extends State<ProductScreen> {
//   int selectedIndex = 1;
//   int currentImage = 0;

//   final List<String> images = [
//     'assets/images/sub1.webp',
//     'assets/images/sub2.webp',
//     'assets/images/sub3.webp',
//   ];
//   List<Product> cachedProducts = [];
//   bool isProcessingPayment = false;

//   bool isSkipEnabled = false;
//   Timer? _skipTimer;
//   late PageController _pageController;
//   Timer? _autoScrollTimer;
//   late final AppLinks _appLinks;

//   @override
//   void initState() {
//     super.initState();

//     context.read<ProductBloc>().add(LoadProducts());

//     _skipTimer = Timer(const Duration(seconds: 3), () {
//       setState(() => isSkipEnabled = true);
//     });

//     _pageController = PageController();

//     _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
//       if (!mounted) return;

//       int nextPage = (currentImage + 1) % images.length;

//       _pageController.animateToPage(
//         nextPage,
//         duration: const Duration(milliseconds: 400),
//         curve: Curves.easeInOut,
//       );
//     });
//     _initDeepLinks();
//   }

//   void _initDeepLinks() async {
//     _appLinks = AppLinks();

//     // Handle initial deep link (when app is cold started)
//     final Uri? initialUri = await _appLinks.getInitialLink();
//     if (initialUri != null) {
//       _handleDeepLink(initialUri);
//     }

//     // Listen for background/foreground deep links
//     _appLinks.uriLinkStream.listen((Uri uri) {
//       _handleDeepLink(uri);
//     });
//   }

//   void _handleDeepLink(Uri uri) {
//     debugPrint("Deep link received: $uri");

//     final status = uri.queryParameters['status'];

//     // if (status == "1") {
//     //   showToast(
//     //     context,
//     //     "پرداخت موفق",
//     //     "پرداخت موفق بود",
//     //     ToastificationType.success,
//     //   );
//     //   // context.read<ProfileBloc>().add(LoadProfile());
//     // } else if (status == "0") {
//     //   showToast(
//     //     context,
//     //     "پرداخت ناموفق",
//     //     "پرداخت ناموفق بود",
//     //     ToastificationType.error,
//     //   );
//     //   // context.read<ProfileBloc>().add(LoadProfile());
//     // } else {
//     //   showToast(
//     //     context,
//     //     "پرداخت نامشخص",
//     //     "وضعیت: $status",
//     //     ToastificationType.info,
//     //   );
//     //   // context.read<ProfileBloc>().add(LoadProfile());
//     // }
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         settings: const RouteSettings(name: '/home'),
//         builder: (_) => const HomeContainerPage(),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _skipTimer?.cancel();
//     _autoScrollTimer?.cancel();
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;

//     final imageHeight = screenWidth * 0.8;

//     final remainingHeight = screenHeight - imageHeight;

//     final sheetChildSize = remainingHeight / screenHeight;

//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         body: BlocConsumer<ProductBloc, ProductState>(
//           listener: _listener,
//           builder: (context, state) {
//             if (state is ProductLoaded) {
//               cachedProducts = state.products;
//             }
//             return Stack(
//               children: [
//                 Positioned(
//                   top: 0,
//                   left: 0,
//                   right: 0,
//                   child: SizedBox(
//                       height: MediaQuery.of(context).size.height * 0.45,
//                       child: PageView.builder(
//                         controller: _pageController,
//                         itemCount: images.length,
//                         onPageChanged: (index) {
//                           setState(() => currentImage = index);
//                         },
//                         itemBuilder: (context, index) {
//                           return Align(
//                             alignment: Alignment.topCenter,
//                             child: Image.asset(
//                               images[index],
//                               width: double.infinity,
//                               fit: BoxFit.fitWidth,
//                             ),
//                           );
//                         },
//                       )),
//                 ),
//                 Positioned(
//                   top: 50,
//                   left: 0,
//                   right: 0,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: List.generate(
//                       images.length,
//                       (index) => AnimatedContainer(
//                         duration: const Duration(milliseconds: 300),
//                         margin: const EdgeInsets.symmetric(horizontal: 4),
//                         width: currentImage == index ? 16 : 8,
//                         height: 8,
//                         decoration: BoxDecoration(
//                           color: currentImage == index
//                               ? Colors.white
//                               : Colors.white.withOpacity(0.5),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 DraggableScrollableSheet(
//                   initialChildSize: sheetChildSize,
//                   minChildSize: sheetChildSize,
//                   maxChildSize: sheetChildSize,
//                   builder: (context, scrollController) {
//                     return ClipRRect(
//                       borderRadius:
//                           const BorderRadius.vertical(top: Radius.circular(32)),
//                       child: BackdropFilter(
//                         filter: ImageFilter.blur(
//                           sigmaX: 20,
//                           sigmaY: 20,
//                         ),
//                         child: Container(
//                           padding: const EdgeInsets.all(20),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.6),
//                             borderRadius: const BorderRadius.vertical(
//                               top: Radius.circular(32),
//                             ),
//                           ),
//                           child: SingleChildScrollView(
//                             controller: scrollController,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Container(
//                                   width: 50,
//                                   height: 5,
//                                   margin: const EdgeInsets.only(bottom: 16),
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey.shade700,
//                                     borderRadius: BorderRadius.circular(2.5),
//                                   ),
//                                 ),
//                                 _pageTitle(),
//                                 const SizedBox(height: 20),
//                                 cachedProducts.isNotEmpty
//                                     ? _plansSection(cachedProducts)
//                                     : _shimmerPlans(),
//                                 const SizedBox(height: 20),
//                                 _paymentButton(state),
//                                 const SizedBox(height: 20),
//                                 _footerNote(),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 if (isProcessingPayment)
//                   Container(
//                     color: Colors.black.withOpacity(0.4),
//                     child: const Center(
//                       child: CircularProgressIndicator(
//                         color: Colors.white,
//                         strokeWidth: 3,
//                       ),
//                     ),
//                   ),
//                 Positioned(
//                   top: 40,
//                   left: 20,
//                   child: AnimatedOpacity(
//                     duration: const Duration(milliseconds: 300),
//                     opacity: isSkipEnabled ? 1 : 0.4,
//                     child: IgnorePointer(
//                       ignoring: !isSkipEnabled,
//                       child: GestureDetector(
//                         onTap: () {
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                               settings: const RouteSettings(name: '/home'),
//                               builder: (_) => const HomeContainerPage(),
//                             ),
//                           );
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 14, vertical: 8),
//                           decoration: BoxDecoration(
//                             color: Colors.black.withOpacity(0.5),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             "رد کردن",
//                             style: TextStyle(
//                               color: Colors.white
//                                   .withOpacity(isSkipEnabled ? 1 : 0.6),
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   void _listener(BuildContext context, ProductState state) async {
//     if (state is PaymentUrlLoading) {
//       setState(() => isProcessingPayment = true);
//     }

//     if (state is PaymentUrlLoaded) {
//       setState(() => isProcessingPayment = false);
//       launchUrl(Uri.parse(state.url), mode: LaunchMode.externalApplication);
//     }

//     if (state is PaymentUrlError) {
//       setState(() => isProcessingPayment = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("خطا در پرداخت، دوباره تلاش کنید")),
//       );
//     }
//   }

//   Widget _pageTitle() {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: Colors.green.shade50.withOpacity(0.8),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.green.shade100),
//           ),
//           child: Text(
//             "پیشنهاد ویژه",
//             style: TextStyle(
//               color: Colors.green.shade700,
//               fontSize: 13,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         const Text(
//           "تشخیص گیاه با هوش مصنوعی",
//           style: TextStyle(
//             color: Colors.black87,
//             fontSize: 24,
//             fontWeight: FontWeight.w900,
//             height: 1.3,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 6),
//         Text(
//           "سریع، دقیق و نامحدود - گیاهان خود را بهتر بشناسید",
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: Colors.grey.shade700,
//             fontSize: 14,
//             height: 1.5,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _shimmerPlans() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         Expanded(child: _shimmerCard(isPopular: false)),
//         const SizedBox(width: 12),
//         Expanded(child: _shimmerCard(isPopular: true)),
//       ],
//     );
//   }

//   Widget _shimmerCard({required bool isPopular}) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       padding: const EdgeInsets.all(3),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade300,
//         borderRadius: BorderRadius.circular(22),
//       ),
//       child: Column(
//         children: [
//           if (isPopular)
//             Container(
//               height: 14,
//               width: 50,
//               margin: const EdgeInsets.only(bottom: 4, top: 4),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade200,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ),
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 15,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _shimmerBox(height: 16, width: 80),
//                 const SizedBox(height: 8),
//                 _shimmerBox(height: 18, width: 100),
//                 const SizedBox(height: 8),
//                 _shimmerBox(height: 32, width: double.infinity),
//                 const SizedBox(height: 16),
//                 Container(
//                   height: 36,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade200,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _shimmerBox({required double height, required double width}) {
//     return Container(
//       height: height,
//       width: width,
//       decoration: BoxDecoration(
//         color: Colors.grey.shade200,
//         borderRadius: BorderRadius.circular(8),
//       ),
//     );
//   }

//   Widget _plansSection(List<Product> products) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         Expanded(
//           child: _planCard(
//             title: products[0].title,
//             price: products[0].price,
//             index: 0,
//             isPopular: false,
//             isSelected: selectedIndex == 0,
//             planId: products[0].id,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: _planCard(
//             title: products[1].title,
//             price: products[1].price,
//             index: 1,
//             isPopular: true,
//             isSelected: selectedIndex == 1,
//             planId: products[1].id,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _planCard({
//     required String title,
//     required int price,
//     required int index,
//     required bool isPopular,
//     required bool isSelected,
//     required int planId,
//   }) {
//     return GestureDetector(
//       onTap: () {
//         if (!isSelected) {
//           setState(() => selectedIndex = index);
//         } else {
//           context.read<ProductBloc>().add(SelectProduct(planId));
//         }
//       },
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         padding: EdgeInsets.all(3),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.green.shade400 : Colors.grey,
//           borderRadius: BorderRadius.circular(22),
//         ),
//         child: Column(
//           children: [
//             if (isPopular)
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                 child: Text(
//                   "اقتصادی",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 9,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(isSelected ? 0.1 : 0.05),
//                     blurRadius: 15,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       color: Colors.grey.shade800,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     "${price.toString().seRagham()} تومان",
//                     style: TextStyle(
//                       color: Colors.green.shade700,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w900,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     _getPlanDescription(index),
//                     style: TextStyle(
//                       color: Colors.grey.shade600,
//                       fontSize: 11,
//                       height: 1.4,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Container(
//                     width: double.infinity,
//                     height: 36,
//                     decoration: BoxDecoration(
//                       gradient: isSelected
//                           ? LinearGradient(
//                               colors: [
//                                 Colors.green.shade500,
//                                 Colors.lightGreen.shade500,
//                               ],
//                             )
//                           : null,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     alignment: Alignment.center,
//                     child: Text(
//                       isSelected ? "✓ انتخاب شده" : "انتخاب پلن",
//                       style: TextStyle(
//                         color: isSelected ? Colors.white : Colors.grey.shade700,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _getPlanDescription(int index) {
//     switch (index) {
//       case 0:
//         return "مناسب برای شروع کار";
//       case 1:
//         return "پیشنهاد اقتصادی";
//       default:
//         return "پلن استاندارد";
//     }
//   }

//   Widget _paymentButton(ProductState state) {
//     final bool isLoading = state is PaymentUrlLoading;

//     final products = (state is ProductLoaded) ? state.products : cachedProducts;

//     if (products.isEmpty) return const SizedBox();

//     final plan = products[selectedIndex];

//     return Container(
//       width: double.infinity,
//       height: 50,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: isLoading
//               ? [Colors.grey.shade400, Colors.grey.shade300]
//               : [Colors.green.shade500, Colors.lightGreen.shade500],
//         ),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: ElevatedButton(
//         onPressed: isLoading
//             ? null
//             : () => context.read<ProductBloc>().add(SelectProduct(plan.id)),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//         ),
//         child: isLoading
//             ? const SizedBox(
//                 width: 22,
//                 height: 22,
//                 child: CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2,
//                 ),
//               )
//             : Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(
//                     Icons.rocket_launch_rounded,
//                     size: 18,
//                     color: Colors.white,
//                   ),
//                   const SizedBox(width: 6),
//                   Text(
//                     "خرید ${plan.title}",
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w800,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }

//   Widget _footerNote() {
//     return Column(
//       children: [
//         Divider(color: Colors.grey.shade300),
//         const SizedBox(height: 12),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.security_rounded,
//                 color: Colors.green.shade600, size: 14),
//             const SizedBox(width: 6),
//             Text(
//               "پرداخت امن و تضمین شده با درگاه بانکی",
//               style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
