#!/usr/bin/perl

$use_parens = 0;

# Polynomial internal format: list of length equal to degree of poly
# Each item in list is coeff of that term
# So, x^2 = [0, 0, 1]

sub parse_poly {
    my ($polytext) = @_;
    my @poly;

    while ($polytext =~ s|^\s*([+-]?[0-9/]*)(x)?(\^([0-9]*))?||) {
	last if ($1 eq "" and $2 eq "" and $3 eq "");
	$coeff = $1;
	$power = $4;

	if ($coeff eq "" or $coeff eq "+") {
	    $coeff = 1;
	} elsif ($coeff eq "-") {
	    $coeff = -1;
	} else {
	    #print STDERR $coeff;
	    $coeff = eval "$coeff + 0";
	    #print STDERR " ", $coeff, "\n",
	}
	$power = "1" if ($power eq "");
	$power = "0" if ($2 ne "x");
	#print STDERR "$coeff $power\n";
	$poly[$power] = $coeff;
    }
    return \@poly;
}

sub poly_degree {
    my ($poly) = @_;

    if ($#$poly == -1) {
	return 0;
    } else {
	return $#$poly;
    }
}

sub texformat_fraction {
    my ($number) = @_;

    return $number if (int($number) == $number);

    for (my $denom=2; ; $denom++) {
	if (int($number*$denom) == $number*$denom) {
	    # return $number*$denom . "/$denom";
	    return "{" . $number*$denom . "\\over$denom}";
	}
    }
}

sub format_poly_texformat {
    my ($poly) = @_;
    my $result;

    for (my $power=$#$poly; $power>=0; $power--) {
	my $coeff = $$poly[$power] + 0;
	next if ($coeff == 0);
	if ($coeff == 1 and $power > 0) {
	    $coeff = "+";
	    $coeff = "" if ($power == $#$poly);
	} elsif ($coeff == -1 and $power > 0) {
	    $coeff = "-";
	} elsif ($coeff > 0) {
	    $coeff = &texformat_fraction($coeff);
	    $coeff = "+$coeff" unless ($power == $#$poly);
	} elsif ($coeff < 0) {
	    $coeff = "-" . &texformat_fraction(-$coeff);
	}

	if ($power == 0) {
	    $result .= "${coeff}";
	} elsif ($power == 1) {
	    $result .= "${coeff}x";
	} else {
	    $result .= "${coeff}x^$power";
	}
    }
    $result = "0" if $result eq "";
    return $result;
}

# Always prints (twice (degree plus one)) number of "&" marks,
# seperating sign from coeff/var of each term, minus two (no leading
# or trailing marks).  So, returned string consumes (twice the degree)
# plus two columns.
#
# &0
# &5
# -&5
# &x&+&1
# -&x&+&1

sub format_poly_textableformat {
    my ($poly) = @_;
    my $result;

    for (my $power=$#$poly; $power>=0; $power--) {
	my $coeff = $$poly[$power] + 0;
	if ($coeff == 0) {
	    $result .= "&&";
	    next;
	}
	if ($coeff == 1 and $power > 0) {
	    if ($power == $#$poly) {
		$result .= "&";
	    } else {
		$result .= "+&";
	    }
	} elsif ($coeff == -1 and $power > 0) {
	    $result .= "-&";
	} elsif ($coeff > 0) {
	    if ($power == $#$poly) {
		$result .= "&";
	    } else {
		$result .= "+&";
	    }
	    $result .= &texformat_fraction($coeff);
	} elsif ($coeff < 0) {
	    $result .= "-&" . &texformat_fraction(-$coeff);
	}

	if ($power == 0) {
	    $result .= "&";
	} elsif ($power == 1) {
	    $result .= "x&";
	} else {
	    $result .= "x^$power&";
	}
    }

    $result =~ s/&$//;
    #$result =~ s/^&//;
    $result = "&0" if $result eq "&";
    return $result;
}

sub print_poly_texformat {
    my ($poly) = @_;
    print &format_poly_texformat($poly), "\n";
}

# &add_poly assumes that poly1's degree is >= poly2's degree

sub add_poly {
    my ($poly1, $poly2) = @_;
    my @result = (0);
    my $maxpower = ($#$poly1 > $#$poly2 ? $#$poly1 : $#$poly2);

    for (my $power = $maxpower; $power>=0; $power--) {
	my $coeff = $$poly1[$power] + $$poly2[$power];
	$result[$power] = $coeff if $coeff != 0;
    }

    return \@result;
}

# &subtract_poly assumes that poly1's degree is >= poly2's degree

sub subtract_poly {
    my ($poly1, $poly2) = @_;
    my @result = (0);

    for (my $power = $#$poly1; $power>=0; $power--) {
	my $coeff = $$poly1[$power] - $$poly2[$power];
	$result[$power] = $coeff if $coeff != 0;
    }

    return \@result;
}

sub multiply_poly {
    my ($poly1, $poly2) = @_;
    my @result = (0);

    for (my $power1 = $#$poly1; $power1>=0; $power1--) {
	for (my $power2 = $#$poly2; $power2>=0; $power2--) {
	    my $coeff = $$poly1[$power1] * $$poly2[$power2];
	    $result[$power1+$power2] += $coeff if $coeff != 0;
	}
    }

    return \@result;
}

# &divide_leading_terms assumes that poly1's degree is >= poly2's degree

sub divide_leading_terms {
    my ($poly1, $poly2) = @_;
    my @result = (0);

    $result[$#$poly1 - $#$poly2] = $$poly1[$#$poly1] / $$poly2[$#$poly2];

    return \@result;
}

$dividend = &parse_poly($ARGV[0]);
$divisor = &parse_poly($ARGV[1]);

my $quotient=[0];
my @remainders = ($dividend);
my @sterms = ([0]);
my @multiples = ([0]);

while ($#{$remainders[$#remainders]} >= $#$divisor) {
    my $multiple = &divide_leading_terms($remainders[$#remainders],$divisor);
    my $sterm = &multiply_poly($multiple, $divisor);
    $quotient = &add_poly($quotient,$multiple);
    push @remainders, &subtract_poly($remainders[$#remainders], $sterm);
    push @sterms, $sterm;
    push @multiples, $multiple;
    #&print_poly_texformat($remainder);
}

#print "            ";
#print &format_poly_texformat($quotient), "\n";
#print &format_poly_texformat($divisor), "         ";
#&print_poly_texformat($dividend);

#for (my $i=1; $i<=$#remainders; $i++) {
#    print "\n";
#    print "          ";
#    &print_poly_texformat($sterms[$i]);
#    print "          ";
#    &print_poly_texformat($remainders[$i]);
#}

#print "\n\n            ";
print STDERR &format_poly_textableformat($quotient), "\n";
print STDERR &format_poly_textableformat($divisor), "\n";
print STDERR &format_poly_textableformat($dividend), "\n";

$numcols = 2*($#$dividend + 1 + $#$divisor + 1);

print STDERR "numcols = $numcols = 2*($#$dividend + 1 + $#$divisor + 1)\n";

# add one more column for closing paren at end if $use_parens

print "\\vbox{\\offinterlineskip\n";
print "\\tabskip=0pt plus1fil\n";
print "\\halign to\\hsize{\\tabskip=0pt";
for ($i=($use_parens?0:1); $i<=$numcols; $i++) {
    print "\\hfil \$#\$";
    print " & " if ($i != $numcols);
}
#print "\\hfil \$#\$&\\hfil \$#\$&&\\hfil \$#\$";
print "\\tabskip=0pt plus1fil\\cr\n";

# quotient, indented
# remember, (twice the degree) plus two columns

print "\\multispan{", $numcols - (2*$#$quotient+2), "}&";
print &format_poly_textableformat($quotient), "\\vbox to16pt{}\\cr\n";

# line under quotient

print "\\multispan{", $numcols - (2*$#$dividend+2), "}&";
print "\\multispan{", (2*$#$dividend+2), "}\\vbox to 5pt{}\\leaders\\hrule\\hfil\\cr\n";

# divisor, vertical bar, dividend

print &format_poly_textableformat($divisor);
print "&\\vrule\\,", &format_poly_textableformat($dividend), "\\vbox to16pt{}\\cr\n";

# series of divisions

for (my $i=1; $i<=$#remainders; $i++) {

    if ($use_parens) {
	print "\\multispan{", $numcols - (2*$#{$sterms[$i]}+2) - 1, "}&";
	print "\\span\\hfil -(";
	my $poly =  &format_poly_textableformat($sterms[$i]);
	$poly =~ s/^&/\\span /;
	print "$poly\\vbox to16pt{}&)\\cr\n";
    } else {
	print "\\multispan{", $numcols - (2*$#{$sterms[$i]}+2), "}&";
	print &format_poly_textableformat($sterms[$i]);
	print "\\vbox to16pt{}\\cr\n";
    }

    # the line - there are two cases here depending on whether the leading
    # term of the polynomial right above use is positive or negative,
    # which determines if we should extend the line left into the sign
    # field (if it's negative) or not (if it's positive)

    if ($sterms[$i][$#{$sterms[$i]}-1] >= 0) {
	print "\\multispan{", $numcols - (2*$#{$sterms[$i]}+2)+1, "}&";
	print "\\multispan{", (2*$#{$sterms[$i]}+2)-1, "}\\vbox to 5pt{}\\leaders\\hrule\\hfil\\cr\n";
    } else {
	print "\\multispan{", $numcols - (2*$#{$sterms[$i]}+2), "}&";
	print "\\multispan{", (2*$#{$sterms[$i]}+2), "}\\vbox to 5pt{}\\leaders\\hrule\\hfil\\cr\n";
    }

    print STDERR $#{$remainders[$i]}, " ", &format_poly_texformat($remainders[$i]),"\n";
    print "\\multispan{", $numcols - (2*$#{$remainders[$i]}+2), "}&";
    print &format_poly_textableformat($remainders[$i]);
    print "\\vbox to16pt{}\\cr\n";
}

print "}}\n";
