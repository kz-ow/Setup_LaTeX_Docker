if ( defined($ENV{'DISABLE_HOT_RELOAD'}) && $ENV{'DISABLE_HOT_RELOAD'} eq '1' ) {
    $preview_continuous_mode = 0;
} else {
    $preview_continuous_mode = 1;
}

$max_repeat = 5;

$halt_on_error = 0;

$clean_ext = 'aux,bbl,blg,idx,ind,lof,lot,out,fdb_latexmk,fls,synctex.gz';

@default_files = ('main.tex');

if ( defined($ENV{'LANG_TYPE'}) && $ENV{'LANG_TYPE'} eq 'japanese' ) {
    $latex = 'uplatex %O -kanji=utf8 -no-guess-input-enc -synctex=1 -interaction=nonstopmode %S';
    $bibtex = 'upbibtex %O %B';
    $makeindex = 'upmendex %O -o %D %S';
    
    # PDF作成は、dvipdfmx を使用
    $dvipdf = 'dvipdfmx %O -o %D %S';
    $pdf_mode = 3;  # 3: uplatexで生成された .dvi を dvi→PDF変換
} else {
    $pdflatex = 'pdflatex %O -synctex=1 -interaction=nonstopmode %S';
    $bibtex = 'bibtex %O %B';
    
    # PDF作成は、直接 pdflatex で実行
    $pdf_mode = 1;  # 1: pdflatex によるPDF出力
}

$pdf_previewer = "start %S";
