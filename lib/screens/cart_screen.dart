import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart';
import '../widgets/cart_item.dart';
import '../providers/cart.dart' show Cart;

class CartScreen extends StatelessWidget {
  static const routeName = '/cart-screen';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: _isLoading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Card(
                  elevation: 10,
                  margin: EdgeInsets.all(15),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(fontSize: 22),
                        ),
                        Spacer(),
                        Chip(
                          backgroundColor: Theme.of(context).primaryColor,
                          label: Text(
                            '\$${cart.totalSpendingAmount.toStringAsFixed(2)}',
                            // ignore: deprecated_member_use
                            style: TextStyle(
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  // ignore: deprecated_member_use
                                  .title!
                                  .color,
                            ),
                          ),
                        ),
                        OrderButton(cart: cart),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (ctx, i) {
                      return CartItem(
                        id: cart.items.values.toList()[i].id,
                        title: cart.items.values.toList()[i].title,
                        quantity: cart.items.values.toList()[i].quantity,
                        price: cart.items.values.toList()[i].price,
                        productId: cart.items.keys.toList()[i],
                      );
                    },
                    itemCount: cart.items.length,
                  ),
                ),
              ],
            ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  @override
  Widget build(BuildContext context) {
    bool _isLoading = false;
    return TextButton(
      onPressed: (widget.cart.totalSpendingAmount <= 0 || _isLoading == true)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Order>(context, listen: false).placeOrder(
                widget.cart.totalSpendingAmount,
                widget.cart.items.values.toList(),
              );
              setState(() {
                _isLoading = false;
              });
              widget.cart.clearCart();
            },
      child: _isLoading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Text(
              'ORDER NOW',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
    );
  }
}
