import {Socket} from "phoenix"

// let socket = new Socket("/ws")
// socket.connect()
// let chan = socket.chan("topic:subtopic", {})
// chan.join().receive("ok", chan => {
//   console.log("Success!")
// })
let socket = new Socket("/ws")
socket.connect()
let chan = socket.chan("world:updates", {})
chan.on("gol:state", payload => {
	console.log("gol", payload)
	// App.draw(payload)
})	
chan.join().receive("ok", () => {
	console.log("Joined Channel")
}).receive("error", ({reason}) => {
	console.log("Failed to join", reason)	
}).after(5000, () => console.log("Still waiting to join..."))

let App = {
}

export default App
