/+------------------------------------------------------------------+
//|                                                 2016-11-28-1.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <WinUser32.mqh>

/*
函数：在屏幕上显示标签
参数说明：LableName:标签名称；LableDoc:文本内容；LableX；标签X位置；LableY：标签Y位置；
DocSize:文本字号；DocStyle;文本字体；DocColor：文本颜色
*/
void iSetLable(string LableName,string LableDoc,int LableX,int LableY,
               int DocSize,string DocStyle,color DocColor)
{
   ObjectCreate(LableName,OBJ_LABEL,0,0,0);
   ObjectSetText(LableName,LableDoc,DocSize,DocStyle,DocColor);
   ObjectSet(LableName,OBJPROP_XDISTANCE,LableX);
   ObjectSet(LableName,OBJPROP_YDISTANCE,LableY);
                  
               
}
/*
函数：两点之间画线
参数：myfirsttime：第一点时间；myfirstprice：第一点价格；mysecondtime：第二点时间；
      mysecondprice：第二点价格
*/
void iDrawHLine(string name1,double myfirstprice,string name2,double mysecondprice)
{
  ObjectCreate(name1,OBJ_HLINE,0,0,myfirstprice);
  ObjectSet(name1,OBJPROP_PRICE1,myfirstprice);
  
   ObjectCreate(name2,OBJ_HLINE,0,0,mysecondprice);
  ObjectSet(name2,OBJPROP_PRICE1,mysecondprice);
//  ObjectSet(name2,OBJPROP_COLOR,SkyBlue);
 
}

void aDrawHLine(string name1,double myfirstprice,string name2,double mysecondprice,int col)
{
  ObjectCreate(name1,OBJ_HLINE,0,0,myfirstprice);
  ObjectSet(name1,OBJPROP_PRICE1,myfirstprice);
   ObjectSet(name1,OBJPROP_COLOR,col);
   ObjectCreate(name2,OBJ_HLINE,0,0,mysecondprice);
  ObjectSet(name2,OBJPROP_PRICE1,mysecondprice);
  ObjectSet(name2,OBJPROP_COLOR,col);
 
}

extern int qushi=2; //1:上升，2：下降,0:未定义  


struct trend_para
{
  double price;
  datetime time;
};


trend_para s_box_top;
trend_para s_box_bot;
trend_para x_box_top={10000,0};
trend_para x_box_bot={10000,0};



trend_para x_qushi_begain = {0,0};//当上升趋势改变的时候，此变量用来记录下降趋势的开始,下降趋势开始的时间
trend_para s_qushi_begain;
trend_para s_qushi_buy1;
trend_para x_qushi_sell1;
trend_para s_qushi_pingcang;
trend_para x_qushi_pingcang;
trend_para x_qushi_end;
trend_para s_qushi_end;


trend_para s_gubi(trend_para &bottom)
{

   int i=1;
   trend_para tem;
   tem.price=Low[1];
  
   int count=1;
  
   for(i=1;i<100;i++)//假设在100根K线里面一定可以找到
   {
      if(Low[i] <= bottom.price){ return (bottom);} //如果K线的最低价就小于底部，则返回原值
      if(Low[i] >= tem.price){;}//如果K线的最低价大于第一根的最低价，则忽略，什么也不做，否则
      else
      {
         tem.price = Low[i];//更新最低价格，计数加1，当加到3的时候表示找到顾比倒数的值，返回此值
         tem.time = Time[i];
         count++;
 //        Print(count);
         if(count == 3){return (tem);}
      }
   }
   return bottom;
 
}
trend_para x_gubi(trend_para &top)
{
int i=1;
trend_para tem;
tem.price=High[1];
int count=1;
for(i=1;i<100;i++)//假设在100根K线里面一定可以找到
   {
      if(High[i] >= top.price)
      {
        // Print("aaaaaaaa");
         return top;
      } //
      if(High[i] <= tem.price){;}//
      else
      {
         tem.price = High[i];//
         tem.time = Time[i];
         count++;
      //   Print("count :",count);
         if(count == 3){return tem;}
      }
   }
   return top;
}
int handle;
int init()
{
//---- indicators
  handle=FileOpen("filename", FILE_CSV|FILE_WRITE, ';');   
//----
 return(0);
}
int deinit() {
  FileClose(handle);
  return 0;
   }
int start()
  {

if(qushi == 1)//在上升趋势中，如果k线的收盘价低于BOX_BOT，则认为趋势反向，需要记录数据：本次趋势最高点的值，如果没有低于box_box，则认为趋势在继续，趋势继续则需要判断箱体的上、下价格是否更新
{
  
   if(Close[1] < s_box_bot.price)//趋势改变
   {
    qushi = 2;//设置趋势改变标志位
   
    x_qushi_begain = s_box_top;//下降趋势的开始
    s_qushi_end = s_box_top;//上升趋势的结束点位
    
    s_qushi_pingcang.price = Close[1];
    s_qushi_pingcang.time = Time[1];
    
    x_qushi_sell1.price = Close[1];
    x_qushi_sell1.time = Time[1];
   
     /******此处注意先后顺序，先给x_qushi_begain赋值再调用***********/
    x_box_bot.price = Low[1];//设置下降趋势的箱体底部，顶部根据顾比倒数规则创建；
    x_box_bot.time =  Time[1];
    
    x_box_top = x_gubi(x_qushi_begain);
    
    
    aDrawHLine("aaa",s_qushi_begain.price,"bbb",s_qushi_end.price,SkyBlue);
//    iSetLable("信息栏6","趋势改变，下降开始,波段长度："+DoubleToString(s_qushi_end.price-s_qushi_begain.price,5),5,120,10,"Verdana",Red);
   
      FileWrite(handle, "上升波段的长度","开始",s_qushi_begain.price,"结束",s_qushi_end.price,s_qushi_end.price-s_qushi_begain.price,
                         "开仓价",              s_qushi_buy1.price,  "平仓价",s_qushi_pingcang.price,s_qushi_pingcang.price-s_qushi_buy1.price,
                s_qushi_begain.time,s_qushi_end.time);
   }
   if(High[1]> s_box_top.price)//如果趋势创新高
   {
    s_box_top.price = High[1];
    s_box_top.time = Time[1];
  
   s_box_bot = s_gubi(s_box_bot);//此处需要一个判断顾比倒数的函数，返回值为第三个重要K线的价格
   
//   iSetLable("信息栏1","上升趋势继续",5,20,10,"Verdana",Red);//在图标上显示价格
   Print("s_box_top :",s_box_top.price);
   Print("s_box_bot:",s_box_bot.price);
  
   }
//  iSetLable("信息栏4","s_box_top:  "+DoubleToString(s_box_top.price,5),5,80,10,"Verdana",Red);
//  iSetLable("信息栏5","s_box_bot:  "+DoubleToString(s_box_bot.price,5),5,100,10,"Verdana",Red);
}
if(qushi == 2)//在下降趋势中，如果k线的收盘价高于BOX_TOP，则认为趋势反向，需要记录数据：本次趋势最低点的值，如果没有高于box_top，则认为趋势在继续，趋势继续则需要判断箱体的上、下价格是否更新
{
 
   if(Close[1] >= x_box_top.price)//趋势改变
   {
  //  Print("aaaaaa");
    qushi = 1;
  
    s_qushi_begain = x_box_bot;//上升趋势开始点
    x_qushi_end    = x_box_bot;//下降趋势结束点
 
    x_qushi_pingcang.price = Close[1];
    x_qushi_pingcang.time  = Time[1];
    
    s_qushi_buy1.price = Close[1];
    s_qushi_buy1.time  = Time[1]; 
 
    /******此处注意先后顺序，先给s_qushi_begain赋值再调用***********/
    s_box_top.price = High[1];//设置新的上升趋势的箱体顶部，底部根据顾比倒数计算。
    s_box_top.time = Time[1];
    s_box_bot = s_gubi(s_qushi_begain);//此处需要一个判断顾比倒数的函数，返回值为第三个重要K线的价格
    
    aDrawHLine("aaa",x_qushi_begain.price,"bbb",x_qushi_end.price,SkyBlue);
    
 //   iSetLable("信息栏7","趋势改变，上升开始，波段长度："+DoubleToString(x_qushi_begain.price-x_qushi_end.price,5),5,140,10,"Verdana",Red); 
    FileWrite(handle, "下降波段的长度","开始",x_qushi_begain.price,"结束",x_qushi_end.price,x_qushi_begain.price-x_qushi_end.price,
               "开仓价",x_qushi_sell1.price,"平仓价",x_qushi_pingcang.price,x_qushi_sell1.price-x_qushi_pingcang.price,
                x_qushi_begain.time,x_qushi_end.time);
   }
   if(Low[1]< x_box_bot.price)//如果趋势创新低
   {
  //  Print("bbbbbbbbbbbbbbbbbbbb");
    x_box_bot.price = Low[1];
    x_box_bot.time = Time[1];
 
    
    x_box_top = x_gubi(x_box_top);//此处需要一个判断顾比倒数的函数，返回值为第三个重要K线的价格
//    iSetLable("信息栏1","下降趋势继续",5,20,10,"Verdana",Red);
  
  
   }
//  iSetLable("信息栏2","x_box_top:  "+DoubleToString(x_box_top.price,5),5,40,10,"Verdana",Red);
 // iSetLable("信息栏3","x_box_bot:  "+DoubleToString(x_box_bot.price,5),5,60,10,"Verdana",Red);
}

  if(qushi == 1){ iDrawHLine("box_top",s_box_top.price,"box_bot",s_box_bot.price);}
  if(qushi == 2){  iDrawHLine("box_top",x_box_top.price,"box_bot",x_box_bot.price);}

  return (0);
  }

