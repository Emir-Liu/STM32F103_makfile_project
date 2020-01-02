#include "stm32f10x_conf.h"
 
void uart_init(u32 bound){
  GPIO_InitTypeDef GPIO_InitStructure;
  USART_InitTypeDef USART_InitStructure;
  NVIC_InitTypeDef NVIC_InitStructure;

  RCC_APB2PeriphClockCmd(RCC_APB2Periph_USART1|RCC_APB2Periph_GPIOA, ENABLE); 

  //USART1_TX   GPIOA.9

  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_9; //PA.9
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF_PP; 
  GPIO_Init(GPIOA, &GPIO_InitStructure);

  //USART1_RX   GPIOA.10
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_10;//PA10
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;
  GPIO_Init(GPIOA, &GPIO_InitStructure);
  //Usart1 NVIC 
   NVIC_InitStructure.NVIC_IRQChannel = USART1_IRQn;
  NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority=2 ;
  NVIC_InitStructure.NVIC_IRQChannelSubPriority = 2;    
  NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;     
  NVIC_Init(&NVIC_InitStructure); 

  USART_InitStructure.USART_BaudRate = bound;
  USART_InitStructure.USART_WordLength = USART_WordLength_8b;
  USART_InitStructure.USART_StopBits = USART_StopBits_1;
  USART_InitStructure.USART_Parity = USART_Parity_No;
  USART_InitStructure.USART_HardwareFlowControl = USART_HardwareFlowControl_None;
  USART_InitStructure.USART_Mode = USART_Mode_Rx | USART_Mode_Tx; 
  USART_Init(USART1, &USART_InitStructure); 
  USART_ITConfig(USART1, USART_IT_RXNE, ENABLE);
  USART_Cmd(USART1, ENABLE);                    
}
 
int _write (int fd, char *pBuffer, int size)
    {
        int i=0;
        for (i = 0; i < size; i++)
        {
            while (!(USART1->SR & USART_SR_TXE))
            {
            }
            USART_SendData(USART1, pBuffer[i]);
        }
        return size;
    }
 
int main(void)
{
	uart_init(9600);
    int i=0;
 
  while(1)
  {
       for(i=0;i<1000000;i++);
       printf("hello!\r\n");
 
  }
}

