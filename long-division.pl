#!/usr/bin/perl

use strict;

use Data::Dumper;

# for debugging messages
open(DEBUG, ">&STDERR");

my $use_parens = 1;

my %poly_var;

my $indent_level=0;
sub indent {
    return substr("                         ",0,$indent_level++);
}
sub exdent {
    $indent_level--;
    return substr("                         ",0,$indent_level);
}

sub add;
sub subtract;
sub multiply;
sub divide;
sub divide_leading_terms;
sub longdivide_poly;
sub texformat;
sub textableformat;

sub ispoly {
    my ($arg) = @_;

    return ((ref $arg) and (exists $poly_var{$arg}));
}

sub ismonomial {
    my ($arg) = @_;

    return 0 unless &ispoly($arg);
    return 1 if ($#$arg == -1);

    for (my $power=$#$arg-1; $power>=0; $power--) {
	return 0 if (defined $$arg[$power] and $$arg[$power] != 0);
    }
    return 1;

}

sub isfraction {
    my ($arg) = @_;

    return ((ref $arg) and (not exists $poly_var{$arg}));
}

sub ispositive {
    my ($coeff) = @_;

    return ($coeff > 0) if not ref $coeff;

    #die "can't test &ispositive on a polynomial" if exists $poly_var{$coeff};
    #return 1 if exists $poly_var{$coeff};
    return &ispositive($$coeff[$#$coeff]) if (&ispoly($coeff));

    return (&ispositive($$coeff[0]));
}

sub negate {
    my ($coeff) = @_;

    return (-$coeff) if not ref $coeff;

    if (&ispoly($coeff)) {
	#my @poly = map &negate($_), @$coeff;
	#die "ispoly " . &texformat($coeff);
	my @poly;
	for (my $power=$#$coeff; $power>=0; $power--) {
	    $poly[$power] = &negate($$coeff[$power]);
	}
	$poly_var{\@poly} = $poly_var{$coeff};
	return \@poly;
    }

    my $result = [&negate($$coeff[0]), $$coeff[1]];
    delete $poly_var{$result};
    return $result;
}

sub swap {
    my ($ref1, $ref2) = @_;
    my $temp;

    die "bad swap" if not ref $ref1 or not ref $ref2;
    $temp = $$ref1;
    $$ref1 = $$ref2;
    $$ref2 = $temp;
}

# The purpose of this routine is to extract common denominators from
# the coefficients of a polynomial.  Multiplying the polynomial by the
# result is guaranteed to cancel the denominators (though it may
# produce common factors in the coefficients).

sub denominator_common_multiple {
    my ($poly) = @_;

    if (&isfraction($poly)) {
	return $$poly[1];
    } elsif (not &ispoly($poly)) {
	return $poly;
    } else {
	my $multiple=1;
	for (my $power=$#$poly; $power>=0; $power--) {
	    if (&isfraction($$poly[$power])) {
		$multiple = &multiply($multiple, ${$$poly[$power]}[1]);
	    }
	}
	return $multiple;
    }
}

sub gcd {
    my ($a,$b) = @_;
    my $result;

    print DEBUG &indent, "GCD ", &texformat($a), " ", &texformat($b), "\n";

    if (not ref $a and not ref $b) {
	# two integers
	$a = &negate($a) if not &ispositive($a);
	$b = &negate($b) if not &ispositive($b);

	swap(\$a, \$b) if (not &ispositive(&subtract($a, $b)));

	my $dividend = $a;
	my $divisor = $b;

	while ($divisor != 0) {
	    my $quotient = int($dividend/$divisor);
	    my $remainder = $dividend - $quotient*$divisor;
	    $dividend = $divisor;
	    $divisor = $remainder;
	}

	$result =  $dividend;

    } else {

	if (exists $poly_var{$a} and exists $poly_var{$b}) {
	    # two polynomials
	    swap(\$a, \$b) if ($#$a < $#$b);
	}

	swap(\$a, \$b) if (not exists $poly_var{$a} and exists $poly_var{$b});

	if (exists $poly_var{$a} and not ref $b) {

	    # a polynomial and an integer
	    # recuse into a gcd of poly's coeffs w/integer

	    my $contenta;

	    for (my $power=$#$a; $power>=0; $power--) {
		if (defined $$a[$power] and $$a[$power] != 0) {
		    if (defined $contenta) {
			$contenta = &gcd($contenta, $$a[$power]);
		    } else {
			$contenta = $$a[$power];
		    }
		}
	    }

	    $result = &gcd($contenta,$b);

	} elsif (exists $poly_var{$a} and ref $b and not exists $poly_var{$b}) {
	    # a polynomial and a rational fraction
	    die "polynomial and rational fraction";

	} else {

	    # two polynomials

	    my $contenta;
	    my $contentb;

	    for (my $power=$#$a; $power>=0; $power--) {
		if (defined $$a[$power] and $$a[$power] != 0) {
		    if (defined $contenta) {
			$contenta = &gcd($contenta, $$a[$power]);
		    } else {
			$contenta = $$a[$power];
		    }
		}
	    }

	    for (my $power=$#$b; $power>=0; $power--) {
		if (defined $$b[$power] and $$b[$power] != 0) {
		    if (defined $contentb) {
			$contentb = &gcd($contentb, $$b[$power]);
		    } else {
			$contentb = $$b[$power];
		    }
		}
	    }

	    print DEBUG &indent, "CONTENTA ", &texformat($contenta), " CONTENTB ", &texformat($contentb), "\n";
	    &exdent;

	    #my $dividend = $a;
	    #my $divisor = $b;
	    my $dividend = &divide($a,$contenta);
	    my $divisor = &divide($b,$contentb);

	    while ($divisor != 0) {
		print DEBUG "DD ",&texformat($dividend), " ", &texformat($divisor), "\n";
		my ($quotient, $remainder);
		if (exists $poly_var{$divisor}) {
		    ($quotient, $remainder) = &longdivide_poly($dividend, $divisor);
		} elsif (exists $poly_var{$dividend}) {
		    my @poly = ($divisor);
		    $poly_var{\@poly} = $poly_var{$dividend};
		    ($quotient, $remainder) = &longdivide_poly($dividend, \@poly);
		} else {
		    $quotient = &divide($dividend, $divisor);
		    $remainder = 0;
		}
		$dividend = $divisor;
		$divisor = $remainder;
	    }

	    if (&ispoly($dividend)) {

		my $dividend_content;

		for (my $power=$#$dividend; $power>=0; $power--) {
		    if (defined $$dividend[$power] and $$dividend[$power] != 0) {
			if (defined $dividend_content) {
			    $dividend_content = &gcd($dividend_content, $$dividend[$power]);
			} else {
			    $dividend_content = $$dividend[$power];
			}
		    }
		}

		print DEBUG &indent, "DIVIDEND CONTENT ", &texformat($dividend_content), "\n";
		&exdent;
		$dividend = &divide($dividend,$dividend_content);
	    } else {
		die "not integer in GCD: " . &texformat($dividend) if ref $dividend;
		$dividend = 1;
	    }

	    $result = &multiply(&gcd($contenta,$contentb), $dividend);
	}
    }

    print DEBUG &exdent, "GCD ", &texformat($a), " ", &texformat($b), " = ", &texformat($result), "\n";

    return $result;
}

# &normalize_coeff - notice that it changes the thing passed in by reference

sub normalize {
    my ($coeff) = @_;
    my $result = $coeff;

    print DEBUG &indent, "NORMALIZE ", &texformat($coeff), "\n";

    if (ref $coeff) {

	if (exists $poly_var{$coeff}) {

	    if ($#$coeff <= 0) {
		$result = &normalize($$coeff[0]);
	    } else {
		for (my $power=$#$coeff; $power>=0; $power--) {
		    $$coeff[$power] = &normalize($$coeff[$power]);
		}
		$result = $coeff;
	    }

	} else {

	    $$coeff[0] = &normalize($$coeff[0]);
	    $$coeff[1] = &normalize($$coeff[1]);

	    if ($$coeff[0] == 0) {

		$result = 0;

	    } else {

		my $common_multiple_numerator;
		my $common_multiple_denominator;
		my $common_multiple;

		my @fraction;
		delete $poly_var{\@fraction};

		$common_multiple_numerator = &denominator_common_multiple($$coeff[0]);
		$common_multiple_denominator = &denominator_common_multiple($$coeff[1]);
		$common_multiple = &multiply($common_multiple_numerator,
					     $common_multiple_denominator);

		print DEBUG "COMMON MULTIPLE ", &texformat($common_multiple), "\n";

		$fraction[0] = &multiply($$coeff[0], $common_multiple);
		$fraction[1] = &multiply($$coeff[1], $common_multiple);

		my $gcd = &gcd($fraction[0],$fraction[1]);

		$fraction[0] = &divide($fraction[0], $gcd);
		$fraction[1] = &divide($fraction[1], $gcd);

		if ((not ref $fraction[1]) and ($fraction[1] < 0)) {
		    $fraction[0] = &negate($fraction[0]);
		    $fraction[1] = &negate($fraction[1]);
		}

		if ($fraction[1] == 1 ) {
		    $result = $fraction[0];
		} else {
		    $result = \@fraction;
		}
	    }
	}
    }

    print DEBUG &exdent, "NORMALIZE ", &texformat($coeff), " = ", &texformat($result), "\n";

    return $result;
}

# Polynomial internal format: list of length equal to degree of poly
# Each item in list is coeff of that term
# So, x^2 = [0, 0, 1]
# Also, $poly_var{ref to poly} contains the variable letter of poly

sub parse_coefficient {
    my ($coeff_text) = @_;
    my $sign = 1;

    $coeff_text =~ s/^\+//;
    $sign = -1 if ($coeff_text =~ s/^-//);
    #die if ($coeff_text =~ s/^-//);

    if ($coeff_text =~ m:^[0-9]+$:) {
	return $sign * ($coeff_text + 0);
    } elsif ($coeff_text =~ m:^([0-9]+)/([0-9]+)$:) {
	return [$sign * ($1 + 0), $2 + 0];
    } elsif ($coeff_text =~ m:^\(([^()]*)\)$:) {
	#return [&parse_poly($1), 1];
	my $result = &parse_poly($1);
	#print DEBUG "parse poly $sign ", &texformat($result), "\n";
	#die "negate " . &texformat($result) if ($sign == -1);
	return (($sign == -1) ? &negate($result) : $result);
    } else {
	die "can't parse coefficient \"$coeff_text\"";
    }
}

sub parse_poly {
    my ($polytext) = @_;
    my @poly;

    while (1) {

	my $coeff;
	my $polyvar;
	my $power;

	$polytext =~ s!^\s*!!;

	if ($polytext =~ m:^[+-]?\(:) {
	    $polytext =~ s!^([+-]?\([^()]*\))([a-z])?(\^([0-9]*))?!!;
	    $coeff = $1;
	    $polyvar = $2;
	    $power = $4;
	} else {
	    $polytext =~ s!^([+-]?[0-9/]*)([a-z])?(\^([0-9]*))?!!;
	    $coeff = $1;
	    $polyvar = $2;
	    $power = $4;
	}

	#print DEBUG "cpp: '$coeff' '$polyvar' '$power' '$polytext'\n";

	last if ($coeff eq "" and $polyvar eq "" and $power eq "");

	if ($polyvar ne "") {
	    if (not exists $poly_var{\@poly}) {
		$poly_var{\@poly} = $polyvar;
	    } else {
		die "inconsistent poly vars in parse" if $poly_var{\@poly} ne $polyvar;
	    }
	}

	if ($coeff eq "" or $coeff eq "+") {
	    $coeff = 1;
	} elsif ($coeff eq "-") {
	    $coeff = -1;
	} else {
	    #print DEBUG $coeff;
	    #$coeff = eval "$coeff + 0";
	    $coeff = &parse_coefficient($coeff);
	    #print DEBUG " ", $coeff, "\n",
	}
	$power = "1" if ($power eq "");
	$power = "0" if ($polyvar eq "");
	#print DEBUG "$coeff $power\n";
	$poly[$power] = $coeff;
    }
    #$poly_var{\@poly} = "x";
    #print DEBUG Dumper(\@poly);
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

    #print DEBUG "texformat_fraction: ", Dumper($number), "\n";

    if (ref $number) {
	return "{" . &texformat($$number[0]) . "\\over " . &texformat($$number[1]) . "}";
    }

    return $number if (int($number) == $number);

    die "Fraction in texformat_fraction!";

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

    #print DEBUG Dumper($poly);
    for (my $power=$#$poly; $power>=0; $power--) {
	#my $coeff = $$poly[$power] + 0;
	my $coeff = $$poly[$power];
	next if ($coeff == 0);
	if (exists $poly_var{$coeff}) {
	    if (not &ispositive($coeff)) {
		$result .= "-";
		$coeff = &negate($coeff);
	    } elsif ($power < $#$poly) {
		$result .= "+";
	    }
	    if (&ismonomial($coeff)) {
		$result .= &texformat($coeff);
	    } else {
		$result .= "(" . &texformat($coeff) . ")";
	    }
	} elsif ($coeff == 1 and $power > 0) {
	    $result .= "+" unless ($power == $#$poly);
	} elsif ($coeff == -1 and $power > 0) {
	    $result .= "-";
	} elsif (&ispositive($coeff)) {
	    $result .= "+" unless ($power == $#$poly);
	    $result .= &texformat($coeff);
	} else {
	    $result .= "-" . &texformat(&negate($coeff));
	}

	if ($power == 1) {
	    $result .= $poly_var{$poly};
	} elsif ($power > 1) {
	    $result .= $poly_var{$poly} . "^$power";
	}
    }
    $result = "0" if $result eq "";
    return $result;
    #return "[" . $result . ";$#$poly]";
    #return "[" . $result . "]";
}

sub texformat {
    my ($arg) = @_;

    if (not defined $arg) {
	return "UNDEF";
    } elsif (exists $poly_var{$arg}) {
	return &format_poly_texformat($arg);
    } else {
	return &texformat_fraction($arg);
    }
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

    if (not exists $poly_var{$poly}) {
	if (&ispositive($poly) or $poly == 0) {
	    $result .= "&" . &texformat($poly);
	} else {
	    $result .= "-&" . &texformat(&negate($poly));
	}
	return $result;
    }

    for (my $power=$#$poly; $power>=0; $power--) {
	#my $coeff = $$poly[$power] + 0;
	my $coeff = $$poly[$power];
	if ($coeff == 0) {
	    $result .= "&&";
	    next;
	}
	if (exists $poly_var{$coeff}) {
	    if (not &ispositive($coeff)) {
		$result .= "-&";
		$coeff = &negate($coeff);
	    } elsif ($power == $#$poly) {
		$result .= "&";
	    } else {
		$result .= "+&";
	    }
	    if (&ismonomial($coeff)) {
		$result .= &texformat($coeff);
	    } else {
		$result .= "(" . &texformat($coeff) . ")";
	    }
	} elsif ($coeff == 1 and $power > 0) {
	    if ($power == $#$poly) {
		$result .= "&";
	    } else {
		$result .= "+&";
	    }
	} elsif ($coeff == -1 and $power > 0) {
	    $result .= "-&";
	} elsif (&ispositive($coeff)) {
	    if ($power == $#$poly) {
		$result .= "&";
	    } else {
		$result .= "+&";
	    }
	    $result .= &texformat($coeff);
	} else {
	    $result .= "-&" . &texformat(&negate($coeff));
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


sub add_coeffs {
    my ($arg1, $arg2) = @_;
    my @quotient;
    delete $poly_var{\@quotient};

    return $arg2 if not defined $arg1;
    return $arg1 if not defined $arg2;

    swap(\$arg1, \$arg2) if not ref $arg1 and ref $arg2;

    if (ref $arg1 and ref $arg2) {
	$quotient[0]=&add(&multiply($$arg2[0],$$arg1[1]),
			  &multiply($$arg2[1],$$arg1[0]));
	$quotient[1]=&multiply($$arg1[1],$$arg2[1]);
	return &normalize(\@quotient);
    } elsif (ref $arg1) {
	$quotient[0] = &add($$arg1[0],&multiply($$arg1[1],$arg2));
	$quotient[1] = $$arg1[1];
	return &normalize(\@quotient);
    } else {
	return $arg1 + $arg2;
    }
}

sub subtract_coeffs {
    my ($arg1, $arg2) = @_;
    my @quotient;

    return &negate($arg2) if not defined $arg1;
    return $arg1 if not defined $arg2;

    return &add_coeffs($arg1, &negate($arg2));
}

sub multiply_coeffs {
    my ($arg1, $arg2) = @_;
    my @quotient;
    delete $poly_var{\@quotient};

    return $arg2 if not defined $arg1;
    return $arg1 if not defined $arg2;

    swap(\$arg1, \$arg2) if (not ref $arg1) and (ref $arg2);

    if (ref $arg1 and ref $arg2) {
	$quotient[0]=&multiply($$arg1[0],$$arg2[0]);
	$quotient[1]=&multiply($$arg1[1],$$arg2[1]);
	return &normalize(\@quotient);
    } elsif (ref $arg1) {
	$quotient[0] = &multiply($$arg1[0],$arg2);
	$quotient[1] = $$arg1[1];
	return &normalize(\@quotient);
    } else {
	return $arg1 * $arg2;
    }
}

sub divide_coeffs {
    my ($arg1, $arg2) = @_;
    my @quotient;
    delete $poly_var{\@quotient};

    return $arg2 if not defined $arg1;
    return $arg1 if not defined $arg2;

    if (ref $arg1 and ref $arg2) {
	$quotient[0]=&multiply($$arg1[0],$$arg2[1]);
	$quotient[1]=&multiply($$arg1[1],$$arg2[0]);
	return &normalize(\@quotient);
    } elsif (ref $arg1) {
	$quotient[0] = $$arg1[0];
	$quotient[1] = &multiply($$arg1[1],$arg2);
	return &normalize(\@quotient);
    } elsif (ref $arg2) {
	$quotient[0] = &multiply($arg1,$$arg2[1]);
	$quotient[1] = $$arg2[0];
	return &normalize(\@quotient);
    } elsif ($arg1 == $arg2*int($arg1/$arg2)) {
	# need to check for exact division here to avoid the call
	# to normalize below, which could cause an infinite loop
	return int($arg1/$arg2);
    } else {
	$quotient[0] = $arg1;
	$quotient[1] = $arg2;
	return &normalize(\@quotient);
	#return $arg1 / $arg2;
    }
}

sub add_poly {
    my ($poly1, $poly2) = @_;
    my @result = (0);
    my $maxpower = ($#$poly1 > $#$poly2 ? $#$poly1 : $#$poly2);

    die "no poly var\n" unless exists $poly_var{$poly1};
    die "no poly var\n" unless exists $poly_var{$poly1};
    die "inconsistent poly vars\n" unless $poly_var{$poly1} eq $poly_var{$poly2};

    for (my $power = $maxpower; $power>=0; $power--) {
	my $coeff = &add($$poly1[$power], $$poly2[$power]);
	$result[$power] = $coeff if $coeff != 0;
    }

    $poly_var{\@result} = $poly_var{$poly1};
    return \@result;
}

sub subtract_poly {
    my ($poly1, $poly2) = @_;
    my @result = (0);
    my $maxpower = ($#$poly1 > $#$poly2 ? $#$poly1 : $#$poly2);

    die "no poly var\n" unless exists $poly_var{$poly1};
    die "no poly var\n" unless exists $poly_var{$poly1};
    die "inconsistent poly vars\n" unless $poly_var{$poly1} eq $poly_var{$poly2};

    for (my $power = $maxpower; $power>=0; $power--) {
	my $coeff = &subtract($$poly1[$power], $$poly2[$power]);
	$result[$power] = $coeff if $coeff != 0;
    }

    # if everything's gone except for (possibly) the constant term...
    return $result[0] if ($#result <= 0);

    $poly_var{\@result} = $poly_var{$poly1};
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
	    my $coeff = &multiply($$poly1[$power1], $$poly2[$power2]);
	    if (defined $coeff and $coeff != 0) {
		if (exists $result[$power1+$power2]) {
		    $result[$power1+$power2] = &add($result[$power1+$power2], $coeff);
		} else {
		    $result[$power1+$power2] = $coeff;
		}
	    }
	}
    }

    $poly_var{\@result} = $poly_var{$poly1};
    return &normalize(\@result);
}

# &divide_leading_terms assumes that poly1's degree is >= poly2's degree

sub divide_leading_terms_poly {
    my ($poly1, $poly2) = @_;
    my @result = (0);

    die "no poly var\n" unless exists $poly_var{$poly1};
    die "no poly var\n" unless exists $poly_var{$poly1};
    die "inconsistent poly vars\n" unless $poly_var{$poly1} eq $poly_var{$poly2};

    $result[$#$poly1 - $#$poly2] = &divide($$poly1[$#$poly1], $$poly2[$#$poly2]);

    $poly_var{\@result} = $poly_var{$poly1};
    return \@result;
}

# polynomial long division - returns two results (quotient and remainder)

sub longdivide_poly
{
    my ($a, $b) = @_;
    my $quotient=0;
    my $remainder=$a;

    while ($poly_var{$remainder} eq $poly_var{$a} and $#$remainder >= $#$b) {
	my $spoly = &divide_leading_terms($a,$b);
	$quotient = &add($quotient, $spoly);
	$remainder = &subtract($remainder, &multiply($spoly, $b));
    }

    return ($quotient, $remainder);
}

sub add {
    my ($arg1, $arg2) = @_;
    my $result;

    print DEBUG &indent, "ADD ";
    print DEBUG &texformat($arg1), " + ", &texformat($arg2), "\n";

    if (not defined $arg1) {
	$result = $arg2;
    } elsif (not exists $poly_var{$arg1} and not exists $poly_var{$arg2}) {
	# adding two fractions
	$result = &add_coeffs($arg1, $arg2);
    } elsif (exists $poly_var{$arg1} and not exists $poly_var{$arg2}) {
	my @quotient = @$arg1;
	$quotient[0] = &add_coeffs($quotient[0], $arg2);
	$poly_var{\@quotient} = $poly_var{$arg1};
	$result = \@quotient;
    } elsif (not exists $poly_var{$arg1} and exists $poly_var{$arg2}) {
	$result = &add($arg2,$arg1);
    } elsif ($poly_var{$arg1} ne $poly_var{$arg2}) {
	die "incompatiable arguments";
    } else {
	$result = &add_poly($arg1, $arg2);
    }
    print DEBUG &exdent, "ADD ";
    print DEBUG &texformat($arg1), " + ", &texformat($arg2), " = ", &texformat($result), "\n";
    return $result;
}

sub subtract {
    my ($arg1, $arg2) = @_;
    my $result;

    print DEBUG &indent, "SUBTRACT ";
    print DEBUG &texformat($arg1), " - ", &texformat($arg2), "\n";

    if (not defined $arg1) {
	$result = &normalize(&negate($arg2));
    } elsif (not exists $poly_var{$arg1}) {
	die "incompatiable arguments" if exists $poly_var{$arg2};
	$result = &normalize(&subtract_coeffs($arg1, $arg2));
    } elsif (not exists $poly_var{$arg2}) {
	my @poly = @$arg1;
	$poly_var{\@poly} = $poly_var{$arg1};
	$poly[0] = &subtract_coeffs($poly[0], $arg2);
	$result = &normalize(\@poly);
	#die "incompatiable arguments";
    } elsif ($poly_var{$arg1} ne $poly_var{$arg2}) {
	die "incompatiable arguments";
    } else {
	$result = &normalize(&subtract_poly($arg1, $arg2));
    }

    print DEBUG &exdent, "SUBTRACT ";
    print DEBUG &texformat($arg1), " - ", &texformat($arg2), " = ", &texformat($result), "\n";
    return $result;
}

sub multiply {
    my ($arg1, $arg2) = @_;
    my $result;

    print DEBUG &indent, "MULTIPLY ";
    print DEBUG &texformat($arg1), " * ", &texformat($arg2), "\n";

    if (not defined $arg1 or not defined $arg2) {
	# maybe this should return zero?
	# $result = $arg2;
	# $result = undef;
	$result = 0;
    } elsif (not exists $poly_var{$arg1} and not exists $poly_var{$arg2}) {
	print DEBUG "multiplying two fractions\n";
	$result = &normalize(&multiply_coeffs($arg1, $arg2));
    } elsif (exists $poly_var{$arg1} and not exists $poly_var{$arg2}) {
	print DEBUG "multiplying polynomial by non-polynomial\n";
	if (ref $arg2 and $poly_var{$$arg2[1]} eq $poly_var{$arg1}) {
	    # multiplying a polynomial by a fraction with that
	    # polynomial's var in the denominator
	    print DEBUG "multiplying poly by fraction w/that poly in denom\n";
	    my @fraction = @$arg2;
	    delete $poly_var{\@fraction};
	    $fraction[0]=&multiply($fraction[0],$arg1);
	    $result = &normalize(\@fraction);
	} else {
	    my @quotient;
	    for (my $power = $#$arg1; $power>=0; $power--) {
		my $coeff = &multiply($$arg1[$power], $arg2);
		$quotient[$power] = $coeff if ($coeff != 0);
		#print DEBUG "power $power $coeff ", &texformat($coeff), "\n";
	    }
	    $poly_var{\@quotient} = $poly_var{$arg1};
	    $result = &normalize(\@quotient);
	}
    } elsif (not exists $poly_var{$arg1} and exists $poly_var{$arg2}) {
	$result = &multiply($arg2,$arg1);
    } elsif ($poly_var{$arg1} ne $poly_var{$arg2}) {
	die "incompatiable arguments";
    } else {
	print DEBUG "multiplying two polynomials\n";
	$result = &normalize(&multiply_poly($arg1, $arg2));
    }
    print DEBUG &exdent, "MULTIPLY ";
    print DEBUG &texformat($arg1), " * ", &texformat($arg2), " = ", &texformat($result), "\n";
    return $result;
}

sub divide {
    my ($arg1, $arg2) = @_;
    my $result;

    print DEBUG &indent, "DIVIDE ";
    print DEBUG &texformat($arg1), " / ", &texformat($arg2), "\n";

    if (not defined $arg1) {
	# undef = zero
	# die "empty division";
	$result = undef;
    } elsif (not exists $poly_var{$arg1} and not exists $poly_var{$arg2}) {
	# dividing two fractions into each other
	$result = &normalize(&divide_coeffs($arg1, $arg2));
    } elsif (exists $poly_var{$arg1} and not exists $poly_var{$arg2}) {
	# dividing polynomial by non-polynomial
	# die "incompatiable arguments";
	my @quotient;
	for (my $power = $#$arg1; $power>=0; $power--) {
	    $quotient[$power] = &divide($$arg1[$power], $arg2);
	}
	$poly_var{\@quotient} = $poly_var{$arg1};
	$result = &normalize(\@quotient);
    } elsif (not exists $poly_var{$arg1} and exists $poly_var{$arg2}) {
	# dividing non-polynomial by polynomial
	#die "incompatiable arguments";
	$result = &normalize([$arg1, $arg2]);
    } elsif ($poly_var{$arg1} ne $poly_var{$arg2}) {
	die "incompatiable arguments";
    } else {
	my ($quotient, $remainder) = &longdivide_poly($arg1, $arg2);
	if ($remainder != 0) {
	    my @fraction = ($arg1, $arg2);
	    delete $poly_var{\@fraction};
	    $result = &normalize(\@fraction);
	} else {
	    $result = &normalize($quotient);
	}
	#return &divide_poly($arg1, $arg2);
    }

    print DEBUG &exdent, "DIVIDE ";
    print DEBUG &texformat($arg1), " / ", &texformat($arg2), " = ", &texformat($result), "\n";
    return $result;
}

sub divide_leading_terms {
    my ($arg1, $arg2) = @_;
    my $result;

    print DEBUG &indent, "DIVIDE_LEADING_TERMS ";
    print DEBUG &texformat($arg1), " / ", &texformat($arg2), "\n";

    if (not defined $arg1) {
	die "empty division";
	$result = $arg2;
    } elsif (not exists $poly_var{$arg1}) {
	die "incompatiable arguments" if exists $poly_var{$arg2};
	die "what do we do here?" if ref $arg1 or ref $arg2;
	$result = int($arg1/$arg2);
	#return &divide_coeffs($arg1, $arg2);
    } elsif (not exists $poly_var{$arg2}) {
	#die "incompatiable arguments";
	my @poly = ($arg2);
	$poly_var{\@poly} = $poly_var{$arg1};
	$result = &divide_leading_terms_poly($arg1, \@poly);
    } elsif ($poly_var{$arg1} ne $poly_var{$arg2}) {
	die "incompatiable arguments";
    } else {
	$result = &divide_leading_terms_poly($arg1, $arg2);
    }

    print DEBUG &exdent, "DIVIDE_LEADING_TERMS ";
    print DEBUG &texformat($arg1), " / ", &texformat($arg2), , " = ", &texformat($result), "\n";
    return $result;
}

my $dividend = &parse_poly($ARGV[0]);
my $divisor = &parse_poly($ARGV[1]);

die "inconsistent poly vars\n" unless $poly_var{$dividend} eq $poly_var{$divisor};
my $quotient=[0];
$poly_var{$quotient}=$poly_var{$dividend};

my @remainders = ($dividend);
my @sterms = ([0]);
my @multiples = ([0]);

while ($poly_var{$remainders[$#remainders]} eq $poly_var{$dividend}
       and $#{$remainders[$#remainders]} >= $#$divisor) {
    my $multiple = &divide_leading_terms($remainders[$#remainders],$divisor);
    my $sterm = &multiply($multiple, $divisor);
    $quotient = &add($quotient,$multiple);
    push @remainders, &subtract($remainders[$#remainders], $sterm);
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
print DEBUG &format_poly_textableformat($quotient), "\n";
print DEBUG &format_poly_textableformat($divisor), "\n";
print DEBUG &format_poly_textableformat($dividend), "\n";

my $numcols = 2*($#$dividend + 1 + $#$divisor + 1);

print DEBUG "numcols = $numcols = 2*($#$dividend + 1 + $#$divisor + 1)\n";

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

    #print DEBUG $#{$remainders[$i]}, " ", &format_poly_texformat($remainders[$i]),"\n";
    if (exists $poly_var{$remainders[$i]}) {
	print "\\multispan{", $numcols - (2*$#{$remainders[$i]}+2), "}&";
	print &format_poly_textableformat($remainders[$i]);
    } else {
	print "\\multispan{", $numcols - 2, "}&";
	print &format_poly_textableformat($remainders[$i]);
    }
    print "\\vbox to16pt{}\\cr\n";
}

print "}}\n";
