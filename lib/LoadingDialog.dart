import 'package:flutter/material.dart';

class LoadingDialog extends Dialog{
  String text;

  LoadingDialog({Key key,this.text:""}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return new Material(
      type: MaterialType.transparency,
      child: new Center(
        child: new SizedBox(
          width: 120.0,
          height: 120.0,
          child: new Container(
            decoration: new ShapeDecoration(
              color: Colors.white,
              shape: new RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0))
              )
            ),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new CircularProgressIndicator(),
                new Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: new Text(text,
                  style: new TextStyle(fontSize: 12.0),),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


}