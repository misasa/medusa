(function($) {
  $(document).on("click", "a.collapse-active", function(a) {
    if ($(this).hasClass("collapsed")) {
      $(this).parent().children("a.collapse-active").children("span.badge").removeClass("badge-active")
    } else {
      $(this).parent().children("a.collapse-active").children("span.badge").addClass("badge-active")
    }
  });
}) (jQuery);
