

extern double 网格中间价格=1300;
extern double 网格高度=1000;//网格高度
extern int net_quality=100;//网格数量



extern int 止盈点数=5500;//止盈点数
extern int 止损点数=30000;//止损点数

double net[300];//300网格的价格
bool check[300];//300个挂单是否存在，存在为true，不存在FALSE（默认）
double orders[300];//订单号


double lots[300];//开仓手数
int arrayLong=0;//网格数组长度

//------------------------------------------------------------------------------------------------------------------------
int start() {
    closeFunc();
    return(0);
}
//------------------------------------------------------------------------------------------------------------------------
int init(){
    arrayLong=net_quality;
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

    double botPrice=网格中间价格-网格倍数*网格高度/2*Point;//底部价格

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
                if(OrderClose(OrderTicket(),lots,Bid,3,Red))
                {
                    check[i]=false;
                    orders[i]=-1;
                }
            }
        }
    }
    sendOrder();
}

