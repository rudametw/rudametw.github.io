#!/usr/bin/env python3
"""Insert the current ESIR course ahead of the Lille-era ones on the teaching page.

Filter: Markdown in (stdin) -> Markdown out. Argument: the author-owned fragment
scripts/fragments/teaching-esir.md. Adds a sidebar entry and a section before
the first Lille section; the pills on the Lille titles are already in place, so
the ESIR title is not tagged.
"""
import io, sys
page = sys.stdin.read()
esir = io.open(sys.argv[1], encoding="utf-8").read()
page = page.replace('<li class="active"><a href="#topOfPage">',
                    '<li><a href="#AL">[ESIR SI] Architectures Logicielles</a></li>\n<li><a href="#topOfPage">', 1)
page = page.replace('<div id="Git" ', esir.rstrip() + '\n\n<div id="Git" ', 1)
sys.stdout.write(page)
