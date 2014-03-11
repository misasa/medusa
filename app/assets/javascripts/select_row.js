(function($) {
  $(document).on("click", "input.select-row-all", function() {
    $(this).closest("table").find("input.select-row").prop("checked", $(this).prop("checked"));
  });
}) (jQuery);
