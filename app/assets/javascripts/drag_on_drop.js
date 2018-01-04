(function($) {
  $(document).on("dragstart", "span.global-id", drag_id);
  $(document).on("drop", "input", drop_id);
  $(document).on("dropend", "input", dropend);

  function drag_id(event) {
    e = event.originalEvent;
    e.dataTransfer.setData("text", $(event.target).text());
  }

  function drop_id(event) {
    e = event.originalEvent;
    $(this).val(e.dataTransfer.getData("text"));
    e.preventDefault();
  }

  function dropend(event) {
    e = event.originalEvent;
    e.preventDefault();
  }
}) (jQuery);
