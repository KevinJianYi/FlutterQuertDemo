import 'package:http/http.dart' as http;

class NetUtils{
  static void get(String url,Function callBack,{Map<String,dynamic> params,Function errorCallBack}) async{
    if(params != null && params.isNotEmpty){
      StringBuffer sb = new StringBuffer("?");
      params.forEach((key,value){
        sb.write("$key"+ "=" + "$value" + "&");
      });
      String paramStr = sb.toString();
      paramStr = paramStr.substring(0,paramStr.length -1);
      url += paramStr;
      print("$url");
    }
    try{
      http.Response  res = await http.get(url);
      if(callBack != null){
        callBack(res.body);
      }
    }catch(exception){
      if(errorCallBack != null){
        errorCallBack(exception);
      }
    }
  }

  static void post(String url,Function callBack,{Map<String,dynamic> params,Function errorCallBack}) async{
    try{
      http.Response res = await http.post(url,body:params);
      if(callBack != null){
        callBack(res.body);
      }
    }catch(exception){
      if(errorCallBack !=null){
        errorCallBack(exception);
      }
    }
  }
}