/*
 * main.c
 *
 *  Created on: 27-06-2013
 *      Author: edd
 */
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/twi.h>
#include <util/delay.h>

#include <stdio.h>
#include <inttypes.h>
#include "mklib_usart.h"
#include "mklib_1wire.h"
#include "mklib_ds18b20.h"

static char spam;
//static char bufor[10] = {0};
static unsigned char address_table[5][8];
static char address_count = 0;

int read_address()
{

	if (DS18B20_read_address(address_table[address_count]) != 0)
		printf("brak czujnika\n");
	else
	{
		for (unsigned char i = 0; i<8; i++)
			{
			printf("%02x",address_table[address_count][i]);
			}
		printf("\n");
		address_count++;
	}
	return 0;
}

ISR(USART_RXC_vect)
{
	char temp = UDR;
	switch (temp)
	{
	case 'r':
		read_address();
		break;
	case 's':
		printf("w³¹czam spam\n");
		spam = 1;
		break;
	case 'p':
		printf("wy³¹czam spam\n");
		spam = 0;
		break;
	case 'a':
		if (address_count > 0)
			{
				for (int i = 0; i <address_count; i++)
				{
					printf("%d: ", i);
					for (int y = 0; y<8; y++)
					{
						printf("%02x", address_table[i][y]);
					}
					printf("\n");
				}
			}
		break;
	default:
		break;
	}
}




int main(){
	USART_init(9600, 1, 1, 1, 0);
	USART_stdout_redirect();
	sei();
	printf("yo yo, kliknij cos!\n");
	spam = 0;

	unsigned int temperatura_ulamki;
	signed char temperatura;

	for(;;)
	{
		_delay_ms(100);
		//DS18B20_get_temp(address_table[0], &temperatura , &temperatura_ulamki);

		if (spam)
			printf("\n");
		//printf("yo yo, kliknij cos!\n");
		for (int i = 0; i <address_count; i++)
		{
			unsigned char result = DS18B20_get_temp(address_table[i], &temperatura , &temperatura_ulamki);
			if (result == 0)
			{
				if (spam != 0)
				{
					printf("%d: %d.%03d\n", i,temperatura, temperatura_ulamki);
				}
			}
			else
			{
				printf("error");
			}
		}


	}
	return 0;
}

