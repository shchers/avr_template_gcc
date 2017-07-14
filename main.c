/**
 * Brief: Simple template for AVR GCC
 * (C) 2017 Sergey Shcherbakov <shchers@gmail.com>
 */
#include <avr/io.h>
#include <avr/interrupt.h>

// On-board LED
#define LED     PB5

int main(void)
{
    // Simple init
    DDRB |= _BV(LED);

    // Turn-on led
    PORTB |= _BV(LED);

    // Infinity loop
    while(1) {}

    return 0;
}
