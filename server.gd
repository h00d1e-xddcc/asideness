extends Node

var server := TCPServer.new()
var clients: Array[StreamPeerTCP] = []

func _ready():
	server.listen(9000, "127.0.0.1")
	print("Command server listening on 9000")

func _process(_delta):
	if server.is_connection_available():
		var client = server.take_connection()
		clients.append(client)

	for client in clients:
		if client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			if client.get_available_bytes() > 0:
				var command = client.get_utf8_string(client.get_available_bytes()).strip_edges()
				handle_command(command)

func handle_command(command: String):
	match command:
		"cfg_reload":
			$"../asideness_user".cfg_reload()
