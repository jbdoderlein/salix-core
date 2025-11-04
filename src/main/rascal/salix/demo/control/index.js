

// listen to message

window.addEventListener("message", (event) => {
  const message = event.data;
  console.log("Received message:", message, event);
});

function sendMessageToParent(message) {
  window.top.postMessage(message, "*");
}