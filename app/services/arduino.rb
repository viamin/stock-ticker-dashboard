class Arduino
  def initialize(
    manipulation: false,
    insider_text: nil,
    scroll_delay: 30, # higher numbers are slower
    ticker_red: "05", # hexadecimal
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
    detect_board_type
    generate_template
    compile
    link
    hex
    upload
  end

  def detect_board_type
    port_data = `arduino-cli board list`
    @board_type = port_data.match(/arduino:avr:(\w+)/).try(:[], 1) || "uno"
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
    `avr-gcc -w -Os -g -flto -fuse-linker-plugin -Wl,--gc-sections -mmcu=#{mmcu} -o #{project_path}.elf #{project_path}.o #{shared_cores_path}/*.o 2>>#{log_file}`
  end

  def hex
    `avr-objcopy -O ihex -R .eeprom #{project_path}.elf #{project_path}.hex 2>>#{log_file}`
  end

  def upload
    `avrdude -F -V -c arduino -p #{mmcu.upcase} -P /dev/ttyACM0 -b 115200 -U flash:w:#{project_path}.hex 2>>#{log_file}`
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
    board_define = @board_type == "uno" ? "ARDUINO_AVR_UNO" : "ARDUINO_AVR_MEGA2560"
    "-c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto -mmcu=#{mmcu} -DF_CPU=16000000L -DARDUINO=10813 -D#{board_define} -DARDUINO_ARCH_AVR -I#{core_path} -I#{variants_path} -I#{hardware_path}"
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
    base = Rails.root.join("vendor", "arduino", "variants")
    @board_type == "uno" ? base.join("standard") : base.join("mega")
  end

  def log_file
    Rails.root.join("log", "arduino.log")
  end

  def mmcu
    @board_type == "uno" ? "atmega328p" : "atmega2560"
  end

  def hardware_path
    Rails.root.join("vendor", "arduino", "hardware", "arduino", "avr")
  end
end
