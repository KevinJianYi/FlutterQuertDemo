import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:querys_app/NetUtils.dart';
import 'package:querys_app/LoadingDialog.dart';
import 'package:querys_app/MessageDialog.dart';
import 'package:image_jpeg/image_jpeg.dart';
import 'package:dio/dio.dart';

class ReadCardPage extends StatefulWidget{

  @override
  _ReadCardPage createState() => new _ReadCardPage();

}

class _ReadCardPage extends State<ReadCardPage>{
  File _image;
  File _compressImage;
  List<int> _inputStream;
  int checkType = 0;
  IDCardInfo _cardInfo;
  BankInfo _bankInfo;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        child: new Center(
          child: new Column(
            children: <Widget>[
              new Container(
                height: 300.0,
                child: new Center(
                  child: _image !=null ?
                  new Image.file(_image,
                    height: 240.0,
                    fit: BoxFit.cover,):
                  new Container(
                    height: 240.0,
                    width: double.infinity,
                    decoration: new BoxDecoration(
                      color: Colors.grey,
                    ),
                    child: new Icon(Icons.cloud_upload),
                  )

                ),
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    new Container(
                      margin: new EdgeInsets.all(20.0),
                      alignment: Alignment.centerLeft,
                      child: new RaisedButton(
                          color: Colors.blue,
                          child: new Text("识别身份证",
                            style: new TextStyle(
                                color: Colors.white
                            ),),
                          onPressed: _readIdCard),
                    ),
                    new Container(
                      alignment: Alignment.centerRight,
                      margin: new EdgeInsets.all(20.0),
                      child: new RaisedButton(
                          color: Colors.blue,
                          child: new Text('识别银行卡',
                            style: new TextStyle(
                                color: Colors.white
                            ),),
                          onPressed: _readBank),
                    ),
                  ],
              ),
              new Offstage(
                offstage: checkType== 0?false:true,
                child: new Card(
                  elevation: 5.0,
//                  color: const Color(0xFFe1f5fe),
                  color: Colors.blue[300],
                  margin: new EdgeInsets.all(10.0),
                  child: new Column(
                    children: <Widget>[
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Container(
                            padding: new EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                            alignment: Alignment.centerLeft,
                            child: new Text('姓名：${_cardInfo!=null?_cardInfo.name:""}',
                              style: _card_text_style,),
                          ),
                          new Container(
                            alignment: Alignment.centerLeft,
                            margin: new EdgeInsets.only(right: 10.0),
                            child: new OutlineButton(
                                borderSide:new BorderSide(color: Colors.blueAccent),
                                child: new Text('复制证号',style: new TextStyle( color: Colors.white),),
                                onPressed: (){
                                  copyToClipboard(_cardInfo.id_card_number);
                            }),
                          )
                        ],
                      ),
                      new Padding(padding: new EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                        child: new Container(
                          alignment: Alignment.centerLeft,
                          child: new Row(
                            children: <Widget>[
                              new Container(
                                alignment: Alignment.centerLeft,
                                child: new Text('性别：${_cardInfo!=null?_cardInfo.gender:""}',
                                  style: _card_text_style,),
                              ),
                              new Container(
                                alignment: Alignment.centerRight,
                                margin: new EdgeInsets.only(left: 70.0),
                                child: new Text('民族：${_cardInfo!=null?_cardInfo.race:""}',
                                  style: _card_text_style,),
                              )
                            ],
                          ),
                        ),),
                      new Padding(padding: new EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                        child: new Container(
                          alignment: Alignment.centerLeft,
                          child: new Text('住址：${_cardInfo!=null?_cardInfo.address:""}',
                            style: _card_text_style,),
                        ),),
                      new Padding(padding: new EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                        child: new Container(
                          alignment: Alignment.centerLeft,
                          child: new Text('身份证号码：${_cardInfo!=null?_cardInfo.id_card_number:""}',
                            style: _card_text_style,),
                        ),
                      ),


                    ],
                  ),
                ) ,
              ),
              new Offstage(
                offstage: checkType == 1?false:true,
                child: new Card(
                  elevation: 5.0,
//                  color: const Color(0xFFe1f5fe),
                  color: Colors.blue[300],
                  margin: new EdgeInsets.all(10.0),
                  child: new Column(
                  children: <Widget>[
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Container(
                            padding: new EdgeInsets.all(20.0),
                            alignment: Alignment.centerLeft,
                            child: new Text('银行：${_bankInfo!=null?_bankInfo.bank:""}',
                              style: _card_text_style,),
                          ),
                          new Container(
                            alignment: Alignment.topRight,
                            margin: new EdgeInsets.only(right: 10.0),
                            child: new OutlineButton(
                                child:new Text('复制卡号',style: new TextStyle(color: Colors.white),),
                                borderSide:new BorderSide(color: Colors.blueAccent),
                                onPressed: (){
                                  if(_bankInfo !=null){
                                      copyToClipboard(_bankInfo.number);
                                  }
                                }),
                          ),
                        ],
                    ),
                    new Padding(padding: new EdgeInsets.all(20.0),
                      child: new Container(
                        alignment: Alignment.centerLeft,
                        child: new Text('银行卡号：${_bankInfo!=null?_bankInfo.number:""}',
                        style: _card_text_style,),
                      ),
                    ),
                  ],
                ),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  var _card_text_style = new TextStyle(
    color: Colors.black,
    fontSize: 20.0,
  );

  void _readIdCard(){
    checkType = 0;
    showModalBottomSheet(context: context, builder: _bottomSheetBuilder);

  }

  void _readBank(){
    checkType = 1;
    showModalBottomSheet(context: context, builder: _bottomSheetBuilder);
  }

  Widget _bottomSheetBuilder(BuildContext context){
    return new Container(
      height: 131.0,
      child: new Padding(padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: new Column(
        children: <Widget>[
          _renderBottomMenuItem("相机", ImageSource.camera),
          new Divider(),
          _renderBottomMenuItem("图库", ImageSource.gallery),
        ],
      ),),
    );
  }

  _renderBottomMenuItem(title,ImageSource source){
    var item = new Container(
      height: 50.0,
      child: new Center(
        child: new Text(title),
      ),
    );

    return new InkWell(
      child: item,
      onTap: (){
        Navigator.of(context).pop();
        setState(() {
          getImage(source);
        });
      },
    );
  }

  Future getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source,maxWidth: 1200.0,maxHeight: 800.0);
    if(image == null)
      return;
    setState(() {
      _image = image;
      _compressImg();
    });
  }

  void _compressImg() async{
    showDialog(context: context,
        builder: (BuildContext context){
          return new LoadingDialog(
            text: '正在解析...',
          );
        }
    );
    _compressImage = _image;
    print("文件大小: ${getRollupSize(_image.lengthSync())}");
    List<int> inputStream = _compressImage.readAsBytesSync();
    _inputStream = inputStream;
    String base64Str = Base64Encoder().convert(_inputStream);

    if(_image == null || _inputStream == null){
      return;
    }
    String dataURL = checkType==0?"https://api-cn.faceplusplus.com/cardpp/v1/ocridcard":
    "https://api-cn.faceplusplus.com/cardpp/v1/ocrbankcard";

    Dio dio = new Dio();
    FormData formData = new FormData.from({
      "api_key":"7md2R6QUj8IO-ClwGrpGs62mIZFI3rbU",
      "api_secret":"kZMp43dnC8baxmu6cCb05BMxiPEjyMWH",
      "image_base64": base64Str
    });
    try {
      Response response = await dio.post(dataURL,data: formData);
      Navigator.of(context).pop();
      print(response.headers);
      print(response.data);
      final data = response.data;
      if(checkType == 0){
        final cardsContent = data['cards'];
        List<IDCardInfo> cards = [];
        cardsContent..forEach((card){
          cards.add(IDCardInfo(card['name'],card['gender'],card['id_card_number'],
              card['birthday'],card['race'],card['address']));
        });
        setState(() {
          _cardInfo = cards[0];
        });
      }else{
        final cardsContent = data['bank_cards'];
        List<BankInfo> cards = [];
        cardsContent..forEach((card){
          cards.add(BankInfo(card['number'],card['bank']));
        });
        setState(() {
          _bankInfo = cards[0];
        });
      }


    } on DioError catch(e) {
      Navigator.of(context).pop();
      print(e.message);
      print(e.response.headers);
      print(e.response.request);
    }

  }

  static const RollupSize_Units = ["GB", "MB", "KB", "B"];
  /// 返回文件大小字符串
  static String getRollupSize(int size) {
    int idx = 3;
    int r1 = 0;
    String result = "";
    while (idx >= 0) {
      int s1 = size % 1024;
      size = size >> 10;
      if (size == 0 || idx == 0) {
        r1 = (r1 * 100) ~/ 1024;
        if (r1 > 0) {
          if (r1 >= 10)
            result = "$s1.$r1${RollupSize_Units[idx]}";
          else
            result = "$s1.0$r1${RollupSize_Units[idx]}";
        } else
          result = s1.toString() + RollupSize_Units[idx];
        break;
      }
      r1 = s1;
      idx--;
    }
    return result;
  }


  /** 复制到剪粘板 */
  static copyToClipboard(final String text) {
    if (text == null) return;
    Clipboard.setData(new ClipboardData(text: text));
  }
}

class IDCardInfo{
 String name;
 String gender;
 String id_card_number;
 String birthday;
 String race;
 String address;

 IDCardInfo(this.name, this.gender, this.id_card_number, this.birthday,
     this.race, this.address);

}

class BankInfo{
 String number;
 String bank;

 BankInfo(this.number, this.bank);

}
