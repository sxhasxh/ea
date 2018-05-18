extern double �����м�۸�=1300;
extern double ����߶�=1000;//����߶�
extern int net_quality=60;//��������
extern int ֹӯ����=5500;//ֹӯ����
extern double ������� =1.03;

double net[300];//300����ļ۸�
bool check_buy[300];//300���ҵ��Ƿ���ڣ�����Ϊtrue��������FALSE��Ĭ�ϣ�
double orders_buy[300];//������

double ��������     = 0;
double lot_buy[300];//���࿪������

int arrayLong=0;//�������鳤��

//------------------------------------------------------------------------------------------------------------------------
int start() {
    closeFunc();
    A_Stop();
    return(0);
}
//------------------------------------------------------------------------------------------------------------------------
int init(){
    arrayLong=net_quality;
	�������� = AccountBalance() *�������;
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
        Print("����");
    }

    for(int k=0;k<arrayLong;k++)
    {
        check_buy[k]=false;
    }

    double botPrice=�����м�۸�-net_quality*����߶�/2*Point;//�ײ��۸�

    for(int i=0;i<arrayLong;i++)
    {
        net[i]=botPrice+i*����߶�*Point;//����ÿһ���۸�ֵ
    }
    set_lot_buy(1300);   //�������������
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
    for(int i=0;i<arrayLong;i++)  //�Ҷ൥
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
    for(int i=0;i<arrayLong;i++) //ƽ�ֶ൥
    {
        OrderSelect(orders_buy[i],SELECT_BY_TICKET);

        if(check_buy[i]==true)
        {
            if(Ask>OrderOpenPrice()+ֹӯ����*Point && OP_BUY == OrderType())
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
    bool �жϷ���ֵ = FALSE;
    double �˻���ֵ;
    if (�������� <= 0.0) return;
    if(AccountNumber()== 0||AccountEquity()==0.0||AccountBalance()== 0.0)return;

    �˻���ֵ = AccountEquity();
    if (�˻���ֵ > ��������) 
    {
        �жϷ���ֵ = TRUE;
    }
 
    if (�жϷ���ֵ) 
    {
		CloseEverything();
		�жϷ���ֵ = False;
	//    �������� = AccountBalance() *�������;
	�������� = AccountBalance()+300;
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






