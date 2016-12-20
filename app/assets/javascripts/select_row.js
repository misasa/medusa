(function($) {
  $(document).on("click", "input.select-row-all", function() {
    $(document).find("input.select-row").prop("checked", $(this).prop("checked"));
  });
}) (jQuery);
