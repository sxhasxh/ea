extern double 网格中间价格=1300;
extern double 网格高度=1000;//网格高度
extern int net_quality=60;//网格数量
extern int 止盈点数=5500;//止盈点数
extern double 收益比例 =1.03;

double net[300];//300网格的价格
bool check_buy[300];//300个挂单是否存在，存在为true，不存在FALSE（默认）
double orders_buy[300];//订单号

double 期望收益     = 0;
double lot_buy[300];//做多开仓手数

int arrayLong=0;//网格数组长度

//------------------------------------------------------------------------------------------------------------------------
int start() {
    closeFunc();
    A_Stop();
    return(0);
}
//------------------------------------------------------------------------------------------------------------------------
int init(){
    arrayLong=net_quality;
	期望收益 = AccountBalance() *收益比例;
    for(int i=0;i<arrayLong;i++)
    {
        orders_buy[i]=-1;
    }
    getNets();
    sendOrder();
}

//------------------------------------------------------------------------------------------------------------------------
void getNets()
{
    if(arrayLong>300)
    {
        Print("报错");
    }

    for(int k=0;k<arrayLong;k++)
    {
        check_buy[k]=false;
    }

    double botPrice=网格中间价格-net_quality*网格高度/2*Point;//底部价格

    for(int i=0;i<arrayLong;i++)
    {
        net[i]=botPrice+i*网格高度*Point;//网格每一个价格赋值
    }
    set_lot_buy(1300);   //设置买入的手数
}

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


//------------------------------------------------------------------------------------------------------------------------
void sendOrder()
{
    for(int i=0;i<arrayLong;i++)  //挂多单
    {
        if(check_buy[i]==false  )
        {
           if( net[i] >= Ask - 51  && net[i] <= Ask + 51)
           {    
               if(net[i]<Ask)
               {
                   orders_buy[i]=OrderSend(Symbol(),OP_BUYLIMIT,lot_buy[i],net[i],2,0,0,"buy",20180517,0,Green);
                   if(orders_buy[i]!=-1)
                   {
                       check_buy[i]=true;   
                   }
               }
               else
               {
                   orders_buy[i]=OrderSend(Symbol(),OP_BUYSTOP,lot_buy[i],net[i],2,0,0,"buy",20180517,0,Green);
                   if(orders_buy[i]!=-1)
                   { 
                       check_buy[i]=true;
                   }
               }
           }
        }
    }
}

//------------------------------------------------------------------------------------------------------------------------
void closeFunc()
{
    for(int i=0;i<arrayLong;i++) //平仓多单
    {
        OrderSelect(orders_buy[i],SELECT_BY_TICKET);

        if(check_buy[i]==true)
        {
            if(Ask>OrderOpenPrice()+止盈点数*Point && OP_BUY == OrderType())
            {
                if(OrderClose(OrderTicket(),lot_buy[i],Bid,3,Red))
                {
                    check_buy[i]=false;
                    orders_buy[i]=-1;
                }
            }
        }
    }
    sendOrder();
}

//------------------------------------------------------------------------------------------------------------------------

void A_Stop() 
{
    bool 判断返回值 = FALSE;
    double 账户净值;
    if (期望收益 <= 0.0) return;
    if(AccountNumber()== 0||AccountEquity()==0.0||AccountBalance()== 0.0)return;

    账户净值 = AccountEquity();
    if (账户净值 > 期望收益) 
    {
        判断返回值 = TRUE;
    }
 
    if (判断返回值) 
    {
		CloseEverything();
		判断返回值 = False;
	//    期望收益 = AccountBalance() *收益比例;
	期望收益 = AccountBalance()+300;
		for(int k=0;k<arrayLong;k++)
		{
			check_buy[k]=false;
		}
    }
}


//------------------------------------------------------------------------------------------------------------------------
int CloseEverything()
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
        switch( myTyp )
        {
            case OP_BUY :result = OrderClose(myTkt, myLot, myBid, 3, Red);
                         break;
            case OP_SELL :result = OrderClose(myTkt, myLot, myAsk, 3, Red);
                          break;
            case OP_BUYLIMIT :
            case OP_BUYSTOP :
            case OP_SELLLIMIT:
            case OP_SELLSTOP :result = OrderDelete( OrderTicket() );
        }
        if(result == false)
        {
            Alert("Order " , myTkt , " failed to close. Error:" , GetLastError() );
            Print("Order " , myTkt , " failed to close. Error:" , GetLastError() );
            Sleep(3000);
        }
        Sleep(1000);
    } 
} 






