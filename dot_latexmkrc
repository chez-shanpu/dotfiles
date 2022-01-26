#!/usr/bin/env perl
$latex            = 'platex -synctex=1 -halt-on-error';
$bibtex           = 'pbibtex';
$biber            = 'biber --bblencoding=utf8 -u -U --output_safechars';
$dvipdf           = 'dvipdfmx %O -o %D %S';
$makeindex        = 'mendex %O -o %D %S';
$max_repeat       = 5;
$pdf_mode         = 3;
$pvc_view_file_via_temporary = 0;
$platform = "$^O";
if ($platform eq "darwin") {
    $pdf_previewer = "open -ga /Applications/Skim.app";
} elsif ($platform eq "linux") {
    $pdf_previewer = 'start evince %O %S'
} 
