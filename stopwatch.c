#include <stdio.h>
#include <unistd.h>
#include "system.h"
#include "sys/alt_irq.h"


unsigned char	seven_seg_table[] =
			{0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07,
		  	 0x7F, 0x67, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71 };

    volatile int edge_capture;
	volatile int * green_LED_ptr = (int *) LEDG_BASE;
	volatile int * ledr_ptr = (int *) LEDR_BASE;
	volatile int * hex_ptr = (int *) HEX_BASE;
	volatile int * sw_ptr = (int *) SW_BASE;
	volatile int * timer_ptr = (int *) TIMER_BASE;
	volatile int * key_ptr = (int *) KEY_BASE;

	char h = 0;
	char min = 0;
	char sec = 0;
	int press = 0;
	int indice = 0;

	char s = 0;
	int m = 0;
	int sw =0 ;





	void handle_timer_interrupts(void* context, alt_u32 id)
	{
		*(timer_ptr) = 0;
		 sec++;
          if (sec==60){
	  		  min++;sec=0;
	  	  }
	  	  if (min==60){
	  		  h++;min=0;
	  	  }
	  	  if (h==24){
	  		  h=0;
	  	  }
  		  if (indice==1){

  			 s++;

  			  if (s==60){
  				  m++;s=0;
  			  }
  			  if (m==60){
  				  m=0;
  			  }
  		  }
	}

	void handle_key_interrupts(void* context, alt_u32 id)
	{
		press = * (key_ptr +3) ;

	    if ((press&0x2) && (indice ==0)) {
		   indice=1;
		}
	    if ((press&0x4) && (indice == 1)){
		      indice=2;}
		else if ((press&0x4) && (indice == 2)){
			  indice=1;
		}
		if  ((press&0x8) && (indice==2)){
			  indice=0;
			  s=0;
			  m=0;}
		* (key_ptr + 3) =0;
	}





	void init_timer()
	{

	    void* edge_capture_ptr = (void*) &edge_capture;

		*(timer_ptr + 1) = 0x7;
	    alt_irq_register( TIMER_IRQ, edge_capture_ptr,handle_timer_interrupts );
	}
	void init_key()
	{
		void* edge_capture_ptr = (void*) &edge_capture;
		* (key_ptr + 2) = 0xe;
	    alt_irq_register( KEY_IRQ, edge_capture_ptr,handle_key_interrupts );
	}



int main()
{

    init_timer();
    init_key();

    while (1) {
      *green_LED_ptr = * (key_ptr + 3);
  	  *ledr_ptr = *sw_ptr;
  	  sw = *sw_ptr;
  	  if (sw == 0){
  		*hex_ptr = ((seven_seg_table[(h/10)]<<24)&0xFF000000) |((seven_seg_table[(h%10)]<<16)&0x00FF0000) |((seven_seg_table[min/10]<<8)&0x0000FF00) | (seven_seg_table[min%10]&0x000000FF);
  	  }else{
  		*hex_ptr = ((seven_seg_table[(m/10)]<<24)&0xFF000000) |((seven_seg_table[(m%10)]<<16)&0x00FF0000) |((seven_seg_table[s/10]<<8)&0x0000FF00) | (seven_seg_table[s%10]&0x000000FF);
  		 }

  	  usleep(1000);

  }

    return 0;}

