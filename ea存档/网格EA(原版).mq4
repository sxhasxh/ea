
extern double 网格高度=1000;//网格高度
extern int 网格倍数=50;//网格倍数
extern double lots=0.01;//开仓手数
extern double 回调平仓值=100;//从高位回调的值，用于平仓
extern int 止盈点数=2500;//止盈点数
extern int 止损点数=30000;//止损点数

double net[300];//300网格的价格
bool check[300];//300个挂单是否存在，存在为true，不存在FALSE（默认）
double orders[300];//
int type[300];//订单类型，sellstop  或者 buystop
int suc[300];//
bool deal[300];//
int arrayLong=0;//网格数组长度

double max;
double min;
//------------------------------------------------------------------------------------------------------------------------
int start() {

closeFunc();
getMaxAndMin();

return(0);

}
//------------------------------------------------------------------------------------------------------------------------
int init(){
   arrayLong=网格倍数*2+1;
   for(int i=0;i<arrayLong;i++)
   {
      orders[i]=-1;
      deal[i]=false;
   }
   getNets();
   sendOrder();
   for(int j=0;j<arrayLong;j++)
   {
      Print(j+"  "+orders[j]);
   }

}

//------------------------------------------------------------------------------------------------------------------------
void getNets(){

if(arrayLong>300){
Print("报错");
}

for(int k=0;k<arrayLong;k++){
check[k]=false;
}

double ask=Ask;
double botPrice=ask-网格倍数*网格高度*Point;//底部价格

for(int i=0;i<arrayLong;i++){
net[i]=botPrice+i*网格高度*Point;//网格每一个价格赋值
}

}

//------------------------------------------------------------------------------------------------------------------------

void getMaxAndMin(){
if(High[0]>max){
max=High[0];
}
if(Low[0]<min){
min=Low[0];
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
             orders[i]=OrderSend(Symbol(),OP_SELLSTOP,lots,net[i],2,0,0,"我的订单",20081010,0,Green);
             if(orders[i]!=-1)
             {
               type[i]=-1;
               check[i]=true;   
               suc[i]=0;
               min=Low[0];
            }
          }
          else
          {
            orders[i]=OrderSend(Symbol(),OP_BUYSTOP,lots,net[i],2,0,0,"我的订单",20081010,0,Green);
            if(orders[i]!=-1)
            {
               type[i]=1;
               check[i]=true;   
               suc[i]=0;
               max=High[0];
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
   if(type[i]==1&&Ask>OrderOpenPrice())deal[i]=true;
   if(type[i]==-1&&Ask<OrderOpenPrice())deal[i]=true;
   if(check[i]==true)
   {
      if(Ask>OrderOpenPrice()+止盈点数*Point&&(max-Ask)>回调平仓值*Point&&type[i]==1)
      {
         if(OrderClose(OrderTicket(),lots,Bid,3,Red))
         {
            check[i]=false;
            orders[i]=-1;
            deal[i]=false;
         }
      }
      if(Ask<OrderOpenPrice()-止盈点数*Point&&(Ask-min)>回调平仓值*Point&&type[i]==-1)
      {
         if(OrderClose(OrderTicket(),lots,Ask,3,Red))
         {
            check[i]=false;
            orders[i]=-1;
            deal[i]=false;
         }
      }
      if(deal[i]&&type[i]==1&&OrderOpenPrice()-Ask>=止损点数*Point)
      {
         if(OrderClose(OrderTicket(),lots,Bid,3,Red))
         {
            check[i]=false;
            orders[i]=-1;
            deal[i]=false;
         }
      }
      if(deal[i]&&type[i]==-1&&Ask-OrderOpenPrice()>=止损点数*Point)
      {
         if(OrderClose(OrderTicket(),lots,Ask,3,Red))
         {
            check[i]=false;
            orders[i]=-1;
            deal[i]=false;
         }
      }
   }
}
sendOrder();
}

//------------------------------------------------------------------------------------------------------------------------
void control()
{
   int iMax=ArrayMaximum(net);
   arrayLong+=1;
   net[arrayLong-1]=net[iMax]+网格高度*Point;
}