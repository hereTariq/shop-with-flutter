import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/screens/cart.dart';

import '../widgets/product_item.dart';
import '../providers/products.dart';
import '../providers/cart.dart';
import '../widgets/badge.dart';
import '../widgets/app_drawer.dart';

enum FilterOptions { favourites, all }

class ProductOverview extends StatefulWidget {
  const ProductOverview({super.key});

  @override
  State<ProductOverview> createState() => _ProductOverviewState();
}

class _ProductOverviewState extends State<ProductOverview> {
  var _showFavourites = false;

  @override
  void initState() {
    // Provider.of<Products>(context).fetchProducts();
    // Future.delayed(Duration.zero)
    //     .then((value) => Provider.of<Products>(context).fetchProducts());
    super.initState();
  }

  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchProducts().then((_) => {
            setState(
              () {
                _isLoading = false;
              },
            )
          });
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'MyShop',
        ),

        actions: [
          PopupMenuButton(
            onSelected: (value) {
              setState(() {
                if (value == FilterOptions.favourites) {
                  _showFavourites = true;
                } else {
                  _showFavourites = false;
                }
              });
            },
            icon: const Icon(
              Icons.more_vert,
            ),
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: FilterOptions.favourites,
                child: Text('Your Favourites'),
              ),
              const PopupMenuItem(
                value: FilterOptions.all,
                child: Text('Show All'),
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (context, cart, ch) => CartBadge(
              value: cart.itemCount.toString(),
              child: ch!,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.route);
              },
              icon: const Icon(
                Icons.shopping_cart,
              ),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ProductGrid(_showFavourites),
    );
  }
}

class ProductGrid extends StatelessWidget {
  final bool showFavourites;
  const ProductGrid(
    this.showFavourites, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products =
        showFavourites ? productsData.favouriteItems : productsData.items;
    return products.isEmpty
        ? Center(
            child: showFavourites
                ? const Text('You don\'t have favourite item!')
                : const Text('No Products please add one!'),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3 / 2,
            ),
            itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
              // create: (context) => products[index],
              value: products[index],
              child: const ProductItem(),
            ),
            itemCount: products.length,
          );
  }
}
