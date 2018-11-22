import 'package:flutter/material.dart';
import 'package:querys_app/express_page.dart';
import 'package:querys_app/readCard_page.dart';
import 'package:querys_app/weather_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: '轻松查',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new ContentController(),
      routes: {
        'weather_page':(BuildContext context) => WeatherPage(),
        'express_page':(BuildContext context) => ExpressPage(),
        'readCard_page':(BuildContext context) => ReadCardPage(),
      },
    );
  }
}

class ContentController extends StatefulWidget{


  @override
  _ContentControllerState createState() => new _ContentControllerState();
}

class _ContentControllerState extends State<ContentController>{
  String title = "查天气";
  int _currentPageIndex = 0;
  var _pageController = new PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new TitleText(
          title: title,
        ),
        centerTitle: true,
      ),
      resizeToAvoidBottomPadding: false,
      body: new PageView.builder(
          onPageChanged: _pageChange,
          controller: _pageController,
          itemBuilder: (BuildContext context,int index){
            return index == 0? new WeatherPage():new ReadCardPage();
      },
      itemCount: 2,),
      bottomNavigationBar:
        new BottomNavigationBar(items: [
          BottomNavigationBarItem(icon: new Icon(Icons.cloud_queue),title: new Text('天气')),
          BottomNavigationBarItem(icon: new Icon(Icons.credit_card),title: new Text('证件'))
        ],
        currentIndex: _currentPageIndex, onTap: onTap,
      ),
    );
  }

  void onTap(int index){
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease);
  }

  void _pageChange (int index){
    setState(() {
      if(_currentPageIndex != index){
        _currentPageIndex = index;
        if(_currentPageIndex == 0){
          title ="查天气";
        }else{
          title = "读证件";
        }
      }
    });
  }

}

class TitleText extends StatefulWidget{

  String title;

  TitleText({Key key,this.title:""}):super(key:key);

  @override
  _TitleTextState createState() =>new _TitleTextState();
}

class _TitleTextState extends State<TitleText>{


  @override
  Widget build(BuildContext context) {
    return new Text(widget.title);
  }
}
