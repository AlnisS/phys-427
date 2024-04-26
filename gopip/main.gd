extends Spatial

# callback to call when new serial data is available (i.e. a full line is read)
var _new_serial_data = JavaScript.create_callback(self, "new_serial_data")

var N := 100

var data_loop: PoolVector2Array
var data_loop_i := 0
var data_all_i := 0

func _ready():
	data_loop = PoolVector2Array()
	data_loop.resize(N)
	for i in range(N):
		data_loop[i] = Vector2.ZERO


func _on_StartSerialButton_pressed():
	# TODO: add filter to port selection to limit to compatible devices
	# TODO: can the JavaScript code go in a .js file for clarity?
	# TODO: fail gracefully on platforms without JavaScript (e.g. desktop)
	JavaScript.eval("""
	async function godotWebSerialStart(GD_new_serial_data) {
		// open port selection dialog
		const port = await navigator.serial.requestPort();
		
		const { usbProductId, usbVendorId } = port.getInfo();
		console.log(usbProductId);
		console.log(usbVendorId);
		
		await port.open({ baudRate: 115200 });
		
		// we buffer incoming data to this string, and then pass complete lines
		// onward to GD_new_serial_data(data) when a complete line is read
		var dataBuffer = "";
		
		const textDecoder = new TextDecoderStream();
		const readableStreamClosed = port.readable.pipeTo(textDecoder.writable);
		const reader = textDecoder.readable.getReader();
		
		// listen to data coming from the serial device
		while (true) {
			const { value, done } = await reader.read();
			if (done) {
				reader.releaseLock();  // allow serial port to be closed later
				break;
			}
			dataBuffer += value;  // value is a string
			
			if (dataBuffer.indexOf("\\n") != -1) {
				var dataBufferLines = dataBuffer.split("\\n");
				for (var i = 0; i < dataBufferLines.length - 1; i++) {
					GD_new_serial_data(dataBufferLines[i]);
				}
				dataBuffer = dataBufferLines[dataBufferLines.length - 1];
			}
		}
	}
	
	var godotWebSerialInterface = { start: godotWebSerialStart };
	""", true)
	JavaScript.get_interface("godotWebSerialInterface").start(_new_serial_data)


var data_collection_paused = false

func new_serial_data(args: Array):
	var data: String = args[0]
	$"%SerialPortMonitorLabel".text += data + "\n"
	if data_collection_paused:
		return
	
	var number = data.substr(1).to_float() / 1000.0
	data_loop[data_loop_i] = Vector2(data_loop_i, number)
	data_loop_i += 1
	data_all_i += 1
	if data_loop_i >= N:
		data_loop_i = 0
	$"%Graph2D".data = data_loop
	$"%TableValueLabel".text += str(data_all_i) + "," + str(number) + "\n"


func _on_PauseDataCollection_pressed():
	data_collection_paused = not data_collection_paused
