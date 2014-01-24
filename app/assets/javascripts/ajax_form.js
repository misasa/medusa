(function($) {
  $(document).on("ajax:success", "form.create", success("Succeed to create."));
  $(document).on("ajax:error", "form.create", error);
  $(document).on("ajax:success", "form.update", success("Succeed to update."));
  $(document).on("ajax:error", "form.update", error);
  $(document).on("ajax:success", "form.destroy", success("Succeed to destroy."));
  $(document).on("ajax:error", "form.destroy", error);

  function success(message) {
    return function(event, data, status) {
      $.notification.success(message);
    };
  }

  function error(event, data, status) {
    if(data.status === 422 && data.responseJSON !== undefined) {
      $.notification.errorMessages(data.responseJSON.errors);
    }
  }
}) (jQuery);
