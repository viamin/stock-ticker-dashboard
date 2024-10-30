class Arduino
  attr_reader :template_name

  def initialize(template_name: "ticker", insider_text: nil)
    @template_name = template_name
    @insider_text = insider_text
  end

  def generate_template
    template = File.read(template_path)
    source_code = ERB.new(template)
    @ticker_text = Stock.full_ticker(display: :arduino)
    source_code.result(binding)
  end

  def compile
    `avr-gcc #{cflags} #{project_name}.cpp -o #{project_name}.o`
  end

  def link
    `avr-gcc -w -Os -g -flto -fuse-linker-plugin -Wl,--gc-sections -mmcu=atmega328p -o #{project_name}.elf #{project_name}.o core/*.o`
  end

  def hex
    `avr-objcopy -O ihex -R .eeprom #{project_name}.elf #{project_name}.hex`
  end

  def upload
    `avrdude -F -V -c arduino -p ATMEGA328P -P /dev/ttyACM0 -b 115200 -l #{log_file} -U flash:w:#{project_path}.hex`
  end

  private

  def project_path
    File.join(temp_directory, template_name)
  end

  def temp_directory
    @temp_directory ||= Dir.mktmpdir
  end

  def cflags
    "-c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto -mmcu=atmega328p -DF_CPU=16000000L -DARDUINO=10813 -DARDUINO_AVR_UNO -DARDUINO_ARCH_AVR -I#{core_path} -I#{variants_path}"
  end

  def template_path
    Rails.root.join("vendor", "arduino", template_name, "#{template_name}.cpp.erb")
  end

  def core_path
    Rails.root.join("vendor", "arduino", "cores", "arduino")
  end

  def variants_path
    Rails.root.join("vendor", "arduino", "variants", "standard")
  end

  def log_file
    Rails.root.join("log", "arduino.log")
  end
end
