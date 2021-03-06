extern double 网格中间价格=1300;
extern double 网格高度=1000;//网格高度
extern int net_quality=60;//网格数量
extern int 止盈点数=5500;//止盈点数
extern double 收益百分比 =0.03;
extern double 收益金额 =300;
double net[300];//300网格的价格
bool check_buy[300];//300个挂单是否存在，存在为true，不存在FALSE（默认）
bool check_sell[300];//300个挂单是否存在，存在为true，不存在FALSE（默认）
double orders_buy[300];//订单号
double orders_sell[300];//订单号
double 期望收益 = 0;
double lot_buy[300];//做多开仓手数
double lot_sell[300];//做空开仓手数
int arrayLong=0;//网格数组长度
double buy_already_close = 0;
double buy_tem = 0;
double sell_already_close = 0;
double sell_tem = 0;
double max_loss = 0;

//--------------------------------------------GB----------------------------------------------------------------//
int qushi=2; //1:上升，2：下降,0:未定义  
int old_qushi=qushi; //1:上升，2：下降,0:未定义  
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


//------------------------------------------end_GB------------------------------------------------------------------//


//------------------------------------------------------------------------------------------------------------------------
int start() {
    trend_judge();
    closeFunc();
    return(0);
}
//------------------------------------------------------------------------------------------------------------------------
int init(){
    arrayLong=net_quality;
    期望收益 = AccountBalance() *收益百分比;
    for(int i=0;i<arrayLong;i++)
    {
        orders_buy[i]=-1;
        orders_sell[i]=-1;
    }
    getNets();
    init_before_run();
    sendOrder();
}
//------------------------------------------------------------------------------------------------------------------------
void getNets()
{
    for(int k=0;k<arrayLong;k++)
    {
        check_buy[k]=false;
        check_sell[k] = false;
    }
    double botPrice=网格中间价格-net_quality*网格高度/2*Point;//底部价格
    for(int i=0;i<arrayLong;i++)
    {
        net[i]=botPrice+i*网格高度*Point;//网格每一个价格赋值
    }
    set_lot_buy(网格中间价格); //设置买入的手数
    set_lot_sell(网格中间价格); //设置卖出的手数
}

void init_before_run()    //运行程序之前的初始化，比如如果存在订单，挂单等
{
   int j= 0;
   for(int i=OrdersTotal();i>=0;i--)
   {  
       OrderSelect(i, SELECT_BY_POS);                                  
       int Tip=OrderType();                   // 定单类型  
       if (Tip>1) {OrderDelete( OrderTicket() ); continue;}               // 是挂单,删除  
       //----------------------------------------------------------------------- 4 --
       if(OP_BUY == Tip)
       {
            for(j = 0;j<arrayLong;j++)
            {
               if(net[j] == MathRound(OrderOpenPrice()) &&OrderComment() == "bear")
               {
                  orders_buy[j]= OrderTicket();
                  check_buy[j] = true;    
               }
            }
        }  
        if(OP_SELL == Tip)
        {
            for(j = 0;j<arrayLong;j++)
            {
               if(net[j] == MathRound(OrderOpenPrice())&&OrderComment() == "bear")
               {
                  orders_sell[j]= OrderTicket();
                  check_sell[j] = true;    
               }
            }
         } 
         //----------------------------------------------------------------------- 5 --  
                                              // 结束定单分析  
    }             
}
void delete_hang_order()
{
   int j= 0;
   for(int i=OrdersTotal();i>=0;i--)
   {  
       OrderSelect(i, SELECT_BY_POS);                                  
       int Tip=OrderType();                   // 定单类型  0 1是买单和卖单，大于1则是挂单
                                              //     OP_BUYLIMIT	2	限价挂单买单
                                              //     OP_SELLLIMIT	3	限价挂单卖单
                                              //     OP_BUYSTOP	4	止损挂单买单
                                             //      OP_SELLSTOP	5	止损挂单卖单
       if (Tip == OP_BUYLIMIT || Tip ==OP_BUYSTOP)   
       {
            for(j = 0;j<arrayLong;j++)
            {
               if(net[j] == MathRound(OrderOpenPrice()) &&OrderComment() == "bear")
               {
                  orders_buy[j]= 0;
                  check_buy[j] = false;    
               }
            }
           OrderDelete( OrderTicket() );
       }
       if (Tip == OP_SELLLIMIT || Tip ==OP_SELLSTOP)  
       {
            for(j = 0;j<arrayLong;j++)
            {
               if(net[j] == MathRound(OrderOpenPrice()) &&OrderComment() == "bear")
               {
                  orders_sell[j]= 0;
                  check_sell[j] = false;    
               }
            }
           OrderDelete( OrderTicket() );
       }
    }
}

//--------------------------------------------GB----------------------------------------------------------------//
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

void trend_judge()
{
   if(old_qushi != qushi)
   {
      delete_hang_order();
      old_qushi = qushi;
   }

   if(qushi == 1)//在上升趋势中，如果k线的收盘价低于BOX_BOT，则认为趋势反向，需要记录数据：本次趋势最高点的值，如果没有低于box_box，则认为趋势在继续，趋势继续则需要判断箱体的上、下价格是否更新
   {
     
      if(Close[1] < s_box_bot.price)//趋势改变
      {
       qushi = 2;//设置趋势改变标志位
      
       x_qushi_begain = s_box_top;//下降趋势的开始
       s_qushi_end = s_box_top;//上升趋势的结束点位
       
      
        /******此处注意先后顺序，先给x_qushi_begain赋值再调用***********/
       x_box_bot.price = Low[1];//设置下降趋势的箱体底部，顶部根据顾比倒数规则创建；
       x_box_bot.time =  Time[1];
       
       x_box_top = x_gubi(x_qushi_begain);
       
      }
      if(High[1]> s_box_top.price)//如果趋势创新高
      {
       s_box_top.price = High[1];
       s_box_top.time = Time[1];
     
      s_box_bot = s_gubi(s_box_bot);//此处需要一个判断顾比倒数的函数，返回值为第三个重要K线的价格
   
      }
   }
   if(qushi == 2)//在下降趋势中，如果k线的收盘价高于BOX_TOP，则认为趋势反向，需要记录数据：本次趋势最低点的值，如果没有高于box_top，则认为趋势在继续，趋势继续则需要判断箱体的上、下价格是否更新
   {
      if(Close[1] >= x_box_top.price)//趋势改变
      {
       qushi = 1;
     
       s_qushi_begain = x_box_bot;//上升趋势开始点
       x_qushi_end    = x_box_bot;//下降趋势结束点
    
       /******此处注意先后顺序，先给s_qushi_begain赋值再调用***********/
       s_box_top.price = High[1];//设置新的上升趋势的箱体顶部，底部根据顾比倒数计算。
       s_box_top.time = Time[1];
       s_box_bot = s_gubi(s_qushi_begain);//此处需要一个判断顾比倒数的函数，返回值为第三个重要K线的价格
       
      }
      if(Low[1]< x_box_bot.price)//如果趋势创新低
      {
       x_box_bot.price = Low[1];
       x_box_bot.time = Time[1];
    
       
       x_box_top = x_gubi(x_box_top);//此处需要一个判断顾比倒数的函数，返回值为第三个重要K线的价格
      }
   }
   
   
}







//------------------------------------------end_GB------------------------------------------------------------------//



void set_lot_buy(double buy_price)
{
    for(int j = 0; j < arrayLong; j++)
    {
        if(net[j] < buy_price && net[j] >= buy_price -100)
        {
            lot_buy[j] = 0.02;
        }
        else if(net[j] < buy_price -100 && net[j] >= buy_price -200)
        {
            lot_buy[j] = 0.03;
        }
        else if(net[j] < buy_price -200 && net[j] >= buy_price -300)
        {
            lot_buy[j] = 0.04;
        }
        else
        {
            lot_buy[j] = 0.01;
        }
    }
}
void set_lot_sell(double sell_price)
{
     for(int j = 0; j < arrayLong; j++)
    {
        if(net[j] >= sell_price && net[j] < sell_price+100)
        {
            lot_sell[j] = 0.02;
        }
        else if(net[j] >= sell_price+100 && net[j] < sell_price+200)
        {
            lot_sell[j] = 0.03;
        }
        else if(net[j] >= sell_price+200 && net[j] < sell_price+300)
        {
            lot_sell[j] = 0.04;
        }
        else if(net[j] >= sell_price+300 && net[j] < sell_price+400)
        {
            lot_sell[j] = 0.05;
        }
        else
        {
            lot_sell[j] = 0.01;
        }
    }
}
//------------------------------------------------------------------------------------------------------------------------
void sendOrder()
{
   if(qushi == 2)
   {
       for(int i=0;i<arrayLong;i++) //挂多单
       {
           if(check_buy[i]==false )
           {
              if( net[i] >= Ask - 21 && net[i] <= Ask + 21)
              {
                  if(net[i]<Ask)
                  {
                      orders_buy[i]=OrderSend(Symbol(),OP_BUYLIMIT,lot_buy[i],net[i],2,0,0,"bear",20180517,0,Green); 
                      if(orders_buy[i]!=-1)
                      {
                          check_buy[i]=true;
                      }
                  }
                  else
                  {
                      orders_buy[i]=OrderSend(Symbol(),OP_BUYSTOP,lot_buy[i],net[i],2,0,0,"bear",20180517,0,Green);
                      if(orders_buy[i]!=-1)
                      {
                          check_buy[i]=true;
                      }
                  }
               // iSetLable("信息栏4","多单已盈利: "+DoubleToString(buy_already_close,5),5,80,10,"Verdana",Red);
              }
           }
       }
   }
   if(qushi == 1)
   {
       for(i=0;i<arrayLong;i++) //挂空单
       {
           if(check_sell[i]==false )
           {
               if( net[i] >= Ask - 21 && net[i] <= Ask + 21)
               {
                  if(net[i] > Ask)
                  {
                      orders_sell[i]=OrderSend(Symbol(),OP_SELLLIMIT,lot_sell[i],net[i],2,0,0,"bear",20180517,0,Green);
                      if(orders_sell[i]!=-1)
                      {
                          check_sell[i]=true;
                      }
                  }
                  else
                  {
                      orders_sell[i]=OrderSend(Symbol(),OP_SELLSTOP,lot_sell[i],net[i],2,0,0,"bear",20180517,0,Green);
                      if(orders_sell[i]!=-1)
                      {
                          check_sell[i]=true;
                      }
                  }
              }
           }
       }
   }
}
//------------------------------------------------------------------------------------------------------------------------
void closeFunc()
{
buy_tem = 0;
sell_tem = 0;
    for(int i=0;i<arrayLong;i++) //平仓多单
    {
        OrderSelect(orders_buy[i],SELECT_BY_TICKET);
        if(check_buy[i]==true)
        {
            if(Ask>OrderOpenPrice()+止盈点数*Point && OP_BUY == OrderType())
            {
                if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,Red))
                {
                    check_buy[i]=false;
                    orders_buy[i]=-1;
                }
                buy_already_close = OrderProfit() + buy_already_close;
   //             Print("余额：",AccountBalance(),"净值：",AccountEquity());
            }
            else
            {
               buy_tem = OrderProfit() + buy_tem;
            }
        }
    }
    for( i=0;i<arrayLong;i++) //平仓空单
    {
        OrderSelect(orders_sell[i],SELECT_BY_TICKET);
        if(check_sell[i]==true)
        {
            if(Bid < OrderOpenPrice() - 止盈点数*Point && OP_SELL == OrderType())
            {
                if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,Red))
                {
                    check_sell[i]=false;
                    orders_sell[i]=-1;
                }
                sell_already_close = OrderProfit() + sell_already_close;
           //     Print("余额：",AccountBalance(),"净值：",AccountEquity());
            }
            else
            {
               sell_tem = OrderProfit() + sell_tem;
            }
        }
    }
    iSetLable("信息栏1","多单已盈利: "+DoubleToString(buy_already_close,5),5,20,10,"Verdana",Red);
    iSetLable("信息栏2","空单已盈利: "+DoubleToString(sell_already_close,5),5,40,10,"Verdana",Red);
    iSetLable("信息栏3","多单净盈利: "+DoubleToString(buy_tem,5),5,60,10,"Verdana",Red);
    iSetLable("信息栏4","空单净盈利: "+DoubleToString(sell_tem,5),5,80,10,"Verdana",Red);
    if(AccountBalance() - AccountEquity()> max_loss)
    {
      max_loss = AccountBalance() - AccountEquity();
      iSetLable("信息栏5","最大亏损: "+DoubleToString(max_loss,5),5,100,10,"Verdana",Red);
      iSetLable("信息栏6","最大亏损时间: "+TimeYear(TimeCurrent()),5,120,10,"Verdana",Red);
      iSetLable("信息栏7","最大亏损时间: "+TimeMonth(TimeCurrent()),5,140,10,"Verdana",Red);
    }
    if( (buy_already_close + buy_tem) >= 收益金额 )
    {
      CloseEverything(False);
    }
    if( (sell_already_close + sell_tem) >= 收益金额 )
    {
      CloseEverything(True);
    }
    sendOrder();
}
//------------------------------------------------------------------------------------------------------------------------
int CloseEverything(bool flag) //flag == false 平多单，true 平空单
{
    double myAsk, myBid, myLot;
    int myTkt, myTyp;
    int i;
    bool result = false;
    for(i=OrdersTotal();i>=0;i--)
    {
        OrderSelect(i, SELECT_BY_POS);
        myAsk=MarketInfo(OrderSymbol(),MODE_ASK);
        myBid=MarketInfo(OrderSymbol(),MODE_BID);
        myTkt=OrderTicket();
        myLot=OrderLots();
        myTyp=OrderType();
        if(flag == True)
        {
              switch( myTyp )
              {
                 case OP_SELL :result = OrderClose(myTkt, myLot, myAsk, 3, Red);
                                   break;
                 case OP_SELLLIMIT:
                 case OP_SELLSTOP :result = OrderDelete( OrderTicket() );
              }
         }
         else
         {
              switch( myTyp )
              {
               case OP_BUY :result = OrderClose(myTkt, myLot, myBid, 3, Red);
                            break;
               case OP_BUYLIMIT :
               case OP_BUYSTOP :result = OrderDelete( OrderTicket() );
               }
         }
        Sleep(1000);
    }
      if(flag == True)
      {
     for(int k=0;k<arrayLong;k++)
     {
      check_sell[k]=false;
      sell_already_close = 0;
     }
      }
      else
      {
     for(k=0;k<arrayLong;k++)
     {
      check_buy[k]=false;
      buy_already_close = 0;
     }
      }
}
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