(function($) {
  //コンテンツ表示
  $(document).on("click", "a.show_switching_content_open", function() {
    $(".show_switching_content").show();
    $(".show_switching_content_close").show();
    $(".show_switching_content_open").hide();
  });

  //コンテンツ非表示
  $(document).on("click", "a.show_switching_content_close", function() {
    $(".show_switching_content").hide();
    $(".show_switching_content_open").show();
    $(".show_switching_content_close").hide();
  });
}) (jQuery);
