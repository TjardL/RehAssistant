import 'package:flutter/material.dart';
class SmallTaskButton extends StatelessWidget {
  SmallTaskButton(this.text,this.function);
  final Function function;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
                width: 200,
                height: 40,
                child: RaisedButton(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Theme.of(context).primaryColor)),
                  //color: Theme.of(context).primaryColor,
                  onPressed: function,
                  child: Text(
                    "$text",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 20.0),
                  ),
                ),
              );
  }
}