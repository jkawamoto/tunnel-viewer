//
// port-forwarder.js
//
// Copyright (c) 2017 Junpei Kawamoto
//
// This software is released under the MIT License.
//
// http://opensource.org/licenses/mit-license.php
//

// This module provides class PortForwarder which maintains a port forwarding
// connection.

const {
    spawn,
    execSync
} = require("child_process");
const readline = require("readline");


class PortForwarder {

    // Construct a ssh object which will connect to the given host via the given
    // port and forward the given port, forwarding_port.
    // Port number of the connecting host can be omitted; the default port, 22,
    // will be used.
    constructor(host, port, forwarding_port) {
        if (!forwarding_port) {
            forwarding_port = port;
        } else if (port) {
            host = `${host}:${port}`;
        }
        this.addr = host;
        this.forwarding_port = forwarding_port;
        this.container_name = `privoxy_${port}`;
        this.connected = false;
    }

    // Connect to the host; return a promise fulfilled after port forwarding
    // starts.
    connect() {
        this.connected = true;
        this.process = spawn("ssh", [
            "-t", "-L", `${this.forwarding_port}:localhost:${this.forwarding_port}`,
            this.addr,
            "docker", "run", "-it", "--rm", "--name", this.container_name,
            "-p", `127.0.0.1:${this.forwarding_port}:8118`, "jkawamoto/privoxy"
        ], {
            stdio: [process.stdin, "pipe", process.stderr]
        });
        this.process.on("exit", () => {
            this.process = null;
        });

        const output = readline.createInterface({
            input: this.process.stdout,
        });
        return new Promise((resolve) => {
            output.on("line", (line) => {
                // When privoxy is ready, set proxy and open a window.
                if (line.indexOf("Program name: privoxy") > -1) {
                    resolve();
                }
            });
        });
    }

    // Close some connection if connected; returns a promise fulfilled after
    // the connection is closed.
    close() {
        if (this.connected) {
            // Stop the privoxy container.
            execSync(`ssh ${this.addr} docker stop ${this.container_name}`, {
                stdio: "inherit"
            });
            this.connected = false;
            if (this.process) {
                return new Promise((resolve) => {
                    this.process.on("exit", () => {
                        this.process = null;
                        resolve();
                    });
                    this.process.kill("SIGTERM");
                });
            }
        }
        return Promise.resolve();
    }

}

module.exports = PortForwarder;
