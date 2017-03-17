window.addEventListener("load", () => {

    const electron = require("electron");
    const riot = require("riot");
    require("./app.tag");
    require("./connection.tag");
    require("./sites.tag");

    // Disable zooming.
    electron.webFrame.setZoomLevelLimits(1, 1);

    // Mount this application.
    riot.mount("app");

});
