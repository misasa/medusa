(function($) {
  var changeDisplay = function() {
    var div_id = $(this).attr('href');
    $("div.display-type").children().addClass("hidden");
    $(div_id).removeClass("hidden");
  };

  $(document).on("click", ".radio-button-group", changeDisplay);
}) (jQuery);