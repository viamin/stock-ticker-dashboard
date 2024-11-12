#include <Arduino.h>

// Change this to be at least as long as your pixel string (too long will work fine, just be a little slower)

// #define PIXELS 96*4  // Number of pixels in the string.
#define PIXELS 40
#define DISPLAY_HEIGHT 6

#define COLOR_R 0x04
#define COLOR_G 0x00
#define COLOR_B 0x00

// These values depend on which pins your 8 strings are connected to and what board you are using
// More info on how to find these at http://www.arduino.cc/en/Reference/PortManipulation

// PORTD controls Digital Pins 0-7 on the Uno

// You'll need to look up the port/bit combination for other boards.

// Note that you could also include the DigitalWriteFast header file to not need to to this lookup.

#define PIXEL_PORT PORTD // Port of the pin the pixels are connected to
#define PIXEL_DDR DDRD   // Port of the pin the pixels are connected to

static const uint8_t onBits = 0b11111100; // Bit pattern to write to port to turn on all pins connected to LED strips.
                                          // If you do not want to use all 8 pins, you can mask off the ones you don't want
                                          // Note that these will still get 0 written to them when we send pixels
                                          // TODO: If we have time, we could even add a variable that will and/or into the bits before writing to the port to support any combination of bits/values

// These are the timing constraints taken mostly from
// imperically measuring the output from the Adafruit library strandtest program

// Note that some of these defined values are for refernce only - the actual timing is determinted by the hard code.

#define T1H 814 // Width of a 1 bit in ns - 13 cycles
#define T1L 438 // Width of a 1 bit in ns -  7 cycles

#define T0H 312 // Width of a 0 bit in ns -  5 cycles
#define T0L 936 // Width of a 0 bit in ns - 15 cycles

// Phase #1 - Always 1  - 5 cycles
// Phase #2 - Data part - 8 cycles
// Phase #3 - Always 0  - 7 cycles

#define RES 50000 // Width of the low gap between bits to cause a frame to latch

// Here are some convience defines for using nanoseconds specs to generate actual CPU delays

#define NS_PER_SEC (1000000000L) // Note that this has to be SIGNED since we want to be able to check for negative values of derivatives

#define CYCLES_PER_SEC (F_CPU)

#define NS_PER_CYCLE (NS_PER_SEC / CYCLES_PER_SEC)

#define NS_TO_CYCLES(n) ((n) / NS_PER_CYCLE)

//                              ######                  #####
//   ####  ###### #    # #####  #     # # ##### #    # #     #
//  #      #      ##   # #    # #     # #   #    #  #  #     #
//   ####  #####  # #  # #    # ######  #   #     ##    #####
//       # #      #  # # #    # #     # #   #     ##   #     #
//  #    # #      #   ## #    # #     # #   #    #  #  #     #
//   ####  ###### #    # #####  ######  #   #   #    #  #####

// Sends a full 8 bits down all the pins, represening a single color of 1 pixel
// We walk though the 8 bits in colorbyte one at a time. If the bit is 1 then we send the 8 bits of row out. Otherwise we send 0.
// We send onBits at the first phase of the signal generation. We could just send 0xff, but that mught enable pull-ups on pins that we are not using.

// Unforntunately we have to drop to ASM for this so we can interleave the computaions durring the delays, otherwise things get too slow.

// OnBits is the mask of which bits are connected to strips. We pass it on so that we
// do not turn on unused pins becuase this would enable the pullup. Also, hopefully passing this
// will cause the compiler to allocate a Register for it and avoid a reload every pass.

static inline void sendBitx8(const uint8_t row, const uint8_t colorbyte, const uint8_t onBits)
{

  asm volatile(

      "L_%=: \n\r"

      "out %[port], %[onBits] \n\t" // (1 cycles) - send either T0H or the first part of T1H. Onbits is a mask of which bits have strings attached.

      // Next determine if we are going to be sending 1s or 0s based on the current bit in the color....

      "mov r0, %[bitwalker] \n\t" // (1 cycles)
      "and r0, %[colorbyte] \n\t" // (1 cycles)  - is the current bit in the color byte set?
      "breq OFF_%= \n\t"          // (1 cycles) - bit in color is 0, then send full zero row (takes 2 cycles if branch taken, count the extra 1 on the target line)

      // If we get here, then we want to send a 1 for every row that has an ON dot...
      "nop \n\t  "                 // (1 cycles)
      "out %[port], %[row]   \n\t" // (1 cycles) - set the output bits to [row] This is phase for T0H-T1H.
                                   // ==========
                                   // (5 cycles) - T0H (Phase #1)

      "nop \n\t nop \n\t " // (2 cycles)
      "nop \n\t nop \n\t " // (2 cycles)
      "nop \n\t nop \n\t " // (2 cycles)
      "nop \n\t "          // (1 cycles)

      "out %[port], __zero_reg__ \n\t" // (1 cycles) - set the output bits to 0x00 based on the bit in colorbyte. This is phase for T0H-T1H
                                       // ==========
                                       // (8 cycles) - Phase #2

      "ror %[bitwalker] \n\t" // (1 cycles) - get ready for next pass. On last pass, the bit will end up in C flag

      "brcs DONE_%= \n\t" // (1 cycles) Exit if carry bit is set as a result of us walking all 8 bits. We assume that the process around us will tak long enough to cover the phase 3 delay

      "nop \n\t \n\t " // (1 cycles) - When added to the 5 cycles in S:, we gte the 7 cycles of T1L

      "jmp L_%= \n\t" // (3 cycles)
                      // (1 cycles) - The OUT on the next pass of the loop
                      // ==========
                      // (7 cycles) - T1L

      "OFF_%=: \n\r" // (1 cycles)    Note that we land here becuase of breq, which takes takes 2 cycles

      "out %[port], __zero_reg__ \n\t" // (1 cycles) - set the output bits to 0x00 based on the bit in colorbyte. This is phase for T0H-T1H
                                       // ==========
                                       // (5 cycles) - T0H

      "ror %[bitwalker] \n\t" // (1 cycles) - get ready for next pass. On last pass, the bit will end up in C flag

      "brcs DONE_%= \n\t" // (1 cycles) Exit if carry bit is set as a result of us walking all 8 bits. We assume that the process around us will tak long enough to cover the phase 3 delay

      "nop \n\t nop \n\t " // (2 cycles)
      "nop \n\t nop \n\t " // (2 cycles)
      "nop \n\t nop \n\t " // (2 cycles)
      "nop \n\t nop \n\t " // (2 cycles)
      "nop \n\t "          // (1 cycles)

      "jmp L_%= \n\t" // (3 cycles)
                      // (1 cycles) - The OUT on the next pass of the loop
                      // ==========
                      //(15 cycles) - T0L

      "DONE_%=: \n\t"

      // Don't need an explicit delay here since the overhead that follows will always be long enough

      ::
          [port] "I"(_SFR_IO_ADDR(PIXEL_PORT)),
      [row] "d"(row),
      [onBits] "d"(onBits),
      [colorbyte] "d"(colorbyte), // Phase 2 of the signal where the actual data bits show up.
      [bitwalker] "r"(0x80)       // Alocate a register to hold a bit that we will walk down though the color byte

  );

  // Note that the inter-bit gap can be as long as you want as long as it doesn't exceed the reset timeout (which is A long time)
}

//   ####  #    #  ####  #    #
//  #      #    # #    # #    #
//   ####  ###### #    # #    #
//       # #    # #    # # ## #
//  #    # #    # #    # ##  ##
//   ####  #    #  ####  #    #

// Just wait long enough without sending any bits to cause the pixels to latch and display the last sent frame

void show()
{
  delayMicroseconds((RES / 1000UL) + 1); // Round up since the delay must be _at_least_ this long (too short might not work, too long not a problem)
}

//                              ######                ######   #####  ######
//   ####  ###### #    # #####  #     #  ####  #    # #     # #     # #     #
//  #      #      ##   # #    # #     # #    # #    # #     # #       #     #
//   ####  #####  # #  # #    # ######  #    # #    # ######  #  #### ######
//       # #      #  # # #    # #   #   #    # # ## # #   #   #     # #     #
//  #    # #      #   ## #    # #    #  #    # ##  ## #    #  #     # #     #
//   ####  ###### #    # #####  #     #  ####  #    # #     #  #####  ######

// Send 3 bytes of color data (R,G,B) for a single pixel down all the connected strings at the same time
// A 1 bit in "row" means send the color, a 0 bit means send black.
static inline void sendRowRGB(uint8_t row, uint8_t r, uint8_t g, uint8_t b)
{

  sendBitx8(row, g, onBits); // WS2812 takes colors in GRB order
  sendBitx8(row, r, onBits); // WS2812 takes colors in GRB order
  sendBitx8(row, b, onBits); // WS2812 takes colors in GRB order
}

//   ####  #      ######   ##   #####
//  #    # #      #       #  #  #    #
//  #      #      #####  #    # #    #
//  #      #      #      ###### #####
//  #    # #      #      #    # #   #
//   ####  ###### ###### #    # #    #

// Turn off all pixels

static inline void clear()
{

  cli();
  for (unsigned int i = 0; i < PIXELS; i++)
  {

    sendRowRGB(0, 0, 0, 0);
  }
  sei();
  show();
}


//  ######  ####  #    # #####
//  #      #    # ##   #   #
//  #####  #    # # #  #   #
//  #      #    # #  # #   #
//  #      #    # #   ##   #
//  #       ####  #    #   #

// defines ascii characters 0x20-0x7F (32-127)
// PROGMEM after variable name as per https://www.arduino.cc/en/Reference/PROGMEM

#define FONT_WIDTH 6
#define INTERCHAR_SPACE 1
#define ASCII_OFFSET 0x20 // ASCII code of 1st char in font array

const uint8_t font[] PROGMEM = {
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, //
    0x2f, 0x00, 0x00, 0x00, 0x00, 0x00, // !
    0x03, 0x00, 0x03, 0x00, 0x00, 0x00, // "
    0x12, 0x3f, 0x12, 0x12, 0x3f, 0x12, // #
    0x2e, 0x2a, 0x7f, 0x2a, 0x3a, 0x00, // $
    0x23, 0x13, 0x08, 0x04, 0x32, 0x31, // %
    0x10, 0x2a, 0x25, 0x2a, 0x10, 0x20, // &
    0x02, 0x01, 0x00, 0x00, 0x00, 0x00, // '
    0x1e, 0x21, 0x00, 0x00, 0x00, 0x00, // (
    0x21, 0x1e, 0x00, 0x00, 0x00, 0x00, // )
    0x08, 0x2a, 0x1c, 0x2a, 0x08, 0x08, // *
    0x08, 0x08, 0x3e, 0x08, 0x08, 0x08, // +
    0x80, 0x60, 0x00, 0x00, 0x00, 0x00, // ,
    0x08, 0x08, 0x08, 0x08, 0x08, 0x00, // -
    0x30, 0x30, 0x00, 0x00, 0x00, 0x00, // .
    0x20, 0x10, 0x08, 0x04, 0x02, 0x00, // /
    0x1e, 0x31, 0x29, 0x25, 0x23, 0x1e, // 0
    0x22, 0x21, 0x3f, 0x20, 0x20, 0x20, // 1
    0x32, 0x29, 0x29, 0x29, 0x29, 0x26, // 2
    0x12, 0x21, 0x21, 0x25, 0x25, 0x1a, // 3
    0x18, 0x14, 0x12, 0x3f, 0x10, 0x10, // 4
    0x17, 0x25, 0x25, 0x25, 0x25, 0x19, // 5
    0x1e, 0x25, 0x25, 0x25, 0x25, 0x18, // 6
    0x01, 0x01, 0x31, 0x09, 0x05, 0x03, // 7
    0x1a, 0x25, 0x25, 0x25, 0x25, 0x1a, // 8
    0x06, 0x29, 0x29, 0x29, 0x29, 0x1e, // 9
    0x24, 0x00, 0x00, 0x00, 0x00, 0x00, // :
    0x80, 0x64, 0x00, 0x00, 0x00, 0x00, // ;
    0x08, 0x14, 0x22, 0x00, 0x00, 0x00, // <
    0x14, 0x14, 0x14, 0x14, 0x14, 0x00, // =
    0x22, 0x14, 0x08, 0x00, 0x00, 0x00, // >
    0x02, 0x01, 0x01, 0x29, 0x05, 0x02, // ?
    0x1e, 0x21, 0x2d, 0x2b, 0x2d, 0x0e, // @
    0x3e, 0x09, 0x09, 0x09, 0x09, 0x3e, // A
    0x3f, 0x25, 0x25, 0x25, 0x25, 0x1a, // B
    0x1e, 0x21, 0x21, 0x21, 0x21, 0x12, // C
    0x3f, 0x21, 0x21, 0x21, 0x12, 0x0c, // D
    0x3f, 0x25, 0x25, 0x25, 0x25, 0x21, // E
    0x3f, 0x05, 0x05, 0x05, 0x05, 0x01, // F
    0x1e, 0x21, 0x21, 0x21, 0x29, 0x1a, // G
    0x3f, 0x04, 0x04, 0x04, 0x04, 0x3f, // H
    0x21, 0x21, 0x3f, 0x21, 0x21, 0x21, // I
    0x10, 0x20, 0x20, 0x20, 0x20, 0x1f, // J
    0x3f, 0x04, 0x0c, 0x0a, 0x11, 0x20, // K
    0x3f, 0x20, 0x20, 0x20, 0x20, 0x20, // L
    0x3f, 0x02, 0x04, 0x04, 0x02, 0x3f, // M
    0x3f, 0x02, 0x04, 0x08, 0x10, 0x3f, // N
    0x1e, 0x21, 0x21, 0x21, 0x21, 0x1e, // O
    0x3f, 0x09, 0x09, 0x09, 0x09, 0x06, // P
    0x1e, 0x21, 0x29, 0x31, 0x21, 0x1e, // Q
    0x3f, 0x09, 0x09, 0x09, 0x19, 0x26, // R
    0x12, 0x25, 0x25, 0x25, 0x25, 0x18, // S
    0x01, 0x01, 0x01, 0x3f, 0x01, 0x01, // T
    0x1f, 0x20, 0x20, 0x20, 0x20, 0x1f, // U
    0x0f, 0x10, 0x20, 0x20, 0x10, 0x0f, // V
    0x1f, 0x20, 0x10, 0x10, 0x20, 0x1f, // W
    0x21, 0x12, 0x0c, 0x0c, 0x12, 0x21, // X
    0x01, 0x02, 0x0c, 0x38, 0x04, 0x02, // Y
    0x21, 0x31, 0x29, 0x25, 0x23, 0x21, // Z
    0x3f, 0x21, 0x00, 0x00, 0x00, 0x00, // [
    0x02, 0x04, 0x08, 0x10, 0x20, 0x00, // "\"
    0x21, 0x3f, 0x00, 0x00, 0x00, 0x00, // ]
    0x04, 0x02, 0x3f, 0x02, 0x04, 0x00, // ^
    0x40, 0x40, 0x40, 0x40, 0x40, 0x40, // _
    0x01, 0x02, 0x00, 0x00, 0x00, 0x00, // `
    0x10, 0x30, 0x2a, 0x2a, 0x3c, 0x00, // a
    0x3f, 0x24, 0x24, 0x24, 0x18, 0x00, // b
    0x0c, 0x14, 0x22, 0x22, 0x00, 0x00, // c
    0x18, 0x24, 0x24, 0x24, 0x3f, 0x00, // d
    0x1c, 0x2c, 0x2a, 0x2a, 0x24, 0x00, // e
    0x3e, 0x05, 0x01, 0x00, 0x00, 0x00, // f
    0x18, 0x28, 0xa4, 0xa4, 0x7c, 0x00, // g
    0x3f, 0x04, 0x04, 0x0c, 0x30, 0x00, // h
    0x24, 0x3d, 0x20, 0x00, 0x00, 0x00, // i
    0x20, 0x40, 0x40, 0x3d, 0x00, 0x00, // j
    0x3f, 0x0c, 0x12, 0x20, 0x00, 0x00, // k
    0x1f, 0x20, 0x20, 0x00, 0x00, 0x00, // l
    0x3e, 0x02, 0x3c, 0x02, 0x3c, 0x00, // m
    0x3e, 0x02, 0x02, 0x02, 0x3c, 0x00, // n
    0x0c, 0x14, 0x22, 0x32, 0x0c, 0x00, // o
    0xfc, 0x24, 0x24, 0x24, 0x18, 0x00, // p
    0x18, 0x24, 0x24, 0x24, 0xfc, 0x80, // q
    0x3c, 0x04, 0x02, 0x02, 0x00, 0x00, // r
    0x24, 0x2c, 0x2a, 0x2a, 0x10, 0x00, // s
    0x02, 0x1f, 0x22, 0x20, 0x00, 0x00, // t
    0x1e, 0x20, 0x20, 0x20, 0x1e, 0x00, // u
    0x06, 0x18, 0x20, 0x18, 0x06, 0x00, // v
    0x1e, 0x30, 0x1c, 0x30, 0x0e, 0x00, // w
    0x22, 0x14, 0x08, 0x14, 0x22, 0x00, // x
    0x0c, 0x10, 0xa0, 0xa0, 0x7c, 0x00, // y
    0x22, 0x32, 0x2a, 0x26, 0x22, 0x22, // z
    0x0c, 0x3f, 0x21, 0x00, 0x00, 0x00, // {
    0x3f, 0x00, 0x00, 0x00, 0x00, 0x00, // |
    0x21, 0x3f, 0x0c, 0x00, 0x00, 0x00, // }
    0x02, 0x01, 0x02, 0x01, 0x00, 0x00, // ~
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
};

//                               #####
//   ####  ###### #    # #####  #     # #    #   ##   #####
//  #      #      ##   # #    # #       #    #  #  #  #    #
//   ####  #####  # #  # #    # #       ###### #    # #    #
//       # #      #  # # #    # #       #    # ###### #####
//  #    # #      #   ## #    # #     # #    # #    # #   #
//   ####  ###### #    # #####   #####  #    # #    # #    #

// Send the pixels to form the specified char, not including interchar space
// skip is the number of pixels to skip at the begining to enable sub-char smooth scrolling

// TODO: Subtract the offset from the char before starting the send sequence to save time if nessisary
// TODO: Also could pad the begining of the font table to aovid the offset subtraction at the cost of 20*8 bytes of progmem
// TODO: Could pad all chars out to 8 bytes wide to turn the the multiply by FONT_WIDTH into a shift

static inline void sendChar(uint8_t c, uint8_t skip, uint8_t r, uint8_t g, uint8_t b)
{
  const uint8_t *charbase = font + ((c - ' ') * FONT_WIDTH);

  uint8_t col = FONT_WIDTH;

  while (skip--)
  {
    charbase++;
    col--;
  }

  while (col--)
  {
    // Reverse the bits of the font data
    uint8_t data = pgm_read_byte_near(charbase++);
    uint8_t reversed = 0;

    // Shift bits right-to-left to flip vertically
    for (uint8_t i = 0; i < 8; i++) {
      if (data & (1 << i)) {
        reversed |= (1 << (7 - i));
      }
    }

    sendRowRGB(reversed, r, g, b);
  }

  // Interchar space
  sendRowRGB(0, r, g, b);
}

//                               #####
//   ####  ###### #    # #####  #     # ##### #####  # #    #  ####
//  #      #      ##   # #    # #         #   #    # # ##   # #    #
//   ####  #####  # #  # #    #  #####    #   #    # # # #  # #
//       # #      #  # # #    #       #   #   #####  # #  # # #  ###
//  #    # #      #   ## #    # #     #   #   #   #  # #   ## #    #
//   ####  ###### #    # #####   #####    #   #    # # #    #  ####

// Show the passed string. The last letter of the string will be in the rightmost pixels of the display.
// Skip is how many cols of the 1st char to skip for smooth scrolling

static inline void sendString(const char *s, uint8_t skip, const uint8_t r, const uint8_t g, const uint8_t b)
{

  unsigned int l = PIXELS / (FONT_WIDTH + INTERCHAR_SPACE);

  sendChar(*s, skip, r, g, b); // First char is special case becuase it can be stepped for smooth scrolling

  while (*(++s) && l--)
  {

    sendChar(*s, 0, r, g, b);
  }
}

//  #      ###### #####   ####  ###### ##### #    # #####
//  #      #      #    # #      #        #   #    # #    #
//  #      #####  #    #  ####  #####    #   #    # #    #
//  #      #      #    #      # #        #   #    # #####
//  #      #      #    # #    # #        #   #    # #
//  ###### ###### #####   ####  ######   #    ####  #

// Set the specified pins up as digital out

void ledsetup()
{

  PIXEL_DDR |= onBits; // Set all used pins to output
}


//   ####  ###### ##### #    # #####
//  #      #        #   #    # #    #
//   ####  #####    #   #    # #    #
//       # #        #   #    # #####
//  #    # #        #   #    # #
//   ####  ######   #    ####  #

void setup()
{

  ledsetup();

  // Run the LED test sequence
  // testStrips();
}

//  #######                      #####
//     #    ######  ####  ##### #     # ##### #####  # #####   ####
//     #    #      #        #   #         #   #    # # #    # #
//     #    #####   ####    #    #####    #   #    # # #    #  ####
//     #    #           #   #         #   #   #####  # #####       #
//     #    #      #    #   #   #     #   #   #   #  # #      #    #
//     #    ######  ####    #    #####    #   #    # # #       ####

void testStrips() {
  // Test each row individually
  for (uint8_t row = 0; row < DISPLAY_HEIGHT; row++) {
    uint8_t rowMask = (1 << row);

    // Light up the entire row
    cli();
    for (uint8_t i = 0; i < PIXELS; i++) {
      sendRowRGB(rowMask, COLOR_R, COLOR_G, COLOR_B);
    }
    sei();
    show();
    delay(500); // Keep lit for 500ms

    // Clear the row
    cli();
    for (uint8_t i = 0; i < PIXELS; i++) {
      sendRowRGB(0, 0, 0, 0);
    }
    sei();
    show();
    delay(200); // Wait 200ms before next row
  }

  // Final full display test
  cli();
  for (uint8_t i = 0; i < PIXELS; i++) {
    sendRowRGB(0xFF, COLOR_R, COLOR_G, COLOR_B);
  }
  sei();
  show();
  delay(2000);
  clear();
}

//   ####    ##   #    # #    #   ##
//  #    #  #  #  ##  ## ##  ##  #  #
//  #      #    # # ## # # ## # #    #
//  #  ### ###### #    # #    # ######
//  #    # #    # #    # #    # #    #
//   ####  #    # #    # #    # #    #

// https://learn.adafruit.com/led-tricks-gamma-correction/the-quick-fix

const uint8_t PROGMEM gamma[] = {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2,
    2, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 5, 5, 5,
    5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10,
    10, 10, 11, 11, 11, 12, 12, 13, 13, 13, 14, 14, 15, 15, 16, 16,
    17, 17, 18, 18, 19, 19, 20, 20, 21, 21, 22, 22, 23, 24, 24, 25,
    25, 26, 27, 27, 28, 29, 29, 30, 31, 32, 32, 33, 34, 35, 35, 36,
    37, 38, 39, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 50,
    51, 52, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 66, 67, 68,
    69, 70, 72, 73, 74, 75, 77, 78, 79, 81, 82, 83, 85, 86, 87, 89,
    90, 92, 93, 95, 96, 98, 99, 101, 102, 104, 105, 107, 109, 110, 112, 114,
    115, 117, 119, 120, 122, 124, 126, 127, 129, 131, 133, 135, 137, 138, 140, 142,
    144, 146, 148, 150, 152, 154, 156, 158, 160, 162, 164, 167, 169, 171, 173, 175,
    177, 180, 182, 184, 186, 189, 191, 193, 196, 198, 200, 203, 205, 208, 210, 213,
    215, 218, 220, 223, 225, 228, 231, 233, 236, 239, 241, 244, 247, 249, 252, 255};

// Map 0-255 visual brightness to 0-255 LED brightness
#define GAMMA(x) (pgm_read_byte(&gamma[x]))


//   ####  #####   ##   #####  ###### # ###### #      #####
//  #        #    #  #  #    # #      # #      #      #    #
//   ####    #   #    # #    # #####  # #####  #      #    #
//       #   #   ###### #####  #      # #      #      #    #
//  #    #   #   #    # #   #  #      # #      #      #    #
//   ####    #   #    # #    # #      # ###### ###### #####

void showstarfield()
{

  const uint8_t field = 40; // Good size for a field, must be less than 256 so counters fit in a byte

  uint8_t sectors = (PIXELS / field); // Repeating sectors makes for more stars and faster update

  for (unsigned int i = 0; i < 300; i++)
  {

    unsigned int r = random(PIXELS * 8); // Random slow, so grab one big number and we will break it down.

    unsigned int x = r / 8;
    uint8_t y = r & 0x07;       // We use 7 rows
    uint8_t bitmask = (2 << y); // Start at bit #1 since we enver use the bottom bit

    cli();

    unsigned int l = x;

    while (l--)
    {
      sendRowRGB(0, 0x00, 0x00, 0x00);
    }

    sendRowRGB(bitmask, 0xFF, 0x00, 0x00);

    l = PIXELS - x;

    while (l--)
    {
      sendRowRGB(0, 0x00, 0x00, 0x00);
    }

    sei();

    // show(); // Not needed - random is always slow enough to trigger a reset
  }
}

//  #######
//     #    #  ####  #    # ###### #####
//     #    # #    # #   #  #      #    #
//     #    # #      ####   #####  #    #
//     #    # #      #  #   #      #####
//     #    # #    # #   #  #      #   #
//     #    #  ####  #    # ###### #    #

void showticker(const char *ticker_text)
{

  const char *m = ticker_text;

  uint8_t step = 0;

  while (*m)
  {

    for (uint8_t step = 0; step < FONT_WIDTH + INTERCHAR_SPACE; step++)
    { // step though each column of the 1st char for smooth scrolling

      cli();

      sendString(m, step, COLOR_R, COLOR_G, COLOR_B);

      sei();

      PORTB |= 0x01;
      delay(100);
      PORTB &= ~0x01;
    }

    m++;
  }
}

//  #       ####   ####  #####
//  #      #    # #    # #    #
//  #      #    # #    # #    #
//  #      #    # #    # #####
//  #      #    # #    # #
//  ######  ####   ####  #

void loop()
{

  showticker("       NY TRASH EXCHANGE");
  showstarfield();
  showstarfield();
  showstarfield();

  return;
}
