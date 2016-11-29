(function($) {
  $(document).on("click", "a.collapse-active", function(a) {
    if ($(this).hasClass("collapsed")) {
      $(this).parent().children("a.collapse-active").children("span.badge").removeClass("badge-active")
      $(this).parent().children(".box").removeClass("glyphicon-folder-open")
      $(this).parent().children(".box").addClass("glyphicon-folder-close")
      $(this).parent().children(".glyphicon").removeClass("glyphicon-active-color")
    } else {
      $(this).parent().children("a.collapse-active").children("span.badge").addClass("badge-active")
      $(this).parent().children(".box").removeClass("glyphicon-folder-close")
      $(this).parent().children(".box").addClass("glyphicon-folder-open")
      $(this).parent().children(".glyphicon").addClass("glyphicon-active-color")
    }
  });
}) (jQuery);
