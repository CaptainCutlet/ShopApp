import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  OrderItem(
    this.order,
  );

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> with TickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _expanded == true
          ? min(widget.order.items.length * 20.0 + 110, 200)
          : 100,
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.all(15),
        elevation: 100,
        child: Column(
          children: [
            ListTile(
              title: Text(
                '\$${widget.order.amount}',
                // ignore: deprecated_member_use
                style:
                    Theme.of(context).textTheme.title!.copyWith(fontSize: 28),
              ),
              subtitle: Text(
                DateFormat('dd-MM-yyyy hh:mm').format(widget.order.date),
              ),
              trailing: IconButton(
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                icon: Icon(
                    _expanded == false ? Icons.expand_more : Icons.expand_less),
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeIn,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              height: _expanded == true ? widget.order.items.length * 20.0 + 10 : 0,
              child: ListView(
                children: widget.order.items
                    .map(
                      (item) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.title,
                           
                          ),
                          // ignore: deprecated_member_use
                          Text(
                            '${item.quantity}x ${item.price}\$',
                            
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
