(function($) {
  $(document).ready(function() {
    // 一覧をドラッグで並び替える処理
    $('.sortable').sortable();
    $('.sortable').disableSelection();
  });
}) (jQuery);
