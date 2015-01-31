function Evryscope () {
  this.staticURL = EVRY_STATIC_URI;
};
Evryscope.prototype.init = function () {
};
var Evry = new Evryscope ();


var editor = null;
var template = {
  home         : null,
  query        : null,
  queryResults : null,
  images       : null,
  graph        : null
};

$( document ).ready(function() {

  function getTemplate (id) {
    var name = "#" + id + "-template";
    var source = $(name).html();
    return Handlebars.compile(source);
  }
  template.home = getTemplate ("home");
  template.query = getTemplate ("query");
  template.queryResults = getTemplate ("queryResults");
  template.images = getTemplate ("images");
  template.graph = getTemplate ("graph");

  $("#container").html (template.home ());    

  $('#search').click (function () {
    $("#container").html (template.query ({}));    
    $('#done').click (function () {
      editor.toTextArea ();
      $('#query').hide ();
    });
    $('#run').click (function () {
      $.post (
        "query",
        { query : editor.getValue () },
        function (data) {
          console.log (data);
          $("#results").html (template.queryResults (data));
        });
    });
    $('#query').show ();
    var element = document.getElementById ("querytext");
    editor = CodeMirror.fromTextArea(element, {
      lineNumbers: true,
      mode: "text/x-sql",
      //matchBrackets: true,
      theme : 'ambiance'
    });
  });

  $('#graph').click (function () {
    $("#container").html (template.graph ({}));
    makeGraph("many", 40, 50, true);
  });

  $('#images').click (function () {
    $("#container").html (template.images ({}));

    // Panoramic tile pyramid image
    PanoJS.MAX_OVER_ZOOM = 0;
    PanoJS.USE_KEYBOARD = true;
    PanoJS.MSG_BEYOND_MIN_ZOOM = null;
    PanoJS.MSG_BEYOND_MAX_ZOOM = null;
    PanoJS.TILE_EXTENSION = 'png';
    function createViewer( viewer, dom_id, url, prefix, w, h, tileSize ) {
      viewer = new PanoJS (dom_id, {
        initialZoom     : 0,
        maxZoom         : 4,
        staticBaseURL   : '/static/js/panojs/',
        tileBaseUri     : url,
        tilePrefix      : prefix,
        tileSize        : tileSize,
        imageWidth      : w,
        imageHeight     : h,
        blankTile       : '/static/js/panojs/images/blank.gif',
        loadingTile     : '/static/js/panojs/images/progress.gif'
      });
      viewer.init();
      return viewer;
    };
    var viewer = createViewer( viewer, 'viewer', '/static/tiles/cube', 'cube-', 4096, 4096, 256 );


    // Manage the image download link.
    var downloadHref = "/fetchImages?images=";
    $('#download').hover (function () {
      var link = $(this);
      var href = downloadHref;
      var images = [];
      $(".tile").each(function() {  
        images.push (this.src.replace (/.*static\/tiles\//g, ""));
      });
      href += images.join (',');
      link.attr ('href', href);
      $('#downloadCommand').html ("wget --quiet -O- '" + window.location.origin + href + "' | sh ");
      $('#downloadCommand').show ();
    });

  });

  $("#home").click (function () {
    $("#container").html (template.home ());    
  });

});
