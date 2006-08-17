#!/usr/bin/perl

use strict;

use Data::Dumper;

my $use_parens = 1;

my %poly_var;

sub parse_coefficient {
    my ($coeff_text) = @_;
    my $sign = 1;

    $coeff_text =~ s/^\+//;
    $sign = -1 if ($coeff_text =~ s/^-//);

    if ($coeff_text =~ m:^[0-9]+$:) {
	return $sign * ($coeff_text + 0);
    } elsif ($coeff_text =~ m:^([0-9]+)/([0-9]+)$:) {
	return [$sign * ($1 + 0), $2 + 0];
    } else {
	die "can't parse coefficient \"$coeff_text\"";
    }
}

sub gcd {
    my ($a,$b) = @_;

    $a *= -1 if $a < 0;
    $b *= -1 if $b < 0;

    if ($a < $b) {
	my $temp = $a;
	$a = $b;
	$b = $temp;
    }

    my $lastremainder = $b;

    while ((my $remainder = $a-(int($a/$b)*$b)) != 0) {
	$a = $b;
	$b = $remainder;
	$lastremainder = $remainder;
    }

    return $lastremainder;
}

sub normalize_coeff {
    my ($coeff) = @_;

    return $coeff if (not ref $coeff);

    return 0 if $$coeff[0] == 0;

    my $gcd = &gcd($$coeff[0],$$coeff[1]);

    $$coeff[0] /= $gcd;
    $$coeff[1] /= $gcd;

    return $$coeff[0] if $$coeff[1] == 1;

    return $coeff;
}

sub add_coeffs {
    my @coeffs = @_;
    # print STDERR Dumper(@coeffs), "\n";
    shift @coeffs if not defined $coeffs[0];
    my @quotient = ref $coeffs[0] ? (${$coeffs[0]}[0],${$coeffs[0]}[1]) : ($coeffs[0],1);
    my $result = ref $coeffs[0] ? undef : $coeffs[0];
    shift @coeffs;
    foreach my $coeff (@coeffs) {
	if (ref $coeff) {
	    $quotient[0]=$$coeff[0]*$quotient[1]+$$coeff[1]*$quotient[0];
	    $quotient[1]=$quotient[1]*$$coeff[1];
	    undef $result;
	} else {
	    $quotient[0] += $quotient[1]*$coeff;
	    $result += $coeff if (defined $result);
	}
    }
    return &normalize_coeff(defined $result ? $result : \@quotient);
}

sub subtract_coeffs {
    my @coeffs = @_;
    $coeffs[0]=0 if not defined $coeffs[0];
    my @quotient = ref $coeffs[0] ? (${$coeffs[0]}[0],${$coeffs[0]}[1]) : ($coeffs[0],1);
    my $result = ref $coeffs[0] ? undef : $coeffs[0];
    shift @coeffs;
    foreach my $coeff (@coeffs) {
	if (ref $coeff) {
	    $quotient[0]=$$coeff[0]*$quotient[1]-$$coeff[1]*$quotient[0];
	    $quotient[1]=$quotient[1]*$$coeff[1];
	    undef $result;
	} else {
	    $quotient[0] -= $quotient[1]*$coeff;
	    $result -= $coeff if (defined $result);
	}
    }
    return &normalize_coeff(defined $result ? $result : \@quotient);
    return defined $result ? $result : \@quotient;
}

sub multiply_coeffs {
    my @coeffs = @_;
    shift @coeffs if not defined $coeffs[0];
    my @quotient = ref $coeffs[0] ? (${$coeffs[0]}[0],${$coeffs[0]}[1]) : ($coeffs[0],1);
    my $result = ref $coeffs[0] ? undef : $coeffs[0];
    shift @coeffs;
    foreach my $coeff (@coeffs) {
	if (ref $coeff) {
	    $quotient[0]=$$coeff[0]*$quotient[0];
	    $quotient[1]=$quotient[1]*$$coeff[1];
	    undef $result;
	} else {
	    $quotient[0] *= $coeff;
	    $result *= $coeff if (defined $result);
	}
    }
    return &normalize_coeff(defined $result ? $result : \@quotient);
    return defined $result ? $result : \@quotient;
}

sub divide_coeffs {
    my @coeffs = @_;
    $coeffs[0]=1 if not defined $coeffs[0];
    my @quotient = ref $coeffs[0] ? (${$coeffs[0]}[0],${$coeffs[0]}[1]) : ($coeffs[0],1);
    my $result = ref $coeffs[0] ? undef : $coeffs[0];
    shift @coeffs;
    foreach my $coeff (@coeffs) {
	if (ref $coeff) {
	    $quotient[0]=$$coeff[1]*$quotient[0];
	    $quotient[1]=$quotient[1]*$$coeff[0];
	    undef $result;
	} else {
	    #$quotient[0] /= $coeff;
	    $quotient[1] *= $coeff;
	    $result /= $coeff if (defined $result);
	}
    }
    return &normalize_coeff(defined $result ? $result : \@quotient);
    #return defined $result ? $result : \@quotient;
    $result = defined $result ? $result : \@quotient;
    #print STDERR "divide_coeffs: ", Dumper($result), "\n";
    return $result;
}

# Polynomial internal format: list of length equal to degree of poly
# Each item in list is coeff of that term
# So, x^2 = [0, 0, 1]
# Also, $poly_var{ref to poly} contains the variable letter of poly

sub parse_poly {
    my ($polytext) = @_;
    my @poly;

    while ($polytext =~ s|^\s*([+-]?[0-9/]*)([a-z])?(\^([0-9]*))?||) {
	last if ($1 eq "" and $2 eq "" and $3 eq "");
	my $coeff = $1;
	my $power = $4;

	if ($2 ne "") {
	    if (not exists $poly_var{\@poly}) {
		$poly_var{\@poly} = $2;
	    } else {
		die "inconsistent poly vars in parse" if $poly_var{\@poly} ne $2;
	    }
	}

	if ($coeff eq "" or $coeff eq "+") {
	    $coeff = 1;
	} elsif ($coeff eq "-") {
	    $coeff = -1;
	} else {
	    #print STDERR $coeff;
	    #$coeff = eval "$coeff + 0";
	    $coeff = &parse_coefficient($coeff);
	    #print STDERR " ", $coeff, "\n",
	}
	$power = "1" if ($power eq "");
	$power = "0" if ($2 eq "");
	#print STDERR "$coeff $power\n";
	$poly[$power] = $coeff;
    }
    #$poly_var{\@poly} = "x";
    #print STDERR Dumper(\@poly);
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

    #print STDERR "texformat_fraction: ", Dumper($number), "\n";

    if (ref $number) {
	return "{" . $$number[0] . "\\over " . $$number[1] . "}";
    }

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

    #print STDERR Dumper($poly);
    for (my $power=$#$poly; $power>=0; $power--) {
	#my $coeff = $$poly[$power] + 0;
	my $coeff = $$poly[$power];
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
	    $result .= $coeff;
	} elsif ($power == 1) {
	    $result .= $coeff . $poly_var{$poly};
	} else {
	    $result .= ${coeff} . $poly_var{$poly} . "^$power";
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

    die "no poly var\n" unless exists $poly_var{$poly};

    for (my $power=$#$poly; $power>=0; $power--) {
	#my $coeff = $$poly[$power] + 0;
	my $coeff = $$poly[$power];
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
	    $result .= $poly_var{$poly} . "&";
	} else {
	    $result .= $poly_var{$poly} . "^$power&";
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


sub add_poly {
    my ($poly1, $poly2) = @_;
    my @result = (0);
    my $maxpower = ($#$poly1 > $#$poly2 ? $#$poly1 : $#$poly2);

    die "no poly var\n" unless exists $poly_var{$poly1};
    die "no poly var\n" unless exists $poly_var{$poly1};
    die "inconsistent poly vars\n" unless $poly_var{$poly1} eq $poly_var{$poly2};

    for (my $power = $maxpower; $power>=0; $power--) {
	my $coeff = &add_coeffs($$poly1[$power], $$poly2[$power]);
	$result[$power] = $coeff if $coeff != 0;
    }

    $poly_var{\@result} = $poly_var{$poly1};
    print STDERR "ADD ";
    print STDERR &format_poly_texformat($poly1), " + ", &format_poly_texformat($poly2), " = ", &format_poly_texformat(\@result), "\n";
    return \@result;
}

# &subtract_poly assumes that poly1's degree is >= poly2's degree

sub subtract_poly {
    my ($poly1, $poly2) = @_;
    my @result = (0);
    my $maxpower = ($#$poly1 > $#$poly2 ? $#$poly1 : $#$poly2);

    die "no poly var\n" unless exists $poly_var{$poly1};
    die "no poly var\n" unless exists $poly_var{$poly1};
    die "inconsistent poly vars\n" unless $poly_var{$poly1} eq $poly_var{$poly2};

    for (my $power = $maxpower; $power>=0; $power--) {
	my $coeff = &subtract_coeffs($$poly1[$power], $$poly2[$power]);
	$result[$power] = $coeff if $coeff != 0;
    }

    $poly_var{\@result} = $poly_var{$poly1};
    print STDERR "SUBTRACT ";
    print STDERR &format_poly_texformat($poly1), " - ", &format_poly_texformat($poly2), " = ", &format_poly_texformat(\@result), "\n";
    return \@result;
}

sub multiply_poly {
    my ($poly1, $poly2) = @_;
    my @result = (0);

    die "no poly var\n" unless exists $poly_var{$poly1};
    die "no poly var\n" unless exists $poly_var{$poly1};
    die "inconsistent poly vars\n" unless $poly_var{$poly1} eq $poly_var{$poly2};

    for (my $power1 = $#$poly1; $power1>=0; $power1--) {
	for (my $power2 = $#$poly2; $power2>=0; $power2--) {
	    my $coeff = &multiply_coeffs($$poly1[$power1], $$poly2[$power2]);
	    if ($coeff != 0) {
		if (exists $result[$power1+$power2]) {
		    $result[$power1+$power2] = &add_coeffs($result[$power1+$power2], $coeff);
		} else {
		    $result[$power1+$power2] = $coeff;
		}
	    }
	}
    }

    $poly_var{\@result} = $poly_var{$poly1};
    print STDERR "MULTIPLY ";
    print STDERR &format_poly_texformat($poly1), " * ", &format_poly_texformat($poly2), " = ", &format_poly_texformat(\@result), "\n";
    return \@result;
}

# &divide_leading_terms assumes that poly1's degree is >= poly2's degree

sub divide_leading_terms {
    my ($poly1, $poly2) = @_;
    my @result = (0);

    die "no poly var\n" unless exists $poly_var{$poly1};
    die "no poly var\n" unless exists $poly_var{$poly1};
    die "inconsistent poly vars\n" unless $poly_var{$poly1} eq $poly_var{$poly2};

    $result[$#$poly1 - $#$poly2] = &divide_coeffs($$poly1[$#$poly1], $$poly2[$#$poly2]);

    $poly_var{\@result} = $poly_var{$poly1};
    print STDERR "DIVIDE_LEADING_TERM ";
    print STDERR &format_poly_texformat($poly1), " / ", &format_poly_texformat($poly2), " = ", &format_poly_texformat(\@result), "\n";
    return \@result;
}

my $dividend = &parse_poly($ARGV[0]);
my $divisor = &parse_poly($ARGV[1]);

die "inconsistent poly vars\n" unless $poly_var{$dividend} eq $poly_var{$divisor};
my $quotient=[0];
$poly_var{$quotient}=$poly_var{$dividend};

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
    #&print_poly_texformat($remainders[$#remainders]);
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

my $numcols = 2*($#$dividend + 1 + $#$divisor + 1);

print STDERR "numcols = $numcols = 2*($#$dividend + 1 + $#$divisor + 1)\n";

# add one more column for closing paren at end if $use_parens

print "\\vbox{\\offinterlineskip\n";
print "\\tabskip=0pt plus1fil\n";
print "\\halign to\\hsize{\\tabskip=0pt";
for (my $i=($use_parens?0:1); $i<=$numcols; $i++) {
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

	# Insane code.  We want to span up to the first text of the
	# polynomial to put a leading "-(" in.  Need to span an extra
	# column if the first column of the poly isn't really occupied
	# by anything.  Also have to explicitly enter (by printing)
	# and leave (by modifying poly) math mode.

	my $multispan_cols = $numcols - (2*$#{$sterms[$i]}+2)+1;
	my $poly =  &format_poly_textableformat($sterms[$i]);
	if ($poly =~ s/^&//) {
	    $multispan_cols ++;
	}
	$poly =~ s/&/\$&/;
	print "\\multispan{", $multispan_cols, "}";
	print "\\hfil \$-(";
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
