# Collection search controls prototype (#75)

Run with `godot --path . --script prototypes/collection_search_controls/harness.gd -- --out-dir=/tmp/collection-search-controls`, then `python3 prototypes/collection_search_controls/verify.py /tmp/collection-search-controls`.

This prototype keeps the accepted Collection window artwork and places native Godot controls over the Search filters body. It uses `PixelMplus12-Regular.ttf` as a measured substitute; it does not claim an exact font match. The result records are explicitly labelled fixtures. Production data, save persistence and frozen interface/test changes remain in #79 and #80.
