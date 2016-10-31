(function($) {
  //ネストフォーム初期表示処理
  $("div.children").ready(function(){
    children_disabled_check();
  });

  //ネストフォームのボタン活性チェック
  function children_disabled_check() {
    if ($("div.child").length <= 1) {
      $("a.remove-child").attr("disabled", true);
    } else {
      $("a.remove-child").attr("disabled", false);
    }
  }

  //ネストフォーム削除
  $(document).on("click", "a.remove-child", function() {
    if ($("div.child").length > 1) {
      $(this).parents("div.child").remove();
    }
    children_disabled_check();
  });

  //ネストフォーム追加
  $(document).on("click", "a.add-child", function() {
    $element = $("div.child").last().clone();
    $element.find("div.alert").remove();
    $element.find(".input-sm").each(function(){
      $input = $(this);
      var val = +$input.prop("name").match(/\[(\d*)\]/)[1] + 1;
      var id = $input.prop("id").replace(/_\d*_/, "_" + val + "_");
      var name = $input.prop("name").replace(/\[\d*\]/, "[" + val + "]");
      $input.prop("id", id);
      $input.prop("name", name);
      $input.val("");
    });
    $("div.child").last().after($element);
    children_disabled_check();
  });
}) (jQuery);
