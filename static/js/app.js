var editor = null;
var template = {
  curves : null
};

$( document ).ready(function() {

  var source   = $("#entry-template").html();
  template.curves = Handlebars.compile(source);

  $('#search').click (function () {
    $('#menu').hide ();
    $('#results').html ('');
    $('#query').show ();
    var element = document.getElementById ("querytext");
    
    editor = CodeMirror.fromTextArea(element, {
      lineNumbers: true,
      mode: "text/x-sql",
      //matchBrackets: true,
      theme : 'ambiance'
    });

  });

  $('#done').click (function () {
    editor.toTextArea ();
    $('#query').hide ();
    $('#menu').show ();
  });

  $('#run').click (function () {
    $.post (
      "query",
      {
        query : editor.getValue (),
      },
      function (data) {
        console.log (data);
        $("#results").html (template.curves (data));
      });
  });

});
