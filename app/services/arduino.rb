class Arduino
  def initialize(
    manipulation: false,
    insider_text: nil,
    scroll_delay: 10,
    ticker_red: "10", # hexadecimal
    ticker_green: "00", # hexadecimal
    ticker_blue: "00" # hexadecimal
  )
    @manipulation = manipulation
    @insider_text = insider_text&.upcase&.center(29)
    @scroll_delay = scroll_delay
    @ticker_red = ticker_red
    @ticker_green = ticker_green
    @ticker_blue = ticker_blue
  end

  def update!
    generate_template
    compile
    link
    hex
    upload
  end

  def generate_template
    template = File.read(template_path)
    source_code = ERB.new(template)
    @ticker_text = Stock.full_ticker(display: :arduino)
    code = source_code.result(binding)
    File.open(project_path + ".cpp", "w") { |file| file.write(code) }
  end

  def compile
    `avr-gcc #{cflags} #{project_path}.cpp -o #{project_path}.o 2>>#{log_file}`
  end

  def link
    `avr-gcc -w -Os -g -flto -fuse-linker-plugin -Wl,--gc-sections -mmcu=atmega328p -o #{project_path}.elf #{project_path}.o #{shared_cores_path}/*.o 2>>#{log_file}`
  end

  def hex
    `avr-objcopy -O ihex -R .eeprom #{project_path}.elf #{project_path}.hex 2>>#{log_file}`
  end

  def upload
    `avrdude -F -V -c arduino -p ATMEGA328P -P /dev/ttyACM0 -b 115200 -U flash:w:#{project_path}.hex 2>>#{log_file}`
  end

  private

  def template_name
    "ticker"
  end

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

  def shared_cores_path
    Rails.root.join("vendor", "arduino", "core")
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
