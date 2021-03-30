(function($) {
  $(document).on("click", "a.collapse-active", function(a) {
    if ($(this).hasClass("collapsed")) {
      $(this).children("span.badge").removeClass("badge-active");
      $(this).prev().removeClass("fa-active-color");
      if ($(this).parent().children("a.collapse-active").children("span.badge-active").length == 0) {
        $(this).parent().children(":first").removeClass("fa-active-color");
        $(this).parent().children(".box:first").children().removeClass("fa-folder-open");
        $(this).parent().children(".box:first").children().addClass("fa-folder");
      }
    } else {
      $(this).children("span.badge").addClass("badge-active");
      $(this).prev().addClass("fa-active-color");
      if ($(this).parent().children("a.collapse-active").children("span.badge-active").length != 0) {
        $(this).parent().children(":first").addClass("fa-active-color");
        $(this).parent().children(".box:first").children().removeClass("fa-folder");
        $(this).parent().children(".box:first").children().addClass("fa-folder-open");
      }
    }
  });
}) (jQuery);
