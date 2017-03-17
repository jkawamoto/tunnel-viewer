<app>
  <!-- TODO: Add an information bar to show errors and warnings here. -->
  <section class="container">
    <h1>Connection</h1>
    <connection host={host} port={port} keyfile={keyfile} onupdate={handleUpdateConnection}></connection>
    <h1>Web sites</h1>
    <sites sitelist={sitelist} onstart={handleStart} onupdate={handleUpdateList}></sites>
  </section>
  <script>
    const {ipcRenderer} = require("electron");

    ipcRenderer.on("initialize-reply", (_, arg) => {
      this.host = arg.connection.host;
      this.port = arg.connection.port;
      this.keyfile = arg.connection.keyfile;
      this.sitelist = arg.sitelist;
      this.update();
    })
    ipcRenderer.send("initialize", "");

    // Handle onchange event of connection.
    handleUpdateConnection(arg){
      this.host = arg.host;
      this.port = arg.port;
      this.keyfile = arg.keyfile;
      this.update();
      ipcRenderer.send("update-connection", {
        host: this.host,
        port: this.port,
        keyfile: this.keyfile
      });
    }

    // Handle onstart event. The given arg object has a title and a url.
    handleStart(arg){
      ipcRenderer.send("start", arg.url);
    }

    handleUpdateList(newList){
      this.sitelist = newList;
      this.update();
      ipcRenderer.send("update-sitelist", {
        host: this.host,
        port: this.port,
        keyfile: this.keyfile
      });
    }
  </script>
</app>
