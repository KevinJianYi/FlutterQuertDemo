import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:querys_app/LoadingDialog.dart';
import 'package:querys_app/MessageDialog.dart';
import 'package:querys_app/NetUtils.dart';

class WeatherPage extends StatefulWidget{

  @override
  _WeatherPageState createState() => new _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage>{

  static TextEditingController cityController = TextEditingController();
  static Weather _weather;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new ListView(
          children: <Widget>[
            new Container(
              margin: new EdgeInsets.all(20.0),
              child: new Center(
                child: new Row(
                  children: <Widget>[
                    new Container(
                      child: new TextField(
                        decoration: new InputDecoration(
                          hintText: '请输入查询的城市名称',
                        ),
                        controller: cityController,
                        style: new TextStyle(
                          fontSize: 22.0,
                          color: Colors.black,
                        ),
                      ),
                      width: 240.0,
                    ),
                    new Container(
                      child: new RaisedButton(
                          color: Colors.blue,
                          textColor: Colors.white,
                          child: new Padding(padding: new EdgeInsets.all(10.0),
                          child: new Text('查询',
                            style: new TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                            ),),
                          ),
                          onPressed: _queryWeather),
                      margin: new EdgeInsets.only(left: 10.0),
                    )
                  ],
                ),
              ),
            ),
            new Container(
              alignment: Alignment.center,
//              decoration: BoxDecoration(
//                  gradient: LinearGradient(
//                      colors: <Color>[Colors.blueAccent[200],Colors.blueAccent[100]],
//                      begin: Alignment.topCenter,
//                      end: Alignment(0.8, 0.0),
//                  )
//              ) ,
              child: new Column(
                children: <Widget>[
                  new Container(
                    height: 50.0,
                    margin: new EdgeInsets.only(top: 10.0),
                    child: new Text('天气：${_weather != null?_weather.forecast[0].type !=null?_weather.forecast[0].type:"":""}',
                      style: new TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w800
                      ),
                    ),
                  ),
                  new Container(
                    height: 50.0,
                    margin: new EdgeInsets.only(top: 10.0),
                    child: new Text('风向：${_weather != null?_weather.forecast[0].fengxiang !=null?_weather.forecast[0].fengxiang:"":""} ~ '
                        '${_weather != null?_weather.forecast[0].fengli !=null?_weather.forecast[0].fengli:"":""}',
                      style: new TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w800
                      ),
                    ),
                  ),
                  new Container(
                    height: 50.0,
                    margin: new EdgeInsets.only(top: 10.0),
                    child: new Text('温度：${_weather != null?_weather.wendu !=null?_weather.wendu:"":""} ℃',
                      style: new TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w800
                      ),
                    ),
                  ),
                  new Container(
                    height: 50.0,
                    margin: new EdgeInsets.only(top: 10.0),
                    child: new Text('${_weather != null?_weather.forecast[0].low !=null?_weather.forecast[0].low:"":""} ~ '
                        '${_weather != null?_weather.forecast[0].high !=null?_weather.forecast[0].high:"":""}',
                      style: new TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w800
                      ),
                    ),
                  ),
                  new Container(
                    height: 50.0,
                    margin: new EdgeInsets.only(top: 10.0),
                    child: new Text('空气质量：${_weather != null?_weather.aqi!=null?_weather.aqi:"":""}',
                        style: new TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w800
                        )
                    ),
                  ),
                  new Container(
                    margin: new EdgeInsets.all(10.0),
                    child: new Text('建议：${_weather != null?_weather.ganmao!=null?_weather.ganmao:"":""}',
                        style: new TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400
                        )
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }

  void _queryWeather() async{
    if(cityController.text.length == 0){
      showDialog(context: context,
      builder: (BuildContext context){
        return new MessageDialog(
          title: '提示',
          message: '查询城市不能为空！',
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
    String dataURL = "https://www.apiopen.top/weatherApi";
    Map<String,dynamic> params = new Map();
    params['city'] = cityController.text;
    NetUtils.get(dataURL,(data){
      if(data != null){
        final body = jsonDecode(data);
        int code = body["code"];
        if(code == 200){
          final weatherContent = body["data"];
          final yesterdayContent = weatherContent['yesterday'];
          Yesterday yesterday = Yesterday(yesterdayContent['date'], yesterdayContent['high'], yesterdayContent['fx'],
              yesterdayContent['low'], cdataToStr(yesterdayContent['fl']), yesterdayContent['type']);
          final forecastContent= weatherContent['forecast'];
          List<Forecast> forecasts = [];
          forecastContent.forEach((forecast){
            forecasts.add(Forecast(forecast['date'], forecast['high'],
                cdataToStr(forecast['fengli']), forecast['low'], forecast['fengxiang'],forecast['type'] ));
          });
          Weather weather = Weather(yesterday, weatherContent['city'],
              weatherContent['aqi'], forecasts,
              weatherContent['ganmao'],weatherContent['wendu'] );

          setState(() {
            _weather =weather;
          });
        }else{
//
        }
      }
      Navigator.of(context).pop();
    },params: params);

  }

  String cdataToStr(String str){
    if(str.isEmpty)
      return "";
    return  str.substring(
        str.lastIndexOf('[')+1,
        str.lastIndexOf(']')-1);
  }

}


class Weather{


    Yesterday yesterday;
    String city ;
    String aqi ;
    List<Forecast> forecast = [];
    String ganmao ;
    String wendu ;

    Weather(this.yesterday, this.city, this.aqi, this.forecast, this.ganmao,
        this.wendu);

}
class Yesterday{
  String date;
  String high;
  String fx;
  String low;
  String fl;
  String type;

  Yesterday(this.date, this.high, this.fx, this.low, this.fl, this.type);

}
class Forecast{
  String date;
  String high;
  String fengli;
  String low;
  String fengxiang;
  String type;

  Forecast(this.date, this.high, this.fengli, this.low, this.fengxiang,
      this.type);

}
