/*
Part 1 – Lifecycle observations
a) On a first page open: initState, didChangeDependencies, then build. (The
   framework may call build again later.)
b) Pressing a heart calls setState, so build runs again on ProductsPage.
c) When a route is removed, deactivate and dispose run. Pushing another route
   leaves the previous route mounted in the Navigator stack; it is disposed
   when it is eventually popped/removed.
d) Resizing the browser changes MediaQuery. ProductsPage's didChangeDependencies
   runs again and then build runs to display the new width/layout.

Part 4 – Short answers
1) context.go replaces the current location/route stack with the destination;
   this app uses goNamed for Login → Products. context.push adds a page on top
   of the current stack; this app pushes Details from Products so Back returns
   to Products.
2) Login → Products is a destination change, so goNamed avoids keeping Login
   as a page in the back stack. Products → Details uses push so Details can be
   popped and return a result to Products.
3) A path parameter is part of the route path, e.g. /details/Laptop/1200
   (name=Laptop, price=1200). A query parameter follows ? in the URL, e.g.
   /products?user=Guest.

Part 2 – Navigator version (kept as requested; go_router is active below)
The LoginPage, ProductsPage, and DetailsPage Navigator examples are preserved
in comments around their active go_router equivalents.
*/

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'product_widgets.dart';

void main() => runApp(const MiniProductCatalogApp());

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(path: '/', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/products',
      name: 'products',
      builder: (context, state) =>
          ProductsPage(username: state.uri.queryParameters['user'] ?? 'Guest'),
    ),
    GoRoute(
      path: '/details/:name/:price',
      name: 'details',
      builder: (context, state) => DetailsPage(
        productName: state.pathParameters['name']!,
        price: int.parse(state.pathParameters['price']!),
      ),
    ),
  ],
);

class MiniProductCatalogApp extends StatelessWidget {
  const MiniProductCatalogApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Mini Product Catalog',
    theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
    routerConfig: _router,
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    print('LoginPage: initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('LoginPage: didChangeDependencies');
  }

  @override
  Widget build(BuildContext context) {
    print('LoginPage: build');
    return Scaffold(
      appBar: AppBar(title: const Text('Mini Product Catalog')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront, size: 72, color: Colors.indigo),
            const SizedBox(height: 12),
            const Text(
              'Welcome to the catalog',
              style: TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              // Navigator version: Navigator.pushNamed(context, '/products', arguments: 'Guest');
              onPressed: () => context.goNamed(
                'products',
                queryParameters: {'user': 'Guest'},
              ),
              icon: const Icon(Icons.login),
              label: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void deactivate() {
    print('LoginPage: deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    print('LoginPage: dispose');
    super.dispose();
  }
}

const List<Map<String, dynamic>> _products = [
  {'name': 'Laptop', 'price': 1200},
  {'name': 'Headphones', 'price': 150},
  {'name': 'Smart Watch', 'price': 230},
  {'name': 'Keyboard', 'price': 85},
  {'name': 'Phone', 'price': 899},
  {'name': 'Camera', 'price': 640},
];

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key, required this.username});
  final String username;

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  int _favorites = 0;
  double _screenWidth = 0;
  String? _cartMessage;

  @override
  void initState() {
    super.initState();
    print('ProductsPage: initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.sizeOf(context);
    _screenWidth = size.width;
    print(
      'ProductsPage: didChangeDependencies -> width: ${size.width}, height: ${size.height}',
    );
  }

  @override
  Widget build(BuildContext context) {
    print('ProductsPage: build');
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${widget.username}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text('Favorites: $_favorites'),
                Text('Screen width: ${_screenWidth.toStringAsFixed(1)} px'),
                if (_cartMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _cartMessage!,
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _screenWidth < 600
                ? ProductsListView(
                    products: _products,
                    onFavoritePressed: () => setState(() => _favorites++),
                    onProductTap: _openDetails,
                  )
                : ProductsGridView(
                    products: _products,
                    onFavoritePressed: () => setState(() => _favorites++),
                    onProductTap: _openDetails,
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDetails(int index) async {
    final product = _products[index];
    // Navigator version:
    // final result = await Navigator.push<String>(context, MaterialPageRoute(
    //   builder: (_) => DetailsPage(productName: product['name'], price: product['price']),
    // ));
    final result = await context.push<String>(
      '/details/${Uri.encodeComponent(product['name'] as String)}/${product['price']}',
    );
    if (result != null && mounted) setState(() => _cartMessage = result);
  }

  @override
  void deactivate() {
    print('ProductsPage: deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    print('ProductsPage: dispose');
    super.dispose();
  }
}

class DetailsPage extends StatefulWidget {
  const DetailsPage({
    super.key,
    required this.productName,
    required this.price,
  });
  final String productName;
  final int price;

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  void initState() {
    super.initState();
    print('DetailsPage: initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('DetailsPage: didChangeDependencies');
  }

  @override
  Widget build(BuildContext context) {
    print('DetailsPage: build');
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 72,
                color: Colors.indigo,
              ),
              const SizedBox(height: 16),
              Text(
                widget.productName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                '\$${widget.price}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                // Navigator version: Navigator.pop(context, '${widget.productName} added to cart');
                onPressed: () =>
                    context.pop('${widget.productName} added to cart'),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to Cart'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void deactivate() {
    print('DetailsPage: deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    print('DetailsPage: dispose');
    super.dispose();
  }
}

/*
Complete Part 2 Navigator alternative (keep this commented while go_router is
active). These are the equivalent route and page snippets:

MaterialApp(
  routes: {
    '/': (_) => const LoginPage(),
    '/products': (context) => ProductsPage(
      username: ModalRoute.of(context)!.settings.arguments as String,
    ),
  },
)

// Login button:
Navigator.pushNamed(context, '/products', arguments: 'Guest');

// Products tap handler:
final result = await Navigator.push<String>(context, MaterialPageRoute(
  builder: (_) => DetailsPage(
    productName: product['name'],
    price: product['price'],
  ),
));
if (result != null && mounted) setState(() => _cartMessage = result);

// Add to Cart button in DetailsPage:
Navigator.pop(context, '${widget.productName} added to cart');
*/
