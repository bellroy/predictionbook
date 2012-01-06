/* we are progressive enhancement guru gods */
/* Thankyou stack overflow ;) */
// http://stackoverflow.com/questions/436710/element-appendchild-chokes-in-ie
var css = document.createElement('style')
css.setAttribute('type', 'text/css')
var cssText = '.noscript { display: none; }';
if(css.styleSheet) { // IE does it this way
        css.styleSheet.cssText = cssText
} else { // everyone else does it this way
        css.appendChild(document.createTextNode(cssText));
}
$('html head').get(0).appendChild(css)

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
    }
    if (timeout) {
      clearTimeout(timeout);
    } else if (execAsap) {
      func.apply(obj, args);
    }

    timeout = setTimeout(delayed, threshold || 100);
  };
}

$(document).ready(function() {
  $('.single-checkbox-form').livequery(single_checkbox_form)
  // AJAXly call feedback?date=DATESTRING when date field changes, populate help box with result
  $("#prediction_deadline_text").keyup(debounce(deadline_changed, 250))
  $("#response_comment").keyup(debounce(response_preview, 250))
  $("a[class~=facebox]").facebox()

  // The browser often fills out forms at load time
  if($("#prediction_deadline_text").get(0)) {
    deadline_changed.call($("#prediction_deadline_text").get(0));
  }
  if($("#response_comment").get(0)) {
    response_preview.call($("#response_comment").get(0));
  }
})

// Focus first input field on page
// 1. first empty element
// 2. first element with an error if all full
// 3. first element if all full and no errors
$(document).ready(function() {
  var input = $('form .input[value=]:first');
  if ( input.size() == 0) {
    input = $('.error .input:first');
    if ( input.size() == 0) {
      input = $('input[type=text]:first');
    }
  }
  input.focus();
})

function single_checkbox_form() {  
  $(this).find('input[type=checkbox]').click(function() {
    form_container = $(this.form).parent()
    $(form_container).find('p.note').text('Saving…')
    $(this.form).ajaxSubmit({
      success: function(content) {
        form_container.html(content)
      },
      error: function(xhr) { form_container.html("There was an error.") }
    })
  });
}

function deadline_changed(event) {
  var that = this;
  if (this.value == '') {
    $('#prediction_deadline_preview').text('')
  }
  else {
    var requestForValue = this.value;
    $('#prediction_deadline_text_preview').text('Waiting…')
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
        $('#prediction_deadline_text_preview').text("I can't work out a time from that, sorry")
      },
      success: function(text) {
        if(that.value != requestForValue) {
          return;
        }
        $('#prediction_deadline_text_preview').text(text)
      }
    })
  }
}

function response_preview(event) {
  var that = this;
  if (this.value == '') {
    $('#response_comment_preview').text('')
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
        $('#response_comment_preview').html(text)
      }
    });
  }
}
