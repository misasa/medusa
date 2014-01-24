(function($) {
  $.notification = {
    success: function(message) {
      notify("alert-success", "<span class='glyphicon glyphicon-ok-circle'></span> Success", message);
    },
    warning: function(message) {
      notify("alert-warning", "<span class='glyphicon glyphicon-exclamation-sign'></span> Warning", message);
    },
    error: function(message) {
      notify("alert-danger", "<span class='glyphicon glyphicon-remove-circle'></span> Error", message);
    },
    errorMessages: function(errors) {
      var $dl = $("<dl>");
      $dl.addClass("dl-horizontal");
      $.each(errors, function(key, message) {
        $dl.append("<dt>" + key + "</dt><dd>" + message + "</dd>");
      });
      $.notification.error($dl);
    }
  };

  function notify(alertClass, title, message) {
    var $modal = $("#notification-modal");
    $modal.find("div.modal-header").removeClass("alert-success alert-warning alert-danger").addClass(alertClass);
    $("#notification-modal-label").html(title);
    $modal.find("div.modal-body").html(message);
    $modal.modal();
  }
}) (jQuery);
