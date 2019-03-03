var $body   = $(document.body);
var navHeight = $('.navbar').outerHeight(true) + 10;

$('#sidebar').affix({
      offset: {
        top: 0,
        bottom: 400
      }
});


$body.scrollspy({
	target: '#leftCol',
	offset: navHeight
});
