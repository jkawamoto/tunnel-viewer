const path = require("path");

const {
    app,
    ipcMain,
    session,
    BrowserWindow
} = require("electron");
const storage = require("electron-json-storage");

const PortForwarder = require("./port-forwarder");
const loadPlugin = require("./plugin");

const MAXPORT = 59000;
const MINPORT = 40000;


// Returns a random port number between MINPORT and MAXPORT.
function getRandomPort() {
    return Math.floor(Math.random() * (MAXPORT - MINPORT)) + MINPORT;
}

// Set a given proxy port to the default session, which is a global object;
// returns a promise fulfilled after the proxy is set.
function setProxy(port) {
    return new Promise((resolve) => {
        session.defaultSession.setProxy({
            proxyRules: `localhost:${port}`
        }, resolve);
    });
}

loadPlugin(app);

app.on("ready", () => {

    storage.get("config", (err, config) => {
        if (err) {
            console.error(err);
        }
        if (!config.connection) {
            config.connection = {};
        }
        if (!config.sitelist) {
            config.sitelist = [];
        }

        const configWindow = new BrowserWindow({
            width: 600,
            height: 500,
            useContentSize: true,
            resizable: false,
            fullscreenable: false
        });
        configWindow.loadURL("file://" + path.join(__dirname, "config", "config.html"));
        ipcMain.on("initialize", (event, _) => {
            event.sender.send("initialize-reply", config);
        });

        ipcMain.on("update-connection", (e, arg) => {
            config.connection = arg;
            storage.set("config", config, (err) => {
                if (err) {
                    console.error(err);
                }
                e.returnValue = "done";
            });
        });

        ipcMain.on("update-sitelist", (e, arg) => {
            config.sitelist = arg;
            storage.set("config", config, (err) => {
                if (err) {
                    console.error(err);
                }
                e.returnValue = "done";
            });
        });

        ipcMain.on("start", (e, url) => {
            console.log("Start to connect:", url, "via", config.connection);
            // Random port address.
            const port = getRandomPort();

            // Establish a connection to forward a port; open a window.
            const forwarder = new PortForwarder(config.connection.host, config.connection.port, port);
            forwarder.connect().then(() => {
                return setProxy(port);
            }).then(() => {
                configWindow.hide();
                e.returnValue = "done";

                const mainWindow = new BrowserWindow({
                    width: 1280,
                    height: 720,
                    useContentSize: true,
                    webPreferences: {
                        nodeIntegration: false,
                        session: session.defaultSession,
                        plugins: true
                    }
                });
                mainWindow.loadURL(url);
                mainWindow.on("closed", () => {
                    forwarder.close().then(() => {
                        configWindow.show();
                    }).catch((err) => {
                        console.error(err);
                        configWindow.show();
                    });
                });
            }).catch((err) => {
                console.error(err);
                configWindow.show();
            });
        });

    });

    app.on("window-all-closed", () => {
        app.quit();
    });

});
