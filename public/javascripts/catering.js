function catererBookmarkToggle( caterer_id, user_id, action )
{
    var bookmark_url = "/bookmark_caterer/" + caterer_id + "/user/" + user_id + "/" + action;

    $.ajax(
            {
                url: bookmark_url,
                dataType: 'json',
                success: function( data )
                {
                    if ( data[0].success < 1 )
                    {
                        showError( data[0].message );
                        return false;
                    }
                    if ( action == -1 )
                    {
                        $('#bookmark_caterer').html( '<a href="#" onClick="catererBookmarkToggle( '
                                                        + caterer_id
                                                        + ', '
                                                        + user_id
                                                        + ', 1 )"><i class="fa fa-bookmark"></i> Bookmark Caterer</a>' );
                    }
                    else
                    {
                        $('#bookmark_caterer').html( '<a href="#" onClick="catererBookmarkToggle( '
                                                        + caterer_id
                                                        + ', '
                                                        + user_id
                                                        + ', -1 )"><i class="fa fa-bookmark-o"></i> Unbookmark Caterer</a>' );
                    }
                    showSuccess( data[0].message )
                },
                error: function()
                {
                    showError( 'An error occurred, and we could not bookmark this Caterer. Please try again later.' )
                },
                type: 'GET'
            }
    );
}

$( function()
    {
        $(".caterer_review_rating").starRating(
            {
                totalStars: 5,
                starSize: 30,
                useGradient: true,
                strokeWidth: 2,
                strokeColor: 'black',
                disableAfterRate: false,
                callback: function( currentRating, $el )
                {
                    document.getElementById("caterer_rating_value").value = currentRating;
                },
            }
        );
    }
);

