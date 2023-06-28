import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Order;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/Orders-screen';
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future _getFuture;

  Future getFutureResultMethod() {
    return Provider.of<Order>(context, listen: false).fetchAndSetUpOrder();
  }

  @override
  void initState() {
    _getFuture = getFutureResultMethod();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      body: FutureBuilder(
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (dataSnapshot.hasError) {
              return AlertDialog(
                title: Text('An error occured'),
                content: Text('Please try again later'),
              );
            } else {
              return Consumer<Order>(
                builder: (ctx, orderData, child) {
                  return ListView.builder(
                    itemBuilder: (context, i) => OrderItem(
                      orderData.orderItems[i],
                    ),
                    itemCount: orderData.orderItems.length,
                  );
                },
              );
            }
          }
        },
        future: _getFuture,
      ),
    );
  }
}
