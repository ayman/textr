# Textr Plugin for Lightroom #

Recognize text in photos using the Google Cloud Vision API and
suggests tags for the photos.

## About

This is an experiment right now.  You supply your API key for Google
Cloud Services and you can select a photo and query Google's API for
what text might be in the photo.  Currently it displays a dialog box
with the text.  Eventually, I'd like it to tag or add EXIF data with
the text (to make it searchable).

This came about as I was listening to
the [PetaPixel Podcast #57][PPP57] and someone had a question about an
automated way to tag race bib numbers in Lightroom.  Lensshark said it
wasn't something he heard of.  I thought it shouldn't be that hard to
whip up in today's age...and here we are.

[PPP57]: https://petapixel.com/2016/03/20/ep-57-strobist-david-hobby-sticks-consumers/

There are a few settings for the plugin which you'll have to
tune. I'll get to those later

## How to use this plugin

### Install Plugin

### How to get an API key for Google Cloud Services

It's not easy...as of the time I wrote this plugin, this is basically
what you want to do.

### Settings

### Running the plugin

The Textr stores a single custom metadata string that is searchable
but won't clutter your existing metadata or keywords.  Text
recognition can be kinda noisy, so I didn't want to mess up any nice
categorization people may have.  Remember you can **undo** this task
when it completes too.

## Does this help your photo buisness? ##

Please donate to [100Cameras][100Cameras]; they teach youth in
marginalized communities how to express themselves through
photography, interact with their environment, and become agents of
change. This plugin is free and under a nice MIT License. Google gives
you some queries for free, then you have to pay them for more.  If you
like this plugin (especially if this helps your business out)...send a
donation to this nice non-profit (pay it forward yo).  I'm not going
to limit or cripple the plugin.  Just if you like it, send a
donation. :-) Sorry to say, Google will continue to charge you beyond
their free query limit.

[100Cameras]: http://100cameras.org "100 Cameras"
