import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shop/screens/splash.dart';

import './providers/products.dart';
import './providers/cart.dart';
import './providers/auth.dart';

import './screens/product_overview.dart';
import './screens/product_detail.dart';
import './screens/cart.dart';
import './providers/order.dart';
import './screens/order.dart';
import './screens/user_product.dart';
import './screens/edit_product.dart';
import './screens/auth.dart';

void main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => UserAuth(),
        ),
        ChangeNotifierProxyProvider<UserAuth, Products>(
          create: (context) => Products(
            Provider.of<UserAuth>(context, listen: false).token ?? '',
            Provider.of<UserAuth>(context, listen: false).userId ?? '',
            [],
          ),
          update: (ctx, auth, previousProducts) => Products(
            auth.token ?? '',
            auth.userId ?? '',
            previousProducts == null ? [] : previousProducts.items,
          ),
        ),
        ChangeNotifierProxyProvider<UserAuth, Orders>(
          create: (context) => Orders(
              Provider.of<UserAuth>(context, listen: false).token!,
              Provider.of<UserAuth>(context, listen: false).userId!, []),
          update: (context, auth, previousOrders) => Orders(
            auth.token ?? '',
            auth.userId ?? '',
            previousOrders == null ? [] : previousOrders.orders,
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
      ],
      // value: Products(),
      child: Consumer<UserAuth>(
        builder: (ctx, auth, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'shop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.purple,
            ).copyWith(
              secondary: Colors.deepOrange,
              error: Colors.red,
            ),
            // textTheme: const TextTheme(
            //   titleMedium: TextStyle(
            //     fontStyle: FontStyle.italic,
            //   ),
            // ),
            fontFamily: 'Lato',
          ),
          home: auth.isAuth
              ? const ProductOverview()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authSnapshot) =>
                      authSnapshot.connectionState == ConnectionState.waiting
                          ? const Splash()
                          : const Auth(),
                ),
          routes: {
            ProductDetail.route: (ctx) => const ProductDetail(),
            CartScreen.route: (context) => const CartScreen(),
            Order.route: (context) => const Order(),
            UserProduct.route: (context) => const UserProduct(),
            EditProduct.route: (context) => const EditProduct(),
          },
        ),
      ),
    );
  }
}
