(function($) {
  $(document).on("ajax:success", "form.create", success("Succeed to create."));
  $(document).on("ajax:error", "form.create", error);
  $(document).on("ajax:success", "form.update", success("Succeed to update."));
  $(document).on("ajax:error", "form.update", error);
  $(document).on("ajax:success", "form.destroy", success("Succeed to destroy."));
  $(document).on("ajax:error", "form.destroy", error);

  function success(message) {
    return function(event, data, status) {
      var msg, self = this, $modal = $.notification.modalObject(), succeed = function(e) {
        $(self).trigger("succeed.ajaxForm");
        $modal.off("hidden.bs.modal", succeed);
      };

      $modal.on("hidden.bs.modal", succeed);
      if (data.message) {
        msg = data.message;
      } else if ($(this).data("message")) {
        msg = $(this).data("message");
      } else {
        msg = message;
      }
      $.notification.success(msg);
    };
  }

  function error(event, data, status) {
    if(data.status === 422 && data.responseJSON !== undefined) {
      $.notification.errorMessages(data.responseJSON.errors);
    }
  }
}) (jQuery);
