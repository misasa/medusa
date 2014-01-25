(function($) {
  $(document).on("ajax:success", "div.tool-selector", function(event, data, status) {
    $("div.tool-content").html(data);
  });
  $(document).on("ajax:error", "div.tool-selector", function(event, data, status) {
    $.notification.error("Fatal error.");
  });
  $(document).ready(function() {
    $("div.tool-selector").find(".activate").click();
  });
}) (jQuery);
