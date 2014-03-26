(function($) {

  var input;

  function determine() {
    $(input).val($(this).data("id"));
    $("#search-modal").modal("hide");
    return false;
  }

  $(document).on("click.bs.modal.data-api", "[data-toggle='modal']", function() {
    if($(this).data("target") === "#search-modal") {
      input = $(this).data("input");
    }
  });

  $(document).on("ajax:success", "#search-modal", function(event, data, status) {
    $(this).find("div.modal-content").html(data);
  });

  $(document).on("loaded.bs.modal", "#search-modal", function() {
    $(this).on("click", ".determine", determine);
  });

  $(document).on("hidden.bs.modal", "#search-modal", function() {
    $(this).removeData("bs.modal");
  });

  $(document).on("hidden.bs.modal", "#show-modal", function() {
    $(this).removeData("bs.modal");
  });

}) (jQuery);
