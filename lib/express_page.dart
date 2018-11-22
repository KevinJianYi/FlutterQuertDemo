import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:querys_app/LoadingDialog.dart';
import 'package:querys_app/MessageDialog.dart';
import 'package:querys_app/NetUtils.dart';


class ExpressPage extends StatefulWidget{

  @override
  _ExpressPageState createState() => new _ExpressPageState();

}

class _ExpressPageState extends State<ExpressPage>{

  static TextEditingController oddController = TextEditingController();
  String barcode = "";
  CompanyInfo _companyInfo;
  List<ExpressInfo> _expressInfos;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body:  new ListView(
          children: <Widget>[
            new Container(
              margin: new EdgeInsets.only(left: 20.0,top: 20.0,right: 20.0),
              child: new Center(
                child: new Row(
                  children: <Widget>[
                    new Container(
                      child:
                      new TextField(
                        decoration: new InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '单号',
                            hintText: '请输入查询的快递单号',
                            suffixIcon: new IconButton(
                                icon: new Icon(Icons.photo_camera),
                                onPressed: _barcode_scan),
                        ),
                        controller: oddController,
                      ),
                      width: 240.0,
                    ),
                    new Container(
                      child: new RaisedButton(
                          color: Colors.blue,
                          textColor: Colors.white,
                          child: new Padding(
                            padding: new EdgeInsets.all(10.0),
                            child: new Text('查询',
                            style: new TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                            ),),
                          ),
                          onPressed: _queryExpress),
                      margin: new EdgeInsets.only(left: 10.0),
                    ),
                  ],
                ),
              ),
            ),
            new Container(
              margin: new EdgeInsets.only(top: 20.0),
              child: new Center(
                child: new Text('${_companyInfo!=null?_companyInfo.fullname:""}'),
              ),
            ),
           // getListView(),
          ],
        ),
    );
  }

  void _queryExpress() async{
    if(oddController.text.length == 0){
      showDialog(context: context,
          builder: (BuildContext context){
            return new MessageDialog(
              title: '提示',
              message: '查询单号不能为空！',
              onCloseEvent: (){
                Navigator.of(context).pop();
              },
            );
          });
      return;
    }
    showDialog(context: context,
        builder: (BuildContext context){
          return new LoadingDialog(
            text: '正在查询...',
          );
        }
    );
//    PC调用正常，且只用提供运单号
//    String dataURL = "https://sp0.baidu.com/9_Q4sjW91Qh3otqbppnN2DJv/pae/channel/data/asyncqury";
//    Map<String,dynamic> params = new Map();
//    params['appid'] = "4001";
//    params['com'] = "huitongkuaidi";
//    params['nu'] = oddController.text;
    //需要提供与单号及快递商家标志
    String dataURL = "http://www.kuaidi100.com/query";
    Map<String,dynamic> params = new Map();
    params['type'] = "huitongkuaidi";
    params['postid'] = oddController.text;
    NetUtils.get(dataURL, (data){
      final body = jsonDecode(data);
      print(body);
//      快递单当前签收状态，包括0在途中、1已揽收、2疑难、3已签收、4退签、5同城派送中、6退回、7转单等7个状态，其中4-7需要另外开通才有效
      String code = body['error_code'];
      print(code);
      if(code == "0"){
        final dataContent = body["data"];
        final infoContent = dataContent['info'];
        final companyContent =dataContent['company'];
        CompanyInfo companyInfo = CompanyInfo(companyContent['fullname'], companyContent['shortname']);
        final contextContent = infoContent['context'];
        List<ExpressInfo> expressInfos = [];
        contextContent.forEach((expressInfo){
          expressInfos.add(ExpressInfo(expressInfo['time'], expressInfo['desc']));
        });
        setState(() {
          _companyInfo = companyInfo;
          _expressInfos.add(getRow(_expressInfos.length+1));
        });
      }else{
        print('查询错误');
      }
      Navigator.of(context).pop();
    },params: params,);
  }

  ListView getListView() => new ListView.builder(
//      itemCount: _expressInfos!=null?_expressInfos.length:0,
      itemCount: 5,
      itemBuilder: (BuildContext context,int position){
        if(position.isOdd) return new Divider();
        return new Text('ssssss');
      });
//      itemBuilder: (BuildContext context,int position){
//        if(position.isOdd) return new Divider();
//        return getRow(position);
//      });

  getRow(int i){
    return new Padding(padding: new EdgeInsets.all(10.0),
      child: new Column(
        children: <Widget>[
          new Text("日期：${_expressInfos!=null?_expressInfos[i].time:""}"),
          new Text("${_expressInfos!=null?_expressInfos[i].context:""}"),
        ],
      ),
    );
  }

  Future _barcode_scan() async{

    try{
      String barCode = await BarcodeScanner.scan();
      print("barCode"+barCode);
      setState(() {
        return this.barcode = barCode;
      });
    }on PlatformException catch (e){
      if(e.code == BarcodeScanner.CameraAccessDenied){
        setState(() {
          return this.barcode = 'The user did not grant the camera permission!';

        });
      }else{
        setState(() {
          return this.barcode = 'Unknown error: $e';
        });
      }
    } on FormatException{
      setState(() => this.barcode = 'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }

  }
}

class ListInfo extends StatefulWidget{

  @override
  _ListInfoState createState() =>new _ListInfoState();
}

class _ListInfoState extends State<ListInfo>{

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
//      itemCount: _expressInfos!=null?_expressInfos.length:0,
        itemCount: 5,
        itemBuilder: (BuildContext context,int position){
          if(position.isOdd) return new Divider();
          return new Text('ssssss');
        });;
  }
}

class ExpressInfo{
  String time;
  String context;

  ExpressInfo(this.time, this.context);
}

class CompanyInfo{
  String fullname;
  String shortname;

  CompanyInfo(this.fullname, this.shortname);

}