import {Socket} from "phoenix"

let canvas = document.getElementById("canvas")
let context = canvas.getContext("2d")

context.fillStyle = "rgb(200, 200, 200)"
context.fillRect(0, 0, canvas.width, canvas.height)
let socket = new Socket("/ws")
socket.connect()

let chan = socket.chan("world:updates", {})
chan.on("gol:state", payload => {
	App.draw(context, payload)
})	
chan.join().receive("ok", () => {
	console.log("Joined Channel")
}).receive("error", ({reason}) => {
	console.log("Failed to join", reason)	
}).after(5000, () => console.log("Still waiting to join..."))

let App = {
	draw: function(context, payload) {
		context.fillStyle = payload.alive ? "rgb(0, 0, 200)" : "rgb(255, 255, 255)"
		context.fillRect(payload.x*10, payload.y*10, 10, 10)	
	}	
}

export default App
