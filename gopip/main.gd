extends Spatial

# callback to call when new serial data is available (i.e. a full line is read)
var _new_serial_data = JavaScript.create_callback(self, "new_serial_data")


func _on_StartSerialButton_pressed():
	# TODO: add filter to port selection to limit to compatible devices
	# TODO: can the JavaScript code go in a .js file for clarity?
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


func new_serial_data(args: Array):
	var data = args[0]
	print(data)
