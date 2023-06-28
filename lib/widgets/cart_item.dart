import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    required this.quantity,
    required this.productId,
    required this.price,
    required this.id,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      confirmDismiss: (direction) {
        return showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Are you sure?'),
                content: Text('Do you really want to remove the item?'),
                actions: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    icon: Icon(
                      Icons.cancel_outlined,
                    ),
                    label: Text('No'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    icon: Icon(
                      Icons.done_all_rounded,
                    ),
                    label: Text('Yes'),
                  ),
                ],
              );
            });
      },
      onDismissed: (direction) {
        var cart = Provider.of<Cart>(context, listen: false);
        cart.delete(productId);
      },
      direction: DismissDirection.endToStart,
      key: ValueKey(productId),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 10),
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      ),
      child: Card(
        elevation: 10,
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            child: FittedBox(
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Text('\$$price'),
              ),
            ),
          ),
          title: Text('$title'),
          subtitle: Text('Total: ${(price * quantity)}'),
          trailing: Text('$quantity x'),
        ),
      ),
    );
  }
}
