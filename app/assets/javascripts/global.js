/* we are progressive enhancement guru gods */
/* Thankyou stack overflow ;) */
// http://stackoverflow.com/questions/436710/element-appendchild-chokes-in-ie

var css = document.createElement('style');
css.setAttribute('type', 'text/css');
var cssText = '.noscript { display: none; }';
if(css.styleSheet) { // IE does it this way
        css.styleSheet.cssText = cssText;
} else { // everyone else does it this way
        css.appendChild(document.createTextNode(cssText));
}
$('html head').get(0).appendChild(css);

// http://unscriptable.com/index.php/2009/03/20/debouncing-javascript-methods/
function debounce(func, threshold, execAsap) {
  var timeout;
  return function debounced() {
    var obj = this, args = arguments;
    var delayed = function() {
      if (!execAsap) {
        func.apply(obj, args);
      }
      timeout = null;
    };
    if (timeout) {
      clearTimeout(timeout);
    } else if (execAsap) {
      func.apply(obj, args);
    }

    timeout = setTimeout(delayed, threshold || 100);
  };
}

$(document).ready(function() {
  $('.single-checkbox-form').livequery(single_checkbox_form);
  // AJAXly call feedback?date=DATESTRING when date field changes, populate help box with result
  $(".deadline_text").keyup(debounce(deadline_changed, 250));
  $("#response_comment").keyup(debounce(response_preview, 250));
  $("a[class~=facebox]").facebox();

  // The browser often fills out forms at load time
  if($(".deadline_text").get(0)) {
    $(".deadline_text").keyup();
  }
  if($("#response_comment").get(0)) {
    response_preview.call($("#response_comment").get(0));
  }

  $('#add-another-prediction').click(function(event) {
    event.preventDefault();
    var oldIndex = parseInt($('.prediction-group-prediction').last().data('index'));
    var newIndex = oldIndex + 1;
    $('.prediction-group-prediction:last').clone().appendTo('.prediction-group-predictions');
    $('.prediction-group-prediction:last').data('index', newIndex);

    $('.prediction-group-prediction:last h2').text("Prediction " + (newIndex + 1));

    $('.prediction-group-prediction:last #prediction_group_prediction_' + oldIndex + '_id').attr('name', 'prediction_group[prediction_' + newIndex + '_id]');
    $('.prediction-group-prediction:last #prediction_group_prediction_' + oldIndex + '_id').val('');
    $('.prediction-group-prediction:last #prediction_group_prediction_' + oldIndex + '_id').attr('id', 'prediction_group_prediction_' + newIndex + '_id');

    $('.prediction-group-prediction:last label[for="prediction_group_prediction_' + oldIndex + '_description"]').attr('for', 'prediction_group_prediction_' + newIndex + '_description');
    $('.prediction-group-prediction:last #prediction_group_prediction_' + oldIndex + '_description').attr('name', 'prediction_group[prediction_' + newIndex + '_description]');
    $('.prediction-group-prediction:last #prediction_group_prediction_' + oldIndex + '_description').val('');
    $('.prediction-group-prediction:last #prediction_group_prediction_' + oldIndex + '_description').attr('id', 'prediction_group_prediction_' + newIndex + '_description');

    $('.prediction-group-prediction:last label[for="prediction_group_prediction_' + oldIndex + '_initial_confidence"]').attr('for', 'prediction_group_prediction_' + newIndex + '_initial_confidence');
    $('.prediction-group-prediction:last #prediction_group_prediction_' + oldIndex + '_initial_confidence').attr('name', 'prediction_group[prediction_' + newIndex + '_initial_confidence]');
    $('.prediction-group-prediction:last #prediction_group_prediction_' + oldIndex + '_initial_confidence').val('');
    $('.prediction-group-prediction:last #prediction_group_prediction_' + oldIndex + '_initial_confidence').attr('id', 'prediction_group_prediction_' + newIndex + '_initial_confidence');
  });

  $('#prediction_group_description').keyup(function(event) {
    if (event.currentTarget.value.length === 0) {
      $('.prediction-group-prediction-description label').text("What do you think will (or won't) happen?");
    } else {
      $('.prediction-group-prediction-description label').text(event.currentTarget.value + '...');
    }
  });

  if($("#prediction_group_description").get(0)) {
    $('#prediction_group_description').keyup();
  }
});

// Focus first input field on page
// 1. first empty element
// 2. first element with an error if all full
// 3. first element if all full and no errors
$(document).ready(function() {
  var input = $('form .input[value=\'\']:first');
  if ( input.size() === 0) {
    input = $('.error .input:first');
    if ( input.size() === 0) {
      input = $('input[type=text]:first');
    }
  }
  input.focus();
});

function single_checkbox_form() {
  $(this).find('input[type=checkbox]').click(function() {
    form_container = $(this.form).parent();
    $(form_container).find('p.note').text('Saving…');
    $(this.form).ajaxSubmit({
      success: function(content) {
        form_container.html(content);
      },
      error: function(xhr) { form_container.html("There was an error."); }
    });
  });
}

function deadline_changed(event) {
  var that = this;
  var prefix = event.currentTarget.id.replace('_deadline_text', '');
  if (this.value === '') {
    $('#' + prefix + '_deadline_preview').text('');
  }
  else {
    var requestForValue = this.value;
    $('#' + prefix + '_deadline_text_preview').text('Waiting…');
    $.ajax({
      url: '/feedback',
      type: 'GET',
      data: 'date=' + encodeURIComponent(this.value),
      dataType: 'text',
      timeout: 5000,
      error: function() {
        if(that.value != requestForValue) {
          // Ignore the server response because the user changed the text
          // box during the request.  That's okay though, because there's
          // already a request for the new value.
          return;
        }
        $('#' + prefix + '_deadline_text_preview').text("I can't work out a time from that, sorry");
      },
      success: function(text) {
        if(that.value != requestForValue) {
          return;
        }
        $('#' + prefix + '_deadline_text_preview').text(text);
      }
    });
  }
}

function response_preview(event) {
  var that = this;
  if (this.value === '') {
    $('#response_comment_preview').text('');
  }
  else {
    var requestForValue = this.value;
    $.ajax({
      url: '/responses/preview',
      type: 'GET',
      data: 'response[comment]=' + encodeURIComponent(this.value),
      dataType: 'text',
      timeout: 5000,
      success: function(text) {
        if(that.value != requestForValue) {
          return;
        }
        $('#response_comment_preview').html(text);
      }
    });
  }
}
