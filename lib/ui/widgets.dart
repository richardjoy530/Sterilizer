import 'package:flutter/material.dart';

Widget genericTile(
    {IconData leadingIcon,
    String text,
    String subTitle,
    Widget trailing,
    void Function() onTap,
    Color color}) {
  return Container(
    decoration: BoxDecoration(
      color: color != null ? color : Colors.grey[100],
      borderRadius: BorderRadius.all(Radius.circular(30.0)),
    ),
    margin: EdgeInsets.all(10),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(
          leadingIcon,
          color: Colors.black,
        ),
        title: Text(text),
        subtitle: subTitle != null ? Text(subTitle) : null,
        trailing: Container(
          width: 60,
          height: 60,
          child: trailing,
        ),
        onTap: onTap,
      ),
    ),
  );
}
