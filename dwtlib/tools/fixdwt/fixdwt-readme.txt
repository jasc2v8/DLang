FixDWT Instructions

Clone DWT from GitHub into the dwtlib/dwt folder

    Git clone --recursive https://github.com/d-widget-toolkit/dwt
    
Fix the source code errors that generate warnings

    cd /dwtlib/tools/fixdwt
    $ rdmd fixdwt.d

Push to GitHub dwtlib

Tag with an update Release Version

The update will be detected on the DUB package repository

Update your DUB packages

    $ dub remove dwtlib
    $ dub fetch dwtlib

Build the static libs on your PC

    cd /dub-packages/dwtlib-3.0.0/dwtlib
    $ rdmd build_dwtlib.d