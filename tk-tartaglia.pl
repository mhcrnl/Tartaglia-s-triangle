#!/usr/bin/perl
use strict;
use warnings;
use Math::BigInt;
use POSIX;
use Tk;
use Tk::Pane;
################################################################################
#   SOME GLOBAL DECLARATION
################################################################################
my @tartaglia ;     #AoA used as CACHE
my @tkcache;        #AoA used as CACHE for Tk buttons in the triangles
my $tart_win;       # triangle window
my $ow;             #output window
my $out;            #output var for out_win
my $row_num = 15;   #default row noumber for the triangle
my $dot_after = 2;  # default: instead of '24' it prints '..'
my $debug = 0;      # no debug infos in the output window
my @posible_colors = qw(red royalblue  orange green yellow violet blue pink purple );
my %next_col = (red=>'royalblue',royalblue=>'orange',orange=>'green',green=>'yellow',yellow=>'violet',
                violet=>'blue',blue=>'pink',pink=>'purple',purple=>'red');
my @colorized;      # array of Tk button yet colorized
my $size_tile = 8;  # size and boldness of various fonts
my $bold_tile = 0;
my $size_help = 13;
my $bold_help = 1;
my $size_out = 13;
my $bold_out = 1 ;

use subs 'tar_print';
################################################################################
#   MAIN WINDOW CREATION
################################################################################
my $mw = MainWindow->new ();
    $mw->Icon(-image => $mw->Pixmap(-data => &tart_icon));
    $mw->geometry("688x861+0+0"); #->geometry("300x450+0+0"); 320+0
    $mw->title(" command ");
    #$mw->optionAdd('*font', 'Courier 10');
    $mw->optionAdd('*Label.font', 'Courier 10');
    $mw->optionAdd( '*Entry.background',   'lavender' );
    $mw->optionAdd( '*Entry.font',   'Courier 12 bold'  );
    my $scrolled_top = $mw->Scrolled('Frame',
                      -background=>'white',
                      -scrollbars => 'osoe',)->pack(-expand => 1, -fill => 'both');
                      
my $fr0 = $scrolled_top->Frame(-borderwidth => 2, -relief => 'groove')->pack(-side=>'top',-pady=>10);
    $fr0->Label(-text => "-Tartaglia's triangle properties-" )->pack(-pady=>10);

my  $fr1 = $scrolled_top->Frame(-borderwidth => 2, -relief => 'groove')->pack(-side=>'top',-anchor=>'w',-pady=>5); #,-fill=>'x'
    $fr1->Label(-text => "Rows in the triangle: from 0 to ")->pack(-side => 'left');#,-expand => 1, -fill=>'x'
    $fr1->Entry(-width => 3,-borderwidth => 4, -textvariable => \$row_num)->pack(-side => 'left', -expand => 1,-padx=>5); #-side => 'left', -expand => 1, -fill=>'x'
    $fr1->Label(-text => "Tiles font size")->pack(-side => 'left',-expand => 1);
    $fr1->Entry(-width => 3,-borderwidth => 4, -textvariable => \$size_tile)->pack(-side => 'left', -expand => 1,-padx=>5);
    $fr1->Label(-text => "bold")->pack(-side => 'left',-expand => 1);
    $fr1->Checkbutton( -variable =>\$bold_tile )->pack(-side => 'left', -expand => 1);
    $fr1->Button(-padx=> 5,-text => "introduction",-borderwidth => 4, -command => sub{&help(\&help_intro)})->pack(-side => 'right',-expand => 1,-padx=>5);#128

my $fr2 = $scrolled_top->Frame(-borderwidth => 2, -relief => 'groove')->pack(-side=>'top',-anchor=>'w',-pady=>5);
  $fr2->Label(-text => "Numbers as dot if ")->pack(-side => 'left',-expand => 1);
  $fr2->Radiobutton(-text => "1",-variable => \$dot_after, -value=>'1')->pack(-side => 'left',-expand => 1);
  $fr2->Radiobutton(-text => "2",-variable => \$dot_after, -value=>'2')->pack(-side => 'left',-expand => 1);
  $fr2->Radiobutton(-text => "3",-variable => \$dot_after, -value=>'3')->pack(-side => 'left',-expand => 1);
  $fr2->Radiobutton(-text => "4",-variable => \$dot_after, -value=>'4')->pack(-side => 'left',-expand => 1);
  $fr2->Radiobutton(-text => "never",-variable => \$dot_after, -value=>'9999')->pack(-side => 'left',-expand => 1);
  $fr2->Label(-text => " digits.  Print debug information")->pack(-side => 'left',-expand => 1);
  $fr2->Checkbutton( -variable =>\$debug,-command => sub { tar_print "Debug info ".($debug ? 'enabled' : 'disabled')."\n" })->pack();

my $fr2a = $scrolled_top->Frame(-borderwidth => 2, -relief => 'groove')->pack(-side=>'top',-anchor=>'w',-pady=>5);
   $fr2a->Label(-text => "Size of help texts")->pack(-side => 'left',-expand => 1);
   $fr2a->Entry(-width => 3,-borderwidth => 4, -textvariable => \$size_help)->pack(-side => 'left', -expand => 1,-padx=>5); #-side => 'left', -expand => 1, -fill=>'x'
   $fr2a->Label(-text => "bold")->pack(-side => 'left',-expand => 1);
   $fr2a->Checkbutton( -variable =>\$bold_help )->pack(-side => 'left', -expand => 1);
   $fr2a->Label(-text => "                 Size of output ")->pack(-side => 'left',-expand => 1);
   $fr2a->Entry(-width => 3,-borderwidth => 4, -textvariable => \$size_out)->pack(-side => 'left', -expand => 1,-padx=>5); #-side => 'left', -expand => 1, -fill=>'x'
   $fr2a->Label(-text => "bold")->pack(-side => 'left',-expand => 1);
   $fr2a->Checkbutton( -variable =>\$bold_out )->pack(-side => 'left', -expand => 1);

my $fr3 = $scrolled_top->Frame(-background => 'white')->pack(-side=>'top',-pady=>5);
  $fr3->Button(-padx=> 20,-text => "draw triangle",-borderwidth => 4, -command => \&draw_triangle)->pack(-side => 'left',-expand => 1,-padx=>5);
  $fr3->Button(-padx=> 20,-text => "delete triangle",-borderwidth => 4, -command => \&destroy_tri )->pack(-side => 'left',-expand => 1,-padx=>5);

################################################################################
#   EXPERIMENTS CREATION FRAME
################################################################################
my $fr4 = $scrolled_top->Frame(-borderwidth => 2, -relief => 'groove')->pack(-side=>'top',-pady=>10);
    $fr4->Label(-text => "-Tartaglia's triangle experiments-" )->pack(-pady=>10);

##### BINOMIAL EXPANSION
my $input_bin;
my $color_bin = 'red';
my $title_bin = "Binomial Expansion (a+b)^";
create_experiment (\$input_bin, \$color_bin, $title_bin, \&help_bin, \sub { $input_bin=~s/\s+//g;
                                                                &given_coord($color_bin,$input_bin." 0-$input_bin");
                                                                &bin_exp($input_bin)});
##### POWERS OF TWO
my $input_p2;
my $color_p2 = 'red';
my $title_p2 = "Powers of 2            2^";
create_experiment (\$input_p2, \$color_p2, $title_p2, \&help_pow2, \sub {power_of_two($input_p2,$color_p2)} );

##### POWERS OF ELEVEN
my $input_p11;
my $color_p11 = 'red';
my $title_p11 = "Powers of 11          11^";
create_experiment (\$input_p11, \$color_p11, $title_p11,\&help_pow11,\sub {power_of_eleven($input_p11,$color_p11)} );

##### FIBONACCI
my $input_fib;
my $color_fib = 'red';
my $title_fib = "Fibonacci         max row";
create_experiment (\$input_fib, \$color_fib, $title_fib,\&help_fib,\sub {fibonacci($input_fib,$color_fib)} );

##### PRIME NUMBERS
my $input_pri;
my $color_pri = 'red';
my $title_pri = "Prime numbers     max row";
create_experiment (\$input_pri, \$color_pri, $title_pri,\&help_pri,\sub {is_prime($input_pri,$color_pri)} );

### POLYGONAL NUMBERS
my $input_tri;
my $color_tri = 'red';
my $title_tri = "Triangular numbers    num";
create_experiment (\$input_tri, \$color_tri, $title_tri, \&help_tri, \sub {&triangulars($input_tri, $color_tri)});

#### COORDINATES
my $input_coord;
my $color_coord = 'red';
my $title_coord = "Colorize by coordinates";
create_experiment (\$input_coord, \$color_coord, $title_coord,\&help_bycoord, \sub {&given_coord($color_coord ,$input_coord)});

### DAVID'S STAR
my $input_star;
my $color_star = 'red';
my $title_star = "David's star   row col";
create_experiment (\$input_star, \$color_star, $title_star, \&help_david, \sub {&david_star($input_star, $color_star)});

### CAPELAN
my $input_cat;
my $color_cat = 'red';
my $title_cat = "Catalan's numbers max row";
create_experiment (\$input_cat, \$color_cat, $title_cat, \&help_cat, \sub {&catalan($input_cat, $color_cat)});

### MERSENNE AND M PRIMES
my $input_mer;
my $color_mer = 'red';
my $title_mer = "Mersenne numbers  max row";
create_experiment (\$input_mer, \$color_mer, $title_mer, \&help_mer, \sub {&mersenne($input_mer, $color_mer)});

### SIERPINSKI
my $input_sie;
my $color_sie = 'red';
my $title_sie = "Sierpinski fractals   num";
create_experiment (\$input_sie, \$color_sie, $title_sie, \&help_sie, \sub {&sierpinski($input_sie, $color_sie)});

### COMBINATIONS
my $input_com;
my $color_com = 'red';
my $title_com = "Combinations      row col";
create_experiment (\$input_com, \$color_com, $title_com, \&help_com, \sub {&combination($input_com, $color_com)});

### EVALUATION
my $input_eval;
my $color_eval = 'red';
my $title_eval = "Colorize by evaluation";
create_experiment (\$input_eval, \$color_eval, $title_eval, \&help_eval, \sub {&col_eval($color_eval ,$input_eval)});

### HOCKEY STICK PATTERN
my $input_hoc;
my $color_hoc = 'red';
my $title_hoc = "Hockey stick      row col";
create_experiment (\$input_hoc, \$color_hoc, $title_hoc, \&help_hockey, \sub {&hockeystick($input_hoc, $color_hoc)});

### PARALLELOGRAM PATTERN
my $input_par;
my $color_par = 'red';
my $title_par = "Parallelogram     row col";
create_experiment (\$input_par, \$color_par, $title_par, \&help_para, \sub {&parallelogram($input_par, $color_par)});

### SUM OF SQUARES
my $input_ssq;
my $color_ssq = 'red';
my $title_ssq = "Sum of squares in the row";
create_experiment (\$input_ssq, \$color_ssq, $title_ssq, \&help_squa, \sub {&sum_squares($input_ssq, $color_ssq)});

tar_print "Welcome to Tartaglia's triangle fun offered by Discipulus as found at www.perlmonks.org";
&draw_triangle;

#tar_print "MainWindow geometry: ",$mw->geometry(),"\n";
#    tar_print "Triangle geometry: ",$tart_win->geometry(),"\n";
#    tar_print "output geometry: ",$ow->geometry(),"\n";

MainLoop;
################################################################################
#   EXPERIMENTS SUBROUTINES
################################################################################
sub sum_squares {
    my ($input,$color)=@_;
    if ($input =~ /\s?(\d+)\D/){$input = $1}
    my $col2 = $next_col{$color};
    tar_print "\n\n*** Sum of sqares of row $input\n\n";
    my @row = tartaglia_row($input);
    my $calc = (join ' ** 2 + ',@row).' ** 2 ';
    tar_print "The sumation of squares of $color tiles in ".$input."th row is:\n$calc = ",eval $calc,"\n";
    given_coord($color, "$input 0-".($input + 1));
    my @double = tartaglia_row($input * 2);
    my $central = $double[ (int $#double / 2 )];
    given_coord($col2, ($input * 2)." ".((int $#double / 2 )));
    tar_print "the central element of $input x 2 (".($input * 2).") row is $central\n\n";
}
################################################################################
sub parallelogram {
    my ($input,$color)=@_;
    my ($row,$col)= split ' ',$input;
    # tar_print("Both must be defined") and return unless ($row && $col)
    tar_print "\n\n*** Parallelogram pattern \n\n";
    given_coord ($color, "$row $col");
    my $wanted = ${[tartaglia_row($row)]}[$col];
    my @parallelogram;

    my $col2 = $next_col{$color};
    $col--;
    my $first = $col;
    my $last = $col;
    foreach my $prow (reverse 0..$row-2){
            my @val = tartaglia_row($prow);
            $first = 0 if $first < 0;
            $last = $col if $last > $col;
            $last = $#val if $last > $#val;
            push @parallelogram, @val[$first .. $last];
            given_coord ($col2, "$prow ".$first.'-'.$last);
            $first--;
            $last++;
    }
    my $sum = join ' + ', sort @parallelogram;
    my $res = eval $sum;
    tar_print "$wanted ($color tile) is equal to the sum of $col2 tiles + 1:\n";
    tar_print "$sum = $res\n$res + 1 = ",$res + 1," = $wanted ($color tile)\n";
}
################################################################################
sub hockeystick {
    my ($input,$color)=@_;
    my ($row,$col)= split ' ',$input;
    tar_print "\n\n*** Hockey stick pattern \n\n";
    my $col2 = $next_col{$color};

    given_coord ($col2, "0-".($row-1)." ".($col-1) );
    given_coord ($color, "$row $col");
    my @hockey;
    foreach my $trow ( 0 .. $row-1) {
            my @val = tartaglia_row($trow);
            defined $val[$col-1] ? (push @hockey, $val[$col-1]) : next;
    }
    my $number = ${ [tartaglia_row($row)] }[$col];
    my $sum  =  join ' + ',@hockey;
    tar_print "$number ($color tile) is equal to the sum of $col2 tiles:\n$sum = ".eval $sum."\n";
}
################################################################################
sub triangulars{
    my ($input,$color)=@_;
    if ($input =~ /\s?(\d+)\D/){$input = $1}
    my $col2 = $next_col{$color};
    tar_print "\n\n*** Triangular number $input\n\n";
    given_coord ($col2, "0-$row_num 2");
    given_coord ($color, ($input+2)." 2");
    my @triangulars = map {my $n; my $x = $_; foreach my $i(0..$x) {$n+=$i};$n    } 1..$input+1;
    tar_print "\nThe $input".'th '."triangular number is: $triangulars[-1] ($color tile)\n";
    tar_print "First triangular numbers found ($col2 tiles):\n",(join ' ', @triangulars),"\n\n";
}
################################################################################
sub combination{
    my ($input,$color)=@_;
    my ($row,$col)= split ' ',$input;
    if ($col > $row) {tar_print "Warning column must be lesser or equal to row\n"; return}
    tar_print "\n\n*** Combinations of $col items in a group of $row\n\n";
    my $col2 = $next_col{$color};
    my $col3 = $next_col{$col2};
    my $col4 = $next_col{$col3};
    given_coord ($col2, "$row 0-$row_num");
    given_coord ($col3, "0-$row_num $col");
    given_coord ($col4, ($row + $col - 1)." $col");
    given_coord ($color, "$row $col");
    tar_print "There are ",${[tartaglia_row($row)]}[$col]," ($color tile position $row - $col) different combinations (when the order does not matter) of $col items in group of $row.\n";
    tar_print "There are ",${[tartaglia_row($row + $col - 1)]}[$col],( $col > 1 ? " ($col4 tile)" : '')." different combinations with repetitions of $col items in group of $row.\n\n";
}
################################################################################
sub sierpinski{
    my ($input,$color)=@_;
    if ($input =~ /\s?(\d+)\D/){$input = $1}
    tar_print "\n\n*** Sierpinski fractal: show numbers divisible by $input\n\n";
    col_eval ($color, '$_ % '.$input.' == 0');
}
################################################################################
sub mersenne{
    my ($input,$color)=@_;
    my @mersenne;
    tar_print "\n\n*** Mersenne's numbers and Mersenne's primes (max row $input)\n\n";
    foreach my $row (0..$input){
            my $cur;
            map {$cur += $_ } tartaglia_row($row);
            push @mersenne, $cur-1;
            given_coord($color,"$row 0-".$row);
            $color = $next_col{$color};
    }
    tar_print "\nMersenne's numbers found in first $input rows:\n";
    foreach my $n (@mersenne){
              tar_print "$n ",( check_prime($n) ? "Mersenne prime " : ''),"\n";      #check_prime($n)
    }
    tar_print "\n\n";
}
################################################################################
sub catalan{
    my ($input,$color)=@_;
    my @catalan;
    my $natural = 1;
    tar_print "\n\n*** Catalan's numbers (max row $input)\n\nNote two methods to generate the serie: the first divide the central term of any odd row ($color tiles) by the correspondant counting number: this gives the right serie: 1 1 2 5 14..\n";
    tar_print "The second method is the central term of any odd row minus the term two place left, if present ($next_col{$color} tiles). This gives the rigth serie but without the first '1'.\n\n";
    given_coord($next_col{$next_col{$color}}, "0-".int($input / 2 + 1)." 1");
    foreach my $rc (0..$input){
       next if ($rc+1) % 2 == 0;
       my @row = tartaglia_row($rc);
       my $mid = (scalar @row / 2);
       my $two_left = ($mid - 2) >= 0 ? $row[$mid - 2] : 0 ;
       tar_print "$row[$mid] / $natural = ",$row[$mid] / $natural,"\t\t$row[$mid] - $two_left = ",$row[$mid] - $two_left,"\n";
       push @catalan, ($row[$mid] / $natural);
       colorize($tkcache[$rc][$mid],$color);
       colorize($tkcache[$rc][$mid - 2],$next_col{$color}) if ($mid - 2) >= 0 and defined $tkcache[$rc][$mid - 2];
       $natural++;
    }
    tar_print "\nCatalan's numbers found in first $input rows:\n",(join ' ', @catalan),"\n\n";
}
################################################################################
sub david_star {
    my ($input,$color)=@_;
    tar_print ("warning coordinated expected\n") unless $input =~ /\d+\s+\d/;
    my ($row, $col) = split /\s/,$input;
    if ($row < 2 or $col == $row or $col == 0){tar_print "warning coordinates must be not on the border\n";return}
    unless ($tkcache[$row][$col]){$debug ? tar_print "skipping $row - $col (outside the triangle)\n" :0;return; }
    my $next_col = $next_col{$color};
    my $other_col = $next_col{$next_col};
    map {&colorize ($_, $next_col)} $tkcache[$row-1][$col-1], $tkcache[$row][$col+1], $tkcache[$row+1][$col];
    map {&colorize ($_, $other_col)} $tkcache[$row-1][$col], $tkcache[$row+1][$col+1], $tkcache[$row][$col-1];
    &colorize ($tkcache[$row][$col], $color);
    my @above = tartaglia_row ($row-1);
    my @mid = tartaglia_row ($row);
    my @below = tartaglia_row ($row+1);
    tar_print "\n\n*** David's star for number $mid[$col] ( $row - $col, $color)\n\n";
    tar_print "($next_col tiles)\ngreatest common divisor: GCD ($above[$col-1], $mid[$col+1], $below[$col]) = ",Math::BigInt::bgcd($above[$col-1], $mid[$col+1], $below[$col]),"\n";
    tar_print "product $above[$col-1] x $mid[$col+1] x $below[$col] = ",$above[$col-1] * $mid[$col+1] * $below[$col],"\n";
    tar_print "\n($other_col tiles)\ngreateast common divisor: GCD ($above[$col], $mid[$col-1],$below[$col+1]) = ",Math::BigInt::bgcd($above[$col], $mid[$col-1],$below[$col+1]),"\n";
    tar_print "product $above[$col] x $mid[$col-1] x $below[$col+1] = ",$above[$col] * $mid[$col-1] * $below[$col+1],"\n";
    tar_print "\nProduct of six terms is always an integer perfect square:\n";
    tar_print "$above[$col-1] x $mid[$col+1] x $below[$col] x $above[$col] x $mid[$col-1] x $below[$col+1] = ";
    my $big_prod = $above[$col-1] * $mid[$col+1] * $below[$col] * $above[$col] * $mid[$col-1] * $below[$col+1];
    tar_print  $big_prod, "\nsquare root of $big_prod = ", sqrt $big_prod,"\n\n";
}
################################################################################
sub is_prime{
      my ($input,$color)=@_;
      tar_print "\n\n*** Prime numbers (max row $input)\n\n";
      foreach my $row (0..$input){
              my @vals = tartaglia_row($row);
              foreach my $pos (0..$#vals){
                      next if $vals[$pos] == 1;
                      if (check_prime($vals[$pos]))  {
                          tar_print "$vals[$pos] is prime\n";
                          colorize($tkcache[$row][$pos],$color );
                      }
              }
      }
}
################################################################################
sub fibonacci{
      my ($input,$color)=@_;
      if ($input > $row_num){$input=$row_num;tar_print "Warning: too many rows specified. Using $row_num\n" if $debug}
      tar_print "\n\n*** Fibonacci's numbers (max row $input)\n\n";
      my @aoa_vals = map {[tartaglia_row($_)]} 0..$input; # why i build triangle by hockey stick pattern?!?!? argh
      my @fibonacci;
      my $fibonacci;
      my $col_i=0;
      foreach my $row (reverse 0..$input){
              my $cur_pos = 0;
              my $cur_row = $row;
              while ($cur_row >= $cur_pos){
                    next unless $tkcache[$cur_row][$cur_pos]->isa('Tk::Button');
                    colorize($tkcache[$cur_row][$cur_pos], $posible_colors[$col_i]);
                    push @{$fibonacci[$row]}, $aoa_vals[$cur_row][$cur_pos];# tar_print "push \$fibonacci[$row], $aoa_vals[$cur_row][$cur_pos];\n";
                    $cur_row--;
                    $cur_pos++;
              }
      $col_i++;
      $col_i > $#posible_colors ? $col_i=0 : 0;
      }
      map {  my $sum = join '+',@{$_};tar_print $sum,' = ', eval $sum,"\n";$fibonacci.=(eval $sum).' ';} @fibonacci;
      tar_print "\n\nFibonacci's numbers: $fibonacci\n\n";
}
################################################################################
sub power_of_eleven{
      my ($input,$color)=@_;
      my $big_int = Math::BigInt->new( '11' );
      tar_print "\n\n*** Power of 11:\t11^$input = ", $big_int->bpow($input),"\n\n";
      &given_coord($color ,"$input 0-$input");
      my @row =tartaglia_row($input);
      my $level = $input;
      my $cur_dec=0;
      my @final;
      tar_print "row $input: ",join ' ',@row,"\n\n";
      foreach my $num ( reverse @row) { # reverse is not util but..
              my ($dec,$unit,$partial_dec,$tmp);
              if ($num=~/(\d+)(\d)$/){$dec=$1;$unit=$2}
              else{$dec=0;$unit=$num}
              my $pad = '    '.("  " x $level--).' ';
              my $minus = (length ("$dec")+1);
              $pad =~ s/\s{$minus}//;
                    tar_print $pad."$dec|$unit\n";
                    $num+=$cur_dec;
                    if ($num=~/(\d+)(\d)$/){$cur_dec=$1;$num=$2}
                    else{$cur_dec=0; }
                    unshift @final,$num;
      }
      $cur_dec ? unshift @final, $cur_dec  : 0;
      tar_print "\n     ",(join ' ',@final),"\n\n = ",(join '',@final),"\n\n";
}
################################################################################
sub power_of_two{
      my ($input,$color)=@_;
      my $big_int = Math::BigInt->new( '2' );#tar_print $x->bpow(15);
      tar_print "\n\n*** Power of 2:\t2^$input = ", $big_int->bpow($input),"\n\n";
      &given_coord($color ,"$input 0-$input");
      my $sum = join ' + ', tartaglia_row($input);
      tar_print "$sum = ",eval $sum,"\n\n";
}
################################################################################
sub bin_exp{ #plagiarized from crazyinsomniac at http://www.perlmonks.org/?node_id=68056
    my $n = shift;
    tar_print "\n\n*** Binomial expansion:\t(a+b)^$n =\n\n";
    my @coefficient = tartaglia_row($n);
    for my $j (0 .. $n)
    {
       my $nj=$n-$j;
       tar_print $coefficient[$j];
       tar_print $_ = ($nj!=0)?( ($nj>1)?(' * a^'.$nj):(' * a') ):'';
       tar_print $_ = ($j!=0)?( ($j==1)?(' * b'):(' * b^'.$j) ):'';
       tar_print $_ = ($j!=$n)?(" +\n"):("\n");
    }
    tar_print "\n\n" ;
}
################################################################################
sub col_eval {
    my $color = shift;
    my $to_eval = shift;
    if ($to_eval =~ /system|exec|`/){tar_print "not safe\n";return}
    foreach my $row (0..$row_num) {
            my @vals = &tartaglia_row($row);
            my $i = 0;
            map {  my $val = $_;
                  ( my $str = $to_eval) =~ s/\$_/$val/e;
                  eval $to_eval ?
                       ( &tar_print ("$str TRUE AT $row - $i\n") and
                         &colorize ($tkcache[$row][$i], $color)
                       ) : 0;
                  $i++;
            } @vals;
    }
}
################################################################################
#   UTILITY SUBROUTINES
################################################################################
sub create_experiment{
    my ($input, $color, $title, $help, $sub_ref) = @_;
    my $frame = $scrolled_top->Frame(-borderwidth => 2, -relief => 'groove')->pack(-side=>'top',-anchor=>'w',-pady=>5);
    $frame->Button(-text => "?",-borderwidth => 2, -command => sub {&help($help)} )->pack(-side => 'left',-expand => 1);
    $frame->Label(-text => (pack 'A25', $title) )->pack(-side => 'left',-expand => 1);
    $frame->Entry(-width => 25,-borderwidth => 4,-textvariable => $input)->pack(-side => 'left',-expand => 1);
    $frame->Optionmenu(-options => [@posible_colors],-variable => $color)->pack(-side => 'left',-expand => 1);
    $frame->Button(-text => "Colorize",-borderwidth => 4, -command => $sub_ref)->pack(-side => 'left',-expand => 1);
    $frame->Button(-text => "Clear",-borderwidth => 4, -command => \&decolorize)->pack(-side => 'left',-expand => 1);
}
################################################################################
sub tar_print{
    &check_output();
    $out->insert('end', "@_");
    $out->see('end');
    1;  # or col_eval will not call colorizes
}
################################################################################
sub check_prime { #http://www.perlmonks.org/?node_id=1054405
  my ($i,$j,$h,$sentinel) = (shift,0,0,0);
  # if $i is an even number, it can't be a prime
  if($i%2==0){return 0}
  else{
    $h=POSIX::floor(sqrt($i));
    $sentinel=0;
      # since $i can't be even -> only divide by odd numbers
      for($j=3; $j<=$h; $j+=2){
          if($i%$j==0){
               $sentinel++;
               # $i is not a prime, we can get out of the loop
              $j=$h;
          }
      }
    if($sentinel==0){
        return 1; print "$i \n";
    }
  }
}
################################################################################
sub decolorize {
                 foreach my $it(@colorized){
                              #tar_print "CLEAR call colorize: $it\n" if $debug;
                              &colorize(  $it,'gray') ;
                 }
                 @colorized=();
                 return;
}
################################################################################
sub colorize {
    my $ref = shift;
    return 0 unless $ref;
    return 0 unless $ref->can('configure');
    my $color = shift;
    unless ($color eq 'gray'){push @colorized, $ref; }
    $ref->configure(-background =>$color);
    $tart_win->update;
}
################################################################################
sub given_coord {
    my $color = shift;
    my $to_color = shift;
    my @group = split /,/,$to_color;
    foreach my $pair (@group){
          $pair =~ s/^\s+//;$pair =~ s/\s+$//; $pair =~ s/\s+/ /;
          map  {  my ($x,$y) = split /\s+/,$_;
                  $tkcache[$x][$y] ? &colorize ($tkcache[$x][$y], $color) :
                                    ($debug ? tar_print "skipping $x - $y (outside the triangle)\n" :0);
          } &exp_coord($pair);
    }
}
################################################################################
sub exp_coord {
    my ($r,$c)=split /\s/,"@_";
    unless (defined $r and defined $c) {tar_print "Both must be defined. Received:",map{defined $_ ? "$_ " : 'UNDEF '}($r,$c);return}
    my @r; my @c;
    my @expanded;
    @r = $r=~/^(.*\d)-(.+)$/ ? ($1..$2) : ($r);
    @c = $c=~/^(.*\d)-(.+)$/ ? ($1..$2) : ($c);

    for my $rc (@r) { for my $cc (@c) { push @expanded, "$rc $cc" } };
    return @expanded;
}
################################################################################
sub destroy_tri {
    if  (Exists($tart_win)) {
        $tart_win->destroy();
        undef @colorized;
    }
    #tar_print "MainWindow geometry: ",$mw->geometry(),"\n";
    #tar_print "Triangle geometry: ",$tart_win->geometry(),"\n";
    #tar_print "output geometry: ",$ow->geometry(),"\n";
}

################################################################################
sub draw_triangle {
  my $scrolledframe;
  if (! Exists($tart_win)) {
    $tart_win = $mw->Toplevel();
    $tart_win->Icon(-image => $mw->Pixmap(-data => &tart_icon));
    $tart_win->geometry("300x450+708+0");
    $scrolledframe = $tart_win->Scrolled('Frame',
                      -background=>'black',
                      -scrollbars => 'osoe',
    )->pack(-expand => 1, -fill => 'both');
    $tart_win->title(" Tartaglia's triangle ");
    $tart_win->optionAdd('*Button.font' => 'Arial '.$size_tile.' '.($bold_tile ? 'bold' : ''), 20); #'Courier 13 bold'
    tar_print "\nDRAWING a tartaglia's triangle of ".($row_num + 1)." rows (with dots if $dot_after or more digits)\n\n";
  }
  else {
    $tart_win->deiconify( ) if $tart_win->state() eq 'iconic';
    $tart_win->raise( ) if $tart_win->state() eq 'withdrawn';
    return;
  }
  #draw the triangle
  foreach my $row( 0..$row_num ){
           my $frame = $scrolledframe->Frame->grid;
          my ($first,@rest) =  &tartaglia_row ($row);
          my @others;
          foreach my $i (0..$#rest) {
                   my $n = $rest[$i];
                   $tkcache[$row][$i + 1] =
                          $frame->Button(-command => sub{tar_print "HIT ($row - ".($i + 1).") VALUE $n\n";},
                                                -text => &shrinkn($n) ,
                                                -background => 'gray' );
                   $others[$i] = $tkcache[$row][$i + 1];
          }
          $tkcache[$row][0] = $frame->Button( -command => sub{print $tkcache[$row][0]->fontActual('font'),"\n";tar_print "HIT ($row - 0) VALUE 1\n"},
                                              -text => &shrinkn($first),
                                              -background => 'gray' )->grid( @others );
  }
 tar_print "\n\n";
}
################################################################################
#{
# my @tartaglia ; #AoA used as CACHE
  sub tartaglia {
      my ($x,$y) = @_; #tar_print "\t\treceiving ".($y)." $x\t";
      if ($x == 0 or $y == 0)  { $tartaglia[$x][$y]=1 ; tar_print "\tFORCED: 1\n" if $debug;return 1};
      tar_print ""."\tCACHE: ",(defined $tartaglia[$x][$y] ? "$tartaglia[$x][$y]" : ' -not present- '),"\n" if $debug;
      my $ret ;
      foreach my $yps (0..$y){
        #tar_print "\tCACHE:", ( $tartaglia[$x-1][$yps] ? " HIT " : ' -not present- '),"for ".($x - 1)." $yps\n";
        $ret += ( $tartaglia[$x-1][$yps] || &tartaglia($x-1,$yps) );
      }
      $tartaglia[$x][$y] = $ret;
      return $ret;
  }
#}
################################################################################
sub tartaglia_row {
    my $y = shift;
    my $x = 0;
    my @row;
       tar_print "ROW:".' '.($y)."\n" if $debug;
    $row[0] = &tartaglia($x,$y+1);
    foreach my $pos (0..$y-1) {push @row, &tartaglia(++$x,--$y)}

    return @row;
}
################################################################################
sub shrinkn {
              my $num = shift;
              my $rex = qr(\d{$dot_after});
              if ($num =~ $rex){ return '..'}
              else {return $num;}
}

################################################################################
sub check_output {
     #my $txt;
     if (! Exists($ow)) { $out = &outwin }
     $ow->deiconify( ) if $ow->state() eq 'iconic';
     $ow->raise( ) if $ow->state() eq 'withdrawn';
}
################################################################################
sub outwin {
    $ow = $mw->Toplevel( );
    $ow->Icon(-image => $mw->Pixmap(-data => &tart_icon));
    my $chars = 'Courier '.$size_out.' '.($bold_out ? 'bold' : '');
    $ow->geometry("755x429+708+490");
    $ow->optionAdd('*Text.font' => $chars, 20); #'Courier 13 bold'
    $ow->title(" output ");
    my $txt = $ow->Scrolled('Text',
                      -scrollbars => 'osoe',
                      -background => 'black',
                      -foreground => 'green',
                      #NO -data => \$cont,
    )->pack(-expand => 1, -fill => 'both');
    #tie *STDOUT,  $txt, $txt;
    return $txt;
}
################################################################################
sub help {
    my @helps = @_;
    my $hw = $mw->Toplevel( );
    $hw->Icon(-image => $mw->Pixmap(-data => &tart_icon));
    my $chars = 'Courier '.$size_help.' '.($bold_help ? 'bold' : '');
    $hw->geometry("900x450+0+0");
    $hw->optionAdd('*Text.font' => $chars, 20); #'Courier 13 bold'
    #$hw->optionAdd( '*Text.background'=>   'royalblue', 20 );
    $hw->title(" help ");
    my $txt = $hw->Scrolled('Text',
                      -background=>'white',
                      -scrollbars => 'osoe',
                      -background => 'blue3',
                      -foreground => 'gold2',
                      #NO -data => \$cont,
    )->pack(-expand => 1, -fill => 'both');

    $txt->Contents(map {&{$_}} @helps);
    $txt->Subwidget("yscrollbar")->configure(-background => 'black');
    $hw->update;
}
################################################################################
#     HELP TEXTS SUBROUTINES
################################################################################
sub help_eval  {
    return <<'EOH'
* Evaluation *

USAGE: enter valid Perl code. ** USE WITH CARE **

This experiment is dedicated mostly to Perl writer that can evaluate some code against any number in the triangle. While traversing the triangle numbers '$_' will be the current number.

  $_ == 13

will colorize only 13, while

  $_ == 13 or $_==14

14 too

  $_ % 7 == 0

will show numbers divisible by 7, reveiling some Sierpinski's pattern too.

  $_ > 0

can change the background color of the Tartaglia's triangle.

EOH
}
################################################################################
sub help_com  {
    return <<EOH
* Combinations *

USAGE: feed the coordinates of a tile in the form of 'row column'. The row, the column and the tile will be colorized with three different colors.
The value of combinations with repetition is colorized with another color, to show the correlation between the two.

The Tartaglia's triangle shows the answer to the question: 'how many groups are possible grouping a set of X (row) by Y (column)?'.
This is called combination (or k-combination) in mathematic, id est no matter of the order of the elements and no repetition of elements.
The formula is the binomial coefiicent's one.

               n!
 C(n,k) =  ----------
            k!(n-k)!

If an element can be found more than once, we call the result a 'combination with repetition' (or k-multicombination). The formula is linked to the binomial coefficient too:

  d                      (n + k - 1)!
C      = C          =    -------------
 (n,k)    (n+k-1,k)      (n-1)!    k!

Speaking in tartaglia's triangle terms, the answer to a combinations with repetitions, in respect to one without repetitions, will be at the same column but the row will be 'n + k - 1' instead of 'n'.

EOH
}
################################################################################
sub help_tri  {
    return <<EOH
* Triangular numbers, Polygonal numbers and Figurates ones *

USAGE: Put in the entry box a number. The correspondent Triangular Number will be colorized along with each of the diagonal of Triangulars Numbers as well.

Triangulars numbers are a subset of Polygonal numbers that are a subset of Figurates ones.

If you can arrange a number of dots forming a regular triangle, then that number is a Triangular Number.
In the same way if you can form a square you have a 'Square Number',  and a 'Pentaghonal Number' if you can form a pentagon and so on.

                                o
                     o         o o
            o       o o       o o o
     o     o o     o o o     o o o o
o   o o   o o o   o o o o   o o o o o

1    3      6       10          15

Very interestingly, every polygonal number can be calculated using the correspondent Triangular one.

The nth s-ogonal number P(s,n) is related to the Triangular number T:


P(s,n)  = (s-2) T(n-1) + n  = (s - 3) T(n-1) + T(n)

For example the 4th exagonal number is:

P(6,4) =  (6 - 2) T(4-1) + 4  =  4 T(3) + 4  =  4 * 6 + 4 =  28

      O O O O
     O       O
    O O O O   O
   O O     O   O
    O O O   O O
     O   O O O
      O O O O

The 6th hexagonal number is, as you can see, 28.

In the II century BC, Ipsicle had found the relation between polygonal numbers an arithmetic progressions.
A polygonal number with sides n is equal to the summation of all terms of an arithmetic progression with first term 1 and ratio n-2.

For the 4th exagonal number the progression has ratio 6-2  = 4.

1 5 9 13

1 + 5 + 9 + 13 = 28


As you can see, the first column of Tartaglia's Triangle is composed by many 1's.
The second column contains Counting Numbers, while the 3rd contains Triangular Numbers(2 dimensions).
The 4th column contains Tetrahedral Numbers (3 dimensions) and the 5th  Pentatope Numbers (4 dimensions) and so on.

So if you want to build a pyramid of oranges with triangular base and 4 floors you need 20 oranges.
Cubic numbers can be calculated using tetrahedral ones:

Cubic(n) =  Tetrahedral(n-2) + 4 Tetrahedral(n-1) + Tetrahedral(n)

Might I hazzard a guess that counting numbers are Figurate Numbers of 1 dimension and the 1's series is a series of 0 dimension Figurate Numbers?
I think you'll find any Figurate Number of any Regular Shape of any Dimension in the Tartaglia's Triangle...

EOH
}
################################################################################
sub help_squa  {
    return <<EOH
* Sumation of squares of terms in a row *

USAGE: give the row number of which you want to calculate the sumation of squares.

You'll see that the summation of squares of term on row n is equal to the central term of row 2n.

EOH
}
################################################################################
sub help_para  {
    return <<EOH
* Parallelogram pattern *

USAGE: give the coordinates of tile and will be demondstrated that this number is equal to the summation of all numbers in the parallelogram excluded by the two diagonals crossing at the given tile position.


EOH
}
################################################################################
sub help_hockey  {
    return <<EOH
* Hockeystick pattern *

USAGE: give the coordinates of tile and will be demondstrated that this number is equal to the summation of all numbers in the prior diagonal up to the same position of the given number.


EOH
}
################################################################################
sub help_sie  {
    return <<EOH
* Sierpinski's fractals *

USAGE: just put in the entry box a number. Every tiles will be colorized if divisible by number given

Selecting a tile by divisibilty criteria can be drawn as a pattern tending to a Sierpinsky Triangle.
With different numbers you will obtains differnt fractals.
EOH
}
################################################################################
sub help_mer  {
    return <<EOH
* Mersenne's numbers *

USAGE: just put in the entry box the max row number to be considerated to find Mersenne's numbers from the triangle.

A Mersenne's number is a number which is one less than a power of two. As every row of the Tartaglia's triangle is a power of 2, the sum of every term in a row, minus 1, is a Mersenne's number.

If a number in such sequence is prime it is called Mersenne's prime. Such primes Mp are correlated with perfect numbers: Euclid (4th century BC) proved that if 2p-1 is prime, then 2p-1(2p - 1) is a perfect number. This number is also expressible as Mp(Mp+1)/2
EOH
}
################################################################################
sub help_cat  {
    return <<EOH
* Catalan's numbers *

USAGE: just put in the entry box the max row number to be considerated to find Catalan's numbers from the triangle.

I have decided to show on the screen two ways to extract Catalan's numbers from the Tartaglia's triangle: while the first shows the correct serie (1 1 2 5 ..) the second sequence has only one '1' in the beginning. I choose this way beacause both solutions are really tied with the triangle itself.

EOH
}
################################################################################
sub help_pri  {
    return <<EOH
* Prime numbers *

USAGE: just put in the entry box the max row number to be considerated to find prime numbers in the triangle.

You'll notice the disposition of primes in the triangle. Also note that if the 1st number on a row is prime (remember 0th number are always 1) all other entries in that row (until the prime number reappers as penultimate entry)  will be divisible by that prime number.

For example, in the 7th row you have:

1 7(a prime) 21 35 35 21 7(the prime again) 1

And, actually 21 and 35 are divisible by 7.


EOH
}
################################################################################
sub help_fib  {
    return <<EOH
* Fibonacci's numbers *

USAGE: just put in the entry box the max row number to be considerated to create a Fibonacci's serie.

Fibonacci's numbers are obtained summing all the values present in a diagonal of the triangle.
In this experiment the color choosen is not take in count.

If you enter '12' as max row you'll obtain a colorfull triangle and in the screen:


Fibonacci's numbers (max row 12)

1 = 1
1 = 1
1+1 = 2
1+2 = 3
1+3+1 = 5
1+4+3 = 8
1+5+6+1 = 13
1+6+10+4 = 21
1+7+15+10+1 = 34
1+8+21+20+5 = 55
1+9+28+35+15+1 = 89
1+10+36+56+35+6 = 144
1+11+45+84+70+21+1 = 233


Fibonacci's numbers: 1 1 2 3 5 8 13 21 34 55 89 144 233

EOH
}
################################################################################
sub help_bycoord  {
        return <<EOH
* Colorize by coordinates *

USAGE: this colorizes by given coordinates, in 'row column' format. More coordinates can be given separting pairs with commas. Both row and column can be expressed as interval as in '7 0-7' for entire row 7 or as '0-7 0' for the first 8 elements of the 0th column.

If a too wide range is given (some coordinates values are outside the triangle as  for '0 1') tales outside the triangle are skipped. You can view some worning on screen if you have enabled the 'print debug information' control.
EOH
}
################################################################################
sub help_pow11  {
    return <<EOH
* Powers of 11 *

USAGE: just put in the entry box the power of 11 you want to calculate.
It appears that digits of a power of two '11 ^ n' are whom present in the nth row.
While this is evident for row 0-4 you need to displace every quantities above '9' for row greater than 4.

For example if you insert '8' and hit 'colorize' the 8th row will change color and in the screen appears:


Power of 11:    11^8 = 214358881

row 8: 1 8 28 56 70 56 28 8 1

                   0|1
                 0|8
               2|8
             5|6
           7|0
         5|6
       2|8
     0|8
   0|1

     2 1 4 3 5 8 8 8 1

 = 214358881


Please note, i'm too lazy to show it, that this is true for every sum of two distinct powers of 10.

Id est: this procedure is valid for these three sums: (10+1), (100+1) e (10+0,1):

          1                   1                       1         1
        1   1                11                   1.001        10,1
      1   2   1             121               1.002.001       102,01
    1   3   3   1         1.331           1.003.003.001     1.030,301
  1   4   6   4   1      14.641       1.004.006.004.001    10.406,0401
1   5  10  10   5   1   161.051   1.005.010.010.005.001   105.101,00501

In the same way, if you write the Tartaglia's triangle not in base 10 but in base 'c' you'll be able to read the powers of every sum of two distinct power of 'c'.

EOH
}
################################################################################
sub help_david  {
    return <<EOH
* David's start  *

USAGE: feed cordinates of a tile not in the border of the triangle and seven tiles will be colorized: the given one of the color specified, the surrounding other six ones in two different, alternate colors forming a David's star pattern.

On the screen will appear three different properties of such pattern as calculation: the two terns share the Greatest Common Divisor and the result of the product of their three terms. Also the product of all six surrounding terms is always an integer perfect square. The last one is obvious: as the product of two terns are equal their product will be a square.

EOH
}################################################################################
sub help_pow2  {
    return <<EOH
* Powers of 2 *

USAGE: just put in the entry box the power of 2 you want to calculate.
It appears that a power of two '2 ^ n' is equal to the sum of every element in the nth row of the triangle.
The corrispondent row will be colorized with choosen color and the resulting addition will be printed on the screen.

For example if you insert '13' and hit 'colorize' the 13th row will change color and in the screen appears:



Power of 2:     2^13 = 8192

1 + 13 + 78 + 286 + 715 + 1287 + 1716 + 1716 + 1287 + 715 + 286 + 78 + 13 + 1 = 8192


Note for this and others experiment: when te result appears two times, as above for 8192, the first time is calculated directly, while the second time is evalueted from the operation just created (in this case a 14 terms addition).
EOH
}
################################################################################
sub help_bin  {
    return <<EOH
* Binomial expansion *

USAGE: just put in the entry box the power you want to calculate for the biomial (a + b)
The corrispondent row will be colorized with choosen color and the full expansion will be printed on the screen.

For example if you insert '5' and hit 'colorize' the 5th row (remember the first row is the 0th) will change color and in the screen appears:


Binomial expansion:     (a+b)^5 =

1 * a^5 +
5 * a^4 * b +
10 * a^3 * b^2 +
10 * a^2 * b^3 +
5 * a * b^4 +
1 * b^5

Binomial expansion describes also the 'Heads and Tails' game, when you trow a coin.
If you trow a coin three times you can have these results:

        HHH
    HHT HTH THH
    TTH THT HTT
        TTT

Id est: 1 time 3 heads, 3 times 2 heads and 1 tail, 3 times 2 tails and 1 heads, 1 time 3 tails.
This is the sequence 1 3 3 1, the 3th row of the triangle, the coefficients of the cubic expansion of (a+b).


Incredibly for me, binomial expansion describes also the geometrical 'points in a circle' scenario.
Given a circle draw points on it for 1 to any number you want and draw all the possible lines between them: you'll see segments, or if you put 3 or more point, some polygons. The number of each type of geometrical shape are binomial coefficients as shown by the Tartaglia's triangle.
Id est: skipping the first diagonal (all 1s),if  the second one (counting numbers) holds how many points you drawn on a circle then others numbers in the row are how many segments, trinagles, quadrilaters, pentagons, hexagons, heptagons ... are possible with all vertices on the circle.


  points
in a circle   segments    triangles   quadrilaters    pentagons   hexagons

    1            -            -            -               -          -
    2            1            -            -               -          -
    3            3            1            -               -          -
    4            6            4            1               -          -
    5            10           10           5               1          -
    6            15           20           15              6          1
EOH
}
################################################################################
sub help_intro  {
    return <<EOH
* Introduction *

In Italy, the arithmetic triangle is called Tartglia's triangle, because exposed in the "General trattato di numeri et misure" written in 1556 by Niccolò Fontana (1499 ca, Brescia 13 December 1557, Venice), known also as Tartaglia.

In 1512 when the French invaded Brescia, a French soldier sliced Niccolò's jaw and palate with a saber. This made it impossible for Niccolò to speak normally, prompting the nickname "Tartaglia" ("stammerer"), which he adopted.

Known as Pascal's triangle (but Pascal drow it as right triangle) in many other countries was known by Halayuda, an Indian commentator, in 10th century, sudied around 1100 by Omar Khayyam, a Persian mathematician, known in China as early as 1261 and so studied in India, Greece, Iran, China, Germany and Italy before Pascal.

About the program: keep it mind i'm not a mathematician, i was only impressed by the huge amount of things you can see in the triangle and i want to show them.

Many useful things about the tartaglia's triangle are shown using the Experiment Panel, others are enumered at the end of this introduction.

When you click a tale of the triangle it's coordinates and it's numerical value are printed on the output window.

Remember that the first row is 0 and the first column is also 0. The triangle is constructed by summing the values of two adiacent position in row and putting the result, below them, in the middle. The general formula to calculate any given number in the triangle given the coordinate is also known as "n choose k"

               n!
 C(n,k) =  ----------
            k!(n-k)!


where n is the row and k is the position, both counting from 0.



* Experiments Panel *

At the top you have the Properties Configuration: This allows the user to determine and/or display:
 * How many rows to draw
 * A button to display this introduction
 * At what point large numbers should be subtituted with dots (to build the shape of the triangle acceptable)
 * The abilty to enable debug information to be displayed on the screen
 * The size and boldness of both output displays
 * The Help Window
 * The main creation or distruction control

Consider that building a bigger triangle requires bigger calculations: You can draw a 127 (or more) row triangle in few seconds on a modern calculator if you want.
If this is the case consider that the values of any element in rows are cached by the main Perl program, so that following calculation will use cached values with no speed penalty.

The next part is a number of experiments you can do with the aritmetic triangle.
The experiments looks very similar:
 * All have some help associated (button '?')
 * A short description
 * An entry field
 * A color chooser
 * And the colorize/clear buttons


* Other properties of the triangle *

-The triangle is symmetrical.
-Some of the numbers in Tartaglia's triangle correlate to numbers in Lozanic''s triangle
-Imagine each number in the triangle is a node in a grid which is connected to the adjacent numbers above and below it. Now for any node in the grid, count the number of paths there are in the grid (without backtracking) which connect this node to the top node (1) of the triangle. The answer is the number associated to that node.
-The only number that appears once is 2.
-All entries in row n are odd if and only if the binary representation of n consists of 1s.
-If p is a prime, then every internal entry in row p ^ n (with n as any positive integer) is divisible by p.



* Further readings and credits *

This software is written in Perl and would not be possible without the aid of the community of www.perlmonks.org (just plagiarized some bit from crazyinsomniac, Anonymous, helped by ambrus and wjw and many others).

If you want learn even more properties of the Tartaglia's triangle (seems impossible but there are more) consider worth a visit to:

http://mathforum.org/mathimages/index.php/Pascal%27s_triangle
http://www.cut-the-knot.org/arithmetic/combinatorics/PascalTriangleProperties.shtml
http://ptri1.tripod.com/
http://www.mathsisfun.com/pascals-triangle.html
http://mathworld.wolfram.com/PascalsTriangle.html

EOH
}
################################################################################
sub tart_icon {
    return <<EOI
/* XPM */
static char * Icon_xpm[] = {
"32 32 4 1",
"     c #000000000000",
"g    c #00FF00",
"X    c #FF0000",
"D    c #FFFF00",
"                                ",
"                                ",
"                                ",
"                                ",
"                                ",
"                                ",
"        XXXXXXXXXXXXXXXX        ",
"        XXXXXXXXXXXXXXXX        ",
"                                ",
"                                ",
"               XX               ",
"               XX               ",
"              XXXX              ",
"              XXXX              ",
"             XXXXXX             ",
"             XXXXXX             ",
"            XXXXXXXX            ",
"            XXXXXXXX            ",
"           XXXXXXXXXX           ",
"           XXXXXXXXXX           ",
"          XXXXXXXXXXXX          ",
"          XXXXXXXXXXXX          ",
"         XXXXXXXXXXXXXX         ",
"         XXXXXXXXXXXXXX         ",
"                                ",
"                                ",
"                                ",
"                                ",
"                                ",
"                                ",
"                                ",
" Discipulus as in perlmonks.org ",};
EOI
}

__DATA__
