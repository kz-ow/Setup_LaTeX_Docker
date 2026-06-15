use Cwd 'getcwd';

# ワークスペースルートを確定（.latexmkrc のある場所を上向きに探索）
my $root;
if ( defined($ENV{'WORKSPACE_ROOT'}) && $ENV{'WORKSPACE_ROOT'} ne '' ) {
    $root = $ENV{'WORKSPACE_ROOT'};
} else {
    my $dir = getcwd();
    while ( $dir ne '/' ) {
        if ( -f "$dir/.latexmkrc" ) { $root = $dir; last; }
        $dir =~ s|/[^/]+$||;
    }
    $root //= getcwd();
}

# papers/<name>/latexmk.conf を読んでエンジン設定を取得
# （.latexmkrc は papers/<name>/ から呼ばれることを前提とする）
my $paper_dir = getcwd();
my $conf_file = "$paper_dir/latexmk.conf";

die "latexmk.conf not found in $paper_dir\nRun from inside a papers/<name>/ directory.\n"
    unless -f $conf_file;

my %conf;
open(my $fh, '<', $conf_file) or die "Cannot read $conf_file: $!";
while (<$fh>) {
    chomp; s/#.*//; s/^\s+|\s+$//g;
    next unless /^(\w+)\s*=\s*(.+)$/;
    $conf{$1} = $2;
}
close($fh);

# TEXINPUTS / BSTINPUTS に format/ 以下を追加（cls/sty の自動解決）
$ENV{'TEXINPUTS'} = "$root/format//:$root/format/**//:" . ($ENV{'TEXINPUTS'} // '');
$ENV{'BSTINPUTS'} = "$root/format//:$root/format/**//:" . ($ENV{'BSTINPUTS'} // '');

my $texinputs_env = "TEXINPUTS=\"$ENV{'TEXINPUTS'}\"";

# エンジンコマンドを設定
my $cmd  = $conf{latex_cmd}  // 'uplatex';
my $opts = $conf{latex_opts} // '-interaction=nonstopmode';

if ( $cmd eq 'lualatex' ) {
    $lualatex = "$texinputs_env lualatex %O $opts %S";
    $biber    = 'biber %O %B';
    $pdf_mode = 4;
} elsif ( $cmd eq 'pdflatex' ) {
    $pdflatex = "$texinputs_env pdflatex %O $opts %S";
    $biber    = 'biber %O %B';
    $pdf_mode = 5;
} else {
    # platex / uplatex（DVI経由）
    $latex  = "$texinputs_env $cmd %O $opts %S";
    $dvipdf = 'dvipdfmx %O -o %D %S';
    if ( ($conf{bibtex_cmd} // '') eq 'biber' ) {
        $biber  = 'biber --bblencoding=utf8 -u -U --output_safechars %O %B';
    } else {
        $bibtex = 'upbibtex %O %B';
        $biber  = 'biber --bblencoding=utf8 -u -U --output_safechars %O %B';
        # /etc/LatexMk が biber を有効にしている場合に備えて明示的に upbibtex を使う
        $bibtex_use = 1;
    }
    $pdf_mode = 3;
}

$max_repeat    = 5;
$halt_on_error = 0;
$clean_ext     = 'aux,bbl,blg,idx,ind,lof,lot,out,toc,fdb_latexmk,fls,synctex.gz,nav,snm';

@default_files = ('main.tex');

$preview_continuous_mode = 0;
