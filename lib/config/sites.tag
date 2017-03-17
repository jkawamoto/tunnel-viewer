<!--
New site tag exposes one event handler, onend, which takes two arguments,
succeed and an object consisting of a title and a url.
If the addition of a new site is canceled, succeed will be false and the object
null.
-->
<new-site>
  <style scoped>
    .row{
      margin: 0px;
    }
    div.row * {
      padding: 0px;
      margin-right: 2px;
    }
    div.row div {
      margin: 0px;
    }
  </style>
  <div class="row">
    <input class="col-xs-3" type="text" ref="title" placeholder="Name"></input>
    <input class="col-xs-7" type="text" ref="url" placeholder="URL"></input>
    <div class="pull-right">
      <button class="btn btn-link" onclick="{ok}">
        <span class="glyphicon glyphicon-ok" area-hidden="true"/>
      </button>
      <button class="btn btn-link" onclick="{cancel}">
        <span class="glyphicon glyphicon-remove" area-hidden="true"/>
      </button>
    </div>
  </div>
  <script>
    ok(){
      opts.onend(true, {
        title: this.refs.title.value,
        url: this.refs.url.value
      });
      this.refs.title.value = "";
      this.refs.url.value = "";
    }
    cancel(){
      opts.onend(false, null);
      this.refs.title.value = "";
      this.refs.url.value = "";
    }
  </script>
</new-site>


<!--
Sites tag exposes one argument, sitelist, which is a list of site objects
each of which consists of title and url; two event handlers, onstart and
onupdate.
onstart sends a site object; onupdate sents a updated list of site objects.
-->
<sites>
  <style scoped>
    @keyframes show{
        from{ opacity: 0; }
        to{ opacity: 1; }
    }
    .show{
      animation: show 0.5s linear 0s;
    }
    .list-group-item button{
      padding: 0px;
    }
    .edit{
      margin: 0px;
    }
    div.edit * {
      padding: 0px;
      margin-right: 2px;
    }
    div.edit div {
      margin: 0px;
    }
  </style>
  <nav class="row">
    <div class="col-xs-offset-11">
      <button type="button" class="btn btn-link {enableList}" onclick="{insert}">
        <span class="glyphicon glyphicon-plus" area-hidden="true"/>
      </button>
    </div>
  </nav>
  <div class="list-group">
    <!-- New web site -->
    <div class="list-group-item {visibleNewSite}">
      <new-site onend="{endNewSite}"></new-site>
    </div>
    <!-- List of existing sites -->
    <div each="{site, key in opts.sitelist}" class="list-group-item">

      <!-- Display information of a site -->
      <div class="{hidden: key === editing} {show: key !== editing}">
        <button class="btn btn-link {enableList}" type="button" onclick={handleStart}>
          <strong>{site.title}:</strong> {site.url} <span class="glyphicon glyphicon-new-window" area-hidden="true"/>
        </button>
        <div class="pull-right">
          <button type="button" class="btn btn-link {enableList}" onclick="{handleEdit}">
            <span class="glyphicon glyphicon-pencil" area-hidden="true"/>
          </button>
          <button type="button" class="btn btn-link {enableList}" onclick="{handleDelete}">
            <span class="glyphicon glyphicon-remove" area-hidden="true"/>
          </button>
        </div>
      </div>

      <!-- Edit information of a site -->
      <div class="row edit {hidden: key !== editing} {show: key === editing}">
        <input class="col-xs-3" type="text" value="{site.title}" oninput="{curTitle}" placeholder="Name"></input>
        <input class="col-xs-7" type="text" value="{site.url}" oninput="{curUrl}" placeholder="URL"></input>
        <div class="pull-right">
          <button class="btn btn-link" onclick="{editOk}">
            <span class="glyphicon glyphicon-ok" area-hidden="true"/>
          </button>
          <button class="btn btn-link" onclick="{editCancel}">
            <span class="glyphicon glyphicon-remove" area-hidden="true"/>
          </button>
        </div>
      </div>
    </div>
  </div>
  <script>
    this.visibleNewSite = "hidden";
    this.enableList = "";
    this.editing = null;

    handleStart(e){
      if(this.enableList !== "disabled"){
        opts.onstart(e.item.site);
      }
    }

    insert(){
      this.visibleNewSite = "show";
      this.enableList = "disabled";
      this.update();
    }

    endNewSite(succeed, site){
      this.visibleNewSite = "hidden";
      this.enableList = "";
      if(succeed){
        opts.sitelist.unshift(site);
        opts.onupdate(opts.sitelist);
      }
      this.update();
    }

    let title;
    let url;
    handleEdit(e){
      if(this.enableList !== "disabled"){
        this.editing = e.item.key;
        title = e.item.site.title;
        url = e.item.site.url;
        this.update();
      }
    }

    curTitle(e){
      title = e.target.value;
    }

    curUrl(e){
      url = e.target.value;
    }

    editOk(e){
      this.editing = null;
      this.update();
      opts.sitelist[e.item.key].title = title;
      opts.sitelist[e.item.key].url = url;
      opts.onupdate(opts.sitelist);
    }

    editCancel(e){
      this.editing = null;
      this.update();
    }

    handleDelete(e){
      if(this.enableList !== "disabled"){
        opts.sitelist.splice(e.item.key, 1);
        opts.onupdate(opts.sitelist);
      }
    }

  </script>
</sites>
