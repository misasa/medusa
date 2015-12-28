(function($) {
  $(document).on("ajax:success", "form.create", successFixedMessage("Succeed to create."));
  $(document).on("ajax:error", "form.create", error);
  $(document).on("ajax:success", "form.update", successFixedMessage("Succeed to update."));
  $(document).on("ajax:error", "form.update", error);
  $(document).on("ajax:success", "form.destroy", successFixedMessage("Succeed to destroy."));
  $(document).on("ajax:error", "form.destroy", error);
  $(document).on("ajax:success", "form.custom-message", successCustomMessage());
  $(document).on("ajax:error", "form.custom-message", error);
  $(document).on("ajax:success", "form.dinamic-message", successDinamicMessage());
  $(document).on("ajax:error", "form.dinamic-message", error);

  function successFixedMessage(message) {
    return function(event, data, status) {
      success.call(this, message);
    }
  }

  function successCustomMessage() {
    return function(event, data, status) {
      success.call(this, $(this).data("message"));
    }
  }

  function successDinamicMessage() {
    return function(event, data, status) {
      success.call(this, data.message);
    }
  }

  function success(message) {
    var self = this, $modal = $.notification.modalObject(), succeed = function(e) {
      $(self).trigger("succeed.ajaxForm");
      $modal.off("hidden.bs.modal", succeed);
    };

    $modal.on("hidden.bs.modal", succeed);
    $.notification.success(message);
  }

  function error(event, data, status) {
    if(data.status === 422 && data.responseJSON !== undefined) {
      $.notification.errorMessages(data.responseJSON.errors);
    }
  }
}) (jQuery);
