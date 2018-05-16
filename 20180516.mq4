extern double 网格中间价格=1300;
extern double 网格高度=1000;//网格高度
extern int net_quality=100;//网格数量
extern int 止盈点数=5500;//止盈点数
extern int 止损点数=30000;//止损点数
extern double 收益比例 =1.03;

double net[300];//300网格的价格
bool check[300];//300个挂单是否存在，存在为true，不存在FALSE（默认）
double orders[300];//订单号
double 高于净值停止     = 0;
bool 开关返回值 = FALSE;
double lots[300];//开仓手数
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
	高于净值停止 = AccountBalance() *收益比例;
    for(int i=0;i<arrayLong;i++)
    {
        orders[i]=-1;
    }
    getNets();
    sendOrder();
    for(int j=0;j<arrayLong;j++)
    {
        Print(j+"  "+orders[j]);
    }
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
        check[k]=false;
    }

    double botPrice=网格中间价格-net_quality*网格高度/2*Point;//底部价格

    for(int i=0;i<arrayLong;i++)
    {
        net[i]=botPrice+i*网格高度*Point;//网格每一个价格赋值
    }
    for(int j = 0; j < arrayLong; j++)
    {
        if(net[j] < 1299 && net[j] > 1199)
        {
            lots[j] = 0.02;
        }
        else if(net[j] < 1199 && net[j] > 1099)
        {
            lots[j] = 0.03;
        }
        else if(net[j] < 1099 && net[j] > 999)
        {
            lots[j] = 0.04;
        }
        else
        {
            lots[j] = 0.01;
        }
    }
}

/*------------------------------
  挂单函数，将网格范围内的订单挂单。
  */
void sendOrder(){
    for(int i=0;i<arrayLong;i++)
    {
        if(check[i]==false)
        {
            if(net[i]<Ask)
            {
                orders[i]=OrderSend(Symbol(),OP_BUYLIMIT,lots[i],net[i],2,0,0,"我的订单",20081010,0,Green);
                if(orders[i]!=-1)
                {
                    check[i]=true;   
                }
            }
            else
            {
                orders[i]=OrderSend(Symbol(),OP_BUYSTOP,lots[i],net[i],2,0,0,"我的订单",20081010,0,Green);
                if(orders[i]!=-1)
                { 
                    check[i]=true;
                }
            }
        }
    }
}

//------------------------------------------------------------------------------------------------------------------------
void closeFunc()
{
    for(int i=0;i<arrayLong;i++)
    {
        OrderSelect(orders[i],SELECT_BY_TICKET);

        if(check[i]==true)
        {
            if(Ask>OrderOpenPrice()+止盈点数*Point&&OP_BUY == OrderType())
            {
                if(OrderClose(OrderTicket(),lots[i],Bid,3,Red))
                {
                    check[i]=false;
                    orders[i]=-1;
                }
            }
        }
    }
    sendOrder();
}

void A_Stop() 
{
    int res;
    bool 判断开关;
    double 账户净值;
    if (高于净值停止 <= 0.0) return;
    if (!开关返回值) 
    {
        if (AccountNumber() == 0 || AccountEquity() == 0.0 || AccountBalance() == 0.0) return;
        判断开关 = FALSE;
        账户净值 = AccountEquity();
        if (账户净值 > 高于净值停止 && 高于净值停止 > 0.0) 
        {
            判断开关 = TRUE;
        } 
        if (判断开关) 开关返回值 = TRUE;
    }
    if (开关返回值) 
    {
		CloseEverything();
		开关返回值 = False;
		高于净值停止 = AccountBalance() *收益比例;
		for(int k=0;k<arrayLong;k++)
		{
			check[k]=false;
		}
    }
}


int CloseEverything()
{
    double myAsk;
    double myBid;
    int myTkt;
    double myLot;
    int myTyp;
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
            //Close opened long positions
            case OP_BUY :result = OrderClose(myTkt, myLot, myBid, 3, Red);
                         break;
                         //Close opened short positions
            case OP_SELL :result = OrderClose(myTkt, myLot, myAsk, 3, Red);
                          break;
                          //Close pending orders
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
    } //for
} // closeeverything






