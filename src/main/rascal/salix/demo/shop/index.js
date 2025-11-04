var outlinesEnabled = false;
// When DOM is fully loaded add a button to toggle the outlines
document.addEventListener("DOMContentLoaded", function() {
    const button = document.createElement("button");
    button.innerText = "Enable Outlines";
    button.style.position = "fixed";
    button.style.top = "10px";
    button.style.right = "10px";
    button.style.zIndex = 1000;

    button.addEventListener("click", function() {
        outlinesEnabled = !outlinesEnabled;
        button.innerText = outlinesEnabled ? "Disable Outlines" : "Enable Outlines";
    });

    document.body.appendChild(button);
});


document.addEventListener("mouseover", function(e) {
    if (outlinesEnabled) {
        if (e.target.classList.contains("ot-model")) {
            e.target.style.outline = "2px solid blue";
        } else if (e.target.classList.contains("ot-msg")) {
            e.target.style.outline = "2px solid green";
        }
    }
});

document.addEventListener("mouseout", function(e) {
    if (outlinesEnabled) {
        if (e.target.style.outline) {
            e.target.style.outline = "";
        }
    }
});