extern double 网格中间价格=1300;
extern double 网格高度=1000;//网格高度
extern int net_quality=60;//网格数量
extern int 止盈点数=5500;//止盈点数
extern double 收益比例 =1.03;

double net[300];//300网格的价格
bool check_sell[300];//300个挂单是否存在，存在为true，不存在FALSE（默认）
double orders_sell[300];//订单号
double 期望收益     = 0;
double lot_sell[300];//做空开仓手数
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
        orders_sell[i]=-1;
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
        check_sell[k] = false;
    }

    double botPrice=网格中间价格-net_quality*网格高度/2*Point;//底部价格

    for(int i=0;i<arrayLong;i++)
    {
        net[i]=botPrice+i*网格高度*Point;//网格每一个价格赋值
    }
    set_lot_sell();  //设置卖出的手数
}

void set_lot_sell()
{
     for(int j = 0; j < arrayLong; j++)
    {
        
        if(net[j] >= 1301 && net[j] < 1401)
        {
            lot_sell[j] = 0.02;
        }
        else if(net[j] >= 1401 && net[j] < 1501))
        {
            lot_sell[j] = 0.03;
        }
        else if(net[j] >= 1501 && net[j] < 1601))
        {
            lot_sell[j] = 0.04;
        }
        else if(net[j] >= 1601 && net[j] < 1701))
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
void sendOrder(){
    for(int i=0;i<arrayLong;i++) //挂空单
    {
        if(check_sell[i]==false)
        {
            if(net[i] > Ask)
            {
                orders_sell[i]=OrderSend(Symbol(),OP_SELLLIMIT,lot_sell[i],net[i],2,0,0,"sell",20180517,0,Green);
                if(orders_sell[i]!=-1)
                {
                    check_sell[i]=true;   
                }
            }
            else
            {
                orders_sell[i]=OrderSend(Symbol(),OP_SELLSTOP,lot_sell[i],net[i],2,0,0,"sell",20180517,0,Green);
                if(orders_sell[i]!=-1)
                { 
                    check_sell[i]=true;
                }
            }
        }
    }
}

//------------------------------------------------------------------------------------------------------------------------
void closeFunc()
{
    for(int i=0;i<arrayLong;i++) //平仓空单
    {
        OrderSelect(orders_sell[i],SELECT_BY_TICKET);

        if(check_sell[i]==true)
        {
            if(Bid < OrderOpenPrice() - 止盈点数*Point && OP_SELL == OrderType())
            {
                if(OrderClose(OrderTicket(),lot_sell[i],OrderClosePrice(),3,Red))
                {
                    check_sell[i]=false;
                    orders_sell[i]=-1;
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
	    期望收益 = AccountBalance() *收益比例;
		for(int k=0;k<arrayLong;k++)
		{
			check_sell[k]=false;
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






