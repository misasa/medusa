(function($) {
  $(document).on('change', ':file.browse', function(){
    var input = $(this),
    numFiles = input.get(0).files ? input.get(0).files.length : 1,
    label = input.val().replace(/\\/g,'/').replace(/.*\//,'');
    //input.parent().parent().next('span.input-group-addon').text(label);
    input.closest('.btn').contents().first()[0].textContent = label;
  });
})(jQuery);
