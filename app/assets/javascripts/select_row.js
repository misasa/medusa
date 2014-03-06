(function($) {
  $(document).on("click", "input.select-row-all", function() {
    $("input.select-row").prop("checked", $(this).prop("checked"));
  });
}) (jQuery);
