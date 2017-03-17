<!--
Connection tag exposes three arguments, host, port, and keyfile,
and one event handler, onupdate.
-->
<connection>
  <form class="form-horizontal">
    <div class="form-group">
      <label class="control-label col-xs-3" for="host">Host:</label>
      <div class="col-xs-9">
        <input class="form-control" id="host" ref="host" type="text" value="{opts.host}" onblur="{handleUpdate}"/>
      </div>
    </div>
    <div class="form-group">
      <label class="control-label col-xs-3" for="port">Port:</label>
      <div class="col-xs-9">
        <input class="form-control" id="port" ref="port" type="text" value="{opts.port}" onblur="{handleUpdate}"/>
        <p class="help-block">If omitted, default port number 22 will be used.</p>
      </div>
    </div>
    <div class="form-group">
      <label class="control-labal col-xs-3" for="keyfile">Private key:</label>
      <div class="col-xs-9">
        <input id="keyfile" ref="keyfile" type="file" value="{opts.keyfile}" onchange="{handleUpdate}"/>
        <p class="help-block">Private key file to connect the above host.</p>
      </div>
    </div>
  </form>
  <script>
    handleUpdate(e){
      e.preventDefault();
      opts.onupdate({
        host: this.refs.host.value,
        port: this.refs.port.value,
        keyfile: this.refs.keyfile.value
      });
    }
  </script>
</connection>
