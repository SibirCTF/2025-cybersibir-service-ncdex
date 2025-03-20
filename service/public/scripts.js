document.addEventListener("DOMContentLoaded", function () {
    function getQueryParam(param) {
        let urlParams = new URLSearchParams(window.location.search);
        return urlParams.get(param);
    }

    let flashMsg = getQueryParam("flash");
    let flashType = getQueryParam("type"); // success, warn, danger

    if (flashMsg) {
        let flashDiv = document.createElement("div");
        flashDiv.textContent = flashMsg;
        flashDiv.style.padding = "10px";
        flashDiv.style.border = "1px solid";
        flashDiv.style.marginBottom = "10px";
        flashDiv.style.position = "fixed";
        flashDiv.style.top = "10px";
        flashDiv.style.left = "50%";
        flashDiv.style.transform = "translateX(-50%)";
        flashDiv.style.zIndex = "1000";
        flashDiv.style.fontSize = "16px";
        flashDiv.style.fontWeight = "bold";
        flashDiv.style.boxShadow = "0px 2px 10px rgba(0,0,0,0.2)";
        flashDiv.style.borderRadius = "5px";

        switch (flashType) {
            case "warn":
                flashDiv.style.backgroundColor = "#fff3cd"; // Жёлтый
                flashDiv.style.borderColor = "#ffeeba";
                flashDiv.style.color = "#856404";
                break;
            case "danger":
                flashDiv.style.backgroundColor = "#f8d7da"; // Красный
                flashDiv.style.borderColor = "#f5c6cb";
                flashDiv.style.color = "#721c24";
                break;
            default:
                flashDiv.style.backgroundColor = "#d4edda"; // Зелёный (success)
                flashDiv.style.borderColor = "#c3e6cb";
                flashDiv.style.color = "#155724";
        }

        document.body.appendChild(flashDiv);

        let hideTimeout = setTimeout(() => {
            flashDiv.style.opacity = "0";
            setTimeout(() => flashDiv.remove(), 500);
        }, 3000); // Исчезает через 3 сек

        // Если навели курсор - останавливаем таймер
        flashDiv.addEventListener("mouseenter", () => clearTimeout(hideTimeout));

        // Когда убрали курсор - снова запускаем таймер (1.5 сек)
        flashDiv.addEventListener("mouseleave", () => {
            hideTimeout = setTimeout(() => {
                flashDiv.style.opacity = "0";
                setTimeout(() => flashDiv.remove(), 500);
            }, 1500);
        });

        // Убираем flash-параметры из URL
        history.replaceState({}, "", window.location.pathname);
    }
});
