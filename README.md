# README

This is the dashboard for the NY Trash Exchange and Trashholder's Lounge

It is used to scrape prices from the Racc Investment Management project website and display them on a dashboard. It will also update the prices on an arduino LED based ticker, and allow "hackers" to alter the ticker text if they can figure out how.

## Deployment

The site is hosted on a raspberry pi 4 with a static IP address. To deploy:

```
bundle exec cap production deploy
```

### Open ngrok tunnel

First log into ngrok and get an auth token and fancy url. Then run:

```
ngrok config add-authtoken <your-token>
```

Then open a tmux session and run:

```
ngrok http --url=ethical-lucky-raptor.ngrok-free.app 443
```

## Compile arduino code on the raspberry pi (this example is for arduino uno)

```
curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
arduino-cli core update-index
# verify the board you have with `arduino-cli board list`
# and get details with `arduino-cli board details -b arduino:avr:uno`
arduino-cli core install arduino:avr

sudo apt install gcc-avr avr-libc avrdude

# Create a directory for Arduino core object files
mkdir -p core

# Compile Arduino core files
ARDUINO_CORE="$HOME/.arduino15/packages/arduino/hardware/avr/1.8.6/cores/arduino"
ARDUINO_VARIANTS="$HOME/.arduino15/packages/arduino/hardware/avr/1.8.6/variants/standard"
CFLAGS="-c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto -mmcu=atmega328p -DF_CPU=16000000L -DARDUINO=10813 -DARDUINO_AVR_UNO -DARDUINO_ARCH_AVR -I$ARDUINO_CORE -I$ARDUINO_VARIANTS"

# Core files
avr-gcc $CFLAGS "$ARDUINO_CORE/main.cpp" -o core/main.o
avr-gcc $CFLAGS "$ARDUINO_CORE/wiring.c" -o core/wiring.o
avr-gcc $CFLAGS "$ARDUINO_CORE/wiring_digital.c" -o core/wiring_digital.o
avr-gcc $CFLAGS "$ARDUINO_CORE/wiring_analog.c" -o core/wiring_analog.o
avr-gcc $CFLAGS "$ARDUINO_CORE/HardwareSerial.cpp" -o core/HardwareSerial.o
avr-gcc $CFLAGS "$ARDUINO_CORE/HardwareSerial0.cpp" -o core/HardwareSerial0.o
avr-gcc $CFLAGS "$ARDUINO_CORE/Print.cpp" -o core/Print.o
avr-gcc $CFLAGS "$ARDUINO_CORE/Stream.cpp" -o core/Stream.o
avr-gcc $CFLAGS "$ARDUINO_CORE/WMath.cpp" -o core/WMath.o
avr-gcc $CFLAGS "$ARDUINO_CORE/WString.cpp" -o core/WString.o
avr-gcc $CFLAGS "$ARDUINO_CORE/hooks.c" -o core/hooks.o

# Compile your sketch
avr-gcc $CFLAGS sign.cpp -o sign.o

# Link everything together
avr-gcc -w -Os -g -flto -fuse-linker-plugin -Wl,--gc-sections -mmcu=atmega328p -o sign.elf sign.o core/*.o

# Create hex file
avr-objcopy -O ihex -R .eeprom sign.elf sign.hex

# Upload the file to the arduino
avrdude -F -V -c arduino -p ATMEGA328P -P /dev/ttyACM0 -b 115200 -U flash:w:sign.hex
```

## Credits

Dashboard ticker font is adapted from https://www.fontspace.com/subway-ticker-font-f5621 with some added glyphs ("⏷" & "⏶")
Arduino ticker is based on https://github.com/bigjosh/MacroMarquee (see https://wp.josh.com/2016/05/20/huge-scrolling-arduino-led-sign/ for build info)
