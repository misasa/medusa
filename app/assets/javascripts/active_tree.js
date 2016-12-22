(function($) {
  $(document).on("click", "a.collapse-active", function(a) {
    if ($(this).hasClass("collapsed")) {
      $(this).children("span.badge").removeClass("badge-active");
      $(this).prev().removeClass("glyphicon-active-color");
      if ($(this).parent().children("a.collapse-active").children("span.badge-active").length == 0) {
        $(this).parent().children(":first").removeClass("glyphicon-active-color");
        $(this).parent().children(".box:first").children().removeClass("glyphicon-folder-open");
        $(this).parent().children(".box:first").children().addClass("glyphicon-folder-close");
      }
    } else {
      $(this).children("span.badge").addClass("badge-active");
      $(this).prev().addClass("glyphicon-active-color");
      if ($(this).parent().children("a.collapse-active").children("span.badge-active").length != 0) {
        $(this).parent().children(":first").addClass("glyphicon-active-color");
        $(this).parent().children(".box:first").children().removeClass("glyphicon-folder-close");
        $(this).parent().children(".box:first").children().addClass("glyphicon-folder-open");
      }
    }
  });
}) (jQuery);
